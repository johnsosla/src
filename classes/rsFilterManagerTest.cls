@isTest
private class rsFilterManagerTest {

    @isTest static void testSetupFilters() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 10);

        rsFilterManager filter = new rsFilterManager();
        filter.UserId = UserInfo.getUserId();
        filter.setupProjectSearchFilters();

        System.assertEquals(2, filter.ProjectGroups.size());
        System.assertEquals(2, filter.ProjectNames.size());
        System.assertEquals(2, filter.ClientNames.size());
        System.assertEquals(true, filter.LocationCountries.size() > 1);
        System.assertEquals(2, filter.LocationCities.size());
        System.assertEquals(3, filter.RecordTypes.size());
    }

}