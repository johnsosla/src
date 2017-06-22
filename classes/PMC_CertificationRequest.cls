public without sharing class PMC_CertificationRequest extends PMC_BaseModel {

	public static final String STATUS_NEW = 'New';
	public static final String STATUS_SPONSOR_END_REQUESTED = 'Sponsor Endorsement Requested';
	public static final String STATUS_TRAINING_APP_REQUESTED = 'Training Approval Requested';
	public static final String STATUS_AWAITING_COMPLETION = 'Awaiting Completion';
	public static final String STATUS_TRAINING_COMPLETED = 'Training Completed';
	public static final String STATUS_TRAINING_EXPIRED = 'Training Request Expired';
	public static final String STATUS_REGISTERED = 'Registered in LMS';
	public static final String STATUS_TRAINING_REQUEST_APPROVED = 'Training Request Approved';
	public static final String STATUS_SCHEDULE_INTERVIEW = 'Schedule Interview';
	public static final String STATUS_INTERVIEW_COMPLETED = 'Interview Completed';
	public static final String STATUS_AWAITING_APPROVAL = 'Awaiting Certification Approval';
	public static final String STATUS_CERTIFICATION_APPROVED = 'Certification Approved';

	public static final String PROV_STATUS_YES = 'Approved';
	public static final String PROV_STATUS_NO = 'Not Approved';

	public static final String TYPE_INITIAL = 'Initial';
	public static final String TYPE_PROVISIONAL = 'Provisional';
	public static final String TYPE_RENEWAL = 'Renewal';

	public static final String GEN_STATUS_PENDING = 'Pending';
	public static final String GEN_STATUS_GENERATING = 'Generating';
	public static final String GEN_STATUS_COMPLETE = 'Generation Complete';
	public static final String GEN_STATUS_SENT = 'Sent';

	public static final String RT_CERT_RENEWAL = 'Certification Renewal';

	public static final List<String> PENDING_TRAINING_STATUS = new List<String>
	{
		'Registered in LMS',
		'Awaiting Completion'
	};

	public PMCertReq__c obj { get { return (PMCertReq__c)mObj; } }

	public static Finder find = new Finder();

	public PMC_CertificationRequest(PMCertReq__c sObj) {
		super(sObj);
	}

	public Date getCertificationDate() {
		return obj.Certification_Award_Approval_Date__c;
	}

	public Date getExpirationDate() {
		PMC_Settings__c ps = PMC_Settings__c.getOrgDefaults();

		if (ps.Renewal_Period_Cutoff_Date__c == null || ps.Renewal_Period_Expiration_Date__c == null || obj.Certification_Award_Approval_Date__c == null) {
			return null;
		}

		

		if (obj.Certification_Award_Approval_Date__c >= ps.Renewal_Period_Cutoff_Date__c) {
			return ps.Renewal_Period_Expiration_Date__c.addYears(2);
		}

		return ps.Renewal_Period_Expiration_Date__c;
	}

	public Boolean isExpired() {
		return obj.CertificationRequestStatus__c == PMC_CertificationRequest.STATUS_TRAINING_EXPIRED;
	}

	public static List<PMC_CertificationRequest> decorate(List<PMCertReq__c> sList) {
		List<PMC_CertificationRequest> result = new List<PMC_CertificationRequest>();
		for (PMCertReq__c row : sList) result.add(new PMC_CertificationRequest(row));
		return result;
	}

	public static List<PMCertReq__c> undecorate(List<PMC_CertificationRequest> wList) {
		List<PMCertReq__c> result = new List<PMCertReq__c>();
		for (PMC_CertificationRequest row : wList) result.add(row.obj);
		return result;
	}

	public PMC_LMS_Interface.TrainingEnrollmentRequest getEnrollmentRequest() {
		PMC_LMS_Interface.TrainingEnrollmentRequest request = new PMC_LMS_Interface.TrainingEnrollmentRequest();
		request.jobCodeId = obj.Job_ID__c;
		request.trackingId = obj.CandidateTrackingID__c;
		return request;
	}

	public static void updateCertificationStatusForUsers(List<PMCertReq__c> certificationApproved) {
		Map<Id, PMCertReq__c> userIdToCertification = new Map<Id, PMCertReq__c>();
		for (PMCertReq__c row : certificationApproved) userIdToCertification.put(row.Candidate__c, row);

		List<User> users = [Select Id from User where Id in :userIdToCertification.keySet()];

		for (User row : users) {
			PMCertReq__c certReq = userIdToCertification.get(row.Id);
			if (certReq.Certification_Type__c == TYPE_INITIAL ||
				certReq.Certification_Type__c == TYPE_RENEWAL) {
				row.Certified_PM__c = 'Yes';
			}
			else if (certReq.Certification_Type__c == TYPE_PROVISIONAL || certReq.Provisional_PM_Request__c) {
				row.Certified_PM__c = 'Provisional';
			}
		}

		update users;
	}

	public static void updateProvisionalStatusForUsers(List<String> userIds) {
		List<User> users = [Select Id from User where Id in :userIds];

		for (User row : users) {

			row.Certified_PM__c = 'Provisional';
			
		}

		update users;
	}


	@Future
	public static void convertToRenewalRequestFuture(List<Id> certRequestIds) {
		List<PMC_CertificationRequest> certRequests = PMC_CertificationRequest.find.findByIds(certRequestIds);
		convertToRenewalRequest(undecorate(certRequests));
	}

	public static void convertToRenewalRequest(List<PMCertReq__c> certRequests) {
		List<Id> userIds = new List<Id>();
		for (PMCertReq__c row : certRequests) userIds.add(row.Candidate__c);

		Map<Id, User> users = new Map<Id, User>([Select Id, TrackingID__c, Supergeography__c, Geography__c, Country from User where Id in :userIds]);
		List<Id> certRequestIds = new List<Id>();

		List<PMC_LMS_Interface.TrainingEnrollmentRequest> enrollments = new List<PMC_LMS_Interface.TrainingEnrollmentRequest>();

		for (PMCertReq__c row : certRequests) {
			User u = users.get(row.Candidate__c);
			convertToRenewalRequest(u, row);
			certRequestIds.add(row.Id);

			PMC_LMS_Interface.TrainingEnrollmentRequest enrollment = new PMC_LMS_Interface.TrainingEnrollmentRequest();
			enrollment.jobCodeId = row.Job_ID__c;
			enrollment.trackingId = u.TrackingID__c;
			enrollments.add(enrollment);
		}

		Boolean success = PMC_LMS_Interface.sendEnrollmentRequests(enrollments);	

		if (success) {
			update certRequests;	
		}
		else {
			System.debug('Did not update cert requests because was not able to send to LMS interface');
		}

		
	}

	public static void convertToRenewalRequest(User u, PMCertReq__c certReq) {
		PMC_Settings__c ps = PMC_Settings__c.getOrgDefaults();
		Map<String, Schema.RecordTypeInfo> rt_map = Schema.getGlobalDescribe().get('PMCertReq__c').getDescribe().getRecordTypeInfosByName();
		String renewalRtId = rt_map.get('Certification Renewal').getRecordTypeId();

		String jobId = null;

		PMC_Curriculum_Assignment__c regionalAssignment = PMC_CurriculumAssignment.getAssignmentForCandidate(u);

		if (regionalAssignment != null && !String.isBlank(regionalAssignment.Renewal_Job_ID__c)) {
			jobId = regionalAssignment.Renewal_Job_ID__c;
		}
		else {
			jobId = ps.Renewal_Job_ID__c;
		}

		certReq.RecordTypeId = renewalRtId;
		certReq.Certification_Type__c = PMC_CertificationRequest.TYPE_RENEWAL;
		certReq.CertificationRequestStatus__c  = PMC_CertificationRequest.STATUS_AWAITING_COMPLETION;
		certReq.TrainingApprovalDate__c = Date.today();
		certReq.Job_ID__c = jobId;
	}

	public class Finder extends PMC_BaseFinder {
		public Finder() {
			super('PMCertReq__c');
		}

		public List<PMC_CertificationRequest> findByIds(List<Id> certRequestIds) {
			List<PMCertReq__c> results = Database.query(getSelect() + ' WHERE Id in :certRequestIds');
			return PMC_CertificationRequest.decorate(results);
		}

		// The "composite key" of the PM certification request is in this format: Tracking_ID|Job_ID|Status
		public Map<String, PMC_CertificationRequest> findByCompositeKeys(Set<String> compositeKeys) {
			List<PMCertReq__c> results = Database.query(getSelect() + ' WHERE Composite_Key__c in :compositeKeys');

			Map<String, PMC_CertificationRequest> resultMap = new Map<String, PMC_CertificationRequest>();

			for (PMCertReq__c row : results) {
				resultMap.put(row.Composite_Key__c, new PMC_CertificationRequest(row));
			}

			return resultMap;
		}

		public List<PMC_CertificationRequest> findByTrackingIds(Set<String> trackingIds) {
			List<PMCertReq__c> results = Database.query(getSelect() + ' WHERE CandidateTrackingID__c in :trackingIds');
			return PMC_CertificationRequest.decorate(results);
		}

		public PMC_CertificationRequest findByTrackingJobId(String trackingId, String jobId, String status) {
			List<PMCertReq__c> results = Database.query(getSelect() + ' WHERE CandidateTrackingID__c = :trackingId AND Job_ID__c = :jobId AND CertificationRequestStatus__c = :status');
			return results.size() == 0 ? null : new PMC_CertificationRequest(results[0]);
		}

		public List<PMC_CertificationRequest> findApprovedRequestsByDate(Date startDate, Set<Id> userIds) {
			String certType = TYPE_INITIAL;
			String approvedStatus = STATUS_CERTIFICATION_APPROVED;
			List<PMCertReq__c> results = Database.query(getSelect() + ' WHERE Certification_Type__c = :certType and CertificationRequestStatus__c = :approvedStatus and Certification_Award_Approval_Date__c >= :startDate and Candidate__c in :userIds');

			return PMC_CertificationRequest.decorate(results);
		}

		public PMC_CertificationRequest findProvisionalRequestByUser(Id userId) {
			String status = PMC_CertificationRequest.PROV_STATUS_YES;
			List<PMCertReq__c> results = Database.query(getSelect() + ' WHERE Candidate__c = :userId and Provisional_Status_Approved__c = :status');
			return results.size() > 0 ? new PMC_CertificationRequest(results[0]) : null;
		}

		public PMC_CertificationRequest findApprovedRequestByUser(Id userId) {
			String status = PMC_CertificationRequest.STATUS_CERTIFICATION_APPROVED;
			List<PMCertReq__c> results = Database.query(getSelect() + ' WHERE Candidate__c = :userId and CertificationRequestStatus__c = :status');
			return results.size() > 0 ? new PMC_CertificationRequest(results[0]) : null;
		}
	}
}