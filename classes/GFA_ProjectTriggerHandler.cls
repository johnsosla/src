public with sharing class GFA_ProjectTriggerHandler {

    public static void handleAfterUpdate(Map<Id, GFA_Project__c> newMap, Map<Id, GFA_Project__c> oldMap) {
        Map<Id, GFA_Project__c> changedProjects = new Map<Id, GFA_Project__c>();
        Map<Id, GFA_Project__c> inProgressProjects = new Map<Id, GFA_Project__c>();

        //---Only work on the items whose Scope of Service or Risk Level change
        for (Id key : newMap.keySet()) {
            if (newMap.get(key).Scope_Of_Service__c != oldMap.get(key).Scope_Of_Service__c
                    || newMap.get(key).Risk_Level__c != oldMap.get(key).Risk_Level__c) {
                changedProjects.put(key, newMap.get(key));
            }
        }

        updateApplicability(changedProjects);

        //---get only projects when set from Not Started to In Progress
        for (Id key : newMap.keySet()) {
            if (newMap.get(key).Project_Status__c == GFA_Project.STATUS_IN_PROGRESS
                    && oldMap.get(key).Project_Status__c == GFA_Project.STATUS_NOT_STARTED) {
                inProgressProjects.put(key, newMap.get(key));
            }
        }

        projectSetupCompleteEmailNotification(inProgressProjects);
    }

    public static void updateApplicability(Map<Id, GFA_Project__c> newMap) {
        Map<Id, List<GFA_ProjectSubtask>> projectSubtasks = GFA_ProjectSubtask.find.findByProjectIds(newMap.keySet());
        List<GFA_ProjectSubtask> updateList = new List<GFA_ProjectSubtask>();
        for (Id key : newMap.keySet()) {
            GFA_Project__c project = newMap.get(key);
            if (projectSubtasks.get(key) != null) {
                for (GFA_ProjectSubtask subtask : projectSubtasks.get(key)) {
                    if(subtask.getAddedBy() == GFA_ProjectSubtask.ADDED_BY_TEMPLATE) {
                        Boolean hasScopeOfService = false;
                        if (String.isNotBlank(subtask.getScopeOfService())) {
                            Set<String> projectSoS = String.isNotBlank(project.Scope_of_Service__c)
                                                     ? new Set<String>(project.Scope_of_Service__c.split(';'))
                                                     : new Set<String>();
                            Set<String> subtaskSoS = new Set<String>(
                                subtask.getScopeOfService().split(';'));
                            for (String scope : subtaskSoS) {
                                if (projectSoS.contains(scope)) {
                                    hasScopeOfService = true;
                                    break;
                                }
                            }
                        } else {
                            //---AEGPDS-115
                            hasScopeOfService = true;
                        }
                        if (hasScopeOfService) {
                            if (project.Risk_Level__c == GFA_ProjectSubtask.RISK_LEVEL_LOW) {
                                if (subtask.getRiskLevel() == GFA_ProjectSubtask.RISK_LEVEL_LOW) {
                                    subtask.setIsApplicable(true);
                                } else {
                                    subtask.setIsApplicable(false);
                                }
                            } else if (project.Risk_Level__c == GFA_ProjectSubtask.RISK_LEVEL_MEDIUM) {
                                        if (subtask.getRiskLevel() == GFA_ProjectSubtask.RISK_LEVEL_LOW || subtask.getRiskLevel() == GFA_ProjectSubtask.RISK_LEVEL_MEDIUM) {
                                            subtask.setIsApplicable(true);
                                        } else {
                                            subtask.setIsApplicable(false);
                                        }
                            } else if (project.Risk_Level__c == GFA_ProjectSubtask.RISK_LEVEL_HIGH) {
                                subtask.setIsApplicable(true);
                            } else {
                                subtask.setIsApplicable(false);
                            }
                        } else {
                            subtask.setIsApplicable(false);
                        }
                        updateList.add(subtask);
                    }
                }
            }
        }

        if (!updateList.isEmpty()) {
            GFA_BaseModel.save(updateList);
        }
    }

    private static void projectSetupCompleteEmailNotification(Map<Id, GFA_Project__c> inProgressProjects) {
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

        Map<Id, List<GFA_ProjectRoster>> projectRosters = GFA_ProjectRoster.find.findByProjectIds(inProgressProjects.keySet());
        List<GFA_Project> projects = GFA_Project.find.findByIds(inProgressProjects.keySet());

        //---Project to contact email and the subject
        Map<Id, Map<String, String>> projectContactToSubjectMap = new Map<Id, Map<String, String>>();
        for (Id key : inProgressProjects.keySet()) {
            projectContactToSubjectMap.put(key, new Map<String, String>());
        }

        //---SETUP the PROJECTS
        setUpProject(projects);

        for (GFA_Project project : projects) {
            for (Integer i = project.getProjectPhases().size() - 1; i > -1; i--) {
                GFA_ProjectPhase phase = project.getProjectPhases()[i];
                for (Integer j = phase.getProjectTasks().size() - 1; j > -1; j--) {
                    GFA_ProjectTask projectTask = phase.getProjectTasks()[j];
                    for (Integer k = projectTask.getProjectSubtasks().size() - 1; k > -1; k--) {
                        GFA_ProjectSubtask subtask = projectTask.getProjectSubtasks()[k];
                        Set<String> rolesForSubtask = disciplineToRoleMap.get(subtask.getDiscipline());
                        List<GFA_ProjectRoster> rosters = new List<GFA_ProjectRoster>();
                        for (GFA_ProjectRoster roster : projectRosters.get(project.getId())) {
                            if (!roster.getIsActingPM() && rolesForSubtask != null && rolesForSubtask.contains(roster.getRole())) {
                                rosters.add(roster);
                            }
                        }
                        //set up email notification
                        setUpEmailTemplate(rosters, projectTask.getLibraryTaskName(), subtask.getLibrarySubtaskName(), projectContactToSubjectMap);
                    }
                }
            }
        }

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for (GFA_Project project : projects) {
            Map<String, String> contactToSubjectMap = projectContactToSubjectMap.get(project.getId());
            for (String email : contactToSubjectMap.keySet()) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {email};
                mail.setToAddresses(toAddresses);    // Set the TO addresses
                mail.setSubject('You have been assigned one or more Subtasks for the following project: ' + project.getProjectName() + ', ' + project.getName() + '.');
                mail.setPlainTextBody(contactToSubjectMap.get(email));
                messages.add(mail);
            }
        }
        if (!messages.isEmpty()) {
            Messaging.SendEmail(messages);
        }
    }

    private static void setUpEmailTemplate(List<GFA_ProjectRoster> projectRosters, String taskName, String subtaskName, Map<Id, Map<String, String>> projectContactToSubjectMap) {
        Set<Id> teamMemberIds = new Set<Id>();

        //get Team member Ids
        for (GFA_ProjectRoster projectRoster : projectRosters) {
            teamMemberIds.add(projectRoster.getTeamMemberNameId());
        }

        // Build a map of all users who are assigned the tasks.
        Map<Id, Contact> contactMap = new Map<Id, Contact>([select Name, Email from Contact where Id in :teamMemberIds]);

        for (GFA_ProjectRoster projectRoster : projectRosters) {
            Contact theContact = contactMap.get(projectRoster.getTeamMemberNameId());
            String template = 'Task: [{0}]\n';
            template += 'Subtask: [{1}]\n\n\n';

            List<String> args = new List<String>();
            args.add(taskName);
            args.add(subtaskName);

            // Here's the String.format() call.
            String formattedHtml = String.format(template, args);

            if (projectContactToSubjectMap.get(projectRoster.getProjectId()).containsKey(theContact.Email)) {
                String newSubject = projectContactToSubjectMap.get(projectRoster.getProjectId()).get(theContact.Email) + formattedHtml;
                projectContactToSubjectMap.get(projectRoster.getProjectId()).put(theContact.Email, newSubject);
            } else {
                projectContactToSubjectMap.get(projectRoster.getProjectId()).put(theContact.Email, formattedHtml);
            }

        }
    }

    private static void setUpProject(List<GFA_Project> projects) {
        Map<Id, List<GFA_ProjectPhase>> projectToPhaseMap = GFA_ProjectPhase.find.findByProjectIds(projects);
        List<GFA_ProjectPhase> allPhases = new List<GFA_ProjectPhase>();
        for (Id key : projectToPhaseMap.keySet()) {
            allPhases.addAll(projectToPhaseMap.get(key));
        }

        Map<Id, List<GFA_ProjectTask>> phasesToTaskMap = GFA_ProjectTask.find.findByProjectPhaseIds(
                    allPhases);

        List<GFA_ProjectTask> allTasks = new List<GFA_ProjectTask>();
        for (Id key : phasesToTaskMap.keySet()) {
            allTasks.addAll(phasesToTaskMap.get(key));
        }

        Map<Id, List<GFA_ProjectSubtask>> taskSubMap = GFA_ProjectSubtask.find.findByProjectTaskIds(
                    allTasks);

        //Start adding subtasks to task, task to phases, and phases to template
        for (GFA_ProjectTask task : allTasks) {
            if (taskSubMap.containsKey(task.getId())) {
                task.setProjectSubtasks(taskSubMap.get(task.getId()));
            }
        }

        for (GFA_ProjectPhase phase : allPhases) {
            if (phasesToTaskMap.containsKey(phase.getId())) {
                phase.setProjectTasks(phasesToTaskMap.get(phase.getId()));
            }
        }

        for (GFA_Project project : projects) {
            if (projectToPhaseMap.containsKey(project.getId())) {
                project.setProjectPhases(projectToPhaseMap.get(project.getId()));
            }
        }
    }

    public static void handleBeforeInsert(List<GFA_Project__c> projectList) {
        Set<Id> oppIds = new Set<Id>();
         for (GFA_Project__c project : projectList) {
                oppIds.add(project.Opportunity__c);
        }

        List<Opportunity> opportunityList = [Select Id, AccountId
                From Opportunity
                Where Id in :oppIds];

        for (GFA_Project__c proj : projectList) {
            for (Opportunity opp : opportunityList) {
                 if (proj.Opportunity__c == opp.Id && opp.AccountId != null) {
                    proj.Client__c = opp.AccountId;
                 }
            }
        }
    }

}