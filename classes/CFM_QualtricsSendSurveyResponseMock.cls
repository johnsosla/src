@isTest
public with sharing class CFM_QualtricsSendSurveyResponseMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {

        System.assertEquals('GET', req.getMethod(), 'SendSurveyToPanel requires a GET request');
        Map<String, String> params = CFM_QualtricsBaseResponseMock.getParams(req);

        //---According to documentation, these are required
        //---https://survey.qualtrics.com/WRAPI/ControlPanel/docs.php#sendSurveyToPanel_2.5
        System.assert(params.containsKey('User'),             'Missing required paramater: User');
        System.assert(params.containsKey('Token'),            'Missing required paramater: Token');
        System.assert(params.containsKey('Format'),           'Missing required paramater: Format');
        System.assert(params.containsKey('Version'),          'Missing required paramater: Version');
        System.assert(params.containsKey('SurveyID'),         'Missing required paramater: SurveyID');
        System.assert(params.containsKey('SendDate'),         'Missing required paramater: SendDate');
        System.assert(params.containsKey('FromEmail'),        'Missing required paramater: FromEmail');
        System.assert(params.containsKey('FromName'),         'Missing required paramater: FromName');
        System.assert(params.containsKey('Subject'),          'Missing required paramater: Subject');
        System.assert(params.containsKey('MessageID'),        'Missing required paramater: MessageID');
        System.assert(params.containsKey('MessageLibraryID'), 'Missing required paramater: MessageLibraryID');
        System.assert(params.containsKey('PanelID'),          'Missing required paramater: PanelID');
        System.assert(params.containsKey('PanelLibraryID'),   'Missing required paramater: PanelLibraryID');

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Meta":{"Status":"Success","Debug":""},"Result":{"Success":true,"EmailDistributionID":"EMD_6VBwiQYnP7XQmiN","DistributionQueueID":"EMD_6VBwiQYnP7XQmiN"}}');
        res.setStatusCode(200);
        return res;
    }
}