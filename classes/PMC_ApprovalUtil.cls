public class PMC_ApprovalUtil {
	public static Boolean submitForApproval(Id submittingUserId, Id objectId) {
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setObjectId(objectId);
		req.setSubmitterId(submittingUserId);
		Approval.ProcessResult result = Approval.process(req);
		return result.isSuccess();
	}

	public static Boolean submitForApproval(List<PMCertReq__c> certRequests) {
		List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();

		for (PMCertReq__c certRequest : certRequests) {
			Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
			approvalRequest.setObjectId(certRequest.Id);
			approvalRequest.setSubmitterId(certRequest.Candidate__c);
			approvalRequests.add(approvalRequest);
		}

		Approval.ProcessResult[] results = Approval.process(approvalRequests, false);

		Boolean success = true;

		for (Approval.ProcessResult result : results) {
			if (!result.isSuccess()) {
				System.debug(LoggingLevel.ERROR, 'Error while processing ' + result.getEntityId() + ': ' + JSON.serialize(result.getErrors()));
				success = false;
			}
		}

		return success;
	}
}