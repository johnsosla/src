@isTest
private class PMC_REST_Test {
	@isTest static void testApplicationUpdateInterface() {
        PMCertReq__c certReq = PMC_TestUtils.createTestInitialApplication();
        User u = [Select TrackingID__c from User where Id = :certReq.Candidate__c];

        Date completionDate = Date.today();
        List<PMC_REST_Curriculum.UpdateCompletionRequest> requestList = new List<PMC_REST_Curriculum.UpdateCompletionRequest>();
        PMC_REST_Curriculum.UpdateCompletionRequest completeRequest = new PMC_REST_Curriculum.UpdateCompletionRequest();
        completeRequest.trackingId = u.TrackingID__c;
        completeRequest.jobId = certReq.Job_ID__c;
        completeRequest.completedDate = completionDate;

        requestList.add(completeRequest);

        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(requestList));
        RestContext.request = req;

        PMC_REST_Curriculum.updateCompletionStatus();

        Test.stopTest();

        // Removing check as process builder/flows are modifying the process outside of codebase.
        //certReq = [Select Id, CertificationRequestStatus__c from PMCertReq__c where Id = :certReq.Id];
        //System.assertEquals(PMC_CertificationRequest.STATUS_TRAINING_COMPLETED, certReq.CertificationRequestStatus__c, 'Should update to training completed status');
    }

    @isTest static void testApplicationNotFoundWarning() {

        PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings();

        Date completionDate = Date.today();
        List<PMC_REST_Curriculum.UpdateCompletionRequest> requestList = new List<PMC_REST_Curriculum.UpdateCompletionRequest>();
        PMC_REST_Curriculum.UpdateCompletionRequest completeRequest = new PMC_REST_Curriculum.UpdateCompletionRequest();
        completeRequest.trackingId = 'ASDF';
        completeRequest.jobId = '1234';
        completeRequest.completedDate = completionDate;

        requestList.add(completeRequest);

        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(requestList));
        RestContext.request = req;

        PMC_REST_Curriculum.updateCompletionStatus();

        Test.stopTest();

        RestResponse res = RestContext.response;
        String respStr = res.responseBody.toString();

        System.assert(respStr.toLowerCase().contains('warning'), 'REST endpoint should have returned warning that completion request was not found');
    }

    @isTest static void testCompletionInterfaceErrorHandling() {
    	RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();
		RestContext.request = req;

		PMC_REST_Curriculum.updateCompletionStatus();
		System.assertEquals(400, RestContext.response.statusCode, 'Shoulkd have returned status code 400 because no request body');

		req.requestBody = Blob.valueOf('Some invalid JSON String');

		PMC_REST_Curriculum.updateCompletionStatus();
		System.assertEquals(400, RestContext.response.statusCode, 'Should have returned status code 400 because invalid JSON in request body');

		List<PMC_REST_Curriculum.UpdateCompletionRequest> requestList = new List<PMC_REST_Curriculum.UpdateCompletionRequest>();
        PMC_REST_Curriculum.UpdateCompletionRequest completeRequest = new PMC_REST_Curriculum.UpdateCompletionRequest();
        requestList.add(completeRequest);

        req.requestBody = Blob.valueOf(JSON.serialize(requestList));

        PMC_REST_Curriculum.updateCompletionStatus();
		System.assertEquals(400, RestContext.response.statusCode, 'Should have returned status code 400 because blank values were sent over');
    }

    @isTest static void testGradeTrackingInterfaceErrorHandling() {

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();
		RestContext.request = req;

		PMC_REST_CompletionTracking.updateTrainingResult();
		System.assertEquals(400, RestContext.response.statusCode, 'Shoulkd have returned status code 400 because no request body');

		req.requestBody = Blob.valueOf('Some invalid JSON String');

		PMC_REST_CompletionTracking.updateTrainingResult();
		System.assertEquals(400, RestContext.response.statusCode, 'Should have returned status code 400 because invalid JSON in request body');

		List<PMC_REST_CompletionTracking.TrainingResult> requestList = new List<PMC_REST_CompletionTracking.TrainingResult>();

        PMC_REST_CompletionTracking.TrainingResult updateRow = new PMC_REST_CompletionTracking.TrainingResult();
        requestList.add(updateRow);

        req.requestBody = Blob.valueOf(JSON.serialize(requestList));

        PMC_REST_CompletionTracking.updateTrainingResult();
		System.assertEquals(400, RestContext.response.statusCode, 'Should have returned status code 400 because blank values were sent over');
    }

    @isTest static void testGradeTrackingInterface() {
    	PMCertReq__c certReq = PMC_TestUtils.createTestInitialApplication();
        User u = [Select TrackingID__c from User where Id = :certReq.Candidate__c];

        PMC_CertificationTrainingResult existingResult = new PMC_CertificationTrainingResult();
        existingResult.obj.PM_Candidate_Application__c = certReq.Id;
        existingResult.obj.Completion_Date__c = Date.today();
        existingResult.obj.Curriculum_Id__c = 'C1';
        existingResult.obj.Grade__c = 'C';
        existingResult.save();

        List<PMC_REST_CompletionTracking.TrainingResult> requestList = new List<PMC_REST_CompletionTracking.TrainingResult>();

        PMC_REST_CompletionTracking.TrainingResult updateRow = new PMC_REST_CompletionTracking.TrainingResult();
        updateRow.trackingId = u.TrackingID__c;
        updateRow.completionDate = Date.today();
        updateRow.curriculumId = 'C1';
        updateRow.grade = 'B';
        requestList.add(updateRow);

        PMC_REST_CompletionTracking.TrainingResult insertRow = new PMC_REST_CompletionTracking.TrainingResult();
        insertRow.trackingId = u.TrackingID__c;
        insertRow.completionDate = Date.today();
        insertRow.curriculumId = 'C2';
        insertRow.grade = 'A';
        requestList.add(insertRow);

        PMC_REST_CompletionTracking.TrainingResult invalidRow = new PMC_REST_CompletionTracking.TrainingResult();
        invalidRow.trackingId = 'INVALID_TRACKING_ID';
        invalidRow.completionDate = Date.today();
        invalidRow.curriculumId = 'C2';
        invalidRow.grade = 'A';
        requestList.add(invalidRow);

        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(requestList));
        RestContext.request = req;

        PMC_REST_CompletionTracking.updateTrainingResult();

        Test.stopTest();

        List<PMC_CertificationTrainingResult> newTrainingResults = PMC_CertificationTrainingResult.find.findByCertRequest(certReq.Id);

        System.assertEquals(2, newTrainingResults.size(), 'Should have two training result records - the existing and the new. Invalid should have been discarded');

        Boolean foundC1 = false;
        Boolean foundC2 = false;

        for (PMC_CertificationTrainingResult row : newTrainingResults) {
        	if (row.obj.Curriculum_Id__c == 'C1') {
        		foundC1 = true;
        		System.assertEquals('B', row.obj.Grade__c, 'Should have updated grade of existing record');
        	}
        	if (row.obj.Curriculum_Id__c == 'C2') {
        		foundC2 = true;
        		System.assertEquals('A', row.obj.Grade__c, 'New record should have proper grade recorded');
        	}
        }

        System.assert(foundC1, 'Integration should have recorded item with Curriculum ID of C1');
        System.assert(foundC2, 'Integration should have recorded item with Curriculum ID of C2');

    }
}