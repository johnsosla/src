/*******************************************************************************
*
* PURPOSE: Decorator for GFA_Project_Deliverable__c object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
public with sharing class GFA_ProjectDeliverable extends GFA_BaseModel {

    public static Finder find = new Finder('GFA_Project_Deliverable__c');

    public GFA_Project_Deliverable__c obj {
        get {
            return (GFA_Project_Deliverable__c)mObj;
        }
    }

    public GFA_ProjectDeliverable() {
        this(new GFA_Project_Deliverable__c());
    }

    public GFA_ProjectDeliverable(GFA_Project_Deliverable__c projectDeliverable) {
        super(projectDeliverable);
    }

    public String getName() {
        return obj.Name;
    }
    public void setName(String Name) {
        obj.Name = Name;
    }

    public Id getProjectSubtaskId() {
        return obj.Project_Subtask__c;
    }

    public String getProjectSubtaskName() {
        return obj.Project_Subtask__r.Library_Subtask_Version__r.Library_Subtask__r.Name;
    }

    public void setProjectSubtaskId(Id projectSubtaskId) {
        obj.Project_Subtask__c = projectSubtaskId;
    }

    public String getLink() {
        if (obj.Link__c != null && (!obj.Link__c.startsWith('https://') && !obj.Link__c.startsWith('http://'))) {
            return 'http://' + obj.Link__c;
        } else {
            return obj.Link__c;
        }
    }

    public void setLink(String link) {
        obj.Link__c = link;
    }

    public Boolean getHiddenDeliverable() {
        return obj.Hidden_Deliverable__c;
    }

    public Id getCreatedById() {
        return obj.CreatedById;
    }

    public Boolean getCanViewDeliverable() {
        return getCreatedById() == GFA_User.getCurrentUser().getId();
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            Set<String> projectSubtaskFields = GFA_ProjectSubtask.find.getFieldSet();
            Set<String> additionalFields = new Set<String>();
            for (String projField : projectSubtaskFields) {
                additionalFields.add('Project_Subtask__r.' + projField);
            }
            //additionalFields.add('Project_Subtask__r.Library_Subtask_Version__r.Library_Subtask__r.Name');
            addFields(additionalFields);
        }

        public GFA_ProjectDeliverable findById(Id projectDeliverableId) {
            GFA_Project_Deliverable__c projDeliverable = (GFA_Project_Deliverable__c)byId(projectDeliverableId);
            return new GFA_ProjectDeliverable(projDeliverable);
        }

        public List<GFA_ProjectDeliverable> findByProjectSubtaskId(Id projectSubtaskId) {
            List<GFA_ProjectDeliverable> projectDeliverables = new List<GFA_ProjectDeliverable>();
            for (GFA_Project_Deliverable__c projectDeliverable : (List<GFA_Project_Deliverable__c>)getSelectWhere('Project_Subtask__c', projectSubtaskId)) {
                projectDeliverables.add(new GFA_ProjectDeliverable(projectDeliverable));
            }
            return projectDeliverables;
        }

        public Map<Id, List<GFA_ProjectDeliverable>> findByProjectSubtaskIds(List<GFA_ProjectSubtask> subtasks) {
            Map<Id, List<GFA_ProjectDeliverable>> subtaskDeliverableMap = new Map<Id, List<GFA_ProjectDeliverable>>();
            Set<String> Ids = new Set<String>();
            for (GFA_ProjectSubtask subtask : subtasks) {
                ids.add(subtask.getId());
            }
            for (GFA_Project_Deliverable__c del : (List<GFA_Project_Deliverable__c>)Database.query(
                        getSelect() + ' where Project_Subtask__c IN: ids ORDER BY Project_Subtask__r.Sequence__c ASC')) {
                Id key = del.Project_Subtask__c;
                if (subtaskDeliverableMap.containsKey(key)) {
                    subtaskDeliverableMap.get(key).add(new GFA_ProjectDeliverable(del));
                } else {
                    subtaskDeliverableMap.put(key, new List<GFA_ProjectDeliverable> {
                        new GFA_ProjectDeliverable(del)
                    });
                }
            }
            return subtaskDeliverableMap;
        }

        public List<GFA_ProjectDeliverable> findByProjectId(Id projectId) {
            List<GFA_ProjectDeliverable> projectDeliverables = new List<GFA_ProjectDeliverable>();
            for (GFA_Project_Deliverable__c projectDeliverable : (List<GFA_Project_Deliverable__c>)
                    getSelectWhere('Project_Subtask__r.Project_Task__r.Project_Phase__r.GFA_Project__c', projectId)) {
                projectDeliverables.add(new GFA_ProjectDeliverable(projectDeliverable));
            }
            return projectDeliverables;
        }

    }
}