/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_SalesGoalCustomReportControllerTest
*              PURPOSE: Test class for SGT_SalesGoalCustomReportController
*              CREATED: 08/2016 Ethos Solutions - www.ethos.com
**/
@isTest
private class SGT_SalesGoalCustomReportControllerTest {

	//@isTest(SeeAllData='true') 
	static testmethod void testController() {
		SGT_Sales_Goal__c salesGoal = SGT_TestUtil.createTestBusinessLineSalesGoal();
		ApexPages.currentPage().getParameters().put('reportName', SGT_SalesGoalCustomReportController.BOOKINGS_YTD);
		ApexPages.StandardController std = new ApexPages.StandardController(salesGoal);
		SGT_SalesGoalCustomReportController cont = new SGT_SalesGoalCustomReportController(std);

		// Cannot query reports without SeeAllData=true, however having SeeAllData enabled is causing a CPU Limits error
		//PageReference pr = cont.goToCustomReport();
		//System.assert(pr.getUrl().contains('Architecture'), pr.getUrl());

		//ApexPages.currentPage().getParameters().put('reportName', SGT_SalesGoalCustomReportController.FORECAST_BOOKINGS_OUTLOOK);
		//Report customReport = [Select Id from Report where DeveloperName =: SGT_SalesGoalCustomReportController.FORECAST_BOOKINGS_OUTLOOK];
		//pr = cont.goToCustomReport();
		//System.assert(pr.getUrl().contains(customReport.Id));

		//ApexPages.currentPage().getParameters().put('reportName', SGT_SalesGoalCustomReportController.WINS_YTD);
		//customReport = [Select Id from Report where DeveloperName =: SGT_SalesGoalCustomReportController.WINS_YTD];
		//pr = cont.goToCustomReport();
		//System.assert(pr.getUrl().contains(customReport.Id));
		//System.assert(pr.getUrl().contains('bool_filter'));

		//ApexPages.currentPage().getParameters().put('reportName', SGT_SalesGoalCustomReportController.FORECAST_WINS_OUTLOOK);
		//customReport = [Select Id from Report where DeveloperName =: SGT_SalesGoalCustomReportController.FORECAST_WINS_OUTLOOK];
		//pr = cont.goToCustomReport();
		//System.assert(pr.getUrl().contains(customReport.Id));
	}
	
	
}