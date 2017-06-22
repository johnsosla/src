@isTest
private class rsUserProfilePartsSummaryTriggerTest {

    @isTest static void testTriggerAward() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,2000,0,rsProfilePart.RT_AWARD,rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        Test.stopTest();

        List<User> users = [Select Award_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_AWARD)
                System.assert(u.Award_Summary__c.contains('Test Award Title') &&
                                u.Award_Summary__c.contains('...'));
        }
    }

    @isTest static void testTriggerCertification() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,1366,0,rsProfilePart.RT_CERTIFICATION,rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        Test.stopTest();

        List<User> users = [Select Certification_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_CERTIFICATION)
                System.assert(u.Certification_Summary__c.contains('Test Certification Title') &&
                                u.Certification_Summary__c.contains('...')
                                );
        }
    }

    @isTest static void testTriggerEducation() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,410,0,rsProfilePart.RT_EDUCATION,rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        Test.stopTest();

        List<User> users = [Select Education_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_EDUCATION)
                System.assert(u.Education_Summary__c.contains('Test Institution') &&
                              u.Education_Summary__c.contains('Test Degree') &&
                              u.Education_Summary__c.contains('Test Degree Specialty') &&
                              u.Education_Summary__c.contains('Test Institution Country') &&
                              u.Education_Summary__c.contains('1998') &&
                              u.Education_Summary__c.contains('...')
                             );
        }
    }

    @isTest static void testTriggerLanguages() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,619,0,rsProfilePart.RT_LANGUAGES,rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        Test.stopTest();

        List<User> users = [Select Languages_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_LANGUAGES)
                System.assert(u.Languages_Summary__c.contains('Test Language') &&
                              u.Languages_Summary__c.contains('Test Language Skill') &&
                              u.Languages_Summary__c.contains('Test Language Level') &&
                              u.Languages_Summary__c.contains('...')
                             );
        }
    }

    @isTest static void testTriggerAssociation() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,1570,0,rsProfilePart.RT_PROF_AFFILIATION,rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        Test.stopTest();

        List<User> users = [Select Professional_Affiliation_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_PROF_AFFILIATION)
                System.assert(u.Professional_Affiliation_Summary__c.contains('Test Association Name') &&
                                u.Professional_Affiliation_Summary__c.contains('...'));
        }
    }

    @isTest static void testTriggerPublication() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,1570,0,rsProfilePart.RT_PUBLICATION,rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        Test.stopTest();

        List<User> users = [Select Publication_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_PUBLICATION)
                System.assert(u.Publication_Summary__c.contains('Test Publication Title') &&
                                u.Publication_Summary__c.contains('...'));

        }
    }

    @isTest static void testTriggerRegistration() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,1100,0,rsProfilePart.RT_REGISTRATION,rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        Test.stopTest();

        List<User> users = [Select Registration_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_REGISTRATION)
                System.assert(u.Registration_Summary__c.contains('Test License/Registration Name') &&
                                u.Registration_Summary__c.contains('...'));
        }
    }

    @isTest static void testTriggerSF254() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,1570,0,rsProfilePart.RT_SF254,rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        Test.stopTest();

        List<User> users = [Select SF254_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_SF254)
                System.assert(u.SF254_Summary__c.contains('Test SF254 Discipline') &&
                                u.SF254_Summary__c.contains('...')
                            );
        }
    }

    @isTest static void testTriggerAwardSF330() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,1570,0,rsProfilePart.RT_SF330,rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        Test.stopTest();

        List<User> users = [Select SF330_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_SF330)
                System.assert(u.SF330_Summary__c.contains('Test SF330 Discipline') &&
                                u.SF330_Summary__c.contains('...')
                             );
        }
    }

    //@isTest static void testTriggerSkills() {
    //  Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    //  Map<Id, String> recordIdToName = new Map<Id,String>();
    //  for(String str : mRtInfo.keySet()) {
    //      recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
    //  }
    //  rsTestUtil.createTestProfileParts(1,770,0,rsProfilePart.RT_SKILL_INDEX,rsPRTeamEmployee.RT_AECOMPROJECT);

    //  List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
    //  Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
    //  for(rs_Profile_Part__c pp : pps) {
    //      pp.Status__c = rsProfilePart.S_APPROVED;
    //      userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
    //  }
    //  Test.startTest();
    //  update pps;
    //  Test.stopTest();

    //  List<User> users = [Select Skill_Index_Summary__c
    //                      from User
    //                      where Id IN: userIdToPPRecordType.keySet()];
    //  for(User u : users) {
    //      if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_SKILL_INDEX)
    //          System.assert(u.Skill_Index_Summary__c.contains('Test Skill Area') &&
    //                        u.Skill_Index_Summary__c.contains('Test Skill') &&
    //                        u.Skill_Index_Summary__c.contains('Test Skill Level') &&
    //                        u.Skill_Index_Summary__c.contains('...')
    //                       );
    //  }
    //}

    @isTest static void testTriggerTraining() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,2530,0,rsProfilePart.RT_TRAINING,rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        Test.stopTest();

        List<User> users = [Select Training_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_TRAINING)
                System.assert(u.Training_Summary__c.contains('Test Training') &&
                                u.Training_Summary__c.contains('...')
                                );
        }
    }
    @isTest static void testTriggerTranslations() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,890,0,rsProfilePart.RT_TRANSLATIONS,rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        Test.stopTest();

        List<User> users = [Select Translations_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_TRANSLATIONS)
                System.assert(u.Translations_Summary__c.contains('Test Translate From') &&
                              u.Translations_Summary__c.contains('Test Translate To') &&
                              u.Translations_Summary__c.contains('...')
                             );
        }
    }
    @isTest static void testTriggerWorkHistory() {
        Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
        Map<Id, String> recordIdToName = new Map<Id,String>();
        for(String str : mRtInfo.keySet()) {
            recordIdToName.put(mRtInfo.get(str).getRecordTypeId(),str);
        }
        rsTestUtil.createTestProfileParts(1,320,0,rsProfilePart.RT_WORK_HISTORY,rsPRTeamEmployee.RT_AECOMPROJECT);

        List<rs_Profile_Part__c> pps = [Select Status__c,User__c,RecordTypeId from rs_Profile_Part__c];
        Map<Id,String> userIdToPPRecordType = new Map<Id,String>();
        for(rs_Profile_Part__c pp : pps) {
            pp.Status__c = rsProfilePart.S_APPROVED;
            userIdToPPRecordType.put(pp.User__c,recordIdToName.get(pp.RecordTypeId));
        }
        Test.startTest();
        update pps;
        Test.stopTest();

        List<User> users = [Select Work_History_Summary__c
                            from User
                            where Id IN: userIdToPPRecordType.keySet()];
        for(User u : users) {
            if(userIdToPPRecordType.get(u.Id) == rsProfilePart.RT_WORK_HISTORY)
                System.assert(u.Work_History_Summary__c.contains('Test Company Name') &&
                              u.Work_History_Summary__c.contains('Test Job Title') &&
                              u.Work_History_Summary__c.contains('10/13/1999') &&
                              u.Work_History_Summary__c.contains('Test City') &&
                              u.Work_History_Summary__c.contains('Test Work History Country') &&
                              u.Work_History_Summary__c.contains('Test Work Hisotry State')
                             );
        }
    }

}