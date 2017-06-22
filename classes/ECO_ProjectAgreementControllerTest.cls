@isTest
private class ECO_ProjectAgreementControllerTest {
    static void initializeSites(){

        list<account> testAccounts = new list<account>();

        // Insert Test Account
        Account testAccount = new Account();
        testAccount.Name = 'test account';
        testAccount.OracleCustomerID__c = '1111';
        testAccounts.add(testAccount);

        insert testAccounts;        

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;
    }

    static testMethod void testProjectAgreementController() {
    	
        initializeSites();

        pse__Proj__c testProject = [select id from pse__Proj__c limit 1];
        
        ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Project__c = testProject.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(projectAgreement);
        
        ECO_ProjectAgreementController controller = new ECO_ProjectAgreementController(sc); 

        controller.init();
        
        
        list<RecordType>  RT = controller.getAgreementRecordTypes();
        controller.selectedRecordType = RT[0].id;
        controller.recordTypeSelected();
        
        controller.returnToProject();
        // TO DO: implement unit test
    }
}