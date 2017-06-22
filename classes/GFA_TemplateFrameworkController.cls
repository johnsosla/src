public with sharing class GFA_TemplateFrameworkController extends GFA_TemplateTreeBaseController {

    public GFA_FilterManager Filter {get; set;}

    public GFA_TemplateFrameworkController(ApexPages.StandardController sc) {
        super(sc);
        setupFilter();
    }

    private void setupFilter() {
        Filter = new GFA_FilterManager();
        Filter.subtask = new GFA_Library_Subtask__c();

        if (String.isNotBlank(CurrentUser.getParameters())) {
            Filter = CurrentUser.getParametersAsFilterManager();
            Filter.subtask.Scope_Of_Service__c = Filter.ScopeOfService;
            Filter.subtask.Operating_Group__c = Filter.OperatingGroup;
            Filter.subtask.Business_Line__c = Filter.BusinessLine;
        }
        Filter.setupLibrarySubtaskFilters();
    }

    public PageReference refreshTemplateSubtasks() {
        setupTemplate();
        if (!Filter.IsFilterBlank()) {
            Set<Id> libSubtaskIds = new Set<Id>();
            for (GFA_LibrarySubtask subtask : Filter.getLibrarySubtasksByCriteria()) {
                libSubtaskIds.add(subtask.getId());
            }

            for (Integer j = template.getTemplatePhases().size() - 1; j > -1; j--) {
                GFA_TemplatePhase phase = template.getTemplatePhases()[j];
                for (Integer k = phase.getTemplateTasks().size() - 1; k > -1; k-- ) {
                    GFA_TemplateTask task = phase.getTemplateTasks()[k];
                    for (Integer i = task.getTemplateSubtasks().size() - 1; i > -1; i-- ) {
                        GFA_TemplateSubtask subtask = task.getTemplateSubtasks()[i];
                        if (!libSubtaskIds.contains(subtask.getLibrarySubtaskId())) {
                            task.getTemplateSubtasks().remove(i);
                        }
                    }
                    if (task.getTemplateSubtasks().isEmpty()) {
                        phase.getTemplateTasks().remove(k);
                    }
                }
                if (phase.getTemplateTasks().isEmpty()) {
                    template.getTemplatePhases().remove(j);
                }
            }
        }

        CurrentUser.setParameters(Filter);
        CurrentUser.save();

        return null;
    }

    public void clearFilter() {
        Filter = new GFA_FilterManager();
        Filter.subtask = new GFA_Library_Subtask__c();
        Filter.setupLibrarySubtaskFilters();
        refreshTemplateSubtasks();
    }
}