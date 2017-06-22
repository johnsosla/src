public with sharing class GFA_ProjectTreeViewController extends GFA_ProjectTreeBaseController {

    public GFA_ProjectTreeViewController(ApexPages.StandardController sc) {
        super(sc);
        setupProjectItems();
    }

    private void setupProjectItems() {
        List<GFA_ProjectRoster> projectRosters = GFA_ProjectRoster.find.findByProjectId(project.getId());
        project.setProjectRosters(projectRosters);
    }

    /*
    *   Restores all project subtasks to tree
    */
    public PageReference setAll() {
        ViewType = VIEW_ALL;
        setupProject();
        return null;
    }

    /*
    *   Removes project subtasks that are not marked as Applicable
    */
    public PageReference setApplicable() {
        ViewType = VIEW_APPLICABLE;
        for (GFA_ProjectPhase phase : project.getProjectPhases()) {
            for (GFA_ProjectTask task : phase.getProjectTasks()) {
                for (Integer i = task.getProjectSubtasks().size() - 1; i > -1; i--) {
                    if (!task.getProjectSubtasks()[i].getIsApplicable()) {
                        task.getProjectSubtasks().remove(i);
                    }
                }
            }
        }
        return null;
    }

    public Boolean getCanEditProject() {
        Boolean isActingPM = false;

        if (project.getProjectRosters() != null && project.getProjectRosters().size() > 0) {
            for (GFA_ProjectRoster roster : project.getProjectRosters()) {
                if (roster.getTeamMemberUserId() == CurrentUser.getId() && roster.getIsActingPM()) {
                    isActingPM = true;
                }
            }
        }
        return CurrentUser.getIsAdminUser() || isActingPM || project.getCreatedById() == CurrentUser.getId();
    }

    public PageReference editProject() {
        PageReference pr = Page.GFA_ProjectTreeEdit;
        pr.setRedirect(true);
        putParam(pr, 'id', project.getId());
        putParam(pr, 'ViewType', ViewType);
        return pr;
    }
}