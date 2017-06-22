/**
 * @author Sujit Kumar
 * @date June 22, 2016
 */
@isTest
private class ECO_RMASummaryControllerPdfTest
{
	private static testMethod void givenAProjectWithQuesSet_afterInit_VerifyPdfFileName(){
		// Arrange
		ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
		pse__Proj__c theProject = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
		QuestionnaireSet__c qs = new ECO_Utils_Testing.QuestionnaireBuilder(theProject).addMarketAssessment().addRisk().build();

		// Act
		Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qs);        
        ECO_RMASummaryControllerPdf ecoRMASummaryControllerPdf = new ECO_RMASummaryControllerPdf(sc);
        ecoRMASummaryControllerPdf.init();
        ecoRMASummaryControllerPdf.getWrappedAnswersForAllQuestionnaires();

		Datetime myDatetime = Datetime.now();
		String myDatetimeStr = myDatetime.format('yyyyMMdd');
		
		// Retrieve the ProjectNumber__c 
		theProject = [select Id, ProjectNumber__c from pse__Proj__c limit 1];
		String actualPdfFileName = theProject.ProjectNumber__c + '_RMASummary_' + qs.Name + '_' + myDatetimeStr + '.pdf';
		
		Test.stopTest();
		
		// Assert
		System.assertEquals(ecoRMASummaryControllerPdf.pdfFileName, actualPdfFileName);
	}
}