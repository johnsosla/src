@isTest
private class ECO_BatchUpdateKeyMembersStartDateTest {

	@isTest 
	static void testBatch() {
		setupTestData();
		test.startTest();
		Database.executeBatch(new ECO_BatchUpdateKeyMembersStartDate());
		test.stopTest();
	}
	
	static void setupTestData(){

		Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;

        //create create source project 
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        List<ProjectTeamMember__c> teamMembers = [select Id from ProjectTeamMember__c];
        teamMembers[0].StartDate__c = Date.today().addDays(-100);
        update teamMembers[0];
	}
	
}