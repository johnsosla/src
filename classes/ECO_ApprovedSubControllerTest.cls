@isTest
public class ECO_ApprovedSubControllerTest {

        static testMethod void testController()
        {
                Account testAccount = new Account();
                testAccount.Name = 'test Account';
                insert testAccount;
                
                ECO_ProjectTriggers.run = false;
                ECO_ProjectTaskTriggers.run = false;
                ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

                ECO_ProjectTriggers.run = true;
                ECO_ProjectTaskTriggers.run = true;

                pse__Proj__c testProject = [select Id, Name from pse__Proj__c limit 1];
                
                Agreement__c agreement = new Agreement__c();
                agreement.Account__c = testAccount.Id;
                
                insert agreement;
                
                Approved_Sub__c approvedSub = new Approved_Sub__c();
                ApexPages.StandardController standardController = new ApexPages.StandardController(approvedSub);
                ApexPages.currentPage().getParameters().put('Agreement__c',agreement.Id);
                ECO_ApprovedSubController controller = new ECO_ApprovedSubController(standardController);
                controller.init();
                controller.save();
                
                approvedSub = [select Id, Agreement__c from Approved_Sub__c limit 1];

                ApexPages.currentPage().getParameters().remove('Agreement__c');
                standardController = new ApexPages.StandardController(approvedSub);
                controller = new ECO_ApprovedSubController(standardController);
                controller.init();
                controller.save();   
        }

}