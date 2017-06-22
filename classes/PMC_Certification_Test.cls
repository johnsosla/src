@IsTest
private class PMC_Certification_Test {
    
    @isTest static void testTrainingRequestApproved() {
        User u = PMC_TestUtils.createTestUser('testuser@aecom.com', 'testu123');
        User sponsor = [Select Id from User where email = 'supervisor@aecom.com'];

        PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings();
        RecordType rt = [Select Id from RecordType where DeveloperName = 'Initial_Certification'];
        PMCertReq__c certReq = new PMCertReq__c();
        certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_NEW;
        certReq.Candidate__c = u.Id;
        certReq.Job_ID__c = ps.Initial_Cert_Job_ID__c;
        certReq.RecordTypeId = rt.Id;
        certReq.Sponsor__c = sponsor.Id;
        insert certReq;

        PMC_TestUtils.MockCallout mockCallout = new PMC_TestUtils.MockCallout();
        Test.setMock(HttpCalloutMock.class, mockCallout);
        Test.startTest();

        certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_TRAINING_REQUEST_APPROVED;
        update certReq;

        Test.stopTest();

        System.assert(PMC_LMS_Interface.wasCalled, 'Should have sent training enrollment request to LMS');
    }

    @isTest static void testCertificationApproved() {
        User u = PMC_TestUtils.createTestUser('testuser@aecom.com', 'testu123');
        User sponsor = [Select Id from User where email = 'supervisor@aecom.com'];

        PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings();
        RecordType rt = [Select Id from RecordType where DeveloperName = 'Initial_Certification'];
        PMCertReq__c certReq = new PMCertReq__c();
        certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_NEW;
        certReq.Certification_Type__c = PMC_CertificationRequest.TYPE_INITIAL;
        certReq.Candidate__c = u.Id;
        certReq.Job_ID__c = ps.Initial_Cert_Job_ID__c;
        certReq.RecordTypeId = rt.Id;
        certReq.Sponsor__c = sponsor.Id;
        insert certReq;
        
        Test.startTest();
        PMC_TestUtils.MockCallout mockCallout = new PMC_TestUtils.MockCallout();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_CERTIFICATION_APPROVED;
        update certReq;

        Test.stopTest();

        u = [Select Id, Certified_PM__c from User where Id = :u.Id];

        System.assertEquals(u.Certified_PM__c, 'Yes', 'After certification request is approved Certified PM flag on user should flip to yes');
        System.assert(PMC_HRI_Interface.wasCalled, 'Should have called certification call to HR Insight');
        System.assert(PMC_LMS_Interface.wasCalled, 'Should have sent renewal request to HR Insight');
       
    }

    @isTest static void testCertificationRequestExpiration() {
        User u = PMC_TestUtils.createTestUser('testuser@aecom.com', 'testu123');
        User sponsor = [Select Id from User where email = 'supervisor@aecom.com'];

        PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings();
        RecordType rt = [Select Id from RecordType where DeveloperName = 'Initial_Certification'];
        PMCertReq__c certReq = new PMCertReq__c();
        certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_AWAITING_COMPLETION;
        certReq.Certification_Type__c = PMC_CertificationRequest.TYPE_INITIAL;
        certReq.Candidate__c = u.Id;
        certReq.Job_ID__c = ps.Initial_Cert_Job_ID__c;
        certReq.TrainingApprovalDate__c = Date.today().addYears(-2); // Training request expires after 180 days
        certReq.RecordTypeId = rt.Id;
        certReq.Sponsor__c = sponsor.Id;
        insert certReq;


        Test.startTest();

        PMC_CertificationRequestExpiration_Batch b = new PMC_CertificationRequestExpiration_Batch();
        b.execute(null);

        Test.stopTest();

        System.assert(PMC_LMS_Interface.wasCalled);

        certReq = [Select Id, CertificationRequestStatus__c from PMCertReq__c where Id = :certReq.Id];

        System.assertEquals(PMC_CertificationRequest.STATUS_TRAINING_EXPIRED, certReq.CertificationRequestStatus__c, 'Status should be set as expired because expiration date was in the past');
    }

    @isTest static void testCertificationRenewal() {
        User u = PMC_TestUtils.createTestUser('testuser@aecom.com', 'testu123', false);
        u.Certified_PM__c = 'Yes';
        insert u;
        
        PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings(Date.today().addYears(-1), null, null);
        
        Test.startTest();

        PMC_CertificationRenewal_Batch b = new PMC_CertificationRenewal_Batch();
        b.execute(null, new List<User> {u});

        Test.stopTest();

        List<PMCertReq__c> requests = [Select Id, Candidate__c, Job_ID__c, Certification_Type__c, RecordType.DeveloperName from PMCertReq__c];

        System.assert(PMC_LMS_Interface.wasCalled, 'The LMS should have been called with the renewal enrollment');
        System.assertEquals(1, requests.size(), 'Should have one request for the one user');
        System.assertEquals(PMC_CertificationRequest.TYPE_RENEWAL, requests[0].Certification_Type__c, 'Should have created a renewal certification');
        

    }

    @isTest static void testCertificationRenewalExpiration() {
        Map<String, Schema.RecordTypeInfo> rt_map = Schema.getGlobalDescribe().get('PMCertReq__c').getDescribe().getRecordTypeInfosByName();
        String renewalRtId = rt_map.get('Certification Renewal').getRecordTypeId();

        User u = PMC_TestUtils.createTestUser('testuser@aecom.com', 'testu123', false);
        u.Certified_PM__c = 'Yes';
        insert u;

        System.assert(!String.isBlank(renewalRtId), 'Test relies on having Certification renewal record type');

        PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings();

        PMCertReq__c req = new PMCertReq__c();
        req.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_AWAITING_COMPLETION;
        req.Candidate__c = u.Id;
        req.RecordTypeId = renewalRtId;
        insert req;

        Test.startTest();

        PMC_CertificationExpiration_Batch b = new PMC_CertificationExpiration_Batch();
        Database.executeBatch(b, 100);

        Test.stopTest();

        req = [Select Id, CertificationRequestStatus__c from PMCertReq__c where Id = :req.Id];
        System.assert(PMC_HRI_Interface.wasCalled, 'System should have called out to HR Insight to remove certification');
        System.assertEquals(PMC_CertificationRequest.STATUS_TRAINING_EXPIRED, req.CertificationRequestStatus__c, 'Overdue renewal should have expired');
        

        u = [Select Id, Certified_PM__c from User where Id =:u.id];

        System.assertEquals('No', u.Certified_PM__c, 'Certification should have been removed from the user');
    }

    @isTest static void testManagementJob() {
        PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings(Date.today().addYears(-1), null, null);

        Test.startTest();

        PMC_CertificationManagement_Job b = new PMC_CertificationManagement_Job();
        b.execute(null);

        Test.stopTest();
    }


    @isTest static void testProvisionalCertification() {
        User u = PMC_TestUtils.createTestUser('testuser@aecom.com', 'testu123');
        User sponsor = [Select Id from User where email = 'supervisor@aecom.com'];

        PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings();
        RecordType rt = [Select Id from RecordType where DeveloperName = 'Initial_Certification'];
        PMCertReq__c certReq = new PMCertReq__c();
        certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_NEW;
        certReq.Certification_Type__c = PMC_CertificationRequest.TYPE_INITIAL;
        certReq.Candidate__c = u.Id;
        certReq.Job_ID__c = ps.Initial_Cert_Job_ID__c;
        certReq.Provisional_PM_Request__c = true;
        certReq.RecordTypeId = rt.Id;
        certReq.Sponsor__c = sponsor.Id;
        insert certReq;

        Test.startTest();
        PMC_TestUtils.MockCallout mockCallout = new PMC_TestUtils.MockCallout();
        Test.setMock(HttpCalloutMock.class, mockCallout);

        certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_TRAINING_REQUEST_APPROVED;
        certReq.Provisional_Status_Approved__c = PMC_CertificationRequest.PROV_STATUS_YES;
        update certReq;

        Test.stopTest();

        System.assert(PMC_HRI_Interface.wasCalled, 'Should have called certification call to HR Insight');
    }

    @isTest static void testpmCertPageCon() {
        User u = PMC_TestUtils.createTestUser('testuser@aecom.com', 'testu123');
        User sponsor = [Select Id from User where email = 'supervisor@aecom.com'];

        PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings();
        RecordType rt = [Select Id from RecordType where DeveloperName = 'Initial_Certification'];
        PMCertReq__c certReq = new PMCertReq__c();
        certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_NEW;
        certReq.Certification_Type__c = PMC_CertificationRequest.TYPE_INITIAL;
        certReq.Candidate__c = u.Id;
        certReq.Job_ID__c = ps.Initial_Cert_Job_ID__c;
        certReq.Provisional_PM_Request__c = true;
        certReq.RecordTypeId = rt.Id;
        certReq.Sponsor__c = sponsor.Id;
        insert certReq;

        System.runAs(u) {
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(certReq);
            pmCertPageCon cont = new pmCertPageCon(sc);
            List<PMCertReq__c> certs = cont.getpmcert();
            Test.stopTest();

            System.assertEquals(1, certs.size());
            System.assertEquals(certReq.Id, certs[0].Id);
        }
    }
    
    @isTest static void test1pmCertPageCon() {
            // Set up test data
        PMCertReq__c req = PMC_TestUtils.createTestInitialApplication();
        pmCertPageCon cont1 = new pmCertPageCon(new ApexPages.StandardController(new PMCertReq__c()));
          cont1.searchValue = 'TEST';
          cont1.searchApplications();
          cont1.recordId=req.Id;
          cont1.deleteRow();
}

    @isTest static void testAssignmentByRegion() {
        User u = PMC_TestUtils.createTestUser('testuser@aecom.com', 'testu123');
        u.Supergeography__c = 'Geo1';
        u.Geography__c = 'Region1';
        update u;

        User sponsor = [Select Id from User where email = 'supervisor@aecom.com'];

        PMC_Curriculum_Assignment__c a1 = new PMC_Curriculum_Assignment__c();
        a1.Name = '1';
        a1.Super_Geo__c = 'Geo1';
        a1.Geo__c = 'Region1';
        a1.Job_ID__c = 'Job1';
        insert a1;

        PMC_Curriculum_Assignment__c a2 = new PMC_Curriculum_Assignment__c();
        a2.Name = '2';
        a2.Super_Geo__c = 'Geo2';
        a2.Geo__c = 'Region2';
        a2.Job_ID__c = 'Job2';
        insert a2;

        PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings();
        RecordType rt = [Select Id from RecordType where DeveloperName = 'Initial_Certification'];
        PMCertReq__c certReq = new PMCertReq__c();
        certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_NEW;
        certReq.Certification_Type__c = PMC_CertificationRequest.TYPE_INITIAL;
        certReq.Candidate__c = u.Id;
        certReq.RecordTypeId = rt.Id;
        certReq.Sponsor__c = sponsor.Id;
        insert certReq;

        certReq = [Select Id, Job_ID__c, Job_ID_Assignment_Preview__c from PMCertReq__c where Id = :certReq.Id];
        System.assertEquals('Job1', certReq.Job_ID_Assignment_Preview__c, 'Should have picked up Job ID preview from region assignment');
        System.assertEquals(null, certReq.Job_ID__c, 'Should not have populated Job ID until training request is approved');

        
        certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_TRAINING_REQUEST_APPROVED;
        update certReq;

        certReq = [Select Id, Job_ID__c, Job_ID_Assignment_Preview__c from PMCertReq__c where Id = :certReq.Id];
        System.assertEquals('Job1', certReq.Job_ID__c, 'Should have picked up Job ID from region assignment');


    }

    @isTest static void testDdpAssignment() {
        PMC_TestUtils.setupTestDDPMapping();
        PMC_TestUtils.setupTestDDP();
        PMC_Settings__c ps = PMC_TestUtils.setupCustomSettings();

        User u = PMC_TestUtils.createTestUser('testuser@aecom.com', 'testu123');
        u.Supergeography__c = 'Geo1';
        u.Geography__c = 'Region1';
        update u;

        User sponsor = [Select Id from User where email = 'supervisor@aecom.com'];

        RecordType rt = [Select Id from RecordType where DeveloperName = 'Initial_Certification'];
        PMCertReq__c certReq = new PMCertReq__c();
        certReq.CertificationRequestStatus__c = PMC_CertificationRequest.STATUS_NEW;
        certReq.Certification_Type__c = PMC_CertificationRequest.TYPE_INITIAL;
        certReq.Candidate__c = u.Id;
        certReq.Job_ID__c = ps.Initial_Cert_Job_ID__c;
        certReq.Provisional_PM_Request__c = true;
        certReq.RecordTypeId = rt.Id;
        certReq.Sponsor__c = sponsor.Id;
        certReq.Letter_Generation_Status__c = 'Pending';
        certReq.Certificate_Generation_Status__c = 'Pending';
        insert certReq;

        Test.startTest();

        PMC_CertificateGeneration_Job j = new PMC_CertificateGeneration_Job();
        j.execute(null);

        Test.stopTest();

        certReq = [Select Id, 
                    Letter_Generation_Status__c, 
                    Certificate_Generation_Status__c, 
                    Letter_DDP_Id__c, 
                    Certificate_DDP_Id__c,
                    Certificate_Delivery_Id__c, 
                    Letter_Delivery_Id__c
                    from PMCertReq__c where Id = :certReq.Id];


        System.assertEquals('Generating', certReq.Letter_Generation_Status__c);
        System.assertEquals('Generating', certReq.Certificate_Generation_Status__c);
        System.assertNotEquals(null, certReq.Letter_DDP_Id__c);
        System.assertNotEquals(null, certReq.Certificate_DDP_Id__c);
        System.assertNotEquals(null, certReq.Certificate_Delivery_Id__c);
        System.assertNotEquals(null, certReq.Letter_Delivery_Id__c);
        
    }


}