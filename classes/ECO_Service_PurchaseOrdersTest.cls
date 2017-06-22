@isTest
private class ECO_Service_PurchaseOrdersTest{

	private static final Integer numTestProjectTasks = 10;	
	private static final Integer numTeamMembers = 1;
    
    static testMethod void testPOStatusCreation() {
        Boolean taskTriggerStatus = ECO_ProjectTaskTriggers.run;
        ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;

		ECO_Utils_Testing.createTestDataForProjectSync(numTestProjectTasks, numTeamMembers);
		ECO_ProjectTaskTriggers.run = taskTriggerStatus;
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;
                
        pse__Proj__c setupProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
		Site__c site = [SELECT Id FROM Site__c];
            
        VendorSite__c vendorSite = new VendorSite__c();
        vendorSite.Project__c = setupProject.Id;
        vendorSite.Site__c = site.Id;
        vendorSite.Type__c = 'Sub';
        
        insert vendorSite;
        
        Agreement__c agreement = ECO_Utils_Testing.createPrimeAgreementForProject(setupProject, 'USD', setupProject.pse__Account__c);
        agreement.VendorSite__c = vendorSite.Id;
        
        Boolean agreementTriggerHandlerStatus = ECO_AgreementTriggerHandler.run;
        Boolean serviceDelegationStatus = ECO_Service_Delegation.run;
        ECO_AgreementTriggerHandler.run = false;
        ECO_Service_Delegation.run = false;
		update agreement;
		ECO_AgreementTriggerHandler.run = agreementTriggerHandlerStatus;
        ECO_Service_Delegation.run = serviceDelegationStatus;
        
        POHeader__c poHeader = new POHeader__c();
		poHeader.Project__c = setupProject.Id;
		insert poHeader;
        
        POStatus__c poStatus;
        
        Test.startTest();
        	try {
                poStatus = new POStatus__c();
                poStatus.POHeader__c = poHeader.Id;
                insert poStatus;
                System.assert(true);	
            }
            catch(Exception e){
                System.assert(false, '*****Error in testPOStatusCreation: ' + e.getMessage() + ' - ' + e.getStackTraceString());
            }       
        Test.stopTest();
        
        system.assertNotEquals(Null, poStatus.Id, '*****Error in testMissingUrlParams: The Po Status Id is not null');
    }

	static testMethod void testCreatePurcaseOrderDTO () {

		//create account and project
		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(numTestProjectTasks, numTeamMembers);
		pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];

		ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true;

		List<pse__Project_Task__c> tasks = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :testProject.Id];

		Account vendor = new Account();
		vendor.Name = 'test vendor';
		insert vendor;

		Site__c site = new Site__c();
		site.Account__c = vendor.Id;
		insert site;

		VendorSite__c vendorSite = new VendorSite__c();
		vendorSite.Site__c = site.Id;
		vendorSite.Project__c = testProject.Id;

		insert vendorSite;

		test.startTest();

		POHeader__c poHeader = new POHeader__c();
		poHeader.Project__c = testProject.Id;
		poHeader.VendorSite__c = vendorSite.Id;
		insert poHeader;

		POLineItem__c poLineItem = new POLineItem__c();
		poLineItem.ProjectTask__c = tasks.get(0).Id;
		poLineItem.POHeader__c = poHeader.Id;
		poLineItem.LineNumber__c = 1;
		poLineItem.LineType__c = 'Fixed Fee';
		poLineItem.UnitofMeasure__c = 'Lump SUm';

		insert poLineItem;

		List<Distribution__c> distributions = [SELECT Id FROM Distribution__c WHERE POLineItem__c = :poLineItem.Id];
		system.assertEquals(1, distributions.size());



		POStatus__c poStatus = new POStatus__c();
		poStatus.POHeader__c = poHeader.Id;
		insert poStatus;



		

		ECO_Service_PurchaseOrders.OR_PurchaseOrder purchaseOrderDTO = new ECO_Service_PurchaseOrders.OR_PurchaseOrder();
		ECO_Service_PurchaseOrders.OR_PurchaseOrderLineItem poLineItemDTO= new ECO_Service_PurchaseOrders.OR_PurchaseOrderLineItem();
		ECO_Service_PurchaseOrders.OR_Distribution distributionDTO = new ECO_Service_PurchaseOrders.OR_Distribution();
		ECO_Service_PurchaseOrders.OR_PurchaseOrderStatus poStatusDTO = new ECO_Service_PurchaseOrders.OR_PurchaseOrderStatus();
		ECO_Service_PurchaseOrders.OR_PurchaseOrderStatus poStatusDTO2 = new ECO_Service_PurchaseOrders.OR_PurchaseOrderStatus(poStatus);

		ECO_Service_PurchaseOrders.PurchaseOrderMessageWrapper wrapper = ECO_Service_PurchaseOrders.createPurchaseOrderMessageWrapper(poHeader.Id);

		Id msgQueueId = ECO_Service_PurchaseOrders.createMessageQueueForRequest(poHeader.Id, ECO_Service_PurchaseOrders.JOBNAME_PO_SYNC);
		system.assertNotEquals(null, msgQueueId);

		String testResponse = ECO_Service_PurchaseOrders.initiateOracleSyncRequest(poHeader.Id, 'https://test.ca', msgQueueId);

		List<POStatus__c> poStatuses = ECO_Service_PurchaseOrders.GetPurchaseOrderStatuses(poHeader.Id);
		system.assertEquals(1,poStatuses.size());


		Datetime syncDateTime = ECO_Service_PurchaseOrders.getLastSuccessfulSyncDateTime(poHeader.Id, ECO_Service_PurchaseOrders.JOBNAME_PO_SYNC);


		test.stopTest();
		//todo asserts

	}



}