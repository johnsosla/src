public abstract with sharing class GFA_TemplateTreeBaseController extends GFA_BaseController {

    public GFA_Template template {get; set;}

    public GFA_TemplateTreeBaseController(ApexPages.StandardController sc) {
        template = GFA_Template.find.findById(sc.getId());
        setupTemplate();
    }

    /**
    * Setups up the template by finding all related phases, tasks, subtasks
    **/
    protected void setupTemplate() {
        List<GFA_TemplatePhase> templatePhases = GFA_TemplatePhase.find.findByTemplateId(
                    template.getId());

        Map<Id, List<GFA_TemplateTask>> phasesToTaskMap = GFA_TemplateTask.find.findByPhaseIds(
                    templatePhases);

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

        for (GFA_TemplatePhase phase : templatePhases) {
            if (phasesToTaskMap.containsKey(phase.getId())) {
                phase.setTemplateTasks(phasesToTaskMap.get(phase.getId()));
            }
        }

        template.setTemplatePhases(templatePhases);
    }
}