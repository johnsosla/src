/** ------------------------------------------------------------------------------------------------------
* @Description Test class for ECO_BatchCreatePTMfromExpenditem
*
* @Author      NTT Data - Priya Parepalli
* @Date        08/03/2016
*-----------------------------------------------------------------------------------------------------*/
@isTest
private class ECO_BatchCreatePTMfromExpenditemTest {
	@testSetup static void init(){
		ECO_Service_Delegation.run = false;
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 5);

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];
        User user1 = ECO_Utils_Testing.createTestUser('Standard User');
        User user2 = ECO_Utils_Testing.createTestUser('Standard User');
        List<User> lUser = new List<User>();
        lUser.add(user1);
        lUser.add(user2);
        insert lUser;
        
        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
        Contact testContact = new Contact();
        testContact.Email = user1.Email;
        testContact.FirstName = user1.FirstName;
        testContact.LastName =  user1.LastName;
        testContact.Phone = '55555555555';
        testContact.pse__Salesforce_User__c = user1.Id;
        testContact.RecordTypeId = recordTypeId;
        testContact.User__c = user1.Id;
        testContact.Person_ID__c = 'testsaq';
        insert testContact;
        
        ProjectRole__c projectRole = new ProjectRole__c();
        projectRole.Name = 'Other';
        projectRole.Type__c = 'Team Member';
        projectRole.Active__c = true;
        insert projectRole;
        
        List<ExpenditureType__c> lExpType = new List<ExpenditureType__c>();

        for (Integer i=0; i<2; i++) {
            lExpType.add(new ExpenditureType__c(Name='et'+i, ExpenditureCategory__c='ExpenditureCategory'+i, 
                PLReportCategory__c='PLReportCategory'+i, ResourceType__c='rt'+i));    
        }
        insert lExpType;

        pse__Project_Task__c pTask = [SELECT Id FROM pse__Project_Task__c LIMIT 1];

        ExpendItem__c expItem = new ExpendItem__c(ExpenditureType__c = lExpType[0].Name, Quantity__c = 50, 
    											  Project__c = project.Id, ExpenditureDateFiscalMonth__c = 'FY2015-02', 
											  	  PersonId__c = 'testsaq', ProjectTask__c = pTask.Id);

        Insert expItem ;
	}

    private static testMethod void TestBatchDefaultSize(){
        test.startTest();
        ECO_BatchCreatePTMfromExpenditem batch = new ECO_BatchCreatePTMfromExpenditem();
        Database.executeBatch(batch);
        test.stoptest();

    }

    private static testMethod void TestBatchEnterSize(){
        test.startTest();
        ECO_BatchCreatePTMfromExpenditem batch = new ECO_BatchCreatePTMfromExpenditem(10);
        Database.executeBatch(batch);
        test.stoptest();
    }

    private static testMethod void testExecute() {
        Test.startTest();
        ECO_BatchCreatePTMfromExpenditem tmb = new ECO_BatchCreatePTMfromExpenditem(null);
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, tmb);
        Test.stopTest();
    }
}