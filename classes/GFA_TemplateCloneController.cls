public with sharing class GFA_TemplateCloneController {
    public GFA_Template template {get; set;}
	public GFA_TemplateCloneController(ApexPages.StandardController sc) {
	   template = GFA_Template.find.findById(sc.getId());

       template.setStatus('Pending');
       template.setDatePublished(null);
       List<GFA_TemplatePhase> phases = GFA_TemplatePhase.find.findByTemplateId(template.getId());

        Map<Id, List<GFA_TemplateTask>> phasesToTaskMap = GFA_TemplateTask.find.findByPhaseIds(
                    phases);

        List<GFA_TemplateTask> allTasks = new List<GFA_TemplateTask>();
        for (Id key : phasesToTaskMap.keySet()) {
            allTasks.addAll(phasesToTaskMap.get(key));
        }

        Map<Id, List<GFA_TemplateSubtask>> taskSubMap = GFA_TemplateSubtask.find.findByTaskIds(
                    allTasks);

        //Start adding subtasks to task, task to phases, and phases to template
        for (GFA_TemplateTask task : allTasks) {
            if (taskSubMap.containsKey(task.getId())) {
                task.setTemplateSubtasks(taskSubMap.get(task.getId()));
            }
        }

        for (GFA_TemplatePhase phase : phases) {
            if (phasesToTaskMap.containsKey(phase.getId())) {
                phase.setTemplateTasks(phasesToTaskMap.get(phase.getId()));
            }
        }

         for (GFA_TemplatePhase phase : phases) {
            for (GFA_TemplateTask task : phase.getTemplateTasks()) {
            }
        }
        template.setTemplatePhases(phases);
	}

    public PageReference saveTemplate() {
        List<GFA_BaseModel> models = new List<GFA_BaseModel>();

        GFA_Template newTemplate = new GFA_Template();

        newTemplate = template;
        GFA_Template clonedTemplate = new GFA_Template((GFA_Template__c)newTemplate.getObj().clone(false, true));
        models.add(clonedTemplate);
        GFA_BaseModel.save(models);

        models.clear();

       //// add logic to copy over phase, task and subtask

       List<GFA_TemplatePhase> newPhases = new List<GFA_TemplatePhase>();
        for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
            GFA_TemplatePhase newPhase = new GFA_TemplatePhase();
            newPhase = phase;
            GFA_TemplatePhase clonedPhase = new GFA_TemplatePhase((GFA_Template_Phase__c)newPhase.getObj().clone(false, true)); //do a deep clone
            clonedPhase.setTemplateId(clonedTemplate.getId());
            clonedPhase.setTemplateTasks(phase.getTemplateTasks());
            newPhases.add(clonedPhase);
        }

        models.addAll((List<GFA_BaseModel>)newPhases);

        GFA_BaseModel.save(models);
        models.clear();

       List<GFA_TemplateTask> newTasks = new List<GFA_TemplateTask>();

        for(GFA_TemplatePhase newPhase : newPhases){
            for(GFA_TemplateTask task : newPhase.getTemplateTasks()){
                GFA_TemplateTask newTask  = new GFA_TemplateTask();
                newTask = task;
                GFA_TemplateTask clonedTask = new GFA_TemplateTask((GFA_Template_Task__c)newTask.getObj().clone(false, true)); //do a deep clone
                clonedTask.setTemplatePhaseId(newPhase.getId());
                clonedTask.setTemplateSubtasks(task.getTemplateSubtasks());
                newTasks.add(clonedTask);
            }
        }

        models.addAll((List<GFA_BaseModel>)newTasks);
        GFA_BaseModel.save(models);
        models.clear();

        List<GFA_TemplateSubtask> newSubtasks = new List<GFA_TemplateSubtask>();

        for(GFA_TemplateTask newTask : newTasks){
            for(GFA_TemplateSubtask subtask : newTask.getTemplateSubtasks()){
                GFA_TemplateSubtask newSubtask  = new GFA_TemplateSubtask();
                newSubtask = subtask;
                GFA_TemplateSubtask clonedSubtask = new GFA_TemplateSubtask((GFA_Template_Subtask__c)newSubtask.getObj().clone(false, true)); //do a deep clone
                clonedSubtask.setTemplateTaskId(newTask.getId());
                newSubtasks.add(clonedSubtask);
            }
        }

        models.addAll((List<GFA_BaseModel>)newSubtasks);
        GFA_BaseModel.save(models);
        models.clear();

        return new PageReference('/' +clonedTemplate.getId());
    }

     public PageReference cancel() {
        return new PageReference('/' +template.getId());
    }
}