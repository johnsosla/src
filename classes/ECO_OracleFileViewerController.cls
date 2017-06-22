public with sharing class ECO_OracleFileViewerController {
	
	private String fileId;
	public String targetURL {get; set;}
	public Boolean renderPage {get; set;}
	public OracleFile__c oracleFile {get; set;}
	public Boolean isTokenValid {get; set;}
	public String OracleUserName {get; set;}
	public String OraclePassword {get; set;}
	public String AuthenticationResult {get; set;}

	public ECO_OracleFileViewerController(ApexPages.StandardController standardController) {
		oracleFile = (OracleFile__c)standardController.getRecord();
	}

	public PageReference init()
	{
		isTokenValid = getIsTokenValid();

		renderPage = isTokenValid;

		User user = [select Id, ShaKey__c from User where Id = :UserInfo.getUserId()];
    	ECO_IntegrationEndpoints__c cs;
    	targetURL = '';
		cs = ECO_IntegrationEndpoints__c.getInstance('OracleFileViewer');
		
	   	targetURL = cs.EndPointUrl__c + '?PICAction=SalesIntegration&ebizId=' + user.ShaKey__c + '&AttachedDocId=' + oracleFile.FileId__c;
		if(!isTokenValid)
        {
        	return null;	    
        }

        return new PageReference(targetURL);
	}

	public boolean getIsTokenValid()
	{
		return ECO_Service_Authentication.authenticateOracleToken(UserInfo.getUserId());
	}

    public PageReference closeAuthenticationWindow()
    {
		if(isTokenValid)
        	return new PageReference(targetURL);
        return null;        
    }

    public PageReference returnToProject()
    {
    	return new PageReference('/' + oracleFile.Project__c);
    }

	public PageReference authenticateCredentials()
    {
        String username = ApexPages.currentPage().getParameters().get('username');
        String password = ApexPages.currentPage().getParameters().get('password');

        ECO_IntegrationEndpoints__c cs;
        cs = ECO_IntegrationEndpoints__c.getInstance('Project Sync 2');

        String endPointUrl = cs.EndPointUrl__c;

        authenticationResult = ECO_Service_Authentication.TestProxy(endPointUrl, 'PICAction=CreateSHAKey&UserId=' + username + '&Password=' + EncodingUtil.URLENCODE(password,'UTF-8'));

        isTokenValid = getIsTokenValid();
        renderPage = isTokenValid;

        return null;
    }
}