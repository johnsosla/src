public with sharing class GFA_ActivateLibrarySubtaskVerController {

    private GFA_LibrarySubtaskVersion version;

    public GFA_ActivateLibrarySubtaskVerController(ApexPages.StandardController sc) {
        version = GFA_LibrarySubtaskVersion.find.findById(sc.getId());
    }

    public PageReference activateLibrarySubtaskVersion() {
        PageReference pr = new PageReference('/' + version.getId());
        Map<String, Schema.RecordTypeInfo> mParentRtInfo = GFA_Library_Subtask__c.SObjectType.getDescribe().getRecordTypeInfosByName();

        GFA_LibrarySubtask subtask = GFA_LibrarySubtask.find.findById(version.getLibrarySubtaskId());

        if (version.getStatus() == GFA_LibrarySubtaskVersion.STATUS_PENDING) {
            version.setStatusActive();
            version.save();
        }
        if (subtask.getRecordTypeId() == mParentRtInfo.get(GFA_LibrarySubtask.RT_PENDING).getRecordTypeId()) {
            subtask.setActive();
            subtask.save();
        }
        return pr;
    }
}