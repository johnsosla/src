@isTest
global class ECO_SmartSearchMockHttpResponseGenerator implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('https://smartsearchrest.aecom.com:8443/rest/search/token', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"token" : "token"}');
        res.setStatusCode(200);
        return res;
    }
}