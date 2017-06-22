public with sharing class GFA_ProjectSubtaskTriggerHandler {

    private final static String READY_FOR_REVIEW_TEMPLATE = 'Project_Subtask_Ready_for_Review';
    private final static String UNSATISFACTORY_TEMPLATE = 'Unsatisfactory_Subtask_Completion';
    private final static String COMPLETED_TASK_TEMPLATE = 'Task_Completed';
    private final static String COMPLETED_PHASE_TEMPLATE = 'Phase_Completed';

    public static void handleBeforeUpdate(Map<Id, GFA_Project_Subtask__c> newMap, Map<Id, GFA_Project_Subtask__c> oldMap) {
        for (Id key : newMap.keySet()) {
            if (newMap.get(key).Status__c != oldMap.get(key).Status__c) {
                newMap.get(key).Last_Status_Change__c = Datetime.now();
            }

            if (newMap.get(key).Status__c == GFA_ProjectSubtask.STATUS_COMPLETED) {
                newMap.get(key).Completion_Date__c = Date.today();
            } else if (oldMap.get(key).Status__c == GFA_ProjectSubtask.STATUS_COMPLETED && newMap.get(key).Status__c != GFA_ProjectSubtask.STATUS_COMPLETED) {
                newMap.get(key).Completion_Date__c = null;
            }
        }
    }

    public static void handleAfterUpdate(Map<Id, GFA_Project_Subtask__c> newMap, Map<Id, GFA_Project_Subtask__c> oldMap) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        createReadyForReviewEmails(newMap, oldMap, messages);
        createUnsatisfactoryEmails(newMap, oldMap, messages);
        createAllSubtasksCompletedEmail(newMap, oldMap, messages);
        createAllSubtasksCompletedInPhaseEmail(newMap, oldMap, messages);

        if (!messages.isEmpty()) {
            Messaging.sendEmail(messages);
        }
    }

    private static void createReadyForReviewEmails(Map<Id, GFA_Project_Subtask__c> newMap, Map<Id, GFA_Project_Subtask__c> oldMap, List<Messaging.SingleEmailMessage> messages) {
        Set<Id> readyForReviewProjectIds = new Set<Id>();

        for (GFA_Project_Subtask__c subtask : [Select Id, Status__c, Project_Task__r.Project_Phase__r.GFA_Project__c from GFA_Project_Subtask__c where Id IN: newMap.keySet()]) {
            if (subtask.Status__c == GFA_ProjectSubtask.STATUS_READY_FOR_REVIEW
                    && oldMap.get(subtask.Id).Status__c != GFA_ProjectSubtask.STATUS_READY_FOR_REVIEW) {
                readyForReviewProjectIds.add(subtask.Project_Task__r.Project_Phase__r.GFA_Project__c);
            }
        }
        if (!readyForReviewProjectIds.isEmpty()) {
            Map<Id, List<GFA_ProjectSubtask>> subtasks = GFA_ProjectSubtask.find.findByProjectIds(readyForReviewProjectIds);
            Map<Id, List<GFA_ProjectRoster>> projectRosters = GFA_ProjectRoster.find.findByProjectIds(readyForReviewProjectIds);

            EmailTemplate readyForReview = [Select Id from EmailTemplate where DeveloperName = : READY_FOR_REVIEW_TEMPLATE];

            for (Id key : readyForReviewProjectIds) {
                for (GFA_ProjectRoster roster : projectRosters.get(key)) {
                    if (roster.getIsActingPM() && roster.getTeamMemberEmail() != null) {
                        for (GFA_ProjectSubtask subtask : subtasks.get(key)) {
                            //---This checks that the subtask is ready for review,
                            //---And that the old value was not already ready for review
                            if (subtask.getStatus() == GFA_ProjectSubtask.STATUS_READY_FOR_REVIEW
                                    && oldMap.containsKey(subtask.getId())
                                    && oldMap.get(subtask.getId()).Status__c != GFA_ProjectSubtask.STATUS_READY_FOR_REVIEW ) {
                                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                message.setTemplateId(readyForReview.Id);
                                message.setSaveAsActivity(false);
                                message.setTargetObjectId(roster.getTeamMemberNameId());
                                message.setWhatId(subtask.getId());
                                messages.add(message);
                            }
                        }
                    }
                }
            }
        }
    }

    private static void createUnsatisfactoryEmails(Map<Id, GFA_Project_Subtask__c> newMap, Map<Id, GFA_Project_Subtask__c> oldMap, List<Messaging.SingleEmailMessage> messages) {
        Set<Id> projectIds = new Set<Id>();
        for (GFA_Project_Subtask__c subtask : [Select Id, Status__c, Project_Task__r.Project_Phase__r.GFA_Project__c from GFA_Project_Subtask__c where Id IN: newMap.keySet()]) {
            if (subtask.Status__c == GFA_ProjectSubtask.STATUS_IN_PROGRESS
                    && oldMap.get(subtask.Id).Status__c == GFA_ProjectSubtask.STATUS_COMPLETED) {
                projectIds.add(subtask.Project_Task__r.Project_Phase__r.GFA_Project__c);
            }
        }

        if (!projectIds.isEmpty()) {
            Map<String, Set<String>> disciplineToRoleMap = new Map<String, Set<String>>();

            //Add all custom metadata discipline and role to a map
            for (GFA_Role_Discipline_Mapping__mdt setting : [Select Role__c, Discipline__c
                    from GFA_Role_Discipline_Mapping__mdt]) {
                if (disciplineToRoleMap.containsKey(setting.Discipline__c)) {
                    disciplineToRoleMap.get(setting.Discipline__c).add(setting.Role__c);
                } else {
                    disciplineToRoleMap.put(setting.Discipline__c, new Set<String> {setting.Role__c});
                }
            }

            Map<Id, List<GFA_ProjectSubtask>> subtasks = GFA_ProjectSubtask.find.findByProjectIds(projectIds);
            Map<Id, List<GFA_ProjectRoster>> projectRosters = GFA_ProjectRoster.find.findByProjectIds(projectIds);
            Map<String, Set<Id>> roleToContactMap = new Map<String, Set<Id>>();

            EmailTemplate unsatisfactoryTemplate = [Select Id from EmailTemplate where DeveloperName = : UNSATISFACTORY_TEMPLATE];

            for (Id key : projectIds) {
                for (GFA_ProjectRoster roster : projectRosters.get(key)) {
                    if (!roster.getIsActingPM()) {
                        for (GFA_ProjectSubtask subtask : subtasks.get(key)) {
                            //---This checks that the subtask is In Progress,
                            //---And that the old value was Completed
                            //---And that the Roster's role is mapped to this discipline
                            Set<String> roleSet = disciplineToRoleMap.get(subtask.getDiscipline());
                            if (subtask.getStatus() == GFA_ProjectSubtask.STATUS_IN_PROGRESS
                                    && oldMap.containsKey(subtask.getId())
                                    && oldMap.get(subtask.getId()).Status__c == GFA_ProjectSubtask.STATUS_COMPLETED
                                    && roleSet != null
                                    && roleSet.contains(roster.getRole())) {
                                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                message.setTemplateId(unsatisfactoryTemplate.Id);
                                message.setSaveAsActivity(false);
                                message.setTargetObjectId(roster.getTeamMemberNameId());
                                message.setWhatId(subtask.getId());
                                messages.add(message);
                            }
                        }
                    }
                }
            }
        }
    }

    private static void createAllSubtasksCompletedEmail(Map<Id, GFA_Project_Subtask__c> newMap, Map<Id, GFA_Project_Subtask__c> oldMap, List<Messaging.SingleEmailMessage> messages) {
        Set<Id> taskIds = new Set<Id>();
        Map<Id, Set<Id>> projectToCompletedTasksMap = new Map<Id, Set<Id>>();
        for (GFA_Project_Subtask__c subtask : [Select Id, Status__c, Project_Task__c, Project_Task__r.Project_Phase__r.GFA_Project__c from GFA_Project_Subtask__c where Id IN: newMap.keySet()]) {
            if (subtask.Status__c == GFA_ProjectSubtask.STATUS_COMPLETED
                    && oldMap.get(subtask.Id).Status__c != GFA_ProjectSubtask.STATUS_COMPLETED) {
                taskIds.add(subtask.Project_Task__c);
                projectToCompletedTasksMap.put(subtask.Project_Task__r.Project_Phase__r.GFA_Project__c, new Set<Id>());
            }
        }

        if (!taskIds.isEmpty()) {
            Map<Id, List<GFA_ProjectSubtask>> subtaskMap = GFA_ProjectSubtask.find.findByProjectTaskIds(taskIds);
            Map<Id, List<GFA_ProjectRoster>> projectRosters = GFA_ProjectRoster.find.findByProjectIds(projectToCompletedTasksMap.keySet());
            EmailTemplate completedTemplate = [Select Id from EmailTemplate where DeveloperName = : COMPLETED_TASK_TEMPLATE];
            for (Id key : subtaskMap.keySet()) {
                Boolean isCompletedTask = true;
                Id projectId = null;
                for (GFA_ProjectSubtask subtask : subtaskMap.get(key)) {
                    projectId = subtask.getProjectId();
                    if (subtask.getStatus() != GFA_ProjectSubtask.STATUS_COMPLETED
                            && (subtask.getIsApplicable() || subtask.getIsPMVisible())) {
                        isCompletedTask = false;
                        break;
                    }
                }
                if (isCompletedTask) {
                    projectToCompletedTasksMap.get(projectId).add(key);
                }
            }

            for (Id key : projectToCompletedTasksMap.keySet()) {
                for (GFA_ProjectRoster roster : projectRosters.get(key)) {
                    if (roster.getIsActingPM()) {
                        for (Id completeTaskId : projectToCompletedTasksMap.get(key)) {
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            message.setTemplateId(completedTemplate.Id);
                            message.setSaveAsActivity(false);
                            message.setTargetObjectId(roster.getTeamMemberNameId());
                            message.setWhatId(completeTaskId);
                            messages.add(message);
                        }
                    }
                }
            }
        }
    }

    private static void createAllSubtasksCompletedInPhaseEmail(Map<Id, GFA_Project_Subtask__c> newMap, Map<Id, GFA_Project_Subtask__c> oldMap, List<Messaging.SingleEmailMessage> messages) {
        Set<Id> phaseIds = new Set<Id>();
        Map<Id, Set<Id>> projectToCompletedPhasesMap = new Map<Id, Set<Id>>();
        for (GFA_Project_Subtask__c subtask : [Select Id, Status__c, Project_Task__r.Project_Phase__c, Project_Task__r.Project_Phase__r.GFA_Project__c from GFA_Project_Subtask__c where Id IN: newMap.keySet()]) {
            if (subtask.Status__c == GFA_ProjectSubtask.STATUS_COMPLETED
                    && oldMap.get(subtask.Id).Status__c != GFA_ProjectSubtask.STATUS_COMPLETED) {
                phaseIds.add(subtask.Project_Task__r.Project_Phase__c);
                projectToCompletedPhasesMap.put(subtask.Project_Task__r.Project_Phase__r.GFA_Project__c, new Set<Id>());
            }
        }

        if (!phaseIds.isEmpty()) {
            Map<Id, List<GFA_ProjectSubtask>> subtaskMap = GFA_ProjectSubtask.find.findByProjectPhaseIds(phaseIds);
            Map<Id, List<GFA_ProjectRoster>> projectRosters = GFA_ProjectRoster.find.findByProjectIds(projectToCompletedPhasesMap.keySet());
            EmailTemplate completedTemplate = [Select Id from EmailTemplate where DeveloperName = : COMPLETED_PHASE_TEMPLATE];

            for (Id key : subtaskMap.keySet()) {
                Boolean isCompletedTask = true;
                Id projectId = null;
                for (GFA_ProjectSubtask subtask : subtaskMap.get(key)) {
                    projectId = subtask.getProjectId();
                    if (subtask.getStatus() != GFA_ProjectSubtask.STATUS_COMPLETED
                            && (subtask.getIsApplicable() || subtask.getIsPMVisible())) {
                        isCompletedTask = false;
                        break;
                    }
                }
                if (isCompletedTask) {
                    projectToCompletedPhasesMap.get(projectId).add(key);
                }
            }

            Set<Id> allCompletedPhaseIds = new Set<Id>();
            for (Id key : projectToCompletedPhasesMap.keySet()) {
                for (GFA_ProjectRoster roster : projectRosters.get(key)) {
                    for (Id completePhaseId : projectToCompletedPhasesMap.get(key)) {
                        if (roster.getIsActingPM()) {
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            message.setTemplateId(completedTemplate.Id);
                            message.setSaveAsActivity(false);
                            message.setTargetObjectId(roster.getTeamMemberNameId());
                            message.setWhatId(key);
                            messages.add(message);
                        }
                        allCompletedPhaseIds.add(completePhaseId);
                    }
                }
            }
            List<GFA_ProjectPhase> completedPhases = GFA_ProjectPhase.find.findByids(allCompletedPhaseIds);
            for (GFA_ProjectPhase phase : completedPhases) {
                phase.setPhaseStatus(GFA_ProjectPhase.PHASE_STATUS_COMPLETED);
                phase.setActualCompletionDate(Date.today());
            }
            GFA_BaseModel.save(completedPhases);

        }
    }
}