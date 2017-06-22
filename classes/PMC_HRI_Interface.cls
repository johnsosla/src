public class PMC_HRI_Interface {

	public static final String STATUS_CERTIFIED = 'Certified';
	public static final String STATUS_PROVISIONAL = 'Provisional';
	public static final String STATUS_NONE = 'None';

	public static Boolean wasCalled = false;

	public static Boolean allowTriggerCallouts = true;

	@Future(callout=true)
	public static void sendNewCertifications(List<String> trackingIds) {
		sendRequest(STATUS_CERTIFIED, trackingIds);
	}

	@Future(callout=true)
	public static void sendProvisionalCertifications(List<String> trackingIds) {
		sendRequest(STATUS_PROVISIONAL, trackingIds);
	}

	// Not being used
	//@Future(callout=true)
	//public static void removeCertificationsFuture(List<String> trackingIds) {
	//	sendRequest(STATUS_NONE, trackingIds);
	//}

	public static void removeCertifications(List<String> trackingIds) {
		sendRequest(STATUS_NONE, trackingIds, true);
	}

	private static Boolean sendRequest(String certificationStatus, List<String> trackingIds) {
		return sendRequest(certificationStatus, trackingIds, false);
	}

	private static Boolean sendRequest(String certificationStatus, List<String> trackingIds, Boolean bufferLogs) {
		try {
			List<CertificationUpdateRequest> requests = new List<CertificationUpdateRequest>();

			for (String trackingId : trackingIds) {
				CertificationUpdateRequest req = new CertificationUpdateRequest();
				req.trackingId = trackingId;
				req.certificationStatus = certificationStatus;
				requests.add(req);
			}

			PMC_Settings__c ps = PMC_Settings__c.getOrgDefaults();

			HttpRequest request = new HttpRequest();
			request.setEndpoint(ps.Certification_API_URL__c);
			request.setMethod('PUT');
			request.setHeader('Ocp-Apim-Subscription-Key', ps.API_Key__c);
			request.setHeader('Content-Type', 'application/json');
			request.setBody(JSON.serialize(requests));
			request.setTimeout(120000);

			Http http = new Http();
			HttpResponse response = null;
			// Known issue with Salesforce which Salesforce will not fix: https://success.salesforce.com/issues_view?id=a1p30000000RXTzAAO
			// If we do a callout from a trigger, EVEN if it is wrapped in an @future, it will still throw an "uncommitted work pending" exception
			try {
				if (!Test.isRunningTest()) response = http.send(request);
				else wasCalled = true;
			}
			catch (Exception e) {
				PMC_LogUtil.insertError('PMC_HRI_Interface', 'Exception while calling LMS: ' + e.getMessage() + '\n' + e.getStackTraceString());
			}
			

			String debugMsg = 'New Status: ' + certificationStatus + ' Tracking IDs: ' + JSON.serialize(trackingIds);
			PMC_LogUtil.insertDebug('PMC_HRI_Interface', debugMsg, bufferLogs);

			if (response != null && response.getStatusCode() != 204) {
				PMC_LogUtil.insertError('PMC_HRI_Interface', 'Error from HRI system received: ' + response.getBody() + ' -- Status Code: ' + response.getStatusCode());
				return false;
			}
			else if (response == null) {
				PMC_LogUtil.insertError('PMC_HRI_Interface', 'No response received from LMS');
				return false;
			}
		}
		catch (Exception e) {
			PMC_LogUtil.insertError('PMC_HRI_Interface', 'General exception while calling HRI: ' + e.getMessage() + '\n' + e.getStackTraceString());
			return false;
		}


		return true;
	}

	public class CertificationUpdateRequest {
		public String trackingId { get; set; }
		public String certificationStatus { get; set; }
	}
}