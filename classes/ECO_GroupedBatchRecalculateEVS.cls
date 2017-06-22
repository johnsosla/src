/** ------------------------------------------------------------------------------------------------------------
* @Description This class runs the Batch job for "Recalculate Earned Value (EV)" process, based on the job Location
*              and can also be rerun for failed jobs.
*
* @Author      NTT Data - Tim Chiang
* @Date        September 2016
*--------------------------------------------------------------------------------------------------------------*/

global class ECO_GroupedBatchRecalculateEVS extends ECO_BatchAdminService {
    
    String query;
    Set<Id> lProjectsRefreshed;
    List<Id> projectIds;
    boolean bRebuildCostActuals = true;
    
    /**
     *  default constructor
     *
     * @Author  NTT Data - Michael Lawrence
     * @Date    April 2016
     *
     * @param   
     **/
    global ECO_GroupedBatchRecalculateEVS() {
        //query = 'select id, pse__Project__c, pse__Project__r.Name from pse__Project_Task__c order by pse__Project__r.id';
    }

    /**
     *  
     *
     * @Author  NTT Data - Michael Lawrence
     * @Date    April 2016
     *
     * @param   BC - BatchableContext
     * @return  Database.QueryLocator
     **/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        lProjectsRefreshed = new Set<Id>();

        //log the job start
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_GroupedBatchRecalculateEVS', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);

        if( this.isProcessingBlock){
            query = 'SELECT id, ' +
                    'SObjectID__c ' +
                    'FROM BatchedChildObject__c ' +
                    'WHERE ChildStatus__c != \'Completed\' ' +
                    '   AND BatchedObject__r.PriorityRequestBy__c != null ' +
                    '   AND BatchedObject__r.BatchJob__c=\'Setup - Recalc EV\'' +
                    ' ORDER BY BatchedObject__r.SObjectID__c';
        } else {
            query = 'SELECT id, ' +
                    'SObjectID__c ' +
                    'FROM BatchedChildObject__c ' +
                    'WHERE ChildStatus__c != \'Completed\' ' +
                    '   AND BatchedObject__r.BatchJob__c=\'Setup - Recalc EV\'';
        }
        System.debug( LoggingLevel.WARN, '=====>query: ' + query);

        return Database.getQueryLocator(query);
    }

    /**
     *  This should not be run in a scheduled context
     *
     * @Author  NTT Data - Deborah Orth
     * @Date    May 2016
     *
     * @param   
     **/
    global void execute(SchedulableContext SC){
          //ECO_GroupedBatchRecalculateEVS batch = new ECO_GroupedBatchRecalculateEVS();
          //Database.executeBatch(batch, batchSize);
    }
    
    /**
     *  
     *
     * @Author  NTT Data - Michael Lawrence
     * @Date    April 2016
     *
     * @param   
     **/
    global void execute(Database.BatchableContext BC, List<BatchedChildObject__c> lScope) {
        String jsonTasks = '';

        try{

            //Begin Recalculation
            Set<Id> lProjectTaskIds = new Set<Id>();

            for(BatchedChildObject__c oBatchChild : lScope){
                lProjectTaskIds.add((id)oBatchChild.SObjectID__c);
            }
            /*for(pse__Project_Task__c oProjectTask : lScope){
                lProjectTaskIds.add(oProjectTask.Id);
            }*/

            String query = 'Select ' + ECO_ProjectTasksSelector.csvFields +' FROM pse__Project_Task__c where id in :lProjectTaskIds';
            
            List<pse__Project_Task__c> tasks = Database.query(query);
            jsonTasks = '\n' + JSON.serialize(tasks, true);

            if(bRebuildCostActuals)
                ECO_Service_EarnedValue.nullifyReportingFields = true;

            ECO_Service_EarnedValue.processTasks(tasks);

            // double-check that any missing WeeklyRollupEntry objects are created in gaps between project tasks

            set<id> lProjectIds = new set<id>();
            /*
            for (pse__Project_Task__c oProjectTask : lScope) {
                lProjectIds.add(oProjectTask.pse__Project__c);   
            }*/

            for (pse__Project_Task__c oProjectTask : tasks) {
                lProjectIds.add(oProjectTask.pse__Project__c);   
            }


            map<Id, pse__Proj__c> mProjects = new map<Id, pse__Proj__c>([SELECT id, pse__Start_Date__c, pse__End_Date__c, ProjectFunctionalCurrencyCode__c FROM pse__Proj__c WHERE Id in :lProjectIds]);
            system.debug('mProjects: ' + mProjects);

            List<WeeklyRollupEntry__c> allWREs = new List<WeeklyRollupEntry__c>();

            for (pse__Proj__c theProject : mProjects.values()) {
                Map<String, WeeklyRollupEntry__c> wreMap = ECO_ProjectTaskTriggers.generateWeeklyRollupEntriesBetweenDates(theProject.pse__Start_Date__c, theProject.pse__End_Date__c, theProject.Id, theProject);
                allWREs.addAll(wreMap.values());
            }

            upsert allWREs CompositeKey__c;

            if(bRebuildCostActuals)
                ECO_Service_EarnedValue.nullifyReportingFields = false;

            //Begin CDL code
            if(bRebuildCostActuals){
                ECO_TriggerSettings.bypass('CDL_SubtractAmountsFromEarnedValueSnapshots');

                List<CostDistLine__c> lines = [SELECT Name
                                                    , CostReportCategory__c, CreatedById
                                                    , CreatedDate, CurrencyIsoCode
                                                    , DENOMBurdenedCost__c, DENOMCurrencyCode__c
                                                    , DENOMRawCost__c, IsDeleted
                                                    , ExpenditureItem__c, ExpenditureResourceType__c
                                                    , ExternalId__c, GLDate__c
                                                    , GLFiscalMonth__c, GLPeriodName__c
                                                    , LastModifiedById, LastModifiedDate
                                                    , LineNumber__c, OracleSyncError__c
                                                    , OracleSyncStatus__c, PADate__c
                                                    , PAFiscalMonth__c, PAPeriodName__c
                                                    , PLReportCategory__c, ProjectBurdenedCost__c
                                                    , ProjectCurrencyCode__c, ProjectFunctionalBurdenedCost__c
                                                    , ProjectFunctionalCurrencyCode__c
                                                    , ProjectFunctionalRawCost__c
                                                    , ProjectNumber__c, ProjectRawCost__c
                                                    , Quantity__c, RecalculateEVSMetrics__c
                                                    , Id, SystemModstamp
                                                    , TaskNumber__c 
                                              FROM CostDistLine__c 
                                              WHERE ExpenditureItem__r.ProjectTask__c in :lProjectTaskIds];

                System.debug(LoggingLevel.WARN,'lines.size()='+lines.size());


                ECO_CostDistributionLineTriggers.rollupCosts(lines, lines);
            }

            for(BatchedChildObject__c oBatchChild : lScope){
                oBatchChild.ChildStatus__c = 'Completed';
            }

            try{
                update lScope;
            } catch (Exception ex) {
                ECO_Service_ErrorLog.logException(ex, jsonTasks);
                throw ex;           
            }

        } catch (Exception ex) {
            ECO_Service_ErrorLog.logException(ex, jsonTasks);
            throw ex;
        }
    }
    
    /**
     *  
     *
     * @Author  NTT Data - Michael Lawrence
     * @Date    April 2016
     *
     * @param   
     **/
    global void finish(Database.BatchableContext BC) {
        //log the end of the job and possible call the next job in the stream
        runNextBatchInStream( BC.getJobId(), 'ECO_GroupedBatchRecalculateEVS');             
        
    }
}