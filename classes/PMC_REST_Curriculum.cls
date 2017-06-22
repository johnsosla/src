@RestResource(urlMapping='/Curriculum/*')
global class PMC_REST_Curriculum {

	public static final String LOG_SOURCE = 'PMC_REST_Curriculum';

	@HttpPost
	global static void updateCompletionStatus() {
		System.debug('PMC_REST_Curriculum.updateCompletionStatus()');

		RestRequest req = RestContext.request;
		RestResponse res = RestContext.response;

        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

        PMC_LogUtil.insertDebug(LOG_SOURCE, 'Call into PMC_REST_Curriculum', false);
        try {
	        if (req.requestBody == null) {
	        	res.statusCode = 400;
	        	res.responseBody = Blob.valueOf('Blank request body found');
	        	PMC_LogUtil.insertError(LOG_SOURCE, 'Blank request body found');
	        }
	        else {
	    		List<UpdateCompletionRequest> completionRequests = null;

	    		try {
	    			String bodyStr = req.requestBody.toString();
	    			PMC_LogUtil.insertDebug(LOG_SOURCE,'Body string: ' + bodyStr, false);
	    			completionRequests = (List<UpdateCompletionRequest>)JSON.deserialize(bodyStr, List<UpdateCompletionRequest>.class);
	    		}
	    		catch (Exception e) {
	    			System.debug('Error while deserializing request body: ' + e);
	    			res.statusCode = 400;
	    			res.responseBody = Blob.valueOf('Invalid JSON in request. Error while parsing was: ' + e);
	    			PMC_LogUtil.insertError(LOG_SOURCE, 'Invalid JSON in request. Error while parsing was: ' + e + ' ---- Body was: ' + req.requestBody.toString());
	    			return;
	    		}

	    		if (completionRequests.isEmpty()) {
	    			System.debug('completionRequests.isEmpty()');
	    		}


	    		Map<String, UpdateCompletionRequest> completionRequestMap = new Map<String, UpdateCompletionRequest>();

	    		for (UpdateCompletionRequest row : completionRequests) {
	    			if (String.isBlank(row.trackingId)) {
						res.statusCode = 400;
						res.responseBody = Blob.valueOf('No tracking ID specified');
						PMC_LogUtil.insertError(LOG_SOURCE, 'No tracking ID specified');
						return;
					}
					else if (String.isBlank(row.jobId)) {
						res.statusCode = 400;
						res.responseBody = Blob.valueOf('No job ID specified');
						PMC_LogUtil.insertError(LOG_SOURCE, 'No job ID specified');
						return;
					}
					else if (row.completedDate == null) {
						res.statusCode = 400;
						res.responseBody = Blob.valueOf('No completed date specified, or invalid date format.');
						PMC_LogUtil.insertError(LOG_SOURCE, 'No completed date specified');
						return;
					}

					String key = row.getKey() + '|' + PMC_CertificationRequest.STATUS_AWAITING_COMPLETION;
					completionRequestMap.put(key, row);
	    		}
	        	

				Map<String, PMC_CertificationRequest> certRequests = PMC_CertificationRequest.find.findByCompositeKeys(completionRequestMap.keySet());
				List<String> warnings = new List<String>();

				for (String key : completionRequestMap.keySet()) {
					UpdateCompletionRequest completionRequest = completionRequestMap.get(key);

					if (!certRequests.containsKey(key)) {
						warnings.add('Not found with status Awaiting Completion: TrackingID:' + completionRequest.trackingId + '|JobID:' + completionRequest.jobId);
					}
					else {
						PMC_CertificationRequest certRequest = certRequests.get(key);
						certRequest.obj.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_TRAINING_COMPLETED;
						certRequest.obj.Training_Completion_Date__c = completionRequest.completedDate;
					}
				}


				PMC_BaseModel.save(certRequests.values());

				if (warnings.size() > 0) {
					// If warnings found, return 200 to indicate partial success with the warnings in the body
					String respStr = 'Certification requests updated. Warnings: ' + JSON.serialize(warnings);
					PMC_LogUtil.insertWarning(LOG_SOURCE, respStr, false);
					res.statusCode = 200;
					res.responseBody = Blob.valueOf(respStr);
				}
				else {
					// If no warnings, return 204 to indicate full success 
					PMC_LogUtil.insertDebug(LOG_SOURCE, 'Call into PMC_REST_Curriculum completed', false);
					res.statusCode = 204;
				}
	        }		
        }
        catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Internal exception caught while processing request: ' + e.getMessage());
            PMC_LogUtil.insertError(LOG_SOURCE, 'Error while processing updateCompletionStatus: ' + e.getMessage() + '\n' + e.getStackTraceString());

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


	global class UpdateCompletionRequest {
		public String trackingId { get; set; }
		public String jobId { get; set; }
		public Date completedDate { get; set; }

		public String getKey() {
			return trackingid + '|' + jobId;
		}
	}

}