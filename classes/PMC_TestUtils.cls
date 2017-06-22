public class PMC_TestUtils {

	public static PMC_Settings__c setupCustomSettings() {
		Date yesterday = Date.today().addDays(-1);
		return setupCustomSettings(Date.today().addDays(1), yesterday, yesterday);
	}
	
	public static PMC_Settings__c setupCustomSettings(Date renewalCutoff, Date renewalStart, Date renewalExpiration) {
		PMC_Settings__c ps = PMC_Settings__c.getOrgDefaults();
		ps.API_Key__c = 'TEST';
		ps.Certification_API_URL__c = 'https://www.test.com';
		ps.Initial_Cert_Job_ID__c = 'JOB1';
		ps.Renewal_Job_ID__c = 'JOB2';
		ps.Training_API_URL__c = 'https://www.test.com';
		ps.Renewal_Period_Cutoff_Date__c = renewalCutoff;
		ps.Renewal_Period_Start_Date__c = renewalStart;
		ps.Renewal_Period_Expiration_Date__c = renewalExpiration;

        List<PMC_Curriculum_Assignment__c> assignmentList = new List<PMC_Curriculum_Assignment__c>();
        PMC_Curriculum_Assignment__c assignment = new PMC_Curriculum_Assignment__c();
        assignment.Name = 'A1';
        assignment.Super_Geo__c = 'APAC';
        assignment.Job_ID__c = 'PM_CERT_INT_10001';
        assignmentList.add(assignment);

        assignment = new PMC_Curriculum_Assignment__c();
        assignment.Name = 'A2';
        assignment.Super_Geo__c = 'Americas';
        assignment.Job_ID__c = 'JOB1';
        assignment.Renewal_Job_ID__c = 'JOB2';
        assignmentList.add(assignment);

        insert assignmentList;

        PMC_Task_Subject_Description__c subject = new PMC_Task_Subject_Description__c();
        subject.Name = 'Test';
        subject.Language_Code__c = 'en_US';
        subject.Task_Subject__c = 'Task Subject';
        subject.Final_Approval_Task_Description__c = 'Final approval';
        subject.Interviewer_Endorsement_Description__c = 'Interviewer endorsement';
        subject.Sponsor_Endorsement_Description__c = 'Sponsor endorsement';
        subject.Training_Approval_Description__c = 'Training approval';
        insert subject;

		upsert ps;

		return ps;
	}

    public static void createAecomTestAccount() {
        CFM_TestUtils.createAecomTestAccount();
    }

	public static PMCertReq__c createTestInitialApplication() {
        createAecomTestAccount();

		User u = PMC_TestUtils.createTestUser('testuser@aecom.com', 'testu123');
        User u2 = PMC_TestUtils.createTestUser('testuser2@aecom.com', 'testu124');

        u.Interviewer__c = u2.Id;
        u.PLManager__c = u2.Id;

        update u;

        PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings();
        RecordType rt = [Select Id from RecordType where DeveloperName = 'Certification_Renewal'];
        PMCertReq__c certReq = new PMCertReq__c();
        certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_AWAITING_COMPLETION;
        certReq.Certification_Type__c = PMC_CertificationRequest.TYPE_INITIAL;
        certReq.Candidate__c = u.Id;
        certReq.Candidate_Supervisor__c = u2.Id;
        certReq.Job_ID__c = ps.Initial_Cert_Job_ID__c;
        certReq.RecordTypeId = rt.Id;
        certReq.Interviewer__c = u2.Id;
        certReq.PLMgr__c = u2.Id;
        certReq.Sponsor__c = u2.Id;
        insert certReq;

        return certReq;
	}

	public static User createTestUser(String email, String alias) {
		return createTestUser(email, alias, true);
	}

	private static Profile standardProfile;

	public static User createTestUser(String email, String alias, Boolean shouldInsert) {
		if (standardProfile == null) standardProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = alias, CommunityNickname=alias, Email=email, 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=email,
            Geography_Allocation__c='Corporate',
            TrackingID__c=email);

        User u2 = new User(Alias = 'super', CommunityNickname=alias+'2', Email='supervisor@aecom.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=email+'2',
            Geography_Allocation__c='Corporate',
            TrackingID__c=email+'2');
       insert u2;

       u.ManagerId = u2.Id;
       u.PLManager__c = u2.Id;
       u.Interviewer__c = u2.Id;


        if (shouldInsert) insert u;

        return u;
	}

	public static void setupTestDDPMapping() {
		PMC_DDP_Assignment__c a1 = new PMC_DDP_Assignment__c();
        a1.Name = '1';
        a1.Super_Geo__c = 'Geo1';
        a1.Geo__c = 'Region1';
        a1.DDP_Name__c = 'Certificate';
        a1.Letter_DDP_Name__c = 'Letter';
        insert a1;
	}

	public static void setupTestDDP() {
        Loop__DDP__c ddp = new Loop__DDP__c(Name='Letter');
        insert ddp;

        Loop__DDP_Integration_Option__c deliveryOption = new Loop__DDP_Integration_Option__c(Loop__DDP__c=ddp.Id,Loop__Order__c=1);
        insert deliveryOption;

        Loop__DDP__c ddp2 = new Loop__DDP__c(Name='Certificate');
        insert ddp2;

        Loop__DDP_Integration_Option__c deliveryOption2 = new Loop__DDP_Integration_Option__c(Loop__DDP__c=ddp2.Id,Loop__Order__c=1);
        insert deliveryOption2;
    }

	public class MockCallout implements HttpCalloutMock {

		public Boolean wasCalled  { get; set; }

		public MockCallout() {
			wasCalled = false;
		}

		public HttpResponse respond(HttpRequest req) {
			wasCalled = true;

			HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody(''); // No content for now. Waiting on response definition from Integration team.
	        res.setStatusCode(204);
	        return res;
		}

		public void reset() {
			wasCalled = false;
		}
	}
}