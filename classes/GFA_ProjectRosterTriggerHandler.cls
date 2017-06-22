public with sharing class GFA_ProjectRosterTriggerHandler {

    public static void handleAfterInsert(Map<Id, GFA_Project_Roster__c> newMap) {
        Set<Id> projectIds = new Set<Id>();
        for (GFA_Project_Roster__c roster : newMap.values()) {
            projectIds.add(roster.GFA_Project__c);
        }
        Map<Id, List<GFA_ProjectRoster>> memberMap = GFA_ProjectRoster.find.findByProjectIds(projectIds);
        updateProjectMemberField(memberMap);
    }

    public static void handleAfterUpdate(Map<Id, GFA_Project_Roster__c> newMap, Map<Id, GFA_Project_Roster__c> oldMap) {
        Set<Id> projectIds = new Set<Id>();
        for (GFA_Project_Roster__c roster : newMap.values()) {
            projectIds.add(roster.GFA_Project__c);
        }
        Map<Id, List<GFA_ProjectRoster>> memberMap = GFA_ProjectRoster.find.findByProjectIds(projectIds);
        updateProjectMemberField(memberMap);
    }

    private static void updateProjectMemberField(Map<Id, List<GFA_ProjectRoster>> memberMap) {
        List<GFA_Project> projects = GFA_Project.find.findByIds(memberMap.keySet());

        for (GFA_Project project : projects) {
            Set<Id> userIds = new Set<Id>();
            for (GFA_ProjectRoster roster : memberMap.get(project.getId())) {
                userIds.add(roster.getTeamMemberUserId());
            }
            project.setRosterUserList(String.join(new List<Id>(userIds), ','));
            GFA_DebugUtils.log('project.getRosterUserList()', project.getRosterUserList());
        }
        GFA_DMLUtils.save(projects);
    }
}