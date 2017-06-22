/** ------------------------------------------------------------------------------------------------------
* @Description The controller for the ECO_PurchaseOrderSummary page.  This page allows POs to track committed
* costs against the project and ensure complience with financial policies.
*
* @Author      NTT Data - ?, Deborah Orth
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_PurchaseOrderSummaryController {
	public class POException extends Exception {}

	public string sJSON {get; set;}
	
	private Id purchaseOrderId;
	private Id messageQueueId;
	private String messageQueueJobName;

	public Integer numSuccessfulSyncs {get; private set;}
	public Integer numFailedAttemptedSyncs {get; private set;}

	private DateTime lastSync;

	public List<POLineItem__c> poLineItems{get; set;}
	public List<nonSyncItem> invalidPOLineItems {get;set;}
	public List<POLineItem__c> validPOLineItems {get;set;}

	public POStatus__c poStatus {get; private set;}
	public List<POStatus__c> poStatusList {get; private set;}

	public String validPOLineItemLimitMsg {get; private set;}
	public String invalidPOLineItemLimitMsg {get; private set;}
	
	public Boolean allowRequestSubmit {get; private set;}
	public String lastSyncStr {get; private set;}

	public Boolean hasSyncHistory {get; private set;}
	public Boolean hasRequestFailures {get; private set;}
	public List<syncHistoryHelper> syncHistory {get; private set;}
	public List<syncHistoryHelper> requestFailures {get; private set;}

	public String retUrl {get; private set;}

	public Integer numInvalidPOLineItems {get; private set;}
	public Integer numValidPOLineItems {get; private set;}
	
	public POHeader__c poHeader {get;set;}

	public boolean allowNewPOLineItems {get; private set;}

	private String poLineItemMsg;
	private Id projectId;
	private Id agreementId;
	private Boolean isFromAgreement; 
	private ProjectTeamMember__c projectManager;

	public boolean hideEverything {get; private set;}
	public boolean allowPOHeaderSave {get; private set;}
	public boolean allowPOCloseout {get; private set;}
	public boolean allowPOCancel {get; private set;}
	
	public String validationMsgSummary {get; private set;}
	public Boolean showValidationMsg {get; private set;}

	public String savePOBtnValue {get; private set;}
	public String returnBtnValue {get; private set;}

	public List<SelectOption> optSelectProjectSites {get; private set;}
	public String selProjectSiteId {get;set;}

	public List<SelectOption> optAgreements {get; private set;}

	public String agreementIdentifier {get; private set;}

	public Boolean canEditHeader {get; private set;}

	public Boolean pendingApproval {get; private set;}

	private Boolean useApprovalProcess;

	public String syncProgressMsg {get;set;}
	private boolean syncErrorOccurred = false;

	@TestVisible
	private List<String> stepMsgs;

	private Integer intProgressBarNumCells;
	private String progressErrors;

	public Boolean pollMessageQueue {get; private set;}
	public Boolean showPollingMsg {get; private set;}
	public String pollingMessageQueueMsg {get; private set;}
	public String pollingMessageQueueMsgBottom {get; private set;}
	public String purchaseOrderSyncProcessingResult {get; private set;}

	private String syncAttemptResult;

	public Boolean isApprovedDoSyncNow {get; private set;}
	
	public Decimal totalPurchaseOrderLineAmount{get; private set;}
	public Decimal totalAllocatedAmount{get; private set;}
	public Decimal totalRemainingAmount{get; private set;}
	
	public Boolean IsOracleTokenValid{get; private set;}
	
	public String OracleUserName {get; set;}
	public String OraclePassword {get; set;}
	public String authenticationResult {get; set;}

	/**
	 * Constructor for the class - it initializes flags, properties and lists
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   stdController - the standard controller for the page, a POHeader__c object
	 * @return  
	 **/
	public ECO_PurchaseOrderSummaryController(ApexPages.StandardController stdController) {        

		POHeader__c rec = (POHeader__c)stdController.getRecord();

		purchaseOrderId = rec.Id;

		hideEverything = false;
		isApprovedDoSyncNow = false;
		poHeader = new POHeader__c();
		allowNewPOLineItems = false;
		allowRequestSubmit = true;
		poIsClosedOutOrClosedOut = false;
		allowPOCloseout = false;	
		allowPOCancel = false;	
		poLineItemMsg = '';
		validationMsgSummary = '';
		showValidationMsg = false;
		returnBtnValue = 'Return to Project';
		isFromAgreement = false;
		allowPOHeaderSave = true;
		pendingApproval = false;
		agreementIdentifier = '';

		useApprovalProcess = true;	//false = to allow oracle group to generate po's for testing, otherwise should be true

		numSuccessfulSyncs = 0;
		numFailedAttemptedSyncs = 0;

		vendorSites = new List<VendorSite__c>();
		optSelectProjectSites = new List<SelectOption>();
		optAgreements = new List<SelectOption>();
		poStatus = new POStatus__c();
		
		reload();
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public PageReference escalateApproval(){
		try{


			poHeader.FlagForEscalate__c = true;
			update poHeader;

			PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
			pageRef.getParameters().put('id', poHeader.Id);
			pageRef.setRedirect(true);          

			return pageRef; 
			
		} catch(Exception e){
			//ApexPages.addMessages(e);
			ECO_Service_ErrorLog.formatPageError(e, 'An error has occurred while Escalating Approval: ');
			
		}
		return null;
	}


	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void reload() {
		canEditHeader = false;

		if(purchaseOrderId == null) {
			savePOBtnValue = 'Add Purchase Order Lines';
			allowRequestSubmit = false;
			projectId = checkForUrlIdParam('projectId');
			agreementId = checkForUrlIdParam('agreementId');
			poHeader.PO_Date__c = Date.today();
			
			if(projectId == null && agreementId == null) {
				ECO_Service_ErrorLog.formatPageError('You have reached this page incorrectly. A Project Id or Agreement Id is missing!', ApexPages.Severity.ERROR);

				hideEverything = true;
				return;
			} else if(projectId == null && agreementId != null) {
				projectId = [SELECT Project__c FROM Agreement__c WHERE Id = :agreementId].Project__c;

				if(projectId == null) {
					ECO_Service_ErrorLog.formatPageError('A Project must be selected for the Agreement! Please return the the Agreement and select a Project.', ApexPages.Severity.WARNING);
					allowPOHeaderSave = false;
					returnBtnValue = 'Return to Agreement';
					isFromAgreement = true;
					return;
				}				
			}

			if(projectId != null) {
				projectManager = getProjectManager();
				poHeader.Project__c = projectId;
				if(projectManager != null){
					poHeader.Requestor__c = projectManager.Contact__c;
				}  

				if(poHeader.ProjectApprover__c == null){
					poHeader.ProjectApprover__c = ECO_Service_ProjectTeam.getActiveProjectApproverId(projectId);       
				}

				pse__Proj__c project = [SELECT Id, CurrencyISOCode FROM pse__Proj__c WHERE Id =: projectId];
				poHeader.CurrencyIsoCode = project.CurrencyISOCode; 
				//System.debug('Purchase Order CurrencyIsoCode set');
			}
				
			if(agreementId != null) {
				poHeader.Agreement__c = agreementId;
				returnBtnValue = 'Return to Agreement';
				isFromAgreement = true;
			}
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Click \'Add Purchase Order Lines\' to create a new Purchase Order.'));
			ECO_Service_ErrorLog.formatPageError('Click \'Add Purchase Order Lines\' to create a new Purchase Order.', ApexPages.Severity.INFO);
			
		} else {
			savePOBtnValue = 'Save Purchase Order';
			poHeader = ECO_Service_PurchaseOrders.GetPurchaseOrder(purchaseOrderId);

			if(!String.isEmpty(poHeader.Agreement__r.VendorSite__r.AccountName__c)) {
				agreementIdentifier = poHeader.Agreement__r.VendorSite__r.AccountName__c + ' ' +  poHeader.Agreement__r.Name;		
			}else {
				agreementIdentifier = poHeader.Agreement__r.Name;
			}
				
			projectId = poHeader.Project__c;
			agreementId = poHeader.Agreement__c;
			selProjectSiteId = poHeader.VendorSite__c;
			projectManager = getProjectManager();
						
			if(poHeader.CancelFlag__c || poHeader.Status__c == 'Closeout') {
				poIsClosedOutOrClosedOut = true;
			}
			
			if(agreementId != null && projectId == null) {
				returnBtnValue = 'Return to Agreement';
				isFromAgreement = true;
			}

			if(poHeader.VendorSite__c != null){
				allowNewPOLineItems = true;
			}
			
			allowPOHeaderSave = false;	//can't update poheader - fields will be read only
			if(!String.isEmpty(poHeader.OraclePurchaseOrderId__c)){
				allowPOCancel = true;	
				
				List<POStatus__c> poStatuses = ECO_Service_PurchaseOrders.GetPurchaseOrderStatuses(purchaseOrderId);
				if(!poStatuses.isEmpty()){
					poStatus = poStatuses.get(0);
					if(poStatus.AP_Invoice__c != null){
						allowPOCloseout = true;	
						allowPOCancel = false;
					}
				}                
			}
			pendingApproval = isPurchasedOrderPendingApproval();    		
		}

		optSelectProjectSites = getVendorProjectSites();
		optAgreements = getProjectAgreements();

		poLineItems = new List<POLineItem__c>();
		//distributions = new List<Distribution__c>();

		//currentPOLineItem = new POLineItem__c();
		//currentPOLineItem_Id = '';

		retUrl = '/apex/' + ApexPages.currentPage().getUrl().split('/apex/')[1];

		//taskFilter = '';
		//noSearchResults = true;

		messageQueueId = null;
		messageQueueJobName = '';
		sJSON = '';

		validPOLineItemLimitMsg = '';
		invalidPOLineItemLimitMsg = '';
		//validDistributionLimitMsg = '';
		//invalidDistributionLimitMsg = '';
	
		hasSyncHistory = false;
		hasRequestFailures = false;

		numInvalidPOLineItems = 0;
		numValidPOLineItems = 0;
		//numInvalidDistributions = 0;
		//numValidDistributions = 0;
	
		invalidPOLineItems = new List<nonSyncItem>();
		validPOLineItems = new List<POLineItem__c>();

		//invalidDistributions = new List<nonSyncItem>();
		//validDistributions = new  List<Distribution__c>();

		if(purchaseOrderId != null) {
			sJSON = ECO_Service_PurchaseOrders.createPurchaseOrderMessageWrapperJSON(purchaseOrderId, null);
			poHeader = ECO_Service_PurchaseOrders.GetPurchaseOrder(purchaseOrderId);

			//get last sync date to use to filter out items that have changed
			lastSync = ECO_Service_PurchaseOrders.getLastSuccessfulSyncDateTime(purchaseOrderId, messageQueueJobName);
			lastSyncStr = 'The project has not yet been synced';
			if(lastSync == null) {
				lastSync = DateTime.newInstance(1900, 1, 1);
			} else {
				lastSyncStr = 'Last sync: ' + lastSync.format();
			}
			lastSyncStr = 'Last sync: ' + lastSync.format();

			validatedAndDisplayWarnings();

			poStatusList = ECO_Service_PurchaseOrders.GetPurchaseOrderStatuses(purchaseOrderId);
			if(!poStatusList.isEmpty()){
				poStatus = poStatusList.get(0);
			}
			totalAllocatedAmount = 0.0;
			totalRemainingAmount = 0.0;

			for( POStatus__c poStatus : poStatusList) {
				if( poStatus.APinvLineFunctAmount__c != Null){
					this.totalAllocatedAmount += poStatus.APinvLineFunctAmount__c;
				}
			}
			
			this.totalRemainingAmount = this.totalPurchaseOrderLineAmount - this.totalAllocatedAmount;
		}
		
		messageQueueJobName = ECO_Service_PurchaseOrders.JOBNAME_PO_SYNC;	//NOT SURE IF THIS NEEDS TO BE DIFFERENT VALUE OR NOT

		generateSyncHistory();

		if(!hasSyncHistory && !pendingApproval){
			canEditHeader = true;
		}
		//System.debug('ProjectId: ' + projectId);

		Boolean isVendor = false;
		Boolean hasVendorSite = false;
		List<VendorSite__c> vendorSites = [SELECT Type__c FROM VendorSite__c WHERE Id =: selProjectSiteId LIMIT 1];
		if(vendorSites.size() > 0){ 
			if(vendorSites[0].Type__c == 'Vendor'){ isVendor = true; }
			hasVendorSite = true;
		}
		if(hasVendorSite && !isVendor && agreementId == null){
			allowRequestSubmit = false;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Agreement is required.'));
		}
	}
	

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void refreshJSON(){
		sJSON = ECO_Service_PurchaseOrders.createPurchaseOrderMessageWrapperJSON(purchaseOrderId, messageQueueId);
	}	

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void getDefaultPaymentTermsForVendor(){
		//System.debug('---Entering getDefaultPaymentTermsForVendor');
		if(!vendorSites.isEmpty() && selProjectSiteId !=''){
			for(VendorSite__c projSite : vendorSites){



				if(projSite.Id == selProjectSiteId){

					string myStr = string.valueof(projSite.Type__c);
					if (myStr == 'Sub')
					{
						//System.debug('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX Type = ' + projSite.Type__c);
					}
					poHeader.VendorSite__c = projSite.Site__r.Id;
					poHeader.PaymentTerm__c = projSite.Site__r.PaymentTerms__c;
				}
			}
		}
		optAgreements = getProjectAgreements();
		//System.debug('---Exiting getDefaultPaymentTermsForVendor');
	}
	
	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private ProjectTeamMember__c getProjectManager(){
		ProjectTeamMember__c result = null;
		
		List<ProjectTeamMember__c> pm = ECO_Service_ProjectSync.getProjectManagerForProject(projectId);
		if(!pm.isEmpty()){
			result = pm.get(0);
		}
		return result;
	}

	private List<VendorSite__c> vendorSites;

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private List<SelectOption> getVendorProjectSites(){
		List<SelectOption> results = new List<SelectOption>();

		try{
			vendorSites = [SELECT Id, 
								AccountName__c,
								Site__r.PaymentTerms__c,
								Type__c,
								Site__r.OUID__c,
								Project__r.OUID__c
							FROM VendorSite__c
							WHERE Project__c = :projectId
							AND IsVendor__c = true
							ORDER BY AccountName__c ASC];
		} catch (Exception e){
			ECO_Service_ErrorLog.formatPageError(e, 'Error while searching for applicable VendorSites: ' + e.getMessage());
		}

		results.add(new SelectOption('', '-- Choose Vendor --'));
	
		if(!vendorSites.isEmpty()){
			for(VendorSite__c psite : vendorSites){   	
				if(psite.Site__r.OUID__c == psite.Project__r.OUID__c){		
					 results.add(new SelectOption(String.valueOf(psite.Id), psite.AccountName__c));
				}
			}

			poHeader.PaymentTerm__c = vendorSites.get(0).Site__r.PaymentTerms__c;
		}	

		return results;
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private List<SelectOption> getProjectAgreements(){
		List<SelectOption> results = new List<SelectOption>();
		//System.debug('---Entering getProjectAgreements: ' + selProjectSiteId);
		List<Agreement__c> projectAgreements = [SELECT
													Id, 
													Name,    
													VendorSite__r.AccountName__c,
													AgreementNumber__c
												FROM
													Agreement__c
												WHERE
													Project__c = :projectId AND VendorSite__c =: selProjectSiteId AND VendorSite__c != Null];

		results.add(new SelectOption('', '-- Choose Agreement --'));											

		if(!projectAgreements.isEmpty()){
			for(Agreement__c agreement : projectAgreements){
				String vendorName = '';
				if(!String.isEmpty(agreement.VendorSite__r.AccountName__c)){
					vendorName = agreement.VendorSite__r.AccountName__c + ' ';
				}
				String agreementIdentifier =  vendorName + agreement.AgreementNumber__c;

				results.add(new SelectOption(String.valueOf(agreement.Id), agreementIdentifier));
			}
		}
		//System.debug('---Exiting getProjectAgreements');
		return results;
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private Id checkForUrlIdParam(String param){
		Id result = null;
		if(ApexPages.currentPage().getParameters().containsKey(param)){
			result = Id.valueOf(ApexPages.currentPage().getParameters().get(param));          
		}
		return result;
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private void displayValidationMessage(){
		validationMsgSummary = '';

		if(!String.isEmpty(poLineItemMsg)){
			showValidationMsg = true;
			validationMsgSummary = 'The purchase order cannot be synced due to missing information on the purchase order or related items:<ul>' + poLineItemMsg + '</ul>';
		}else{
			showValidationMsg = false;
		}		
	}

	/*private Boolean isPurchasedOrderApproved(){
		Boolean result = false;
		List<ProcessInstance> approvalProcess = [SELECT Status, SystemModstamp 
												 FROM ProcessInstance
												 WHERE TargetObjectId = :poHeader.Id
												 ORDER BY SystemModstamp DESC];
		if(!approvalProcess.isEmpty()){
			if(approvalProcess.get(0).Status.equalsIgnoreCase('Approved')){
				result = true;
			}
		}
		return result;
	}*/

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private Boolean isPurchasedOrderPendingApproval(){
		Boolean result = false;
		List<ProcessInstance> approvalProcess = [SELECT Status, 
													SystemModstamp 
												FROM ProcessInstance
												WHERE TargetObjectId = :poHeader.Id
												ORDER BY SystemModstamp DESC];
		if(!approvalProcess.isEmpty()){
			if(approvalProcess.get(0).Status.equalsIgnoreCase('Pending')){
				result = true;
			}
		}else{
			//no approval sumbmissions yet - po status is Pending but is not actually pending an approval
			result = false;
		}
		return result;
	}	

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private Boolean savePurchaseOrder(){
		Boolean saveSuccessful = false;

		try {
			if(selProjectSiteId == null) {
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Vendor Site has not been selected and must be picked before saving the Purchase Order.'));
				ECO_Service_ErrorLog.formatPageError('The Vendor Site has not been selected and must be picked before saving the Purchase Order.', ApexPages.Severity.ERROR);
				return saveSuccessful;
			}

			poHeader.VendorSite__c = Id.valueOf(selProjectSiteId);
			
			// Validate the PO Date
			//if(poHeader.Id != Null) {
			//	List<POLineItem__c> poLineItems = [SELECT Id, ProjectTask__r.pse__Start_Date__c, ProjectTask__r.pse__End_Date__c FROM POLineItem__c WHERE POHeader__c =:poHeader.Id];
			//	for(POLineItem__c poLineItem : poLineItems) {
			//		if(poHeader.PO_Date__c < poLineItem.ProjectTask__r.pse__Start_Date__c || poHeader.PO_Date__c > poLineItem.ProjectTask__r.pse__End_Date__c) {
			//			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The PO Date is not a valid PO Date. PO Date must fall between Task Start and End Date'));
			//			ECO_Service_ErrorLog.formatPageError('The PO Date is not a valid PO Date. PO Date must fall between Task Start and End Date', ApexPages.Severity.ERROR);
			//			return saveSuccessful;
			//		}
			//	}
			//}
			
			List<ProjectTeamMember__c> projectManagers = ECO_Service_ProjectSync.getProjectManagerForProject(projectId);
			if(!projectManagers.isEmpty()){
				poHeader.ProjectManager__c = projectManagers.get(0).Contact__r.pse__Salesforce_User__c;
			}

			//Set Project Approver from Project. Approvals are routed to this user
			if(poHeader.ProjectApprover__c == null){
				poHeader.ProjectApprover__c = ECO_Service_ProjectTeam.getActiveProjectApproverId(projectId);       
			}
			
			if(hasSyncHistory && !syncHistory.isEmpty()) {
				poHeader.ActionFlag__c = 'U';
			}else {
				poHeader.ActionFlag__c = 'C';
			}
			if(poHeader.Id == null) {	
				
				try {
					insert poHeader;
				} catch (Exception e){
					ECO_Service_ErrorLog.logException(e);
				}
				purchaseOrderId = poHeader.Id;						
											
			}else {					
				try {
					update poHeader;
				} catch (Exception e){
					ECO_Service_ErrorLog.logException(e);
				}
			}

			if(poHeader.VendorSite__c != null) {
				allowNewPOLineItems = true;
			}

			saveSuccessful = true;
		}catch(Exception e) {
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred while updating the project! ' + e.getMessage()));
			ECO_Service_ErrorLog.formatPageError('An error has occurred while updating the project! ' + e.getMessage(), ApexPages.Severity.ERROR);
		}

		return saveSuccessful;
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public PageReference saveAndSubmitForApproval() {
		
		isApprovedDoSyncNow = false;

		PageReference pageRef = null;
		
		Id currUserId = UserInfo.getUserId();
		
		pse__Proj__c project = [SELECT 	
									Id, 
									pse__Project_Manager__c, 
									pse__Project_Manager__r.pse__Salesforce_User__c,
									ProjectApprover__r.pse__Salesforce_User__c,
									OwnerId
								FROM 
									pse__Proj__c	
								WHERE 
									Id = :projectId];

		//if(poHeader.ProjectApprover__c == null)
		//    poHeader.ProjectApprover__c = ECO_Service_ProjectTeam.getActiveProjectApproverId(projectId);   

		if(savePurchaseOrder()) {			
			if(poHeader.CancelFlag__c) {
				poIsClosedOutOrClosedOut = true;
			}

			if(useApprovalProcess) {
				
				Boolean isPM = false;				
				
				if(project != null) {
					if(project.pse__Project_Manager__r.pse__Salesforce_User__c != null) {
						if(project.pse__Project_Manager__r.pse__Salesforce_User__c == currUserId) {
							isPM = true;
						}
					}else if(project.OwnerId == currUserId) {	// if no pm is set it's assumed project owner is pm
						isPM = true;
					}
				}
				//system.debug('isPM = ' + isPM);

				Boolean hasPermissionForApprovalProcess = ECO_Service_RecordAccess.getProjectRecordAccessForApprovalProcess ('POHeader__c', project.Id);
				if(isPM && poHeader.Status__c != 'APPROVED') {
					if (! hasPermissionForApprovalProcess)  
					{   
						ECO_Service_ErrorLog.formatPageError('You do not have permission to Submit for Approval', ApexPages.Severity.ERROR);
			
						return null;
					}
					if(project.ProjectApprover__r.pse__Salesforce_User__c != null) {
						POHeader__c poheader = [SELECT Id, ProjectManager__c, ProjectApprover__c FROM POHeader__c WHERE Id =: poHeader.Id];
						poheader.ProjectManager__c = project.ProjectApprover__r.pse__Salesforce_User__c;
						
						//Check if all approvers are active and approved
						list<ECO_Service_ProjectTeam.CheckMember> lstCheckMembers = new list<ECO_Service_ProjectTeam.CheckMember>();
			            lstCheckMembers.add(new ECO_Service_ProjectTeam.CheckMember(project.id, 'Project Approver'));
			            
			            ECO_Service_ProjectTeam.CheckMembers(lstCheckMembers);
			            List<ProjectTeamMember__c> lPTM = new List<ProjectTeamMember__c>();
        
				        for(ECO_Service_ProjectTeam.CheckMember chk: lstCheckMembers){
				            if(chk.errormsg !=null){
			            		ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,chk.errormsg);
								ApexPages.addMessage(oPageMessage);
			                    return null;
				            }
				            else{
				                lPTM.add(chk.approvedPTM);
				            }
				        }
				        
				        if(!lPTM.isEmpty()){
				            for(ProjectTeamMember__c ptm : lPTM){
				                if(ptm.ProjectRole__r.Name == 'Project Approver' && 
				                	(poheader.ProjectApprover__c != ptm.Contact__r.pse__Salesforce_User__c || poheader.ProjectManager__c != ptm.Contact__r.pse__Salesforce_User__c)){
				                    poheader.ProjectApprover__c = ptm.Contact__r.pse__Salesforce_User__c;
				                    poheader.ProjectManager__c = ptm.Contact__r.pse__Salesforce_User__c;
				                }
				                
				            }
				        }

				        try {
							update poheader;
						} catch (Exception e){
							ECO_Service_ErrorLog.formatPageError(e, '' + e.getMessage());
						}
			        }
										
					// Create an approval request for the account
					Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
					req1.setComments('Submitting request for approval.');
					req1.setObjectId(poHeader.Id);
					
					// Submit on behalf of a specific submitter
					req1.setSubmitterId(currUserId); 

					// Submit the record to specific process and skip the criteria evaluation
					req1.setProcessDefinitionNameOrId('EcoPurchaseOrder2');
					
					// Submit the approval request for the account
					Approval.ProcessResult result = Approval.process(req1);
				}else if(poheader.Status__c == 'APPROVED' && isApprovedFromApprovalProcess()){
					isApprovedDoSyncNow = true;
				}else{					
					//system.debug('pm is not user - sending for approval');
					
					List<Contact> lContacts = new List<Contact>([SELECT Id, pse__Salesforce_User__r.Id FROM Contact WHERE Id = :poHeader.Requestor__c]);
					
					Contact oContact = new Contact();
					
					if(lContacts.size() > 0){
						oContact = lContacts.get(0);
					}else{
						throw new POException('No Requestor has been specified or requestor is not a Salesforce user!');
					}

					if (! hasPermissionForApprovalProcess)  
					{   
						ECO_Service_ErrorLog.formatPageError('You do not have permission to Submit for Approval', ApexPages.Severity.ERROR);
			
						return null;
					}
                    
                    //Check if all approvers are active and approved
			        list<ECO_Service_ProjectTeam.CheckMember> lstCheckMembers = new list<ECO_Service_ProjectTeam.CheckMember>();
		            lstCheckMembers.add(new ECO_Service_ProjectTeam.CheckMember(project.id, 'Project Manager'));

		            ECO_Service_ProjectTeam.CheckMembers(lstCheckMembers);
		            List<ProjectTeamMember__c> lPTM = new List<ProjectTeamMember__c>();
        
			        for(ECO_Service_ProjectTeam.CheckMember chk: lstCheckMembers){
			            if(chk.errormsg !=null){
		            		ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,chk.errormsg);
							ApexPages.addMessage(oPageMessage);
		                    return null;
			            }
			            else{
			                lPTM.add(chk.approvedPTM);
			            }
			        }
			        
			        if(!lPTM.isEmpty()){
			            for(ProjectTeamMember__c ptm : lPTM){
			                if(ptm.ProjectRole__r.Name == 'Project Manager' && poheader.ProjectManager__c != ptm.Contact__r.pse__Salesforce_User__c){
			                    poheader.ProjectManager__c = ptm.Contact__r.pse__Salesforce_User__c;
			                }
			                
			            }
			        }

			        try {
						update poheader;
					} catch (Exception e){
						ECO_Service_ErrorLog.formatPageError(e, '' + e.getMessage());
					}
		            
					
					// Create an approval request for the account
					Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
					req1.setComments('Submitting request for approval.');
					req1.setObjectId(poHeader.Id);
					
					// Submit on behalf of a specific submitter
					req1.setSubmitterId(currUserId); 
					
					// Submit the record to specific process and skip the criteria evaluation
					req1.setProcessDefinitionNameOrId('EcoPurchaseOrder2');
					
					// Submit the approval request for the account
					Approval.ProcessResult result = Approval.process(req1);  
				}
			}else{
				isApprovedDoSyncNow = true;
			}					
		}
		
		/*
		poHeader = ECO_Service_PurchaseOrders.GetPurchaseOrder(purchaseOrderId);
		pendingApproval = isPurchasedOrderPendingApproval(); 
		canEditHeader = false;
		
		if(!hasSyncHistory && !pendingApproval){
			canEditHeader = true;
		}
		*/
		reload();
		
		//system.debug('canEditHeader: ' + canEditHeader);
		
		return pageRef;
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private Boolean isApprovedFromApprovalProcess(){
		Boolean result = false;
		List<ProcessInstance> approvalProcess = [SELECT Status, 
													SystemModstamp 
												FROM ProcessInstance
												WHERE TargetObjectId = :poHeader.Id
												ORDER BY SystemModstamp DESC];
		if(!approvalProcess.isEmpty()){
			if(approvalProcess.get(0).Status.equalsIgnoreCase('APPROVED')){
				result = true;
			}
		}
		return result;
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public PageReference updatePurchaseOrder(){
		PageReference pageRef = null;
		if(savePurchaseOrder()){
			pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
			pageRef.getParameters().put('projectId', projectId);
			pageRef.getParameters().put('id', poHeader.Id);
			pageRef.setRedirect(true);			
		}
		return pageRef;	
	}
	
	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void closeOutPurchaseOrder(){
		try{
			poHeader.Status__c = 'CLOSEOUT';
			update poHeader;
			poIsClosedOutOrClosedOut = true;
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Purchase Order flagged as Closeout!<br/>TBD - business rules and validation to check if purchase order can be cancelled.'));
			ECO_Service_ErrorLog.formatPageError('Purchase Order flagged as Closeout!<br/>TBD - business rules and validation to check if purchase order can be cancelled.', ApexPages.Severity.WARNING);
			
		}catch(Exception e){
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'An error has occurred while updating the purchase order: ' + e.getMessage()));
			ECO_Service_ErrorLog.formatPageError(e, 'An error has occurred while updating the purchase order: ' + e.getMessage());
		}
	}

	public Boolean poIsClosedOutOrClosedOut {get; private set;}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void cancelPurchaseOrder(){
		poHeader.CancelFlag__c = true;
		saveAndSubmitForApproval();
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private void validatedAndDisplayWarnings(){
		allowRequestSubmit = true;
		poLineItemMsg = validatePOLineItems();		
		//poHeaderMsg = '';
		displayValidationMessage();
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public PageReference gotoPOLineItemPage(){
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderLineItem');
		pageRef.getParameters().put('projectId', projectId);
		pageRef.getParameters().put('poHeaderId', poHeader.Id);
		pageRef.getParameters().put('retURL', retUrl);
		pageRef.setRedirect(true);
		return pageRef;	
	}

	/*public void doRerenderPOListItems(){
		validatedAndDisplayWarnings();
	}*/

	/** ------------------------------------------------------------------------------------------------------
	* @Description 
	*
	* @Author      NTT Data - ?, Deborah Orth
	* @Date        2015
	*-----------------------------------------------------------------------------------------------------*/
	public class syncHistoryHelper {
		public String syncLocalDateTime {get;set;}
		public IntegrationMessageQueue__c msgQueue {get;set;}
	}
	
	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void initiateOracleSyncRequest(){
		messageQueueId = ECO_Service_PurchaseOrders.createMessageQueueForRequest(poHeader.Id, messageQueueJobName);

		sJSON = ECO_Service_PurchaseOrders.createPurchaseOrderMessageWrapperJSON(purchaseOrderId, messageQueueId);
		//system.debug('controller - initiateOracleSyncRequest - messageQueueId = ' + messageQueueId);
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void executeOracleSyncRequest(){
		syncAttemptResult = '';
		try{
  
			ECO_IntegrationEndpoints__c cs = ECO_IntegrationEndpoints__c.getInstance('Purchase Order Sync');
			String url = cs.EndPointUrl__c;
			
			User user = [select Id, ShaKey__c from User where Id = :UserInfo.getUserId()];
			url = url + '?ebizId=' + user.ShaKey__c + '&pTransType=N';
			//system.debug('endpoint url = ' + url);

			String resp = '';
		
			resp = ECO_Service_PurchaseOrders.initiateOracleSyncRequest(purchaseOrderId, url, messageQueueId);
		
			//system.debug('resp at controller level = ' + resp);
			
			syncAttemptResult = checkResults();
			if(String.isEmpty(syncAttemptResult)){	//no message logged in msgqueue table for some reason
				syncAttemptResult = resp;
			}

			//system.debug('syncAttemptResult from resp at controller level = ' + syncAttemptResult);
			//system.debug('syncErrorOccurred = ' + syncErrorOccurred);
		}catch(Exception e){
			syncAttemptResult = 'Request has returned an error. Response is : ' + e.getMessage();
			syncErrorOccurred = true;
		}

		generateSyncHistory();			
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private String checkResults(){
		String result = '';

		List<IntegrationMessageQueue__c> msgQueueResults = [SELECT Id, Status__c, SuccessMessage__c, ErrorMessage__c 
													FROM IntegrationMessageQueue__c
													WHERE Id = :messageQueueId];
		
		if(msgQueueResults.isEmpty()){
			result = 'Unable to find message queue record for this request!';
			syncErrorOccurred = true;
		}else{
			IntegrationMessageQueue__c msgQueueResult = msgQueueResults.get(0);
			if(msgQueueResult.Status__c == ECO_Service_PurchaseOrders.STATUS_SUCCESS){
				

				String poInfoJson = msgQueueResult.SuccessMessage__c;
				ECO_Service_PurchaseOrders.POSuccessResponseJson poInfo = (ECO_Service_PurchaseOrders.POSuccessResponseJson)JSON.deserialize(poInfoJson, ECO_Service_PurchaseOrders.POSuccessResponseJson.class);

				poHeader.OraclePurchaseOrderNumber__c = poInfo.PO_NUMBER;
				poHeader.OraclePurchaseOrderId__c = poInfo.PO_HEADER_ID;
				result = 'Request successfully processed - Oracle PO Number: ' + poInfo.PO_NUMBER;

				if(poHeader.CancelFlag__c){	//po has been cancelled
					poHeader.Status__c = 'Cancelled';
				}

				try {
					update poHeader;
				} catch (Exception e){
					ECO_Service_ErrorLog.logException(e);
				}
			}else{
				result = msgQueueResult.ErrorMessage__c;
				syncErrorOccurred = true;
			}	    	
		}
		
		//system.debug('checkResults result = ' + result);
		
		return result;
	}    

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private String checkForEmpty(String stringIn, String fieldLabel){
		String result = '';
		if(String.isEmpty(stringIn)){
			result = fieldLabel + ', ';
		}
		return result;
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public PageReference returnToProject(){
		PageReference pageRef = new PageReference('/' + projectId);
		if(isFromAgreement || projectId == null){
			pageRef = new PageReference('/' + agreementId);
		}
		pageRef.setRedirect(true);
		return pageRef;
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private void generateSyncHistory(){
		if(poHeader.Id != null){

			numSuccessfulSyncs = 0;
			numFailedAttemptedSyncs = 0;

			Set<String> successStatus = new Set<String>{ ECO_Service_PurchaseOrders.STATUS_SUCCESS };
			List<IntegrationMessageQueue__c> tmpSyncHistory = ECO_Service_PurchaseOrders.getSyncHistory(poHeader.Id, ECO_Service_PurchaseOrders.JOBNAME_PO_SYNC, successStatus); 
			syncHistory = new List<syncHistoryHelper>();
			for(IntegrationMessageQueue__c tmpRec : tmpSyncHistory){
				syncHistoryHelper syncHelper = new syncHistoryHelper();
				syncHelper.syncLocalDateTime = tmpRec.LastModifiedDate.format();
				syncHelper.msgQueue = tmpRec;
				syncHistory.add(syncHelper);
			}	
			if(!syncHistory.isEmpty()){
				hasSyncHistory = true;
				numSuccessfulSyncs = syncHistory.size();
			}
			Set<String> otherStatuses = new Set<String> {ECO_Service_PurchaseOrders.STATUS_ERROR, ECO_Service_PurchaseOrders.STATUS_INITIATED, ECO_Service_PurchaseOrders.STATUS_ATTEMPTED, ECO_Service_ProjectSync.STATUS_SENT };
			List<IntegrationMessageQueue__c> tmpRequestFailures = ECO_Service_PurchaseOrders.getSyncHistory(poHeader.Id, ECO_Service_PurchaseOrders.JOBNAME_PO_SYNC, otherStatuses); 
			requestFailures = new List<syncHistoryHelper>();
			for(IntegrationMessageQueue__c tmpRec : tmpRequestFailures){
				syncHistoryHelper syncHelper = new syncHistoryHelper();
				syncHelper.syncLocalDateTime = tmpRec.LastModifiedDate.format();
				syncHelper.msgQueue = tmpRec;
				requestFailures.add(syncHelper);
			}	
			if(!requestFailures.isEmpty()){
				hasRequestFailures = true;
				numFailedAttemptedSyncs = requestFailures.size();
			}		
		}
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public class nonSyncItem{
		public Id recordId {get;set;}
		public String recordName {get;set;}
		public String validationErrorMessage{get;set;}
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public String validatePOLineItems(){
		String results = '';
		poLineItems = ECO_Service_PurchaseOrders.GetPurchaseOrderLineItems(purchaseOrderId);
		validPOLineItems = new List<POLineItem__c>();
		invalidPOLineItems = new List<nonSyncItem>();
		
		String poLineItemTask = Schema.SobjectType.POLineItem__c.fields.ProjectTask__c.label;
			
		if(!poLineItems.isEmpty()){
			for(POLineItem__c poLineItem : poLineItems){
				String validationMsgForPOLineItem = '';
				validationMsgForPOLineItem += checkForEmpty(poLineItem.ProjectTask__c, poLineItemTask);

				if(!String.isEmpty(validationMsgForPOLineItem)){
					validationMsgForPOLineItem = validationMsgForPOLineItem.substring(0,validationMsgForPOLineItem.length()-2);
					nonSyncItem badItem = new nonSyncItem();
					badItem.recordId = poLineItem.Id;
					badItem.recordName = poLineItem.Name;
					badItem.validationErrorMessage = 'The following fields must be completed to sync: ' + validationMsgForPOLineItem;
					invalidPOLineItems.add(badItem);  		
				}else{
					validPOLineItems.add(poLineItem);
				}    			
			}
		}
		numValidPOLineItems = validPOLineItems.size();
		numInvalidPOLineItems = invalidPOLineItems.size();

		//selectedPOLineItemTab = 'validPOLineItems';
		invalidPOLineItemLimitMsg = '(' + numInvalidPOLineItems + ' records)';
		if(!invalidPOLineItems.isEmpty()){
			allowRequestSubmit = false;
			results += '<li>' + numInvalidPOLineItems + ' PO Line Items failed validation. See the PO Line Items section below for details.</li>';					
			//selectedPOLineItemTab = 'invalidPOLineItems';			
		}

		validPOLineItemLimitMsg = '(' +numValidPOLineItems + ' records)';
		
		totalPurchaseOrderLineAmount = 0.0;
		for(POLineItem__c lineItem : poLineItems) {
			if(lineItem.Amount__c != null && lineItem.CancelFlag__c == False) {
				totalPurchaseOrderLineAmount =  totalPurchaseOrderLineAmount + lineItem.Amount__c;
			}            
		}
		
		return results;
	}	

	/*public PageReference SimulateProcessedByOracle() {

		poHeader.OraclePurchaseOrderId__c = '654321';
		update poHeader;

		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
		pageRef.getParameters().put('projectId', projectId);
		pageRef.getParameters().put('id', poHeader.Id);
		pageRef.setRedirect(true);
		return pageRef;    	
	}

	public void SimulateInvoicedByOracle(){
		
		poStatus.POHeader__c = poHeader.Id;
		poStatus.AP_Invoice__c = '123456';
		poStatus.APPaidDate__c = Date.today();
		insert poStatus;
	}*/
	
	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	private String generateProgressBar(Integer currentPosition, String statusMsg, Boolean isError){
		if(isError){
			progressErrors += '<font color="red">' + statusMsg + '</font><br/>';
		}
		String html = '<table border="1"><tr>';

		for(Integer i=1; i<intProgressBarNumCells; i++){
			String tdTitle = '';

			if(!stepMsgs.isEmpty()){
				if(stepMsgs.size() >= i){
					tdTitle = stepMsgs.get(i-1);					
				}
			}
			
			if(i <= currentPosition){
				html += '<td width="20px" height="10px" style="background-color:green;"><span title="' + tdTitle + '"><font color="green">.....</font></span></td>';
			}else{
				html += '<td  width="20px" height="10px" >&nbsp</td>';
			}
		}
		html += '</tr></table>';
		html += '<br/>';
		html += '<b>' + statusMsg + '</b>';
		if(!String.isEmpty(progressErrors)){
			html += '<font color="red">Errors:<font><br/>' + progressErrors;
		}
		return html;
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void createMessageQueueRecord_start(){
		intProgressBarNumCells = 6;
	   
		pollingMessageQueueMsg = '';
		pollingMessageQueueMsgBottom = '';
		stepMsgs = new List<String>();
		stepMsgs.add('');
		progressErrors = '';
		//showSyncMsg = true;
		syncProgressMsg = '';
		syncErrorOccurred = false;
		showPollingMsg = false;
		syncProgressMsg = 'Creating Message Queue record...';
		stepMsgs.add(syncProgressMsg);
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(1, syncProgressMsg, false)));
		ECO_Service_ErrorLog.formatPageError(generateProgressBar(1, syncProgressMsg, false), ApexPages.Severity.INFO);
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void createMessageQueueRecord_complete(){
		try{
			initiateOracleSyncRequest();
			syncProgressMsg =  'Creating Message Queue record - Complete!';
			stepMsgs.add(syncProgressMsg);
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(2, syncProgressMsg, false)));
			ECO_Service_ErrorLog.formatPageError(generateProgressBar(2, syncProgressMsg, false), ApexPages.Severity.INFO);
		}catch(Exception e){
			syncErrorOccurred = true;    		
			syncProgressMsg =  'Error occurred while creating Message Queue record!' + e.getMessage();
			stepMsgs.add(syncProgressMsg);
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(2, syncProgressMsg, true)));
			ECO_Service_ErrorLog.formatPageError(generateProgressBar(2, syncProgressMsg, true), ApexPages.Severity.ERROR);
		}    	
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void sendPOSyncRequest_start(){
		//syncProgressMsg = 'Sending purchase order request to oracle...';
		syncProgressMsg = 'Sending purchase order request to oracle...<br/>';
		stepMsgs.add(syncProgressMsg);	    	
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(3, syncProgressMsg, false)));			
		ECO_Service_ErrorLog.formatPageError(generateProgressBar(3, syncProgressMsg, false), ApexPages.Severity.INFO);
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void sendPOSyncRequest_complete(){
		executeOracleSyncRequest();
		syncProgressMsg += syncAttemptResult + '<br/>';

		///////////////////////////////testing///////////////////////////
		//syncErrorOccurred = false;
		///////////////////////////////////////////////////////////////////

		if(syncErrorOccurred){	
			stepMsgs.add('An error occurred while sending the request');			
		}else{	    	
			stepMsgs.add('Request successfully sent for purchaseOrderSyncProcessingResult');	
		}	    

		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, generateProgressBar(4, syncProgressMsg, syncErrorOccurred)));	       
		ECO_Service_ErrorLog.formatPageError(generateProgressBar(4, syncProgressMsg, syncErrorOccurred), ApexPages.Severity.INFO);
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void sendPOSyncRequest_Finish(){
		if(syncErrorOccurred){
			syncProgressMsg += 'Error occurred while sending purchase order request. Processing cannot continue.<br/>';
			stepMsgs.add('');		    
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(5, syncProgressMsg, true)));
			ECO_Service_ErrorLog.formatPageError(generateProgressBar(5, syncProgressMsg, true), ApexPages.Severity.ERROR);
			
		}else{
			//syncProgressMsg += 'Purchase order request is currently being processed by oracle.<br/>';
			syncProgressMsg += '';
			stepMsgs.add('');
			showPollingMsg = true;
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, generateProgressBar(5, syncProgressMsg, false)));
			ECO_Service_ErrorLog.formatPageError(generateProgressBar(5, syncProgressMsg, false), ApexPages.Severity.CONFIRM);
			validatedAndDisplayWarnings();
			hasSyncHistory = true;			
		}	   
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public void checkIfSyncHasBeenProcessed(){
		pollMessageQueue = true;
		IntegrationMessageQueue__c msgQueueResult = ECO_Service_ProjectSync.getMessageQueue(this.messageQueueId);

		if(msgQueueResult == null){
			//todo - display error - 
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The message queue record with Id =' + messageQueueId + ' could not be found!'));
			ECO_Service_ErrorLog.formatPageError('The message queue record with Id =' + messageQueueId + ' could not be found!', ApexPages.Severity.ERROR);
			pollMessageQueue = false;
			return;
		}

		if(msgQueueResult.Status__c.equalsIgnoreCase('Success') || msgQueueResult.Status__c.equalsIgnoreCase('Error')){
			if(msgQueueResult.Status__c.equalsIgnoreCase('Success')){
				pollingMessageQueueMsg = 'The project was successfully processed!';
				pollingMessageQueueMsgBottom = pollingMessageQueueMsg;
				purchaseOrderSyncProcessingResult = 'SUCCESS';
			}else{
				pollingMessageQueueMsg = 'An error occurred while processing the project!<br/>' + msgQueueResult.ErrorMessage__c;
				pollingMessageQueueMsgBottom = pollingMessageQueueMsg;
				purchaseOrderSyncProcessingResult = 'ERROR';
			} 
			generateSyncHistory();
			pollMessageQueue = false;   		
		}else{
			pollingMessageQueueMsg = 'Checking if project has been processed in <span id="pollingTimer">10</span> seconds...';
			pollingMessageQueueMsgBottom = 'Checking if project has been processed in <span id="pollingTimerBottom">10</span> seconds...';
		}
	}
	
	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public PageReference deletePurchaseOrder() {
		try {
			delete poHeader;
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e);
		}
		
		PageReference pageRef = new PageReference('/' + projectId);
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public PageReference authenticateCredentials()
	{
		String username = ApexPages.currentPage().getParameters().get('username');
		String password = ApexPages.currentPage().getParameters().get('password');

		ECO_IntegrationEndpoints__c cs;
		cs = ECO_IntegrationEndpoints__c.getInstance('Project Sync 2');
		String endPointUrl = cs.EndPointUrl__c;

		authenticationResult = ECO_Service_Authentication.TestProxy(endPointUrl, 'PICAction=CreateSHAKey&UserId=' + username + '&Password=' + EncodingUtil.URLENCODE(password,'UTF-8'));

		return null;
	}
	
	/**
	 * @Description
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public PageReference closeAuthenticationWindow() {
		PageReference pageRef = new PageReference('/apex/ECO_PurchaseOrderSummary');
		pageRef.getParameters().put('projectId', projectId);
		pageRef.getParameters().put('id', poHeader.Id);
		pageRef.setRedirect(true);	

		return pageRef;          
	} 
}