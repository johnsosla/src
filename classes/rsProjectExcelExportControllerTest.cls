@isTest
private class rsProjectExcelExportControllerTest {

    @isTest static void testExport() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_AECOMPROJECT, 1);
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 1);

        rsProjectController cont = new rsProjectController();
        cont.profile = rsProfile.find.byUserId(UserInfo.getUserId());
        cont.Filter = new rsFilterManager();
        cont.Filter.UserId = cont.profile.getId();
        cont.Filter.setupProjectSearchFilters();

        PageReference pg = cont.exportProjectsToExcel();

        List<rs_Search__c> searches = [Select Id from rs_Search__c];
        System.assertNotEquals(0, searches.size(), 'Project export should have saved a search');

        List<Attachment> attachments = [Select Id from Attachment where ParentId = :searches[0].Id];
        System.assertNotEquals(0, attachments.size(), 'Project export should have created an attachment containing the JSON');

        ApexPages.currentPage().getParameters().put('id', searches[0].Id);

        rsProjectExcelExportController exportController = new rsProjectExcelExportController();

        System.assertNotEquals(0, exportController.searchResults.size(), 'ExportController should have gotten search results from attachment JSON');
        System.assertNotEquals(null, exportController.xlsHeader, 'ExportController should have an XLS Header');

        exportController.deleteSearchRecord();

        searches = [Select Id from rs_Search__c];
        System.assertEquals(0, searches.size(), 'Project export should have deleted the temporary search');

        attachments = [Select Id from Attachment];
        System.assertEquals(0, attachments.size(), 'Project export should have deleted the temporary attachments');


    }


}