public with sharing class ECO_ProjectTaskSearchController{

	public String taskFilter {get;set;}
	public List<pse__Project_Task__c> projectTasks {get; private set;}
	public Boolean noSearchResults {get; private set;}
	private Id projectId;
	private ApexPAges.StandardsetController setCon;
	private final Integer pagingResultSize = 20;

	public POLineItem__c currentPOLineItem {get; set;}
	public String currentPOLineItem_TaskName {get;set;}
	public String currentPOLineItem_TaskId {get;set;}
	private Id poLineItemId;
	private Id poHeaderId;

	public ECO_ProjectTaskSearchController(){
		projectTasks = new List<pse__Project_Task__c>();
		taskFilter = '';
		poHeaderId = checkForId('poHeaderId');
		projectId = checkForId('projectId');
		poLineItemId  = checkForId('poLineItemId');
    	if(projectId == null || poHeaderId == null){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have reached this page incorrectly. Project Id is missing!'));
				return;
    	}else{
    		getTasksForProject();
    	}




    	currentPOLineItem = new POLineItem__c();
    	currentPOLineItem.POHeader__c = poHeaderId;
    	if(poLineItemId != null){
    		currentPOLineItem = [SELECT Id, 
    								Name, 
    								POHeader__c,
    								Amount__c,
    								CurrencyIsoCode
    							FROM POLineItem__c
    							WHERE Id = :poLineItemId];

    		if(currentPOLineItem == null){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find PO Line Item with Id = ' + poLineItemId + '!'));
				return;
    		}
    	}
	}


	public void saveCurrentPOLineItem(){

		if(!String.isEmpty(currentPOLineItem_TaskId)){
			currentPOLineItem.ProjectTask__c = Id.valueOf(currentPOLineItem_TaskId);
		}
		
		if(currentPOLineItem.Id == null){						
			insert currentPOLineItem;					
		}else{
			update currentPOLineItem;
		}	
		
	}

	public void getTasksForProject(){

		String soql = 'SELECT Id, Name, ProjectTaskNumber__c, BillTo__c, ShipTo__c,	pse__End_Date__c, ';
		soql +=	'pse__Start_Date__c, IsBillable__c, IsChargeable__c, WorkTypeName__c, pse__Parent_Task__r.Name ';
		soql += 'FROM pse__Project_Task__c ';
		soql += 'WHERE pse__Project__c = :projectId ';
		if(!String.isEmpty(taskFilter)){
			soql += 'AND Name LIKE \'%' + String.escapeSingleQuotes(taskFilter) + '%\' ';
		}
		soql += 'LIMIT ' + pagingResultSize;
		setCon = new ApexPages.StandardsetController(Database.getQueryLocator(soql));
        setCon.setPageSize(pagingResultSize);  
        populateProjectTaskList(); 

	}

	private void populateProjectTaskList(){
		projectTasks = setCon.getRecords(); 
        if(projectTasks.isEmpty()){
            noSearchResults = true;
        }else{
            noSearchResults = false;
        }
		//updatePagingVars();
	}

	private Id checkForId(String paramName){
		Id result = null;
        if(ApexPages.currentPage().getParameters().containsKey(paramName)){
            result = Id.valueOf(ApexPages.currentPage().getParameters().get(paramName));          
        }
        return result;
    }


}