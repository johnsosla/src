/** ------------------------------------------------------------------------------------------------------
* @Description Performs validations on tasks before they are inserted or updated in the DB, only pays attention
* to a single record, no compare between before and after record changes
*
* @Author      NTT Data - ?, Deborah Orth
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_ProjectTaskValidator{
	public static Boolean CONFIG_DISABLED = false;
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   syncStatus - the Oracle sync status 
	 * @return  
	 **/
	public static Boolean isSyncedWithOracle(String syncStatus) {
		if (syncStatus != null &&
			(syncStatus == 'T' || syncStatus =='S')) {
				return true;            
		} 

		return false;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   tasks - trigger.new list of pse__Project_Task__c
	 * @param   ets - the instance of a ECO_ProjectTaskService
	 * @return  list of validation errors if any
	 **/
	public static List<String> validateForInsertAndUpdate(pse__Project_Task__c[] tasks, ECO_ProjectTaskService ets ){
		List<String> validationErrors = new List<String>();

		//if this is coming from WBS page it will be turned off, it only runs for the Task Manager page modified tasks
		if(ECO_ProjectTask.CONFIG_AUTOSETFLAGS ||  ECO_ProjectTaskValidator.CONFIG_DISABLED) {
			system.debug('validateForInsertAndUpdate bypassed due to CONFIG_DISABLED');
			return validationErrors;
		}

		system.debug(' -- validateForInsertAndUpdate entered');
		List<pse__Project_Task__c> childTasks = new List<pse__Project_Task__c>();
		Map<Id, List<pse__Project_Task__c>> mapParentChildTasks = new Map<Id, List<pse__Project_Task__c>>();

		List<Revenue__c> lRevenue = new List<Revenue__c>();
		Map<ID, List<Revenue__c>> mapProjectTaskRevenue = new Map<ID, List<Revenue__c>>();

		List<ExpendItem__c> lExpend = new List<ExpendItem__c>();
		Map<ID, List<ExpendItem__c>> mapProjectTaskExpenditure = new Map<ID, List<ExpendItem__c>>();

		//find the list of tasks acted on by the trigger
		Set<Id> taskIds = new Set<Id>();
		for(pse__Project_Task__c task : tasks){
			taskIds.add(task.Id);
		}

		Set<Id> tasksWithPOLineItems = getTasksAssociatedWithPurchaseOrders(tasks);

		if(true || Trigger.isUpdate) {       //wouldn't this run all the time? DJO		
			//get all the child tasks for these tasks
			childTasks = [SELECT Id, FinancialTask__c, IsChargeable__c, pse__Parent_Task__r.FinancialTask__c, pse__Parent_Task__r.IsChargeable__c
							FROM pse__Project_Task__c
							WHERE pse__Parent_Task__c IN :taskIds
							ORDER BY pse__Parent_Task__c];

			//create a map of child tasks to their parent
			if(!childTasks.isEmpty()){
				for(pse__Project_Task__c childTask : childTasks){
					if(!mapParentChildTasks.containsKey(childTask.pse__Parent_Task__c)){
						List<pse__Project_Task__c> tempChildTasks = new List<pse__Project_Task__c>();
						tempChildTasks.add(childTask);
						mapParentChildTasks.put(childTask.pse__Parent_Task__c, tempChildTasks);
					}else{
						mapParentChildTasks.get(childTask.pse__Parent_Task__c).add(childTask);
					}
				}	
			}        					

			/*
			// ALERT - disabled by Omar Dec 4, 2015
			lRevenue = [SELECT id, TaskNumber__c, GLDate__c FROM Revenue__c WHERE TaskNumber__c IN :taskIds ORDER BY TaskNumber__c, GLDate__c DESC];

			if(!lRevenue.isEmpty()){
				for(Revenue__c rev : lRevenue){
					if(!mapProjectTaskRevenue.containsKey(rev.TaskNumber__c)){
						List<Revenue__c> tempRev = new List<Revenue__c>();
						tempRev.add(rev);
						mapProjectTaskRevenue.put(rev.TaskNumber__c, tempRev);
					}else{
						mapProjectTaskRevenue.get(rev.TaskNumber__c).add(rev);
					}
				}   
			}   

			lExpend = [SELECT id, ProjectTask__c, ExpenditureItemDate__c FROM ExpendItem__c WHERE ProjectTask__c IN :taskIds ORDER BY ProjectTask__c, ExpenditureItemDate__c DESC];

			if(!lExpend.isEmpty()){
				for(ExpendItem__c exp : lExpend){
					if(!mapProjectTaskExpenditure.containsKey(exp.ProjectTask__c)){
						List<ExpendItem__c> tempExp = new List<ExpendItem__c>();
						tempExp.add(exp);
						mapProjectTaskExpenditure.put(exp.ProjectTask__c, tempExp);
					}else{
						mapProjectTaskExpenditure.get(exp.ProjectTask__c).add(exp);
					}
				}   
			}               
			*/
		}
		Map<Id, ECO_ProjectTask> mapTasksById;

		// ets = new ECO_ProjectTaskService();
		if (true || Trigger.isUpdate == true) {
			mapTasksById = ets.returnMapProjectTask(tasks);
		}

		Map<Id, List<pse__Project_Task__c>> mapParentPeerTasks = new Map<Id, List<pse__Project_Task__c>>();
		Set<Id> parentTaskIds = new Set<Id>();
		for(pse__Project_Task__c task : tasks){
			if(task.pse__Parent_Task__c != null){
				parentTaskIds.add(task.pse__Parent_Task__c);
			}        		
		}

		if(!parentTaskIds.isEmpty()){
			List<pse__Project_Task__c> peerTasks = [SELECT Id, Name, FinancialTask__c, pse__Parent_Task__c, IsChargeable__c, IsWorkPlanTask__c, pse__Parent_Task__r.FinancialTask__c, pse__Parent_Task__r.IsChargeable__c
													FROM pse__Project_Task__c
													WHERE pse__Parent_Task__c IN :parentTaskIds AND Id NOT IN :taskIds ];
			if(!peerTasks.isEmpty()){
				for(pse__Project_Task__c peerTask : peerTasks){
					if(!mapParentPeerTasks.containsKey(peerTask.pse__Parent_Task__c)){
							List<pse__Project_Task__c> tempChildTasks = new List<pse__Project_Task__c>();
							tempChildTasks.add(peerTask);
							mapParentPeerTasks.put(peerTask.pse__Parent_Task__c, tempChildTasks);
					}else{
							mapParentPeerTasks.get(peerTask.pse__Parent_Task__c).add(peerTask);
					}
				}
			}
		}
			

		Integer pos = 0;
		String errMsg = '';

		//process all the records in the buffer and validate them
		for(pse__Project_Task__c task : tasks){
			ECO_ProjectTask ecoTask = mapTasksById.get(task.Id);

			pse__Project_Task__c soqlTask = ecoTask == null ? task : ecoTask.oprojectTask;

			//rule: All Top Tasks must be Financial
			if(!soqlTask.FinancialTask__c && soqlTask.pse__Parent_Task__c == null){
				errMsg = injectTaskNameInLabel(String.valueOf(System.Label.ECO_OracleTaskError_TopLevelFinancial), task.Name);
				validationErrors.add(errMsg);
				tasks[pos].addError(errMsg); 
			}


			//rule: a non fincancial task must be non chargeable
			if(!soqlTask.FinancialTask__c && soqlTask.IsChargeable__c){
				System.debug('rule: If a task is non financial it must also be non-chargeable - ' + soqlTask.Name + ': ' +soqlTask.FinancialTask__c + '--' + soqlTask.IsChargeable__c);
				errMsg = 'Non-Financial tasks must also be Non-Chargeable.';
				validationErrors.add(errMsg);
				tasks[pos].addError(errMsg);
			}

			if(true || Trigger.isUpdate){

				//rule: All tasks that are parents of financial tasks must be financial
				if(ecoTask.children.size() > 0){

					if(!soqlTask.FinancialTask__c){
						for(ECO_ProjectTask ecoChildTask : ecoTask.children){
							if(ecoChildTask.oprojectTask.FinancialTask__c){
								errMsg = injectTaskNameInLabel(String.valueOf(System.Label.ECO_OracleTaskError_NotFinancialWithChildren), task.Name);
								validationErrors.add(errMsg);
								tasks[pos].addError(errMsg); 
							}
						}        					
					}

					//rule: Task should be chargeable at the lowest level of the "Financial" task hierarchy only
					if(soqlTask.IsChargeable__c) {
						for(ECO_ProjectTask ecoChildTask : ecoTask.children) {
							
							if(ecoChildTask.oprojectTask.FinancialTask__c) {
							//system.debug('ECO_OracleTaskError_ChargeableAtLowestLevel: eco_charge- '+ ecoTask.isChargeable + ' db-' + ecoTask.isChargeable__c);
								 errMsg =injectTaskNameInLabel(String.valueOf(System.Label.ECO_OracleTaskError_ChargeableAtLowestLevel), task.Name);
								 validationErrors.add(errMsg);
							   tasks[pos].addError(errMsg);
						   }
					   } 
					}
				}

			}
				
			//rule: All peer tasks on the same branch must be the same financial setting
			if( soqlTask.pse__Parent_Task__c != null){

				if(mapParentPeerTasks.containsKey(soqlTask.pse__Parent_Task__c)){
					Boolean addError3 = false;
					Boolean addWPTError = false;
					for(pse__Project_Task__c peerTask : mapParentPeerTasks.get(soqlTask.pse__Parent_Task__c)){
						if(peerTask.FinancialTask__c != task.FinancialTask__c){
							system.debug(peerTask.FinancialTask__c + ' - peerTask.Name: ' + peerTask.Name );
							system.debug(task.FinancialTask__c + ' - task.Name: ' + task.Name);
							addError3 = true;
						}
						
						if(peerTask.IsWorkPlanTask__c != task.IsWorkPlanTask__c){
							system.debug(peerTask.IsWorkPlanTask__c + ' - peerTask.Name: ' + peerTask.Name );
							system.debug(task.IsWorkPlanTask__c + ' - task.Name: ' + task.Name);
							addWPTError = true;
						}
					}
					if(addWPTError) {
						errMsg = String.Format(System.Label.ECO_OracleTaskError_PeerWPT, new List<String> {task.Name});
						validationErrors.add(errMsg);
						tasks[pos].addError(errMsg); 
					}

					if(addError3){
						errMsg = injectTaskNameInLabel(String.valueOf(System.Label.ECO_OracleTaskError_PeerFinancial), task.Name);
						validationErrors.add(errMsg);
						tasks[pos].addError(errMsg); 
					}
				}
			}
				

			//rule: If a task is non financial it must also be non-chargeable
			if(!soqlTask.FinancialTask__c && soqlTask.IsChargeable__c){
				System.debug('rule: If a task is non financial it must also be non-chargeable - ' + soqlTask.FinancialTask__c + soqlTask.IsChargeable__c);
				errMsg = injectTaskNameInLabel(String.valueOf(System.Label.ECO_OracleTaskError_FinancialNonChargeable), task.Name);
				validationErrors.add(errMsg);
				tasks[pos].addError(errMsg);                    
			}

			//rule: if task is part of a purchase order it must be financial and chargeable
			if(tasksWithPOLineItems.contains(task.Id) && (!task.FinancialTask__c|| !task.IsChargeable__c)){
				//tasks[pos].addError(injectTaskNameInLabel(String.valueOf(System.Label.ECO_OracleTaskError_TaskIsPartOfPurchaseOrder), task.Name));   
			}

			//rule: updated task date cannot be before the latest revenue date
			// ALERT - disabled by Graham per Michael/Phani/Linda on October 29, 2015
			/*
			if(isUpdate){
				if(mapProjectTaskRevenue.containsKey(task.Id)){
					if(task.pse__End_Date_Time__c < mapProjectTaskRevenue.get(task.id)[0].GLDate__c){
						tasks[pos].addError(injectTaskNameInLabel(String.valueOf(System.Label.ECO_Revenue_Validation), task.Name)); 
					}

				}

			}
			*/

			//rule: updated task date cannot be before the latest expenditure date
			/*if(isUpdate){
				if(mapProjectTaskExpenditure.containsKey(task.Id)){
					if(task.pse__End_Date_Time__c < mapProjectTaskExpenditure.get(task.id)[0].ExpenditureItemDate__c){
						tasks[pos].addError(injectTaskNameInLabel(String.valueOf(System.Label.ECO_Expenditure_Validation), task.Name)); 
					}

				}

			}*/

			pos ++;
		}

		return validationErrors;
	}


	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   tasks - trigger.old list of pse__Project_Task__c
	 * @return  
	 **/
	public static void validateForDelete(pse__Project_Task__c[] tasks){
	  
		Set<Id> tasksWithPOLineItems = getTasksAssociatedWithPurchaseOrders(tasks);

		Integer delPos = 0;
	   
		for(pse__Project_Task__c task : tasks){
			//rule: Do not allow the deletion of a project task if the project task has been sent to Oracle
			if(task.OracleSyncStatus__c != null){
				if(task.OracleSyncStatus__c == 'T' || task.OracleSyncStatus__c == 'S'){
					tasks[delPos].addError(injectTaskNameInLabel(String.valueOf(System.Label.ECO_OracleTaskError_Synced), task.Name));                    
				}
				if(tasksWithPOLineItems.contains(task.Id)){
					// tasks[delPos].addError(injectTaskNameInLabel(String.valueOf(System.Label.ECO_OracleTaskError_TaskIsPartOfPurchaseOrder), task.Name));   
				}
			}  
			delPos ++;
		}   
	}

	@TestVisible
	private static String injectTaskNameInLabel(String label, String  taskName){
		String labelStr = label;
		labelStr = labelStr.replaceAll('##TASKNAME##', taskName);
		return labelStr;
	}

	/**
	 * Can't find any current reference to this method
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   tasks - 
	 * @return  
	 **/
	public static void setTopTasksFinancial(pse__Project_Task__c[] tasks){
		
		for(pse__Project_Task__c task : tasks){
			if(task.pse__Parent_Task__c == null && !task.FinancialTask__c){
				task.FinancialTask__c = true;
			}
		}
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   tasks - trigger.old list of pse__Project_Task__c
	 * @return  
	 **/
	private static Set<Id> getTasksAssociatedWithPurchaseOrders(pse__Project_Task__c[] tasks){
		Set<Id> tasksWithPOLineItems = new Set<Id>();

        /*
		Set<Id> taskIds = new Set<Id>();
		for(pse__Project_Task__c task : tasks){
			taskIds.add(task.Id);
		}
		List<POLineItem__c> poLineItems = [SELECT Id, ProjectTask__c FROM POLineItem__c WHERE ProjectTask__c IN :taskIds];
	  
		if(!poLineItems.isEmpty()){
			for(POLineItem__c poLineItem : poLineItems){
				tasksWithPOLineItems.add(poLineItem.ProjectTask__c);
			}
		}
        */
		return tasksWithPOLineItems;
	}
   
}