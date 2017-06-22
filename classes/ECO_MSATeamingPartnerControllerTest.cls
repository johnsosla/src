@isTest
public class ECO_MSATeamingPartnerControllerTest {

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
                
                MSATeamingPartner__c teamingPartner = new MSATeamingPartner__c();
                ApexPages.StandardController standardController = new ApexPages.StandardController(teamingPartner);
                ApexPages.currentPage().getParameters().put('Agreement__c',agreement.Id);
                ECO_MSATeamingPartnerController controller = new ECO_MSATeamingPartnerController(standardController);
                controller.init();
                controller.save();
                
                teamingPartner = [select Id, Agreement__c from MSATeamingPartner__c limit 1];
                system.AssertEquals(agreement.Id, teamingPartner.Agreement__c);       
                ApexPages.currentPage().getParameters().remove('Agreement__c');
                controller.init();
                controller.save();

	}
}