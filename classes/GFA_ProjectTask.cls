/*******************************************************************************
*
* PURPOSE: Decorator for GFA_Project_Task__c object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
public with sharing class GFA_ProjectTask extends GFA_BaseModel {

    public String subtaskCompletedCount {get; set;}
    public Integer totalCount {get; set;}
    public Integer completedCount {get; set;}

    public static Finder find = new Finder('GFA_Project_Task__c');
    private List<GFA_ProjectSubtask> projectSubtasks;

    public GFA_Project_Task__c obj {
        get {
            return (GFA_Project_Task__c)mObj;
        }
    }

    public GFA_ProjectTask() {
        this(new GFA_Project_Task__c());
    }

    public GFA_ProjectTask(GFA_Project_Task__c projectTask) {
        super(projectTask);
        projectSubtasks = new List<GFA_ProjectSubtask>();
    }

    public GFA_ProjectTask(GFA_LibraryTask libTask) {
        this(new GFA_Project_Task__c());
        mObj.putSObject('Library_Task__r', libTask.obj);
        setLibraryTaskId(libTask.getId());
    }

    public void setProjectSubtasks(List<GFA_ProjectSubtask> subtasks) {
        projectSubtasks = subtasks;
        calculateSubtaskCompleted(subtasks);
    }

    public List<GFA_ProjectSubtask> getProjectSubtasks() {
        return projectSubtasks;
    }

    public Id getProjectId() {
        return obj.Project_Phase__r.GFA_Project__c;
    }

    public Id getProjectPhaseId() {
        return obj.Project_Phase__c;
    }
    public void setProjectPhaseId(Id projectPhase) {
        obj.Project_Phase__c = projectPhase;
    }

    public String getLibraryTaskName() {
        return obj.Library_Task__r.Name;
    }

    public Id getLibraryTaskId() {
        return obj.Library_Task__c;
    }
    public void setLibraryTaskId(Id LibraryTask) {
        obj.Library_Task__c = LibraryTask;
    }

    public String getName() {
        return obj.Name;
    }

    public Decimal getSequence() {
        return obj.Sequence__c;
    }
    public void setSequence(Decimal Sequence) {
        obj.Sequence__c = Sequence;
    }

    public void calculateSubtaskCompleted(List<GFA_ProjectSubtask> subtasks) {
        totalCount = 0;
        completedCount = 0;
        for (GFA_ProjectSubtask subtask : subtasks) {
            if (subtask.getImpactLevel() == GFA_ProjectSubtask.IMPACT_LEVEL_CRITICAL || subtask.getIsCriticalOverride()) {
                totalCount += GFA_ProjectSubtask.CRITICAL_WEIGHT;
                if (subtask.getIsSubtaskCompleted()) {
                    completedCount += GFA_ProjectSubtask.CRITICAL_WEIGHT;
                }
            } else if (subtask.getImpactLevel() == GFA_ProjectSubtask.IMPACT_LEVEL_NORMAL) {
                totalCount += GFA_ProjectSubtask.NORMAL_WEIGHT;
                if (subtask.getIsSubtaskCompleted()) {
                    completedCount += GFA_ProjectSubtask.NORMAL_WEIGHT;
                }
            }
        }
        subtaskCompletedCount = calculateSubtaskCompletedCount(completedCount, totalCount);
    }

    private String calculateSubtaskCompletedCount(Integer completedCount, Integer totalCount) {
        subtaskCompletedCount = '0%';
        if (totalCount > 0) {
            subtaskCompletedCount = String.valueOf((completedCount * 100) / totalCount) + '%';
        }
        return subtaskCompletedCount;
    }

    public String getSubtaskCompletedCount() {
        return subtaskCompletedCount;
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            Set<String> libraryTaskFields = GFA_LibraryTask.find.getFieldSet();
            Set<String> additionalFields = new Set<String>();
            for (String libField : libraryTaskFields) {
                additionalFields.add('Library_Task__r.' + libField);
            }
            additionalFields.add('Project_Phase__r.GFA_Project__c');
            addFields(additionalFields);
        }

        public GFA_ProjectTask findById(Id projTaskId) {
            GFA_Project_Task__c projTask = (GFA_Project_Task__c)byId(projTaskId);
            return new GFA_ProjectTask(projTask);
        }

        public Map<Id, List<GFA_ProjectTask>> findByProjectPhaseIds(List<GFA_ProjectPhase> phases) {
            Map<Id, List<GFA_ProjectTask>> phaseTaskMap = new Map<Id, List<GFA_ProjectTask>>();
            Set<String> ids = new Set<String>();
            for (GFA_ProjectPhase phase : phases) {
                ids.add(phase.getId());
            }
            for (GFA_Project_Task__c task : (List<GFA_Project_Task__c>)Database.query(
                        getSelect() + ' Where Project_Phase__c IN: ids ORDER BY Sequence__c ASC')) {
                Id key = task.Project_Phase__c;
                if (phaseTaskMap.containsKey(key)) {
                    phaseTaskMap.get(key).add(new GFA_ProjectTask(task));
                } else {
                    phaseTaskMap.put(key, new List<GFA_ProjectTask> {new GFA_ProjectTask(task)});
                }
            }
            return phaseTaskMap;
        }
    }
}