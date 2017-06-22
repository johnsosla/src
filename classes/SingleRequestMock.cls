@isTest
global class SingleRequestMock implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"careerBand":"s2","birthDate":"1951-12-01"}');
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }

   
}