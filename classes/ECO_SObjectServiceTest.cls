@isTest
public class ECO_SObjectServiceTest {
	
	static testMethod void testSObjectServiceInsert() {

		pse__Proj__c project = new pse__Proj__c();
		project.pse__Start_Date__c = Date.today();
		project.pse__End_Date__c = Date.today().addDays(-1);
		ECO_SObjectService.saveInsertReturnErrors(project);
		
	}

	static testMethod void testSObjectServiceUpdate() {

		ECO_Service_Delegation.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;

        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c testProject = [select Id, Name from pse__Proj__c limit 1];
        testProject.pse__Start_Date__c = Date.today();
		testProject.pse__End_Date__c = Date.today().addDays(-1);
		ECO_SObjectService.saveResultReturnErrors(testProject);

    }
}