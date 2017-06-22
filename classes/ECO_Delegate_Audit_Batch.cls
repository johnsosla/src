/****************************************************************
Created: Oct 29 2015
Author: Aaron Pettitt(NTT Data)
Purpose : Looks at Delegate Pending approval process to check number of days in queue.  If threshold past, it will be changed to
alternate approver.
Modifications:
******************************************************************/
global class ECO_Delegate_Audit_Batch implements Database.Batchable<sObject>, Schedulable {
	
	String query;
	ECO_Delegate_Approval_Process_Settings__c settings;

	//constructor
	global ECO_Delegate_Audit_Batch() {
		//settings = ECO_Delegate_Approval_Process_Settings__c.getOrgDefaults();
	}

	// ----------------------------------------------------------------------------------------
    // SCHEDULABLE
    // ----------------------------------------------------------------------------------------
	

	global void execute(SchedulableContext context) {
      //ECO_Delegate_Audit_Batch batch = new ECO_Delegate_Audit_Batch();
      //Database.executeBatch(batch);
    }

    // ----------------------------------------------------------------------------------------
    // BATCHABLE
    // ----------------------------------------------------------------------------------------
	
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		/*query = 'Select CompletedDate, ProcessDefinitionId, CreatedById, CreatedDate, ElapsedTimeInDays, ElapsedTimeInHours, Id, LastActorId, Status, TargetObjectId,';
	    query += '(SELECT Id, ActorId, OriginalActorId, StepStatus FROM Steps), '; 
	    query += '(SELECT Id,OriginalActorId FROM StepsAndWorkitems), ';
		query += '(SELECT ActorId,CreatedDate,OriginalActorId,ProcessInstanceId,Id FROM Workitems) ';
	    query += 'from ProcessInstance where (ProcessDefinition.DeveloperName = \'Project_Team_Member_Approve_Team_Member\' OR ProcessDefinition.DeveloperName = \'ECO_Delegate_Delegation_Approval\') And Status = \'Pending\'';
		return Database.getQueryLocator(query);*/

		return null;
	}

   	global void execute(Database.BatchableContext context, List<ProcessInstance> processInstances) {

   		/*if(processInstances.size() > 0){
   			List<Id> originalApproverIds = new List<Id>();
			List<ProcessInstance> processesForAlternates = new List<ProcessInstance>();

			//retrieve all approval processes that are in pending past the threshhold set in custom settings
			for(ProcessInstance processInstance : processInstances){
				if((!Test.isRunningTest() && processInstance.ElapsedTimeInDays > settings.Number_of_Days_Allowed_In_Process__c) || Test.isRunningTest()){
					processesForAlternates.add(processInstance);
					for(ProcessInstanceStep step : processInstance.Steps){
						if(step.StepStatus == 'Pending' || step.StepStatus == 'Started'){
							originalApproverIds.add(step.ActorId);
						}
					}
				}
			}

			if(processesForAlternates.size() > 0){
				//find the alternate delegates for the original actors in the approval process
				Map<Id, Delegate__c> delegatorId2Delegate = new Map<Id, Delegate__c>();
				List<Delegate__c> delegates = [Select Id, Delegate__c, Delegate__r.pse__Salesforce_User__c, Delegator__c, Delegator__r.pse__Salesforce_User__c from Delegate__c where RecordType.Name = 'Alternate' and Delegator__r.pse__Salesforce_User__c IN : originalApproverIds and (End_Date__c = null or End_Date__c >=: date.today())];
				for(Delegate__c delegate : delegates){
					delegatorId2Delegate.put(delegate.Delegate__r.pse__Salesforce_User__c, delegate);
				}

				//reassign the process instance work item to the alternate delegate
				List<ProcessInstanceWorkitem> processInstanceWorkitems = new List<ProcessInstanceWorkitem>();
				for(ProcessInstance processesForAlternate : processesForAlternates){
					for(ProcessInstanceWorkitem processInstanceWorkItem : processesForAlternate.Workitems){
						if(delegatorId2Delegate.containsKey(processInstanceWorkitem.ActorId)){
							processInstanceWorkitem.ActorId = delegatorId2Delegate.get(processInstanceWorkitem.ActorId).Delegate__r.pse__Salesforce_User__c;
							processInstanceWorkitems.add(processInstanceWorkitem);
						}
					}
				}
				update processInstanceWorkitems;
			}
		}*/
	}
	
	global void finish(Database.BatchableContext context) {
		
	}
	
}