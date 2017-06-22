//---This is the controller extension for adding new projects to a Survey Batch
public without sharing class CFM_SurveyBatchAddProjectsController {

    public static final Integer MAX_NUMBER_ADDED_PROJECTS = 9000; // Maximum number of DML rows is 10,000

    public static final Integer DEFAULT_NUMBER_LOGIC_ROWS = 5;

    public static final Integer PAGE_SIZE = 50;


    public CFM_SavedSearch defaultInclusionCriteria { get; set; }
    
    public CFM_Survey_Batch__c surveyBatch { get; set; }

    public List<CFM_SavedSearch> savedSearches { get; set; }
    public String savedSearchName { get; set; }

    public String selectedCriteria { get; set; }
    public Boolean isRandom { get; set; }
    public Integer batchSize { get; set; }

    public Integer currentPage { get; set; }

    public List<CFM_LogicRow> logicRowList { get; set; }

    public Boolean showFilterLogic { get; set; }
    public String filterLogic { get; set; }

    public Boolean showResults { get; set; }

    public List<Id> searchResultsIdList { get; set; }

    public Boolean checkAll { get; set; }


    public Set<Id> selectedIdList { get; set; }
    public List<CFM_Project> projectList { get; set; }

    public String searchSummaryText { get; set; }

    public Boolean wasSearchRandom { get; set; }

    public CFM_SurveyBatchAddProjectsController() { 
        setup();
    }

    public CFM_SurveyBatchAddProjectsController(ApexPages.StandardController stdController) {
        surveyBatch = (CFM_Survey_Batch__c)stdController.getRecord();
        setup();
    }

    private void setup() {

        savedSearches = CFM_SavedSearch.find.findAll();

        currentPage = 0;

        showFilterLogic = false;
        showResults = false;
        isRandom = false;
        wasSearchRandom = false;

        checkAll = false;

        defaultInclusionCriteria = CFM_SavedSearch.find.findDefaultInclusionCriteria();

        selectedIdList = new Set<Id>();

        setupLogicRows(); 
    }

    public void setupLogicRows() {
        logicRowList = new List<CFM_LogicRow>();

        for (Integer i = 0; i < DEFAULT_NUMBER_LOGIC_ROWS; i++) {
            logicRowList.add(new CFM_LogicRow(i+1));
        }

        logicRowList.get(logicRowList.size()-1).isLastRow = true;
    }

    public Integer getDisplayPage() {
        return currentPage + 1; // Current page is always zero-indexed, so add one to get the "Logical" page
    }

    public List<Integer> getPageNumbers() {
        List<Integer> result = new List<Integer>();


        Integer beginIndex = currentPage > 10 ? currentPage - 10 : 0;

        for (Integer i = beginIndex; (i * PAGE_SIZE) < searchResultsIdList.size() && i < beginIndex + 20; i++) {
            // Page size is 50, result size if 50; i = 0, i = 
            result.add(i+1);
        }

        return result;
    }

    //---Get list of saved criteria
    public List<SelectOption> getCriteriaList() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('','--None--'));

        for (CFM_SavedSearch row : savedSearches) {
            options.add(new SelectOption(row.getId(), row.obj.Name));
        }

        return options;
    }


    public PageReference addLogicRowAction() {
        logicRowList.get(logicRowList.size()-1).isLastRow = false;

        CFM_LogicRow newRow = new CFM_LogicRow(logicRowList.size()+1);
        newRow.isLastRow = true;
        logicRowList.add(newRow);

        return null;
    }

    public PageReference removeLogicRowAction() {
        logicRowList.remove(logicRowList.size()-1);
        logicRowList.get(logicRowList.size()-1).isLastRow = true;
        return null;
    }

    public PageReference addFilterAction() {
        showFilterLogic = true;
        return null;
    }

    public PageReference clearFilterAction() {
        filterLogic = '';
        showFilterLogic = false;

        return null;
    }

    //---Action to handle the selection of a saved criteria
    public PageReference criteriaSelectChangedAction() {
        for (CFM_SavedSearch row : savedSearches) {
            if (row.getId() == selectedCriteria) {
                logicRowList = row.logicRowList;
                showFilterLogic = row.enableFilterLogic;
                filterLogic = row.filterLogic;
            }
        }
        
        return null;
    }

    //---Cancel Action
    public PageReference cancelAction() {
        return new PageReference('/' + SurveyBatch.Id);
    }

    //---Cancel Action
    public PageReference searchAction() {

        selectedIdList = new Set<Id>();
        currentPage = 0;

        if (isRandom && (batchSize == null || batchSize <= 0)) {
            CFM_PageUtil.addError('You must enter a batch size for a random search');
             return null;
        }
        

        String whereClause = '';
        String defaultInclusionClause = '';

        if (defaultInclusionCriteria != null) {
            defaultInclusionClause = CFM_LogicRow.getDefaultInclusionCriteriaClause(defaultInclusionCriteria);
        }
        
        try {
            if (showFilterLogic) {
                if (String.isBlank(filterLogic)) {
                    CFM_PageUtil.addError('Please enter a valid filter logic condition');
                    return null;
                }
                whereClause = CFM_LogicRow.parseFilterLogic(filterLogic, logicRowList);
                whereClause += defaultInclusionClause;
            }
            else {
                whereClause = CFM_LogicRow.evaluateAndLogic(logicRowList);
                whereClause += defaultInclusionClause;
            }
        }
        catch (CFM_LogicRow.InvalidFilterLogicException ex) {
            // Exception contains user-friendly error message
            CFM_PageUtil.addError(ex.getMessage());
           return null;
        }
        catch (CFM_StringUtil.InvalidDateFormatException ex) {
            CFM_PageUtil.addError('Invalid date format in search criteria');
            return null;
        }




        try {
            System.debug('Where Clause: ' + whereClause);
            searchResultsIdList = CFM_Project.find.findIdByWhere(whereClause);
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            CFM_PageUtil.addError('Error occurred while searching. Please ensure that your search criteria is in the correct format.');
            return null;
        }

        if (isRandom) {
            if (searchResultsIdList.size() < batchSize) {
                searchSummaryText = 'Batch size was ' + batchSize + ' but only ' + searchResultsIdList.size() + ' results were found';
            }
            else {
                Set<Id> randomResultsSet = new Set<Id>();

                // Create a copy of the results as a pool to pull from. 
                // This avoids the problem of having many already-added IDs returned in a row when the batch size is close to the results size
                List<Id> randomPool = new List<Id>(searchResultsIdList); 

                while (randomResultsSet.size() < batchSize) {
                    Integer randomIndex = CFM_Project.getRandomProject(randomPool);
                    randomResultsSet.add(randomPool[randomIndex]); // If set already contains ID this is a no-op
                    randomPool.remove(randomIndex);
                }

                projectList = CFM_Project.find.findByIds(new List<Id>(randomResultsSet));

                searchSummaryText = randomResultsSet.size() + ' out of ' + searchResultsIdList.size() + ' total results';

                searchResultsIdList = new List<Id>(randomResultsSet);
            }
            
        }
        else {
            searchSummaryText = searchResultsIdList.size() + ' total results';
        }


        getCurrentPageResults();
 
        showResults = true;
        wasSearchRandom = isRandom;
        
        return null;
    }

    public void setupCurrentPage() {
        readSelectedIdListFromPage();
        getCurrentPageResults();
        populateSelectedIdListToPage();
    }

    public void getCurrentPageResults() {
        Integer beginIndex = PAGE_SIZE * currentPage; 
        Integer endIndex = (PAGE_SIZE * (currentPage + 1)) - 1; 
        if (endIndex >= searchResultsIdList.size()) endIndex = searchResultsIdList.size()-1;

        List<Id> subList = new List<Id>();

        for (Integer i = beginIndex; i <= endIndex; i++) {
            subList.add(searchResultsIdList.get(i));
        }

        projectList = CFM_Project.find.findByIds(subList);

    }

    // Read the selection state of the current page to save across pagination
    public void readSelectedIdListFromPage() {
        for (CFM_Project row : projectList) {
            if (row.selected) selectedIdList.add(row.getId());
            else selectedIdList.remove(row.getId());
        }
    }

    // Populate selection state of the current page of results
    public void populateSelectedIdListToPage() {
         for (CFM_Project row : projectList) {
            if (selectedIdList.contains(row.getId())) row.selected = true;
        }
    }

    public PageReference checkAllAction() {
        for (CFM_Project project : projectList) {
            project.selected = checkAll;
        }

        readSelectedIdListFromPage();

        return null;
    }

    public PageReference previousPage() {
        if (currentPage > 0) currentPage--;

        setupCurrentPage();

        return null;
    }

    public PageReference nextPage() {
        Integer maxPage = (Integer)Math.ceil(((Decimal)searchResultsIdList.size() / (Decimal)PAGE_SIZE)) - 1;
        if (currentPage < maxPage) currentPage++;

        setupCurrentPage();

        return null;
    }

    public PageReference switchToPage() {
        String sPage = ApexPages.currentPage().getParameters().get('pageIndex');
        currentPage = Integer.valueOf(sPage) - 1;

        setupCurrentPage(); 

        return null;
    }

    public PageReference addAllProjectsAction() {
        List<CFM_Survey_Batch_Project__c> surveyBatchProjects = new List<CFM_Survey_Batch_Project__c>();

        if (searchResultsIdList.size() > MAX_NUMBER_ADDED_PROJECTS) {
            CFM_PageUtil.addError('You cannot add more than ' + MAX_NUMBER_ADDED_PROJECTS + ' at a time.');
            return null;
        }

        for (Id selectedProjectId : searchResultsIdList) {
            CFM_Survey_Batch_Project__c newSurveyProject = new CFM_Survey_Batch_Project__c();
            newSurveyProject.Project__c = selectedProjectId;
            newSurveyProject.Survey_Batch__c = surveyBatch.Id;
            newSurveyProject.Add_Method__c = 'Random';
            newSurveyProject.Status__c = 'New';
            surveyBatchProjects.add(newSurveyProject);
        }

        insert surveyBatchProjects;

        return new PageReference('/' + SurveyBatch.Id);
    }

    public PageReference addSelectedProjectsAction() {

        readSelectedIdListFromPage();

        if (selectedIdList.size() == 0) {
            CFM_PageUtil.addError('No projects selected');
            return null;
        }
        else if (selectedIdList.size() > MAX_NUMBER_ADDED_PROJECTS) {
            CFM_PageUtil.addError('You cannot add more than ' + MAX_NUMBER_ADDED_PROJECTS + ' at a time.');
            return null;
        }

        List<CFM_Survey_Batch_Project__c> surveyBatchProjects = new List<CFM_Survey_Batch_Project__c>();

        for (Id selectedProjectId : selectedIdList) {
            CFM_Survey_Batch_Project__c newSurveyProject = new CFM_Survey_Batch_Project__c();
            newSurveyProject.Project__c = selectedProjectId;
            newSurveyProject.Survey_Batch__c = surveyBatch.Id;
            newSurveyProject.Add_Method__c = 'Manual Selection';
            newSurveyProject.Status__c = 'New';
            surveyBatchProjects.add(newSurveyProject);
            
        }

        insert surveyBatchProjects;

        return new PageReference('/' + SurveyBatch.Id);
    }

    public PageReference updateSavedSearch() {
         CFM_SavedSearch savedSearch = getSelectedSearch();

        if (savedSearch == null) {
            CFM_PageUtil.addError('Please select a search criteria to update');
            return null;
        }

        Boolean foundNonEmpty = false;

        for (CFM_LogicRow row : logicRowList) {
            if (!row.isEmpty()) foundNonEmpty = true;
        }

        if (!foundNonEmpty) {
            CFM_PageUtil.addError('You must enter at least one search criteria');
            return null;
        }

       
        savedSearch.updateLogic(logicRowList, showFilterLogic, filterLogic);
        savedSearch.save();

        CFM_PageUtil.addConfirm('Saved search updated');

        return null;
    }

    public PageReference saveSearch() {
        if (String.isBlank(savedSearchName)) {
            CFM_PageUtil.addError('Please enter a saved search name');
            return null;
        }


        List<CFM_SavedSearch> duplicateSearch = CFM_SavedSearch.find.findByName(savedSearchName);

        if (duplicateSearch.size() > 0) {
            CFM_PageUtil.addError('A saved search with this name already exists');
            return null;
        }
    
    
        Boolean foundNonEmpty = false;

        for (CFM_LogicRow row : logicRowList) {
            if (!row.isEmpty()) foundNonEmpty = true;
        }

        if (foundNonEmpty) {
            CFM_Survey_Project_Saved_Search__c newSavedSearch = new CFM_Survey_Project_Saved_Search__c(Name=savedSearchName);
            CFM_SavedSearch savedSearch = new CFM_SavedSearch(newSavedSearch, logicRowList, showFilterLogic, filterLogic);
            savedSearch.save();

            selectedCriteria = savedSearch.getId();
        }
        else {
            CFM_PageUtil.addError('You must enter at least one search criteria');
        }
        
        savedSearches = CFM_SavedSearch.find.findAll();
        
        return null;
    }

    public PageReference updateSavedSearchName() {
        CFM_SavedSearch searchObj = getSelectedSearch();

        if (searchObj == null) {
            CFM_PageUtil.addError('Please select a search criteria to update');
            return null;
        }


        List<CFM_SavedSearch> duplicateSearch = CFM_SavedSearch.find.findByName(savedSearchName);

        if (duplicateSearch.size() > 0) {
            for (CFM_SavedSearch duplicate : duplicateSearch) {
                if (duplicate.getId() != searchObj.getId()) {
                    CFM_PageUtil.addError('A saved search with this name already exists');
                    return null;
                }
            }
        }

        searchObj.obj.Name = savedSearchName;
        searchObj.save();

        CFM_PageUtil.addConfirm('Name updated');
        
        savedSearches = CFM_SavedSearch.find.findAll();

        return null;


    }

    public PageReference deleteSavedSearch() {
        CFM_SavedSearch search = getSelectedSearch();

        if (search == null) {
            CFM_PageUtil.addError('Please select a search criteria to delete');
            return null;
        }

        
        search.destroy();

        setup();

        return null;
    }

    public CFM_SavedSearch getSelectedSearch() {
        for (CFM_SavedSearch row : savedSearches) {
            if (row.getId() == selectedCriteria) {
                return row;
            }
        }

        return null;
    }

}