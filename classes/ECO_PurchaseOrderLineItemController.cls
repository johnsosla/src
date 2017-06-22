/** ------------------------------------------------------------------------------------------------------
* @Description The controller for the Add/Edit Purchase Order Line Item page - it allows for users to select
* available tasks to allocate to POs on the project.
*
* @Author      NTT Data - Brad Furdyk, Sanchivan, Deborah Orth
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
public class ECO_PurchaseOrderLineItemController{
	private Id projectId;
	private ApexPAges.StandardsetController setCon;
	//private final Integer pagingResultSize = 20; removed DJO 5/10/2016 issue 4676
	private Id poLineItemId;
	private Id poHeaderId;
	private List<POLineItem__c> previousVersions;

	public String editType 								{ get; private set; }
	public String cancelButtonText 						{ get; private set; }
	public String retUrl 								{ get; private set; }
	public String poHeaderName 						 	{ get; private set; }

	public Boolean noSearchResults 						{ get; private set; }
	public Boolean hasBeenSynced 						{ get; private set; }
	public Boolean hasPreviousVersions 					{ get; private set; }
	public Boolean hasBeenInvoiced 						{ get; private set; }

	public POLineItem__c currentPOLineItem 				{ get; set; }
	public String currentPOLineItem_TaskName 			{ get; set; }
	public String currentPOLineItem_TaskId 				{ get; set; }
	public String taskFilter 							{ get; set; }

	public String searchTaskName						{ get; set; }
	public List<pse__Project_Task__c> projectTasks 		{ get; set; }

	/**
	 * Extension Contoller Constructor for the class - it initializes some default properties and lists
	 *
	 * @Author  NTT Data - Brad Furdyk, Sanchivan, Deborah Orth
	 * @Date    2015
	 *
	 * @param	oStandardController
	 * @return 	
	 **/
	public ECO_PurchaseOrderLineItemController(ApexPages.StandardController oStandardController) {
		setDefaults();
		poHeaderId = checkForId('poHeaderId');
		projectId = checkForId('projectId');		
		currentPOLineItem_TaskId = checkForId('taskId');

		this.currentPOLineItem = (POLineItem__c)oStandardController.getRecord();
		if(currentPOLineItem.Id != null){
			poLineItemId = currentPOLineItem.Id;
			getPOLineItem();
			hasBeenInvoiced = getInvoiceStatus();
		}else{
			currentPOLineItem.POHeader__c = poHeaderId;
			currentPOLineItem.LineType__c = 'Unit Rate';
			currentPOLineItem.LineNumber__c = getDefaultLineNumber();
			currentPOLineItem.Quantity__c = 1;
			//currentPOLineItem.UnitOfMeasureUserDefined__c = 'Each';
		}

		Initialize();
	}

	/**
	 * Default Constructor for the class - it initializes some default properties and lists, 
	 *
	 * @Author  NTT Data - Brad Furdyk, Sanchivan, Deborah Orth
	 * @Date    2015
	 *
	 * @param	
	 * @return 	
	 **/
	//DJO - don't think this is used anymore since this page now uses an extension controller
	public ECO_PurchaseOrderLineItemController(){
		setDefaults();
		poHeaderId = checkForId('poHeaderId');
		projectId = checkForId('projectId');		
		currentPOLineItem_TaskId = checkForId('taskId');
		poLineItemId  = checkForId('Id');

		Initialize();
	}

	/**
	 *  
	 *
	 * @Author  NTT Data - Brad Furdyk, Sanchivan, Deborah Orth
	 * @Date    2015
	 *
	 * @param	
	 * @return 	Boolean
	 **/
	private Boolean getInvoiceStatus(){
		Boolean result = false;
		List<POStatus__c> poStatuses = [SELECT Id, AP_Invoice__c
										FROM POStatus__c 
										WHERE POHeader__c = :currentPOLineItem.POHeader__c];
		if(!poStatuses.isEmpty()){
			if(poStatuses.get(0).AP_Invoice__c != null){
				//result = true;
			}
		}
		return result;
	}

	/**
	 *  
	 *
	 * @Author  NTT Data - Brad Furdyk, Sanchivan, Deborah Orth
	 * @Date    2015
	 *
	 * @param	
	 * @return 	
	 **/
	private void getPOLineItem(){
		currentPOLineItem = new POLineItem__c();
		
		if(poLineItemId != null){
			currentPOLineItem = ECO_Service_PurchaseOrders.GetPurchaseOrderLineItem(poLineItemId);
							
			if(currentPOLineItem == null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find PO Line Item with Id = ' + poLineItemId + '!'));
				return;
			}else{

				editType = 'Edit';
				if(currentPOLineItem.ProjectTask__c != null){
					currentPOLineItem_TaskName = currentPOLineItem.ProjectTask__r.ProjectTaskNumber__c + ' (' + currentPOLineItem.ProjectTask__r.Name + ')';
					currentPOLineItem_TaskId = currentPOLineItem.ProjectTask__c;
				}
				poHeaderId = currentPOLineItem.POHeader__c;
				projectId = currentPOLineItem.POHeader__r.Project__c;	
				if(currentPOLineItem.OracleSyncDateTime__c != null){
					hasBeenSynced = true;
					this.cancelButtonText = 'Cancel Purchase Order Line Item';
				}
				previousVersions = ECO_Service_PurchaseOrders.getPreviousPurchaseLineItemVersions(poLineItemId);
				if(!previousVersions.isEmpty()){
					hasPreviousVersions = true;
				}
			}
		}    	
	}

	/**
	 *  
	 *
	 * @Author  NTT Data - Brad Furdyk, Sanchivan, Deborah Orth
	 * @Date    2015
	 *
	 * @param	
	 * @return 	Decimal
	 **/
	private Decimal getDefaultLineNumber(){
		Decimal result = 1;

		List<POLineItem__c> existingPOLineItems = [SELECT LineNumber__c 
													FROM POLineItem__c 
													WHERE POHeader__c = :poHeaderId
													ORDER BY LineNumber__c DESC LIMIT 1];
		if(!existingPOLineItems.isEmpty()){
			result = existingPOLineItems.get(0).LineNumber__c + 1;
		}
		return result;
	}

	/**
	 *  
	 *
	 * @Author  NTT Data - 
	 * @Date    2015
	 *
	 * @param	
	 * @return 	
	 **/
	private void setDefaults(){
		this.cancelButtonText = 'Delete';
		this.hasBeenInvoiced = false;
		this.hasBeenSynced = false;
		this.hasPreviousVersions = false;
		this.previousVersions = new List<POLineItem__c>();
	}

	/**
	 *  
	 *
	 * @Author  NTT Data - Brad Furdyk, Sanchivan, Deborah Orth
	 * @Date    2015
	 *
	 * @param	
	 * @return 	
	 **/
	private void Initialize(){
		projectTasks = new List<pse__Project_Task__c>();
		taskFilter = '';

		searchTaskName = '';		

		//coming from po summary page or coming from task detail
		if((projectId != null && poHeaderId != null) || (poLineItemId != null) ){
			if(projectId != null)
			getTasksForProject();
			POHeader__c poHeader = [SELECT Name, CurrencyIsoCode FROM POHeader__c WHERE Id = :poHeaderId];
			poHeaderName = poHeader.Name;
			
			if(poLineItemId == Null) {
				currentPOLineItem.CurrencyIsoCode = poHeader.CurrencyIsoCode;
			}
			this.editType = 'Add';    	
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have reached this page incorrectly. Project Id is missing!'));
			return;
		}

		if(ApexPages.currentPage().getParameters().containsKey('retUrl') || ApexPages.currentPage().getParameters().containsKey('retURL')){
			this.retUrl = ApexPages.currentPage().getParameters().get('retUrl');
		}else{
			this.retUrl = '/apex/ECO_PurchaseOrderSummary?id=' + poHeaderId;
		}
	}

	/*public void setSelectedTask(){
		/*

		List<pse__Project_Task__c> tasks = [SELECT Id, Name FROM pse__Project_Task__c WHERE Id = :currentPOLineItem_TaskId];
		if(!tasks.isEmpty()){
			currentPOLineItem_TaskName = tasks.get(0).Name;
		}		
		*/
	//}

	/**
	 *  
	 *
	 * @Author  NTT Data - Brad Furdyk, Sanchivan, Deborah Orth
	 * @Date    2015
	 *
	 * @param	
	 * @return 	PageReference
	 **/
	public PageReference saveCurrentPOLineItem(){
		//todo - validation if invoiced
		PageReference pageRef = null;

		Boolean validationOK = true;
		String validationMsg = '';

		if(!String.isEmpty(currentPOLineItem_TaskId)){
			currentPOLineItem.ProjectTask__c = Id.valueOf(currentPOLineItem_TaskId);
		}else{
			validationMsg += '<li>A task must be selected.</li>';
			validationOK = false;
		}
		if(String.isEmpty(currentPOLineItem.ExpenditureType__c)){
			validationMsg += '<li>An expenditure type be selected.</li>';
			validationOK = false;
		}
		if(String.isEmpty(currentPOLineItem.LineDescription__c)){
			validationMsg += '<li>A line description must be completed.</li>';
			validationOK = false;
		}

		system.debug('currentPOLineItem.LineType__c = ' + currentPOLineItem.LineType__c);
		if(currentPOLineItem.LineType__c == 'Unit Rate'){
			if(currentPOLineItem.Quantity__c != null &&  currentPOLineItem.UnitPrice__c != null && currentPOLineItem.Quantity__c != 0 && currentPOLineItem.UnitPrice__c != 0){
				currentPOLineItem.Amount__c = currentPOLineItem.Quantity__c * currentPOLineItem.UnitPrice__c;
			}else{
				validationMsg += '<li>Quantity and Unit Price must be completed if the Line Type is "Unit Rate"</li>';
				validationOK = false;
			}			
		}else{
			system.debug('currentPOLineItem.Amount__c = ' + currentPOLineItem.Amount__c);
			if(currentPOLineItem.Amount__c == null || currentPOLineItem.Amount__c != 0){
				currentPOLineItem.Quantity__c = currentPOLineItem.Amount__c;
				currentPOLineItem.UnitPrice__c = 1;
			}else{
				validationMsg += '<li>Line Amount must be completed if the Line Type is "Fixed Fee"</li>';
				validationOK = false;
			}						
		}

		if(!validationOK){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '<ul>' + validationMsg + '</ul>'));
			return null;
		}

		if(currentPOLineItem.Id == null){	
			//check that line number isn't already in use
			List<POLineItem__c> existingPOLineItems = [SELECT LineNumber__c 
														FROM POLineItem__c 
														WHERE POHeader__c = :currentPOLineItem.POHeader__c 
														AND LineNumber__c = :currentPOLineItem.LineNumber__c];

			if(!existingPOLineItems.isEmpty()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Line Number ' + currentPOLineItem.LineNumber__c + ' has already been used. Please enter a different value for the Line Number.'));
				return null;
			}
		}
		
		// Check PO Date validation
		POHeader__c poHeader = [SELECT Id, PO_Date__c, Status__c FROM POHeader__c WHERE Id =:currentPOLineItem.POHeader__c];
		pse__Project_Task__c projectTask = [SELECT Id, pse__Start_Date__c, pse__End_Date__c FROM pse__Project_Task__c WHERE Id =:currentPOLineItem.ProjectTask__c];
		//if(poHeader.PO_Date__c < projectTask.pse__Start_Date__c || poHeader.PO_Date__c > projectTask.pse__End_Date__c) {
		//	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Task Selected is not valid. The PO Date is not within the Task range!!!'));
		//	return null;
		//}		        

		Savepoint sp = Database.setSavepoint();

		try{
			if(currentPOLineItem.Id == null){	
				insert currentPOLineItem;					
			}else{

				if(hasBeenSynced){
					//create a clone of the original to use for reference
					POLineItem__c snapshot = ECO_Service_PurchaseOrders.ClonePurchaseOrderLineItemForChangeRequest(currentPOLineItem.Id);
					snapshot.Revision__c = previousVersions.size();
					insert snapshot;

					currentPOLineItem.OracleSyncStatus__c = null;
					currentPOLineItem.OracleSyncDatetime__c = null;
					currentPOLineItem.Revision__c = previousVersions.size() + 1;
					update currentPOLineItem;

				}else{
					update currentPOLineItem;
				}                             
			}	
			
			// Sanchivan: Added code to set the Status to Pending if a PO Line Item is added or edited.
			// Bug 1645
			//POHeader__c poHeader = [SELECT Id, Status__c FROM POHeader__c WHERE Id = :currentPOLineItem.POHeader__c];
			if(poHeader.Status__c == 'APPROVED') {
				poHeader.Status__c = 'UNAPPROVED';                
				update poHeader;                    
			} 
			
			pageRef = returnToPurchaseOrder();
		}catch(Exception e){
			Database.rollback(sp);
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			ECO_Service_ErrorLog.formatPageError(e, 'An error has occurred while saving the Purchase Order Line Item: '+e);
		}
		return pageRef;
	}

	/**
	 *  
	 *
	 * @Author  NTT Data - Brad Furdyk, Sanchivan, Deborah Orth
	 * @Date    2015
	 *
	 * @param	
	 * @return 	PageReference
	 **/
	public PageReference cancelPurchaseOrderLineItem(){
		PageReference result = null;
		Savepoint sp = Database.setSavepoint();

		Decimal prevRevisonNumber = 0;

		try{
			if(!hasBeenSynced){				
				if(hasPreviousVersions){
					//if this was an unsynced change order then unarchive the previous version
					prevRevisonNumber = currentPOLineItem.Revision__c - 1;
					POLineItem__c prevVersion = [SELECT Id, 
													OracleSyncStatus__c, 
													OracleSyncDatetime__c
													FROM POLineItem__c
													WHERE ChangeRequestPOLineItem__c = :poLineItemId
													AND Revision__c = :prevRevisonNumber 
													LIMIT 1];
		
					currentPOLineItem = ECO_Service_PurchaseOrders.ClonePurchaseOrderLineItemForChangeRequest(prevVersion.Id);
					currentPOLineItem.Revision__c = prevRevisonNumber;
					currentPOLineItem.IsArchived__c = false;
					currentPOLineItem.Id = poLineItemId;
					update currentPOLineItem;

					delete prevVersion;

				}else{
					delete currentPOLineItem;
				}			

				result = returnToPurchaseOrder();
			}else{
				POLineItem__c snapshot = ECO_Service_PurchaseOrders.ClonePurchaseOrderLineItemForChangeRequest(currentPOLineItem.Id);
				snapshot.Revision__c = previousVersions.size();
				insert snapshot;

				currentPOLineItem.OracleSyncStatus__c = null;
				currentPOLineItem.OracleSyncDatetime__c = null;
				currentPOLineItem.CancelFlag__c = true;
				currentPOLineItem.Revision__c = previousVersions.size() + 1;
				update currentPOLineItem;

				result = returnToPurchaseOrder();
			}
		}catch(Exception e){
			Database.rollback(sp);
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred while deleting or canceling the Purchase Order Line Item: ' + e.getMessage()));
			ECO_Service_ErrorLog.formatPageError(e, 'An error has occurred while deleting or canceling the Purchase Order Line Item: ');
		}
		return result;
	}
	
	/**
	 *  sends the user back to the PO page, &retUrl, when they click the button
	 *
	 * @Author  NTT Data - Brad Furdyk, Sanchivan, Deborah Orth
	 * @Date    2015
	 *
	 * @param	
	 * @return 	PageReference
	 **/
	public PageReference returnToPurchaseOrder(){
		PageReference pageRef = new PageReference(retUrl);
		pageRef.setRedirect(true);
		return pageRef;
	}

	/**
	 *  Gets a list of tasks for this project and displays them all for the user to select from, only isChargeable FinancialTasks are
	 *  eligible for selection by the user
	 *
	 * @Author  NTT Data - Brad Furdyk, Sanchivan, Deborah Orth
	 * @Date    2015
	 *
	 * @param	
	 * @return 	
	 **/
	public void getTasksForProject(){
		String soql = 'SELECT Id, Name, ProjectTaskNumber__c, FinancialTask__c, BillTo__c, ShipTo__c,	pse__End_Date__c, ';
		soql +=	'pse__Start_Date__c, IsBillable__c, IsChargeable__c, WorkTypeName__c, pse__Parent_Task__r.Name ';
		soql += 'FROM pse__Project_Task__c ';
		soql += 'WHERE pse__Project__c = :projectId ';
		if(!String.isEmpty(searchTaskName)){
			soql += 'AND Name LIKE \'%' + String.escapeSingleQuotes(searchTaskName) + '%\' ';
		}
		//soql += 'LIMIT ' + pagingResultSize; removed DJO 5/10/2016 issue 4676

		system.debug('soql = ' + soql);
		
		projectTasks = Database.query(soql);
		system.debug('projectTasks size = ' + projectTasks.size());
		 if(projectTasks.isEmpty()){
			noSearchResults = true;
		}else{
			noSearchResults = false;
		}
	}

	/**
	 *  looks for a specific Id, one of 3 possible types; HeaderPO, Project or Task
	 *
	 * @Author  NTT Data - Brad Furdyk, Sanchivan, Deborah Orth
	 * @Date    2015
	 *
	 * @param	paramName - the arg name from the URL
	 * @return 	Id
	 **/
	private Id checkForId(String paramName){
		Id result = null;
		if(ApexPages.currentPage().getParameters().containsKey(paramName)){
			result = Id.valueOf(ApexPages.currentPage().getParameters().get(paramName));          
		}
		return result;
	}

	/**
	 *  Refactored from the following client-side Javascript function which does not handle locales correctly:
	 *
	 *			function calculateTotalForGoods(){
	 *			
	 *			var hasBeenInvoiced = "{!hasBeenInvoiced}";
	 *			var unitPrice = j$.trim(j$("[id*=poliUnitPrice]").val());
	 *			if(hasBeenInvoiced == "true"){
	 *				unitPrice = j$.trim(j$("[id*=changedUnitPrice]").val());  // GM: near as I can tell, this is the old value
	 *			}else{
	 *				unitPrice = j$.trim(j$("[id*=poliUnitPrice]").val());  // GM: what the hell? (see 4 lines up)
	 *			}
	 *			
	 *			var quantity = j$.trim(j$("[id*=poliQuantity]").val());
	 *			
	 *			if(unitPrice.length > 0 && quantity.length > 0){	
	 *				if(j$.isNumeric(parseFloat(unitPrice)) && j$.isNumeric(parseFloat(quantity))){
	 *					var amtTotal = parseFloat(unitPrice) * parseFloat(quantity);	
	 *					amtTotal = amtTotal.toFixed(2); 						
	 *					j$("[id*=poliAmount]").val(amtTotal);					
	 *				}
	 *			}
	 *		}
 	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2017
	 **/

	public void calculateTotalForGoodsService() {
		Decimal unitPrice = currentPOLineItem.UnitPrice__c;

		if (unitPrice != null) {
			unitPrice.setScale(2);
			currentPOLineItem.UnitPrice__c = unitPrice;
		}

		// JS function checks hasBeenInvoiced, but in that case field is read-only and couldn't have changed
		// 'changedUnitPrice' in JS function is just a cached version of the old value anyway

		Decimal quantity = currentPOLineItem.Quantity__c;

		if (quantity != null) {
			quantity.setScale(2);
			currentPOLineItem.Quantity__c = quantity;
		}

		if ((unitPrice != null) && (quantity != null)) {
			Decimal amtTotal = unitPrice * quantity;
			amtTotal.setScale(2);

			currentPOLineItem.Amount__c = amtTotal;
		}
	}
}