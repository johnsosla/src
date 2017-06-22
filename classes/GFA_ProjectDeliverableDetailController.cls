public with sharing class GFA_ProjectDeliverableDetailController extends GFA_BaseController {
    public GFA_ProjectDeliverable projectDeliverable {get; set;}
    public String subtaskId {get; set;}
    public String subtaskName {get; set;}
    public GFA_ProjectSubtask projectSubtask {get; set;}
    public GFA_ProjectTask projectTask {get; set;}
    public GFA_ProjectPhase projectPhase {get; set;}
    public GFA_Project project {get; set;}
    private Boolean mCanEdit;
    public String projectDeliverableName {get; set;}

    public GFA_ProjectDeliverableDetailController(ApexPages.StandardController sc) {
        if (sc.getId() != null) {
            projectDeliverable = GFA_ProjectDeliverable.find.findById(sc.getId());
            subtaskName = projectDeliverable.getProjectSubtaskName();
            projectSubtask = GFA_ProjectSubtask.find.findById(projectDeliverable.getProjectSubtaskId());
            projectDeliverableName = projectDeliverable.getName();
        } else {
            subtaskId = ApexPages.currentPage().getParameters().get('subtaskid');
            projectSubtask = GFA_ProjectSubtask.find.findById(Id.valueOf(subtaskId));
            projectDeliverable = new GFA_ProjectDeliverable();
            projectDeliverable.setProjectSubtaskId(Id.valueOf(subtaskId));
            subtaskName = projectSubtask.getLibrarySubtaskName();
            projectDeliverableName = 'New Project Deliverable';
        }
        projectTask = GFA_ProjectTask.find.findById(projectSubtask.getProjectTaskId());
        projectPhase = GFA_ProjectPhase.find.findById(projectTask.getProjectPhaseId());
        project = GFA_Project.find.findById(projectSubtask.getProjectId());
    }

    public PageReference saveDeliverable() {
        projectDeliverable.save();

        PageReference pr = Page.GFA_ProjectDeliverableDetailView;
        pr.setRedirect(true);
        putParam(pr, 'id', projectDeliverable.getId());
        return pr;
    }

    public PageReference cancelDeliverable() {
        PageReference pr = Page.GFA_ProjectSubtaskDetailView;
        pr.setRedirect(true);
        putParam(pr, 'id', projectDeliverable.getProjectSubtaskId());
        return pr;
    }

    public PageReference editDeliverable() {
        PageReference pr = Page.GFA_ProjectDeliverableDetailEdit;
        pr.setRedirect(true);
        putParam(pr, 'id', projectDeliverable.getId());
        return pr;
    }

    public PageReference deleteDeliverable() {
        Id projectSubtaskId = projectDeliverable.getProjectSubtaskId();
        projectDeliverable.destroy();

        PageReference pr = Page.GFA_ProjectSubtaskDetailView;
        pr.setRedirect(true);
        putParam(pr, 'id', projectSubtaskId);
        return pr;
    }

    public Boolean getCanEdit() {
        if (mCanEdit == null) {
            GFA_ProjectSubtask pSubtask = GFA_ProjectSubtask.find.findById(projectDeliverable.getProjectSubtaskId());
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
            for (GFA_ProjectRoster roster : GFA_ProjectRoster.find.findByProjectId(pSubtask.getProjectId())) {
                if (roster.getTeamMemberUserId() == UserInfo.getUserId()) {
                    userRoles.add(roster.getRole());
                }
            }
            Set<String> rolesForSubtask = disciplineToRoleMap.get(pSubtask.getDiscipline());
            Boolean foundRole = false || CurrentUser.getIsAdminUser();
            for (String role : userRoles) {
                if (rolesForSubtask != null && rolesForSubtask.contains(role)) {
                    foundRole = true;
                    break;
                }
            }
            mCanEdit = foundRole;
        }
        return mCanEdit;
    }
}