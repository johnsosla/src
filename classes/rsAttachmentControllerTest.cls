/*************************************************************************
*
* PURPOSE: Test Class for Controller for attaching files to profile parts
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
***************************************************************************/
@isTest
private class rsAttachmentControllerTest {

    @isTest static void testNoFile() {
        rs_Profile_Part__c pp = new rs_Profile_Part__c(User__c = UserInfo.getUserId());
        insert pp;

        PageReference pg = new PageReference('/apex/rsAttachment?partId='+pp.Id);
        Test.setCurrentPage(pg);

        rsAttachmentController cont = new rsAttachmentController();

        Test.startTest();
        pg = cont.upload();
        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();

        Boolean noFileError = false;

        for(Apexpages.Message msg:msgs){

            if (msg.getDetail().contains('Please select a file before continuing')){
                noFileError = true;
            }

        }

        System.assert(noFileError);
        System.assertEquals(pg, null);

    }

    @isTest static void testNormalUpload(){

        rs_Profile_Part__c pp = new rs_Profile_Part__c(User__c = UserInfo.getUserId());
        insert pp;

        PageReference pg = new PageReference('/apex/rsAttachment?partId='+pp.Id+'&ownerId='+UserInfo.getUserId());
        Test.setCurrentPage(pg);

        rsAttachmentController cont = new rsAttachmentController();

        cont.attachment.Name = 'Test Attachment Name';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        cont.attachment.Body = bodyBlob;

        Test.startTest();
        pg = cont.upload();
        Test.stopTest();

        Attachment a = [select Id, ParentId from Attachment where ParentId = :pp.Id];
        pp = [select Id, Attachment_Id__c from rs_Profile_Part__c where Id = :pp.Id];

        //check that the attachment parent Id is same as PP id
        System.assertEquals(a.ParentId, pp.Id);
        //make sure the profile part's Attachment ID field was populated correctly
        System.assertEquals(a.Id, pp.Attachment_Id__c);

    }

    //test the VF Action method
    @isTest static void testGetAttachmentStatus(){
        rs_Profile_Part__c pp = new rs_Profile_Part__c(User__c = UserInfo.getUserId(), Attachment_Id__c = '123456');
        insert pp;

        PageReference pg = new PageReference('/apex/rsAttachment?partId='+pp.Id);
        Test.setCurrentPage(pg);

        rsAttachmentController cont = new rsAttachmentController();

        pg = cont.getAttachmentStatus();

        List<Apexpages.Message> msgs = ApexPages.getMessages();

        Boolean attachLimitError = false;

        for(Apexpages.Message msg:msgs){

            if (msg.getDetail().contains('Maximum of 1 attachment allowed. Uploading another file will overwrite existing attachment.')){
                attachLimitError = true;
            }

        }

        System.assert(attachLimitError);
        System.assertEquals(pg, null);

    }

    @isTest static void testCancel(){
        rs_Profile_Part__c pp = new rs_Profile_Part__c(User__c = UserInfo.getUserId(), Attachment_Id__c = '123456');
        insert pp;

        PageReference pg = new PageReference('/apex/rsAttachment?partId='+pp.Id+'&retUrl=fakeUrl&tab=SkillsAndQuals&tab.SkillsAndQuals.subtab=1&ownerId='+UserInfo.getUserId());
        Test.setCurrentPage(pg);

        rsAttachmentController cont = new rsAttachmentController();

        pg = cont.cancel();

        System.assertEquals(pg.getUrl(), 'fakeUrl?tab=SkillsAndQuals&tab.SkillsAndQuals.subtab=1&u='+UserInfo.getUserId());
    }




}