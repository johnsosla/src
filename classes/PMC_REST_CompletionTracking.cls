@RestResource(urlMapping='/TrainingResult/*')
global class PMC_REST_CompletionTracking {

    public static final String LOG_SOURCE = 'PMC_REST_CompletionTracking';

	@HttpPost
	global static void updateTrainingResult() {

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

		PMC_LogUtil.insertDebug(LOG_SOURCE, 'Call into PMC_REST_CompletionTracking', false);

        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

        try {
            if (req.requestBody == null) {
            	res.statusCode = 400;
            	res.responseBody = Blob.valueOf('Blank request body found');
            	PMC_LogUtil.insertError(LOG_SOURCE, 'Blank request body found');
            }
            else {
            	List<TrainingResult> trainingResults = null;

            	try {
        			String bodyStr = req.requestBody.toString();
        			PMC_LogUtil.insertDebug(LOG_SOURCE, 'Body string: ' + bodyStr, false);
        			trainingResults = (List<TrainingResult>)JSON.deserialize(bodyStr, List<TrainingResult>.class);
        		}
        		catch (Exception e) {
        			System.debug('Error while deserializing request body: ' + e);
        			res.statusCode = 400;
        			res.responseBody = Blob.valueOf('Invalid JSON in request. Error while parsing was: ' + e);
        			PMC_LogUtil.insertError(LOG_SOURCE, 'Invalid JSON in request. Error while parsing was: ' + e + ' ---- Body was: ' + req.requestBody.toString());
        			return;
        		}


                Set<String> trackingIds = new Set<String>();

                for (TrainingResult row : trainingResults) {
                    if (String.isBlank(row.trackingId) || String.isBlank(row.curriculumId)) {
                        res.statusCode = 400;
                        String message = 'Blank value found in one of the following fields: trackingId,curriculumId. JSON: ' + JSON.serialize(row);
                        res.responseBody = Blob.valueOf(message);
                        PMC_LogUtil.insertError(LOG_SOURCE, message);
                        return;
                    }

                    trackingIds.add(row.trackingId);
                }

                Set<Id> certificationRequestIds = new Set<Id>();
                List<PMC_CertificationRequest> requests = PMC_CertificationRequest.find.findByTrackingIds(trackingIds);

                Map<String, PMC_CertificationRequest> trackingIdToCertRequest = new Map<String, PMC_CertificationRequest>();
                for (PMC_CertificationRequest row : requests) {
                    if (!row.isExpired()) {
                        trackingIdToCertRequest.put(row.obj.CandidateTrackingID__c, row);    
                    }

                    certificationRequestIds.add(row.obj.Id);
                }

                Map<String, List<PMC_CertificationTrainingResult>> trainingResultMap = PMC_CertificationTrainingResult.find.findMapByCertRequests(certificationRequestIds);


                List<String> warningMessages = new List<String>();

                List<PMC_CertificationTrainingResult> newRecords = new List<PMC_CertificationTrainingResult>();
                Map<Id, PMC_CertificationTrainingResult> existingRecords = new Map<Id, PMC_CertificationTrainingResult>();

                for (TrainingResult row : trainingResults) {
                    if (!trackingIdToCertRequest.containsKey(row.trackingId)) {
                        warningMessages.add('No cert request found for tracking ID: ' + row.trackingId + '. It may be expired.');
                        continue;
                    }

                    PMC_CertificationRequest request = trackingIdToCertRequest.get(row.trackingId);

                    List<PMC_CertificationTrainingResult> existingResults = new List<PMC_CertificationTrainingResult>();
                    if (trainingResultMap.containsKey(request.obj.Id)) existingResults = trainingResultMap.get(request.obj.Id);

                    Boolean foundExisting = false;

                    for (PMC_CertificationTrainingResult existingResult : existingResults) {
                        if (existingResult.matches(row)) {
                            foundExisting = true;

                            PMC_CertificationTrainingResult resultFromSameFile = existingRecords.get(existingResult.getId());

                            // This is an update to the record in the database, OR there is a line in the same request and it is an update to that line
                            if (existingResult.completionDateIsUpdateOrLater(row) && (resultFromSameFile == null || resultFromSameFile.completionDateIsUpdateOrLater(row))) {
                                existingResult.updateFromApiResult(row);
                                existingRecords.put(existingResult.getId(), existingResult);
                            }
                            else {
                                PMC_LogUtil.insertDebug(LOG_SOURCE, 'Update skipped because it is outdated: ' + JSON.serialize(row), true);
                            }
                        }
                    }

                    if (!foundExisting) {
                        PMC_CertificationTrainingResult newResult = new PMC_CertificationTrainingResult();
                        newResult.obj.PM_Candidate_Application__c = request.obj.Id;
                        newResult.updateFromApiResult(row);
                        newRecords.add(newResult);
                    }
                }

                PMC_BaseModel.save(newRecords);
                PMC_BaseModel.save(existingRecords.values());

                if (warningMessages.size() > 0) {
                    String respStr = 'TrainingResults updated';
                    respStr += '. Warnings: ' + JSON.serialize(warningMessages);
                    PMC_LogUtil.insertWarning(LOG_SOURCE, respStr, false);
                    res.statusCode = 200;
                    res.responseBody = Blob.valueOf(respStr);
                }
                else {
                    PMC_LogUtil.insertDebug(LOG_SOURCE, 'Call into PMC_REST_CompletionTracking completed', false);
                    res.statusCode = 204;
                }
            }

            PMC_LogUtil.flush();
        }
        catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Internal exception caught while processing request: ' + e.getMessage());
            PMC_LogUtil.insertError(LOG_SOURCE, 'Error while processing completion tracking: ' + e.getMessage() + '\n' + e.getStackTraceString());

            try {
                if (req != null && req.requestBody != null) {
                    String bodyStr = req.requestBody.toString();
                    PMC_LogUtil.insertDebug(LOG_SOURCE, 'Error caught, body string was: ' + bodyStr, false);
                }
                
            }
            catch (Exception e2) {

            }

        }
	}



	global class TrainingResult {
		public String trackingId;
		public String curriculumId;
		public String itemType;
		public String itemId;
		public String itemTitle;
		public Date completionDate;
		public String grade;
	}
}