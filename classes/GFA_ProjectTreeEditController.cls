public with sharing class GFA_ProjectTreeEditController extends GFA_ProjectTreeBaseController {

    public String SelectedPhase {get; set;}
    public String SelectedTask {get; set;}
    public String SelectedTaskName {get; set;}

    private List<GFA_ProjectSubtask> mDeleteProjectSubtasks;

    private List<GFA_LibrarySubtask> mAvailableLibrarySubtasks;

    public GFA_FilterManager Filter {get; set;}

    public GFA_ProjectTreeEditController(ApexPages.StandardController sc) {
        super(sc);
        mDeleteProjectSubtasks = new List<GFA_ProjectSubtask>();
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

    public PageReference save() {
        List<GFA_ProjectSubtask> subtasks = new List<GFA_ProjectSubtask>();

        for (GFA_ProjectPhase phase : project.getProjectPhases()) {
            for (GFA_ProjectTask task : phase.getProjectTasks()) {
                subtasks.addAll(task.getProjectSubtasks());
            }
        }

        GFA_BaseModel.save(subtasks);
        if (!mDeleteProjectSubtasks.isEmpty()) {
            Map<Id, List<GFA_ProjectDeliverable>> projectDeliverables = GFA_ProjectDeliverable.find.findByProjectSubtaskIds(mDeleteProjectSubtasks);
            List<GFA_ProjectDeliverable> allDeliverables = new List<GFA_ProjectDeliverable>();
            for (Id key : projectDeliverables.keySet()) {
                allDeliverables.addAll(projectDeliverables.get(key));
            }
            GFA_BaseModel.destroy(allDeliverables);
            GFA_BaseModel.destroy(mDeleteProjectSubtasks);
        }

        mDeleteProjectSubtasks.clear();

        PageReference pr = Page.GFA_ProjectTreeView;
        putParam(pr, 'id', project.getId());
        pr.setRedirect(true);
        return pr;
    }

    public PageReference saveAndContinue() {
        save();
        return null;
    }

    public PageReference cancel() {
        PageReference pr = Page.GFA_ProjectTreeView;
        putParam(pr, 'id', project.getId());
        pr.setRedirect(true);
        return pr;
    }

    public List<GFA_LibrarySubtask> getAvailableLibrarySubtasks() {
        return mAvailableLibrarySubtasks;
    }

    public PageReference refreshAvailableLibrarySubtasks() {
        setupPagination();
        Set<Id> usedSubtaskIds = new Set<Id>();
        for (GFA_ProjectPhase phase : project.getProjectPhases()) {
            for (GFA_ProjectTask task : phase.getProjectTasks()) {
                for (GFA_ProjectSubtask subtask : task.getProjectSubtasks()) {
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

    public PageReference addLibrarySubtasks() {
        readSelectedIdListFromPage();
        Set<Id> libSubtaskIds = new Set<Id>();
        Decimal maxSequence = 0;

        //---Get list of all selected active versions
        List<GFA_LibrarySubtaskVersion> activeVersions = GFA_LibrarySubtaskVersion.find.findLatestActiveVersions(selectedIdList);
        for (GFA_ProjectPhase phase : project.getProjectPhases()) {
            if (phase.getLibraryPhaseId() == SelectedPhase) {
                for (GFA_ProjectTask task : phase.getProjectTasks()) {
                    if (task.getLibraryTaskId() == SelectedTask) {
                        for (GFA_ProjectSubtask subtask : task.getProjectSubtasks()) {
                            if (subtask.getSequence() != null && maxSequence < subtask.getSequence()) {
                                maxSequence = subtask.getSequence();
                            }
                        }
                        for (GFA_LibrarySubtaskVersion version : activeVersions) {
                            GFA_ProjectSubtask subtask = new GFA_ProjectSubtask(version);
                            subtask.setProjectTaskId(task.getId());
                            subtask.setAddedBy(GFA_ProjectSubtask.ADDED_BY_MANUAL);
                            subtask.setIsApplicable(true);
                            subtask.setSequence(++maxSequence);
                            task.getProjectSubtasks().add(subtask);
                        }
                    }
                }
            }
        }
        return null;
    }

    public PageReference removeProjectSubtasks() {
        Id libPhaseId = getParam('libPhaseId');
        Id libTaskId = getParam('libTaskId');
        Id libSubtaskId = getParam('libSubtaskId');
        for (GFA_ProjectPhase phase : project.getProjectPhases()) {
            if (phase.getLibraryPhaseId() == libPhaseId) {
                for (GFA_ProjectTask task : phase.getProjectTasks()) {
                    if (task.getLibraryTaskId() == libTaskId) {
                        for (Integer i = task.getProjectSubtasks().size() - 1; i > -1; i--) {
                            if (task.getProjectSubtasks()[i].getLibrarySubtaskId() == libSubtaskId) {
                                GFA_ProjectSubtask subtask = task.getProjectSubtasks().remove(i);
                                //---Only add them to delete list if they have already been saved
                                if (task.getId() != null) {
                                    mDeleteProjectSubtasks.add(subtask);
                                }
                            }
                        }
                    }
                }
            }
        }
        return null;
    }

    public void clearFilter() {
        Filter = new GFA_FilterManager();
        Filter.subtask = new GFA_Library_Subtask__c();
        Filter.setupLibrarySubtaskFilters();
        refreshAvailableLibrarySubtasks();
    }
}