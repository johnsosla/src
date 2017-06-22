/** ------------------------------------------------------------------------------------------------------------
* @Description Creates "Historical" Project Snapshots for a given fiscal year
*              only at batch size of 1, with regionalization and rerun for failed jobs.
*
* @Author      Jake White
* @Date        November 2016
*--------------------------------------------------------------------------------------------------------------*/
global class ECO_GroupedBatchProjectSnapshot_FY2015 extends ECO_BatchAdminService {

    private static final Integer THIS_JOB_FISCAL_YEAR = 2015;  // Unique jobs for each FY
    private static final String THIS_JOB_TITLE = 'Setup - Snapshot History FY2015'; // Should match Custom setting job title
    private static final String THIS_CLASS_NAME = 'ECO_GroupedBatchProjectSnapshot_FY2015';

    public static final Integer DEFAULT_BATCH_SIZE = 1;
    private static final ECO_Service_ProjectSnapshots.SnapshotKeyRule DEFAULT_SNAPSHOT_KEY_RULE = ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END;

    String query;

    /**
     *  constructor
     *
     * @Author  AECOM - Jake White
     * @Date    November 2016
     *
     * @param
     **/
    global ECO_GroupedBatchProjectSnapshot_FY2015() {
      this.batchSize = DEFAULT_BATCH_SIZE;
    }

    /**
     *  batch start
     *
     * @Author  AECOM - Jake White
     * @Date    November 2016
     *
     * @param
     **/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //log the job start
        this.logId = ECO_Service_BatchLog.logJobStart(THIS_JOB_TITLE, this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);

        // Creates Historical Snapshots for a given fiscal year for a single project

        if( this.isProcessingBlock){
            query = 'SELECT Id, ' +
                    'SObjectID__c ' +
                    'FROM BatchedObject__c ' +
                    'WHERE ChildrenComplete__c=false ' +
                    '   AND PriorityRequestBy__c != null' +
                    '   AND BatchJob__c=\''+THIS_JOB_TITLE+'\'';
        } else {
            query = 'SELECT Id, ' +
                    'SObjectID__c ' +
                    'FROM BatchedObject__c ' +
                    'WHERE ChildrenComplete__c=false ' +
										'   AND BatchJob__c=\''+THIS_JOB_TITLE+'\'';
        }


       System.debug('__query='+query);
       return Database.getQueryLocator(query);
    }

    /**
     *  batch execute
     *
     * @Author  AECOM - Jake White
     * @Date    November 2016
     *
     * @param
     **/
    global void execute(Database.BatchableContext BC, List<BatchedObject__c> scope) {
        // convert pse__Proj__c records (a subset of the original requested list) to a list of Ids
        String jsonBO = '';
        jsonBO = '\n' + JSON.serialize(scope, true);

        try{

            // convert pse__Proj__c records (a subset of the original requested list) to a list of Ids
            List<Id> projectIds = new List<Id>();
            set<Id> boID = new set<Id>();
            for (BatchedObject__c ps : scope) {
                projectIds.add((id)ps.SObjectID__c);
                boID.add(ps.id);
            }

			System.Assert(scope.size()==1,'This job runs only at a batch size of 1.');
			ECO_Service_ProjectSnapshots.ECO_ProjectSnapshotBatch_MonthEnd_Init( projectIds[0] , THIS_JOB_FISCAL_YEAR);

            list<BatchedChildObject__c> lstBco = new list<BatchedChildObject__c>();

            for(BatchedChildObject__c oBatchChild : [select id, SObjectID__c from BatchedChildObject__c where BatchedObject__c IN: boID]){
                System.debug('@@@GOT HERE FOR oBatchChild: ' + oBatchChild.sObjectId__c);

                BatchedChildObject__c boc = new BatchedChildObject__c(id=oBatchChild.id, ChildStatus__c = 'Completed');
                //oBatchChild.ChildStatus__c = 'Completed';
                lstBco.add(boc);
            }

            try{
                update lstBco;
            } catch (Exception ex) {
                ECO_Service_ErrorLog.logException(ex, jsonBO);
            }

        } catch (Exception ex) {
            ECO_Service_ErrorLog.logException(ex, jsonBO);
        }

    }

    /**
     *  batch finish
     *
     * @Author  AECOM - Jake White
     * @Date    November 2016
     *
     * @param
     **/
    global void finish(Database.BatchableContext BC) {

        //log the end of the job and possible call the next job in the stream
        runNextBatchInStream( BC.getJobId(), THIS_CLASS_NAME);
    }

    /**
     *  This should not be run in a scheduled context
     *
     * @Author  AECOM - Jake White
     * @Date    Oct 2016
     *
     * @param
     **/
    global void execute(SchedulableContext sc) {}
}