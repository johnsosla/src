global class ECO_SmartSearchController extends ECO_PageControllerBase {
    public String awanJSPath							{get; set;}
    
    public String coveoToken							{get; set;}
    public String endPointURL							{get; set;}
    public String analyticsEndPoint						{get; set;}
    public String tpnSearchExpression					{get; set;}
    public String searchCoveoSearchInterfaceExpression 	{get; set;}
    public String coveoTabAllExpression					{get; set;}
    public String coveoTabPeopleExpression				{get; set;}
    public String coveoTabProjectsExpression			{get; set;}
    public String coveoTabPracticeExpression			{get; set;}
    public String filterByFileTypeAllowedValues			{get; set;}
    public String sourceFilterCS						{get; set;}
    
    private String randomKey							{get; set;}
    private String orgId								{get; set;}
    
    public String collaborationGroups					{get; set;}
    public String userProfile							{get; set;}
    
    private class ECO_SmartSearchControllerException extends Exception {}    
    private System.LoggingLevel debugLevel = LoggingLevel.INFO;

    public ECO_SmartSearchController() {
        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');
        
        awanJSPath = ECO_PortalSettings__c.getInstance().OnAWANJavascriptPath__c;
    }
    
	public PageReference onLoad () {
        System.debug('Total Number of DML: ' + Limits.getDMLStatements());
        setCollaborationGroups();
        retrieveCustomSettingParameters();
		getSearchToken();
        
        return null;
    }
    
    public void setCollaborationGroups(){
        List<CollaborationGroupMember> cgmList = [select CollaborationGroupId from CollaborationGroupMember where MemberId=:UserInfo.getUserId()];

		List<Id> cgmIdsList = new List<Id>();
        for (CollaborationGroupMember cgm : cgmList){
        	cgmIdsList.add(cgm.CollaborationGroupId);
        }
		collaborationGroups = String.join(cgmIdsList, ',');
    }
    
    public void retrieveCustomSettingParameters() {
        ECO_Smart_Search_Settings__c smartSearchSetting = ECO_Smart_Search_Settings__c.getInstance('SmartSearch');
        
        endPointURL = smartSearchSetting.endPointURL__c;
        analyticsEndPoint = smartSearchSetting.Analytics_End_Point__c;
        
        tpnSearchExpression = smartSearchSetting.TPN_Search_Expression1__c;
        if(smartSearchSetting.TPN_Search_Expression_2__c != null && smartSearchSetting.TPN_Search_Expression_2__c != '') {
            tpnSearchExpression = tpnSearchExpression + ' OR ' + smartSearchSetting.TPN_Search_Expression_2__c;            
        }
        tpnSearchExpression = tpnSearchExpression.replace('{!collaborationGroups}', collaborationGroups);
        
        searchCoveoSearchInterfaceExpression = smartSearchSetting.Search_CoveoSearchInterface_Expression__c;
        
        coveoTabAllExpression = smartSearchSetting.CoveoTab_All_Expression1__c;
        if(smartSearchSetting.CoveoTab_All_Expression2__c != null && smartSearchSetting.CoveoTab_All_Expression2__c != '') {
            coveoTabAllExpression = coveoTabAllExpression + ' OR ' + smartSearchSetting.CoveoTab_All_Expression2__c;
        }
        
        coveoTabAllExpression = coveoTabAllExpression.replace('{!collaborationGroups}', collaborationGroups);
        
        coveoTabPeopleExpression = smartSearchSetting.CoveoTab_People_Expression__c;
        
        coveoTabProjectsExpression = smartSearchSetting.CoveoTab_Projects_Expression__c;
        
        coveoTabPracticeExpression = smartSearchSetting.CoveoTab_Practice_Expression_1__c;
		if(smartSearchSetting.CoveoTab_Practice_Expression_2__c != null && smartSearchSetting.CoveoTab_Practice_Expression_2__c != '') {
            coveoTabPracticeExpression = coveoTabPracticeExpression + ' OR ' + smartSearchSetting.CoveoTab_Practice_Expression_2__c;
        }       
        
        coveoTabPracticeExpression = coveoTabPracticeExpression.replace('{!collaborationGroups}', collaborationGroups);
        
        filterByFileTypeAllowedValues = smartSearchSetting.Filter_By_File_Type_Allowed_Values__c;
        
        randomKey = smartsearchSetting.Key__c;
        
        orgId = smartSearchSetting.OrganizationId__c;
        if(String.isBlank(orgId) || orgId.length() != 15){
        	orgId = UserInfo.getOrganizationId();
        }  
        
        sourceFilterCS = smartSearchSetting.Source_Filter__c;
        //String sourceFilterCS = 'NOT @syssource==(\"MyAECOM - Production\")'; //value is a test: Should be reading from a custom setting
    }
    
    public PageReference getSearchToken() {
        Id profileId = UserInfo.getProfileId();
        
		String profileName = [SELECT Id, Name FROM Profile WHERE Id=:profileId].Name;
        
        //Coveo UA: provide profilename to VF page, so it can forward it to UA database.
        userProfile = profileName;
        
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
    
    @RemoteAction
    global static String getMyRecentSearch() {
        User usr = [SELECT Id, smartSearchMyRecentSearch__c FROm User WHERE Id =: UserInfo.getUserId()];
        
        return usr.smartSearchMyRecentSearch__c;
    }
    
    @RemoteAction
    global static void pushMyRecentSearch(String smartSearchMyRecentSearch) {
        User usr = [SELECT Id, smartSearchMyRecentSearch__c FROm User WHERE Id =: UserInfo.getUserId()];
        usr.smartSearchMyRecentSearch__c = smartSearchMyRecentSearch;
        
        update usr;
    }
    
    @RemoteAction
    global static String getMyRecentlyViewed() {
        User usr = [SELECT Id, smartSearchMyRecentlyViewed__c FROm User WHERE Id =: UserInfo.getUserId()];
        
        return usr.smartSearchMyRecentlyViewed__c;
    }
    
    @RemoteAction
    global static void pushMyRecentlyViewed(String smartSearchMyRecentlyViewed) {
        User usr = [SELECT Id, smartSearchMyRecentlyViewed__c FROm User WHERE Id =: UserInfo.getUserId()];
        usr.smartSearchMyRecentlyViewed__c = smartSearchMyRecentlyViewed;
        
        update usr;
    }
}