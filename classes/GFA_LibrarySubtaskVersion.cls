/*******************************************************************************
*
* PURPOSE: Decorator for GFA_Library_Subtask_Content__c object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
public with sharing class GFA_LibrarySubtaskVersion extends GFA_BaseModel {

    public static Finder find = new Finder('GFA_Library_Subtask_Version__c');
    public final static String STATUS_ACTIVE = 'Active';
    public final static String STATUS_PENDING = 'Pending';
    public final static String STATUS_ARCHIVED = 'Archived';

    private static final Map<String, Schema.RecordTypeInfo> mRtInfo;
    static {
        mRtInfo = GFA_Library_Subtask_Version__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    }

    public GFA_Library_Subtask_Version__c obj {
        get {
            return (GFA_Library_Subtask_Version__c)mObj;
        }
    }

    private List<GFA_LibrarySubtaskContent> libSubtaskContents;

    public GFA_LibrarySubtaskVersion() {
        this(new GFA_Library_Subtask_Version__c());
    }

    public GFA_LibrarySubtaskVersion(GFA_Library_Subtask_Version__c libSubtaskVersion) {
        super(libSubtaskVersion);
        libSubtaskContents = new List<GFA_LibrarySubtaskContent>();
    }

    public void setLibrarySubtaskContents(List<GFA_LibrarySubtaskContent> contents) {
        libSubtaskContents = contents;
    }
    public List<GFA_LibrarySubtaskContent> getLibrarySubtaskContents() {
        return libSubtaskContents;
    }

    public String getStatus() {
        return obj.Version_Status__c;
    }
    public void setStatus(String Status) {
        obj.Version_Status__c = Status;
    }

    public void setStatusActive() {
        setStatus(STATUS_ACTIVE);
        setRecordTypeId(mRtInfo.get(STATUS_ACTIVE).getRecordTypeId());
    }

    public String getLibrarySubtaskName() {
        return obj.Library_Subtask__r.Name;
    }
    public Id getLibrarySubtaskId() {
        return obj.Library_Subtask__c;
    }

    public void setLibrarySubtaskId(Id librarySubtaskId) {
        obj.Library_Subtask__c = librarySubtaskId;
    }

    public String getScopeofService() {
        return obj.Scope_of_Service__c;
    }

    public String getDescription() {
        return obj.Description__c;
    }

    public String getImpactLevel() {
        return obj.Impact_Level__c;
    }

    public String getRiskLevel() {
        return obj.Risk_Level__c;
    }

    public String getDiscipline() {
        return obj.Discipline__c;
    }

    public Id getRecordTypeId() {
        return obj.RecordTypeId;
    }
    public void setRecordTypeId(Id RecordTypeId) {
        obj.RecordTypeId = RecordTypeId;
    }


    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            Set<String> librarySubtaskFields = GFA_LibrarySubtask.find.getFieldSet();
            Set<String> additionalFields = new Set<String>();
            for (String libField : librarySubtaskFields) {
                additionalFields.add('Library_Subtask__r.' + libField);
            }
            addFields(additionalFields);
        }

        public GFA_LibrarySubtaskVersion findById(Id libSubtaskVersionId) {
            GFA_Library_Subtask_Version__c lsVersion = (GFA_Library_Subtask_Version__c)byId(libSubtaskVersionId);
            return new GFA_LibrarySubtaskVersion(lsVersion);
        }

        public List<GFA_LibrarySubtaskVersion> findByIds(Set<Id> libSubtaskVersionIds) {
            List<GFA_LibrarySubtaskVersion> versions = new List<GFA_LibrarySubtaskVersion>();
            for (GFA_Library_Subtask_Version__c version : (List<GFA_Library_Subtask_Version__c>) Database.query(getSelect() +
                    ' where Id IN: libSubtaskVersionIds')) {
                versions.add(new GFA_LibrarySubtaskVersion(version));
            }
            return versions;
        }

        public List<GFA_LibrarySubtaskVersion> findBySubtaskId(Id subtaskId) {
            List<GFA_LibrarySubtaskVersion> versions = new List<GFA_LibrarySubtaskVersion>();
            for (GFA_Library_Subtask_Version__c version : (List<GFA_Library_Subtask_Version__c>)getSelectWhere('Library_Subtask__c', subtaskId)) {
                versions.add(new GFA_LibrarySubtaskVersion(version));
            }
            return versions;
        }

        public GFA_LibrarySubtaskVersion findLatestActiveVersion(Id libSubtaskId) {
            GFA_Library_Subtask_Version__c ver = (GFA_Library_Subtask_Version__c)Database.query(getSelect() + 'Where Library_Subtask__c =: libSubtaskId AND Version_Status__c =: STATUS_ACTIVE ORDER BY Version_No__c DESC LIMIT 1');
            return new GFA_LibrarySubtaskVersion(ver);
        }

        public List<GFA_LibrarySubtaskVersion> findLatestActiveVersions(Set<Id> libSubtaskIds) {
            List<GFA_LibrarySubtaskVersion> versions = new List<GFA_LibrarySubtaskVersion>();
            for (GFA_Library_Subtask_Version__c version : (List<GFA_Library_Subtask_Version__c>)Database.query(getSelect() + 'Where Library_Subtask__c in :libSubtaskIds AND Version_Status__c =: STATUS_ACTIVE ORDER BY Version_No__c DESC')) {
                versions.add(new GFA_LibrarySubtaskVersion(version));
            }
            return versions;
        }

        public Map<Id, List<GFA_LibrarySubtaskVersion>> findByLibrarySubtaskIds(List<GFA_LibrarySubtask> librarySubtasks) {
            Map<Id, List<GFA_LibrarySubtaskVersion>> libSubtaskVersionMap = new Map<Id, List<GFA_LibrarySubtaskVersion>>();
            Set<String> ids = new Set<String>();
            for (GFA_LibrarySubtask librarySubtask : librarySubtasks) {
                ids.add(librarySubtask.getId());
            }
            for (GFA_Library_Subtask_Version__c version : (List<GFA_Library_Subtask_Version__c>)getSelectIn(
                        'Library_Subtask__c', ids)) {
                Id key = version.Library_Subtask__c;
                if (libSubtaskVersionMap.containsKey(key)) {
                    libSubtaskVersionMap.get(key).add(new GFA_LibrarySubtaskVersion(version));
                } else {
                    libSubtaskVersionMap.put(key, new List<GFA_LibrarySubtaskVersion> {new GFA_LibrarySubtaskVersion(version)});
                }
            }
            return libSubtaskVersionMap;
        }

        public List<GFA_LibrarySubtaskVersion> findActiveByIds(Set<Id> libSubtaskVersionIds) {
            List<GFA_LibrarySubtaskVersion> versions = new List<GFA_LibrarySubtaskVersion>();
            for (GFA_Library_Subtask_Version__c version : (List<GFA_Library_Subtask_Version__c>)Database.query(getSelect() + 'Where Id in :libSubtaskVersionIds AND Version_Status__c =: STATUS_ACTIVE ORDER BY Version_No__c DESC')) {
                versions.add(new GFA_LibrarySubtaskVersion(version));
            }
            return versions;
        }
    }
}