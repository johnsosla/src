@istest
public class ECO_ePM_Landing_OraceLoginTest {

    @istest
    private static void authTest()
    {
        ApexPages.currentPage().getparameters().put('username', 'fake');
        ApexPages.currentPage().getparameters().put('password', 'none');
        
        insert new ECO_IntegrationEndpoints__c(Name='Project Sync 2', EndPointUrl__c = 'http://fake.none');

        ECO_ePM_Landing_OracleLoginController ctor = new ECO_ePM_Landing_OracleLoginController();
        try
        {
            ctor.authenticateCredentials();
        }catch(Exception e){}
        
        ctor.OraclePassword = ctor.OraclePassword;
    }
}