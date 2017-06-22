public class ECO_SmartSearch_TokenExt {
    public String coveoToken							{get; set;}
    public String endPointURL							{get; set;}
    
    public ECO_SmartSearch_TokenExt(ApexPages.StandardController tdCcontroller) {
        generateToken();
    }
    
    public ECO_SmartSearch_TokenExt() {
        generateToken();
    }

    public void generateToken() {
        ECO_Smart_Search_Settings__c smartSearchSetting = ECO_Smart_Search_Settings__c.getInstance('SmartSearch');
        endPointURL = smartSearchSetting.endPointURL__c;
        String randomKey = smartsearchSetting.Key__c;

        String orgId = smartSearchSetting.OrganizationId__c;
        if(String.isBlank(orgId) || orgId.length() != 15){
        	orgId = UserInfo.getOrganizationId();
        }
        
        Id profileId = UserInfo.getProfileId();
		String profileName = [SELECT Id, Name FROM Profile WHERE Id=:profileId].Name;
        
        // Make endpointURL and key passed to the server configurable.
    	Http http = new Http();
        String orgIdFilter = '(@sforganizationid=('+orgId.substring(0, 15)+') OR NOT @sforganizationid)';//every saleforce document from current org  + everything  that is not Salesforce conent
        String jsonReq = '{"userIds": [{"name":"' + UserInfo.getUserEmail() + '", "provider" : "Email Security Provider", "type" : "User"}],"filter": "'+orgIdFilter+'","userGroups": ["' + profileName + '"]}';
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
    }

}