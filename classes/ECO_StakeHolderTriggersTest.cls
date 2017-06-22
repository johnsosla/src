@isTest

public class ECO_StakeHolderTriggersTest {
	
	static testMethod void testStakeHolderTriggers() {

		Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;

        //create create source project 
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c testProject = [select Id, Name, isClosed__c from pse__Proj__c limit 1];

        Stakeholder__c stakeHolder = new Stakeholder__c(Project__c = testProject.Id, ChangeManagerIsChanged__c = false);
        insert stakeholder;

		stakeholder.Interest__c = 'Test2';
		update stakeholder;

		delete stakeholder;
	}
}