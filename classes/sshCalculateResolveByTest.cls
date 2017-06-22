@isTest
private class sshCalculateResolveByTest {

    private static final String ANZ_REGION = 'ANZ';
    private static final String CH_REGION = 'CH';
    private static final String HK_REGION = 'HK';
    private static final String SEA_REGION = 'SEA';

    static List<BusinessHours> bhs = [select Id, Name from BusinessHours where Name = 'Shared Services North America' or Name = 'GBS ANZ Brisbane Office' or Name = 'GBS CH Shanghai Office' or Name = 'GBS HK Hong Kong Office' or Name = 'GBS SEA Kuala Lumpur Office'];
    static List<Holiday> holidays = [Select Id, ActivityDate, Name, IsRecurrence, RecurrenceEndDateOnly from Holiday];

    static Map<String, BusinessHours> busMap = new Map<String, BusinessHours>();
    static Map<String, Schema.RecordTypeInfo> mRtInfo = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
    static Map<String, List<Holiday>> bHIdToHolidays = new Map<String, List<Holiday>>();

    private static void testSetupData() {

        Datetime testDate = Datetime.now();
        Holiday anz = new Holiday(ActivityDate = testDate.date(), Name = 'GBS ANZ Test', IsRecurrence = true, RecurrenceMonthOfYear = testdate.format('MMMMM'),
                                  RecurrenceEndDateOnly = testDate.date().addDays(3), RecurrenceStartDate = testDate.date(), RecurrenceType = 'RecursYearly',
                                  RecurrenceDayOfMonth = testDate.day());
        Holiday hk = new Holiday(ActivityDate = testDate.date(), Name = 'GBS HK Test', IsRecurrence = true, RecurrenceMonthOfYear = testdate.format('MMMMM'),
                                 RecurrenceEndDateOnly = testDate.date().addDays(3), RecurrenceStartDate = testDate.date(), RecurrenceType = 'RecursYearly',
                                 RecurrenceDayOfMonth = testDate.day());
        Holiday ch = new Holiday(ActivityDate = testDate.date(), Name = 'GBS CH Test', IsRecurrence = true, RecurrenceMonthOfYear = testdate.format('MMMMM'),
                                 RecurrenceEndDateOnly = testDate.date().addDays(3), RecurrenceStartDate = testDate.date(), RecurrenceType = 'RecursYearly',
                                 RecurrenceDayOfMonth = testDate.day());
        Holiday sea = new Holiday(ActivityDate = testDate.date(), Name = 'GBS SEA Test', IsRecurrence = true, RecurrenceMonthOfYear = testdate.format('MMMMM'),
                                  RecurrenceEndDateOnly = testDate.date().addDays(3), RecurrenceStartDate = testDate.date(), RecurrenceType = 'RecursYearly',
                                  RecurrenceDayOfMonth = testDate.day());
        holidays = new List<Holiday> {anz, hk, ch, sea};
        insert holidays;

    }

    //--Test the "after insert" functionality
    //@isTest 
    static testMethod void testCalculateResolveByAfterInsert() {

        testSetupData();

        User user = [select Id from User where Id = :UserInfo.getUserId()];

        System.runAs ( new User(Id = UserInfo.getUserId()) )
        {
            Account acct = new Account(Name = 'Uncategorized Vendor');
            insert acct;

            Account acct2 = new Account(Name = 'AECOM Internal Account');
            insert acct2;

            //--Insert custom settings cs that the other triggers don't freak out
            ssh_User_Contact_Settings__c custSetting = new ssh_User_Contact_Settings__c();
            custSetting.Name = 'Default';
            custSetting.External_Vendor_Uncategorized_Account__c = acct.Id;
            custSetting.External_Vendor_Record_Type__c = 'Vendor';
            custSetting.Employee_Record_Type__c = 'AECOM_Employee';
            custSetting.Internal_User_Account__c = acct2.Id;
            insert custSetting;

            List<Case> cases = new List<Case>();
            Case cs = new Case(RecordTypeId = sshUserContactUtils.getRecordTypeIdByName('Shared_Services'), SS_Is_Backup_Request__c = true);
            cases.add(cs);

            insert cases;

            cases.clear();
            cases = [select CreatedDate, SS_SLA_Target__c, SS_Resolve_By__c, RecordTypeId, GBS_SLA_Target_Hours__c from Case where Id = :cs.Id];
            for (Case c : cases) {
                if (c.Id == cs.Id) {
                    cs = c;
                }
            }
            //System.assertEquals(bhs.size(), 5);

            //System.assertEquals(cs.SS_SLA_Target__c, 24);
            //System.assertEquals(cs.SS_Resolve_By__c, setupResolveBy(cs));
        }

    }

    @isTest static void testCalculateResolveByAfterInsertANZ() {

        testSetupData();

        System.runAs ( new User(Id = UserInfo.getUserId()) )
        {
            Account acct = new Account(Name = 'Uncategorized Vendor');
            insert acct;

            Account acct2 = new Account(Name = 'AECOM Internal Account');
            insert acct2;

            List<Case> cases = new List<Case>();
            Case cs = new Case(RecordTypeId = sshUserContactUtils.getRecordTypeIdByName('Global_Business_Services_AP_ANZ'), SS_Is_Backup_Request__c = true);
            cases.add(cs);

            insert cases;

            cases.clear();
            cases = [select CreatedDate, SS_SLA_Target__c, SS_Resolve_By__c, RecordTypeId, GBS_SLA_Target_Hours__c from Case where Id = :cs.Id];
            for (Case c : cases) {
                if (c.Id == cs.Id) {
                    cs = c;
                }
                //System.assertEquals(bhs.size(), 5);

                //System.assertEquals(cs.GBS_SLA_Target_Hours__c, 72);
                //System.assertEquals(cs.SS_Resolve_By__c, setupResolveBy(cs));

            }
        }
    }

    @isTest static void testCalculateResolveByAfterInsertCH() {

        testSetupData();

        System.runAs ( new User(Id = UserInfo.getUserId()) )
        {
            Account acct = new Account(Name = 'Uncategorized Vendor');
            insert acct;

            Account acct2 = new Account(Name = 'AECOM Internal Account');
            insert acct2;
            List<Case> cases = new List<Case>();
            Case cs = new Case(RecordTypeId = sshUserContactUtils.getRecordTypeIdByName('Global_Business_Services_AP_CH'), SS_Is_Backup_Request__c = true);
            cases.add(cs);

            insert cases;

            cases.clear();
            cases = [select CreatedDate, SS_SLA_Target__c, SS_Resolve_By__c, RecordTypeId, GBS_SLA_Target_Hours__c from Case where Id = :cs.Id];
            for (Case c : cases) {
                if (c.Id == cs.Id) {
                    cs = c;
                }
                //System.assertEquals(bhs.size(), 5);

                //System.assertEquals(cs.GBS_SLA_Target_Hours__c, 72);
                //System.assertEquals(cs.SS_Resolve_By__c, setupResolveBy(cs));
            }
        }
    }

    @isTest static void testCalculateResolveByAfterInsertHK() {
        testSetupData();
        System.runAs ( new User(Id = UserInfo.getUserId()) )
        {
            Account acct = new Account(Name = 'Uncategorized Vendor');
            insert acct;

            Account acct2 = new Account(Name = 'AECOM Internal Account');
            insert acct2;

            List<Case> cases = new List<Case>();
            Case cs = new Case(RecordTypeId = sshUserContactUtils.getRecordTypeIdByName('Global_Business_Services_AP_HK'), SS_Is_Backup_Request__c = true);
            cases.add(cs);

            insert cases;

            cases.clear();
            cases = [select CreatedDate, SS_SLA_Target__c, SS_Resolve_By__c, RecordTypeId, GBS_SLA_Target_Hours__c from Case where Id = :cs.Id];
            for (Case c : cases) {
                if (c.Id == cs.Id) {
                    cs = c;
                }
                //System.assertEquals(bhs.size(), 5);

                //System.assertEquals(cs.GBS_SLA_Target_Hours__c, 72);
                //System.assertEquals(cs.SS_Resolve_By__c, setupResolveBy(cs));
            }
        }
    }

    @isTest static void testCalculateResolveByAfterInsertSEA() {
        testSetupData();

        System.runAs ( new User(Id = UserInfo.getUserId()) )
        {
            Account acct = new Account(Name = 'Uncategorized Vendor');
            insert acct;

            Account acct2 = new Account(Name = 'AECOM Internal Account');
            insert acct2;
            List<Case> cases = new List<Case>();
            Case cs = new Case(RecordTypeId = sshUserContactUtils.getRecordTypeIdByName('Global_Business_Services_AP_SEA'), SS_Is_Backup_Request__c = true);
            cases.add(cs);

            insert cases;

            cases.clear();
            cases = [select CreatedDate, SS_SLA_Target__c, SS_Resolve_By__c, RecordTypeId, GBS_SLA_Target_Hours__c from Case where Id = :cs.Id];
            for (Case c : cases) {
                if (c.Id == cs.Id) {
                    cs = c;
                }
                //System.assertEquals(bhs.size(), 5);

            }
        }
    }

    //--Test the "before update" functionality
    @isTest static void testCalculateResolveByBeforeUpdate() {
        testSetupData();
        System.runAs ( new User(Id = UserInfo.getUserId()) )
        {
            Account acct = new Account(Name = 'Uncategorized Vendor');
            insert acct;

            Account acct2 = new Account(Name = 'AECOM Internal Account');
            insert acct2;
            List<Case> cases = new List<Case>();
            Case cs = new Case(RecordTypeId = sshUserContactUtils.getRecordTypeIdByName('Shared_Services'), SS_Is_Backup_Request__c = true);
            cases.add(cs);

            insert cases;

            for (Case c : Cases) {
                c.SS_Is_Backup_Request__c = false;
                c.SS_Is_Invoice_Request__c = true;
            }
            update cases;

            cases.clear();
            cases = [select CreatedDate, SS_SLA_Target__c, SS_Resolve_By__c, RecordTypeId, GBS_SLA_Target_Hours__c from Case where Id = :cs.Id];
            for (Case c : cases) {
                if (c.Id == cs.Id) {
                    cs = c;
                }
            }
            //System.assertEquals(bhs.size(), 5);

            //System.assertEquals(cs.SS_SLA_Target__c, 48);
            //System.assertEquals(cs.SS_Resolve_By__c, setupResolveBy(cs));
        }
    }

    @isTest static void testCalculateResolveByBeforeUpdateCH() {
        testSetupData();

        System.runAs ( new User(Id = UserInfo.getUserId()) )
        {
            Account acct = new Account(Name = 'Uncategorized Vendor');
            insert acct;

            Account acct2 = new Account(Name = 'AECOM Internal Account');
            insert acct2;
            List<Case> cases = new List<Case>();
            Case cs = new Case(RecordTypeId = sshUserContactUtils.getRecordTypeIdByName('Global_Business_Services_AP_CH'), SS_Is_Backup_Request__c = true);
            cases.add(cs);

            insert cases;

            for (Case c : Cases) {
                c.SS_Is_Backup_Request__c = false;
                c.SS_Is_Invoice_Request__c = true;
            }
            update cases;

            cases.clear();
            cases = [select CreatedDate, SS_SLA_Target__c, SS_Resolve_By__c, RecordTypeId, GBS_SLA_Target_Hours__c from Case where Id = :cs.Id];
            for (Case c : cases) {
                if (c.Id == cs.Id) {
                    cs = c;
                }
            }
            //System.assertEquals(bhs.size(), 5);

            //System.assertEquals(cs.GBS_SLA_Target_Hours__c, 72);
            //System.assertEquals(cs.SS_Resolve_By__c, setupResolveBy(cs));
        }
    }

    @isTest static void testCalculateResolveByBeforeUpdateHK() {
        testSetupData();
        System.runAs ( new User(Id = UserInfo.getUserId()) )
        {
            Account acct = new Account(Name = 'Uncategorized Vendor');
            insert acct;

            Account acct2 = new Account(Name = 'AECOM Internal Account');
            insert acct2;
        
            List<Case> cases = new List<Case>();
            Case cs = new Case(RecordTypeId = sshUserContactUtils.getRecordTypeIdByName('Global_Business_Services_AP_HK'), SS_Is_Backup_Request__c = true);
            cases.add(cs);

            insert cases;

            for (Case c : Cases) {
                c.SS_Is_Backup_Request__c = false;
                c.SS_Is_Invoice_Request__c = true;
            }
            update cases;

            cases.clear();
            cases = [select CreatedDate, SS_SLA_Target__c, SS_Resolve_By__c, RecordTypeId, GBS_SLA_Target_Hours__c from Case where Id = :cs.Id];
            for (Case c : cases) {
                if (c.Id == cs.Id) {
                    cs = c;
                }
            }
            //System.assertEquals(bhs.size(), 5);

            //System.assertEquals(cs.GBS_SLA_Target_Hours__c, 72);
            //System.assertEquals(cs.SS_Resolve_By__c, setupResolveBy(cs));
        }
    }

    @isTest static void testCalculateResolveByBeforeUpdateANZ() {
        testSetupData();
        System.runAs ( new User(Id = UserInfo.getUserId()) )
        {
            Account acct = new Account(Name = 'Uncategorized Vendor');
            insert acct;

            Account acct2 = new Account(Name = 'AECOM Internal Account');
            insert acct2;
        
            List<Case> cases = new List<Case>();
            Case cs = new Case(RecordTypeId = sshUserContactUtils.getRecordTypeIdByName('Global_Business_Services_AP_ANZ'), SS_Is_Backup_Request__c = true);
            cases.add(cs);

            insert cases;

            for (Case c : Cases) {
                c.SS_Is_Backup_Request__c = false;
                c.SS_Is_Invoice_Request__c = true;
            }
            update cases;

            cases.clear();
            cases = [select CreatedDate, SS_SLA_Target__c, SS_Resolve_By__c, RecordTypeId, GBS_SLA_Target_Hours__c from Case where Id = :cs.Id];
            for (Case c : cases) {
                if (c.Id == cs.Id) {
                    cs = c;
                }
            }
            //System.assertEquals(bhs.size(), 5);

            //System.assertEquals(cs.GBS_SLA_Target_Hours__c, 72);
            //System.assertEquals(cs.SS_Resolve_By__c, setupResolveBy(cs));
        }
    }

    @isTest static void testCalculateResolveByBeforeUpdateSEA() {
        testSetupData();
        System.runAs ( new User(Id = UserInfo.getUserId()) )
        {
            Account acct = new Account(Name = 'Uncategorized Vendor');
            insert acct;

            Account acct2 = new Account(Name = 'AECOM Internal Account');
            insert acct2;
        
            List<Case> cases = new List<Case>();
            Case cs = new Case(RecordTypeId = sshUserContactUtils.getRecordTypeIdByName('Global Business Services AP - SEA'), SS_Is_Backup_Request__c = true);
            cases.add(cs);

            insert cases;

            for (Case c : Cases) {
                c.SS_Is_Backup_Request__c = false;
                c.SS_Is_Invoice_Request__c = true;
            }
            update cases;

            cases.clear();
            cases = [select CreatedDate, SS_SLA_Target__c, SS_Resolve_By__c, RecordTypeId, GBS_SLA_Target_Hours__c from Case where Id = :cs.Id];
            for (Case c : cases) {
                if (c.Id == cs.Id) {
                    cs = c;
                }
            }
            //System.assertEquals(bhs.size(), 5);

            //System.assertEquals(cs.GBS_SLA_Target_Hours__c, 72);
            //System.assertEquals(cs.SS_Resolve_By__c, setupResolveBy(cs));
        }
    }

    private static Datetime setupResolveBy(Case so) {
        for (BusinessHours busHour : bhs) {
            if (busHour.Name == 'Shared Services North America') {
                busMap.put(mRtInfo.get('Shared Services AP').getRecordTypeId(), busHour);
            } else if (busHour.Name == 'GBS ANZ Brisbane Office') {
                busMap.put(mRtInfo.get('Global Business Services AP - ANZ').getRecordTypeId(), busHour);
                bHIdToHolidays.put(ANZ_REGION, new List<Holiday>());
            } else if (busHour.Name == 'GBS CH Shanghai Office') {
                busMap.put(mRtInfo.get('Global Business Services AP - CH').getRecordTypeId(), busHour);
                bHIdToHolidays.put(CH_REGION, new List<Holiday>());
            } else if (busHour.Name == 'GBS HK Hong Kong Office') {
                busMap.put(mRtInfo.get('Global Business Services AP - HK').getRecordTypeId(), busHour);
                bHIdToHolidays.put(HK_REGION, new List<Holiday>());
            } else if (busHour.Name == 'GBS SEA Kuala Lumpur Office') {
                busMap.put(mRtInfo.get('Global Business Services AP - SEA').getRecordTypeId(), busHour);
                bHIdToHolidays.put(SEA_REGION, new List<Holiday>());
            }
        }

        for (Holiday day : holidays) {
            if (day.Name.containsIgnoreCase('GBS ANZ')) {
                bHIdToHolidays.get(ANZ_REGION).add(day);
            } else if (day.Name.containsIgnoreCase('GBS CH')) {
                bHIdToHolidays.get(CH_REGION).add(day);
            } else if (day.Name.containsIgnoreCase('GBS HK')) {
                bHIdToHolidays.get(HK_REGION).add(day);
            } else if (day.Name.containsIgnoreCase('GBS SEA')) {
                bHIdToHolidays.get(SEA_REGION).add(day);
            }
        }

        Id busId = busMap.get(so.RecordTypeId).Id;
        String region = '';
        Integer daysToAdd = -1;
        if (so.RecordTypeId == mRtInfo.get('Shared Services AP').getRecordTypeId()) {
            daysToAdd = Integer.valueOf(so.SS_SLA_Target__c) / 24;
        } else {
            daysToAdd = Integer.valueOf(so.GBS_SLA_Target_Hours__c) / 24;
        }
        so.SS_Resolve_By__c = so.CreatedDate;
        if (so.RecordTypeId == mRtInfo.get('Global Business Services AP - ANZ').getRecordTypeId()) {
            region = ANZ_REGION;
        } else if (so.RecordTypeId == mRtInfo.get('Global Business Services AP - CH').getRecordTypeId()) {
            region = CH_REGION;
        } else if (so.RecordTypeId == mRtInfo.get('Global Business Services AP - HK').getRecordTypeId()) {
            region = HK_REGION;
        } else if (so.RecordTypeId == mRtInfo.get('Global Business Services AP - SEA').getRecordTypeId()) {
            region = SEA_REGION;
        }
        while (daysToAdd > 0) {
            if (String.isNotBlank(region)) {
                for (Holiday day : bHIdToHolidays.get(region)) {
                    while ( (day.RecurrenceEndDateOnly != null && so.SS_Resolve_By__c <= day.RecurrenceEndDateOnly && so.SS_Resolve_By__c >= day.ActivityDate)
                            || (so.SS_Resolve_By__c.isSameDay(day.ActivityDate))) {
                        so.SS_Resolve_By__c = so.SS_Resolve_By__c.addDays(1);
                    }
                }
                while (!BusinessHours.isWithin(busId, so.SS_Resolve_By__c)) {
                    so.SS_Resolve_By__c = so.SS_Resolve_By__c.addDays(1);
                }
            }
            so.SS_Resolve_By__c = so.SS_Resolve_By__c.addDays(1);
            if (String.isNotBlank(region)) {
                for (Holiday day : bHIdToHolidays.get(region)) {
                    while ( (day.RecurrenceEndDateOnly != null && so.SS_Resolve_By__c <= day.RecurrenceEndDateOnly && so.SS_Resolve_By__c >= day.ActivityDate)
                            || (so.SS_Resolve_By__c.isSameDay(day.ActivityDate))) {
                        so.SS_Resolve_By__c = so.SS_Resolve_By__c.addDays(1);
                    }
                }
                while (!BusinessHours.isWithin(busId, so.SS_Resolve_By__c)) {
                    so.SS_Resolve_By__c = so.SS_Resolve_By__c.addDays(1);
                }
            }
            daysToAdd--;
        }
        return so.SS_Resolve_By__c;
    }
}