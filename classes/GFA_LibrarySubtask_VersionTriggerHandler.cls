public with sharing class GFA_LibrarySubtask_VersionTriggerHandler extends GFA_BaseController {

    public static Set<Id> subtaskVersionIds = new Set<Id>();

    public static void HandleBeforeUpdate(List<GFA_Library_Subtask_Version__c> lsvNewList, List<GFA_Library_Subtask_Version__c> lsvOldList) {
        Map<Id, GFA_LibrarySubtask> subtaskMap = new Map<Id, GFA_LibrarySubtask>();
        Map<Id, List<GFA_LibrarySubtaskVersion>> versionMap = new Map<Id, List<GFA_LibrarySubtaskVersion>>();

        Set<Id> subtaskIds = new Set<Id>();

        for (GFA_Library_Subtask_Version__c lsvNewItem : lsvNewList) {
            for (GFA_Library_Subtask_Version__c lsvOldItem : lsvOldList) {
                if (lsvOldItem.Version_Status__c == GFA_LibrarySubtaskVersion.STATUS_ARCHIVED ||
                        (lsvOldItem.Version_Status__c == GFA_LibrarySubtaskVersion.STATUS_ACTIVE  &&
                         lsvNewItem.Version_Status__c == GFA_LibrarySubtaskVersion.STATUS_ACTIVE)) {
                    lsvNewItem.addError('Active or Archived record cannot be edited');
                } else if (lsvNewItem.Version_Status__c == GFA_LibrarySubtaskVersion.STATUS_ACTIVE &&
                           lsvOldItem.Version_Status__c == GFA_LibrarySubtaskVersion.STATUS_PENDING &&
                           lsvOldItem.Id == lsvNewItem.Id) {
                    subtaskIds.add(lsvNewItem.Library_Subtask__c);
                }
            }
            subtaskVersionIds.add(lsvNewItem.Id);
        }

        if (subtaskIds.size() > 0) {
            for (GFA_LibrarySubtask subtask : GFA_LibrarySubtask.find.findByIds(subtaskIds)) {
                subtaskMap.put(subtask.getId(), subtask);
            }
            versionMap = GFA_LibrarySubtaskVersion.find.findByLibrarySubtaskIds(subtaskMap.values());

            List<GFA_BaseModel> models = new List<GFA_BaseModel>();
            for (GFA_Library_Subtask_Version__c lsvItem : lsvNewList) {
                for (GFA_Library_Subtask_Version__c lsvOldItem : lsvOldList) {
                    if (lsvItem.Version_Status__c == GFA_LibrarySubtaskVersion.STATUS_ACTIVE
                            && lsvOldItem.Id == lsvItem.Id) {
                        for (GFA_LibrarySubtaskVersion version : versionMap.get(lsvItem.Library_Subtask__c)) {
                            //---Find Active Version and make sure it's not the one that's being updated
                            if (lsvItem.Id != version.getId() && version.getStatus() == GFA_LibrarySubtaskVersion.STATUS_ACTIVE) {
                                version.setStatus(GFA_LibrarySubtaskVersion.STATUS_ARCHIVED);
                                models.add((GFA_BaseModel)version);
                            }
                        }
                        GFA_LibrarySubtask subtask = subtaskMap.get(lsvItem.Library_Subtask__c);
                        subtask.setDescription(lsvItem.Description__c);
                        subtask.setScopeOfService(lsvItem.Scope_of_Service__c);
                        subtask.setImpactLevel(lsvItem.Impact_Level__c);
                        subtask.setGroup(lsvItem.Group__c);
                        subtask.setOperatingGroup(lsvItem.Operating_Group__c);
                        subtask.setBusinessLine(lsvItem.Business_Line__c);
                        subtask.setProjectSponsor(lsvItem.Project_Sponsor__c);
                        subtask.setDiscipline(lsvItem.Discipline__c);
                        subtask.setRiskLevel(lsvItem.Risk_Level__c);
                    }
                }
            }

            models.addAll((List<GFA_BaseModel>)subtaskMap.values());
            GFA_BaseModel.save(models);
        }
    }

    public static void HandleBeforeInsert(List<GFA_Library_Subtask_Version__c> lsvList) {
        Map<Id, List<GFA_Library_Subtask_Version__c>> versionMap = new Map<Id, List<GFA_Library_Subtask_Version__c>>();
        Set<Id> subtaskIds = new Set<Id>();
        for (GFA_Library_Subtask_Version__c lsvItem : lsvList) {
            subtaskIds.add(lsvItem.Library_Subtask__c);
        }

        for (GFA_Library_Subtask_Version__c item : [Select ID, Version_No__c, Library_Subtask__c
                From GFA_Library_Subtask_Version__c
                Where Library_Subtask__c IN: subtaskIds
                Order By Library_Subtask__c, Version_No__c Desc]) {
            Id key = item.Library_Subtask__c;
            if (versionMap.containsKey(key)) {
                versionMap.get(key).add(item);
            } else {
                versionMap.put(key, new List<GFA_Library_Subtask_Version__c> {item});
            }
        }

        for (GFA_Library_Subtask_Version__c lsvItem : lsvList) {
            if (versionMap.containsKey(lsvItem.Library_Subtask__c)) {
                lsvItem.Version_No__c = versionMap.get(lsvItem.Library_Subtask__c)[0].Version_No__c + 1;
                lsvItem.Version_Status__c = GFA_LibrarySubtaskVersion.STATUS_PENDING;
            }
        }
    }


    public static void HandleBeforeDelete(List<GFA_Library_Subtask_Version__c> lsvList) {
        for (GFA_Library_Subtask_Version__c lsvItem : lsvList) {
            if (lsvItem.Version_Status__c == GFA_LibrarySubtaskVersion.STATUS_ARCHIVED ||
                    lsvItem.Version_Status__c == GFA_LibrarySubtaskVersion.STATUS_ACTIVE) {
                lsvItem.addError('Active or Archived record cannot be deleted');
            }
        }
    }
}