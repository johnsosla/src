public with sharing class SGT_SalesGoalEditController {

    public static final Integer DEFAULT_NUMBER_LOGIC_ROWS = 5;

    public ApexPages.standardController sc;
	public SGT_SalesGoal salesGoal { get; set; }
    public RecordType rt { get; set; }


     public List<SGT_LogicRow> logicRows { get; set; }

    public Boolean showFilterLogic { get; set; }
    public String filterLogic { get; set; }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public SGT_SalesGoalEditController(ApexPages.StandardController stdController) {
        this.sc = stdController;

        if (String.isBlank(stdController.getId())) {
            this.salesGoal = new SGT_SalesGoal((SGT_Sales_Goal__c)stdController.getRecord());    
        }
        else {
            this.salesGoal = SGT_SalesGoal.find.findById(stdController.getId());
        }
        
        this.rt = [Select Id, DeveloperName From RecordType Where Id = :salesGoal.obj.RecordTypeId];

        if (rt.DeveloperName == 'Business_Line_Sales_Goal') {
            if (salesGoal.getLogicRows() == null) {
                setupDefaultLogicRows();
                showFilterLogic = false;
            }
            else {
                logicRows = salesGoal.getLogicRows();
                showFilterLogic = salesGoal.obj.Filter_Logic_Enabled__c;
                filterLogic = salesGoal.obj.Filter_Logic__c;
            }
        }
    }

    public PageReference save() {

        if (rt.DeveloperName == 'Business_Line_Sales_Goal') {
            return saveBusinessLineGoal();
        }
        else {
            salesGoal.save();
            PageReference pg = new PageReference('/' + salesGoal.getId());
            pg.setRedirect(true);
            return pg;
        }

        
    }

    private PageReference saveBusinessLineGoal() {
        Boolean foundNonEmpty = false;
        Boolean foundIncomplete = false;


        for (SGT_LogicRow row : logicRows) {
            if (!row.isEmpty()) foundNonEmpty = true;
            if (row.isIncomplete()) foundIncomplete = true;

            if (!row.allowsMultipleValues() && row.isMultiValue()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Multiple values are only allowed for "Equals", "Not Equals", "Includes", "Excludes" operators'));
                return null;
            }
        }

        if (foundIncomplete) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Incomplete criteria found, please choose and field and operator for all criteria'));
            return null;
        }

        if (foundNonEmpty) {
            if (showFilterLogic && String.isBlank(filterLogic)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Filter logic is required'));
                return null;
            }

            if (!String.isBlank(filterLogic)) {

                filterLogic = filterLogic.toUpperCase();

                if (filterLogic.contains('NOT')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '"NOT" Operator is not currently supported for filter logic'));
                    return null;
                }
            }

            for (Integer i = logicRows.size() - 1; i >= 0; i--) {
                SGT_LogicRow row = logicRows[i];
                if (row.isEmpty()) logicRows.remove(i);
            }

            // Re-number rows in case one was removed in the middle
            for (Integer i = 0; i < logicRows.size(); i++) {
                logicRows[i].position = i + 1;
            }
           
            salesGoal.updateCriteria(logicRows, showFilterLogic, filterLogic);

            SGT_SalesGoalTriggerHandler.updateFiscalYears(new List<SGT_Sales_Goal__c> { salesGoal.obj });


            try {
                String queryString = SGT_Opportunity.find.getQueryStringForSalesGoals(new List<SGT_SalesGoal>{salesGoal});
                System.debug(LoggingLevel.DEBUG, queryString);
                Database.query(queryString + ' LIMIT 1');
            }
            catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage() + ' -- ' + e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered while querying with selected criteria. Please ensure input is in a correct format'));
                return null;
            }
        }
        else {
            // No criteria specified
            salesGoal.clearCriteria();
        }

        try {
            salesGoal.save();    
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered while saving: ' + e.getMessage()));
            return null;
        }
        

        PageReference pg = new PageReference('/' + salesGoal.getId());
        pg.setRedirect(true);
        return pg;
    }

    public PageReference cancelEdit() {
        return sc.cancel();
    }


    public void setupDefaultLogicRows() {
        logicRows = new List<SGT_LogicRow>();

        for (Integer i = 0; i < DEFAULT_NUMBER_LOGIC_ROWS; i++) {
            logicRows.add(new SGT_LogicRow(i+1));
        }

        logicRows.get(logicRows.size()-1).isLastRow = true;
    }

    public PageReference addLogicRowAction() {
        logicRows.get(logicRows.size()-1).isLastRow = false;

        SGT_LogicRow newRow = new SGT_LogicRow(logicRows.size()+1);
        newRow.isLastRow = true;
        logicRows.add(newRow);

        return null;
    }

    public PageReference removeLogicRowAction() {
        if (logicRows.size() > 1) {
            logicRows.remove(logicRows.size()-1);
            logicRows.get(logicRows.size()-1).isLastRow = true;    
        }
        
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

}