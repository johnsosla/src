public with sharing class GFA_LibrarySubtaskVersionController extends GFA_BaseController {
    public GFA_LibrarySubtaskVersion librarySubtaskActiveVersion {get; set;}
    public GFA_LibrarySubtaskVersion lsVersionNew {get; set;}
    private static Map<String, Schema.RecordTypeInfo> mRtInfo = GFA_Library_Subtask_Version__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    public GFA_LibrarySubtaskVersion lsActiveVersion {get; set;}

	public GFA_LibrarySubtaskVersionController(ApexPages.StandardController sc) {
        if (sc.getRecord() != null) {
            lsActiveVersion = new GFA_LibrarySubtaskVersion((GFA_Library_Subtask_Version__c)sc.getRecord());
            if (lsActiveVersion.getLibrarySubtaskId() != null) {
                librarySubtaskActiveVersion = GFA_LibrarySubtaskVersion.find.findLatestActiveVersion(lsActiveVersion.getLibrarySubtaskId());
                List<GFA_LibrarySubtaskContent> lsContents = GFA_LibrarySubtaskContent.find.findBySubtaskVersionId(librarySubtaskActiveVersion.getId());
                librarySubtaskActiveVersion.setLibrarySubtaskContents(lsContents);
            }
        }
    }

    public PageReference callPageReference() {
        if (lsActiveVersion != null && lsActiveVersion.getLibrarySubtaskId() != null) {

            GFA_LibrarySubtaskVersion tempLSVersion = new GFA_LibrarySubtaskVersion();
            Boolean chkPending = false;

            List<GFA_LibrarySubtaskVersion> lsVers = GFA_LibrarySubtaskVersion.find.findBySubtaskId(lsActiveVersion.getLibrarySubtaskId());
            if(lsVers != null && lsVers.size() > 0) {
                for (GFA_LibrarySubtaskVersion lsVer : lsVers) {
                    if (lsVer.getStatus() == GFA_LibrarySubtaskVersion.STATUS_PENDING) {
                        chkPending = true;
                    }
                }
            }
            if(!chkPending) {

                tempLSVersion = librarySubtaskActiveVersion;
                lsVersionNew = new GFA_LibrarySubtaskVersion((GFA_Library_Subtask_Version__c)tempLSVersion.getObj().clone(false, true));
                lsVersionNew.setRecordTypeId(mRtInfo.get(GFA_LibrarySubtask.RT_PENDING).getRecordTypeId());
                lsVersionNew.save();

               List<GFA_LibrarySubtaskContent> newContents = new List<GFA_LibrarySubtaskContent>();

                for (GFA_LibrarySubtaskContent content : librarySubtaskActiveVersion.getLibrarySubtaskContents()) {
                    GFA_LibrarySubtaskContent newContent = new GFA_LibrarySubtaskContent();
                    newContent = content;
                    GFA_LibrarySubtaskContent clonedContent = new GFA_LibrarySubtaskContent((GFA_Library_Subtask_Content__c)newContent.getObj().clone(false, true)); //do a deep clone
                    clonedContent.setLibrarySubtaskVersionId(lsVersionNew.getId());
                    newContents.add(clonedContent);
                }
                if( newContents != null && newContents.size() > 0) {
                    List<GFA_BaseModel> models = new List<GFA_BaseModel>();
                    models.addAll((List<GFA_BaseModel>)newContents);

                    GFA_BaseModel.save(models);
                }

                PageReference pr = new PageReference('/' +lsVersionNew.getId() +'/e?retURL=' +lsVersionNew.getLibrarySubtaskId());
                pr.setRedirect(true);

                return pr;
            } else {
                String stringURL  = '<a href=/' + lsActiveVersion.getLibrarySubtaskId() + '>Back</a>';
                addError('There cannot be more than one pending Version. <br/><br/>' +stringURL);
                return null;
            }
        } else {
            String retId = ApexPages.currentPage().getParameters().get('retURL');
            String retURL;
            if (retId.contains('https://')) {
                retURL = '<a href=' + retId + '>Back</a>';
            } else {
                retURL = '<a href=/' + retId.substring(1, retId.length()) + '>Back</a>';
            }
            addError('There cannot be more than one pending Version. <br/><br/>' +retURL);
            return null;
        }
    }
}