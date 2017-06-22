@isTest
private class rsUserProjectsSummaryTriggerTest {

    @isTest static void testTrigger() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,0,850,rsProfilePart.RT_AWARD,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,0,850,rsProfilePart.RT_AWARD,rsPRTeamEmployee.RT_NONAECOMPROJECT);

        List<PR_Team_Employee__c> projs = [Select Status__c,EmployeeUser__c,RecordTypeId from PR_Team_Employee__c];
        Map<Id,String> userIdToProjRecordType = new Map<Id,String>();
        for(PR_Team_Employee__c proj : projs) {
            proj.Status__c = rsPRTeamEmployee.S_APPROVED;
            userIdToProjRecordType.put(proj.EmployeeUser__c,recordIdToName.get(proj.RecordTypeId));
        }

        Test.startTest();
        update projs;
        Test.stopTest();

        List<User> users = [Select AECOM_Projects_Summary__c, Non_AECOM_Projects_Summary__c
                            from User
                            where Id IN: userIdToProjRecordType.keySet()];

        for(User u : users) {
            if(userIdToProjRecordType.get(u.Id) == rsPRTeamEmployee.RT_AECOMPROJECT) {
                System.assert(u.AECOM_Projects_Summary__c.contains('Test Project Name') &&
                              u.AECOM_Projects_Summary__c.contains('09/10/11') &&
                              u.AECOM_Projects_Summary__c.contains('01/02/13') &&
                              u.AECOM_Projects_Summary__c.contains('This is a test role') &&
                              u.AECOM_Projects_Summary__c.contains('This is a test description of my test role') &&
                              u.AECOM_Projects_Summary__c.contains('Test Client Name') &&
                              u.AECOM_Projects_Summary__c.contains('Test Project Group') &&
                              u.AECOM_Projects_Summary__c.contains('Test Location Country') &&
                              u.AECOM_Projects_Summary__c.contains('...')
                             );
            }
            else if(userIdToProjRecordType.get(u.Id) == rsPRTeamEmployee.RT_NONAECOMPROJECT) {
                System.assert(u.Non_AECOM_Projects_Summary__c.contains('Test Project Name') &&
                              u.Non_AECOM_Projects_Summary__c.contains('09/10/11') &&
                              u.Non_AECOM_Projects_Summary__c.contains('01/02/13') &&
                              u.Non_AECOM_Projects_Summary__c.contains('This is a test role') &&
                              u.Non_AECOM_Projects_Summary__c.contains('This is a test description of my test role') &&
                              u.Non_AECOM_Projects_Summary__c.contains('Test Client Name') &&
                              u.Non_AECOM_Projects_Summary__c.contains('Test Project Group') &&
                              u.Non_AECOM_Projects_Summary__c.contains('Test Location Country') &&
                              u.Non_AECOM_Projects_Summary__c.contains('...')
                             );
            }
        }
    }

}