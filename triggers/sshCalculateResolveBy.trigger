/*************************************************************************
*
* PURPOSE: Trigger to calculate the date by which a case must be resolved
* based on the Business Hours that are defined
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
* MODIFIED BY: BRIAN LAU
***************************************************************************/
trigger sshCalculateResolveBy on Case (after insert, before update) {

    private static final String ANZ_REGION = 'ANZ';
    private static final String CH_REGION = 'CH';
    private static final String HK_REGION = 'HK';
    private static final String SEA_REGION = 'SEA';

    Map<Integer, String> slaTargetToPriority = new Map<Integer, String> {
        1 => 'High',
        2 => 'Medium',
        3 => 'Low'
    };

    List<BusinessHours> busHours = [select Id, Name from BusinessHours where Name = 'Shared Services North America' or Name = 'GBS ANZ Brisbane Office' or Name = 'GBS CH Shanghai Office' or Name = 'GBS HK Hong Kong Office' or Name = 'GBS SEA Kuala Lumpur Office'];
    List<Holiday> holidays = [Select Id, ActivityDate, Name, IsRecurrence, RecurrenceEndDateOnly from Holiday];

    Map<String, BusinessHours> busMap = new Map<String, BusinessHours>();
    Map<String, Schema.RecordTypeInfo> mRtInfo = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
    Map<String, List<Holiday>> bHIdToHolidays = new Map<String, List<Holiday>>();
    Set<Id> caseIds = new Set<Id>();

    if (!busHours.isEmpty()) {
        for (BusinessHours busHour : busHours) {
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
            // Setup BH Id to Holidays list
        }
        // Currently holidays have been set up with APAC regions (ANZ, HK, CH, SEA)
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
        for (Case so : Trigger.new) {
            if ( (so.RecordTypeId == mRtInfo.get('Shared Services AP').getRecordTypeId()
                    || so.RecordTypeId == mRtInfo.get('Global Business Services AP - ANZ').getRecordTypeId()
                    || so.RecordTypeId == mRtInfo.get('Global Business Services AP - CH').getRecordTypeId()
                    || so.RecordTypeId == mRtInfo.get('Global Business Services AP - HK').getRecordTypeId()
                    || so.RecordTypeId == mRtInfo.get('Global Business Services AP - SEA').getRecordTypeId())
                    && (so.SS_SLA_Target__c != null || so.GBS_SLA_Target_Hours__c != null)) {

                caseIds.add(so.Id);

                if (Trigger.isBefore) {
                    setupResolveBy(so);
                }
            }
        }
    }
    if (Trigger.isAfter && !caseIds.isEmpty()) {
        List<Case> cases = [select CreatedDate, SS_SLA_Target__c, GBS_SLA_Target_Hours__c, RecordTypeId from Case where Id in :caseIds];

        for (Case so : cases) {
            setupResolveBy(so);
        }

        update cases;
    } 

    if ( Trigger.isAfter && Trigger.isInsert ){
        HRS_CaseHandler.autoPopulateFromAPIData( Trigger.New );
    }

    if ( Trigger.isBefore && Trigger.isUpdate ){
        //To auto populate the four select picklist value if an Org is definded
        HRS_CaseHandler.autoPopulateSelectionValueOnCase( Trigger.New, Trigger.oldMap );     
        //To auto populate the four select picklist value if an Org is definded
        HRS_CaseHandler.autoPopulateHRSysCodeOnCase( Trigger.New, Trigger.oldMap );     
        //HRS_CaseHandler.autoEbandCaseSubmit( Trigger.New, Trigger.oldMap );     

    }


    private void setupResolveBy(Case so) {
        Id busId = busMap.get(so.RecordTypeId).Id;
        String region = '';
        Integer daysToAdd = -1;
        if (so.RecordTypeId == mRtInfo.get('Shared Services AP').getRecordTypeId()) {
            daysToAdd = Integer.valueOf(so.SS_SLA_Target__c) / 24;
        } else {
            daysToAdd = Integer.valueOf(so.GBS_SLA_Target_Hours__c) / 24;
        }
        so.Priority = slaTargetToPriority.get(daysToAdd);
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
    }

}