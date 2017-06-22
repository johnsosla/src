@isTest
public class CFM_QualtricsImportPanelCalloutTest {

    public static testMethod void testDefaultArguments() {
        Test.setMock(HttpCalloutMock.class, new CFM_QualtricsImportPanelResponseMock());

        CFM_Survey_Batch__c batch = new CFM_Survey_Batch__c();
        insert batch;

        Test.startTest();
        CFM_QualtricsImportPanelCallout callout = new CFM_QualtricsImportPanelCallout(batch.Id, 'Test,csv,string');
        System.assertEquals('Test,csv,string', callout.getSurveyBatchProjectCSV(), 'Getter should have returned initial value');

        callout.setSurveyBatchProjectCSV('Survey Batch: Survey Batch Number,Survey Batch: ID,Survey_Batch_Project_Id,Project_Name,Project ID,Project Name: Business Line,AECOM_Firm,Survey Contact,Contact ID,Email,Project Name: Survey Contact Phone,Project Name: Survey Contact Language,Oracle Client Name,Account ID,Oracle Client Number,Geo,Oracle District,Oracle % Complete,Project Name: Oracle Department,Project Name: Oracle Project Director,Oracle Project Manager,Project Name: Oracle Project Number,Oracle Status,Oracle Region,Oracle Super Geography\nSBP-002868,a4lM0000000AFoMIAW,SBP-002868,MICOS Al Sys Thermal,a0gM0000008YDDCIA4,SBP-002868,AECOM,Austin Test-csv,003M000000egJjmIAE,adelorme+csv@ethos.com,(555) 555-5555,EN,MICOS ALUMINIUM SYSTEMS PTY LTD,,52250,ANZ,ANZ - NAC,99,2428 - 80.BLD - FACADES - Sydney,Austin Delorme,Austin Delorme,60143771,Approved,ANZ STHN,APAC');

        HttpResponse res = callout.callout();
        
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode(), 'Status code should be OK');

        CFM_QualtricsImportPanelResponse response = CFM_QualtricsImportPanelResponse.parse(res.getBody());
        System.assertEquals(CFM_QualtricsBaseCallout.STATUS_SUCCESS, response.Meta.Status, 'Response should have reported Success: ' + res.getBody());
    }

}