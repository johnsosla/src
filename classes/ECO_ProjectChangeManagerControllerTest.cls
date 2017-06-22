@isTest
public class ECO_ProjectChangeManagerControllerTest {
	
	static testMethod void testProjectChangeManagerControllerExecutionApproval() {
		
		ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        pse__Proj__c testProject = [select Id, Name from pse__Proj__c limit 1];

        ApexPages.StandardController standardController = new ApexPages.StandardController(testProject);
        ApexPages.currentPage().getParameters().put('mode', 'ExecutionApproval');

        ECO_ProjectChangeManagerController controller = new ECO_ProjectChangeManagerController(standardController);
        controller.init();
	}

	static testMethod void testProjectChangeManagerControllerNonExecutionApproval() {
		
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        pse__Proj__c testProject = [select Id, Name from pse__Proj__c limit 1];

        ApexPages.StandardController standardController = new ApexPages.StandardController(testProject);
        ECO_ProjectChangeManagerController controller = new ECO_ProjectChangeManagerController(standardController);
        controller.init();
        //controller.getChangeManagerFieldSetFields();
        controller.getIsChangedTasks();
        controller.getIsChangedKeyMembers();
        controller.getIsChangedCustomers();
        controller.getIsChangedClassifications();
        controller.getIsChangedSHE();
        controller.getIsChangedAgreements();
        controller.getIsChangedFunding();
        controller.getIsChangedDocManage();
        controller.getIsChangedStakeComm();
        controller.getIsChangedResources();
        controller.getIsChangedDeliverables();
        controller.getIsChangedScope();
        controller.getIsChangedResilience();
        controller.getIsChangedRisk();
	}
}