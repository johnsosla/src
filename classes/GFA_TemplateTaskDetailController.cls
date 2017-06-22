public with sharing class GFA_TemplateTaskDetailController extends GFA_BaseController {

    public GFA_TemplateTask task {get; set;}
    public GFA_TemplatePhase templatePhase {get; set;}
    public GFA_Template template {get; set;}

    private List<GFA_LibrarySubtask> mAvailableLibrarySubtasks;

    public String SelectedTask {get; set;}
    public GFA_FilterManager Filter {get; set;}


    public GFA_TemplateTaskDetailController(ApexPages.StandardController sc) {
        task = GFA_TemplateTask.find.findById(sc.getId());
        setTask();
        setupFilter();
        setupPagination();
        refreshAvailableLibrarySubtasks();
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

    private void setTask() {
        Filter = new GFA_FilterManager();
        Filter.subtask = new GFA_Library_Subtask__c();

        if (String.isNotBlank(CurrentUser.getParameters())) {
            Filter = CurrentUser.getParametersAsFilterManager();
            Filter.subtask.Scope_Of_Service__c = Filter.ScopeOfService;
            Filter.subtask.Operating_Group__c = Filter.OperatingGroup;
            Filter.subtask.Business_Line__c = Filter.BusinessLine;
        }

        Set<Id> filterlibSubtaskIds = new Set<Id>();
        for (GFA_LibrarySubtask subtask : Filter.getLibrarySubtasksByCriteria()) {
            filterlibSubtaskIds.add(subtask.getId());
        }

        List<GFA_TemplateSubtask> templateSubtasks = GFA_TemplateSubtask.find.findByTaskId(task.getId());

        Set<Id> libSubtaskIds = new Set<Id>();
        List<GFA_LibrarySubtask> libSubtasks = new List<GFA_LibrarySubtask>();
        for (Integer i = templateSubtasks.size() - 1; i > -1; i--) {
            if (!filterlibSubtaskIds.contains(templateSubtasks[i].getLibrarySubtaskId())) {
                templateSubtasks.remove(i);
            } else {
                libSubtaskIds.add(templateSubtasks[i].getLibrarySubtaskId());
            }
        }

        templatePhase = GFA_TemplatePhase.find.findById(task.getTemplatePhaseId());
        template = GFA_Template.find.findById(task.getTemplateId());

        List<GFA_LibrarySubtaskVersion> activeLibSubtaskVersions = GFA_LibrarySubtaskVersion.find.findLatestActiveVersions(libSubtaskIds);

        //---Clearing set to use to return GFA_LibrarySubtasks
        libSubtaskIds.clear();
        for (GFA_LibrarySubtaskVersion activeLSVersion : activeLibSubtaskVersions) {
            libSubtaskIds.add(activeLSVersion.getLibrarySubtaskId());
        }
        libSubtasks = GFA_LibrarySubtask.find.findByIds(libSubtaskIds);

        Map<Id, List<GFA_LibrarySubtaskContent>> versionContentMap = GFA_LibrarySubtaskContent.find.findByVersionIds(activeLibSubtaskVersions);

        //Start adding Content to Version, Version to LibrarySubtask, and LibrarySubtask to TemplateSubtask
        //libSubtaskContent to libSubtaskVersions
        for (GFA_LibrarySubtask libSubtask : libSubtasks) {
            for (GFA_LibrarySubtaskVersion version : activeLibSubtaskVersions) {
                if (version.getStatus() == GFA_LibrarySubtaskVersion.STATUS_ACTIVE && version.getLibrarySubtaskId() == libSubtask.getId()) {
                    libSubtask.getVersions().add(version);
                }
            }

            for (GFA_LibrarySubtaskVersion version : libSubtask.getVersions()) {
                version.setLibrarySubtaskContents(versionContentMap.get(version.getId()));
            }
        }

        // libSubtask to templateSubtasks
        for (GFA_TemplateSubtask templateSubtask : templateSubtasks) {
            for (GFA_LibrarySubtask libSubtask : libSubtasks) {
                if (templateSubtask.getLibrarySubtaskId() == libSubtask.getId()) {
                    templateSubtask.getLibrarySubtasks().add(libSubtask);
                }
            }
        }

        //templatesubtask to task
        templateSubtasks.sort();
        task.setTemplateSubtasks(templateSubtasks);

    }

    private void setupFilter() {
        Filter = new GFA_FilterManager();
        Filter.subtask = new GFA_Library_Subtask__c();
        Filter.setupLibrarySubtaskFilters();
    }

    public List<GFA_LibrarySubtask> getAvailableLibrarySubtasks() {
        return mAvailableLibrarySubtasks;
    }

    public PageReference refreshAvailableLibrarySubtasks() {
        setupPagination();
        Set<Id> usedSubtaskIds = new Set<Id>();
        for (GFA_TemplateSubtask subtask : GFA_TemplateSubtask.find.findByTaskId(task.getId())) {
            usedSubtaskIds.add(subtask.getLibrarySubtaskId());
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
        Set<Id> libSubtaskIds = new Set<Id>();
        mAvailableLibrarySubtasks = GFA_LibrarySubtask.find.findByIds(selectedIdList);
        for (GFA_LibrarySubtask libSubtask : mAvailableLibrarySubtasks) {
            libSubtask.IsSelected = true;
            libMap.put(libSubtask.getId(), libSubtask);
        }

        for (GFA_TemplateSubtask subtask : task.getTemplateSubtasks()) {
            if (maxSequence < subtask.getSequence()) {
                maxSequence = subtask.getSequence();
            }
        }

        List<GFA_LibrarySubtaskVersion> activeLibSubtaskVersions = GFA_LibrarySubtaskVersion.find.findLatestActiveVersions(libSubtaskIds);
        Map<Id, List<GFA_LibrarySubtaskContent>> contentMap = GFA_LibrarySubtaskContent.find.findByVersionIds(activeLibSubtaskVersions);

        for (Id key : libMap.keySet()) {
            if (libMap.get(key).IsSelected) {
                GFA_TemplateSubtask tempSubtask = new GFA_TemplateSubtask(libMap.get(key));
                tempSubtask.getLibrarySubtasks().add(libMap.get(key));

                for (GFA_LibrarySubtask libSubtask : tempSubtask.getLibrarySubtasks()) {
                    for (GFA_LibrarySubtaskVersion activeLSVersion : activeLibSubtaskVersions) {
                        if (libSubtask.getId() == activeLSVersion.getLibrarySubtaskId()) {
                            activeLSVersion.setLibrarySubtaskContents(contentMap.get(activeLSVersion.getId()));
                            libSubtask.setDescription(activeLSVersion.getDescription());
                            libSubtask.setVersions(new List<GFA_LibrarySubtaskVersion> {activeLSVersion});
                        }
                    }
                }
                tempSubtask.setTemplateTaskId(task.getId());
                tempSubtask.setSequence(++maxSequence);
                task.getTemplateSubtasks().add(tempSubtask);
            }
        }

        List<GFA_BaseModel> models = new List<GFA_BaseModel>();
        List<GFA_TemplateSubtask> subtasks = new List<GFA_TemplateSubtask>();
        subtasks.addAll(task.getTemplateSubtasks());
        subtasks.sort();

        models.addAll((List<GFA_BaseModel>)subtasks);
        GFA_BaseModel.save(models);

        return null;
    }

    public PageReference templateFramework() {
        PageReference pr = Page.GFA_TemplateFramework;
        pr.setRedirect(true);
        putParam(pr, 'id', templatePhase.getTemplateId());
        return pr;
    }

    public void clearFilter() {
        Filter = new GFA_FilterManager();
        Filter.subtask = new GFA_Library_Subtask__c();
        Filter.setupLibrarySubtaskFilters();
        refreshAvailableLibrarySubtasks();
    }

    public Boolean getCanEdit() {
        return CurrentUser.getIsAdminUser();
    }
}