@isTest
/*
 *  @Author: Sanchivan Sivadasan & Deborah Orth
 *  Created: July 2015, updated June 2016
 *
 *  Methods to be tested:
 *
 */
private class ECO_PurchaseOrderLineItemControllerTest{

	private static final Integer numTestProjectTasks = 2;   
	private static final Integer numTeamMembers = 1;

	@testSetup static void setup() {
		//turn off task triggers as they run into too many SOQL queries when this standard create data method loads
		//Boolean delegationTriggerStatus = ECO_Service_Delegation.run;
		//Boolean taskTriggerStatus = ECO_ProjectTaskTriggers.run;
		//Boolean projectTriggerStatus = ECO_ProjectTriggers.run;
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(numTestProjectTasks, numTeamMembers);
		//ECO_ProjectTriggers.run = projectTriggerStatus;
		//ECO_ProjectTaskTriggers.run = taskTriggerStatus;
		//ECO_Service_Delegation.run = delegationTriggerStatus;

		pse__Proj__c setupProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c poHeader = new POHeader__c();
		poHeader.Project__c = setupProject.Id;
		poHeader.Status__c = 'APPROVED';
		insert poHeader;
	}

	private static POLineItem__c buildTestPOLineItem( Id poHeaderId, Id taskId, Boolean isSynced){
		POLineItem__c newPoLineItem = new POLineItem__c( 
														POHeader__c = poHeaderId,
														LineDescription__c = 'test',
														ExpenditureType__c = 'SUBC-Land Survey',
														LineType__c = 'Unit Rate', 
														LineNumber__c = 1, 
														Quantity__c = 1, 
														UnitPrice__c = 99.99, 
														ProjectTask__c = taskId,
														Revision__c = 1);
		if( isSynced){
			newPoLineItem.OracleSyncDateTime__c = DateTime.newInstance(2016, 6, 23);
		}
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		insert newPoLineItem;
		return newPoLineItem;
	}



	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data
	When:
		construct the controller
	Then:
		ensure we have no errors 
	*/
	static testMethod void testPositiveLoadConstructor() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];

		//setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		pageRef.getParameters().put('poHeaderId', testHeader.Id);
		pageRef.getParameters().put('projectId', testProject.Id);
		Test.setCurrentPage(pageRef);

		ECO_PurchaseOrderLineItemController controller;

		Test.startTest();
		try {
			controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(new POLineItem__c()));
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in testPositiveLoadConstructor: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals(2, controller.projectTasks.size(), '*****Error in testPositiveLoadConstructor: There should be 2 tasks for the project');
	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data
	When:
		construct the controller with a new PO and then select cancel
	Then:
		ensure we have no errors 
	*/
	static testMethod void testPositiveLoadConstructorSelectCancel() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];

		//setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		pageRef.getParameters().put('taskId', testHeader.Id);
		Test.setCurrentPage(pageRef);

		ECO_PurchaseOrderLineItemController controller;

		Test.startTest();
		try {
			controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(new POLineItem__c()));
			controller.searchTaskName = 'testing';
			controller.getTasksForProject();
			controller.cancelPurchaseOrderLineItem();
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in testPositiveLoadConstructorSelectCancel: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		System.assertEquals(0, controller.projectTasks.size(), '*****Error in testPositiveLoadConstructorSelectCancel: There should be no tasks for the project');
	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data
	When:
		construct the controller
	Then:
		ensure we have no errors 
	*/
	static testMethod void testPositiveLoadDeadConstructor() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];

		//setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		pageRef.getParameters().put('poHeaderId', testHeader.Id);
		pageRef.getParameters().put('projectId', testProject.Id);
		Test.setCurrentPage(pageRef);

		ECO_PurchaseOrderLineItemController controller;

		Test.startTest();
		try {
			controller = new ECO_PurchaseOrderLineItemController();
			System.assert(false, '*****Error in testPositiveLoadDeadConstructor: this should have thrown an error');
		} catch (Exception e){
			System.assert(true);
			//doean't matter, this constructor is dead and should be removed from the controller
		}
		Test.stopTest();

	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data & instanciate controller
	When:
		create the new PO and save it
	Then:
		ensure we have no errors & the data is saved as expected
	*/
	static testMethod void testPositiveSavePOLineItem() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];

		//setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		pageRef.getParameters().put('poHeaderId', testHeader.Id);
		pageRef.getParameters().put('projectId', testProject.Id);
		Test.setCurrentPage(pageRef);

		ECO_PurchaseOrderLineItemController controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(new POLineItem__c()));
		controller.currentPOLineItem.LineDescription__c = 'test';
		controller.currentPOLineItem.ExpenditureType__c = 'SUBC-Land Survey';
		controller.currentPOLineItem.LineType__c = 'Unit Rate';
		controller.currentPOLineItem.LineNumber__c = 1;
		controller.currentPOLineItem.Quantity__c = 1;
		controller.currentPOLineItem.UnitPrice__c = 99.99;
		controller.currentPOLineItem.ProjectTask__c = controller.projectTasks.get(0).Id;
		controller.currentPOLineItem_TaskId = String.valueOf(controller.projectTasks.get(0).Id);

		PageReference savePageRef;

		Test.startTest();
		try {
			savePageRef = controller.saveCurrentPOLineItem();
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in testPositiveSavePOLineItem: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		POLineItem__c savedPOLineItem = [SELECT Id, LineType__c, LineNumber__c, Quantity__c, UnitPrice__c, ProjectTask__c, Amount__c
											FROM POLineItem__c
											WHERE POHeader__c = :testHeader.Id];

		system.assertEquals(savedPOLineItem.LineType__c, 'Unit Rate', '*****Error in testPositiveSavePOLineItem: Line Type should be Unit Rate');
		system.assertEquals(savedPOLineItem.LineNumber__c, 1, '*****Error in testPositiveSavePOLineItem: line number should be 1');
		system.assertEquals(savedPOLineItem.Quantity__c, 1, '*****Error in testPositiveSavePOLineItem: Quantity should be 1');
		system.assertEquals(savedPOLineItem.UnitPrice__c, 99.99, '*****Error in testPositiveSavePOLineItem: Price should be 99.99');
		system.assertEquals(savedPOLineItem.Amount__c, 99.99, '*****Error in testPositiveSavePOLineItem: The amount should be 99.99');
		system.assertEquals(savedPOLineItem.ProjectTask__c, controller.projectTasks.get(0).Id, '*****Error in testPositiveSavePOLineItem: page should be looking at the correct task');
	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data & instanciate controller
	When:
		edit an existing PO and save it
	Then:
		ensure we have no errors & the data is saved as expected
	*/
	static testMethod void positivePageSavesEditPOLineItem() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];
		pse__Project_task__c testTask = [SELECT Id FROM pse__Project_task__c WHERE pse__Project__c = :testProject.Id LIMIT 1];

		POLineItem__c poLineItem = buildTestPOLineItem( testHeader.Id, testTask.Id, false);
		POLineItem__c previousPoLineItem = new POLineItem__c(
															POHeader__c = testHeader.Id,
															LineDescription__c = 'test',
															ExpenditureType__c = 'SUBC-Land Survey',
															LineType__c = 'Unit Rate', 
															LineNumber__c = 1, 
															Quantity__c = 1, 
															UnitPrice__c = 89.99, 
															ProjectTask__c = testTask.Id,
															Revision__c = 2,
															ChangeRequestPOLineItem__c = poLineItem.Id);
		insert previousPoLineItem;
		ECO_ProjectTaskTriggers.run = false;
		ECO_PurchaseOrderLineItemController controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(poLineItem));

		//setup the page
		PageReference editPageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		editPageRef.getParameters().put('id', poLineItem.Id);
		Test.setCurrentPage(editPageRef);

		Test.startTest();
		try {
			controller.currentPOLineItem.Quantity__c = 2;
			editPageRef = controller.saveCurrentPOLineItem();
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in positivePageSavesEditPOLineItem: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		poLineItem = [SELECT Id, Quantity__c
					FROM POLineItem__c
					WHERE id = :poLineItem.Id LIMIT 1];
		system.assertEquals(2, poLineItem.Quantity__c, '*****Error in positivePageSavesEditPOLineItem: quantity should be udpated to 2');
	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data & instanciate controller
	When:
		edit an existing PO and cancel it
	Then:
		ensure we have no errors & the data is saved as expected
	*/
	static testMethod void positivePageCancelEditPOLineItem() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];
		pse__Project_task__c testTask = [SELECT Id FROM pse__Project_task__c WHERE pse__Project__c = :testProject.Id LIMIT 1];

		POLineItem__c poLineItem = buildTestPOLineItem( testHeader.Id, testTask.Id, true);
		POLineItem__c previousPoLineItem = new POLineItem__c(
															POHeader__c = testHeader.Id,
															LineDescription__c = 'test',
															ExpenditureType__c = 'SUBC-Land Survey',
															LineType__c = 'Unit Rate', 
															LineNumber__c = 1, 
															Quantity__c = 3, 
															UnitPrice__c = 89.99, 
															ProjectTask__c = testTask.Id,
															ChangeRequestPOLineItem__c = poLineItem.Id);
		insert previousPoLineItem;
		ECO_ProjectTaskTriggers.run = false;
		ECO_PurchaseOrderLineItemController controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(poLineItem));

		//setup the page
		PageReference editPageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		editPageRef.getParameters().put('id', poLineItem.Id);
		Test.setCurrentPage(editPageRef);

		Test.startTest();
		try {
			controller.currentPOLineItem.Quantity__c = 2;
			editPageRef = controller.cancelPurchaseOrderLineItem();
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in positivePageCancelEditPOLineItem: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data & instanciate controller
	When:
		edit an existing PO and cancel it
	Then:
		ensure we have no errors & the data is saved as expected
	*/
	static testMethod void positivePageCancelNotSyncedPOLineItem() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];
		pse__Project_task__c testTask = [SELECT Id FROM pse__Project_task__c WHERE pse__Project__c = :testProject.Id LIMIT 1];

		POLineItem__c poLineItem = buildTestPOLineItem( testHeader.Id, testTask.Id, false);
		POLineItem__c previousPoLineItem = new POLineItem__c(
															POHeader__c = testHeader.Id,
															LineDescription__c = 'test',
															ExpenditureType__c = 'SUBC-Land Survey',
															LineType__c = 'Unit Rate', 
															LineNumber__c = 1, 
															Quantity__c = 3, 
															UnitPrice__c = 89.99, 
															ProjectTask__c = testTask.Id,
															ChangeRequestPOLineItem__c = poLineItem.Id);
		insert previousPoLineItem;
		ECO_ProjectTaskTriggers.run = false;
		ECO_PurchaseOrderLineItemController controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(poLineItem));

		//setup the page
		PageReference editPageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		editPageRef.getParameters().put('id', poLineItem.Id);
		Test.setCurrentPage(editPageRef);

		Test.startTest();
		try {
			controller.currentPOLineItem.Quantity__c = 2;
			editPageRef = controller.cancelPurchaseOrderLineItem();
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in positivePageCancelNotSyncedPOLineItem: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data & instanciate controller
	When:
		edit an existing PO and save it
	Then:
		ensure we have no errors & the data is saved as expected
	*/
	static testMethod void negativeConstructorWithoutParams() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];
		pse__Project_task__c testTask = [SELECT Id FROM pse__Project_task__c WHERE pse__Project__c = :testProject.Id LIMIT 1];

		POLineItem__c poLineItem = buildTestPOLineItem( testHeader.Id, testTask.Id, false);

		//setup the page but don't add any data parameters
		PageReference editPageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		editPageRef.getParameters().put('retUrl', '/whatever');
		Test.setCurrentPage(editPageRef);

		Boolean taskTriggerStatus = ECO_ProjectTaskTriggers.run;
		ECO_ProjectTaskTriggers.run = false;

		Test.startTest();
		try {
			ECO_PurchaseOrderLineItemController controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(poLineItem));
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in negativeConstructorWithoutParams: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data & instanciate controller
	When:
		set the OracleSyncDateTime to something
	Then:
		cancel button text should read 'Cancel Purchase Order Line Item'
	*/
	static testMethod void positiveSyncedCancelButtonText() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];
		pse__Project_task__c testTask = [SELECT Id FROM pse__Project_task__c WHERE pse__Project__c = :testProject.Id LIMIT 1];

		POLineItem__c poLineItem = buildTestPOLineItem( testHeader.Id, testTask.Id, true);
		Boolean taskTriggerStatus = ECO_ProjectTaskTriggers.run;
		ECO_ProjectTaskTriggers.run = false;
		ECO_PurchaseOrderLineItemController controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(poLineItem));

		//setup the page
		PageReference editPageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		editPageRef.getParameters().put('id', poLineItem.Id);
		Test.setCurrentPage(editPageRef);

		Test.startTest();
		try {
			controller.currentPOLineItem.Quantity__c = 2;
			editPageRef = controller.saveCurrentPOLineItem();
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in positiveSyncedCancelButtonText: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		system.assertEquals('Cancel Purchase Order Line Item', controller.cancelButtonText, '*****Error in positiveSyncedCancelButtonText: cancel button text not set correctly');
	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data & instanciate controller
	When:
		edit an existing PO and save it when it doesn't have a task assiciated with it
	Then:
		get a page message error
	*/
	static testMethod void negativePageSavesEditPOLineItemWithoutTask() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];
		pse__Project_task__c testTask = [SELECT Id FROM pse__Project_task__c WHERE pse__Project__c = :testProject.Id LIMIT 1];

		POLineItem__c poLineItem = buildTestPOLineItem( testHeader.Id, testTask.Id, false);
		Boolean taskTriggerStatus = ECO_ProjectTaskTriggers.run;
		ECO_ProjectTaskTriggers.run = false;

		//remove the taskId
		poLineItem.ProjectTask__c = null;
		update poLineItem;
		ECO_PurchaseOrderLineItemController controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(poLineItem));

		//setup the page
		PageReference editPageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		editPageRef.getParameters().put('id', poLineItem.Id);
		Test.setCurrentPage(editPageRef);

		Test.startTest();
		try {
			controller.currentPOLineItem.Quantity__c = 2;
			editPageRef = controller.saveCurrentPOLineItem();
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in negativePageSavesEditPOLineItemWithoutTask: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		List<Apexpages.Message> pageMessages = ApexPages.getMessages();
		System.assert( pageMessages.size() > 0, '*****Error in negativePageSavesEditPOLineItemWithoutTask: there should be a page message explaining the error');

	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data & instanciate controller
	When:
		create the new PO but leave out key values and save it
	Then:
		get a page error
	*/
	static testMethod void negativeSavePOLineItemNoExpenditureType() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];

		//setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		pageRef.getParameters().put('poHeaderId', testHeader.Id);
		pageRef.getParameters().put('projectId', testProject.Id);
		Test.setCurrentPage(pageRef);

		ECO_PurchaseOrderLineItemController controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(new POLineItem__c()));
		//controller.currentPOLineItem.LineDescription__c = 'test';
		//controller.currentPOLineItem.ExpenditureType__c = 'SUBC-Land Survey';
		controller.currentPOLineItem.LineType__c = 'Unit Rate';
		controller.currentPOLineItem.LineNumber__c = 1;
		controller.currentPOLineItem.Quantity__c = 1;
		controller.currentPOLineItem.UnitPrice__c = 99.99;
		controller.currentPOLineItem.ProjectTask__c = controller.projectTasks.get(0).Id;
		controller.currentPOLineItem_TaskId = String.valueOf(controller.projectTasks.get(0).Id);

		PageReference savePageRef;

		Test.startTest();
		try {
			savePageRef = controller.saveCurrentPOLineItem();
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in negativeSavePOLineItemNoExpenditureType: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		List<Apexpages.Message> pageMessages = ApexPages.getMessages();
		System.assert( pageMessages.size() > 0, '*****Error in negativeSavePOLineItemNoExpenditureType: there should be a page message explaining the error');

	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data & instanciate controller
	When:
		create the new PO but leave out key values and save it
	Then:
		get a page error
	*/
	static testMethod void negativeSavePOLineItemNoQuantityOrUnitPrice() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];

		//setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		pageRef.getParameters().put('poHeaderId', testHeader.Id);
		pageRef.getParameters().put('projectId', testProject.Id);
		Test.setCurrentPage(pageRef);

		ECO_PurchaseOrderLineItemController controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(new POLineItem__c()));
		controller.currentPOLineItem.LineDescription__c = 'test';
		controller.currentPOLineItem.ExpenditureType__c = 'SUBC-Land Survey';
		controller.currentPOLineItem.LineType__c = 'Unit Rate';
		controller.currentPOLineItem.LineNumber__c = 1;
		//controller.currentPOLineItem.Quantity__c = 1;
		//controller.currentPOLineItem.UnitPrice__c = 99.99;
		controller.currentPOLineItem.ProjectTask__c = controller.projectTasks.get(0).Id;
		controller.currentPOLineItem_TaskId = String.valueOf(controller.projectTasks.get(0).Id);

		PageReference savePageRef;

		Test.startTest();
		try {
			savePageRef = controller.saveCurrentPOLineItem();
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in negativeSavePOLineItemNoQuantityOrUnitPrice: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		List<Apexpages.Message> pageMessages = ApexPages.getMessages();
		System.assert( pageMessages.size() > 0, '*****Error in negativeSavePOLineItemNoQuantityOrUnitPrice: there should be a page message explaining the error');

	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data & instanciate controller
	When:
		create the new PO but leave out amount values on line type = Fixed Fee
	Then:
		get a page error
	*/
	static testMethod void negativeSavePOLineItemFixedFeeNoAmount() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];

		//setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		pageRef.getParameters().put('poHeaderId', testHeader.Id);
		pageRef.getParameters().put('projectId', testProject.Id);
		Test.setCurrentPage(pageRef);

		ECO_PurchaseOrderLineItemController controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(new POLineItem__c()));
		controller.currentPOLineItem.LineDescription__c = 'test';
		controller.currentPOLineItem.ExpenditureType__c = 'SUBC-Land Survey';
		controller.currentPOLineItem.LineType__c = 'Fixed Fee';
		controller.currentPOLineItem.LineNumber__c = 1;
		controller.currentPOLineItem.Quantity__c = 1;
		controller.currentPOLineItem.UnitPrice__c = 99.99;
		controller.currentPOLineItem.Amount__c = 0;
		controller.currentPOLineItem.ProjectTask__c = controller.projectTasks.get(0).Id;
		controller.currentPOLineItem_TaskId = String.valueOf(controller.projectTasks.get(0).Id);

		PageReference savePageRef;

		Test.startTest();
		try {
			savePageRef = controller.saveCurrentPOLineItem();
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in negativeSavePOLineItemFixedFeeNoAmount: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

		List<Apexpages.Message> pageMessages = ApexPages.getMessages();
		System.assert( pageMessages.size() > 0, '*****Error in negativeSavePOLineItemFixedFeeNoAmount: there should be a page message explaining the error');

	}

	/*
	Given:
		Create basic Account, Contact, Project, Oppy, Task, Team member data & instanciate controller
	When:
		create the new PO but leave out amount values on line type = Fixed Fee
	Then:
		controller creates an amount with quantity and unit price
	*/
	static testMethod void positivetiveSavePOLineItemFixedFeeNullAmount() {
		//get the setup data
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		POHeader__c testHeader = [SELECT Id, Project__c FROM POHeader__c WHERE Project__c = :testProject.Id];

		//setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		pageRef.getParameters().put('poHeaderId', testHeader.Id);
		pageRef.getParameters().put('projectId', testProject.Id);
		Test.setCurrentPage(pageRef);

		ECO_PurchaseOrderLineItemController controller = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(new POLineItem__c()));
		controller.currentPOLineItem.LineDescription__c = 'test';
		controller.currentPOLineItem.ExpenditureType__c = 'SUBC-Land Survey';
		controller.currentPOLineItem.LineType__c = 'Fixed Fee';
		controller.currentPOLineItem.LineNumber__c = 1;
		controller.currentPOLineItem.Quantity__c = 1;
		controller.currentPOLineItem.UnitPrice__c = 99.99;
		//controller.currentPOLineItem.Amount__c = 0;
		controller.currentPOLineItem.ProjectTask__c = controller.projectTasks.get(0).Id;
		controller.currentPOLineItem_TaskId = String.valueOf(controller.projectTasks.get(0).Id);

		PageReference savePageRef;

		Test.startTest();
		try {
			savePageRef = controller.saveCurrentPOLineItem();
			System.assert(true);
		} catch (Exception e){
			System.assert(false, '*****Error in negativeSavePOLineItemFixedFeeNullAmount: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();

	}

//To Cover
//==========================================

//getTasksForProject with searchTaskName


  //    savedPOLineItem.OracleSyncDateTime__c = Date.today();
  //    update savedPOLineItem;

  //    //test change request

  //    ECO_PurchaseOrderLineItemController con3 = new ECO_PurchaseOrderLineItemController(new ApexPages.StandardController(savedPOLineItem));
  //    con3.currentPOLineItem.Quantity__c = 3;
  //    savePageRef = con3.saveCurrentPOLineItem();

  //    List<POLineItem__c> poLineItems = [SELECT Id FROM POLineItem__c WHERE POHeader__c = :poHeader.Id];
  //    system.assertEquals(2, poLineItems.size());

  //    savePageRef = con3.cancelPurchaseOrderLineItem();

  //    savedPOLineItem.OracleSyncDateTime__c = null;
  //    update savedPOLineItem;

  //    savePageRef = con3.cancelPurchaseOrderLineItem();

  //    PageReference backPageRef = con3.returnToPurchaseOrder();
	//}

 //  static testMethod void testCreateNewControllerInstance() {
	//  ECO_Utils_Testing.createTestDataForProjectSync(numTestProjectTasks, numTeamMembers);
	//  pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];

	//  POHeader__c poHeader = new POHeader__c();
	//  poHeader.Project__c = testProject.Id;
	//  insert poHeader;

	//  PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
	//  pageRef.getParameters().put('poHeaderId', poHeader.Id);
	//  pageRef.getParameters().put('projectId', testProject.Id);

	//  test.setCurrentPage(pageRef);

	//  ECO_PurchaseOrderLineItemController con = new ECO_PurchaseOrderLineItemController();
	//}
}