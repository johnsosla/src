@isTest
private class rsPRTeamEmployeeCriteriaTest {

    @isTest static void testConstructor() {
        rsPRTeamEmployeeCriteria criteria = new rsPRTeamEmployeeCriteria();
        String nonAecomProjectRecordTypeId = PR_Team_Employee__c.SObjectType.getDescribe().getRecordTypeInfosByName().get(rsPRTeamEmployee.RT_NONAECOMPROJECT).getRecordTypeId();
        criteria.UserId = UserInfo.getUserId();
        criteria.ProjectGroup = 'TEST ProjectGroup';
        criteria.ProjectName = 'TEST ProjectName';
        criteria.ClientName = 'TEST client';
        criteria.LocationCountry = 'United States';
        criteria.LocationCity = 'CITY';
        criteria.RecordTypeId = nonAecomProjectRecordTypeId;
        String whereClause = criteria.getWhereClause();

        Test.startTest();
        System.assert(whereClause.contains('TEST ProjectGroup'));
        System.assert(whereClause.contains('TEST ProjectName'));
        System.assert(whereClause.contains('TEST client'));
        System.assert(whereClause.contains('United States'));
        System.assert(whereClause.contains('CITY'));
        System.assert(whereClause.contains('Status__c != ' + rsStringUtil.quote(rsPRTeamEmployee.S_ARCHIVED)));

        criteria.Status = rsPRTeamEmployee.S_APPROVED;
        String approvedStatus = criteria.getWhereClause();
        System.assert(approvedStatus.contains('Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_APPROVED)));

        criteria.Status = rsPRTeamEmployee.S_PENDING;
        String pendingStatus = criteria.getWhereClause();
        System.assert(pendingStatus.contains('Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_PENDING)));

        criteria.Status = rsPRTeamEmployee.S_ALL;
        String allStatus = criteria.getWhereClause();
        System.assert(!allStatus.contains('Status__c'));
        Test.stopTest();

    }


}