@isTest
public class ECO_ChangeManagerRecordTypeContrTest {
	
	static testMethod void  testECOChangeManagerRecordTypeContr() 
	{
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id, OUID__c from pse__Proj__c limit 1];	


		ApexPages.StandardController standardController = new ApexPages.StandardController(project);
		ECO_ChangeManagerRecordTypeController controller = new ECO_ChangeManagerRecordTypeController(standardController);

		controller.init();
		controller.returnToProject();
		controller.redirectToProjectChanges();
		
	}
}