@isTest
public class ECO_CloseoutOpptyPhaseControllerTest {
	
	static testMethod void testCloseoutOpptyPhaseController() {
	
		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;

		ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        pse__Proj__c testProject = [select Id, Name from pse__Proj__c limit 1];

        ApexPages.StandardController standardController = new ApexPages.StandardController(testProject);
        ECO_CloseoutOpportunityPhaseController controller = new ECO_CloseoutOpportunityPhaseController(standardController);	
        controller.init();
        try
        {
        	controller.createChangeManagementPlanning();
        }
        catch(Exception e)
        {}
        controller.createChangeManagement();

        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        Attachment attachment = controller.dclosureAttachment;
		attachment.Name = 'Test';
		attachment.Body = myBlob;
		controller.overrideControlSystemName = 'Test2';
		controller.saveClosureAttachmentAndProject();
		controller.getAttachedClosureFiles();

        controller.closesave();
	}
}