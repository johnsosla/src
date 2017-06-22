/** ------------------------------------------------------------------------------------------------------
* @Description does a project task recalculation - works on only 1 project at a time
*
* @Author      NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
global class ECO_EarnedValueBatch implements Database.Batchable<sObject>, Queueable {
	private static final Integer DML_LIMIT;
	private static final Integer CPU_LIMIT;
	static {
//		DML_LIMIT = Limits.getLimitDMLRows() - 3000;
   		//# of tasks * # of weeks = # of DML 
		DML_LIMIT = 5000;  // per Michael on 4/8/16
		CPU_LIMIT = 5000;
	}

	String query;
	Set<Id> projectTaskIds;

	/**
	 * @Description returns true if batch was executed
	 *
	 * @Author  NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
	 * @Date    2015
	 *
	 * @param	tasksToSnap
	 * @return 	Boolean
	 **/
	global static Boolean go(List<pse__Project_Task__c> tasksToSnap) {
		ECO_Limits_Thresholds__c limitSettings = ECO_Limits_Thresholds__c.getInstance();

		Integer taskWeeks = 0;

		//calculate the number of weeks for each task
		for (pse__Project_Task__c task : tasksToSnap) {
			Date startDate = (task.pse__Start_Date__c == null) ? task.pse__Project__r.pse__Start_Date__c : task.pse__Start_Date__c;
			Date endDate = (task.pse__End_Date__c == null) ? task.pse__Project__r.pse__End_Date__c : task.pse__End_Date__c;

			if (startDate == null)
				continue;

			if (endDate == null)
				continue;

			taskWeeks += (startDate.daysBetween(endDate) / 7 + 1);
		}

		//get DML left with a buffer for "other things"
		Decimal DmlThreshold = DML_LIMIT - Limits.getDMLRows();
		system.debug(LoggingLevel.INFO, 'ECO_EarnedValueBatch total/DML-Limit: ' + taskWeeks + ' / ' + DmlThreshold);
		Decimal CpuThreshold = CPU_LIMIT - Limits.getCpuTime();
		system.debug(LoggingLevel.INFO, 'ECO_EarnedValueBatch total/CPU-Limit: ' + taskWeeks + ' / ' + CpuThreshold);
		Decimal SoqlThreshold = limitSettings.SOQL_Limit_Buffer__c - Limits.getQueries();
		system.debug(LoggingLevel.INFO, 'ECO_EarnedValueBatch total/CPU-Limit: ' + taskWeeks + ' / ' + SoqlThreshold);

		//decide if this can be handled in real time or must be done in batch
		if (taskWeeks > DmlThreshold || 
				taskWeeks*50 > CpuThreshold || 
				taskWeeks * limitSettings.SOQL_per_TaskWeeks__c > SoqlThreshold ) 
		{
			Set<Id> taskIds = new Set<Id>();
			for (pse__Project_Task__c task : tasksToSnap) taskIds.add(task.Id);	

			executeBatch(taskIds);
			
			return true;
		}

		return false;
	}

	/**
	 * @Description 
	 *
	 * @Author  NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
	 * @Date    2015
	 *
	 * @param	projectTaskIds
	 * @return 	
	 **/
	private static void executeBatch(Set<Id> projectTaskIds) {
		ECO_EarnedValueBatch batch = new ECO_EarnedValueBatch(projectTaskIds);

		//check the number of currently running jobs
        Integer jobs = [Select count() From AsyncApexJob Where JobType = 'BatchApex' and ( Status = 'Queued' or Status = 'Processing' or Status = 'Preparing' )];

        //can we do this now?
        if (jobs > 4) {
        	System.enqueueJob(batch);
    	} else {
    		Database.executeBatch(batch, 1);
    	}
	}

	/**
	 * @Description 
	 *
	 * @Author  NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
	 * @Date    2015
	 *
	 * @param	projectTaskIds
	 * @return 	
	 **/
	global ECO_EarnedValueBatch(Set<Id> projectTaskIds) {
		this.projectTaskIds = projectTaskIds;

		query = 'Select ' + ECO_ProjectTasksSelector.csvFields +' FROM pse__Project_Task__c WHERE Id IN :projectTaskIds';
	}
	
	/**
	 * @Description 
	 *
	 * @Author  NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
	 * @Date    2015
	 *
	 * @param	BC - batch context
	 * @return 	
	 **/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	/**
	 * @Description 
	 *
	 * @Author  NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
	 * @Date    2015
	 *
	 * @param	BC - batch context
	 * @param	scope - the records to be processed
	 * @return 	
	 **/
   	global void execute(Database.BatchableContext BC, List<pse__Project_Task__c> scope) {
   		ECO_Service_EarnedValue.processTasks(scope);
    	// ECO_ProjectTaskTriggers.calculateEarnedValueSnaps(scope);
	}
	
	/**
	 * @Description 
	 *
	 * @Author  NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
	 * @Date    2015
	 *
	 * @param	BC - batch context
	 * @return 	
	 **/
	global void finish(Database.BatchableContext BC) {
	}

	/**
	 * @Description 
	 *
	 * @Author  NTT Data - Graham MacRobie - graham.macrobie@nttdata.com
	 * @Date    2015
	 *
	 * @param	context - queueable context
	 * @return 	
	 **/	
	 global void execute(QueueableContext context) {
		executeBatch(projectTaskIds);
	}
}