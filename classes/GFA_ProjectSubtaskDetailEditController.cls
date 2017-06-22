public with sharing class GFA_ProjectSubtaskDetailEditController extends GFA_BaseController {
    public GFA_ProjectSubtask projectSubtask {get; set;}
    public GFA_LibrarySubtaskVersion lsVersion {get; set;}
    public GFA_ProjectSubtaskDetailEditController(ApexPages.StandardController sc) {
        projectSubtask = GFA_ProjectSubtask.find.findById(sc.getId());
        lsVersion = GFA_LibrarySubtaskVersion.find.findById(projectSubtask.getLibrarySubtaskVersionId());

    }

    public PageReference saveSubtask() {
        List<GFA_ProjectRoster> projectRosters = GFA_ProjectRoster.find.findByProjectId(projectSubtask.getProjectId());

        Boolean canSetCompleted = false || projectSubtask.getStatus() != GFA_ProjectSubtask.STATUS_COMPLETED || CurrentUser.getIsAdminUser();

        for (GFA_ProjectRoster roster : projectRosters) {
            if (roster.getTeamMemberUserId() == CurrentUser.getId() && roster.getIsActingPM()) {
                canSetCompleted = true;
            }
        }

        if (canSetCompleted) {
            projectSubtask.save();
        } else {
            addError('You do not have the correct privileges to complete this task');
            return null;
        }

        PageReference pr = Page.GFA_ProjectSubtaskDetailView;
        pr.setRedirect(true);
        putParam(pr, 'id', projectSubtask.getId());
        return pr;
    }

    public PageReference cancelSubtask() {
        PageReference pr = Page.GFA_ProjectSubtaskDetailView;
        pr.setRedirect(true);
        putParam(pr, 'id', projectSubtask.getId());
        return pr;
    }
}