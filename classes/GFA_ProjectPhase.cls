/*******************************************************************************
*
* PURPOSE: Decorator for GFA_Project_Phase__c object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
public with sharing class GFA_ProjectPhase extends GFA_BaseModel {

    public static final String PHASE_STATUS_NOT_STARTED = 'Not Started';
    public static final String PHASE_STATUS_IN_PROGRESS = 'In Progress';
    public static final String PHASE_STATUS_COMPLETED = 'Completed';
    public static final String PHASE_STATUS_APPROVED = 'Approved';

    public String subtaskCompletedCount {get; set;}


    public static Finder find = new Finder('GFA_Project_Phase__c');
    private List<GFA_ProjectTask> projectTasks;

    public Integer NumberOfSubtasks {get; set;}
    public Integer NumberOfCriticals {get; set;}

    public GFA_Project_Phase__c obj {
        get {
            return (GFA_Project_Phase__c)mObj;
        }
    }

    public GFA_ProjectPhase() {
        this(new GFA_Project_Phase__c());
    }

    public GFA_ProjectPhase(GFA_Project_Phase__c projectPhase) {
        super(projectPhase);
        projectTasks = new List<GFA_ProjectTask>();
        NumberOfSubtasks = 0;
        NumberOfCriticals = 0;
    }

    public GFA_ProjectPhase(GFA_LibraryPhase libPhase) {
        this(new GFA_Project_Phase__c());
        mObj.putSObject('Library_Phase__r', libPhase.obj);
        setLibraryPhaseId(libPhase.getId());
    }

    public void setProjectTasks(List<GFA_ProjectTask> projectTasks) {
        this.projectTasks = projectTasks;
        calculateSubtaskCompleted(projectTasks);
    }
    public List<GFA_ProjectTask> getProjectTasks() {
        return projectTasks;
    }

    public String getName() {
        return obj.Name;
    }

    public String getLibraryPhaseName() {
        return obj.Library_Phase__r.Name;
    }

    public Id getLibraryPhaseId() {
        return obj.Library_Phase__c;
    }
    public void setLibraryPhaseId(Id LibraryPhase) {
        obj.Library_Phase__c = LibraryPhase;
    }

    public Id getProjectId() {
        return obj.GFA_Project__c;
    }
    public void setProjectId(Id Project) {
        obj.GFA_Project__c = Project;
    }

    public Decimal getSequence() {
        return obj.Sequence__c;
    }
    public void setSequence(Decimal Sequence) {
        obj.Sequence__c = Sequence;
    }

    public Decimal getDaysRemaining() {
        return obj.Days_Remaining__c;
    }

    public String getPhaseStatus() {
        return obj.Phase_Status__c;
    }

    public void setPhaseStatus(String status) {
        obj.Phase_Status__c = status;
    }

    public Date getActualCompletionDate() {
        return obj.Actual_Completion_Date__c;
    }
    public void setActualCompletionDate(Date actualCompletionDate) {
        obj.Actual_Completion_Date__c = actualCompletionDate;
    }

    public Date getScheduledCompletionDate() {
        return obj.Scheduled_Completion_Date__c;
    }
    public void setScheduledCompletionDate(Date scheduledCompletionDate) {
        obj.Scheduled_Completion_Date__c = scheduledCompletionDate;
    }

    public Date getForecastCompletionDate() {
        return obj.Forecast_Completion_Date__c;
    }
    public void setForecastCompletionDate(Date forecastCompletionDate) {
        obj.Forecast_Completion_Date__c = forecastCompletionDate;
    }

    public String getLibraryPhaseDescription() {
        return obj.Library_Phase__r.Description__c;
    }

    public void calculateSubtaskCompleted(List<GFA_ProjectTask> tasks) {
        subtaskCompletedCount = '0%';
        Integer totalCount = 0;
        Integer completedCount = 0;
        for (GFA_ProjectTask task : tasks) {
            task.calculateSubtaskCompleted(task.getProjectSubtasks());
            totalCount += task.totalCount;
            completedCount += task.completedCount;
        }
        if (totalCount > 0) {
            subtaskCompletedCount = String.valueOf((completedCount * 100) / totalCount) + '%';
        }
    }

    public String getSubtaskCompletedCount() {
        return subtaskCompletedCount;
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            Set<String> libraryPhaseFields = GFA_LibraryPhase.find.getFieldSet();
            Set<String> additionalFields = new Set<String>();
            for (String libField : libraryPhaseFields) {
                additionalFields.add('Library_Phase__r.' + libField);
            }
            addFields(additionalFields);
        }

        public GFA_ProjectPhase findById(Id projPhaseId) {
            GFA_Project_Phase__c projPhase = (GFA_Project_Phase__c)byId(projPhaseId);
            return new GFA_ProjectPhase(projPhase);
        }

        public List<GFA_ProjectPhase> findByIds(Set<Id> phaseIds) {
            List<GFA_ProjectPhase> phases = new List<GFA_ProjectPhase>();
            for (GFA_Project_Phase__c phase : Database.query(getSelect() + ' where Id IN: phaseIds')) {
                phases.add(new GFA_ProjectPhase(phase));
            }
            return phases;
        }

        public List<GFA_ProjectPhase> findByProjectId(Id projectId) {
            List<GFA_ProjectPhase> phases = new List<GFA_ProjectPhase>();
            for (GFA_Project_Phase__c phase : (List<GFA_Project_Phase__c>)Database.query(
                        getSelect() + ' where GFA_Project__c =: projectId')) {
                phases.add(new GFA_ProjectPhase(phase));
            }
            return phases;
        }

        public Map<Id, List<GFA_ProjectPhase>> findByProjectIds(List<GFA_Project> projects) {
            Map<Id, List<GFA_ProjectPhase>> projectPhaseMap = new Map<Id, List<GFA_ProjectPhase>>();
            Set<String> ids = new Set<String>();
            for (GFA_Project project : projects) {
                ids.add(project.getId());
            }
            for (GFA_Project_Phase__c phase : (List<GFA_Project_Phase__c>)Database.query(
                        getSelect() + ' Where GFA_Project__c IN: ids')) {
                Id key = phase.GFA_Project__c;
                if (projectPhaseMap.containsKey(key)) {
                    projectPhaseMap.get(key).add(new GFA_ProjectPhase(phase));
                } else {
                    projectPhaseMap.put(key, new List<GFA_ProjectPhase> {new GFA_ProjectPhase(phase)});
                }
            }
            return projectPhaseMap;
        }
    }
}