/*************************************************************************
*
* PURPOSE: Test Class for Controller for Update Tracking Section
*
* CREATED: 2015 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
@isTest
private class rsUpdateTrackingControllerTest {
    private static rsUpdateTrackingController setupController() {
        User u = [Select Id from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);

        rsUpdateTrackingController cont = new rsUpdateTrackingController();
        cont.profile = profile;
        return cont;
    }
    @isTest static void testSave() {
        rsUpdateTrackingController cont = setupController();

        cont.newPart();
        cont.CurrentTrackUpdate.setDetails('deets');
        cont.CurrentTrackUpdate.setSource('source');

        Test.startTest();
        System.assertEquals(0, cont.profile.getProfileUpdateTrackings().size());
        PageReference pf = cont.savePart();
        Test.stopTest();

        rs_Update_Tracking__c ut = [Select Id, Source__c, Details__c, User__c from rs_Update_Tracking__c];
        System.assertEquals(null, pf);
        System.assertEquals(ut.Id, cont.CurrentTrackUpdate.getId());
        System.assertEquals('deets', ut.Details__c);
        System.assertEquals('source', ut.Source__c);
        System.assertEquals(UserInfo.getUserId(), ut.User__c);
        System.assertEquals(1, cont.profile.getProfileUpdateTrackings().size());

        ApexPages.currentPage().getParameters().put('trackId', ut.Id);
        cont.editPart();
        System.assertEquals(true, cont.getIsEditMode());
        cont.savePart();

        System.assertEquals(1, cont.profile.getProfileUpdateTrackings().size());

        cont.newPart();
        cont.CurrentTrackUpdate.setDetails('deets2');
        cont.CurrentTrackUpdate.setSource('source2');
        cont.savePart();
        rs_Update_Tracking__c ut2 = [Select Id, Source__c, Details__c, User__c from rs_Update_Tracking__c where Id =: cont.CurrentTrackUpdate.getId()];
        ApexPages.currentPage().getParameters().put('trackId', ut2.Id);
        cont.editPart();
        cont.savePart();

        System.assertEquals(2, cont.profile.getProfileUpdateTrackings().size());
    }

    @isTest static void testCanel() {
        rsUpdateTrackingController cont = setupController();
        cont.newPart();
        cont.CurrentTrackUpdate.setDetails('deets');
        cont.CurrentTrackUpdate.setSource('source');

        cont.savePart();

        rs_Update_Tracking__c ut = [Select Id, Source__c, Details__c, User__c from rs_Update_Tracking__c];
        ApexPages.currentPage().getParameters().put('trackId', ut.Id);
        cont.editPart();

        cont.CurrentTrackUpdate.setDetails('newDeets');
        cont.CurrentTrackUpdate.setSource('newSource');

        Test.startTest();
        PageReference pr = cont.cancelPart();
        cont.editPart();
        Test.stopTest();

        System.assertEquals(null, pr);
        System.assertEquals('deets', cont.CurrentTrackUpdate.getDetails());
        System.assertEquals('source', cont.CurrentTrackUpdate.getSource());
    }

    @isTest static void testNew() {
        rsUpdateTrackingController cont = setupController();
        cont.newPart();

        System.assertEquals(UserInfo.getUserId(), cont.CurrentTrackUpdate.getUserId());
        System.assertEquals(null, cont.CurrentTrackUpdate.getId());
        System.assertEquals(true, cont.getIsEditMode());
    }

    @isTest static void testEdit() {
        rsUpdateTrackingController cont = setupController();
        cont.newPart();
        cont.CurrentTrackUpdate.setDetails('deets');
        cont.CurrentTrackUpdate.setSource('source');

        cont.savePart();

        rs_Update_Tracking__c ut = [Select Id, Source__c, Details__c, User__c from rs_Update_Tracking__c];
        ApexPages.currentPage().getParameters().put('trackId', ut.Id);

        Test.startTest();
        cont.editPart();
        Test.stopTest();

        System.assertEquals(true, cont.getIsEditMode());
        System.assertEquals(ut.Id, cont.CurrentTrackUpdate.getId());
    }

    @isTest static void testDelete() {
        rsUpdateTrackingController cont = setupController();
        cont.newPart();
        cont.CurrentTrackUpdate.setDetails('deets');
        cont.CurrentTrackUpdate.setSource('source');

        cont.savePart();

        rs_Update_Tracking__c ut = [Select Id, Source__c, Details__c, User__c from rs_Update_Tracking__c];
        ApexPages.currentPage().getParameters().put('trackId', ut.Id);

        Test.startTest();
        cont.deletePart();
        Test.stopTest();

        List<rs_Update_Tracking__c> uts = [Select Id from rs_Update_Tracking__c where Id =: ut.Id];
        System.assertEquals(0, uts.size());
    }

    @isTest static void testGetTrackingViewParts() {
        rsUpdateTrackingController cont = setupController();
        cont.newPart();
        cont.CurrentTrackUpdate.setDetails('deets');
        cont.CurrentTrackUpdate.setSource('source');
        System.assertEquals(0, cont.getTrackingViewParts().size());
        cont.savePart();

        Test.startTest();
        List<rsTrackingViewModel> models = cont.getTrackingViewParts();
        Test.stopTest();

        System.assertEquals(1, models.size());
        System.assertEquals(cont.CurrentTrackUpdate.getId(), models[0].getObj().getId());
    }

    @isTest static void testSortParts() {
        rsUpdateTrackingController cont = setupController();
        cont.newPart();
        cont.CurrentTrackUpdate.setDetails('deets');
        cont.CurrentTrackUpdate.setSource('source');
        System.assertEquals(0, cont.getTrackingViewParts().size());
        cont.savePart();

        cont.newPart();
        cont.CurrentTrackUpdate.setDetails('abc');
        cont.CurrentTrackUpdate.setSource('abc');
        cont.savePart();

        cont.getTrackingViewParts();
        ApexPages.currentPage().getParameters().put('sortField','Source__c');
        cont.sortParts();

        System.assertEquals(cont.CurrentTrackUpdate.getId(), cont.getTrackingViewParts()[0].getObj().getId());

        cont.sortParts();
        System.assertEquals(cont.CurrentTrackUpdate.getId(), cont.getTrackingViewParts()[1].getObj().getId());

        cont.sortParts();
        System.assertEquals(cont.CurrentTrackUpdate.getId(), cont.getTrackingViewParts()[0].getObj().getId());
    }
}