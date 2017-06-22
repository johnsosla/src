@isTest
private class ECO_ContractReviewRequestExtensionTest {
    
    static testmethod void controllerTestMethod(){
        //init();

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Service_Delegation.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        
        pse__Proj__c project = [select Id from pse__Proj__c limit 1];

        Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
        insert ctry;
        
        ProjectRole__c projectRole = new ProjectRole__c(Name='ORM Contact', Active__c = true);
        insert projectRole;
        
        DOAApprovalRequest__c doa = new DOAApprovalRequest__c(Project__c = project.Id, ApprovalStatus__c='Submitted');
        insert doa;
        
        Agreement__c agr = new Agreement__c(Project__c = project.Id);
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        ECO_AgreementTriggerHandler.run = false;
        insert agr;

        Contract_Review__c cr = new Contract_Review__c(Agreement__c = agr.Id, Country__c = ctry.Id, Date_Required__c = Date.today());
        insert cr;

        Test.startTest();
        DOAApprovalRequest__c doaSelect = [Select Id From DOAApprovalRequest__c Limit 1];
        PageReference pageRef = new PageReference('/apex/ECO_ContractReviewRequests');
        test.setCurrentPage(pageRef);
        ECO_ContractReviewRequestExtension con = new ECO_ContractReviewRequestExtension(new ApexPages.StandardController(doaSelect));
        con.loadContractReview();
        Test.stopTest();
        
    }

}