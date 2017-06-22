/*******************************************************************************
*
* PURPOSE: Decorator for GFA_Library_Subtask_Content__c object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
public with sharing class GFA_LibrarySubtaskContent extends GFA_BaseModel {

    public static Finder find = new Finder('GFA_Library_Subtask_Content__c');

    public GFA_Library_Subtask_Content__c obj {
        get {
            return (GFA_Library_Subtask_Content__c)mObj;
        }
    }

    public GFA_LibrarySubtaskContent() {
        this(new GFA_Library_Subtask_Content__c());
    }

    public GFA_LibrarySubtaskContent(GFA_Library_Subtask_Content__c libSubtaskContent) {
        super(libSubtaskContent);
    }

    public String getName() {
        return obj.Name;
    }

    public void setName(String Name) {
        mObj.put('Name', Name);
    }

    public String getLibrarySubtaskVersionName() {
        return obj.Library_Subtask_Version__r.Name;
    }

    public Id getLibrarySubtaskVersionId() {
        return obj.Library_Subtask_Version__c;
    }

    public void setLibrarySubtaskVersionId(Id lsVersionId) {
        obj.Library_Subtask_Version__c = lsVersionId;
    }

    public Boolean getHiddenDeliverable() {
        return obj.Hidden_Deliverable__c;
    }
    public void setHiddenDeliverable(Boolean HiddenDeliverable) {
        mObj.put('Hidden_Deliverable__c', HiddenDeliverable);
    }

    public String getCreatedBy() {
        return obj.CreatedBy.Name;
    }

    public String getLastModifiedBy() {
        return obj.LastModifiedBy.Name;
    }

    public String getLink() {
        if (obj.Link__c != null && (!obj.Link__c.startsWith('https://') && !obj.Link__c.startsWith('http://'))) {
            return 'http://' + obj.Link__c;
        } else {
            return obj.Link__c;
        }
    }

    public void setLink(String Link) {
        mObj.put('Link__c', Link);
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            Set<String> librarySubtaskVersionFields = GFA_LibrarySubtaskVersion.find.getFieldSet();
            Set<String> additionalFields = new Set<String>();
            for (String libField : librarySubtaskVersionFields) {
                additionalFields.add('Library_Subtask_Version__r.' + libField);
            }
            additionalFields.add('CreatedBy.Name');
            additionalFields.add('LastModifiedBy.Name');
            addFields(additionalFields);
        }

        public GFA_LibrarySubtaskContent findById(Id contentId) {
            GFA_Library_Subtask_Content__c content = (GFA_Library_Subtask_Content__c)byId(contentId);
            return new GFA_LibrarySubtaskContent(content);
        }

        public List<GFA_LibrarySubtaskContent> findBySubtaskVersionId(Id subtaskVersionId) {
            List<GFA_LibrarySubtaskContent> contents = new List<GFA_LibrarySubtaskContent>();
            for (GFA_Library_Subtask_Content__c content : (List<GFA_Library_Subtask_Content__c>)getSelectWhere('Library_Subtask_Version__c', subtaskVersionId)) {
                contents.add(new GFA_LibrarySubtaskContent(content));
            }
            return contents;
        }

        public Map<Id, List<GFA_LibrarySubtaskContent>> findByVersionIds(List<GFA_LibrarySubtaskVersion> versions) {
            Map<Id, List<GFA_LibrarySubtaskContent>> versionContentMap = new Map<Id, List<GFA_LibrarySubtaskContent>>();
            Set<String> ids = new Set<String>();
            for (GFA_LibrarySubtaskVersion version : versions) {
                ids.add(version.getId());
            }
            for (GFA_Library_Subtask_Content__c content : (List<GFA_Library_Subtask_Content__c>)getSelectIn(
                        'Library_Subtask_Version__c', ids)) {
                Id key = content.Library_Subtask_Version__c;
                if (versionContentMap.containsKey(key)) {
                    versionContentMap.get(key).add(new GFA_LibrarySubtaskContent(content));
                } else {
                    versionContentMap.put(key, new List<GFA_LibrarySubtaskContent> {new GFA_LibrarySubtaskContent(content)});
                }
            }
            return versionContentMap;
        }
    }
}