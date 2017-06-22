@isTest
private class rsProfileTest {

    private static testMethod void testProfile() {

        rsTestUtil.createTestProfileParts(1,10);
        List<User> users = [select Id from User where Geography__c =: '0xDEADBEEF'];

        Test.startTest();
        rsProfile p = rsProfile.find.byUserId(users[0].Id);
        List<rsProfilePart> parts = p.getPartsByType(rsProfilePart.RT_TRAINING);
        String status = p.getStatus();
        p.setLock(true);
        Boolean locked = p.getLock();

        p.setProfileReviewer(null);
        String reviewer = p.getProfileReviewer();


        p.setDateProxyAdded(Date.today());
        p.getProfileProxy();

        p.getCitizenship();
        p.setCitizenship('Murica');

        p.setTermDate('12/28/1985');
        p.getTermDate();

        p.getDateOfBirth();
        p.setDateOfBirth('12/28/1985');

        p.getTrackingId();
        p.setTrackingId('someId');

        p.getAdjustedServiceDate();
        p.setAdjustedServiceDate('12/28/1985');

        p.getGender();
        p.setGender('teehee');

        p.getAssignmentStatus();
        p.setAssignmentStatus('someStatus');

        p.getEmployeeCategory();
        p.setEmployeeCategory('mep');

        p.getInternationalAssignmentStatus();
        p.setInternationalAssignmentStatus('lolz');

        p.getOriginalHireDate();
        //p.setOriginalHireDate('12/28/1985');

        p.getJobFamilyMeaning();
        p.setJobFamilyMeaning('No Meaning');

        p.getRehireDate();
        p.setRehireDate('12/28/1985');

        p.getNationality();
        p.setNationality('Murica');

        p.setMiscellaneousNotes('MiscNotes');
        System.assertEquals('MiscNotes', p.getMiscellaneousNotes());

        p.setNoteToUser('NoteToUser');
        System.assertEquals('NoteToUser', p.getNoteToUser());

        p.setNoteToEmployee('NoteToEmployee');
        System.assertEquals('NoteToEmployee', p.getNoteToEmployee());

        Test.stopTest();


        System.assert(locked);

    }

}