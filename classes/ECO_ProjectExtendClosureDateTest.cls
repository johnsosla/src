@isTest
private class ECO_ProjectExtendClosureDateTest {

    static testMethod void testProjectExtendClosureBatch() {

		Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;
		
		Contact testContact = new Contact();
		testContact.LastName = 'Test Last Name';
		testContact.FirstName = 'Test First Name';
		insert testContact;
        //create create source project 
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        pse__Proj__c testProject = [select Id, Name, isClosed__c from pse__Proj__c limit 1];

        testProject.CMProjectClosureIsApproved__c = false;
        testProject.ClosureDate__c = Date.today();
        update testProject;

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        
				 		
		Test.StartTest();                
        ECO_ProjectExtendClosureDateBatch projectClosureBatch = new ECO_ProjectExtendClosureDateBatch();
        Id batchprocessid = Database.executeBatch(projectClosureBatch);    
        Test.StopTest(); 
        
        list<PortalMessage__c> portalMessage = [select Id, Name from PortalMessage__c];      
        System.AssertEquals(1, portalMessage.size());
    }

    static testMethod void testProjectExtendClosureBatchPM() {

		Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;
		
		Contact testContact = new Contact();
		testContact.LastName = 'Test Last Name';
		testContact.FirstName = 'Test First Name';
		insert testContact;
        //create create source project 
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        pse__Proj__c testProject = [select Id, Name, isClosed__c from pse__Proj__c limit 1];

        testProject.CMProjectClosureIsApproved__c = false;
        testProject.ClosureDate__c = Date.today();
        update testProject;

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;
		 		
		Test.StartTest();                
        //ECO_ProjectExtendClosureDateBatch projectClosureBatch = new ECO_ProjectExtendClosureDateBatch('');
        //Id batchprocessid = Database.executeBatch(projectClosureBatch);    
        Test.StopTest(); 
	}    
}