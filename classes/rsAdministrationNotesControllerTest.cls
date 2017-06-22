@isTest
private class rsAdministrationNotesControllerTest {

    @isTest static void testController() {
        User u = [Select Id from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);

        rsAdministrationNotesController cont = new rsAdministrationNotesController();
        cont.profile = profile;

        Test.startTest();
        cont.editPart();
        System.assertEquals(true, cont.getIsEditMode());
        cont.profile.setNoteToEmployee('yea');
        cont.savePart();
        Test.stopTest();

        User uRequery = [Select Id, rs_Note_To_Employee__c from User where Id =: u.Id];
        System.assertEquals('yea', uRequery.rs_Note_To_Employee__c);

        System.assertEquals(false, cont.getIsContentManager());
    }

    @isTest static void testCancelPart() {
        User u = [Select Id from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);

        rsAdministrationNotesController cont = new rsAdministrationNotesController();
        cont.profile = profile;

        Test.startTest();
        cont.editPart();
        cont.profile.setNoteToEmployee('yea');
        cont.cancelPart();
        Test.stopTest();

        System.assert(cont.Profile.getNoteToEmployee() != 'yea');
    }

}