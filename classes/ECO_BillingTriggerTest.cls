@isTest
private class ECO_BillingTriggerTest
{

    static testMethod void testBillingTriggersTest() {
       
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
		ECO_ProjectTriggers.run = true;
		ECO_ProjectTaskTriggers.run = true;

		pse__Proj__c project = [select Id from pse__Proj__c limit 1];
               
        Billing__c billing = new Billing__c(ProjectNumber__c = project.Id);

        insert billing;    
    }
}