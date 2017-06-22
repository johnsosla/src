@isTest
/*
 *  @Author: Sanchivan Sivadasan
 *  Created: December 2015, updated June 2016
 *
 *  Methods to be tested:
 *
 */
private class ECO_PurchaseOrderSummaryControllerTest {

	private static final Integer numTestProjectTasks = 10;	
	private static final Integer numTeamMembers = 1;
	
	@testSetup static void setup() {
		//turn off task triggers as they run into too many SOQL queries when this standard create data method loads
		Boolean taskTriggerStatus = ECO_ProjectTaskTriggers.run;
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(numTestProjectTasks, numTeamMembers);
		ECO_ProjectTaskTriggers.run = taskTriggerStatus;
				
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
	}
	
	private static POHeader__c buildTestPOHeader( Id projectId){
		POHeader__c poHeader = new POHeader__c();
		poHeader.Project__c = projectId;
		insert poHeader;
		return poHeader;
	}
	
	/*
	Given:
		Don't pass any parameters to the Controller
	When:
		construct the controller
	Then:
		ensure we have errors and that hideEverything flag is set to true.
	*/
	static testMethod void testMissingAllUrlParams(){
		// setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
		test.setCurrentPage(pageRef);
		ECO_PurchaseOrderSummaryController controller;
		
		Test.startTest();
		try {
			controller = new ECO_PurchaseOrderSummaryController(new ApexPages.StandardController(new POHeader__c()));
			System.assert(true);	
		}
		catch(Exception e){
			System.assert(false, '*****Error in testMissingUrlParams: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		system.assertEquals(true, controller.hideEverything, '*****Error in testMissingUrlParams: The hideEverything flag should be true');	//flag to not display any of the form
		
		PageReference pageRefAfterSave = controller.updatePurchaseOrder();
	}
	
	/*
	Given:
		Pass in the Agreement Id which doesn't have a Project associated to it and only pass the agreement Id
		After controller initiation call returnToProject
	When:
		construct the controller
	Then:
		ensure we have errors and allowPOHeaderSave is false, returnBtnValue is Return to Agreement, when you call returnToProject it takes them to the Agreement record.
	*/
	static testMethod void testMissingProjectIdUrlParams(){        
		// Remove the agreement's association to the Project
		Agreement__c agreement = [SELECT Id, Project__c FROM Agreement__c limit 1];
		agreement.Project__c = null;
		agreement.VendorSite__c = null;
		
		Boolean agreementTriggerHandlerStatus = ECO_AgreementTriggerHandler.run;
		Boolean serviceDelegationStatus = ECO_Service_Delegation.run;
		ECO_AgreementTriggerHandler.run = false;
		ECO_Service_Delegation.run = false;
		update agreement;
		ECO_AgreementTriggerHandler.run = agreementTriggerHandlerStatus;
		ECO_Service_Delegation.run = serviceDelegationStatus;

		// setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
		pageRef.getParameters().put('agreementId', agreement.Id);
		test.setCurrentPage(pageRef);
		ECO_PurchaseOrderSummaryController controller;
		
		Test.startTest();
		try {
			controller = new ECO_PurchaseOrderSummaryController(new ApexPages.StandardController(new POHeader__c()));
			pageRef = controller.returnToProject();
			System.assert(true);	
		}
		catch(Exception e){
			System.assert(false, '*****Error in testMissingProjectIdUrlParams: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		system.assertEquals(false, controller.allowPOHeaderSave, '*****Error in testMissingProjectIdUrlParams: The allowPOHeaderSave flag should be false');
		system.assertEquals('Return to Agreement', controller.returnBtnValue, '*****Error in testMissingProjectIdUrlParams: The returnBtnValue should be Return to Agreement');
		system.assertEquals('/' + agreement.Id, pageRef.getUrl(), '*****Error in testMissingProjectIdUrlParams: The returnToProject should take the user to the Agreement.');
	
	}
	
	/*
	Given:
		Pass agreement and project Id to page
	When:
		construct the controller
	Then:
		ensure we have no errors and that 
			- allowRequestSubmit is false
			- agreement's Project and PoHeader's Project id are the same
			- agreement Id we passed in is the agreement id of the poHeader
			- optSelectProjectsites has a size of 2
			- sJSON is empty
			- validPOLineItems is empty
			- invalidPOLineItems is empty
			- hasSyncHistory is false 
	*/
	static testMethod void testPositveUrlParams(){        
		// query the agreement which we created in the testsetup along with the Project Id
		Agreement__c agreement = [SELECT Id, Project__c FROM Agreement__c limit 1];
		
		// setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
		pageRef.getParameters().put('projectId', agreement.Project__c);   
		pageRef.getParameters().put('agreementId', agreement.Id);        
		test.setCurrentPage(pageRef);
		ECO_PurchaseOrderSummaryController controller;
		
		Test.startTest();
		try {
			controller = new ECO_PurchaseOrderSummaryController(new ApexPages.StandardController(new POHeader__c()));
			System.assert(true);
		}
		catch(Exception e){
			System.assert(false, '*****Error in testPositveUrlParams: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		system.assertEquals(false, controller.allowRequestSubmit, '*****Error in testPositveUrlParams: The allowRequestSubmit flag should be false');
		system.assertEquals(agreement.Project__c, controller.poHeader.Project__c , '*****Error in testPositveUrlParams: The project Id passed in should match poHeader.Project__c');
		system.assertEquals(agreement.Id, controller.poHeader.Agreement__c, '*****Error in testPositveUrlParams: The agreement Id passed in should match poHeader.Agreement__c');
		
		// test vendor is available
		system.assertEquals(2, controller.optSelectProjectSites.size(), '*****Error in testPositveUrlParams: The con.optSelectProjectSites.size should be 2');	
		
		//json should be empty
		system.assertEquals(true, String.isEmpty(controller.sJSON), '*****Error in testPositveUrlParams: The json should be empty');
		
		//verify other 
		system.assertEquals(true, controller.validPOLineItems.isEmpty(), '*****Error in testPositveUrlParams: The validPOLineItems should be empty'); 
		system.assertEquals(true, controller.invalidPOLineItems.isEmpty(), '*****Error in testPositveUrlParams: The invalidPOLineItems should be empty'); 

		//system.assertEquals(false, con.hasBeenApproved);
		system.assertEquals(false, controller.hasSyncHistory, '*****Error in testPositveUrlParams: The hasSyncHistory should be false');    
	}
	
	/*
	Given:
		Pass agreement and Project Id
	When:
		construct the controller, set selprojectSiteId and call getDefaultPaymentTermsForVendor
	Then:
		ensure we have no errors and that 
			- site and Purchase Order Payment Terms are the same
			- Purchase Orders Vendorsite__c id is the site Id
			- optAgreements size is 2
	*/
	static testMethod void testGetDefaultPaymentTermsForVendor(){        
		// query the agreement which we created in the testsetup along with the Project Id
		Agreement__c agreement = [SELECT Id, Project__c FROM Agreement__c limit 1];
		Site__c site = [SELECT Id, PaymentTerms__c FROM Site__c limit 1];
		
		// setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
		pageRef.getParameters().put('projectId', agreement.Project__c);   
		pageRef.getParameters().put('agreementId', agreement.Id);        
		test.setCurrentPage(pageRef);
		ECO_PurchaseOrderSummaryController controller;
		
		Test.startTest();
		try {
			controller = new ECO_PurchaseOrderSummaryController(new ApexPages.StandardController(new POHeader__c()));
			//test set vendor
			SelectOption vendorOpt = controller.optSelectProjectSites.get(1);

			controller.selProjectSiteId = vendorOpt.getValue();
			controller.getDefaultPaymentTermsForVendor();
			System.assert(true);
		}
		catch(Exception e){
			System.assert(false, '*****Error in testGetDefaultPaymentTermsForVendor: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		system.assertEquals(site.PaymentTerms__c, controller.poHeader.PaymentTerm__c, '*****Error in testGetDefaultPaymentTermsForVendor: the Site PaymentTerms and Purchase Order Payment Terms must be the same');
		system.assertEquals(site.Id, controller.poHeader.VendorSite__c, '*****Error in testGetDefaultPaymentTermsForVendor: the Site Id must be the Purchase Orders VendorSite__c Id');
		system.assertEquals(2, controller.optAgreements.size(), '*****Error in testGetDefaultPaymentTermsForVendor: The optAgreements size should be 2');
	}
	
	/*
	Given:
		Pass agreement and Project Id
	When:
		calling controller.updatePurchaseOrder
	Then:
		ensure we have no errors and that 
			- poHeader.Id is not null to make sure it was inserted
			- allowNewPOLineItems is true			
	*/
	static testMethod void testUpdatePurchaseOrder(){        
		// query the agreement which we created in the testsetup along with the Project Id
		Agreement__c agreement = [SELECT Id, Project__c FROM Agreement__c limit 1];
		
		// setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
		pageRef.getParameters().put('projectId', agreement.Project__c);   
		pageRef.getParameters().put('agreementId', agreement.Id);        
		test.setCurrentPage(pageRef);
		ECO_PurchaseOrderSummaryController controller;
		PageReference pageRefAfterSave;
		
		Test.startTest();
		try {
			controller = new ECO_PurchaseOrderSummaryController(new ApexPages.StandardController(new POHeader__c()));
			//test set vendor
			SelectOption vendorOpt = controller.optSelectProjectSites.get(1);

			controller.selProjectSiteId = vendorOpt.getValue();
			controller.getDefaultPaymentTermsForVendor();
			pageRefAfterSave = controller.updatePurchaseOrder();
			System.assert(true);
		}
		catch(Exception e){
			System.assert(false, '*****Error in testUpdatePurchaseOrder: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		//system.assertNotEquals(null, controller.poHeader.Id, '*****Error in testUpdatePurchaseOrder: The purchaseOrderId and poHeader Id must be the same');
		system.assertEquals(true, controller.allowNewPOLineItems, '*****Error in testUpdatePurchaseOrder: The allowNewPOLineItems flag must be true');
	}
	
	/*
	Given:
		Pass agreement and Project Id and existing POHeader
	When:
		calling controller.deletePurcahseOrder
	Then:
		ensure we have no errors and that 
			- poHeader is deleted
			- The page return's to the Project Detail Page			
	*/
	static testMethod void testDeletePurchaseOrder(){        
		// query the agreement which we created in the testsetup along with the Project Id
		Agreement__c agreement = [SELECT Id, Project__c FROM Agreement__c limit 1];
		POHeader__c poHeader;
		
		// setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
		pageRef.getParameters().put('projectId', agreement.Project__c);   
		pageRef.getParameters().put('agreementId', agreement.Id);        
		test.setCurrentPage(pageRef);
		ECO_PurchaseOrderSummaryController controller;
		PageReference pageRefAfterDelete;
		
		Test.startTest();
		try {
			poHeader =  buildTestPOHeader(agreement.Project__c);
			controller = new ECO_PurchaseOrderSummaryController(new ApexPages.StandardController(poHeader));
			pageRefAfterDelete = controller.deletePurchaseOrder();
			System.assert(true);
		}
		catch(Exception e){
			System.assert(false, '*****Error in testDeletePurchaseOrder: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
		
		List<POHeader__c> poHeaders = [SELECT Id FROM POHeader__c WHERE Id =: poHeader.Id];
		
		system.assertEquals(0, poHeaders.size(), '*****Error in testDeletePurchaseOrder: The POHeader__c should not exist in the database');
		system.assertEquals('/' + agreement.Project__c, pageRefAfterDelete.getUrl(), '*****Error in testDeletePurchaseOrder: The deletePurchaseOrder should take you to the Project detail page');
	}
	
	/*
	Given:
		Pass agreement and Project Id and existing POHeader
	When:
		calling controller.AuthenticateCredentials and CloseAuthenticationWindow
	Then:
		ensure we have no errors and that 
			- AuthenticateCredentials return's null
			- CloseAuthenticationWindow takes us to the correct URL		
	*/
	static testMethod void testAuthenticateCredentialsAndCloseAuthenticationWindow(){        
		// query the agreement which we created in the testsetup along with the Project Id
		Agreement__c agreement = [SELECT Id, Project__c FROM Agreement__c limit 1];
		POHeader__c poHeader;
		
		// setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
		pageRef.getParameters().put('projectId', agreement.Project__c);   
		pageRef.getParameters().put('agreementId', agreement.Id);  
		pageRef.getParameters().put('username', 'username');    	
		pageRef.getParameters().put('password', 'password');		      
		test.setCurrentPage(pageRef);
		ECO_PurchaseOrderSummaryController controller;
		PageReference pageRefAfterAuthenticateCredentials; 
		PageReference pageRefAfterCloseAuthenticationWindow;
		
		Test.startTest();
		try {
			poHeader =  buildTestPOHeader(agreement.Project__c);
			ECO_IntegrationEndpoints__c integrationEndPoint2 = new ECO_IntegrationEndpoints__c();
			integrationEndPoint2.Name = 'Project Sync 2';
			integrationEndPoint2.EndPointUrl__c = 'https://ecodev.aecom.com/OA_HTML/jsp/fnd/PicDisconnSF.jsp';
			insert integrationEndPoint2;
						
			controller = new ECO_PurchaseOrderSummaryController(new ApexPages.StandardController(poHeader));
			pageRefAfterAuthenticateCredentials = controller.authenticateCredentials();
			pageRefAfterCloseAuthenticationWindow = controller.closeAuthenticationWindow();
			
			System.assert(true);
		}
		catch(Exception e){
			//System.assert(false, '*****Error in testAuthenticateCredentialsAndCloseAuthenticationWindow: ' + e.getMessage() + ' - ' + e.getStackTraceString());
			System.debug('*****Error in testAuthenticateCredentialsAndCloseAuthenticationWindow: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
				
		//system.assertEquals(null, pageRefAfterAuthenticateCredentials, '*****Error in testAuthenticateCredentialsAndCloseAuthenticationWindow: The PageReference should be null');
		//system.assertEquals('/apex/ECO_PurchaseOrderSummary?id=' + poHeader.Id + '&projectId=' + agreement.Project__c, pageRefAfterCloseAuthenticationWindow.getUrl(), '*****Error in testAuthenticateCredentialsAndCloseAuthenticationWindow: It should take you to the ECO_PurchaseOrderSummary');
	}
	
	/*
	Given:
		Pass agreement and Project Id and existing POHeader
	When:
		calling controller.validatePOLineItems
	Then:
		ensure we have no errors and that 
			- result is not null
			- controller.poLineItems.size() is 2
			- controller.validPOLineItems.size() is 1
			- controller.invalidPOLineItems.size() is 1
			- controller.numValidPOLineItems is 1
			- controller.numInvalidPOLineItems is 1
			- controller.totalPurchaseOrderLineAmount is 2000
	*/
	static testMethod void testValidatePOLineItems(){        
		// query the agreement which we created in the testsetup along with the Project Id
		Agreement__c agreement = [SELECT Id, Project__c FROM Agreement__c limit 1];
		POHeader__c poHeader;
		
		// setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
		pageRef.getParameters().put('projectId', agreement.Project__c);   
		pageRef.getParameters().put('agreementId', agreement.Id);  
		test.setCurrentPage(pageRef);
		ECO_PurchaseOrderSummaryController controller;
		String result;		
		PageReference poLineItemPageRef;
		
		Test.startTest();
		try {
			poHeader =  buildTestPOHeader(agreement.Project__c);
			
			List<pse__Project_Task__c> tasks = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :agreement.Project__c limit 1];
			POLineItem__c poLineItem = new POLineItem__c();
			poLineItem.ProjectTask__c = tasks.get(0).Id;
			poLineItem.POHeader__c = poHeader.Id;
			poLineItem.LineNumber__c = 1;
			poLineItem.LineType__c = 'Fixed Fee';
			poLineItem.UnitofMeasure__c = 'Lump Sum';
			poLIneItem.Amount__c = 1000;
	
			insert poLineItem;
			 
			POLineItem__c poLineItem2 = new POLineItem__c();
			poLineItem2.ProjectTask__c = tasks.get(0).Id;
			poLineItem2.POHeader__c = poHeader.Id;
			poLineItem2.LineNumber__c = 1;
			poLineItem2.LineType__c = 'Fixed Fee';
			poLineItem2.UnitofMeasure__c = 'Lump Sum';
			poLineItem2.Amount__c = 1000;
			
			insert poLineItem2;	
			poLineItem2.ProjectTask__c = Null;
			update poLineItem2;
			
			controller = new ECO_PurchaseOrderSummaryController(new ApexPages.StandardController(poHeader));
			
			result = controller.validatePOLineItems();
			poLineItemPageRef = controller.gotoPOLineItemPage();
			System.assert(true);
		}
		catch(Exception e){
			System.assert(false, '*****Error in testValidatePOLineItems: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
				
		system.assertNotEquals('', result, '*****Error in testValidatePOLineItems: The result should be null');
		system.assertEquals(2, controller.poLineItems.size(), '*****Error in testValidatePOLineItems: controller.poLineItems.size should be 2');
		system.assertEquals(1, controller.validPOLineItems.size(), '*****Error in testValidatePOLineItems: controller.validPOLineItems.size should be 1');
		system.assertEquals(1, controller.invalidPOLineItems.size(), '*****Error in testValidatePOLineItems: controller.invalidPOLineItems.size should be 1');
		system.assertEquals(1, controller.numValidPOLineItems, '*****Error in testValidatePOLineItems: controller.numValidPOLineItems should be 1');
		system.assertEquals(1, controller.numInvalidPOLineItems, '*****Error in testValidatePOLineItems: controller.numInvalidPOLineItems should be 1');
		system.assertEquals(2000.0, controller.totalPurchaseOrderLineAmount, '*****Error in testValidatePOLineItems: controller.totalPurchaseOrderLineAmount should be 2000');
		system.assertNotEquals(Null, poLineItemPageRef.getUrl());
	}
	
	/*
	Given:
		Pass agreement and Project Id and existing POHeader
	When:
		calling controller.validatePOLineItems
	Then:
		ensure we have no errors and that 
			- result is not null
	*/
	static testMethod void testOracleSync(){        
		// query the agreement which we created in the testsetup along with the Project Id
		Agreement__c agreement = [SELECT Id, Project__c FROM Agreement__c limit 1];
		POHeader__c poHeader;
		poHeader =  buildTestPOHeader(agreement.Project__c);
		
		// setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
		pageRef.getParameters().put('projectId', agreement.Project__c);   
		pageRef.getParameters().put('agreementId', agreement.Id);  
		pageRef.getParameters().put('username', 'username');    	
		pageRef.getParameters().put('password', 'password');
		test.setCurrentPage(pageRef);
		ECO_PurchaseOrderSummaryController controller;
		String result;		
		PageReference poLineItemPageRef;
		
		Test.startTest();
		try {
			controller = new ECO_PurchaseOrderSummaryController(new ApexPages.StandardController(poHeader));
			SelectOption vendorOpt = controller.optSelectProjectSites.get(1);
			controller.selProjectSiteId = vendorOpt.getValue();
			controller.getDefaultPaymentTermsForVendor();
			controller.updatePurchaseOrder();
			poHeader =  buildTestPOHeader(agreement.Project__c);
			
			List<pse__Project_Task__c> tasks = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :agreement.Project__c limit 1];
			POLineItem__c poLineItem = new POLineItem__c();
			poLineItem.ProjectTask__c = tasks.get(0).Id;
			poLineItem.POHeader__c = controller.poHeader.Id;
			poLineItem.LineNumber__c = 1;
			poLineItem.LineType__c = 'Fixed Fee';
			poLineItem.UnitofMeasure__c = 'Lump Sum';
			poLIneItem.Amount__c = 1000;
	
			insert poLineItem;
			
			ECO_IntegrationEndpoints__c integrationEndPoint2 = new ECO_IntegrationEndpoints__c();
			integrationEndPoint2.Name = 'Project Sync 2';
			integrationEndPoint2.EndPointUrl__c = 'https://ecodev.aecom.com/OA_HTML/jsp/fnd/PicDisconnSF.jsp';
			insert integrationEndPoint2;
			
			ECO_IntegrationEndpoints__c integrationEndPoint = new ECO_IntegrationEndpoints__c();
			integrationEndPoint.Name = 'Purchase Order Sync';
			integrationEndPoint.EndPointUrl__c = 'https://ecodev.aecom.com/services/api/PurchaseOrder';
			insert integrationEndPoint;
			
			controller.initiateOracleSyncRequest();
			controller.executeOracleSyncRequest();
			controller.createMessageQueueRecord_start();
			controller.createMessageQueueRecord_complete();
			controller.sendPOSyncRequest_start();
			controller.sendPOSyncRequest_complete();
			controller.sendPOSyncRequest_Finish();
			controller.checkIfSyncHasBeenProcessed();
			controller.refreshJSON();        	
			System.assert(true);
		}
		catch(Exception e){
			System.assert(false, '*****Error in testOracleSync: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}
	
	 /*
	Given:
		Pass agreement and Project Id and existing POHeader
	When:
		calling controller.validatePOLineItems
	Then:
		ensure we have no errors and that 
			- result is not null
			
	*/
	static testMethod void testCancelCloseOutAndReturnToProject(){        
		// query the agreement which we created in the testsetup along with the Project Id
		Agreement__c agreement = [SELECT Id, Project__c FROM Agreement__c limit 1];
		POHeader__c poHeader;
		
		// setup the page
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
		pageRef.getParameters().put('projectId', agreement.Project__c);   
		pageRef.getParameters().put('agreementId', agreement.Id);  
		test.setCurrentPage(pageRef);
		ECO_PurchaseOrderSummaryController controller;
		String result;		
		PageReference poLineItemPageRef;
		
		Test.startTest();
		try {
			poHeader =  buildTestPOHeader(agreement.Project__c);
			
			List<pse__Project_Task__c> tasks = [SELECT Id FROM pse__Project_Task__c WHERE pse__Project__c = :agreement.Project__c limit 1];
			POLineItem__c poLineItem = new POLineItem__c();
			poLineItem.ProjectTask__c = tasks.get(0).Id;
			poLineItem.POHeader__c = poHeader.Id;
			poLineItem.LineNumber__c = 1;
			poLineItem.LineType__c = 'Fixed Fee';
			poLineItem.UnitofMeasure__c = 'Lump Sum';
			poLIneItem.Amount__c = 1000;
	
			insert poLineItem;
			
			controller = new ECO_PurchaseOrderSummaryController(new ApexPages.StandardController(poHeader));
			controller.cancelPurchaseOrder();
			controller.closeOutPurchaseOrder();
			controller.returnToProject(); 
			String purchaseOrderSyncProcessingResult = controller.purchaseOrderSyncProcessingResult;
			Boolean IsOracleTokenValid = controller.IsOracleTokenValid;
			controller.oracleUserName = 'username';
			controller.OraclePassword = 'username';
			controller.escalateApproval();
			poHeader.CancelFlag__c = true;
			poHeader.OraclePurchaseOrderId__c = '123456789';
			update poHeader;

			controller = new ECO_PurchaseOrderSummaryController(new ApexPages.StandardController(poHeader));
			System.assert(true);
		}
		catch(Exception e){
			System.assert(false, '*****Error in testCancelCloseOutAndReturnToProject: ' + e.getMessage() + ' - ' + e.getStackTraceString());
		}
		Test.stopTest();
	}
}