/*******************************************************************************
*
* PURPOSE: Test class for GFA_AttachmentTest
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
@isTest
private class GFA_AttachmentTest {

    @isTest static void testConstructors() {
        GFA_Attachment attachment = new GFA_Attachment();
    }

    @isTest static void testGetsAndSets() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');

        Attachment attachment = new Attachment(
            Name = 'Test Attachment 0',
            ParentId = projects[0].getId(),
            Body = bodyBlob
        );
        insert attachment;

        GFA_Attachment convertAttach = new GFA_Attachment((Attachment)attachment);

        projects[0].setAttachments(new List<GFA_Attachment> { convertAttach });

        System.assertEquals('Test Attachment 0', projects[0].getAttachments()[0].getName());

        projects[0].getAttachments()[0].setName('Test Attachment 1');

        System.assertEquals('Test Attachment 1', projects[0].getAttachments()[0].getName());

        List<GFA_Attachment> attachments = GFA_Attachment.find.findByProjectId(projects[0].getId());

        GFA_Attachment attachmentTest = GFA_Attachment.find.findById(attachments[0].getId());
        attachmentTest.setName('Test Attachment 2');

        System.assertEquals('Test Attachment 2', attachmentTest.getName());

    }
}