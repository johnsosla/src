@isTest
public class CFM_QualtricsSendSurveyToPanelCallTest {

    public static testMethod void testDefaultArguments() {
        Test.setMock(HttpCalloutMock.class, new CFM_QualtricsSendSurveyResponseMock());

        CFM_Survey_Batch__c batch = new CFM_Survey_Batch__c();
        batch.Target_Survey_Date__c = Date.today();
        insert batch;

        Test.startTest();
        CFM_QualtricsSendSurveyToPanelCallout callout = new CFM_QualtricsSendSurveyToPanelCallout(new CFM_SurveyBatch(batch), 'testPanelId');

        HttpResponse res = callout.callout();
        
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode(), 'Status code should be OK');

        CFM_QualtricsSendSurveyToPanelResponse response = CFM_QualtricsSendSurveyToPanelResponse.parse(res.getBody());
        System.assertEquals(CFM_QualtricsBaseCallout.STATUS_SUCCESS, response.Meta.Status, 'Response should have reported Success: ' + res.getBody());
    }

}