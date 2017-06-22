@isTest
private class rsGlobalMobilityControllerTest {

    @isTest static void testController() {
        rsTestUtil.createTestUsers(true, 1);
        User u = [Select Id, Interest_Countries__c,Interest_Regions__c,Interest_Relocating_Current_Country__c,
                    Interest_Relocating_Different_Country__c,Length_of_Time_Abroad__c,No_Interest_Countries__c,
                    No_Interest_Regions__c
                  from User
                  where Id !=: UserInfo.getUserId() LIMIT 1];
        rsProfile profile = new rsProfile(u);
        rsGlobalMobilityController cont = new rsGlobalMobilityController();
        cont.profile = profile;
        List<SelectOption> interestedCountries = new List<SelectOption>{new SelectOption('United States','United States')};
        List<SelectOption> notInterestedCountries = new List<SelectOption>{new SelectOption('Anguilla','Anguilla')};
        List<SelectOption> interestedRegions = new List<SelectOption>{new SelectOption('Africa','Africa'),new SelectOption('Americas','Americas')};
        List<SelectOption> notInterestedRegions = new List<SelectOption>{new SelectOption('Asia','Asia')};
        Test.startTest();
        cont.editPart();
        cont.cancelPart();
        cont.editPart();
        Boolean checkAvailInterest = cont.availableInterestCountries.size() > 0;
        Boolean checkAvailNoInterest = cont.availableNoInterestCountries.size() > 0;
        Boolean checkSelectedInterest = cont.getInterestCountriesSel().size() == 0;
        Boolean checkSelectedNoInterest = cont.getNoInterestCountriesSel().size() == 0;
        cont.setInterestCountriesSel(interestedCountries);
        cont.setInterestRegionsSel(interestedRegions);
        cont.profile.setInterestRelocatingCurrentCountry('Yes');
        cont.profile.setInterestRelocatingDifferentCountry('No');
        cont.profile.setLengthOfTimeAbroad('Open Ended');
        cont.setNoInterestRegionsSel(notInterestedRegions);
        cont.setNoInterestCountriesSel(notInterestedCountries);
        cont.profile.setTimeToRelocate('Immediate');
        cont.profile.setAccompaniedStatus('Unaccompanied');
        cont.savePart();
        Test.stopTest();

        User u2 = [Select Id, Interest_Countries__c,Interest_Regions__c,Interest_Relocating_Current_Country__c,
                    Interest_Relocating_Different_Country__c,Length_of_Time_Abroad__c,No_Interest_Countries__c,
                    No_Interest_Regions__c, rs_Time_To_Relocate__c, rs_Accompanied_Status__c
                  from User
                  where Id =: u.Id];
        System.assertEquals(true,checkAvailInterest);
        System.assertEquals(true,checkAvailNoInterest);
        System.assertEquals(true,checkSelectedInterest);
        System.assertEquals(true,checkSelectedNoInterest);
        System.assertEquals(cont.profile.getInterestCountries(),u2.Interest_Countries__c);
        System.assertEquals(cont.profile.getInterestRegions(),u2.Interest_Regions__c);
        System.assertEquals(cont.profile.getInterestRelocatingCurrentCountry(),u2.Interest_Relocating_Current_Country__c);
        System.assertEquals(cont.profile.getInterestRelocatingDifferentCountry(),u2.Interest_Relocating_Different_Country__c);
        System.assertEquals(cont.profile.getLengthOfTimeAbroad(),u2.Length_of_Time_Abroad__c);
        System.assertEquals(cont.profile.getNoInterestCountries(),u2.No_Interest_Countries__c);
        System.assertEquals(cont.profile.getNoInterestRegions(),u2.No_Interest_Regions__c);
        System.assertEquals(cont.profile.getTimeToRelocate(), u2.rs_Time_To_Relocate__c);
        System.assertEquals(cont.profile.getAccompaniedStatus(), u2.rs_Accompanied_Status__c);
    }

    @isTest static void testSetupCaseBoth() {
        rsTestUtil.createTestUsers(true, 1);
        User u = [Select Id, Interest_Countries__c,Interest_Regions__c,Interest_Relocating_Current_Country__c,
                    Interest_Relocating_Different_Country__c,Length_of_Time_Abroad__c,No_Interest_Countries__c,
                    No_Interest_Regions__c
                  from User
                  where Id !=: UserInfo.getUserId() LIMIT 1];
        u.Interest_Countries__c = 'Anguilla; United States';
        u.No_Interest_Countries__c = 'Andorra';
        update u;
        rsProfile profile = new rsProfile(u);
        rsGlobalMobilityController cont = new rsGlobalMobilityController();
        cont.profile = profile;

        Test.startTest();
        cont.editPart();
        Boolean checkSelectedInterest = cont.getInterestCountriesSel().size() == 2;
        Boolean checkSelectedNoInterest = cont.getNoInterestCountriesSel().size() == 1;
        Test.stopTest();

        System.assertEquals(true, checkSelectedInterest);
        System.assertEquals(true, checkSelectedNoInterest);
    }

    @isTest static void testSetupCaseInterest() {
        rsTestUtil.createTestUsers(true, 1);
        User u = [Select Id, Interest_Countries__c,Interest_Regions__c,Interest_Relocating_Current_Country__c,
                    Interest_Relocating_Different_Country__c,Length_of_Time_Abroad__c,No_Interest_Countries__c,
                    No_Interest_Regions__c
                  from User
                  where Id !=: UserInfo.getUserId() LIMIT 1];
        u.Interest_Countries__c = 'Anguilla; United States';
        update u;
        rsProfile profile = new rsProfile(u);
        rsGlobalMobilityController cont = new rsGlobalMobilityController();
        cont.profile = profile;

        Test.startTest();
        cont.editPart();
        Boolean checkSelectedInterest = cont.getInterestCountriesSel().size() == 2;
        Boolean checkSelectedNoInterest = cont.getNoInterestCountriesSel().size() == 0;
        Test.stopTest();

        System.assertEquals(true, checkSelectedInterest);
        System.assertEquals(true, checkSelectedNoInterest);
    }

    @isTest static void testSetupCaseNoInterest() {
        rsTestUtil.createTestUsers(true, 1);
        User u = [Select Id, Interest_Countries__c,Interest_Regions__c,Interest_Relocating_Current_Country__c,
                    Interest_Relocating_Different_Country__c,Length_of_Time_Abroad__c,No_Interest_Countries__c,
                    No_Interest_Regions__c
                  from User
                  where Id !=: UserInfo.getUserId() LIMIT 1];
        u.No_Interest_Countries__c = 'Andorra';
        update u;
        rsProfile profile = new rsProfile(u);
        rsGlobalMobilityController cont = new rsGlobalMobilityController();
        cont.profile = profile;

        Test.startTest();
        cont.editPart();
        Boolean checkSelectedInterest = cont.getInterestCountriesSel().size() == 0;
        Boolean checkSelectedNoInterest = cont.getNoInterestCountriesSel().size() == 1;
        Test.stopTest();

        System.assertEquals(true, checkSelectedInterest);
        System.assertEquals(true, checkSelectedNoInterest);
    }

    @isTest static void testSetupRegionsBoth() {
        rsTestUtil.createTestUsers(true, 1);
        User u = [Select Id, Interest_Countries__c,Interest_Regions__c,Interest_Relocating_Current_Country__c,
                    Interest_Relocating_Different_Country__c,Length_of_Time_Abroad__c,No_Interest_Countries__c,
                    No_Interest_Regions__c
                  from User
                  where Id !=: UserInfo.getUserId() LIMIT 1];
        u.Interest_Regions__c = 'Africa;Asia';
        u.No_Interest_Regions__c = 'Europe';
        update u;
        rsProfile profile = new rsProfile(u);
        rsGlobalMobilityController cont = new rsGlobalMobilityController();
        cont.profile = profile;

        Test.startTest();
        cont.editPart();
        Boolean checkSelectedInterest = cont.getInterestRegionsSel().size() == 2;
        Boolean checkSelectedNoInterest = cont.getNoInterestRegionsSel().size() == 1;
        Test.stopTest();

        System.assertEquals(true, checkSelectedInterest);
        System.assertEquals(true, checkSelectedNoInterest);
    }

    @isTest static void testSetupCaseInterestRegions() {
        rsTestUtil.createTestUsers(true, 1);
        User u = [Select Id, Interest_Countries__c,Interest_Regions__c,Interest_Relocating_Current_Country__c,
                    Interest_Relocating_Different_Country__c,Length_of_Time_Abroad__c,No_Interest_Countries__c,
                    No_Interest_Regions__c
                  from User
                  where Id !=: UserInfo.getUserId() LIMIT 1];
        u.Interest_Regions__c = 'Africa;Asia';
        update u;
        rsProfile profile = new rsProfile(u);
        rsGlobalMobilityController cont = new rsGlobalMobilityController();
        cont.profile = profile;

        Test.startTest();
        cont.editPart();
        Boolean checkSelectedInterest = cont.getInterestRegionsSel().size() == 2;
        Boolean checkSelectedNoInterest = cont.getNoInterestRegionsSel().size() == 0;
        Test.stopTest();

        System.assertEquals(true, checkSelectedInterest);
        System.assertEquals(true, checkSelectedNoInterest);
    }

    @isTest static void testSetupCaseNoInterestRegions() {
        rsTestUtil.createTestUsers(true, 1);
        User u = [Select Id, Interest_Countries__c,Interest_Regions__c,Interest_Relocating_Current_Country__c,
                    Interest_Relocating_Different_Country__c,Length_of_Time_Abroad__c,No_Interest_Countries__c,
                    No_Interest_Regions__c
                  from User
                  where Id !=: UserInfo.getUserId() LIMIT 1];
        u.No_Interest_Regions__c = 'Europe';
        update u;
        rsProfile profile = new rsProfile(u);
        rsGlobalMobilityController cont = new rsGlobalMobilityController();
        cont.profile = profile;

        Test.startTest();
        cont.editPart();
        Boolean checkSelectedInterest = cont.getInterestRegionsSel().size() == 0;
        Boolean checkSelectedNoInterest = cont.getNoInterestRegionsSel().size() == 1;
        Test.stopTest();

        System.assertEquals(true, checkSelectedInterest);
        System.assertEquals(true, checkSelectedNoInterest);
    }

}