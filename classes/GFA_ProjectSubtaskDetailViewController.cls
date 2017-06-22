public with sharing class GFA_ProjectSubtaskDetailViewController extends GFA_BaseController {
    public GFA_ProjectSubtask projectSubtask {get; set;}
    public GFA_LibrarySubtaskVersion lsVersion {get; set;}
    public GFA_ProjectTask projectTask {get; set;}
    public GFA_ProjectPhase projectPhase {get; set;}
    public GFA_Project project {get; set;}
    private Boolean mCanEdit;
    private Boolean mCanViewHiddenDeliverables;

    // the variable being set from the commandbutton
    public String deliverableId {get; set;}

    public GFA_ProjectSubtaskDetailViewController(ApexPages.StandardController sc) {
        projectSubtask = GFA_ProjectSubtask.find.findById(sc.getId());
        deliverableId = ApexPages.currentPage().getParameters().get('deliverableId');

        setProjectSubtask();
    }

    private void setProjectSubtask() {
        lsVersion = GFA_LibrarySubtaskVersion.find.findById(projectSubtask.getLibrarySubtaskVersionId());
        projectTask = GFA_ProjectTask.find.findById(projectSubtask.getProjectTaskId());
        projectPhase = GFA_ProjectPhase.find.findById(projectTask.getProjectPhaseId());
        project = GFA_Project.find.findById(projectPhase.getProjectId());

        List<GFA_LibrarySubtaskContent> documentationList = GFA_LibrarySubtaskContent.find.findBySubtaskVersionId(lsVersion.getId());
        lsVersion.setLibrarySubtaskContents(documentationList);

        List<GFA_ProjectDeliverable> projectDeliverables = GFA_ProjectDeliverable.find.findByProjectSubtaskId(projectSubtask.getId());
        projectSubtask.setProjectDeliverables(projectDeliverables);

    }

    public PageReference editSubtask() {
        PageReference pr = Page.GFA_ProjectSubtaskDetailEdit;
        pr.setRedirect(true);
        putParam(pr, 'id', projectSubtask.getId());
        return pr;
    }

    public PageReference newDeliverable() {
        PageReference pr = Page.GFA_ProjectDeliverableDetailEdit;
        pr.setRedirect(true);
        GFA_ProjectDeliverable projectDeliverableNew = new GFA_ProjectDeliverable();
        putParam(pr, 'id', projectDeliverableNew.getId());
        putParam(pr, 'subtaskid', projectSubtask.getId());
        return pr;
    }

    public PageReference editDeliverable() {
        PageReference pr = Page.GFA_ProjectDeliverableDetailEdit;
        pr.setRedirect(true);
        putParam(pr, 'id', Id.valueOf(deliverableId));
        return pr;
    }

    public PageReference deleteDeliverable() {

        GFA_ProjectDeliverable projdeliverable = new GFA_ProjectDeliverable();
        for (GFA_ProjectDeliverable projectDeliverable : projectSubtask.getProjectDeliverables()) {
            if (projectDeliverable.getId() == Id.valueOf(deliverableId)) {
                projdeliverable = projectDeliverable;
            }
        }
        if (projdeliverable != null) {
            projdeliverable.destroy();
        }

        PageReference pr = Page.GFA_ProjectSubtaskDetailView;
        pr.setRedirect(true);
        putParam(pr, 'id', projectSubtask.getId());
        return pr;
    }

    public Boolean getCanEdit() {
        if (mCanEdit == null) {
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
            Boolean foundRole = false || CurrentUser.getIsAdminUser();
            for (GFA_ProjectRoster roster : GFA_ProjectRoster.find.findByProjectId(project.getId())) {
                if (roster.getTeamMemberUserId() == UserInfo.getUserId()) {
                    userRoles.add(roster.getRole());
                    if (roster.getIsActingPM()) {
                        foundRole = true;
                    }
                }
            }
            Set<String> rolesForSubtask = disciplineToRoleMap.get(projectSubtask.getDiscipline());
            for (String role : userRoles) {
                if (rolesForSubtask != null && rolesForSubtask.contains(role)) {
                    foundRole = true;
                    break;
                }
            }
            mCanEdit = foundRole && !CurrentUser.getIsOtherUser();
        }
        return mCanEdit;
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