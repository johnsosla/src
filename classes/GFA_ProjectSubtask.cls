/*******************************************************************************
*
* PURPOSE: Decorator for GFA_Project_Subtask__c object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
public with sharing class GFA_ProjectSubtask extends GFA_BaseModel {

    public static final String IMPACT_LEVEL_CRITICAL = 'Critical';
    public static final String IMPACT_LEVEL_NORMAL = 'Normal';

    public static final String STATUS_NOT_STARTED = 'Not Started';
    public static final String STATUS_IN_PROGRESS = 'In Progress';
    public static final String STATUS_READY_FOR_REVIEW = 'Ready for Review';
    public static final String STATUS_COMPLETED = 'Completed';

    public static final Integer CRITICAL_WEIGHT = 4;
    public static final Integer NORMAL_WEIGHT = 1;

    public static final String ADDED_BY_MANUAL = 'Manual Add';
    public static final String ADDED_BY_TEMPLATE = 'Template';

    public static final String RISK_LEVEL_LOW = 'Low';
    public static final String RISK_LEVEL_MEDIUM = 'Medium';
    public static final String RISK_LEVEL_HIGH = 'High';

    public static Finder find = new Finder('GFA_Project_Subtask__c');
    private List<GFA_LibrarySubtaskVersion> projectLibrarySubtaskVersions;
    private List<GFA_ProjectDeliverable> projectDeliverables;

    public GFA_Project_Subtask__c obj {
        get {
            return (GFA_Project_Subtask__c)mObj;
        }
    }

    public GFA_ProjectSubtask() {
        this(new GFA_Project_Subtask__c());
    }

    public GFA_ProjectSubtask(GFA_Project_Subtask__c projectSubtask) {
        super(projectSubtask);
        projectLibrarySubtaskVersions = new List<GFA_LibrarySubtaskVersion>();
        projectDeliverables = new List<GFA_ProjectDeliverable>();
    }

    public GFA_ProjectSubtask(GFA_LibrarySubtaskVersion libSubVersion) {
        this(new GFA_Project_Subtask__c());
        mObj.putSObject('Library_Subtask_Version__r', libSubVersion.getObj());
        setLibrarySubtaskVersionId(libSubVersion.getId());
    }

    public Id getLibrarySubtaskId() {
        return obj.Library_Subtask_Version__r.Library_Subtask__c;
    }

    public Id getLibrarySubtaskVersionId() {
        return obj.Library_Subtask_Version__c;
    }
    public void setLibrarySubtaskVersionId(Id librarySubtaskVersion) {
        obj.Library_Subtask_Version__c = librarySubtaskVersion;
    }

    public Id getProjectTaskId() {
        return obj.Project_Task__c;
    }
    public void setProjectTaskId(Id ProjectTask) {
        obj.Project_Task__c = ProjectTask;
    }

    public Id getProjectId() {
        return obj.Project_Task__r.Project_Phase__r.GFA_Project__c;
    }

    public void setLibrarySubtaskVersions(List<GFA_LibrarySubtaskVersion> librarySubtaskVersions) {
        projectLibrarySubtaskVersions = librarySubtaskVersions;
    }
    public List<GFA_LibrarySubtaskVersion> getLibrarySubtaskVersions() {
        return projectLibrarySubtaskVersions;
    }

    public String getStatus() {
        return obj.Status__c;
    }
    public void setStatus(String status) {
        obj.Status__c = status;
    }

    public String getName() {
        return obj.Name;
    }

    public String getLibrarySubtaskName() {
        return obj.Library_Subtask_Version__r.Library_Subtask__r.Name;
    }

    public String getAddedBy() {
        return obj.Added_By__c;
    }
    public void setAddedBy(String AddedBy) {
        obj.Added_By__c = AddedBy;
    }

    public String getImpactLevel() {
        return obj.Library_Subtask_Version__r.Impact_Level__c;
    }

    public Boolean getIsCritical() {
        return getImpactLevel() == IMPACT_LEVEL_CRITICAL;
    }

    public Boolean getIsManualAdd() {
        return getAddedBy() == ADDED_BY_MANUAL;
    }

    public Boolean getIsApplicable() {
        return obj.Is_Applicable__c;
    }
    public void setIsApplicable(Boolean IsApplicable) {
        obj.Is_Applicable__c = IsApplicable;
    }

    public Boolean getIsCriticalOverride() {
        return obj.Is_Critical_Override__c;
    }
    public void setIsCriticalOverride(Boolean IsCriticalOverride) {
        obj.Is_Critical_Override__c = IsCriticalOverride;
    }

    public Boolean getIsPMVisible() {
        return obj.Is_PM_Visible__c;
    }
    public void setIsPMVisible(Boolean IsPMVisible) {
        obj.Is_PM_Visible__c = IsPMVisible;
    }

    public Date getDueDate() {
        return (Date)obj.Due_Date_Formula__c;
    }
    
    public Date getCompletionDate() {
        return (Date)obj.Completion_Date__c;
    }
    public void setCompletionDate(Date CompletionDate) {
        obj.Completion_Date__c = CompletionDate;
    }

    public Decimal getDaysRemaining() {
        return obj.Days_Remaining__c;
    }

    public Decimal getSequence() {
        return obj.Sequence__c;
    }
    public void setSequence(Decimal sequence) {
        obj.Sequence__c = sequence;
    }

    public String getDiscipline() {
        return obj.Library_Subtask_Version__r.Discipline__c;
    }

    public String getScopeOfService() {
        return obj.Library_Subtask_Version__r.Scope_Of_Service__c;
    }

    public String getRiskLevel() {
        return obj.Library_Subtask_Version__r.Risk_Level__c;
    }

    public void setProjectDeliverables(List<GFA_ProjectDeliverable> projDeliverables) {
        projectDeliverables = projDeliverables;
    }
    public List<GFA_ProjectDeliverable> getProjectDeliverables() {
        return projectDeliverables;
    }

    public Boolean getIsSubtaskCompleted() {
        return getStatus() == STATUS_COMPLETED;
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            Set<String> librarySubtaskVersionFields = GFA_LibrarySubtaskVersion.find.getFieldSet();
            Set<String> librarySubtaskFields = GFA_LibrarySubtask.find.getFieldSet();
            Set<String> additionalFields = new Set<String>();
            for (String libField : librarySubtaskVersionFields) {
                additionalFields.add('Library_Subtask_Version__r.' + libField);
            }
            for (String libSubtaskField : librarySubtaskFields) {
                additionalFields.add('Library_Subtask_Version__r.Library_Subtask__r.' + libSubtaskField);
            }
            additionalFields.add('Project_Task__r.Project_Phase__r.GFA_Project__c');
            addFields(additionalFields);
        }

        public GFA_ProjectSubtask findById(Id projSubtaskId) {
            GFA_Project_Subtask__c projSubtask = (GFA_Project_Subtask__c)byId(projSubtaskId);
            return new GFA_ProjectSubtask(projSubtask);
        }

        public List<GFA_ProjectSubtask> findByProjectTaskId(Id projectTaskId) {
            List<GFA_ProjectSubtask> projectSubtasks = new List<GFA_ProjectSubtask>();
            for (GFA_Project_Subtask__c projectSubtask : (List<GFA_Project_Subtask__c>)getSelectWhere('Project_Task__c', projectTaskId)) {
                projectSubtasks.add(new GFA_ProjectSubtask(projectSubtask));
            }
            return projectSubtasks;
        }

        public List<GFA_ProjectSubtask> findByCriteria(GFA_ProjectSubtaskCriteria criteria) {
            String whereClause = criteria.getWhereClause();
            GFA_DebugUtils.log('whereClause', whereClause);
            List<GFA_ProjectSubtask> projSubtasks = new List<GFA_ProjectSubtask>();
            for (GFA_Project_Subtask__c subtask : (List<GFA_Project_Subtask__c>)Database.query(getSelect() +
                    whereClause + ' ORDER BY Sequence__c ASC')) {
                projSubtasks.add(new GFA_ProjectSubtask(subtask));
            }
            return projSubtasks;
        }

        public Map<Id, List<GFA_ProjectSubtask>> findByProjectTaskIds(Set<Id> projectIds) {
            Map<Id, List<GFA_ProjectSubtask>> taskSubMap = new Map<Id, List<GFA_ProjectSubtask>>();
            for (GFA_Project_Subtask__c subtask : (List<GFA_Project_Subtask__c>)Database.query(
                        getSelect() + ' Where Project_Task__c IN: projectIds')) {
                Id key = subtask.Project_Task__c;
                if (taskSubMap.containsKey(key)) {
                    taskSubMap.get(key).add(new GFA_ProjectSubtask(subtask));
                } else {
                    taskSubMap.put(key, new List<GFA_ProjectSubtask> {
                        new GFA_ProjectSubtask(subtask)
                    }
                                  );
                }
            }
            return taskSubMap;
        }

        public Map<Id, List<GFA_ProjectSubtask>> findByProjectTaskIds(List<GFA_ProjectTask> tasks) {
            Set<Id> ids = new Set<Id>();
            for (GFA_ProjectTask task : tasks) {
                ids.add(task.getId());
            }
            return findByProjectTaskIds(ids);
        }

        public Map<Id, List<GFA_ProjectSubtask>> findByProjectPhaseIds(Set<Id> phaseIds) {
            Map<Id, List<GFA_ProjectSubtask>> subtaskMap = new Map<Id, List<GFA_ProjectSubtask>>();
            for (GFA_Project_Subtask__c subtask : Database.query(getSelect() + ' where '
                    + 'Project_Task__r.Project_Phase__c IN: phaseIds')) {
                Id key = subtask.Project_Task__r.Project_Phase__c;
                if (subtaskMap.containsKey(key)) {
                    subtaskMap.get(key).add(new GFA_ProjectSubtask(subtask));
                } else {
                    subtaskMap.put(key, new List<GFA_ProjectSubtask> {new GFA_ProjectSubtask(subtask)});
                }
            }
            return subtaskMap;
        }

        public Map<Id, List<GFA_ProjectSubtask>> findByProjectPhaseIds(List<GFA_ProjectPhase> phases) {
            Set<Id> ids = new Set<Id>();
            for (GFA_ProjectPhase phase : phases) {
                ids.add(phase.getId());
            }
            return findByProjectPhaseIds(ids);
        }

        public Map<Id, List<GFA_ProjectSubtask>> findByProjectIds(Set<Id> projectIds) {
            Map<Id, List<GFA_ProjectSubtask>> subtaskMap = new Map<Id, List<GFA_ProjectSubtask>>();
            for (GFA_Project_Subtask__c subtask : (List<GFA_Project_Subtask__c>)Database.query(
                        getSelect() + ' where Project_Task__r.Project_Phase__r.GFA_Project__c IN : projectIds')) {
                Id key = subtask.Project_Task__r.Project_Phase__r.GFA_Project__c;
                if (subtaskMap.containsKey(key)) {
                    subtaskMap.get(key).add(new GFA_ProjectSubtask(subtask));
                } else {
                    subtaskMap.put(key, new List<GFA_ProjectSubtask> {new GFA_ProjectSubtask(subtask)});
                }
            }
            return subtaskMap;
        }
    }
}