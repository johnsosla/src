@isTest
public class ECO_ServiceAuthenticationTest {
	

	static testMethod void testServiceAuthentication() {

		try
		{
		ECO_Service_Authentication.authenticateOracleToken(UserInfo.getUserId());
		ECO_Service_Authentication.TestProxy('Test', 'Test');

		ECO_Service_Authentication.PICRequestStatus status = new ECO_Service_Authentication.PICRequestStatus();
		}
		catch(Exception e){}

	}
}