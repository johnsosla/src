public with sharing class GFA_TemplateSubtask extends GFA_BaseModel implements Comparable {

    public static Finder find = new Finder('GFA_Template_Subtask__c');
    private List<GFA_LibrarySubtask> templateLibrarySubtasks;


    public GFA_Template_Subtask__c obj {
        get {
            return (GFA_Template_Subtask__c)mObj;
        }
    }

    public GFA_TemplateSubtask() {
        this(new GFA_Template_Subtask__c());
    }

    public GFA_TemplateSubtask(GFA_Template_Subtask__c tempSubtask) {
        super(tempSubtask);
        templateLibrarySubtasks = new List<GFA_LibrarySubtask>();
    }

    public GFA_TemplateSubtask(GFA_LibrarySubtask libSubtask) {
        this(new GFA_Template_Subtask__c());
        mObj.putSObject('Library_Subtask__r', libSubtask.getObj());
        setLibrarySubtaskId(libSubtask.getId());
    }

    public Id getLibrarySubtaskId() {
        return obj.Library_Subtask__c;
    }
    public void setLibrarySubtaskId(Id LibrarySubtask) {
        obj.Library_Subtask__c = LibrarySubtask;
    }

    public Id getTemplateTaskId() {
        return obj.Template_Task__c;
    }
    public void setTemplateTaskId(Id TemplateTask) {
        obj.Template_Task__c = TemplateTask;
    }

    public Id getTemplatePhaseId() {
        return obj.Template_Task__r.Template_Phase__c;
    }

    public Id getTemplateId() {
        return obj.Template_Task__r.Template_Phase__r.Template__c;
    }

    public String getLibrarySubtaskName() {
        return obj.Library_Subtask__r.Name;
    }

    public Decimal getSequence() {
        return (Decimal)mObj.get('Sequence__c');
    }
    public void setSequence(Decimal Sequence) {
        mObj.put('Sequence__c', Sequence);
    }

    public String getName() {
        return obj.Name;
    }

    public void setLibrarySubtasks(List<GFA_LibrarySubtask> librarySubtasks) {
        templateLibrarySubtasks = librarySubtasks;
    }

    public List<GFA_LibrarySubtask> getLibrarySubtasks() {
        return templateLibrarySubtasks;
    }

    // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
        GFA_TemplateSubtask compareToSubtask = (GFA_TemplateSubtask)compareTo;
        if (getSequence() == compareToSubtask.getSequence()) return 0;
        if (getSequence() > compareToSubtask.getSequence()) return 1;
        return -1;
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            Set<String> librarySubtaskFields = GFA_LibrarySubtask.find.getFieldSet();
            Set<String> templateTaskFields = GFA_TemplateTask.find.getFieldSet();
            Set<String> additionalFields = new Set<String>();
            for (String libField : librarySubtaskFields) {
                additionalFields.add('Library_Subtask__r.' + libField);
            }
            for (String libField : templateTaskFields) {
                additionalFields.add('Template_Task__r.' + libField);
            }
            additionalFields.add('Template_Task__r.Template_Phase__r.Template__c');
            addFields(additionalFields);
        }

        public Map<Id, List<GFA_TemplateSubtask>> findByTaskIds(Set<Id> taskIds) {
            Map<Id, List<GFA_TemplateSubtask>> taskSubMap = new Map<Id, List<GFA_TemplateSubtask>>();
            Set<String> ids = new Set<String>();
            for (Id taskId : taskIds) {
                ids.add(taskId);
            }
            for (GFA_Template_Subtask__c subtask : (List<GFA_Template_Subtask__c>)Database.query(
                        getSelect() + ' where Template_Task__c IN: ids ORDER BY Sequence__c ASC')) {
                Id key = subtask.Template_Task__c;
                if (taskSubMap.containsKey(key)) {
                    taskSubMap.get(key).add(new GFA_TemplateSubtask(subtask));
                } else {
                    taskSubMap.put(key, new List<GFA_TemplateSubtask> {
                        new GFA_TemplateSubtask(subtask)
                    }
                                  );
                }
            }
            return taskSubMap;
        }

        public Map<Id, List<GFA_TemplateSubtask>> findByTaskIds(List<GFA_TemplateTask> tasks) {
            Map<Id, List<GFA_TemplateSubtask>> taskSubMap = new Map<Id, List<GFA_TemplateSubtask>>();
            Set<Id> ids = new Set<Id>();
            for (GFA_TemplateTask task : tasks) {
                ids.add(task.getId());
            }
            return findByTaskIds(ids);
        }

        public GFA_TemplateSubtask findById(Id templateSubtaskId) {
            GFA_Template_Subtask__c templateSubtask = (GFA_Template_Subtask__c)byId(templateSubtaskId);
            return new GFA_TemplateSubtask(templateSubtask);
        }

        public List<GFA_TemplateSubtask> findByTaskId(Id taskId) {
            List<GFA_TemplateSubtask> subtasks = new List<GFA_TemplateSubtask>();
            for (GFA_Template_Subtask__c subtask : (List<GFA_Template_Subtask__c>)getSelectWhere('Template_Task__c', taskId)) {
                subtasks.add(new GFA_TemplateSubtask(subtask));
            }
            return subtasks;
        }
    }
}