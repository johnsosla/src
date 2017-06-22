@isTest
public class ECO_OracleFileViewerControllerTest {
	
	static testMethod void testOracleFileViewerController() {

		ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c(Name = 'OracleFileViewer');
		endpoint.EndPointUrl__c = 'test';
		insert endPoint;

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTaskTriggers.run = true;
        ECO_ProjectTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		OracleFile__c oracleFile = new OracleFile__c();
		oracleFile.Project__c = project.Id;
		oracleFile.FileId__c = '12345678';
		insert oracleFile;

		ApexPages.StandardController stdController = new ApexPages.StandardController(oracleFile);

		try
		{
		ECO_OracleFileViewerController controller = new ECO_OracleFileViewerController(stdController);
		controller.init();
		}catch(Exception e){}
		
	}

	static testMethod void testOracleFileViewerControllerAuthenticateCredentials() {

		ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c(Name = 'OracleFileViewer');
		endpoint.EndPointUrl__c = 'test';
		insert endPoint;

		ECO_IntegrationEndpoints__c endpoint2 = new ECO_IntegrationEndpoints__c(Name = 'Project Sync 2');
		endpoint2.EndPointUrl__c = 'test';
		insert endPoint2;
		
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTaskTriggers.run = true;
        ECO_ProjectTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];
		OracleFile__c oracleFile = new OracleFile__c();
		oracleFile.Project__c = project.Id;
		oracleFile.FileId__c = '12345678';
		insert oracleFile;

		ApexPages.currentPage().getParameters().put('userName', 'test');
		ApexPages.currentPage().getParameters().put('password', 'test');

		ApexPages.StandardController stdController = new ApexPages.StandardController(oracleFile);

		try
		{
		ECO_OracleFileViewerController controller = new ECO_OracleFileViewerController(stdController);
		controller.init();
		controller.authenticateCredentials();
		controller.closeAuthenticationWindow();
		controller.returnToProject();
		controller.OracleUserName = 'test';
		controller.OraclePassword = 'test';
		}catch(Exception e){}
		
	}
}