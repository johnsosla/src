public with sharing class ECO_BudgetHeaderSummaryController extends ECO_Financial_Security{
	public pse__Proj__c theProject{ get; set; }
    
    public ECO_DTO_BudgetHeaderWrapper budgetWrapper {get; set;}
    
    private Boolean isThisFirstBudget;
    
    public String selectedBudgetHeader {get; set;}
    public String selectedAction {get; set;}
    public Boolean restrictAccess {get;set;}
    
   	public ECO_BudgetHeaderSummaryController (ApexPages.StandardController con) {
        theProject = ECO_Service_Projects.getProjectById(con.getId());
       
        restrictAccess = ECO_Service_RecordAccess.getPageAccess(theProject.Id);
        if (restrictAccess)  
        {   
            //ECO_Service_ErrorLog.formatPageError('You do not have permission to view this page', ApexPages.Severity.ERROR);
            Throw new ECO_Financial_SecurityAccessException('You do not have permissions to view this page');
        }
		 
        if (theProject.BudgetHeaders__r.isEmpty()) {
			isThisFirstBudget = true;
		} else {
			isThisFirstBudget = false;
		}
        
        if(!isThisFirstBudget) {
        	budgetWrapper = new ECO_DTO_BudgetHeaderWrapper(theProject.Id);    
        }
    }
    
    public PageReference goToQuestionnaire () {
		PageReference pageReference = Page.ECO_BudgetQuestionnaire;
		pageReference.getParameters().put('retURL', '/apex/ECO_BudgetHeaderSummary?id='+theProject.Id);
		pageReference.getParameters().put('id', theProject.Id);
		return pageReference;
	}
    
    public PageReference onAction() {
        String bhId = Apexpages.currentPage().getParameters().get('budgetHeaderId');
        String actionSelected = Apexpages.currentPage().getParameters().get('actionSelected');
        
        //system.debug('budgetHeaderId:' + bhId);
        //system.debug('selectionAction:' + actionSelected);
        
        if(actionSelected == 'SubmitInternalChange') {
			Id newChangeManagerId = ECO_Service_ChangeManager.createNewInternalChangeManagerFromBudget(bhId, theProject.Id);
            PageReference changeManagerPage = new PageReference('/apex/ECO_ChangeManagerDetail?Id=' + newChangeManagerId + '&mode=Edit');
			changeManagerPage.setRedirect(true);
            return changeManagerPage;
        }
        else if (actionSelected == 'SubmitWorkAtRiskChange') {
            Id newChangeManagerId = ECO_Service_ChangeManager.createNewWorkAtRiskChangeManagerFromBudget(bhId, theProject.Id);
            PageReference changeManagerPage = new PageReference('/apex/ECO_ChangeManagerDetail?Id=' + newChangeManagerId + '&mode=Edit');
            changeManagerPage.setRedirect(true);
            return changeManagerPage;
        }
        else if (actionSelected == 'SubmitExternalChange') {
            Id newChangeManagerId = ECO_Service_ChangeManager.createNewExternalChangeManagerFromBudget(bhId, theProject.Id);
            PageReference changeManagerPage = new PageReference('/apex/ECO_ChangeManagerDetail?Id=' + newChangeManagerId + '&mode=Edit');
			changeManagerPage.setRedirect(true);
            return changeManagerPage;
        }
        else if (actionSelected == 'ViewInternalChange') {
            ECO_DTO_BudgetHeader dtoBudgetHeader = budgetWrapper.findBudgetHeaderDTOById(Id.valueOf(bhId));
            PageReference changeManagerPage = new PageReference('/apex/ECO_ChangeManagerDetail?Id=' + dtoBudgetHeader.budgetHeaderChangeManagerMap.get('Internal Change') + '&mode=Edit');
			changeManagerPage.setRedirect(true);
            return changeManagerPage;
        }
        else if(actionSelected == 'ViewExternalChange') {
            ECO_DTO_BudgetHeader dtoBudgetHeader = budgetWrapper.findBudgetHeaderDTOById(Id.valueOf(bhId));
            PageReference changeManagerPage = new PageReference('/apex/ECO_ChangeManagerDetail?Id=' + dtoBudgetHeader.budgetHeaderChangeManagerMap.get('External Change') + '&mode=Edit');
			changeManagerPage.setRedirect(true);
            return changeManagerPage;
        }
        else if(actionSelected == 'ViewWorkAtRiskChange') {
            ECO_DTO_BudgetHeader dtoBudgetHeader = budgetWrapper.findBudgetHeaderDTOById(Id.valueOf(bhId));
            PageReference changeManagerPage = new PageReference('/apex/ECO_ChangeManagerDetail?Id=' + dtoBudgetHeader.budgetHeaderChangeManagerMap.get('Work at Risk Change') + '&mode=Edit');
            changeManagerPage.setRedirect(true);
            return changeManagerPage;
        }

        else if(actionselected == 'ArchiveBudget') {
            BudgetHeader__c bh = new BudgetHeader__c(Id = bhId, Status__c = ECO_DTO_BudgetHeader.STATUS_ARCHIVE);
            update bh;

            List<BudgetTask__c> budgetTasks = [select id, ProjectTask__c from BudgetTask__c where BudgetHeader__c = :bhId];

            update budgetTasks;
        }        
        else if(actionselected == 'UnArchiveBudget') {
            BudgetHeader__c bh = new BudgetHeader__c(Id = bhId, Status__c = ECO_DTO_BudgetHeader.STATUS_ESTIMATE);
            update bh;

            List<BudgetTask__c> budgetTasks = [select id, ProjectTask__c from BudgetTask__c where BudgetHeader__c = :bhId];

            update budgetTasks;
        }
        
        PageReference pageReference = new PageReference('/apex/ECO_BudgetHeaderSummary?Id=' + theProject.Id);
        pageReference.setRedirect(true);
		return pageReference;
    }
    
    public PageReference onArchiveLoad () {
        budgetWrapper = new ECO_DTO_BudgetHeaderWrapper(theProject.Id, true);
        return null;
    }

    public PageReference onLoad () {

        
		if (theProject.DateLastCompletedBudgetQuestionnaire__c == null) {
			return goToQuestionnaire();
		}
		
		if (isThisFirstBudget) {
            System.savePoint oSavePoint = Database.setSavepoint();
            
            BudgetHeader__c oBudgetHeader = new BudgetHeader__c();
            
            try {
                oBudgetHeader.Project__c = theProject.Id;
                oBudgetHeader.BudgetName__c = 'Estimate 1';
                oBudgetHeader.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(BudgetHeader__c.sObjectType, 'Baseline');
                oBudgetHeader.Status__c = ECO_DTO_BudgetHeader.STATUS_ESTIMATE;
                
                insert oBudgetHeader; 
            } catch (Exception e) {
                system.debug('Handled Exception:  '+e.getMessage());
                system.debug('Handled Exception.getLineNumber:  '+e.getLineNumber());
                Database.rollback(oSavePoint);
                ApexPages.addMessages(e);
            }
            
            try {
                List<BudgetTask__c> lBudgetTask = new List<BudgetTask__c>();
                
                for (pse__Project_Task__c oProjectTask : [SELECT Id, Name 
                                                		  FROM pse__Project_Task__c 
                                                		  WHERE pse__Project__c = :theProject.Id
                                                          AND IsWorkPlanTask__c = false]) {
    
                    BudgetTask__c oBudgetTask = new BudgetTask__c();
                    oBudgetTask.ProjectTask__c = oProjectTask.Id;
                    oBudgetTask.BudgetHeader__c = oBudgetHeader.Id;
                    oBudgetTask.TaskName__c = oProjectTask.Name;
                    lBudgetTask.add(oBudgetTask);
                }
                
                if (!lBudgetTask.isEmpty()) {
                    insert lBudgetTask;
                }
    
            } catch (Exception e) {
                system.debug('Handled Exception:  '+e.getMessage());
                system.debug('Handled Exception.getLineNumber:  '+e.getLineNumber());
                Database.rollback(oSavePoint);
                ApexPages.addMessages(e);
            }
            
            budgetWrapper = new ECO_DTO_BudgetHeaderWrapper(theProject.Id);
		}
		
		return null;
	}
}