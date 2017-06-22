public with sharing class GFA_ActivateLibrarySubtaskController {

    private GFA_LibrarySubtask subtask;

    public GFA_ActivateLibrarySubtaskController(ApexPages.StandardController sc) {
		subtask = GFA_LibrarySubtask.find.findById(sc.getId());
	}

    public PageReference activatePendingVersion() {
        List<GFA_LibrarySubtaskVersion> versions = GFA_LibrarySubtaskVersion.find.findBySubtaskId(subtask.getId());

        PageReference pr = new PageReference('/' + subtask.getId());
        pr.setRedirect(true);

        //---Only do this step if there is only one version and that version is Pending
        if(versions.size() == 1 && versions[0].getStatus() == GFA_LibrarySubtaskVersion.STATUS_PENDING) {
            subtask.setActive();
            subtask.save();

            GFA_LibrarySubtaskVersion version = versions[0];
            version.setStatusActive();
            version.save();

        }
        return pr;
    }
}