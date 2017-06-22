@IsTest
private class PMC_Approval_Test {


	@isTest
	static void testSponsorEndorsement()
	{
		PMCertReq__c app =  PMC_TestUtils.createTestInitialApplication();

		PMC_SponsorEndorsementController cont = new PMC_SponsorEndorsementController(new ApexPages.StandardController(app));

		cont.checkUserIsSponsor();

		System.assertNotEquals(null, cont.certReq, 'App should have loaded');
		System.assert(cont.userIsNotSponsor, 'System user is not sponsor');

		System.assertNotEquals(0, cont.getEndorsementOptions().size(), 'Page should have some endorsement options');

		User u = [Select Id, Name from User where Id = :cont.certReq.Sponsor__c];

		System.runAs(u) {
			cont.checkUserIsSponsor();
			System.assert(!cont.userIsNotSponsor, 'Running as sponsor should set sponsor flag to true'); // Running as sponsor should set sponsor flag to true


			// Reject
			cont.certReq.Sponsor_Endorsement__c = 'Not Endorsed';
			cont.next();
			System.assertEquals(cont.certReq.CertificationRequestStatus__c, 'Sponsor Endorsement Rejected', 'Not endorsing candidate should have changed status to rejected');

			// Approve
			cont.certReq.Sponsor_Endorsement__c = 'Endorsed';
			cont.next();
			System.assertEquals(cont.certReq.CertificationRequestStatus__c, 'Sponsor Endorsement Approved', 'Endorsing candidate should have changed status to approved');

		}
	}

	@isTest
	static void testProvisionalTrainingApproval()
	{
		// Test provisional
		PMCertReq__c app =  PMC_TestUtils.createTestInitialApplication();
		app.Provisional_PM_Request__c = true;
		update app;

		PMC_PLMgrTrainingApprovalController cont = new PMC_PLMgrTrainingApprovalController(new ApexPages.StandardController(app));

		System.assertNotEquals(null, cont.certReq);

		System.assertEquals(1, cont.currentStep, 'Provisional PM Request should start training app from step 1 (provisional approval)');

		System.assertNotEquals(0, cont.getRejectionReasons().size());
		System.assertNotEquals(0, cont.getProvisionalApprovalOptions().size());

		cont.checkUserIsPlManager();

		System.assert(cont.authError, 'Running as non-approver user should have triggered authorization error');

		User u = [Select Id from User where Id = :app.PLMgr__c];

		System.runAs(u) {
			cont.checkUserIsPlManager();
			System.assert(!cont.authError, 'Running as PL Manager should not have triggered authorization error');

			cont.provisionalNext();
			System.assertEquals(2, cont.currentStep);

			cont.approvalPrevious();
			System.assertEquals(1, cont.currentStep);


			// First test approval
			cont.trainingApprovalGranted = 'Yes';
			cont.approvalNext();
			System.assertEquals('Training Request Approved', cont.certReq.CertificationRequestStatus__c, 'Approving should have switched status to Approved');

			// Next test rejection
			cont.trainingApprovalGranted = 'No';
			cont.approvalNext();
			cont.rejectionNext();
			System.assertEquals('Training Request Rejected', cont.certReq.CertificationRequestStatus__c, 'Rejecting should have switched status to Approved');
		}

	}

	@isTest 
	static void testInterviewerEndorsement()
	{
		PMCertReq__c app =  PMC_TestUtils.createTestInitialApplication();

		User u = [Select Id from User where Id = :app.Interviewer__c];

		System.runAs(u) {
			Attachment a = new Attachment(ParentId=app.Id,Body=Blob.valueOf('Test'),Name='Resume.txt');
			insert a;

			PMC_InterviewerEndorsementController cont = new PMC_InterviewerEndorsementController(new ApexPages.StandardController(app));

			System.assertNotEquals(null, cont.certReq);
			System.assertNotEquals(null, cont.candidate);
			System.assert(cont.authError != true); // Could be null, need to check against true
			System.assert(cont.missingAttachmentError != true);
			System.assertNotEquals(0, cont.getEndorsementOptions().size());


			PageReference pg = cont.next();

			System.assertEquals(cont.certReq.CertificationRequestStatus__c, 'Interview Completed');
		}
	}

	@isTest
	static void testFinalApproval()
	{
		PMCertReq__c app =  PMC_TestUtils.createTestInitialApplication();

		User u = new User(Id=app.PLMgr__c);

		System.runAs(u) {

			PMC_PLMgrFinalApprovalController cont = new PMC_PLMgrFinalApprovalController(new ApexPages.StandardController(app));

			System.assertNotEquals(null, cont.certReq);
			System.assertEquals(1, cont.currentStep);

			System.assertNotEquals(0, cont.getRejectionReasons().size());

			cont.previous();

			System.assertEquals(1, cont.currentStep);

			// Test approval
			cont.plManagerApproved = 'Yes';
			cont.next();
			System.assertEquals('Certification Approved', cont.certReq.CertificationRequestStatus__c);

			// Test rejection

			cont.plManagerApproved = 'No';
			cont.next();
			System.assertEquals(2, cont.currentStep);

			cont.reject();
			System.assertEquals('Certification Rejected', cont.certReq.CertificationRequestStatus__c);
			System.assertEquals('No', cont.certReq.P_L_Manager_Approved__c);
		}

	}
}