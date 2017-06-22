@isTest
private class rsAecomCertificationControllerTest {
	@isTest static void testCertifiedUser() {
		PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings();

		User u = PMC_TestUtils.createTestUser('testuser@aecom.com', 'testu123', false);
		u.Certified_PM__c = 'Yes';
		insert u;

		Map<String, Schema.RecordTypeInfo> rt_map = Schema.getGlobalDescribe().get('PMCertReq__c').getDescribe().getRecordTypeInfosByName();
        String rtId = rt_map.get('Initial Certification').getRecordTypeId();

		PMCertReq__c certReq = new PMCertReq__c();
		certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_NEW;
		certReq.Candidate__c = u.Id;
		certReq.Job_ID__c = ps.Initial_Cert_Job_ID__c;
		certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_CERTIFICATION_APPROVED;
		certReq.Certification_Award_Approval_Date__c = Date.today();
		certReq.RecordTypeId = rtId;
		insert certReq;

		Test.startTest();

		rsAecomCertificationController cont = new rsAecomCertificationController();
        cont.profile = rsProfile.find.byUserId(u.Id);

        Test.stopTest();


        System.assert(cont.getIsCertified());
        System.assert(!cont.getIsProvisionallyCertified());

        String certificationDate = cont.getCertificationDate();
        System.assert(!String.isBlank(certificationDate));

        String expirationDate = cont.getExpirationDate();
        System.assert(String.isBlank(expirationDate));
	}
}