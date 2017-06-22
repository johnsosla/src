public with sharing class GFA_TemplateTreeEditController extends GFA_TemplateTreeBaseController {

    private transient List<GFA_LibraryPhase> mAvailableLibraryPhases;
    private transient List<GFA_LibraryTask> mAvailableLibraryTasks;
    private List<GFA_LibrarySubtask> mAvailableLibrarySubtasks;

    private List<GFA_TemplatePhase> mDeleteTemplatePhases;
    private List<GFA_TemplateTask> mDeleteTemplateTasks;
    private List<GFA_TemplateSubtask> mDeleteTemplateSubtasks;

    public String SelectedPhase {get; set;}
    public String SelectedTask {get; set;}
    public String SelectedPhaseName {get; set;}
    public String SelectedTaskName {get; set;}

    public GFA_FilterManager Filter {get; set;}

    public GFA_TemplateTreeEditController(ApexPages.StandardController sc) {
        super(sc);
        mDeleteTemplatePhases = new List<GFA_TemplatePhase>();
        mDeleteTemplateTasks = new List<GFA_TemplateTask>();
        mDeleteTemplateSubtasks = new List<GFA_TemplateSubtask>();
        setupFilter();
        setupPagination();
        refreshAvailableLibrarySubtasks();
    }

    private void setupFilter() {
        Filter = new GFA_FilterManager();
        Filter.subtask = new GFA_Library_Subtask__c();
        Filter.setupLibrarySubtaskFilters();
    }

    public override void readSelectedIdListFromPage() {
        for (GFA_LibrarySubtask subtask : mAvailableLibrarySubtasks) {
            if (subtask.IsSelected) {
                selectedIdList.add(subtask.getId());
            } else {
                selectedIdList.remove(subtask.getId());
            }
        }
    }

    public override void getCurrentPageResults() {
        Integer beginIndex = PAGE_SIZE * currentPage;
        Integer endIndex = (PAGE_SIZE * (currentPage + 1)) - 1;
        if (endIndex >= searchResultsIdList.size()) {
            endIndex = searchResultsIdList.size() - 1;
        }

        Set<Id> subList = new Set<Id>();

        for (Integer i = beginIndex; i <= endIndex; i++) {
            subList.add(searchResultsIdList.get(i));
        }

        mAvailableLibrarySubtasks = GFA_LibrarySubtask.find.findByIds(subList);
    }

    public override void populateSelectedIdListToPage() {
        for (GFA_LibrarySubtask subtask : mAvailableLibrarySubtasks) {
            if (selectedIdList.contains(subtask.getId())) {
                subtask.IsSelected = true;
            }
        }
    }

    public override PageReference checkAllAction() {
        for (GFA_LibrarySubtask subtask : mAvailableLibrarySubtasks) {
            subtask.IsSelected = CheckAll;
        }

        readSelectedIdListFromPage();

        return null;
    }

    public List<GFA_LibraryPhase> getAvailableLibraryPhases() {
        if (mAvailableLibraryPhases == null) {
            refreshAvailableLibraryPhases();
        }
        return mAvailableLibraryPhases;
    }

    public PageReference refreshAvailableLibraryPhases() {
        Set<Id> usedPhaseIds = new Set<Id>();
        for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
            usedPhaseIds.add(phase.getLibraryPhaseId());
        }
        mAvailableLibraryPhases = GFA_LibraryPhase.find.findByNotInIds(usedPhaseIds);
        return null;
    }

    public PageReference addLibraryPhase() {
        Decimal maxSequence = 0;
        Id libPhaseId = getParam('libId');
        GFA_TemplatePhase tempPhase = new GFA_TemplatePhase(GFA_LibraryPhase.find.findById(libPhaseId));
        for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
            if (maxSequence < phase.getSequence()) {
                maxSequence = phase.getSequence();
            }
        }

        tempPhase.setTemplateId(template.getId());
        tempPhase.setSequence(maxSequence + 1);
        template.getTemplatePhases().add(tempPhase);
        return null;
    }

    public PageReference removeTemplatePhase() {
        Id libPhaseId = getParam('libId');
        for (Integer i = template.getTemplatePhases().size() - 1; i > -1; i--) {
            if (template.getTemplatePhases()[i].getLibraryPhaseId() == libPhaseId) {
                GFA_TemplatePhase phase = template.getTemplatePhases().remove(i);
                if (phase.getId() != null) {
                    mDeleteTemplatePhases.add(phase);
                }
            }
        }
        return null;
    }

    public List<GFA_LibraryTask> getAvailableLibraryTasks() {
        if (mAvailableLibraryTasks == null) {
            refreshAvailableLibraryTasks();
        }
        return mAvailableLibraryTasks;
    }

    public PageReference refreshAvailableLibraryTasks() {
        Set<Id> usedTaskIds = new Set<Id>();
        for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
            for (GFA_TemplateTask task : phase.getTemplateTasks()) {
                usedTaskIds.add(task.getLibraryTaskId());
            }
        }
        mAvailableLibraryTasks = GFA_LibraryTask.find.findByNotInIds(usedTaskIds);
        return null;
    }

    public PageReference addLibraryTask() {
        Decimal maxSequence = 0;
        Id libTaskId = getParam('libTaskId');
        GFA_TemplateTask tempTask = new GFA_TemplateTask(GFA_LibraryTask.find.findById(libTaskId));
        for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
            if (phase.getLibraryPhaseId() == SelectedPhase) {
                for (GFA_TemplateTask task : phase.getTemplateTasks()) {
                    if (maxSequence < task.getSequence()) {
                        maxSequence = task.getSequence();
                    }
                }
            }
        }
        for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
            if (phase.getLibraryPhaseId() == SelectedPhase) {
                tempTask.setTemplatePhaseId(phase.getId());
                tempTask.setSequence(maxSequence + 1);
                phase.getTemplateTasks().add(tempTask);
            }
        }
        return null;
    }

    public PageReference removeTemplateTask() {
        Id libPhaseId = getParam('libPhaseId');
        Id libTaskId = getParam('libTaskId');
        for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
            if (phase.getLibraryPhaseId() == libPhaseId) {
                for (Integer i = phase.getTemplateTasks().size() - 1; i > -1; i--) {
                    if (phase.getTemplateTasks()[i].getLibraryTaskId() == libTaskId) {
                        GFA_TemplateTask task = phase.getTemplateTasks().remove(i);
                        //---Only add them to delete list if they have already been saved
                        if (task.getId() != null) {
                            mDeleteTemplateTasks.add(task);
                        }
                    }
                }
            }
        }
        return null;
    }

    public List<GFA_LibrarySubtask> getAvailableLibrarySubtasks() {
        return mAvailableLibrarySubtasks;
    }

    public PageReference refreshAvailableLibrarySubtasks() {
        setupPagination();
        Set<Id> usedSubtaskIds = new Set<Id>();
        for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
            for (GFA_TemplateTask task : phase.getTemplateTasks()) {
                for (GFA_TemplateSubtask subtask : task.getTemplateSubtasks()) {
                    usedSubtaskIds.add(subtask.getLibrarySubtaskId());
                }
            }
        }
        Filter.ExcludeIds = usedSubtaskIds;
        for (GFA_LibrarySubtask subtask : Filter.getLibrarySubtasksByCriteria()) {
            searchResultsIdList.add(subtask.getId());
        }
        getCurrentPageResults();
        return null;
    }

    public PageReference addLibrarySubtask() {
        readSelectedIdListFromPage();
        Decimal maxSequence = 0;
        Map<Id, GFA_LibrarySubtask> libMap = new Map<Id, GFA_LibrarySubtask>();
        mAvailableLibrarySubtasks = GFA_LibrarySubtask.find.findByIds(selectedIdList);
        for (GFA_LibrarySubtask libSubtask : mAvailableLibrarySubtasks) {
            libSubtask.IsSelected = true;
            libMap.put(libSubtask.getId(), libSubtask);
        }
        for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
            if (phase.getLibraryPhaseId() == SelectedPhase) {
                for (GFA_TemplateTask task : phase.getTemplateTasks()) {
                    if (task.getLibraryTaskId() == SelectedTask) {
                        for (GFA_TemplateSubtask subtask : task.getTemplateSubtasks()) {
                            if (maxSequence < subtask.getSequence()) {
                                maxSequence = subtask.getSequence();
                            }
                        }
                    }
                }
            }
        }

        for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
            if (phase.getLibraryPhaseId() == SelectedPhase) {
                for (GFA_TemplateTask task : phase.getTemplateTasks()) {
                    if (task.getLibraryTaskId() == SelectedTask) {
                        for (Id key : libMap.keySet()) {
                            if (libMap.get(key).IsSelected) {
                                GFA_TemplateSubtask tempSubtask = new GFA_TemplateSubtask(libMap.get(key));
                                tempSubtask.setTemplateTaskId(task.getId());
                                tempSubtask.setSequence(++maxSequence);
                                task.getTemplateSubtasks().add(tempSubtask);
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public PageReference removeTemplateSubtask() {
        Id libPhaseId = getParam('libPhaseId');
        Id libTaskId = getParam('libTaskId');
        Id libSubtaskId = getParam('libSubtaskId');
        for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
            if (phase.getLibraryPhaseId() == libPhaseId) {
                for (GFA_TemplateTask task : phase.getTemplateTasks()) {
                    if (task.getLibraryTaskId() == libTaskId) {
                        for (Integer i = task.getTemplateSubtasks().size() - 1; i > -1; i--) {
                            if (task.getTemplateSubtasks()[i].getLibrarySubtaskId() == libSubtaskId) {
                                GFA_TemplateSubtask subtask = task.getTemplateSubtasks().remove(i);
                                //---Only add them to delete list if they have already been saved
                                if (task.getId() != null) {
                                    mDeleteTemplateSubtasks.add(subtask);
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public PageReference save() {

        List<GFA_BaseModel> models = new List<GFA_BaseModel>();
        List<GFA_BaseModel> deleteModels = new List<GFA_BaseModel>();

        models.add(template);
        models.addAll((List<GFA_BaseModel>)template.getTemplatePhases());
        GFA_BaseModel.save(models);
        models.clear();

        //---Adding these because of possible chunking issues with saving
        //---multiple types of records in a single transaction.
        List<GFA_TemplateTask> tasks = new List<GFA_TemplateTask>();
        List<GFA_TemplateSubtask> subtasks = new List<GFA_TemplateSubtask>();

        for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
            for (GFA_TemplateTask task : phase.getTemplateTasks()) {
                if (task.getTemplatePhaseId() == null) {
                    task.setTemplatePhaseId(phase.getId());
                }
                tasks.add(task);
            }
        }

        models.addAll((List<GFA_BaseModel>)tasks);
        GFA_BaseModel.save(models);
        models.clear();

        for (GFA_TemplateTask task : tasks) {
            for (GFA_TemplateSubtask subtask : task.getTemplateSubtasks()) {
                if (subtask.getTemplateTaskId() == null) {
                    subtask.setTemplateTaskId(task.getId());
                }
            }
            subtasks.addAll(task.getTemplateSubtasks());
        }

        models.addAll((List<GFA_BaseModel>)subtasks);
        GFA_BaseModel.save(models);

        deleteModels.addAll((List<GFA_BaseModel>)mDeleteTemplatePhases);
        deleteModels.addAll((List<GFA_BaseModel>)mDeleteTemplateTasks);
        deleteModels.addAll((List<GFA_BaseModel>)mDeleteTemplateSubtasks);
        GFA_BaseModel.destroy(deleteModels);

        mDeleteTemplatePhases.clear();
        mDeleteTemplateTasks.clear();
        mDeleteTemplateSubtasks.clear();

        PageReference pr = Page.GFA_TemplateTreeView;
        pr.setRedirect(true);
        putParam(pr, 'id', template.getId());
        return pr;
    }

    public PageReference saveAndContinue() {
        save();
        return null;
    }

    public PageReference cancel() {
        PageReference pr = Page.GFA_TemplateTreeView;
        pr.setRedirect(true);
        putParam(pr, 'id', template.getId());
        return pr;
    }

    public void clearFilter() {
        Filter = new GFA_FilterManager();
        Filter.subtask = new GFA_Library_Subtask__c();
        Filter.setupLibrarySubtaskFilters();
        refreshAvailableLibrarySubtasks();
    }

}