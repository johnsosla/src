@isTest
private class rsGenerateResumeControllerTest {

    private static testMethod void testGeneration() {
         Test.setMock(HttpCalloutMock.class, new rsGenerationMockResp());

         rsTestUtil.createTestProfileParts(10,10);
         //Pretty sure we were selecting everyone in the entire system
         //limiting to users with geography = deadbeef
         //from alex's test class
         List<User> users = [select Id from User where Geography__c =: '0xDEADBEEF'];
         List<String> userIds = new List<String>();

         for(User u : users) {
            userIds.add(u.Id);
         }

         Test.startTest();
         rsGenerateResumeController controller = new rsGenerateResumeController();
         controller.setTemplateName(rsGenerationClient.AECOM_PLAIN);
         controller.clearDownload();
         controller.UserIds = userIds;
         controller.setShowDownloadLink(false);
         controller.generateResume();
         Boolean showDownload = controller.getShowDownloadLink();
         String link = controller.getDownloadLink();
         String templateName = controller.getTemplateName();
         Test.stopTest();

         System.assert(showDownload);
         System.assert(link.contains('/download?resumeId=63'));
         System.assert(templateName.equals(rsGenerationClient.AECOM_PLAIN));



    }
}