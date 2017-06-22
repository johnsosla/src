/** ------------------------------------------------------------------------------------------------------------
* @Description This class runs the Batch job for the "Batch Update Project Tasks" process, based on the 
*			   job Location and can also be rerun for failed jobs.
*
* @Author      NTT Data - Tim Chiang
* @Date        September 2016
*--------------------------------------------------------------------------------------------------------------*/
global class ECO_GroupedBatchUpdateProjectTasks extends ECO_BatchAdminService {

	public Integer batchSize {get; set;}
	public String query = '';

    /**
     *  default constructor
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/
	global ECO_GroupedBatchUpdateProjectTasks() {
		if (batchSize == null) {
        	batchSize = 50;
      	}
	}

    /**
     *  scheduled execute
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/
	global void execute(SchedulableContext context) {
		if (batchSize == null) {
        	batchSize = 50;
      	}
		ECO_GroupedBatchUpdateProjectTasks batch = new ECO_GroupedBatchUpdateProjectTasks();
		Database.executeBatch(batch, batchSize);
	}

	// ----------------------------------------------------------------------------------------
	// BATCHABLE
	// ----------------------------------------------------------------------------------------

    /**
     *  start
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/
	global Database.QueryLocator start(Database.BatchableContext context) {
		/*
		query = 
		
		query += '(Select Id, StartDate__c from ProjectTeamMembers__r where ProjectRole__r.Type__c = \'Key Member\') ';
		query += 'From pse__Proj__c ';
		query += 'Where pse__Stage__c IN : validStages';
		*/

		/*List<String> regionOuIds = new list<string>();
		regionOuIds = ECO_GroupedBatchHelper.getListOfRegions();

		query = 'Select Id, isConverted__c FROM pse__Proj__c WHERE isConverted__c = true and ouid__c IN: regionOuIds';*/

		//query = 'select id, SObjectID__c from BatchedChildObject__c where ChildStatus__c != \'Completed\' and BatchedObject__r.BatchJob__c=\'Setup - Batch Update Project Tasks\'';
		query = 'select id, SObjectID__c from BatchedObject__c where ChildrenComplete__c=false and BatchJob__c=\'Setup - Batch Update Project Tasks\'';
		return Database.getQueryLocator(query);
	}

    /**
     *  execute
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/
	global void execute(Database.BatchableContext BC, List<BatchedObject__c> BatchedObjects) {
		List<ProjectTeamMember__c> projectTeamMembers = new List<ProjectTeamMember__c>();
		ECO_ProjectTask.CONFIG_AUTOSETFLAGS = false;
		ECO_ProjectTask.CONFIG_AUTOSETDATES = false;
		
		String jsonBO = '';
		jsonBO = '\n' + JSON.serialize(BatchedObjects, true);

		try{
			set<Id> boID = new set<Id>();

			for (BatchedObject__c bo : BatchedObjects) {
				boID.add(bo.id);
				ECO_ProjectTaskService ets = new ECO_ProjectTaskService();
				List<pse__Project_Task__c> tNew = new List<pse__Project_Task__c> ();

				tNew.add(new pse__Project_Task__c( pse__Project__c = (id)bo.SObjectID__c));

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

            list<BatchedChildObject__c> lstBco = new list<BatchedChildObject__c>();

            for(BatchedChildObject__c oBatchChild : [select id, SObjectID__c from BatchedChildObject__c where BatchedObject__c IN: boID]){
                BatchedChildObject__c boc = new BatchedChildObject__c(id=oBatchChild.id, ChildStatus__c = 'Completed');
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
     *  finish
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/
	global void finish(Database.BatchableContext BC) {

	}
}