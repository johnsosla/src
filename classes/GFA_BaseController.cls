public abstract with sharing class GFA_BaseController {

    //---Pagination variables
    public static final Integer PAGE_SIZE = 20;
    public Integer CurrentPage {get; set;}
    public List<Id> searchResultsIdList {get; set;} //---All Library Subtasks Ids
    public Set<Id> selectedIdList {get; set;} //---All Selected Library Subtask Ids
    public Boolean CheckAll {get; set;}

    public GFA_User CurrentUser {
        get {
            return GFA_User.getCurrentUser();
        }
    }

    public GFA_BaseController() {}

    /**
    *   @param key Current Page Reference parameter to retreive
    *   @return value associated with the key
    **/
    public String getParam(String key) {
        return ApexPages.currentPage().getParameters().get(key);
    }

    /**
    *   @param key parameter to put into Current Page Reference
    *   @param value string associated with the parameter for the Current Page Reference
    **/
    public void putParam(String key, String value) {
        ApexPages.CurrentPage().getParameters().put(key, value);
    }

    /**
    *   @param pr PageReference that we will put the key/value string into
    *   @param key parameter to put into Current Page Reference
    *   @param value string associated with the parameter for the PageReference
    **/
    public void putParam(PageReference pr, String key, String value) {
        pr.getParameters().put(key, value);
    }

    /**
    *   @param messsage Info that will be added to the error message
    *   @return ApexPages error message is added to current page
    **/
    public static void addError(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    }

    /**
    *   @param messsage Info that will be added to the warning message
    *   @return ApexPages warning message is added to current page
    **/
    public static void addWarning(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
    }

    /**
    *   @param messsage Info that will be added to the info message
    *   @return ApexPages info message is added to current page
    **/
    public static void addInfo(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }

    //---Pagination methods

    public void setupPagination() {
        CurrentPage = 0;
        CheckAll = false;
        selectedIdList = new Set<Id>();
        searchResultsIdList = new List<Id>();
    }

    public Integer getDisplayPage() {
        return currentPage + 1; // Current page is always zero-indexed, so add one to get the "Logical" page
    }

    public List<Integer> getPageNumbers() {
        List<Integer> result = new List<Integer>();
        Integer beginIndex = currentPage > 10 ? currentPage - 10 : 0;

        for (Integer i = beginIndex; (i * PAGE_SIZE) < searchResultsIdList.size() && i < beginIndex + 30; i++) {
            result.add(i + 1);
        }

        return result;
    }

    public void setupCurrentPage() {
        readSelectedIdListFromPage();
        getCurrentPageResults();
        populateSelectedIdListToPage();
        CheckAll = false;
    }

    //---Why not use abstact? Because I would have to implement these methods
    //---for the view controller which does not use these,

    // Read the selection state of the current page to save across pagination
    public virtual void readSelectedIdListFromPage() {}

    public virtual void getCurrentPageResults() {}

    // Populate selection state of the current page of results
    public virtual void populateSelectedIdListToPage() {}

    //---Leave implementation for checkAll in Edit Controller
    public virtual PageReference checkAllAction() {
        return null;
    }

    public PageReference previousPage() {
        if (currentPage > 0) {
            currentPage--;
        }

        setupCurrentPage();

        return null;
    }

    public PageReference nextPage() {
        Integer maxPage = (Integer)Math.ceil(((Decimal)searchResultsIdList.size() / (Decimal)PAGE_SIZE)) - 1;
        if (currentPage < maxPage) {
            currentPage++;
        }

        setupCurrentPage();

        return null;
    }

    public PageReference switchToPage() {
        String sPage = ApexPages.currentPage().getParameters().get('pageIndex');
        currentPage = Integer.valueOf(sPage) - 1;

        setupCurrentPage();

        return null;
    }
}