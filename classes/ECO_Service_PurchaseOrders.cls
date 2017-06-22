/** ------------------------------------------------------------------------------------------------------
* @Description The service class for Purchase Orders; it contains common methods for 
* ECO_PurchaseOrderLineItemController, ECO_PurchaseOrderSummaryControllers & ECO_PurchaseOrder_AllEvents 
* & ECO_PurchaseOrderStatus_AllEvents triggers
*
* @Author      NTT Data - ?, Deborah Orth
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_Service_PurchaseOrders{
	public class EcoPurchaseOrderServiceException extends Exception {}

	public static Boolean run = true;

	public final Static String STATUS_INITIATED = 'Initiated';	//Connection attempt started
	public final Static String STATUS_ATTEMPTED = 'Attempted';	//Connection attempt failed (time out, or responded with fail code)
	public final Static String STATUS_SENT = 'Sent';				//HTTP Request completed positively
	public final Static String STATUS_ERROR = 'Error';			//Service writes to Message an error
	public final Static String STATUS_SUCCESS = 'Success';		//Service writes to Message with success

	public final Static String JOBNAME_PO_SYNC = 'PO Sync';

	public final Static String SYNC_STATUS_PENDING = 'P';
	public final Static String SYNC_STATUS_SUCCESS = 'S';
	public final Static String SYNC_STATUS_ERROR = 'E';
	public final Static String SYNC_STATUS_TRANSFERSENT = 'T';

	//public final Static String JOBNAME_PO_NUMBER = 'PO Number';


	/**
	 * Decorator method to add PO and Distribution items to POs
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sPurchaseOrderId - the POHeader__c to decorate
	 * @return  PurchaseOrderMessageWrapper
	 **/
	public static PurchaseOrderMessageWrapper createPurchaseOrderMessageWrapper(Id sPurchaseOrderId){
		PurchaseOrderMessageWrapper wrapper = new PurchaseOrderMessageWrapper();

		wrapper.PO_HEADER = createPurchaseOrderHeader(sPurchaseOrderId);
		wrapper.POLINEITEM_COLLECTION = createPurchaseOrderLineItemCollection(sPurchaseOrderId);
		wrapper.DISTRIBUTION_COLLECTION = createDistributionCollection(sPurchaseOrderId);
		//wrapper.PO_STATUS = new OR_PurchaseOrderStatus();

		return wrapper;
	}


	/**
	 * Creates a new PO Header for Oracle
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sPurchaseOrderId - the POHeader__c to create an Oracle PO from
	 * @return  OR_PurchaseOrder
	 **/
	public static OR_PurchaseOrder createPurchaseOrderHeader(Id sPurchaseOrderId){
		OR_PurchaseOrder result = new OR_PurchaseOrder(GetPurchaseOrder(sPurchaseOrderId));
		return result;
	}


	/**
	 * Creates a list of PO Line Item records for Oracle
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sPurchaseOrderId - the POHeader__c to create the Oracle PI Line Items from
	 * @return  List<OR_PurchaseOrderLineItem>
	 **/
	public static List<OR_PurchaseOrderLineItem> createPurchaseOrderLineItemCollection(Id sPurchaseOrderId){
		List<OR_PurchaseOrderLineItem> results = new List<OR_PurchaseOrderLineItem>();
		List<POLineItem__c> poLineItems = getNonSyncedPurchaseOrderLineItems(sPurchaseOrderId);
		Set<Id> poLineItemChangeRequests = getChangedRequestPOLineItems(sPurchaseOrderId);

		//List<POLineItem__c> poLineItems = getPurchaseOrderLineItems(sPurchaseOrderId);
		
		for(POLineItem__c poLineItem : poLineItems){
			if(poLineItem.IsArchived__c != true){
				Boolean isChangeRequest = false;
				if(poLineItemChangeRequests.contains(poLineItem.Id)){
					isChangeRequest = true;
				}
				results.add(new OR_PurchaseOrderLineItem(poLineItem, isChangeRequest));
			}
			
		}
		return results;
	}

	/**
	 * Creates a list of Distibution records for Oracle
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sPurchaseOrderId - the POHeader__c to create the Oracle Distribution Items from
	 * @return  List<OR_Distribution>
	 **/
	public static List<OR_Distribution> createDistributionCollection(Id sPurchaseOrderId){
		List<OR_Distribution> results = new List<OR_Distribution>();
		List<Distribution__c> distributions = GetDistributions(sPurchaseOrderId);
		for(Distribution__c distribution : distributions){
			results.add(new OR_Distribution(distribution));
		}
		return results;
	}

	/**
	 * Creates a PO Message JSON string
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sPurchaseOrderId - the POHeader__c to create the Oracle Distribution Items from
	 * @param   messageQueueId - the POHeader__c to create the Oracle Distribution Items from
	 * @return  String - the JSON serialized PurchaseOrderMessageWrapper
	 **/
	public static string createPurchaseOrderMessageWrapperJSON(Id sPurchaseOrderId, Id messageQueueId){
		PurchaseOrderMessageWrapper poWrapper = createPurchaseOrderMessageWrapper(sPurchaseOrderId);
		String JobId = '';
		if(messageQueueId != null){
			IntegrationMessageQueue__c msgQueue = getMessageQueue(messageQueueId);
			if(msgQueue != null){
				JobId = String.valueOf(msgQueue.JobId__c);
			}
			poWrapper.PO_HEADER.JOB_ID = JobId;
		}
		if(!poWrapper.POLINEITEM_COLLECTION.isEmpty()){
			for(OR_PurchaseOrderLineItem poli : poWrapper.POLINEITEM_COLLECTION){
				poli.JOB_ID = JobId;
			}
		}
		if(!poWrapper.DISTRIBUTION_COLLECTION.isEmpty()){
			for(OR_Distribution distribution : poWrapper.DISTRIBUTION_COLLECTION){
				distribution.JOB_ID = JobId;
			}
		}

		String json_poWrapper = JSON.serializePretty(poWrapper);
		return json_poWrapper;
	}

	/**
	 * Does the actual sending of a PO Request to AECOM REST Server
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sEndPointUrl - correct URL to send the request to depending on the environment
	 * @param   sJsonPayload - the request payload data that is POSTed to the service
	 * @return  Static Map<String, String> - the JSON serialized PurchaseOrderMessageWrapper
	 **/
	public Static Map<String, String> sendRequest(String sEndPointUrl, String sJsonPayload){
		Map<String, String> results = new Map<String, String>();

		//setup the REST request
		Http h = new Http();		    
		HttpRequest req = new HttpRequest();	   
		req.setEndpoint(sEndPointUrl);		    
		req.setClientCertificateName('ECOProjService');
		req.setHeader('Content-Type', 'application/json');		    
		req.setMethod('POST');	
		req.setBody(sJsonPayload);
		req.setTimeout(120000);

		// Send the request, and return a response
		HttpResponse res = h.send(req);
		system.debug('purchase order sendRequest from service = ' + res.getBody());
		String respBody = res.getBody();

		String respStatus = res.getStatus();	//OK for success
		String statusCode = String.valueOf(res.getStatusCode());

		system.debug('respStatus=' + respStatus);
		system.debug('statusCode=' + statusCode);		    
	   
		if(statusCode == '200'){
			results.put(statusCode, respBody);
		} else {
			if(!String.isEmpty(respBody)){	//depending if the service is up and running properly there may not be a response body message
				results.put(statusCode, respBody);
			} else {
				results.put(statusCode, respStatus);
			}		    	
		}
		
		return results;
	}

	/**
	 * Initiates an Oracle Sync request
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sPurchaseOrderId - the POHeader__c.id to sync
	 * @param   url - correct URL to send the request to depending on the environment
	 * @param   sMessageQueueId - the message queue Id
	 * @return  String - the JSON serialized PurchaseOrderMessageWrapper
	 **/
	public Static String initiateOracleSyncRequest(Id sPurchaseOrderId, String url, Id sMessageQueueId){		
		String result = '';
		String statusCode = '';

		IntegrationMessageQueue__c messageQueue = getMessageQueue(sMessageQueueId);
		if(messageQueue == null){
			throw new EcoPurchaseOrderServiceException('Cannot find message queue with Id = ' + sMessageQueueId);
		}
		
		try{

			String jsonPayload = createPurchaseOrderMessageWrapperJSON(sPurchaseOrderId, sMessageQueueId);
			system.debug('service - jsonPayload = ' + jsonPayload);
			Map<String, String> resultMap = sendRequest(url, jsonPayload);
			for(String key : resultMap.keySet()){
				statusCode = key;
				system.debug('statusCode = ' + statusCode);
				result = resultMap.get(statusCode);
			}

			system.debug('response at service level = ' + result);

			String polineItemStatus = SYNC_STATUS_TRANSFERSENT;
			system.debug('int statuscode = ' + Integer.valueOf(statusCode));

			////////////////////////testing/////////////////////////////
			//statusCode = '200';
			////////////////////////////////////////////////////////////

			//if(Integer.valueOf(statusCode) == 200 && result.trim() == '42'){
			if(Integer.valueOf(statusCode) == 200){
				system.debug('response status = ' + STATUS_SUCCESS);
				
				messageQueue.Status__c = STATUS_SUCCESS;
				messageQueue.SuccessMessage__c = result;
				polineItemStatus = SYNC_STATUS_SUCCESS;

			}else{
				if(statusCode.startsWith('5') || statusCode.startsWith('4')){	//handle 500 type errors from webservice
					messageQueue.Status__c = STATUS_ERROR;
					messageQueue.ErrorMessage__c = result;
					polineItemStatus = SYNC_STATUS_ERROR;
				}else{
					messageQueue.Status__c = STATUS_ATTEMPTED;
					messageQueue.ErrorMessage__c = result;
				}				
			}
			update messageQueue;
			flagPurchaseOrderLineItemsWithSyncStatus(sPurchaseOrderId, polineItemStatus);			    
			
		}catch(Exception e){			
			result = e.getMessage();
			system.debug('error response = ' + result);
			messageQueue.ErrorMessage__c = result;
			messageQueue.Status__c = STATUS_ATTEMPTED;
			update messageQueue;
			flagPurchaseOrderLineItemsWithSyncStatus(sPurchaseOrderId, STATUS_ATTEMPTED);
		}
		
		return result;
	}

	////////////////////////////////////////// DTO OBJECTS ///////////////////////////////////////////////

	/** ------------------------------------------------------------------------------------------------------
	* @Description 
	*
	* @Author      NTT Data - ?, Deborah Orth
	* @Date        2015
	*-----------------------------------------------------------------------------------------------------*/
	public class PurchaseOrderMessageWrapper {

		//public OR_PurchaseOrderStatus PO_STATUS {get; set;}

		public OR_PurchaseOrder PO_HEADER {get; set;}

		public List<OR_PurchaseOrderLineItem> POLINEITEM_COLLECTION {get; set;}

		public List<OR_Distribution> DISTRIBUTION_COLLECTION {get; set;} 

		//public List<OR_PurchaseOrderCommitment> PO_COMMITMENTS {get;set;}
	}

	/** ------------------------------------------------------------------------------------------------------
	* @Description 
	*
	* @Author      NTT Data - ?, Deborah Orth
	* @Date        2015
	*-----------------------------------------------------------------------------------------------------*/
	public class OR_PurchaseOrder{
		//maps to POHeader__c
		public String FF_PO_ID {get;set;}	
		public String PO_NUMBER {get;set;}			
		public String PO_ID {get;set;}			
		public String PO_TYPE {get;set;}	
		public String PO_CURRENCY {get;set;}	
		public String AGENT_ID {get;set;}	
		public String VENDOR_ID {get;set;}
		public String VENDOR_SITE_ID {get;set;}
		public String VENDOR_NUMBER {get;set;}
		public String VENDOR_NAME {get;set;}
		public String SFDC_VENDOR_NUMBER {get;set;}
		public String PAYMENT_TERMS {get;set;}
		public String REQUESTOR_ID {get;set;}
		public String REQUESTOR_NAME {get;set;}
		//public String REVISION {get;set;}
		public String STATUS {get;set;}
		public String CANCEL_FLAG {get;set;}
		public String OU_ID {get;set;}
		public String ACTION_FLAG {get;set;}
		public String JOB_ID {get;set;}
		public String PO_DATE {get;set;}

		/**
		 * Constructor
		 *
		 * @Author  NTT Data - ?, Deborah Orth
		 * @Date    2015
		 *
		 * @param   
		 * @return  
		 **/
		public OR_PurchaseOrder(){
			this.FF_PO_ID = '';
			this.PO_NUMBER = '';
			this.PO_ID = '';		
			this.PO_TYPE = '';
			this.PO_CURRENCY = '';	
			this.AGENT_ID = '';
			this.VENDOR_ID = '';
			this.VENDOR_SITE_ID = '';
			this.VENDOR_NUMBER = '';
			this.VENDOR_NAME = '';
			this.SFDC_VENDOR_NUMBER = '';
			this.PAYMENT_TERMS = '';
			this.REQUESTOR_ID = '';
			this.REQUESTOR_NAME = '';
			//this.REVISION = '';
			this.STATUS = '';
			this.CANCEL_FLAG = '';
			this.OU_ID = '';
			this.ACTION_FLAG = '';
			this.JOB_ID = '';
			this.PO_DATE = '';
		}

		/**
		 * Constructor
		 *
		 * @Author  NTT Data - ?, Deborah Orth
		 * @Date    2015
		 *
		 * @param   poHeader - the POHeader__c to create an Oracle PO from
		 * @return  
		 **/
		public OR_PurchaseOrder(POHeader__c poHeader){
			this.FF_PO_ID = String.valueOf(poHeader.FFPOId__c);
			this.PO_NUMBER = ECO_Utils_String.NullCheck(poHeader.OraclePurchaseOrderNumber__c);		
			this.PO_ID =  ECO_Utils_String.NullCheck(poHeader.OraclePurchaseOrderId__c);		
			this.PO_TYPE = ECO_Utils_String.NullCheck(poHeader.POType__c);
			this.PO_CURRENCY = poHeader.CurrencyIsoCode;	
			this.AGENT_ID = '499092';	//'480155';	//HARDCODED
			this.VENDOR_ID = ECO_Utils_String.NullCheck(poHeader.OracleVendorId__c);			
			this.VENDOR_SITE_ID = ECO_Utils_String.NullCheck(poHeader.OracleVendorSiteId__c);
			this.VENDOR_NUMBER = ECO_Utils_String.NullCheck(poHeader.OracleVendorNumber__c);
			this.VENDOR_NAME = ECO_Utils_String.NullCheck(poHeader.VendorName__c);			

			String vendorSfdcId = ECO_Utils_String.NullCheck(poHeader.SFDCVendorNumber__c);
			if(!String.isEmpty(vendorSfdcId)){
				vendorSfdcId = (Id)vendorSfdcId;
			}
			this.SFDC_VENDOR_NUMBER = vendorSfdcId;

			this.PAYMENT_TERMS = ECO_Utils_String.NullCheck(poHeader.OraclePaymentTermId__c);
			this.REQUESTOR_ID = ECO_Utils_String.NullCheck(poHeader.RequestorOracleId__c);
			this.REQUESTOR_NAME = ECO_Utils_String.NullCheck(poHeader.Requestor__r.Name);
			//this.REVISION = '';
			this.STATUS = ECO_Utils_String.NullCheck(poHeader.Status__c);
			this.CANCEL_FLAG = formatBooleanForOracle(poHeader.CancelFlag__c);
			this.OU_ID = ECO_Utils_String.NullCheck(poHeader.Project__r.OUID__c);
			if(String.isEmpty(poHeader.OraclePurchaseOrderNumber__c)){
				this.ACTION_FLAG = 'C';
			}else{
				this.ACTION_FLAG = 'U';
			}
			//this.ACTION_FLAG = ECO_Utils_String.NullCheck(poHeader.ActionFlag__c);
			
			this.JOB_ID = '';
			this.PO_DATE = ECO_Utils_String.NullCheck(formatDateForOracle(poHeader.PO_Date__c));
		}
																

	}

	/** ------------------------------------------------------------------------------------------------------
	* @Description 
	*
	* @Author      NTT Data - ?, Deborah Orth
	* @Date        2015
	*-----------------------------------------------------------------------------------------------------*/
	public class OR_PurchaseOrderLineItem{
		//maps to POLineItem__c
		public String FF_PO_ID {get;set;}
		public String FF_PO_LINE_ID {get;set;}
		public String PO_NUMBER {get;set;}
		//public String PO_ID {get;set;}
		//public String REVISION {get;set;}
		public String LINE_NUMBER {get;set;}
		public String PO_CLASS {get;set;}
		public String PO_SUB_CLASS {get;set;}
		public String LINE_DESCRIPTION {get;set;}
		public String LINE_AMOUNT {get;set;}
		public String QUANTITY {get;set;}
		public String UNIT_OF_MEASURE {get;set;}
		public String UNIT_PRICE {get;set;}
		public String LINE_TYPE {get;set;}
		public String CANCEL_FLAG {get;set;}
		public String ACTION_FLAG {get;set;}
		public String JOB_ID {get;set;}
				
		/**
		 * Constructor
		 *
		 * @Author  NTT Data - ?, Deborah Orth
		 * @Date    2015
		 *
		 * @param   
		 * @return  
		 **/
		public OR_PurchaseOrderLineItem(){
			this.FF_PO_ID = '';
			this.FF_PO_LINE_ID = '';
			this.PO_NUMBER = '';
			//this.PO_ID = '';
			//this.REVISION = '';
			this.LINE_NUMBER = '';
			this.PO_CLASS = '';
			this.PO_SUB_CLASS = '';
			this.LINE_DESCRIPTION = '';
			this.LINE_AMOUNT = '';
			this.QUANTITY = '';
			this.UNIT_OF_MEASURE = '';
			this.UNIT_PRICE = '';
			this.LINE_TYPE = '';
			this.CANCEL_FLAG = '';
			this.ACTION_FLAG = '';
			this.JOB_ID = '';
		}

		/**
		 * Constructor
		 *
		 * @Author  NTT Data - ?, Deborah Orth
		 * @Date    2015
		 *
		 * @param   poLineItem - the POLineItem__c to create an Oracle PO LI from
		 * @param   isChangeRequest - is this a change request LI?
		 * @return  
		 **/
		public OR_PurchaseOrderLineItem(POLineItem__c poLineItem, Boolean isChangeRequest){
			this.FF_PO_ID = String.valueOf(poLineItem.POHeader__r.FFPOId__c);
			this.FF_PO_LINE_ID = String.valueOf(poLineItem.FFPOLineId__c);
			this.PO_NUMBER = ECO_Utils_String.NullCheck(poLineItem.OraclePONumber__c);
			//this.PO_ID = ECO_Utils_String.NullCheck(poLineItem.OraclePOID__c);
			/*
			if(poLineItem.Revision__c == null){
				this.REVISION = '0';
			}else{
				this.REVISION = String.valueOf(poLineItem.Revision__c);
			}	
			*/
			if(poLineItem.Amount__c == null){
				this.LINE_NUMBER = '';
			}else{
				this.LINE_NUMBER = String.valueOf(poLineItem.LineNumber__c);
			}		
			String poClass = poLineItem.Class__c;			
			String subClass = poLineItem.SubClass__c;		
			this.PO_CLASS = poClass.toUpperCase();
			this.PO_SUB_CLASS = subClass.toUpperCase();
			this.LINE_DESCRIPTION = ECO_Utils_String.NullCheck(poLineItem.LineDescription__c);
			if(poLineItem.Amount__c == null){
				this.LINE_AMOUNT = '';
			}else{
				this.LINE_AMOUNT = String.valueOf(poLineItem.Amount__c);
			}
			if(poLineItem.Quantity__c == null){
				this.QUANTITY = '';
			}else{
				this.QUANTITY = String.valueOf(poLineItem.Quantity__c);
			}
			/*
			if(poLineItem.UnitofMeasure__c == null){
				this.UNIT_OF_MEASURE = '';
			}else{
				this.UNIT_OF_MEASURE = String.valueOf(poLineItem.OracleUnitOfMeasure__c);
			}
			*/
			this.UNIT_OF_MEASURE = ECO_Utils_String.NullCheck(poLineItem.OracleUnitOfMeasure__c);
			if(poLineItem.UnitPrice__c == null){
				this.UNIT_PRICE = '';
			}else{
				this.UNIT_PRICE = String.valueOf(poLineItem.UnitPrice__c);
		
			}
			//this.LINE_TYPE = ECO_Utils_String.NullCheck(poLineItem.LineType__c);
			this.LINE_TYPE = ECO_Utils_String.NullCheck(poLineItem.OracleLineType__c);
			this.CANCEL_FLAG = formatBooleanForOracle(poLineItem.CancelFlag__c);
			if(!isChangeRequest){
				this.ACTION_FLAG = 'C';
			}else{
				this.ACTION_FLAG = 'U';
			}

			this.JOB_ID = '';
		
		}
	}

	/** ------------------------------------------------------------------------------------------------------
	* @Description 
	*
	* @Author      NTT Data - ?, Deborah Orth
	* @Date        2015
	*-----------------------------------------------------------------------------------------------------*/
	public class OR_Distribution{

		public String FF_PO_ID {get;set;}
		public String FF_PO_LINE_ID {get;set;}
		public String LINE_NUMBER {get;set;}
		public String DISTRIBUTION_NUMBER {get;set;}
		public String PROJECT_NUMBER {get;set;}
		public String TASK_NUMBER {get;set;}
		public String EXPENDITURE_TYPE {get;set;}
		public String EXPENDITURE_DATE {get;set;}
		public String QUANTITY_ORDERED {get;set;}
		public String AMOUNT_ORDERED {get;set;}
		public String JOB_ID {get;set;}
		//public String REVISION {get;set;}

		public OR_Distribution(){
			this.FF_PO_ID = '';
			this.FF_PO_LINE_ID = '';
			this.LINE_NUMBER = '';
			this.DISTRIBUTION_NUMBER = '';
			this.PROJECT_NUMBER = '';
			this.TASK_NUMBER = '';
			this.EXPENDITURE_TYPE = '';
			this.EXPENDITURE_DATE = '';
			this.QUANTITY_ORDERED = '';
			this.AMOUNT_ORDERED = '';
			//this.REVISION = '';
			this.JOB_ID = '';
		}

		/**
		 * Constructor
		 *
		 * @Author  NTT Data - ?, Deborah Orth
		 * @Date    2015
		 *
		 * @param   distribution - the Distribution__c to create an Oracle distribution from
		 * @return  
		 **/
		public OR_Distribution(Distribution__c distribution){
			//this.FF_PO_ID = distribution.POLineItem__r.POHeader__c;
			//this.FF_PO_LINE_ID = distribution.POLineItem__c;

			this.FF_PO_ID = String.valueOf(distribution.POLineItem__r.POHeader__r.FFPOId__c);
			this.FF_PO_LINE_ID = String.valueOf(distribution.POLineItem__r.FFPOLineId__c); 
			if(distribution.POLineNumber__c == null){
				this.LINE_NUMBER = '';
			}else{
				this.LINE_NUMBER = String.valueOf(distribution.POLineNumber__c);
			}			
			this.DISTRIBUTION_NUMBER = String.valueOf(distribution.DistributionNumber__c);
			this.PROJECT_NUMBER = ECO_Utils_String.NullCheck(distribution.OracleProjectNumber__c);
			this.TASK_NUMBER = ECO_Utils_String.NullCheck(distribution.ProjectTaskNumber__c);
			this.EXPENDITURE_TYPE = ECO_Utils_String.NullCheck(distribution.POLinteItemExpenditureType__c);
			this.EXPENDITURE_DATE = ECO_Utils_String.NullCheck(formatDateForOracle(distribution.ExpenditureDate__c));
			this.QUANTITY_ORDERED = String.valueOf(distribution.QuantityOrdered__c);

			if(distribution.POLineItem__r.OracleLineType__c.equalsIgnoreCase('GOODS')){
				this.AMOUNT_ORDERED = String.valueOf(distribution.AmountOrdered__c);
			}else{
				this.AMOUNT_ORDERED = '';
			}
			
			this.JOB_ID = '';
			/*			
			if(distribution.Revision__c == null){
				this.REVISION = '0';
			}else{
				this.REVISION = String.valueOf(distribution.Revision__c);
			}	
			*/
		}

	}

	/** ------------------------------------------------------------------------------------------------------
	* @Description 
	*
	* @Author      NTT Data - ?, Deborah Orth
	* @Date        2015
	*-----------------------------------------------------------------------------------------------------*/
	public class OR_PurchaseOrderStatus{

		public String PO_NUMBER {get;set;}
		public String PO_STATUS {get;set;}
		public String PO_TOTAL_AMOUNT {get;set;}
		public String PO_ALLOCATED {get;set;}
		public String PO_REMAINING {get;set;}
		public String AP_INVOICE {get;set;}
		public String AP_TOTAL_AMOUNT {get;set;}
		public String AP_PAID_DATE {get;set;}

		/**
		 * Constructor
		 *
		 * @Author  NTT Data - ?, Deborah Orth
		 * @Date    2015
		 *
		 * @param   
		 * @return  
		 **/
		public OR_PurchaseOrderStatus(){
			this.PO_NUMBER = '';
			this.PO_STATUS = '';
			this.PO_TOTAL_AMOUNT = '';
			this.PO_ALLOCATED = '';
			this.PO_REMAINING = '';
			this.AP_INVOICE = '';
			this.AP_TOTAL_AMOUNT = '';
			this.AP_PAID_DATE = '';
		}

		/**
		 * Constructor
		 *
		 * @Author  NTT Data - ?, Deborah Orth
		 * @Date    2015
		 *
		 * @param   poStatus - the POStatus__c to create an Oracle status from
		 * @return  
		 **/
		public OR_PurchaseOrderStatus(POStatus__c poStatus){
			this.PO_NUMBER = '';
			this.PO_STATUS = '';
			this.PO_TOTAL_AMOUNT = '';
			this.PO_ALLOCATED = '';
			this.PO_REMAINING = '';
			this.AP_INVOICE = '';
			this.AP_TOTAL_AMOUNT = '';
			this.AP_PAID_DATE = '';
		}
		
	}



	/** ------------------------------------------------------------------------------------------------------
	* @Description 
	*
	* @Author      NTT Data - ?, Deborah Orth
	* @Date        2015
	*-----------------------------------------------------------------------------------------------------*/
	public class OR_PurchaseOrderCommitment{

	}

	////////////////////////////////////////// END DTO OBJECTS ///////////////////////////////////////////////



	////////////////////////////////////////// SOQL QUERIES ///////////////////////////////////////////////

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sPurchaseOrderId - the POHeader__c to get the data for
	 * @return  POHeader__c
	 **/
	public static POHeader__c GetPurchaseOrder(Id sPurchaseOrderId){
		
		List<POHeader__c> lPurchaseOrders = new List<POHeader__c>([SELECT Id,
																		Name,
																		CurrencyIsoCode,
																		Project__c,
																		Agreement__c,
																		CancelFlag__c,
																		OraclePaymentTermId__c,
																		OraclePurchaseOrderId__c,
																		OraclePurchaseOrderNumber__c,
																		OracleVendorId__c,
																		OracleVendorNumber__c,
																		OracleVendorSiteId__c,
																		OUID__c,
																		Project__r.OUID__c,
																		PaymentTerm__c,
																		POType__c,
																		VendorSite__c,
																		Revision__c,
																		SFDCVendorNumber__c,
																		Status__c,
																		VendorName__c,
																		Requestor__c,
																		Requestor__r.Name,
																		OraclePersonId__c,
																		CarryingOutOrganization__c,
																		CarryingOutOrganizationOrgId__c,
																		CarryingOutOrganizationOUID__c,
																		ActionFlag__c,
																		RequestorOracleId__c,
																		PO_Date__c,
																		VendorSite__r.Address1__c,
																		VendorSite__r.City__c,
																		VendorSite__r.State__c,																		
																		VendorSite__r.Country__c,
																		VendorSite__r.PostalCode__c,
																		FFPOId__c,
																		Agreement__r.VendorSite__r.AccountName__c,
																		Agreement__r.Name,
																		FlagForEscalate__c																		
																FROM POHeader__c
																WHERE Id = :sPurchaseOrderId]);

		if(lPurchaseOrders.size() == 0){
			throw new EcoPurchaseOrderServiceException('Purchase Order Not Found');
		}

		return lPurchaseOrders.get(0);
	}


	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sPurchaseOrderId - the POHeader__c to get the data for
	 * @return  List<POLineItem__c>
	 **/
	public static List<POLineItem__c> GetPurchaseOrderLineItems(Id sPurchaseOrderId){
		
		List<POLineItem__c> lPOLineItems = new List<POLineItem__c>([SELECT Id,
																		Name,
																		CurrencyIsoCode,
																		POHeader__c,
																		ProjectTask__r.Name,
																		ProjectTask__r.ProjectTaskNumber__c,
																		ProjectTask__c,
																		Amount__c,
																		CancelFlag__c,
																		LineDescription__c,
																		LineType__c,
																		OraclePONumber__c,
																		OraclePOID__c,
																		Quantity__c,
																		Revision__c,
																		UnitofMeasure__c,
																		UnitPrice__c,
																		ExpenditureType__c,
																		POHeader__r.Name,
																		POHeader__r.Project__c,
																		LineNumber__c,
																		POHeader__r.CurrencyIsoCode,
																		OracleSyncStatus__c,
																		OracleUnitOfMeasure__c,
																		OracleLineType__c,
																		POHeader__r.FFPOId__c,
																		FFPOLineId__c,
																		OracleSyncDatetime__c,
																		UnitOfMeasureUserDefined__c,
																		Class__c,
																		SubClass__c,
																		IsArchived__c,
																		ChangeRequestPOLineItem__c,
																		IsLocked__c
																FROM POLineItem__c
																WHERE POHeader__c = :sPurchaseOrderId																
																ORDER BY LineNumber__c ASC, IsArchived__c ASC]);

		return lPOLineItems;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sPurchaseOrderLineItemId - the POLineItem__c to get the data for
	 * @return  POLineItem__c
	 **/
	public static POLineItem__c GetPurchaseOrderLineItem(Id sPurchaseOrderLineItemId){
		POLineItem__c result = null;
		List<POLineItem__c> lPOLineItems = new List<POLineItem__c>([SELECT Id,
																		Name,
																		CurrencyIsoCode,
																		POHeader__c,
																		ProjectTask__r.Name,
																		ProjectTask__r.ProjectTaskNumber__c,
																		ProjectTask__c,
																		Amount__c,
																		CancelFlag__c,
																		LineDescription__c,																		
																		LineType__c,
																		OraclePONumber__c,
																		OraclePOID__c,
																		Quantity__c,
																		Revision__c,
																		UnitofMeasure__c,
																		UnitPrice__c,
																		ExpenditureType__c,
																		POHeader__r.Name,
																		POHeader__r.Project__c,
																		LineNumber__c,
																		POHeader__r.CurrencyIsoCode,
																		CreatedDate,
																		POHeader__r.FFPOId__c,
																		FFPOLineId__c,
																		OracleSyncStatus__c,
																		OracleSyncDatetime__c,
																		UnitOfMeasureUserDefined__c,
																		Class__c,
																		SubClass__c,
																		IsArchived__c,
																		ChangeRequestPOLineItem__c
																FROM POLineItem__c
																WHERE Id = :sPurchaseOrderLineItemId]);

		if(!lPOLineItems.isEmpty()){
			result = lPOLineItems.get(0);
		}
		return result;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sPurchaseOrderId - the POHeader__c to get the data for
	 * @return  List<Distribution__c>
	 **/
	public static List<Distribution__c> GetDistributions(Id sPurchaseOrderId){
		String sPurchaseOrderIdStr = String.valueOf(sPurchaseOrderId);
		String sPurchaseOrderIdShortStr = String.valueOf(sPurchaseOrderId);
		system.debug('sPurchaseOrderId=' + sPurchaseOrderId); 

		if(sPurchaseOrderIdShortStr.length() == 18){
			sPurchaseOrderIdShortStr = sPurchaseOrderIdShortStr.substring(0, 15);
		}
		
		List<Distribution__c> lDistributions = new List<Distribution__c>([SELECT Id,
																		Name,
																		CurrencyIsoCode,
																		POLineItem__c,
																		POLineItem__r.Name,
																		POHeader__c,
																		AmountOrdered__c,
																		DistributionNumber__c,
																		ExpenditureDate__c,
																		POLinteItemExpenditureType__c,
																		OracleProjectNumber__c,
																		POLineNumber__c,
																		ProjectTaskNumber__c,
																		QuantityOrdered__c,
																		Revision__c,																	
																		POLineItem__r.LineType__c,
																		POLineItem__r.POHeader__c,
																		POLineItem__r.Amount__c,
																		POLineItem__r.OracleLineType__c,
																		POLineItem__r.FFPOLineId__c,
																		POLineItem__r.POHeader__r.FFPOId__c																
																FROM Distribution__c
																WHERE (POHeader__c = :sPurchaseOrderIdStr OR POHeader__c = :sPurchaseOrderIdShortStr)
																AND POLineItem__r.OracleSyncDatetime__c = null
																ORDER BY POLineItem__c, CreatedDate]);

		return lDistributions;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sPurchaseOrderId - the POHeader__c to get the data for
	 * @return  List<POStatus__c>
	 **/
	public static List<POStatus__c> GetPurchaseOrderStatuses(Id sPurchaseOrderId){
		
		List<POStatus__c> lPOStatuses = new List<POStatus__c>([SELECT Id,
																		Allocated__c,
																		AP_Invoice__c,
																		APPaidDate__c,
																		APTotalAmount__c,
																		POHeader__c,
																		Remaining__c,
																		TotalAmount__c,
																		APInvoiceNumber__c,
																		APINVLineAmount__c,
																		APinvLineFunctAmount__c,
																		POLine__c,
																		APINVDate__c,
																		APPaidAmount__c,
																		APINVCurrency__c
																FROM POStatus__c
																WHERE POHeader__c = :sPurchaseOrderId]);
		

		return lPOStatuses;
		/*AggregateResult[] groupedResults  = [SELECT APInvoiceNumber__c, SUM(Allocated__c) Allocated, MAX(APPaidDate__c) APPaidDate, 
									 SUM(APTotalAmount__c) APTotalAmount, SUM(Remaining__c) Remaining, 
									 SUM(TotalAmount__c) TotalAmount
									FROM POStatus__c
									WHERE POHeader__c = :sPurchaseOrderId
									GROUP BY APInvoiceNumber__c];
//        System.debug('groupedResults:' + groupedResults);
		List<POStatus__c> poStatuses = new List<POStatus__c>();
		for (AggregateResult ar : groupedResults) {
			POStatus__c status = new POStatus__c();
			status.APInvoiceNumber__c = (String)ar.get('APInvoiceNumber__c');
			status.Allocated__c = (Decimal)ar.get('Allocated');
			status.APPaidDate__c = (Date)ar.get('APPaidDate');
			status.APTotalAmount__c = (Decimal)ar.get('APTotalAmount');
			status.Remaining__c = (Decimal)ar.get('Remaining');
			status.TotalAmount__c = (Decimal)ar.get('TotalAmount');
			status.POHeader__c = sPurchaseOrderId;
			poStatuses.add(status);    
		}
		
		return poStatuses;*/
	}


	////////////////////////////////////////// END SOQL QUERIES ///////////////////////////////////////////////


	////////////////////////////////////////////////// UTILS //////////////////////////////////////////
	//todo - create service util class

	@TestVisible
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sMessageQueueId - the IntegrationMessageQueue__c to get the data for
	 * @return  IntegrationMessageQueue__c
	 **/
	private Static IntegrationMessageQueue__c getMessageQueue(Id sMessageQueueId){
		IntegrationMessageQueue__c msgQueue = null;
		List<IntegrationMessageQueue__c> messageQueues = [SELECT Id, ErrorMessage__c, Status__c, JobName__c, SuccessMessage__c, JobId__c
															FROM IntegrationMessageQueue__c
															WHERE Id = :sMessageQueueId];

		if(!messageQueues.isEmpty()){
			msgQueue = messageQueues.get(0);
		}
		return msgQueue;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sRecordId - the IntegrationMessageQueue__c to be created for this record
	 * @param   sJobName - the Job Name of the IntegrationMessageQueue__c object
	 * @return  Id
	 **/
	public Static Id createMessageQueueForRequest(Id sRecordId, String sJobName){
		//save to the msg queue that we're attempting a call to the oracle ws
		IntegrationMessageQueue__c msgQueue = new IntegrationMessageQueue__c();
		msgQueue.ErrorMessage__c = '';
		msgQueue.JobName__c = sJobName;
		msgQueue.RecordId__c = sRecordId;
		msgQueue.Status__c = STATUS_INITIATED;
		//msgQueue.OwnerId = '005e0000002Bj3L';
		insert msgQueue;
		return msgQueue.Id;
	}


	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sRecordId - the Rrecord Id to get the sync history for
	 * @param   sJobName - the Job Name to get the sync history for
	 * @param   statuses - the statuses to get the sync history for
	 * @return  List<IntegrationMessageQueue__c>
	 **/
	public static List<IntegrationMessageQueue__c> getSyncHistory(Id recordId, String jobName, Set<String> statuses){
		
		List<IntegrationMessageQueue__c> msgQueues = [SELECT ErrorMessage__c, JobName__c, RecordCount__c, RecordId__c, Status__c, SuccessMessage__c,
														CreatedById, CreatedBy.Name, CreatedDate, LastModifiedDate
														FROM IntegrationMessageQueue__c
														WHERE RecordId__c = :recordId AND Status__c IN :statuses 
														AND JobName__c = :jobName
														ORDER By LastModifiedDate DESC];


		return msgQueues;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   sRecordId - the Record Id to get the sync date/time for
	 * @param   sJobName - the Job Name to get the sync date/time for
	 * @return  Datetime
	 **/
	public static Datetime getLastSuccessfulSyncDateTime(Id recordId, String jobName){
		Datetime result = null;
		Set<String> statuses = new Set<String>{ STATUS_SUCCESS };

		List<IntegrationMessageQueue__c> syncHistory = getSyncHistory(recordId, jobName, statuses);
		if(!syncHistory.isEmpty()){
			result = syncHistory.get(0).LastModifiedDate;
		}

		return result;
	}


	/**
	 * format a date correctly to send to Oracle
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   dateIn - the date to format
	 * @return  String
	 **/
	public Static String formatDateForOracle(Date dateIn){
		
		if(dateIn != null){
			return String.valueOf(dateIn);
		}
		return null;
	}

	/**
	 * format a Boolean correctly to send to Oracle
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   boolIn - the Boolean to format
	 * @return  String - either Y or N
	 **/
	public Static String formatBooleanForOracle(Boolean boolIn){
		String result = null;
		if(boolIn != null){
			if(boolIn){
				result = 'Y';
			}else{
				result = 'N';
			}
		}
		return result;
	}



	////////////////////////////////////////// END UTILS ///////////////////////////////////////////////

	


	public static void submitForApproval(POHeader__c poHeader, Id userId){

		// Create an approval request for the account
		Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setComments('Submitting request for approval.');
		req1.setObjectId(poHeader.id);
		
		// Submit on behalf of a specific submitter
		req1.setSubmitterId(userId); 
		
		// Submit the record to specific process and skip the criteria evaluation
		req1.setProcessDefinitionNameOrId('EcoPurchaseOrder2');
		req1.setSkipEntryCriteria(true);
		
		// Submit the approval request for the account
		Approval.ProcessResult result = Approval.process(req1);
		
		// Verify the result
		/*
		System.assert(result.isSuccess());
		
		System.assertEquals(
			'Pending', result.getInstanceStatus(), 
			'Instance Status'+result.getInstanceStatus());
		*/

		// Approve the submitted request
		// First, get the ID of the newly created item
		List<Id> newWorkItemIds = result.getNewWorkitemIds();
		
		// Instantiate the new ProcessWorkitemRequest object and populate it
		Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
		req2.setComments('Auto approved - requestor is project manager.');
		req2.setAction('Approve');
		req2.setNextApproverIds(new Id[] {userId});
		
		// Use the ID from the newly created item to specify the item to be worked
		req2.setWorkitemId(newWorkItemIds.get(0));
		
		// Submit the request for approval
		Approval.ProcessResult result2 =  Approval.process(req2);
		
		// Verify the results
		/*
		System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
		
		System.assertEquals(
			'Approved', result2.getInstanceStatus(), 
			'Instance Status'+result2.getInstanceStatus());
		*/

	}

	private static void flagPurchaseOrderLineItemsWithSyncStatus(Id purchaseOrderId, String syncStatus){
		List<POLineItem__c> poLineItemsJustSynced = getNonSyncedPurchaseOrderLineItems(purchaseOrderId);

		if(!poLineItemsJustSynced.isEmpty()){
			DateTime timeStamp = Datetime.now();
			for(POLineItem__c poLineItem : poLineItemsJustSynced){
				poLineItem.OracleSyncStatus__c = syncStatus;
				if(syncStatus == SYNC_STATUS_SUCCESS){
					poLineItem.OracleSyncDatetime__c = timeStamp;
				}	    		
			}
			update poLineItemsJustSynced;
		}
			
	}

	private static Set<Id> getChangedRequestPOLineItems(Id purchaseOrderId){
		Set<Id> results = new Set<Id>();
		List<POLineItem__c> allPOLineItems = GetPurchaseOrderLineItems(purchaseOrderId);
		if(!allPOLineItems.isEmpty()){
			for(POLineItem__c poLineItem : allPOLineItems){
				if(poLineItem.ChangeRequestPOLineItem__c != null){
					results.add(poLineItem.ChangeRequestPOLineItem__c);
				}
			}
		}

		return results;
	}


	private static List<POLineItem__c> getNonSyncedPurchaseOrderLineItems(Id purchaseOrderId){
		List<POLineItem__c> results = new List<POLineItem__c>();
		List<POLineItem__c> allPOLineItems = GetPurchaseOrderLineItems(purchaseOrderId);
		if(!allPOLineItems.isEmpty()){
			for(POLineItem__c poLineItem : allPOLineItems){
				if(poLineItem.OracleSyncDatetime__c == null){
					results.add(poLineItem);
				}
			}
		}

		return results;
	}

	public static POLineItem__c ClonePurchaseOrderLineItemForChangeRequest(Id poLineItemId){
		POLineItem__c source = GetPurchaseOrderLineItem(poLineItemId);
		POLineItem__c archive = new POLineItem__c();
		archive.CurrencyIsoCode = source.CurrencyIsoCode;
		archive.POHeader__c = source.POHeader__c;
		archive.ProjectTask__c = source.ProjectTask__c;
		archive.Amount__c = source.Amount__c;
		archive.LineDescription__c = source.LineDescription__c;
		archive.LineType__c = source.LineType__c;
		archive.Quantity__c = source.Quantity__c;
		archive.UnitofMeasure__c = source.UnitofMeasure__c;
		archive.UnitPrice__c = source.UnitPrice__c;
		archive.ExpenditureType__c = source.ExpenditureType__c;
		archive.LineNumber__c = source.LineNumber__c;
		archive.OracleSyncStatus__c = source.OracleSyncStatus__c;
		archive.OracleSyncDatetime__c = source.OracleSyncDatetime__c;
		archive.UnitOfMeasureUserDefined__c = source.UnitOfMeasureUserDefined__c;
		archive.Class__c = source.Class__c;
		archive.SubClass__c = source.SubClass__c;
		archive.IsArchived__c = true;
		archive.ChangeRequestPOLineItem__c = poLineItemId;
		return archive;
	}

	public static List<POLineItem__c> getPreviousPurchaseLineItemVersions(Id poLineItemId){
		List<POLineItem__c> results = [SELECT Id 
										FROM POLineItem__c 
										WHERE ChangeRequestPOLineItem__c = :poLineItemId];
		return results;
	}

	/** ------------------------------------------------------------------------------------------------------
	* @Description 
	*
	* @Author      NTT Data - ?, Deborah Orth
	* @Date        2015
	*-----------------------------------------------------------------------------------------------------*/
	public class POSuccessResponseJson{
		public String PO_NUMBER {get;set;}
		public String PO_HEADER_ID {get;set;}
	}
	
	public static void setPurchaseOrderForPurchaseOrderStatuses(List<POStatus__c> newPOStatuses) {
		Set<String> poNumbers = new Set<String>();
		Map<String, Id> poNumberToSFDCPOIdMap = new Map<String, Id>();
		
		for(POStatus__c poStatus : newPOStatuses) {
			poNumbers.add(poStatus.PONumber__c);
		}
		
		List<POHeader__c> purchaseOrders = [SELECT Id, OraclePurchaseOrderNumber__c FROM POHeader__c WHERE OraclePurchaseOrderNumber__c in : poNumbers];
		for(POHeader__c po : purchaseOrders) {
			poNumberToSFDCPOIdMap.put(po.OraclePurchaseOrderNumber__c, po.Id);	    
		}
		
		for(POStatus__c poStatus : newPOStatuses) {
			if((poStatus.PONumber__c != Null) && (poNumberToSFDCPOIdMap.get(poStatus.PONumber__c) != Null)) {
				poStatus.POHeader__c = poNumberToSFDCPOIdMap.get(poStatus.PONumber__c);
			}           
		}       
	}
	
	public static void lockPurchaseOrderLineItems(Map<Id, POHeader__c> newPurchaseOrderMap, Map<Id, POHeader__c> oldPurchaseOrderMap) {
		Set<Id> purchaseOrderIds = new Set<Id>();
		
		for(POHeader__c purchaseOrder : newPurchaseOrderMap.values()) {
			if(purchaseOrder.Status__c != oldPurchaseOrderMap.get(purchaseOrder.Id).Status__c &&
			   purchaseOrder.Status__c == 'APPROVED') {
				purchaseOrderIds.add(purchaseOrder.Id);
			}
		}
		
		List<POLineItem__c> poLineItems = [SELECT Id, IsLocked__c FROM POLineItem__c WHERE POHeader__c in : purchaseOrderIds];
		
		for(POLineItem__c poLineItem : poLineItems) {
			poLineItem.IsLocked__c = True;
		}
		
		update poLineItems;
	}
}