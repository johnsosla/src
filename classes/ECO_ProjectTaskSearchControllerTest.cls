@isTest
private class ECO_ProjectTaskSearchControllerTest
{
	@testSetup static void initData() {
	    ECO_Utils_Testing.createTestDataForBudgets();
	}

	private static POLineItem__c buildTestPOLineItem( Id poHeaderId, Id taskId){
		POLineItem__c newPoLineItem = new POLineItem__c( 
														POHeader__c = poHeaderId,
														LineDescription__c = 'test',
														ExpenditureType__c = 'SUBC-Land Survey',
														LineType__c = 'Unit Rate', 
														LineNumber__c = 1, 
														Quantity__c = 1, 
														UnitPrice__c = 99.99, 
														ProjectTask__c = taskId);
		//turn off delegation & task triggers as they are causing too many SOQL query exception
		Boolean delegationTriggerStatus = ECO_Service_Delegation.run;
		Boolean taskTriggerStatus = ECO_ProjectTaskTriggers.run;
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		insert newPoLineItem;
		ECO_ProjectTaskTriggers.run = taskTriggerStatus;
		ECO_Service_Delegation.run = delegationTriggerStatus;
		return newPoLineItem;
	}

	@isTest
	static void itShould()
	{
		pse__Project_Task__c task = [Select Id, pse__Project__c from pse__Project_Task__c Limit 1];

		POHeader__c poHeader = new POHeader__c();
		poHeader.Project__c = task.pse__Project__c;
		insert poHeader;

		POLineItem__c poLineItem = buildTestPOLineItem(poHeader.Id, task.Id);

		Test.setCurrentPage(Page.ECO_ProjectTaskSearch);
		Apexpages.currentPage().getParameters().put('projectId', task.pse__Project__c);
		
		Apexpages.currentPage().getParameters().put('poHeaderId', poHeader.Id);
		Apexpages.currentPage().getParameters().put('poLineItemId', poLineItem.Id);

		ECO_ProjectTaskSearchController con = new ECO_ProjectTaskSearchController();
		
		String currentPOLineItem_TaskName = con.currentPOLineItem_TaskName;
		con.taskFilter = '---THESEARENOTTHETASKSYOUARELOOKINGFOR---';
		con.getTasksForProject();

		con.taskFilter = '';
		con.getTasksForProject();

		con.saveCurrentPOLineItem();
	}
}