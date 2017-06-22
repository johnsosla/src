/*******************************************************************************
*
* PURPOSE: Decorator for GFA_Project__c object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
public with sharing class GFA_Project extends GFA_BaseModel {

    public static final String STATUS_NOT_STARTED = 'Not Started';
    public static final String STATUS_IN_PROGRESS = 'In Progress';
    public static final String STATUS_COMPLETED = 'Completed';
    public static final String STATUS_CANCELLED = 'Cancelled';
    public static final String STATUS_DISCONTINUED = 'Discontinued';
    public static final String STATUS_NA = 'NA';

    public static final String LIFECYCLE_STAGE_PROPOSAL = 'Proposal';
    public static final String LIFECYCLE_STAGE_PROJECT = 'Project';

    public static final String OPERATING_GROUP_CSOIL = 'CS-Oil & Gas';

    public static Finder find = new Finder('GFA_Project__c');
    private List<GFA_ProjectPhase> projectPhases;
    private List<GFA_ProjectRoster> projectRosters;
    private List<GFA_Note> notes;
    private List<GFA_Attachment> attachments;

    public GFA_Project__c obj {
        get {
            return (GFA_Project__c)mObj;
        }
    }

    public GFA_Project() {
        this(new GFA_Project__c());
    }

    public GFA_Project(GFA_Project__c project) {
        super(project);
        projectPhases = new List<GFA_ProjectPhase>();
        projectRosters = new List<GFA_ProjectRoster>();
        notes = new List<GFA_Note>();
        attachments = new List<GFA_Attachment>();
    }

    public void setProjectPhases(List<GFA_ProjectPhase> phases) {
        projectPhases = phases;
    }
    public List<GFA_ProjectPhase> getProjectPhases() {
        return projectPhases;
    }

    public String getName() {
        return obj.Name;
    }

    public String getProjectName() {
        return obj.Project_Name__c;
    }

    public void setProjectName(String Name) {
        obj.Project_Name__c = Name;
    }

    public Id getTemplateId() {
        return obj.Template__c;
    }
    public void setTemplateId(Id Template) {
        obj.Template__c = Template;
    }

    public Boolean getCanSelectTemplate() {
        return String.isBlank(getTemplateId())
               && String.isNotBlank(getGroup())
               && String.isNotBlank(getOperatingGroup())
               && String.isNotBlank(getProjectSponsor())
               && getCreatedById() == GFA_User.getCurrentUser().getId();
    }

    public String getGroup() {
        return obj.Group__c;
    }
    public void setGroup(String Groupg) {
        obj.Group__c = Groupg;
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

    public String getProjectSponsor() {
        return obj.Project_Sponsor__c;
    }
    public void setProjectSponsor(String ProjectSponsor) {
        obj.Project_Sponsor__c = ProjectSponsor;
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

    public void setProjectRosters(List<GFA_ProjectRoster> rosters) {
        projectRosters = rosters;
    }

    public List<GFA_ProjectRoster> getProjectRosters() {
        return projectRosters;
    }

    public List<GFA_Note> getNotes() {
        return notes;
    }

    public void setNotes(List<GFA_Note> newNotes) {
        notes = newNotes;
    }

    public List<GFA_Attachment> getAttachments() {
        return attachments;
    }
    public void setAttachments(List<GFA_Attachment> newAttachments) {
        attachments = newAttachments;
    }

    public String getLifecycleStage() {
        return obj.Lifecycle_Stage__c;
    }
    public void setLifecycleStage(String  lifecycleStage) {
        obj.Lifecycle_Stage__c = lifecycleStage;
    }

    public String getProjectStatus() {
        return obj.Project_Status__c;
    }
    public void setProjectStatus(String  projectStatus) {
        obj.Project_Status__c = projectStatus;
    }

    public String getComplexity() {
        return obj.Complexity__c;
    }
    public void setComplexity(String Complexity) {
        obj.Complexity__c = Complexity;
    }

    public String getRosterUserList() {
        return obj.Roster_User_List__c;
    }
    public void setRosterUserList(String RosterUserList) {
        obj.Roster_User_List__c = RosterUserList;
    }

    public Id getCreatedById() {
        return obj.CreatedById;
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            Set<String> additionalFields = new Set<String> {
                'Client_Contact__r.Phone',
                'Client_Contact__r.Email',
                'Contractor_Contact__r.Phone',
                'Contractor_Contact__r.Email'
            };
            addFields(additionalFields);
        }

        public GFA_Project findById(Id projectId) {
            GFA_Project__c project = (GFA_Project__c)byId(projectId);
            return new GFA_Project(project);
        }

        public List<GFA_Project> findByIds(Set<Id> projectIds) {
            List<GFA_Project> projects = new List<GFA_Project>();
            for (GFA_Project__c project : (List<GFA_Project__c>)Database.query(getSelect() +
                    ' where Id IN: projectIds')) {
                projects.add(new GFA_Project(project));
            }
            return projects;
        }
    }
}