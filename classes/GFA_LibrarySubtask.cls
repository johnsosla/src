/*******************************************************************************
*
* PURPOSE: Decorator for GFA_Library_Subtask__c object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
public with sharing class GFA_LibrarySubtask extends GFA_BaseModel {

    public static final String RT_PENDING = 'Pending';
    public static final String RT_ACTIVE = 'Active';

    public static Finder find = new Finder('GFA_Library_Subtask__c');
    private List<GFA_LibrarySubtaskVersion> librarySubtaskVersions;
    public Boolean IsSelected {get; set;}

    private static final Map<String, Schema.RecordTypeInfo> mRtInfo;
    static {
        mRtInfo = GFA_Library_Subtask__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    }

    public GFA_Library_Subtask__c obj {
        get {
            return (GFA_Library_Subtask__c)mObj;
        }
    }

    public GFA_LibrarySubtask() {
        this(new GFA_Library_Subtask__c());
    }

    public GFA_LibrarySubtask(GFA_Library_Subtask__c libSubtask) {
        super(libSubtask);
        librarySubtaskVersions = new List<GFA_LibrarySubtaskVersion>();
        IsSelected = false;
    }

    public void setVersions(List<GFA_LibrarySubtaskVersion> libSubtaskVersions) {
        librarySubtaskVersions = libSubtaskVersions;
    }

    public List<GFA_LibrarySubtaskVersion> getVersions() {
        return librarySubtaskVersions;
    }

    public String getName() {
        return obj.Name;
    }
    public void setName(String Name) {
        obj.Name = Name;
    }

    public String getProjectSponsor() {
        return obj.Project_Sponsor__c;
    }
    public void setProjectSponsor(String ProjectSponsor) {
        obj.Project_Sponsor__c = ProjectSponsor;
    }

    public String getDescription() {
        return obj.Description__c;
    }
    public void setDescription(String Description) {
        obj.Description__c = Description;
    }

    public String getDiscipline() {
        return obj.Discipline__c;
    }
    public void setDiscipline(String Discipline) {
        obj.Discipline__c = Discipline;
    }

    public String getScopeOfService() {
        return obj.Scope_Of_Service__c;
    }
    public void setScopeOfService(String ScopeOfService) {
        obj.Scope_Of_Service__c = ScopeOfService;
    }

    public String getRiskLevel() {
        return obj.Risk_Level__c;
    }
    public void setRiskLevel(String RiskLevel) {
        obj.Risk_Level__c = RiskLevel;
    }

    public String getImpactLevel() {
        return obj.Impact_Level__c;
    }
    public void setImpactLevel(String ImpactLevel) {
        obj.Impact_Level__c = ImpactLevel;
    }

    public String getGroup() {
        return obj.Group__c;
    }
    public void setGroup(String Groupp) {
        obj.Group__c = Groupp;
    }

    public String getOperatingGroup() {
        return obj.Operating_Group__c;
    }
    public void setOperatingGroup(String OperatingGroup) {
        obj.Operating_Group__c = OperatingGroup;
    }

    public String getBusinessLine() {
        return obj.Business_Line__c;
    }
    public void setBusinessLine(String BusinessLine) {
        obj.Business_Line__c = BusinessLine;
    }

    public void setActive() {
        setRecordTypeId(mRtInfo.get(RT_ACTIVE).getRecordTypeId());
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
        }

        public GFA_LibrarySubtask findById(Id libSubtaskId) {
            GFA_Library_Subtask__c libSubtask = (GFA_Library_Subtask__c)byId(libSubtaskId);
            return new GFA_LibrarySubtask(libSubtask);
        }

        public List<GFA_LibrarySubtask> findByIds(Set<Id> libSubtaskIds) {
            List<GFA_LibrarySubtask> libSubtasks = new List<GFA_LibrarySubtask>();
            for (GFA_Library_Subtask__c libSubtask : Database.query(getSelect() + ' where Id IN: libSubtaskIds ' +
                    'ORDER BY Name ASC')) {
                libSubtasks.add(new GFA_LibrarySubtask(libSubtask));
            }
            return libSubtasks;
        }

        public List<GFA_LibrarySubtask> findByCriteria(GFA_LibrarySubtaskCriteria criteria) {
            String whereClause = String.isNotBlank(criteria.getWhereClause())
                                 ? criteria.getWhereClause() + ' AND RecordType.Name =: RT_ACTIVE '
                                 : ' where RecordType.Name =: RT_ACTIVE';
            List<GFA_LibrarySubtask> libSubtasks = new List<GFA_LibrarySubtask>();
            for (GFA_Library_Subtask__c subtask : (List<GFA_Library_Subtask__c>)Database.query(getSelect() +
                    whereClause + ' ORDER BY Name ASC')) {
                libSubtasks.add(new GFA_LibrarySubtask(subtask));
            }
            return libSubtasks;
        }

        /**
        * @param libSubtaskIds, These are the Ids to exclude from the search
        * @return libSubtasks, all Library Subtasks that were not a part of libSubtaskIds
        **/
        public List<GFA_LibrarySubtask> findByNotInIds(Set<Id> libSubtaskIds) {
            List<GFA_LibrarySubtask> libSubtasks = new List<GFA_LibrarySubtask>();
            for (GFA_Library_Subtask__c subtask : (List<GFA_Library_Subtask__c>)Database.query(getSelect() +
                    ' where Id NOT IN: libSubtaskIds')) {
                libSubtasks.add(new GFA_LibrarySubtask(subtask));
            }
            return libSubtasks;
        }

        //--- Returns list of select options from GFA Type field
        public List<SelectOption> getProjectSponsorsOptions() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
            for (String option : getPicklistOptions(GFA_Library_Subtask__c.Project_Sponsor__c)) {
                options.add(new SelectOption(option, option));
            }
            return options;
        }

        //--- Returns list of select options from Discipline field
        public List<SelectOption> getDisciplineOptions() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
            for (String option : getPicklistOptions(GFA_Library_Subtask__c.Discipline__c)) {
                options.add(new SelectOption(option, option));
            }
            return options;
        }

        //--- Returns list of select options from Risk Level field
        public List<SelectOption> getRiskLevelOptions() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
            for (String option : getPicklistOptions(GFA_Library_Subtask__c.Risk_Level__c)) {
                options.add(new SelectOption(option, option));
            }
            return options;
        }

        //--- Returns list of select options from Impact Level field
        public List<SelectOption> getImpactLevelOptions() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
            for (String option : getPicklistOptions(GFA_Library_Subtask__c.Impact_Level__c)) {
                options.add(new SelectOption(option, option));
            }
            return options;
        }
    }
}