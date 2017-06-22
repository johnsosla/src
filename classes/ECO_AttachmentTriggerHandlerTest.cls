@isTest
private class ECO_AttachmentTriggerHandlerTest {

    static testMethod void testDeleteAgreementAttachment() {
    	
    	Agreement__c agreement = new Agreement__c();
    	insert agreement;
    	
    	Blob attachmentBody = Blob.valueOf('This is a test');
    	Attachment attachment = new Attachment();
    	attachment.Body = attachmentBody;
    	attachment.ParentId = agreement.Id;
    	attachment.Name = 'Test Attachment';
    	insert attachment;
    	
    	try
    	{
    		delete attachment;
    	}
    	catch(Exception e)
		{
			Boolean expectedExceptionThrown =  e.getMessage().contains('Users are not allowed to delete Agreement Attachments') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
		} 
    
        // TO DO: implement unit test
    }
    
    static testMethod void testDeleteBudgetAttachment() {
    	
        ECO_Service_Delegation.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_ProjectTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;   

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];
    	BudgetHeader__c budgetHeader = new BudgetHeader__c(Project__c = project.Id);
    	insert budgetHeader;
    	
    	Blob attachmentBody = Blob.valueOf('This is a test');
    	Attachment attachment = new Attachment();
    	attachment.Body = attachmentBody;
    	attachment.ParentId = budgetHeader.Id;
    	attachment.Name = 'Test Attachment';
    	insert attachment;
    	
    	try
    	{
    		delete attachment;
    	}
    	catch(Exception e)
		{
			Boolean expectedExceptionThrown =  e.getMessage().contains('Users are not allowed to delete Budget Attachments') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
		} 
    
        // TO DO: implement unit test
    }    
}