@isTest
private class rsUserSummaryFieldsBatchProcessorTest {

    @isTest static void testProfilePartBatch() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_AWARD,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_CERTIFICATION,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_EDUCATION,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_LANGUAGES,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_PROF_AFFILIATION,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_PUBLICATION,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_REGISTRATION,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_SF254,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_SF330,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_SKILL_INDEX,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_TRAINING,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_TRANSLATIONS,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_WORK_HISTORY,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,10,0,rsProfilePart.RT_PERSONAL, rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        String query = 'Select ' + String.join(new List<String>(rsProfilePart.find.getFieldSet()),',') + ' from rs_Profile_Part__c where Status__c = ' + rsStringUtil.quote(rsProfilePart.S_APPROVED);
        List<User> users = [Select Award_Summary__c,Certification_Summary__c,Education_Summary__c,Languages_Summary__c,
                               Professional_Affiliation_Summary__c,Publication_Summary__c,Registration_Summary__c,
                               SF254_Summary__c,SF330_Summary__c,Skill_Index_Summary__c,Training_Summary__c,Translations_Summary__c,
                               Work_History_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        // Clear fields from trigger
        for(User user : users) {
            user.Award_Summary__c = '';
            user.Certification_Summary__c = '';
            user.Education_Summary__c = '';
            user.Languages_Summary__c = '';
            user.Professional_Affiliation_Summary__c = '';
            user.Publication_Summary__c = '';
            user.Registration_Summary__c = '';
            user.SF254_Summary__c = '';
            user.SF330_Summary__c = '';
            user.Skill_Index_Summary__c = '';
            user.Training_Summary__c = '';
            user.Translations_Summary__c = '';
            user.Work_History_Summary__c = '';
        }
        update users;
        Database.executeBatch(new rsUserSummaryFieldsBatchProcessor(query));
        Test.stopTest();

        users = [Select Award_Summary__c,Certification_Summary__c,Education_Summary__c,Languages_Summary__c,
                               Professional_Affiliation_Summary__c,Publication_Summary__c,Registration_Summary__c,
                               SF254_Summary__c,SF330_Summary__c,Skill_Index_Summary__c,Training_Summary__c,Translations_Summary__c,
                               Work_History_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_AWARD)
                System.assert(u.Award_Summary__c.contains('Test Award Title'));

            else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_CERTIFICATION)
                System.assert(u.Certification_Summary__c.contains('Test Certification Title'));

            else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_EDUCATION)
                System.assert(u.Education_Summary__c.contains('Test Institution') &&
                              u.Education_Summary__c.contains('Test Degree') &&
                              u.Education_Summary__c.contains('Test Degree Specialty') &&
                              u.Education_Summary__c.contains('Test Institution Country') &&
                              u.Education_Summary__c.contains('1998')
                             );

            else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_LANGUAGES)
                System.assert(u.Languages_Summary__c.contains('Test Language') &&
                              u.Languages_Summary__c.contains('Test Language Skill') &&
                              u.Languages_Summary__c.contains('Test Language Level')
                             );

            else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_PROF_AFFILIATION)
                System.assert(u.Professional_Affiliation_Summary__c.contains('Test Association Name'));

            else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_PUBLICATION)
                System.assert(u.Publication_Summary__c.contains('Test Publication Title'));

            else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_REGISTRATION)
                System.assert(u.Registration_Summary__c.contains('Test License/Registration Name'));

            else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_SF254)
                System.assert(u.SF254_Summary__c.contains('Test SF254 Discipline'));

            else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_SF330)
                System.assert(u.SF330_Summary__c.contains('Test SF330 Discipline'));

            //else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_SKILL_INDEX)
            //  System.assert(u.Skill_Index_Summary__c.contains('Test Skill Area') &&
            //                u.Skill_Index_Summary__c.contains('Test Skill') &&
            //                u.Skill_Index_Summary__c.contains('Test Skill Level')
            //               );

            else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_TRAINING)
                System.assert(u.Training_Summary__c.contains('Test Training'));

            else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_TRANSLATIONS)
                System.assert(u.Translations_Summary__c.contains('Test Translate From') &&
                              u.Translations_Summary__c.contains('Test Translate To')
                             );

            else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_WORK_HISTORY)
                System.assert(u.Work_History_Summary__c.contains('Test Company Name') &&
                              u.Work_History_Summary__c.contains('Test Job Title') &&
                              u.Work_History_Summary__c.contains('10/13/1999') &&
                              u.Work_History_Summary__c.contains('Test City') &&
                              u.Work_History_Summary__c.contains('Test Work History Country') &&
                              u.Work_History_Summary__c.contains('Test Work Hisotry State')
                             );
            else if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_WORK_HISTORY)
                System.assert(u.Resume_Name__c == 'Test Resume Name');
        }
    }

    @isTest static void testProjectsBatch() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,0,100,rsProfilePart.RT_AWARD,rsPRTeamEmployee.RT_AECOMPROJECT);
        rsTestUtil.createTestProfileParts(1,0,100,rsProfilePart.RT_AWARD,rsPRTeamEmployee.RT_NONAECOMPROJECT);

        List<PR_Team_Employee__c> projs = [Select Status__c,EmployeeUser__c,RecordTypeId from PR_Team_Employee__c];
        Map<Id,String> userIdToProjRecordType = new Map<Id,String>();
        for(PR_Team_Employee__c proj : projs) {
            proj.Status__c = rsPRTeamEmployee.S_APPROVED;
            userIdToProjRecordType.put(proj.EmployeeUser__c,recordIdToName.get(proj.RecordTypeId));
        }

        Test.startTest();
        update projs;
        String query = 'Select ' + String.join(new List<String>(rsPRTeamEmployee.find.getFieldSet()),',') + ' from PR_Team_Employee__c where Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_APPROVED);
        List<User> users = [Select AECOM_Projects_Summary__c, Non_AECOM_Projects_Summary__c
                            from User
                            where Id IN: userIdToProjRecordType.keySet()];
        // Clear user summary fields from trigger
        for(User user : users) {
            user.AECOM_Projects_Summary__c = '';
            user.Non_AECOM_Projects_Summary__c = '';
        }
        update users;
        Database.executeBatch(new rsUserSummaryFieldsBatchProcessor(query));
        Test.stopTest();

        users = [Select AECOM_Projects_Summary__c, Non_AECOM_Projects_Summary__c
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
                              u.AECOM_Projects_Summary__c.contains('Test Location Country')
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
                              u.Non_AECOM_Projects_Summary__c.contains('Test Location Country')
                             );
            }
        }
    }

}