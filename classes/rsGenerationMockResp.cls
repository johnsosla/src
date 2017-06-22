@isTest
global class rsGenerationMockResp implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        // Set response values, and
        // return response.

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"resumeId":63,"key":"62537c10-1a66-481d-8ddf-2bf0447df4ba","logId":65}');
        res.setStatusCode(200);
        return res;
    }
}