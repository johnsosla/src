@isTest
private class ECO_ProjectOnHoldRestartBatchTest {

    static testMethod void testProjectOnHoldRestartBatch() {

		Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;
        
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        pse__Proj__c testProject = [select Id, Name from pse__Proj__c limit 1];
        testProject.ScheduledRestartDate__c = Date.today().addDays(-1);
        testProject.pse__Stage__c = 'On Hold';
        update testProject;
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;
				 		
		Test.StartTest();                
        ECO_ProjectOnHoldRestartBatch projectOnHoldRestartBatch = new ECO_ProjectOnHoldRestartBatch();
        Id batchprocessid = Database.executeBatch(projectOnHoldRestartBatch);    
        Test.StopTest(); 
       
        list<PortalMessage__c> portalMessage = [select Id from PortalMessage__c];        
        //System.AssertEquals(1, portalMessage.size());
    }
    
    static testMethod void testProjectOnHoldRestartBatch2() {

		Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        pse__Proj__c testProject = [select Id, Name from pse__Proj__c limit 1];
        testProject.ScheduledRestartDate__c = Date.today().addDays(-1);
        testProject.pse__Stage__c = 'On Hold';
        update testProject;

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;        
				 		
		Test.StartTest();                
        ECO_ProjectOnHoldRestartBatch projectOnHoldRestartBatch = new ECO_ProjectOnHoldRestartBatch();
        Id batchprocessid = Database.executeBatch(projectOnHoldRestartBatch);    
        Test.StopTest(); 
       
        list<PortalMessage__c> portalMessage = [select Id from PortalMessage__c];        
        //System.AssertEquals(0, portalMessage.size());
    }
}