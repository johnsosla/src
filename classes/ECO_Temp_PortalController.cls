public with sharing class ECO_Temp_PortalController {
	
	public User theHeaderUser { get; set; }
	public List<ProcessInstanceWorkitem> approvals		{ get; set; }
	public List<Task> tasks								{ get; set; }
	public List<PortalMessage__c> alerts				{ get; set; }
	public String photoUrl								{ get; set; }
	public List<Configuration__c> applications			{ get; set; }
	public List<PortalMessage__c> tickerMessages		{ get; set; }	
	public String awanJSPath							{ get; set; }
    
    public String coveoToken							{get; set;}
    public String endPointURL							{get; set;}
    private String randomKey							{get; set;}
    private String orgId								{get; set;}
    public String sourceFilterCS						{get; set;}

	public ECO_Temp_PortalController () {
		theHeaderUser = ECO_Service_Users.getUserInfoById(UserInfo.getUserId());
		approvals = ECO_Service_Users.getApprovalsForUser(theHeaderUser.Id);
		tasks = ECO_Service_Users.getOpenTasksForUser(theHeaderUser.Id);
		alerts = ECO_Utils_Alerts.getPortalMessagesForUser(theHeaderUser.Id);
		tickerMessages = ECO_Utils_Alerts.getTickerMessages();
		applications = ECO_Service_Applications.getSortedList(theHeaderUser);
		awanJSPath = ECO_PortalSettings__c.getInstance().OnAWANJavascriptPath__c;
		
		if (!Test.isRunningTest()) {
			photoUrl = ConnectApi.ChatterUsers.getPhoto(null, theHeaderUser.Id).smallPhotoUrl;
		}
        
        retrieveCustomSettingParameters();
		getSearchToken();
	} 
	
	public PageReference onLoad() {
		// applications = ECO_Service_Applications.getSortedList(theHeaderUser);
		ECO_Service_Applications.upsertApplicationsForUser();
		System.debug('applications size: ' + applications.size());
		return null;
	}
	
	public PageReference goToApplicationConfiguration () {
		PageReference returnPR = Page.ECO_ApplicationCustomizer;
		returnPR.getParameters().put('retURL', EncodingUtil.urlEncode('/apex/ECO_Portal', 'UTF-8'));
		return returnPR;
	}
 
 	/*
	public PageReference goToApplicationConfigurationv2 () {
		PageReference returnPR = Page.ECO_ApplicationCustomizer;
		returnPR.getParameters().put('retURL', EncodingUtil.urlEncode('/apex/ECO_Portalv2', 'UTF-8'));
		return returnPR; 
	}
	*/
	
	public PageReference goToReportBuilder () {
		PageReference returnPR = Page.ECO_ReportFinder;
		returnPR.getParameters().put('retURL', EncodingUtil.urlEncode('/apex/ECO_Portal', 'UTF-8'));
		return returnPR;
	}

	/*
	public PageReference goToReportBuilderv2 () {
		PageReference returnPR = Page.ECO_ReportFinder;
		returnPR.getParameters().put('retURL', EncodingUtil.urlEncode('/apex/ECO_Portalv2', 'UTF-8'));
		return returnPR;
	}
	*/
	
	public PageReference goToNewProject () {
		//PageReference pageRef = Page.ECO_ProjectSetup;
		PageReference pageRef = new PageReference('/'+pse__Proj__c.sObjectType.getDescribe().getKeyPrefix()+'/e');
		pageRef.getParameters().put('retURL', EncodingUtil.urlEncode('/apex/ECO_Portal', 'UTF-8'));
		return pageRef;
	}
	
	public PageReference goToNewOpportunity () {
		PageReference pageRef = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F006%2Fo&save_new_url=%2F006%2Fe%3FretURL%3D%252F006%252Fo');
		// PageReference pageRef = new PageReference('/'+Opportunity.sObjectType.getDescribe().getKeyPrefix()+'/e');
		pageRef.getParameters().put('retURL', EncodingUtil.urlEncode('/apex/ECO_Portal', 'UTF-8'));
		return pageRef;
	}
    
    public void retrieveCustomSettingParameters() {
        ECO_Smart_Search_Settings__c smartSearchSetting = ECO_Smart_Search_Settings__c.getInstance('SmartSearch');
        
        endPointURL = smartSearchSetting.endPointURL__c;
        
        randomKey = smartsearchSetting.Key__c;
        
        orgId = smartSearchSetting.OrganizationId__c;
        if(String.isBlank(orgId) || orgId.length() != 15){
        	orgId = UserInfo.getOrganizationId();
        }
        
        sourceFilterCS = smartSearchSetting.Source_Filter__c;
    }
    
    public PageReference getSearchToken() {
        Id profileId = UserInfo.getProfileId();
        
		String profileName = [SELECT Id, Name FROM Profile WHERE Id=:profileId].Name;
        
        // Make endpointURL and key passed to the server configurable.
    	Http http = new Http();
        String orgIdFilter = '(@sforganizationid=('+orgId.substring(0, 15)+') OR NOT @sforganizationid)';//every saleforce document from current org  + everything  that is not Salesforce conent
        
        String sourceFilter = ''; 
        if(!String.IsBlank(sourceFilterCS)){
            // escape JSON double quotes
        	sourceFilter = '('+ sourceFilterCS.replace('"', '\\"') +')';
        }
        
        String finalFilter = orgIdFilter + ' ' + sourceFilter;
        String jsonReq = '{"userIds": [{"name":"' + UserInfo.getUserEmail() + '", "provider" : "Email Security Provider", "type" : "User"}],"filter": "'+finalFilter+'","userGroups": ["' + profileName + '"]}';
        System.debug('jsonReq: ' + jsonReq);
        String endPoint = endPointURL + 'token';
        
        HttpRequest request = new HttpRequest();
        
        request.setMethod('POST');
        
        request.setHeader('content-type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + randomKey);
        request.setEndpoint(endPoint);
        request.setBody(jsonReq);
        
        HTTPResponse response = http.send(request);
        system.debug('Response: ' + response.getBody());
        
        System.debug('response.getStatusCode(): ' + response.getStatusCode());
		if(response.getStatusCode() == 200) {
            System.debug('parsing record');
            JSONParser parser = JSON.createParser(response.getBody());
            parser.nextToken();
			parser.nextValue();
            coveoToken = parser.getText();
        }
        else {
            coveoToken = null;
        }
        system.debug('coveoToken: ' + coveoToken);
        
        return null;
    }
	
}