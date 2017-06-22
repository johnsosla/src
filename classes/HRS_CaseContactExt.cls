/*
*    Project Name        : eConnect
*    Project NameSpace   : HRS
*    Class Name          : HRS_CaseContactExt
*    Date                : Oct 11th, 2016
*    Description         : A VF extsion to the Case controller
*                        : 
*/

public with sharing class HRS_CaseContactExt {

	Private Boolean isSetup {get; set;}				//Check if Custom Setting is setup for Case Type
	Public Boolean isTokenValid {get; set;}			//Check if user has valid token
	Public Boolean isDisplay {get; set;}			//Check if display is allowed to user
	Public String OracleUserName {get; set;}		//Oracle Username variable
	Public String OraclePassword {get; set;}		//Oracle Password variable
	Public String AuthenticationResult {get; set;}	//Result from the login request

	Private ApexPages.StandardController ctrl;		//Case Controller
	Private Case c;									//Case Object Variable

	Public HRSManager hrsManager {get; set;}		//HRS Manager variable

	Public HRS_CaseContactExt( ApexPages.StandardController controllerParam ) {
		ctrl = controllerParam;
    	c = (Case)ctrl.getRecord();	

    	isTokenValid = false;				//Assume Token is not valid
    	isDisplay = false;					//Assume Display to user is not needed
    	isSetup = false;					//Assume Custom Setting case type mapping is not completed

    	hrsManager = new HRSManager();

    	if ( c != null && c.Id != null ){

    		c = [select Id, Type, Tracking_ID__c, CaseNumber, Status from Case where Id =: c.Id ];

    		hrsManager.hrcase = c ;

    		//To set the locked value if the case status meet the following status
    		if ( c.Status == 'Approved' || c.Status == 'In Approval' || c.Status == 'System Entry' || c.Status == 'Complete' )
    			hrsManager.isLocked = true;
    	}  
    	//check if the security token is valid
    	isTokenValid = ECO_Service_Authentication.authenticateOracleTokenSecure( UserInfo.getUserId() );
    	//check if the setup is done correctly based on the type in the case
    	isSetup = checkSetupType( hrsManager.hrcase.Type );   
	}

    //Function : checkSetupType
    //Parameter : String
    //Return : Boolean
    //To check if all the custom setting is setup correctly for the case type
    //If setup is not done, field can't be display to user
	Public Boolean checkSetupType ( String TypeValue ){

		List<HRS_API__mdt> hrsList = new List<HRS_API__mdt>();
		
		try {
			hrsList = [select Id, CaseType__c, Field__c, isActive__c, Order__c, isRead__c, isEdit__c, FieldType__c from HRS_API__mdt where 
									CaseType__c =: TypeValue and isActive__c = true order by Order__c asc ];
		} catch ( Exception ex ){
			System.debug('The following exception has occurred: ' + ex.getMessage());
		}

		Boolean isReadFound = false;
		Boolean isEditFound = false;

		for ( HRS_API__mdt hrsapi : hrsList ){
			//Checking against the Case Type and Custom Setting Type
			//Only add into the set if the active check is checked
			if ( hrsapi.CaseType__c == TypeValue && hrsapi.isActive__c == true && hrsapi.isRead__c == true ){
				isReadFound = true;
				hrsManager.readWorker.fieldsList.add( hrsapi.Field__c );
			}

			if ( hrsapi.CaseType__c == TypeValue && hrsapi.isActive__c == true && hrsapi.isEdit__c == true ){
				isEditFound = true;
				hrsManager.editWorker.fieldsList.add( hrsapi.Field__c );
			}	

			if ( hrsapi.FieldType__c == 'Text'){
				hrsManager.inputList.add( hrsapi.Field__c );
			}
			if ( hrsapi.FieldType__c == 'Picklist'){
				hrsManager.picklistList.add( hrsapi.Field__c );
			}
			if ( hrsapi.FieldType__c == 'Date'){
				hrsManager.dateList.add( hrsapi.Field__c );
			}

		}

		//Once we have identified the requested field, we construct the query and store it in the worker
		if ( hrsManager.readWorker.fieldsList.size() > 0 ){
			hrsManager.readWorker.dynamicQuery = '?$select=' + String.join ( new List<String>( hrsManager.readWorker.fieldsList ), ',');
		}
		if ( hrsManager.editWorker.fieldsList.size() > 0 ){
			hrsManager.editWorker.dynamicQuery = '?$select=' + String.join ( new List<String>( hrsManager.editWorker.fieldsList ), ',');
		}
		//We put the field type string field with the list populate above
		if ( hrsManager.inputList.size() > 0 ){
			hrsManager.inputStr =  String.join ( new List<String>( hrsManager.inputList ), ',');
		}
		if ( hrsManager.picklistList.size() > 0 ){
			hrsManager.picklistStr =  String.join ( new List<String>( hrsManager.picklistList ), ',');
		}
		if ( hrsManager.dateList.size() > 0 ){
			hrsManager.dateStr =  String.join ( new List<String>( hrsManager.dateList ), ',');
		}
		//It depends on which pages you are on, it returns if the setup is done correctly
		if ( hrsManager.pageName.contains('HRS_OdataRead') )
			return isReadFound;
		if ( hrsManager.pageName.contains('HRS_OdataEdit') )
			return isEditFound;

		return false;
	}	

    //Function : validateRetrieve
    //Parameter : None
    //Return : None
    //Initialize function, it will run when the page loads
	public void validateRetrieve(){

    	//validate case record has a tracking ID, post msg to user otherwise
    	if ( hrsManager.hrcase.Tracking_ID__c == '' ){
          apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, System.Label.hasTrackingIDError );
          apexpages.addmessage(msg); 

    	}

		//validate custom setting is setup for case Type, post msg to user otherwise
		//If case type doesn't need to display PII, no Tab is added into the console layout
    	if ( isSetup != true ){
          apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info, System.Label.hasSetupError );
          apexpages.addmessage(msg);    		
    	}
    	
    	//To check if all predefined condition is met before rendering the page
		if ( isTokenValid && isSetup && hrsManager.hrcase.Tracking_ID__c != '' ){

			isDisplay = true;

		} 

        //This is to query the oracle key and formatting for URI
        //For security purpose, this is on demand only and not stored in anywhere
    	User user = [select Id, ShaKey__c, FederationIdentifier from User where Id = :UserInfo.getUserId()];
    	String key = user.ShaKey__c;
    	String fid = user.FederationIdentifier;

    	//Construct the read End Point with the employee tracking ID
   		String readEndPointBase = hrsManager.readWorker.baseUrl +'(\''+ hrsManager.hrcase.Tracking_ID__c +'\')';

   		//Check if the user is on the READ page and calls the correct endpoint
   		//if result is successful, parse the value into JSON2Employee object
    	if ( hrsManager.pageName.contains('HRS_OdataRead')){
    		hrsManager.readWorker.resultRsp = ECO_Service_Authentication.DynamicProxyRequestNew( readEndPointBase + hrsManager.readWorker.dynamicQuery, key, 'eConnect', false, false, hrsManager.MAXTIMEOUT, fid, null, null );
				if ( hrsManager.readWorker.resultRsp != null && hrsManager.readWorker.resultRsp.getBody() != '' ) 
					hrsManager.employee = JSON2Employee.parse( hrsManager.readWorker.resultRsp.getBody() );

    	}

   		//Check which page the user is on and calls the correct endpoint
   		//if result is successful, parse the value into JSON2Employee object
   		//if result is empty, which means it is a brand new case
   		//it will first get data from read end point, parse into JSON2Employee and map data into employee object
   		//if result exists, which means it is only for update, eTag will be stored
    	if ( hrsManager.pageName.contains('HRS_OdataEdit') ){
    		//Construct the write End Point with the Case Number
    		String editEndPointBase = hrsManager.editWorker.baseUrl +'(\''+ hrsManager.hrcase.CaseNumber +'\')';

			hrsManager.editWorker.resultRsp = ECO_Service_Authentication.DynamicProxyRequestNew( editEndPointBase + hrsManager.editWorker.dynamicQuery, key, 'eConnect', false, false, hrsManager.MAXTIMEOUT, fid, null, null );
			//hrsManager.casebodyResult = caseRsp.getBody();

			if ( hrsManager.editWorker.resultRsp != null && hrsManager.editWorker.resultRsp.getHeader('ETag') != null ) 
				hrsManager.eTag = hrsManager.editWorker.resultRsp.getHeader('ETag');

			if ( hrsManager.editWorker.resultRsp != null && hrsManager.editWorker.resultRsp.getBody() == '' ){

				//Only request when No record has been saved from DB to the READ endpoint
				if ( hrsManager.readWorker.dynamicQuery != '' )
					hrsManager.readWorker.resultRsp = ECO_Service_Authentication.DynamicProxyRequestNew( readEndPointBase + hrsManager.readWorker.dynamicQuery, key, 'eConnect', false, false, hrsManager.MAXTIMEOUT, fid, null, null );
					
					if ( hrsManager.readWorker.resultRsp != null && hrsManager.readWorker.resultRsp.getBody() != '' ){
						hrsManager.employee = JSON2Employee.parse( hrsManager.readWorker.resultRsp.getBody() );
						hrsManager.readWorker.keyValueMap = JSON2Case.parseValue( hrsManager.readWorker.resultRsp.getBody() );
					}
				//use the Pre Populate json string to push the data into EDIT worker
				//and store the URL endpoint as New Case
				String preDefineJson = hrsManager.prePopulateJsonStr();
				hrsManager.casepii = JSON2Case.parse( preDefineJson );
				hrsManager.editWorker.keyValueMap = JSON2Case.parseValue( preDefineJson );
				hrsManager.editWorker.baseUrl = hrsManager.editWorker.baseUrl;

			} else { 
				//if record already exists in the database, no employee to case operation is required 
				//store the url endpoint with the case number
				if ( hrsManager.editWorker.resultRsp != null ) { 
					hrsManager.casepii = JSON2Case.parse( hrsManager.editWorker.resultRsp.getBody() );
					hrsManager.editWorker.keyValueMap = JSON2Case.parseValue( hrsManager.editWorker.resultRsp.getBody() );
    				hrsManager.editWorker.baseUrl = hrsManager.editWorker.baseUrl +'(\''+ hrsManager.hrcase.CaseNumber +'\')';
				}    					
			}

			//depends on the picklist input populate the picklist key and option mapping
    	    hrsManager.setPicklistMapping();

    	}

	}

    //Function : authenticateCredentials
    //Parameter : None
    //Return : PageReference Null
	public PageReference authenticateCredentials(){

        String username = ApexPages.currentPage().getParameters().get('username');
        String password = ApexPages.currentPage().getParameters().get('password');

        ECO_IntegrationEndpoints__c cs;
        cs = ECO_IntegrationEndpoints__c.getInstance('Project Sync 2');

        String endPointUrl = cs.EndPointUrl__c;

        authenticationResult = ECO_Service_Authentication.TestProxyHR(endPointUrl, 'PICAction=CreateSHAKey&UserId=' + username + '&Password=' + EncodingUtil.URLENCODE(password,'UTF-8'));

        isTokenValid = ECO_Service_Authentication.authenticateOracleTokenSecure( UserInfo.getUserId() );

        return null;
    }

    //Function : closeAuthenticationWindow
    //Parameter : None
    //Return : PageReference Null
	public PageReference closeAuthenticationWindow(){

	    if(isTokenValid){
	          validateRetrieve();
	          //startRequest();
	    }
	        return null;        
	} 
 
}