@isTest
private class ECO_DocumentManagementControllerTest {

    static testMethod void testDocmentManagementController() {
		final Integer numTestRisks = 50;

		Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		//create create source project 
		pse__Proj__c testProject =new ECO_Utils_Testing.ProjectBuilder().build(false);
		testProject.Name = 'test project 1';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;
		insert testProject;

		String myString = 'StringToBlob';
		Blob myBlob = Blob.valueof(myString);

		ApexPages.StandardController sc = new ApexPages.StandardController(testProject);
        
        ECO_DocumentManagementContoller documentManagementController = new ECO_DocumentManagementContoller(sc);
        //Control System Attachment
        documentManagementController.docControlSystemAttachment.Name = 'test1';
        documentManagementController.docControlSystemAttachment.Body = myBlob;
        documentManagementController.docControlSystemAttachment.ContentType = 'test1';
        documentManagementController.saveDocumentControlSystemAttachmentAndProject();
        System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test1'].size());
        documentManagementController.docControlSystemAttachment.Name = 'test1';
        documentManagementController.docControlSystemAttachment.Body = myBlob;
        documentManagementController.docControlSystemAttachment.ContentType = 'test1';
        documentManagementController.saveDocumentControlSystemAttachmentAndProject();
        System.AssertEquals(2, documentManagementController.getAttachedDocumentControlSystemFiles().size());
        
        //Naming Conventions
        documentManagementController.docNamingConventionsAttachment.Name = 'test2';
        documentManagementController.docNamingConventionsAttachment.Body = myBlob;
        documentManagementController.docNamingConventionsAttachment.ContentType = 'test2';
        documentManagementController.saveDocumentNamingConventionsAttachmentAndProject();
        System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test2'].size());  
        documentManagementController.docNamingConventionsAttachment.Name = 'test2';
        documentManagementController.docNamingConventionsAttachment.Body = myBlob;
        documentManagementController.docNamingConventionsAttachment.ContentType = 'test2';
        documentManagementController.saveDocumentNamingConventionsAttachmentAndProject();         
        System.AssertEquals(2, documentManagementController.getAttachedDocumentNamingConventionsFiles().size());  

		//File Management
		documentManagementController.fManagementStructureAttachment.Name = 'test3';
        documentManagementController.fManagementStructureAttachment.Body = myBlob;
        documentManagementController.fManagementStructureAttachment.ContentType = 'test3';
        documentManagementController.saveFileManagementStructureAttachmentAndProject();
        System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test3'].size());
		documentManagementController.fManagementStructureAttachment.Name = 'test3';
        documentManagementController.fManagementStructureAttachment.Body = myBlob;
        documentManagementController.fManagementStructureAttachment.ContentType = 'test3';
        documentManagementController.saveFileManagementStructureAttachmentAndProject();        
        System.AssertEquals(2, documentManagementController.getAttachedFileManagementStructureFiles().size());
        
        test.starttest();

		//Transmittals
		documentManagementController.docTransmittalsAttachment.Name = 'test4';
        documentManagementController.docTransmittalsAttachment.Body = myBlob;
        documentManagementController.docTransmittalsAttachment.ContentType = 'test4';
        documentManagementController.saveDocumentTransmittalsAttachmentAndProject();
        System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test4'].size());
        documentManagementController.docTransmittalsAttachment.Name = 'test4';
        documentManagementController.docTransmittalsAttachment.Body = myBlob;
        documentManagementController.docTransmittalsAttachment.ContentType = 'test4';
        documentManagementController.saveDocumentTransmittalsAttachmentAndProject();
        System.AssertEquals(2, documentManagementController.getAttachedDocumentTransmittalsFiles().size());

		//Archiving
		documentManagementController.docRecordsAndArchivingAttachment.Name = 'test5';
        documentManagementController.docRecordsAndArchivingAttachment.Body = myBlob;
        documentManagementController.docRecordsAndArchivingAttachment.ContentType = 'test5';
        documentManagementController.saveDocumentRecordsAndArchivingAttachmentAndProject();
        System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test5'].size());
        documentManagementController.docRecordsAndArchivingAttachment.Name = 'test5';
        documentManagementController.docRecordsAndArchivingAttachment.Body = myBlob;
        documentManagementController.docRecordsAndArchivingAttachment.ContentType = 'test5';
        documentManagementController.saveDocumentRecordsAndArchivingAttachmentAndProject();
        System.AssertEquals(2, documentManagementController.getAttachedDocumentRecordsAndArchivingFiles().size());

		//Comments Other Notes
		documentManagementController.docCommentsOtherNotesAttachment.Name = 'test6';
        documentManagementController.docCommentsOtherNotesAttachment.Body = myBlob;
        documentManagementController.docCommentsOtherNotesAttachment.ContentType = 'test6';
        documentManagementController.saveDocumentCommentsOtherNotesAttachmentAndProject();
        System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test6'].size());
		documentManagementController.docCommentsOtherNotesAttachment.Name = 'test6';
        documentManagementController.docCommentsOtherNotesAttachment.Body = myBlob;
        documentManagementController.docCommentsOtherNotesAttachment.ContentType = 'test6';
        documentManagementController.saveDocumentCommentsOtherNotesAttachmentAndProject();        
        System.AssertEquals(2, documentManagementController.getAttachedDocumentCommentsOtherNotesFiles().size());
        
        //documentManagementController.ViewLinks();
        documentManagementController.setDirty();
        //documentManagementController.splitList();
        //documentManagementController.removeattachment();
        documentManagementController.getDocM_AttachmentFiles();
        //documentManagementController.saveDocM_AttachmentAndProject();


        documentManagementController.save();

        test.stoptest();
        
    }
}