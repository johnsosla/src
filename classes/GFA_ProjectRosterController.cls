public with sharing class GFA_ProjectRosterController extends GFA_BaseController {
    public GFA_ProjectRoster projectRoster {get; set;}
    public String projectId {get; set;}
    public String teamMemberName {get; set;}
    private Boolean mCanEdit;

    public GFA_ProjectRosterController(ApexPages.StandardController sc) {
        if (sc.getId() != null) {
            projectRoster = GFA_ProjectRoster.find.findById(sc.getId());
            teamMemberName = projectRoster.getName();
        } else {
            projectId = ApexPages.currentPage().getParameters().get('projectid');
            projectRoster = new GFA_ProjectRoster();
            projectRoster.setProjectId(Id.valueOf(projectId));
            teamMemberName = 'New Team Roster';
        }
    }

    public PageReference editPR() {
        PageReference pr = Page.GFA_ProjectRosterEdit;
        pr.setRedirect(true);
        putParam(pr, 'id', projectRoster.getId());
        return pr;
    }

    public Boolean getCanEdit() {
        if (mCanEdit == null) {
        // Add the User's Roles to a set
            Boolean foundRole = false || CurrentUser.getIsAdminUser();
            for (GFA_ProjectRoster roster : GFA_ProjectRoster.find.findByProjectId(projectId)) {
                if (roster.getTeamMemberUserId() == UserInfo.getUserId()) {
                    if (roster.getIsActingPM()) {
                        foundRole = true;
                    }
                }
            }
            mCanEdit = foundRole && !CurrentUser.getIsOtherUser();
        }
        return mCanEdit;
    }

    public PageReference savePR() {
        List<GFA_ProjectRoster> projectRosters = new List<GFA_ProjectRoster>();
        projectRosters.add(projectRoster);

        GFA_DMLUtils.save(projectRosters);

        PageReference pr = Page.GFA_ProjectDetailView;
        pr.setRedirect(true);
        putParam(pr, 'id', projectRoster.getProjectId());
        pr.setAnchor('teamRosterPanel');
        return pr;
    }

    public PageReference cancelPR() {
        PageReference pr = Page.GFA_ProjectDetailView;
        pr.setRedirect(true);
        putParam(pr, 'id', projectRoster.getProjectId());
        pr.setAnchor('teamRosterPanel');
        return pr;
    }

    public PageReference deletePR() {
        Id projectId = projectRoster.getProjectId();
        List<GFA_ProjectRoster> projectRosters = new List<GFA_ProjectRoster>();
        projectRosters.add(projectRoster);

        GFA_DMLUtils.destroy(projectRosters);

        PageReference pr = Page.GFA_ProjectDetailView;
        pr.setRedirect(true);
        putParam(pr, 'id', projectId);
        pr.setAnchor('teamRosterPanel');
        return pr;
    }
}