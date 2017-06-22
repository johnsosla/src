@isTest
private class rsProfilePartTest {

    private static testMethod void testProfilePartDataAccess() {
        rsTestUtil.createTestProfileParts(1,10);
        List<User> users = [select Id from User where Geography__c =: '0xDEADBEEF'];

        Test.startTest();
        List<rsProfilePart> parts = rsProfilePart.find.byIdAsSelfOrProxyOrCM(users[0].Id);
        rsProfilePart part = parts[0];

        part.getStatus();
        part.setPublicationDate('');
        Boolean isType = part.isType(rsProfilePart.RT_TRAINING);
        part.setDateCertified('');
        part.getHeldFrom();
        part.getHeldTo();
        part.setMemberSince('');
        part.getCountry();

        part.setIssuedDate('');
        part.setExpirationDate('');
        part.setYearObtained(-11);
        part.getCompanyName();
        part.getJobTitle();
        part.setStartDate('');
        part.getCity();
        part.getWorkHistoryCountry();
        part.getWorkHistoryState();
        part.setCurrent(true);
        part.getCurrent();
        part.setAwardDate('');
        part.setTrainingDate('');
        part.getOutputOnResume();
        part.setSF254Discipline(null);
        part.getSF254Discipline();
        part.setSF330Discipline(null);
        part.getSF330Discipline();
        part.getIsSF254Primary();
        part.getIsSF330Primary();
        part.getAttachmentId();
        part.setAttachmentId(null);
        part.getAttachmentName();
        part.setAttachmentName('none');
        part.getNextPart();
        part.setNextPart(null);
        part.getPreviousPart();
        part.setPreviousPart(null);
        part.getInitialLocale();
        part.setInitialLocale(UserInfo.getLocale());
        part.getIsPendingOrInReview();

        Test.stopTest();


        System.assert(isType);
    }

    private static testMethod void testProfilePartFinders() {
        rsTestUtil.createTestProfileParts(1,10);
        List<User> users = [select Id from User where Geography__c =: '0xDEADBEEF'];
        Test.startTest();
        List<rsProfilePart> parts = rsProfilePart.find.byIdAsEmployee(UserInfo.getUserId());
        List<rs_Profile_Part__c> rawParts = rsProfilePart.find.byUsers(new Set<Id>{UserInfo.getUserId()});
        List<rs_Profile_Part__c> rawParts2 = rsProfilePart.find.byUsersAndWhere('Output_On_Resume__c = true',new Set<Id>{users[0].Id});
        Test.stopTest();
    }

    private static testMethod void testProfilePartFinders2() {
        rsTestUtil.createTestProfileParts(1,10);
        List<User> users = [select Id from User where Geography__c =: '0xDEADBEEF'];

        Test.startTest();
        rsProfilePart.find.reviewUnassigned(DateTime.now(), DateTime.now(), 'AB', 'CD', 'EF', 'G', 'HI', 'JK', 'asc');
        rsProfilePart.find.reviewAssignedToMe(UserInfo.getUserId(),null,null,null,null,null,null,null,'asc');
        rsProfilePart.find.reviewCompleted(null,null,null,null,null,null,null,'asc');
        rsProfilePart.find.reviewCompleted(null,DateTime.now(),'AB',null,null,null,null,'asc');
        rsProfilePart.find.reviewCompleted(null,DateTime.now(),'AB','CD',null,null,null,'asc');
        rsProfilePart.find.reviewCompleted(null,DateTime.now(),'AB','CD','EF',null,null,'asc');
        rsProfilePart.find.reviewCompleted(null,DateTime.now(),'AB','CD','EF','G',null,'asc');
        Test.stopTest();
    }
}