public with sharing class GFA_TemplateTask extends GFA_BaseModel {

    public static Finder find = new Finder('GFA_Template_Task__c');

    public GFA_Template_Task__c obj {
        get {
            return (GFA_Template_Task__c)mObj;
        }
    }

    private List<GFA_TemplateSubtask> templateSubtasks;

    public GFA_TemplateTask() {
        this(new GFA_Template_Task__c());
    }

    public GFA_TemplateTask(GFA_Template_Task__c tempTask) {
        super(tempTask);
        templateSubtasks = new List<GFA_TemplateSubtask>();
    }

    public GFA_TemplateTask(GFA_LibraryTask libTask) {
        this(new GFA_Template_Task__c());
        mObj.putSObject('Library_Task__r', libTask.obj);
        setLibraryTaskId(libTask.getId());
    }

    public Id getLibraryTaskId() {
        return obj.Library_Task__c;
    }
    public void setLibraryTaskId(Id LibraryTask) {
        obj.Library_Task__c = LibraryTask;
    }

    public Id getTemplatePhaseId() {
        return obj.Template_Phase__c;
    }
    public void setTemplatePhaseId(Id TemplatePhase) {
        obj.Template_Phase__c = TemplatePhase;
    }

    public Id getTemplateId() {
        return obj.Template_Phase__r.Template__c;
    }

    public void setTemplateSubtasks(List<GFA_TemplateSubtask> subtasks) {
        templateSubtasks = subtasks;
    }
    public List<GFA_TemplateSubtask> getTemplateSubtasks() {
        return templateSubtasks;
    }

    public String getLibraryTaskName() {
        return obj.Library_Task__r.Name;
    }

    public Decimal getSequence() {
        return obj.Sequence__c;
    }
    public void setSequence(Decimal Sequence) {
        obj.Sequence__c = Sequence;
    }

    public String getName() {
        return obj.Name;
    }


    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            Set<String> libraryTaskFields = GFA_LibraryTask.find.getFieldSet();
            Set<String> additionalFields = new Set<String>();
            for (String libField : libraryTaskFields) {
                additionalFields.add('Library_Task__r.' + libField);
            }
            additionalFields.add('Template_Phase__r.Template__c');
            addFields(additionalFields);
        }

        public Map<Id, List<GFA_TemplateTask>> findByPhaseIds(Set<Id> phaseIds) {
            Map<Id, List<GFA_TemplateTask>> phaseTaskMap = new Map<Id, List<GFA_TemplateTask>>();
            Set<String> ids = new Set<String>();
            for (Id phaseId : phaseIds) {
                ids.add(phaseId);
            }
            for (GFA_Template_Task__c task : (List<GFA_Template_Task__c>)Database.query(getSelect()
                    + ' where Template_Phase__c IN: ids ORDER BY Sequence__c ASC')) {
                Id key = task.Template_Phase__c;
                if (phaseTaskMap.containsKey(key)) {
                    phaseTaskMap.get(key).add(new GFA_TemplateTask(task));
                } else {
                    phaseTaskMap.put(key, new List<GFA_TemplateTask> {new GFA_TemplateTask(task)});
                }
            }
            return phaseTaskMap;
        }

        public Map<Id, List<GFA_TemplateTask>> findByPhaseIds(List<GFA_TemplatePhase> phases) {
            Map<Id, List<GFA_TemplateTask>> phaseTaskMap = new Map<Id, List<GFA_TemplateTask>>();
            Set<Id> ids = new Set<Id>();
            for (GFA_TemplatePhase phase : phases) {
                ids.add(phase.getId());
            }
            return findByPhaseIds(ids);
        }

        public GFA_TemplateTask findById(Id templateTaskId) {
            GFA_Template_Task__c templateTask = (GFA_Template_Task__c)byId(templateTaskId);
            return new GFA_TemplateTask(templateTask);
        }
    }
}