@isTest
private class ECO_OtherDirectCostControllerTest {

	static testMethod void testController()
	{
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
                
                Agreement__c agreement = new Agreement__c();
                agreement.Account__c = testAccount.Id;
                
                insert agreement;
                
                OtherDirectCost__c otherDirectCost = new OtherDirectCost__c();
                ApexPages.StandardController standardController = new ApexPages.StandardController(otherDirectCost);
                ApexPages.currentPage().getParameters().put('Agreement__c',agreement.Id);
                ECO_OtherDirectCostController controller = new ECO_OtherDirectCostController(standardController);
                controller.init();
                controller.save();
                
                otherDirectCost = [select Id, Agreement__c from OtherDirectCost__c limit 1];
                system.AssertEquals(agreement.Id, otherDirectCost.Agreement__c);      
                ApexPages.currentPage().getParameters().remove('Agreement__c');
                controller.init();
                controller.save();
	}
}