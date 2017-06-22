@isTest
private class ECO_ChangeRecordTypeSelectControllerTest {

    static testMethod void positiveCancelReturnsToRetUrl() {

        PageReference testPage = Page.ECO_ChangeRecordTypeSelect;
        testPage.getParameters().put('retUrl', 'https://www.Salesforce.com/apex/testing');
        Test.setCurrentPage(testPage);

        ECO_ChangeRecordTypeSelectController controller = new ECO_ChangeRecordTypeSelectController();
        controller.startHere();
        controller.btnContinue();
        PageReference returnURL;

        Test.startTest();
            returnURL = controller.btnCancel();
        try {
        } catch (Exception e) {
            System.assert(False, '*****>Error in positiveCancelReturnsToRetUrl: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
        Test.stopTest();

        System.assertEquals('https://www.Salesforce.com/apex/testing', returnURL.getUrl(), '*****>Error in positiveCancelReturnsToRetUrl: return URL not as expected on Cancel');

    }
    
}