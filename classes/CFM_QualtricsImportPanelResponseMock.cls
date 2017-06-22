@isTest
public with sharing class CFM_QualtricsImportPanelResponseMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {

        System.assertEquals('POST', req.getMethod(), 'ImportPanel requires a POST of CSV data');
        System.assert(req.getBody() != null,         'POST method should have a body');
        System.assert(req.getBody().contains('\n'),  'There should be at least two lines in the request body');
        Map<String, String> params = CFM_QualtricsBaseResponseMock.getParams(req);

        //---According to documentation, these are required
        //---https://survey.qualtrics.com/WRAPI/ControlPanel/docs.php#importPanel_2.5
        System.assert(params.containsKey('User'),      'Missing required paramater: User');
        System.assert(params.containsKey('Token'),     'Missing required paramater: Token');
        System.assert(params.containsKey('Version'),   'Missing required paramater: Version');
        System.assert(params.containsKey('LibraryID'), 'Missing required paramater: LibraryID');
        System.assert(params.containsKey('Email'),     'Missing required paramater: Email');

        
        System.assertEquals('1', params.get('ColumnHeaders'), 'The generated data has headers, and the callout should indicate such');
        System.assertEquals('1', params.get('AllED'),         'The generated data has headers, and the callout should use all columns');

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Meta":{"Status":"Success","Debug":""},"Result":{"PanelID":"CG_cBiy32Uj0l7sIlv","Count":3,"IgnoredCount":-1,"Recipients":{"CreatedContacts":0,"UpdatedContacts":2,"FailedContacts":[]}}}');
        res.setStatusCode(200);
        return res;
    }

}