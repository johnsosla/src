public with sharing class GFA_ProjectTaskDetailController extends GFA_BaseController {
    public GFA_ProjectTask projectTask {get; set;}
    public GFA_ProjectPhase projectPhase {get; set;}
    public GFA_Project project { get; set;}
    public Boolean MySubtaskView {get; set;}
    private GFA_FilterManager Filter;
    private Boolean mCanViewHiddenDeliverables {get; set;}

    public GFA_ProjectTaskDetailController(ApexPages.StandardController sc) {
        projectTask = GFA_ProjectTask.find.findById(sc.getId());
        setupFilter();
        setProjectTask();
        MySubtaskView = Filter.ShowMyTasks != null ? Filter.ShowMyTasks : false;
        if (MySubtaskView) {
            mySubtask(false);
        }
    }

    private void setupFilter() {
        Filter = new GFA_FilterManager();
        if (String.isNotBlank(CurrentUser.getParameters())) {
            GFA_FilterManager userFilter = CurrentUser.getParametersAsFilterManager();
            Filter.ImpactLevel = userFilter.ImpactLevel;
            Filter.ShowMyTasks = userFilter.ShowMyTasks;
        }
        Filter.ProjectId = projectTask.getProjectId();
    }

    public void setProjectTask() {
        //---Adding applicable librarySubtasks to a list
        Set<Id> libSubtaskIds = new Set<Id>();
        for (GFA_ProjectSubtask subtask : Filter.getProjectSubtasksByCriteria()) {
            libSubtaskIds.add(subtask.getId());
        }

        List<GFA_ProjectSubtask> projectSubtasks = GFA_ProjectSubtask.find.findByProjectTaskId(projectTask.getId());
        projectTask.calculateSubtaskCompleted(projectSubtasks);

        for (Integer i = projectSubtasks.size() - 1; i > -1; i--) {
            GFA_ProjectSubtask subtask = projectSubtasks[i];
            if (!libSubtaskIds.contains(subtask.getId())
                    || (!subtask.getIsApplicable() && !subtask.getIsPMVisible())) {
                projectSubtasks.remove(i);
            }
        }
        Map<Id, List<GFA_ProjectDeliverable>> deliverableMap = GFA_ProjectDeliverable.find.findByProjectSubtaskIds(projectSubtasks);

        Set<Id> libSubtaskVersionIds = new Set<Id>();
        for (GFA_ProjectSubtask projectSubtask : projectSubtasks) {
            libSubtaskVersionIds.add(projectSubtask.getLibrarySubtaskVersionId());
        }

        projectPhase = GFA_ProjectPhase.find.findById(projectTask.getProjectPhaseId());
        project = GFA_Project.find.findById(projectPhase.getProjectId());

        List<GFA_LibrarySubtaskVersion> libSubtaskVersions = GFA_LibrarySubtaskVersion.find.findByIds(libSubtaskVersionIds);
        Map<Id, List<GFA_LibrarySubtaskContent>> versionContentMap = GFA_LibrarySubtaskContent.find.findByVersionIds(libSubtaskVersions);

        //Start adding Content to Version, Version to ProjectSubtask

        for (GFA_LibrarySubtaskVersion activeLibSubtaskVersion : libSubtaskVersions) {
            activeLibSubtaskVersion.setLibrarySubtaskContents(versionContentMap.get(activeLibSubtaskVersion.getId()));
        }

        // libSubtaskVersion to projectSubtasks
        for (GFA_ProjectSubtask projectSubtask : projectSubtasks) {
            for (GFA_LibrarySubtaskVersion version : libSubtaskVersions) {
                if (version.getId() == projectSubtask.getLibrarySubtaskVersionId()) {
                    projectSubtask.getLibrarySubtaskVersions().add(version);
                    break;
                }
            }
            projectSubtask.setProjectDeliverables(deliverableMap.get(projectSubtask.getId()));
        }

        //projectsubtask to projecttask
        projectTask.setprojectSubtasks(projectSubtasks);
        List<GFA_ProjectSubtask> calcSubtasks = new List<GFA_ProjectSubtask>();
        for (GFA_ProjectSubtask subtask : GFA_ProjectSubtask.find.findByProjectTaskId(projectTask.getId())) {
            if (subtask.getIsApplicable() || subtask.getIsPMVisible()) {
                calcSubtasks.add(subtask);
            }
        }
        projectTask.calculateSubtaskCompleted(calcSubtasks);
    }

    public PageReference mySubtask() {
        return mySubtask(true);
    }

    public PageReference mySubtask(Boolean shouldSave) {
        MySubtaskView = true;
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

        for (Integer i = projectTask.getProjectSubtasks().size() - 1; i > -1; i--) {
            GFA_ProjectSubtask subtask = projectTask.getProjectSubtasks()[i];
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
                projectTask.getProjectSubtasks().remove(i);
            }
        }
        Filter.ShowMyTasks = true;
        if (shouldSave) {
            saveSearchCriteria();
        }
        return null;
    }

    public PageReference allSubtasks() {
        MySubtaskView = false;
        Filter.ShowMyTasks = false;
        saveSearchCriteria();
        setProjectTask();
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

    public PageReference projectFramework() {
        PageReference pr = Page.GFA_ProjectFramework;
        pr.setRedirect(true);
        putParam(pr, 'id', projectPhase.getProjectId());
        putParam(pr, 'OnlyApplicable', 'true');
        return pr;
    }

    public Boolean getCanViewHiddenDeliverables() {
        if (mCanViewHiddenDeliverables == null) {
            mCanViewHiddenDeliverables = false || CurrentUser.getIsAdminUser();
            List<GFA_ProjectRoster> rosters = GFA_ProjectRoster.find.findByProjectId(projectPhase.getProjectId());
            for (GFA_ProjectRoster roster : rosters) {
                if (roster.getTeamMemberUserId() == CurrentUser.getId()
                        && roster.getIsActingPM()
                        && !mCanViewHiddenDeliverables) {
                    mCanViewHiddenDeliverables = true;
                }
            }
        }
        return mCanViewHiddenDeliverables;
    }
}