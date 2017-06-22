public class PMC_LMS_Interface {

	public static Boolean wasCalled = false;

	// These methods must be @future because they are called from triggers
	@Future(callout=true)
	public static void sendEnrollmentRequestsForCertifications(List<Id> newEnrollmentIds) {
		List<PMC_CertificationRequest> certRequests = PMC_CertificationRequest.find.findByIds(newEnrollmentIds);

		List<TrainingEnrollmentRequest> requests = new List<TrainingEnrollmentRequest>();

		for (PMC_CertificationRequest certReq : certRequests) {
			requests.add(certReq.getEnrollmentRequest());
		}

		sendRequest('POST', requests, certRequests, PMC_CertificationRequest.STATUS_AWAITING_COMPLETION, false);
	}
	
	
	public static Boolean sendEnrollmentRequests(List<TrainingEnrollmentRequest> requests) {
		return sendRequest('POST', requests, false);
	}

	public static Boolean removeEnrollmentRequests(List<TrainingEnrollmentRequest> requests) {
		return sendRequest('DELETE', requests, true);
	}

	private static Boolean sendRequest(String method, List<TrainingEnrollmentRequest> requests, Boolean bufferLogs) {
		return sendRequest(method, requests, null, null, bufferLogs);
	}

	private static Boolean sendRequest(String method, List<TrainingEnrollmentRequest> requests, List<PMC_CertificationRequest> certRequests, String newStatus, Boolean bufferLogs) {
		try {
			PMC_Settings__c ps = PMC_Settings__c.getOrgDefaults();

			HttpRequest request = new HttpRequest();
			request.setEndpoint(ps.Training_API_URL__c);
			request.setMethod(method);
			request.setHeader('Ocp-Apim-Subscription-Key', ps.API_Key__c);
			request.setHeader('Content-Type', 'application/json');
			request.setBody(JSON.serialize(requests));
			request.setTimeout(120000);

			Http http = new Http();

			HttpResponse response = null;
			
			// Known issue with Salesforce which Salesforce will not fix: https://success.salesforce.com/issues_view?id=a1p30000000RXTzAAO
			// If we do a callout from a trigger, EVEN if it is wrapped in an @future, it will still throw an "uncommitted work pending" exception
			try {
				if (!Test.isRunningTest()) {
					response = http.send(request);
				}
				else {
					// When running this code as part of a unit test, mock a fake response
					wasCalled = true;
					response = new HttpResponse();
					response.setStatusCode(204);
				}
			}
			catch (Exception e) {
				PMC_LogUtil.insertError('PMC_LMS_Interface', 'Exception while calling LMS: ' + e.getMessage() + '\n' + e.getStackTraceString());
			}

			String debugMsg = 'Method: ' + method + ' Body: ' + JSON.serialize(requests);
			PMC_LogUtil.insertDebug('PMC_LMS_Interface', debugMsg, bufferLogs);
			
			if (response != null && response.getStatusCode() != 204) {
				PMC_LogUtil.insertError('PMC_LMS_Interface', 'Error from LMS system received: ' + response.getBody() + ' -- Status Code: ' + response.getStatusCode());
				return false;
			}
			else if (response == null) {
				PMC_LogUtil.insertError('PMC_LMS_Interface', 'No response received from LMS');
				return false;
			}

			if (certRequests != null && !String.isBlank(newStatus)) {
				for (PMC_CertificationRequest row : certRequests) {
					row.obj.CertificationRequestStatus__c = newStatus;
				}

				PMC_BaseModel.save(certRequests);
			}
		}
		catch (Exception e) {
			PMC_LogUtil.insertError('PMC_LMS_Interface', 'General exception while calling LMS: ' + e.getMessage() + '\n' + e.getStackTraceString());
			return false;
		}

		return true;
	}

	public class TrainingEnrollmentRequest {
		public String trackingId;
		public String jobCodeId;
	}
}