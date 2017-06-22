global class ECO_ProjectSnapshotBatch_MonthEnd_Init { //extends ECO_BatchAdminService {
// DEPRECATED -- REMOVE
/*
    private List<String> regionOuIds            { get; set; }
    private String regionString                 { get; set; }

	public static final String batchScheduleSettingName = 'ECO_ProjectSnapshotBatch_MonthEnd_Init';
	public static final String batchAvailableSettingName = 'ECO_ProjectSnapshotBatch_MonthEnd_Init';

    public static final Integer DEFAULT_BATCH_SIZE = 1;
    String query;

    private Integer getBatchSchedulerBatchSize(){
    	// OVERRIDE batchSize in this case, where we're using a setup batch job to schedule other batch jobs
    	// use setup batch schedule job size, fall back to setup class batchavailable batch size, fall back to DEFAULT_BATCH_SIZE
    	Integer result = DEFAULT_BATCH_SIZE;

        list<ECO_BatchScheduleSettings__c> selectedSetupStep = [select name, BatchSize__c from ECO_BatchScheduleSettings__c where ClassName__c=:batchScheduleSettingName limit 1];
        ECO_BatchScheduleAvailable__c selectedClass;
        if (!selectedSetupStep.isempty()) {
            result =  Integer.valueOf(selectedSetupStep[0].BatchSize__c);
            /// not used -- this would use the recommended value from the batchavailable setting referred to by the batch schedule class namee
            //  selectedClass = ECO_BatchScheduleAvailable__c.getValues( selectedSetupStep.ClassName__c);
            //  if (selectedClass != null)
            //    result =  Integer.valueOf(selectedClass.RecommendedBatchSize__c);
        } else {
            selectedClass = ECO_BatchScheduleAvailable__c.getValues(batchAvailableSettingName);
            if (selectedClass != null)
                result =  Integer.valueOf(selectedClass.RecommendedBatchSize__c);
        }

		return result;
    }

    global ECO_ProjectSnapshotBatch_MonthEnd_Init() {

        //which regions are we running this time?
        this.regionOuIds = new List<String>();
        this.regionString = '';
        for( ECO_BatchSetupRegions__c bsr : [SELECT RegionOuId__c FROM ECO_BatchSetupRegions__c]){
            this.regionOuIds.add( bsr.RegionOuId__c);
            this.regionString += bsr.RegionOuId__c + ',';
        }

        if( !this.isProcessingBlock){
        	query = 'SELECT Id FROM pse__Proj__c WHERE OUId__c IN :regionOuIds and isActive__c = true LIMIT 1'; // so there will only be one batch
//TODO - finish this up
        //} else {
        //    query = 'SELECT sObjectID__c FROM BatchEdObject__c WHERE PriorityRequestBy__c != null and ChildrenComplete__c != true LIMIT 1'; // so there will only be one batch
        }

	}
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //log the job start
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectSnapshotBatch_MonthEnd_Init', this.batchStream, this.regionString, BC.getJobId(), this.jobName);

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<pse__Proj__c> scope) {
    	// no-op -- there's code in the finish method
    }
    global void execute(SchedulableContext sc) {
    	// no-op -- there's code in the finish method
    }

    global void finish(Database.BatchableContext BC) {

        Date earliestSnapshotToTake;
        Boolean useRecalculateFlag = false; // operate only on projects with Recalculate__c == true? if not, operate on all Projects
    	Boolean useEarliestProjectStart = false;
        if (useEarliestProjectStart){
            pse__Proj__c oldestProject = [SELECT id, pse__Start_Date__c FROM pse__Proj__c WHERE OUId__c IN :regionOuIds and isActive__c = true ORDER BY pse__Start_Date__c ASC NULLS LAST LIMIT 1];
            Date earliestProjectStart = oldestProject.pse__Start_Date__c;
            earliestSnapshotToTake = earliestProjectStart;
        } else {
            earliestSnapshotToTake = Date.newInstance(2010, 10, 2);  // start of fiscal 2011 for AECOM
            //earliestSnapshotToTake = Date.newInstance(2015, 10, 2);  // TESTING ONLY
        }
        List<pse__Time_Period__c> fiscalMonths = ECO_Utils_Date.calcTimePeriods(earliestSnapshotToTake,Date.today(),'Month');
        Date mostRecentMonthEnd = ECO_Utils_Date.getFiscalPeriod(Date.today(),1, fiscalMonths).pse__End_Date__c; // previous completed fiscal month to today
        List<Id> runOnProjects; // null means all active projects
        if (useRecalculateFlag){ // true for testing, false to run on all active projects
            runOnProjects = new List<id>();
            for (pse__Proj__c project:[SELECT id FROM pse__Proj__c WHERE OUId__c IN :regionOuIds and Recalculate__c = true]) runOnProjects.add(project.Id);
        } else {
            runOnProjects = new List<id>();
            for (pse__Proj__c project:[SELECT id FROM pse__Proj__c WHERE OUId__c IN :regionOuIds and pse__Stage__c ='Execution' and isActive__c = true]) runOnProjects.add(project.Id);
        }
		List<Id> batches = scheduleSnapshotsForMonthEnds(runOnProjects, earliestSnapshotToTake, mostRecentMonthEnd);

        //log the end of the job and possible call the next job in the stream
        runNextBatchInStream( BC.getJobId(), 'ECO_ProjectSnapshotBatch_MonthEnd_Init');

    }

    private List<Id> scheduleSnapshotsForMonthEnds(List<Id> projectIds, Date first, Date last)  {
        // Convenience method to schedule multiple "catch-up" month end snapshots for multiple projects
        List<pse__Time_Period__c> months = ECO_Utils_Date.calcTimePeriods(first,last,'Month');
        List<Date> asOfDates = new List<Date>();
        for(pse__Time_Period__c month:months) asOfDates.add(month.pse__End_Date__c);
        return scheduleSnapshots(projectIds, asOfDates);
    }

    private List<Id> scheduleSnapshots(List<Id> projectIds, List<Date> asOfDates)  {
        // Convenience method to schedule multiple "catch-up" month end snapshots for multiple projects
        List<Id> batchInstances = new List<Id>();
        for(Date asOfDate:asOfDates){
            batchInstances.add(Database.executeBatch(
                new ECO_ProjectSnapshotBatch_MonthEnd(projectIds, asOfDate), getBatchSchedulerBatchSize()
            ));
        }
        return batchInstances;
    }
    */
}