global class ECO_BatchUpdateProjectTasks  extends ECO_BatchAdminService {
    public static final Integer DEFAULT_BATCH_SIZE = 50;

	//public Integer batchSize {get; set;}
	public String query = 'Select Id, isConverted__c FROM pse__Proj__c WHERE isConverted__c = true';

	global ECO_BatchUpdateProjectTasks() {
		if (batchSize == null) {
        	batchSize = DEFAULT_BATCH_SIZE;
      	}
	}

  /**
   *  Ensures that when the batch runs scheduled it gets all the correct properties and is run with the correct batch size
   *
   * @Author  NTT Data - ? & Deborah Orth
   * @Date    May 2016
   *
   * @param   
   **/
	global void execute(SchedulableContext context) {
		if (batchSize == null) {
        	batchSize = DEFAULT_BATCH_SIZE;
      	}
		ECO_BatchUpdateProjectTasks batch = new ECO_BatchUpdateProjectTasks();
		batch.batchSize = this.batchSize;
		batch.batchStream = this.batchStream;
		batch.regionOuIds = this.regionOuIds;
		batch.jobName = this.jobName;
		Database.executeBatch(batch, batchSize);
	}

	// ----------------------------------------------------------------------------------------
	// BATCHABLE
	// ----------------------------------------------------------------------------------------


    /**
     * Method contains the Query on which batch job is run
     *
     * @Author  NTT Data - ?
     * @Date    ?
     *
     * @param   context - Batchable Context to start the job
     * @return  Database.QueryLocator - returns the query on which batch job runs
     **/
	global Database.QueryLocator start(Database.BatchableContext context) {
		this.logId = ECO_Service_BatchLog.logJobStart('ECO_BatchUpdateProjectTasks', this.batchStream, this.regionOuIds, context.getJobId(), this.jobName);
		/*
		query = 
		
		query += '(Select Id, StartDate__c from ProjectTeamMembers__r where ProjectRole__r.Type__c = \'Key Member\') ';
		query += 'From pse__Proj__c ';
		query += 'Where pse__Stage__c IN : validStages';
		*/
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<pse__Proj__c> projects) {
		List<ProjectTeamMember__c> projectTeamMembers = new List<ProjectTeamMember__c>();
		ECO_ProjectTask.CONFIG_AUTOSETFLAGS = false;
		ECO_ProjectTask.CONFIG_AUTOSETDATES = false;
		
		for (pse__Proj__c project : projects) {
			ECO_ProjectTaskService ets = new ECO_ProjectTaskService();
			List<pse__Project_Task__c> tNew = new List<pse__Project_Task__c> ();

			tNew.add(new pse__Project_Task__c( pse__Project__c = project.Id));

			Map<Id,pse__Project_Task__c> tasksToUpdateForecasts = new Map<Id,pse__Project_Task__c>();
			
			Map<Id, ECO_ProjectTask> mapTasksById = ets.returnMapProjectTask(tNew);

			//ECO_ProjectTask.recalcAllTasks(ets.lstProjectTasksSorted);

			for (ECO_ProjectTask pt : ets.lstProjectTasksSorted) {

				if(pt.hasChanged) {
					tasksToUpdateForecasts.put(pt.id, pt.taskForUpdate);
				}
			}

			system.debug(LoggingLevel.INFO, 'In rollupForecastDates @End CPU time: ' + Limits.getCpuTime());

			if(!tasksToUpdateForecasts.isEmpty()) {
				system.debug('Disable run - PT_rollupForecastDates');
				ECO_ProjectTaskTriggers.run = false;
				ECO_pseProjectTaskTriggers.externalTriggerStart();
				System.debug('DEBUG*** NEEDED TO UPDATE ' + tasksToUpdateForecasts.SIZE());
				Database.SaveResult[] srListUpdate = Database.update(tasksToUpdateForecasts.values(), false); 
				
				ECO_Service_ErrorLog.logException(tasksToUpdateForecasts.values(), srListUpdate, 'ECO_BatchUpdateProjectTasks.execute');

				ECO_pseProjectTaskTriggers.externalTriggerFinish();
				ECO_ProjectTaskTriggers.run = true;
				system.debug('Renable run - PT_rollupForecastDates');

			}
		}
	}

    /**
     * call the next batch in the stream if this job is a stream member
     *
     * @Author  NTT Data - Deborah Orth
     * @Date    November 2016
     *
     * @param 	BC - Batchable Context
     * @return  
     **/
	global void finish(Database.BatchableContext BC) {
		runNextBatchInStream( BC.getJobId(), 'ECO_BatchUpdateProjectTasks'); 
	}

}