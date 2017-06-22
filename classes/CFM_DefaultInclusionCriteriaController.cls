public class CFM_DefaultInclusionCriteriaController {

	public static final Integer DEFAULT_NUMBER_LOGIC_ROWS = 10;

	public CFM_SavedSearch defaultInclusionCriteria { get; set; }

	public List<CFM_LogicRow> logicRowList { get; set; }
	public Boolean showFilterLogic { get; set; }
    public String filterLogic { get; set; }

	public CFM_DefaultInclusionCriteriaController() {
		
	}

	public PageReference doSetup() {
		// Must do setup in Page action as DML in constructor is not allowed

		defaultInclusionCriteria = CFM_SavedSearch.find.findDefaultInclusionCriteria();
        showFilterLogic = false;

		if (defaultInclusionCriteria == null) {
			setupLogicRows();

			CFM_Survey_Project_Saved_Search__c savedSearch = new CFM_Survey_Project_Saved_Search__c(Is_Default_Inclusion_Criteria__c=true);
			defaultInclusionCriteria = new CFM_SavedSearch(savedSearch, logicRowList, false, '');
			defaultInclusionCriteria.save();
		}
		else {
			logicRowList = defaultInclusionCriteria.logicRowList;
			showFilterLogic = defaultInclusionCriteria.enableFilterLogic;
			filterLogic = defaultInclusionCriteria.filterLogic;
		}

		return null;
	}

	public PageReference saveChanges() {

		if (isLogicValid()) {
			defaultInclusionCriteria.logicRowList = logicRowList;
			defaultInclusionCriteria.enableFilterLogic = showFilterLogic;
			defaultInclusionCriteria.filterLogic = filterLogic;
			defaultInclusionCriteria.save();

			CFM_PageUtil.addConfirm('Changes saved');
		}
		

		return null;
	}

	public PageReference discardChanges() {
		CFM_PageUtil.addInfo('Changes discarded');

		return doSetup();
	}

	public PageReference checkLogicAction() {
		if (isLogicValid()) {
			 CFM_PageUtil.addConfirm('Logic passed validation');
		}

		return null;
	}

	public Boolean isLogicValid() {
		String whereClause = '';

		try {
            if (showFilterLogic) {
                if (String.isBlank(filterLogic)) {
                    CFM_PageUtil.addError('Please enter a valid filter logic condition');
                    return false;
                }
                whereClause = CFM_LogicRow.parseFilterLogic(filterLogic, logicRowList);
            }
            else {
                whereClause = CFM_LogicRow.evaluateAndLogic(logicRowList);
            }
        }
        catch (CFM_LogicRow.InvalidFilterLogicException ex) {
            // Exception contains user-friendly error message
            CFM_PageUtil.addError(ex.getMessage());
           return false;
        }
        catch (CFM_StringUtil.InvalidDateFormatException ex) {
            CFM_PageUtil.addError('Invalid date format in search criteria');
            return false;
        }

        try {
            System.debug('Where Clause: ' + whereClause);
            List<Id> searchResultsIdList = CFM_Project.find.findIdByWhere(whereClause);
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            CFM_PageUtil.addError('Error occurred while searching. Please ensure that your search criteria is in the correct format.');
            return false;
        }

        return true;
	}


	public void setupLogicRows() {
        logicRowList = new List<CFM_LogicRow>();

        for (Integer i = 0; i < DEFAULT_NUMBER_LOGIC_ROWS; i++) {
            logicRowList.add(new CFM_LogicRow(i+1));
        }

        logicRowList.get(logicRowList.size()-1).isLastRow = true;
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
}