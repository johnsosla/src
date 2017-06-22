public with sharing class CFM_QualtricsSendSurveyToPanelResponse {
    public Meta Meta;
    public Result Result;

    public class Meta {
        public String Status;
        public String RequestType;
        public Integer ErrorCode;
        public String QualtricsErrorCode;
        public String ErrorMessage;
        public String Debug;
    }

    public class Result {
        public Boolean Success;
        public String EmailDistributionID;
        public String DistributionQueueID;
    }

    
    public static CFM_QualtricsSendSurveyToPanelResponse parse(String json) {
        return (CFM_QualtricsSendSurveyToPanelResponse) System.JSON.deserialize(json, CFM_QualtricsSendSurveyToPanelResponse.class);
    }
}
    //static testMethod void testParseStatusError() {
    //    String json = '{"Meta":{"Status":"Error","RequestType":"sendSurveyToPanel","ErrorCode":400,"QualtricsErrorCode":"ESRV35|SendDate","ErrorMessage":"Invalid request. Missing or invalid parameter SendDate.","Debug":""},"Result":null}';
    //    JSON2Apex obj = parse(json);
    //    System.assert(obj != null);
    //}

    //static testMethod void testParseStatusSuccess() {
    //    String json = '{"Meta":{"Status":"Success","Debug":""},"Result":{"Success":true,"EmailDistributionID":"EMD_6D9asX295ujlKp7","DistributionQueueID":"EMD_6D9asX295ujlKp7"}}';
    //    JSON2Apex obj = parse(json);
    //    System.assert(obj != null);
    //}