@isTest
private class ECO_ServiceContractReviewTest {

    static testMethod void myUnitTest() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(1, 2);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;
       	pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
       	
        ECO_AgreementTriggerHandler.run = false;
       	Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Agreement__c.sObjectType, 'Prime Task Order');
       	Agreement__c testAgreement = new Agreement__c();
       	testAgreement.FundingCurrencyCode__c = 'USD';
       	testAgreement.ScopeOfServices__c = 'Test Services';
       	testAgreement.RecordTypeId = recordTypeId;
       	testAgreement.ProfIndemnityLiabilityAmt__c = 1000;
       	testAgreement.PublicGeneralLiabilityAmt__c = 1000;
       	testAgreement.AgreementType__c = 'Test Agreement Type';
       	insert testAgreement;
        ECO_AgreementTriggerHandler.run = true;
       	
       	ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = testAgreement.Id, Project__c = testProject.Id);
       	insert projectAgreement;
       	
       	list<ECO_ContractReviewDTO> contractReviewDTOs = ECO_Service_ContractReview.getContractReivewDTOs(testAgreement.Id);
       	System.AssertEquals(1, contractReviewDTOs.size());
        
    }
    
    static testMethod void myUnitTest2() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(1, 2);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;
        //ECO_Utils_Testing.createTestDataForProjectSync(1, 2);
        
       	pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c];
       	
        ECO_AgreementTriggerHandler.run = false;
       	Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Agreement__c.sObjectType, 'Prime Task Order');
       	Agreement__c testAgreement = new Agreement__c();
       	testAgreement.FundingCurrencyCode__c = 'USD';
       	testAgreement.ScopeOfServices__c = 'Test Services';
       	testAgreement.RecordTypeId = recordTypeId;
       	testAgreement.ProfIndemnityLiabilityAmt__c = 1000;
       	testAgreement.PublicGeneralLiabilityAmt__c = 1000;
       	testAgreement.AgreementType__c = 'Test Agreement Type';
       	insert testAgreement;
        ECO_AgreementTriggerHandler.run = true;
       	
       	Account testAccount = new Account();
    		testAccount.Name = 'test Account';
    		insert testAccount;
    		
    		//create create source project 
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
    		pse__Proj__c testProject2 = new pse__Proj__c();
    		testProject2.Name = 'test project 2';
    		testProject2.pse__Account__c = testAccount.Id;
    		testProject2.pse__Project_Type__c = 'Customer Project';
    		testProject2.pse__Billing_Type__c = 'Fixed Price';
    		testProject2.CurrencyIsoCode = 'USD';
    		testProject2.pse__Is_Active__c = true;
    		testProject2.pse__End_Date__c = Date.today().addDays(5);
    		insert testProject2;		
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;
           	
        test.starttest();

       	ProjectAgreement__c projectAgreement1 = new ProjectAgreement__c(Agreement__c = testAgreement.Id, Project__c = testProject.Id);
       	ProjectAgreement__c projectAgreement2 = new ProjectAgreement__c(Agreement__c = testAgreement.Id, Project__c = testProject2.Id);
       	insert projectAgreement1;
       	insert projectAgreement2;
       	   	
       	list<ECO_ContractReviewDTO> contractReviewDTOs = ECO_Service_ContractReview.getContractReivewDTOs(testAgreement.Id);
       	System.AssertEquals(2, contractReviewDTOs.size());
    test.stoptest();
        
    }    
    
}