@isTest
private class rsSearchTest {

    @isTest static void testConstructor() {
        Test.startTest();
        rsSearch rSearch = new rsSearch();
        Test.stopTest();

        System.assertEquals(rSearch.getSearchType(), rsSearch.BASIC_SEARCH);
        System.assertEquals(rSearch.getConditions().size(),0);
        System.assertNotEquals(rSearch.getUserConditions(),null);
        System.assertEquals(0,rSearch.getPRTeamEmployeeConditions().size());
        System.assertNotEquals(null,rSearch.getResultFieldOptions());
    }

    @isTest static void testConstructorWithRecord() {
       User testUser = rsTestUtil.createTestusers(false, 1)[0];
        rs_Search__c testsearch = new rs_Search__c();
        insert testsearch;

        System.runAs(testUser) {
            Test.startTest();
            rsSearch rSearch = new rsSearch(testsearch);
            rSearch.setOwnerId(UserInfo.getUserId());
            rSearch.save();
            Test.stopTest();
            System.assertEquals(testsearch.Id, rSearch.getId());
            System.assertEquals(testUser.Id, rSearch.getOwnerId());
        }

    }

    @isTest static void testAdditionalFields() {
        rsSearch rSearch = new rsSearch();

        Test.startTest();
        rSearch.setLastName('lastName');
        rSearch.setFirstName('firstName');
        rSearch.setLicenseRegistration('licReg');
        rSearch.setLicenseRegistrationCountry('licRegCountry');
        rSearch.setCountry('United States');
        rSearch.setGeography('geo');
        rSearch.setOfficeLocation('officeLoc');
        rSearch.setActive(true);
        rSearch.setName('name');
        rSearch.setSearchType(rsSearch.ADVANCED_SEARCH);
        rSearch.setBusinessLine('busLine');
        rSearch.setTextSearch('text');
        rSearch.setFilter('filter');
        Test.stopTest();

        System.assertEquals('lastName',rSearch.getLastName());
        System.assertEquals('firstName',rSearch.getFirstName());
        System.assertEquals('licReg',rSearch.getLicenseRegistration());
        System.assertEquals('licRegCountry',rSearch.getLicenseRegistrationCountry());
        System.assertEquals('United States',rSearch.getCountry());
        System.assertEquals('geo',rSearch.getGeography());
        System.assertEquals('officeLoc',rSearch.getOfficeLocation());
        System.assertEquals(true,rSearch.getActive());
        System.assertEquals('name',rSearch.getName());
        System.assertEquals(rsSearch.ADVANCED_SEARCH,rSearch.getSearchType());
        System.assertEquals('busLine',rSearch.getBusinessLine());
        System.assertEquals('text',rSearch.getTextSearch());
        System.assertEquals('filter',rSearch.getFilter());
        System.assertNotEquals(0,rSearch.getBusinessLineList().size());
        System.assertNotEquals(0,rSearch.getLicenseRegistrationList().size());
        System.assertNotEquals(0,rSearch.getCountryList().size());
        System.assertNotEquals(0,rSearch.getGeographyList().size());
        System.assertNotEquals(0,rSearch.getOfficeLocationList().size());
        System.assertNotEquals(0,rSearch.getOfficeLocation2List().size());
        System.assertNotEquals(0,rSearch.getOfficeLocation3List().size());

    }

    @isTest static void testSetConditionsTextSearchBasic() {
        rsSearch rSearch = new rsSearch();

        Test.startTest();
        rSearch.setConditions('test');
        Test.stopTest();

        //TODO Better Asserts
        System.assertNotEquals(0, rSearch.getConditions().size());
    }

    @isTest static void testSetConditionsTextSearchAdvanced() {
        rsSearch rSearch = new rsSearch();
        rSearch.setSearchType(rsSearch.ADVANCED_SEARCH);

        Test.startTest();
        rSearch.setConditions('test');
        Test.stopTest();

        //TODO Better Asserts
        System.assertNotEquals(0, rSearch.getConditions().size());
    }

    @isTest static void testGetOperators() {
        rsSearch.Condition cond = new rsSearch.Condition('test','LIKE','rs_Profile_Part__c|Name');
        rsSearch.Condition cond2 = new rsSearch.Condition('test','LIKE','');
        rsSearch.Condition cond3 = new rsSearch.Condition('test','LIKE','User|AboutMe');

        Test.startTest();
        List<SelectOption> list1 = cond.getOperators();
        List<SelectOption> list2 = cond2.getOperators();
        List<SelectOption> list3 = cond3.getOperators();
        Test.stopTest();
        //TODO Better Asserts

        System.assertEquals(9, list1.size());
        System.assertEquals(12, list2.size());
        System.assertEquals(2, list3.size());
    }

}