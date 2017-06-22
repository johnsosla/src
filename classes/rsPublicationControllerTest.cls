@isTest
private class rsPublicationControllerTest {

    @isTest static void test_method_one() {
        User u = [Select Id, Is_Profile_Locked__c, Date_Time_Sent_for_Review__c from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsPublicationController cont = new rsPublicationController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setPublicationTitle('Test Title');
        cont.CurrentPart.setPublication('test Pub');
        cont.CurrentPart.setPublicationDate('12/2013');
        cont.CurrentPart.setPublicationAuthor('Test Author');

        Test.startTest();
        PageReference pf = cont.savePart();
        Test.stopTest();

        rs_Profile_Part__c pp = [Select Publication_Title__c, Publication__c, Publication_Date__c, Publication_Author__c
                            from rs_Profile_Part__c];

        System.assertEquals( null, pf);
        System.assertEquals( pp.Publication_Title__c, cont.CurrentPart.getPublicationTitle());
        System.assertEquals( pp.Publication__c, cont.CurrentPart.getPublication());
        System.assertEquals( true, pp.Publication_Date__c.isSameDay(Date.parse('12/01/2013')));
        System.assertEquals( pp.Publication_Author__c, cont.CurrentPart.getPublicationAuthor());

    }

    @isTest static void testMovePart() {
        User u = [Select Id from User where Id = : UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);

        rsProfilePart pub1 = new rsProfilePart(UserInfo.getUserId(), rsProfilePart.RT_PUBLICATION);
        pub1.setPublicationTitle('Test Title');
        pub1.setPublication('test Pub');
        pub1.setPublicationDate('12/12/2013');
        pub1.setPublicationAuthor('Test Author');
        pub1.setPartSequence(0);
        pub1.save();

        rsProfilePart pub2 = new rsProfilePart(UserInfo.getUserId(), rsProfilePart.RT_PUBLICATION);
        pub2.setPublicationTitle('Test Titlezzzzzzzzzzz');
        pub2.setPublication('test Pubzzzzzzzzzz');
        pub2.setPublicationDate('12/15/2013');
        pub2.setPublicationAuthor('Test Authorzzzzzzz');
        pub2.setPartSequence(1);
        pub2.save();

        rsPublicationController part1 = new rsPublicationController();
        part1.profile = profile;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('partId', pub2.getId());
        part1.movePartUp();
        part1.movePartDown();
        part1.movePartUp();
        Test.stopTest();

        rs_Profile_Part__c requery = [Select Publication_Title__c, Part_Sequence__c from rs_Profile_Part__c where Publication_Title__c = 'Test Title'];
        rs_Profile_Part__c requery2 = [Select Publication_Title__c, Part_Sequence__c from rs_Profile_Part__c where Publication_Title__c = 'Test Titlezzzzzzzzzzz'];
        System.assertEquals(1, requery.Part_Sequence__c);
        System.assertEquals(0, requery2.Part_Sequence__c);
    }

}