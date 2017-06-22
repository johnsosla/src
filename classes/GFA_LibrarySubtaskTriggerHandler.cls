public with sharing class GFA_LibrarySubtaskTriggerHandler {

    private static Map<String, Schema.RecordTypeInfo> mRtInfo = GFA_Library_Subtask_Version__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    private static Map<String, Schema.RecordTypeInfo> mParentRtInfo = GFA_Library_Subtask__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    public static void HandleAfterInsert(List<GFA_Library_Subtask__c> lsList) {
        List<GFA_Library_Subtask_Version__c> newLSVersions = new List<GFA_Library_Subtask_Version__c>();

        for (GFA_Library_Subtask__c libSubtask : lsList) {
            GFA_Library_Subtask_Version__c newLSV = new GFA_Library_Subtask_Version__c (
                Library_Subtask__c = libSubtask.ID,
                Version_Status__c = GFA_LibrarySubtask.RT_PENDING,
                Description__c = libSubtask.Description__c,
                Scope_of_Service__c = libSubtask.Scope_of_Service__c,
                Impact_Level__c = libSubtask.Impact_Level__c,
                Group__c = libSubtask.Group__c,
                Operating_Group__c = libSubtask.Operating_Group__c,
                Business_Line__c = libSubtask.Business_Line__c,
                Project_Sponsor__c = libSubtask.Project_Sponsor__c,
                Discipline__c = libSubtask.Discipline__c,
                Risk_Level__c = libSubtask.Risk_Level__c,
                Version_No__c = 1,
                RecordTypeId = mRtInfo.get(GFA_LibrarySubtask.RT_PENDING).getRecordTypeId()
            );
            newLSVersions.add(newLSV);
        }

        insert newLSVersions;
    }

    public static void HandleAfterUpdate(List<GFA_Library_Subtask__c> lsList) {
        List<GFA_Library_Subtask_Version__c> newLSVersions = new List<GFA_Library_Subtask_Version__c>();
        Map<Id, GFA_Library_Subtask_Version__c> libSubtaskActiveVersions = new Map<Id, GFA_Library_Subtask_Version__c>();
        Map<Id, GFA_Library_Subtask_Version__c> libSubtaskPendingVersions = new Map<Id, GFA_Library_Subtask_Version__c>();
        Map<Id, GFA_Library_Subtask__c> libSubtaskMap = new Map<Id, GFA_Library_Subtask__c>();

        for (GFA_Library_Subtask__c lsItem : lsList) {
            if (lsItem.RecordTypeId == mParentRtInfo.get(GFA_LibrarySubtask.RT_PENDING).getRecordTypeId()) {
                libSubtaskMap.put(lsItem.Id, lsItem);
            }
        }

        List<GFA_Library_Subtask_Version__c> lsvList = [Select Id, Library_Subtask__c, Version_Status__c, Version_No__c
                From GFA_Library_Subtask_Version__c
                Where Library_Subtask__c in :libSubtaskMap.keySet()
                and  Version_Status__c != : GFA_LibrarySubtaskVersion.STATUS_ARCHIVED
                and Id NOT IN: GFA_LibrarySubtask_VersionTriggerHandler.subtaskVersionIds
                Order By Version_No__c Desc];

        for (GFA_Library_Subtask_Version__c libSubtask : lsvList) {
            if (libSubtask.Version_Status__c == GFA_LibrarySubtaskVersion.STATUS_PENDING) {
                libSubtaskPendingVersions.put(libSubtask.Library_Subtask__c, libSubtask);
            }
        }


        for (GFA_Library_Subtask_Version__c lsv : lsvList) {
            if (lsv.Version_Status__c == 'Pending') {
                lsv.Version_Status__c = 'Pending';
                lsv.Description__c = libSubtaskMap.get(lsv.Library_Subtask__c).Description__c;
                lsv.Scope_of_Service__c = libSubtaskMap.get(lsv.Library_Subtask__c).Scope_of_Service__c;
                lsv.Impact_Level__c = libSubtaskMap.get(lsv.Library_Subtask__c).Impact_Level__c;
                lsv.Group__c = libSubtaskMap.get(lsv.Library_Subtask__c).Group__c;
                lsv.Operating_Group__c = libSubtaskMap.get(lsv.Library_Subtask__c).Operating_Group__c;
                lsv.Business_Line__c = libSubtaskMap.get(lsv.Library_Subtask__c).Business_Line__c;
                lsv.Project_Sponsor__c = libSubtaskMap.get(lsv.Library_Subtask__c).Project_Sponsor__c;
                lsv.Discipline__c = libSubtaskMap.get(lsv.Library_Subtask__c).Discipline__c;
                lsv.Risk_Level__c = libSubtaskMap.get(lsv.Library_Subtask__c).Risk_Level__c;
                newLSVersions.add(lsv);
            }
        }

        if (newLSVersions.size() > 0) {
            upsert newLSVersions;
        }
    }

    public static void HandleBeforeInsert(List<GFA_Library_Subtask__c> lsList) {
        for (GFA_Library_Subtask__c libSubtask : lsList) {
            if (!GFA_User.getCurrentUser().getIsAdminUser()) {
                libSubtask.addError('Only Admins can create Library Subtasks');
            }
        }
    }

    public static void HandleBeforeDelete(List<GFA_Library_Subtask__c> lsList) {
        for (GFA_Library_Subtask__c ls : lsList) {
            if (ls.RecordTypeId == mParentRtInfo.get(GFA_LibrarySubtask.RT_ACTIVE).getRecordTypeId()) {
                ls.addError('Active Subtask Cannot be deleted');
            }
        }
    }
}