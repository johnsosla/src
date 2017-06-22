public with sharing class GFA_ProjectFrameworkController extends GFA_ProjectTreeBaseController {

    public GFA_FilterManager Filter {get; set;}
    public Boolean MyTaskView {get; set;}

    public GFA_ProjectFrameworkController(ApexPages.StandardController sc) {
        super(sc);
        setupFilter();
        MyTaskView = Filter.ShowMyTasks != null ? Filter.ShowMyTasks : false;
    }

    private void setupFilter() {
        Filter = new GFA_FilterManager();
        if (String.isNotBlank(CurrentUser.getParameters())) {
            GFA_FilterManager userFilter = CurrentUser.getParametersAsFilterManager();
            Filter.ImpactLevel = userFilter.ImpactLevel;
            Filter.ShowMyTasks = userFilter.ShowMyTasks;
        }
        Filter.ProjectId = project.getId();
        Filter.setupLibrarySubtaskFilters();
    }

    public PageReference refreshProjectSubtasks() {
        setupProject();
        if (!Filter.IsFilterBlank()) {
            Set<Id> libSubtaskIds = new Set<Id>();
            for (GFA_ProjectSubtask subtask : Filter.getProjectSubtasksByCriteria()) {
                libSubtaskIds.add(subtask.getId());
            }

            for (Integer i = project.getProjectPhases().size() - 1; i > -1; i--) {
                GFA_ProjectPhase phase = project.getProjectPhases()[i];
                for (Integer j = phase.getProjectTasks().size() - 1; j > -1; j--) {
                    GFA_ProjectTask task = phase.getProjectTasks()[j];
                    for (Integer k = task.getProjectSubtasks().size() - 1; k > -1; k--) {
                        GFA_ProjectSubtask subtask = task.getProjectSubtasks()[k];
                        if (!libSubtaskIds.contains(subtask.getId())
                                || (!subtask.getIsApplicable() && !subtask.getIsPMVisible())) {
                            task.getProjectSubtasks().remove(k);
                        }
                    }
                    if (task.getProjectSubtasks().isEmpty()) {
                        phase.getProjectTasks().remove(j);
                    }
                }
                if (phase.getProjectTasks().isEmpty()) {
                    project.getProjectPhases().remove(i);
                }
            }
        }
        if (MyTaskView) {
            myTasks(false);
        }
        saveSearchCriteria();
        return null;
    }

    private void saveSearchCriteria() {
        GFA_FilterManager userFilter = Filter;
        if (String.isNotBlank(CurrentUser.getParameters())) {
            userFilter = CurrentUser.getParametersAsFilterManager();
            userFilter.ImpactLevel = Filter.ImpactLevel;
            userFilter.ShowMyTasks = Filter.ShowMyTasks;
        }
        CurrentUser.setParameters(userFilter);
        CurrentUser.save();
    }

    public PageReference myTasks() {
        return myTasks(true);
    }

    public PageReference myTasks(Boolean shouldSave) {
        MyTaskView = true;
        Filter.ShowMyTasks = true;
        if (shouldSave) {
            saveSearchCriteria();
        }
        Set<String> userRoles = new Set<String>();
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

        // Add the User's Roles to a set
        for (GFA_ProjectRoster roster : GFA_ProjectRoster.find.findByProjectId(project.getId())) {
            if (roster.getTeamMemberUserId() == UserInfo.getUserId()) {
                userRoles.add(roster.getRole());
            }
        }

        for (Integer i = project.getProjectPhases().size() - 1; i > -1; i--) {
            GFA_ProjectPhase phase = project.getProjectPhases()[i];
            for (Integer j = phase.getProjectTasks().size() - 1; j > -1; j--) {
                GFA_ProjectTask projectTask = phase.getProjectTasks()[j];
                for (Integer k = projectTask.getProjectSubtasks().size() - 1; k > -1; k--) {
                    GFA_ProjectSubtask subtask = projectTask.getProjectSubtasks()[k];
                    Set<String> rolesForSubtask = disciplineToRoleMap.get(subtask.getDiscipline());
                    // See if any of the user's project roles is in this subtask's discipline
                    Boolean foundRole = false;
                    if (rolesForSubtask != null) {
                        for (String role : userRoles) {
                            if (rolesForSubtask.contains(role)) {
                                foundRole = true;
                                break;
                            }
                        }
                    }
                    if (!foundRole) {
                        projectTask.getProjectSubtasks().remove(k);
                    }
                }
                if (projectTask.getProjectSubtasks().isEmpty()) {
                    phase.getProjectTasks().remove(j);
                }
            }
            if (phase.getProjectTasks().isEmpty()) {
                project.getProjectPhases().remove(i);
            }
        }

        return null;
    }

    public PageReference allTasks() {
        MyTaskView = false;
        Filter.ShowMyTasks = false;
        refreshProjectSubtasks();
        return null;
    }

    public PageReference clearFilter() {
        Filter = new GFA_FilterManager();
        Filter.setupLibrarySubtaskFilters();
        return allTasks();
    }
}