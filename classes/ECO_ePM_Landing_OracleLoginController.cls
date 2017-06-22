public class ECO_ePM_Landing_OracleLoginController {

    public String OracleUserName {get; set;}
    public String OraclePassword {get; set;}
    public String authenticationResult {get; set;}


    public PageReference authenticateCredentials()
    {
        String username = ApexPages.currentPage().getParameters().get('username');
        String password = ApexPages.currentPage().getParameters().get('password');

        ECO_IntegrationEndpoints__c cs;
        cs = ECO_IntegrationEndpoints__c.getInstance('Project Sync 2');

        String endPointUrl = cs.EndPointUrl__c;

        //OracleUserName = changeManager.OracleUserName__c;
        authenticationResult = ECO_Service_Authentication.TestProxy(endPointUrl, 'PICAction=CreateSHAKey&UserId=' + username + '&Password=' + EncodingUtil.URLENCODE(password,'UTF-8'));

        return null;
    }

    
}