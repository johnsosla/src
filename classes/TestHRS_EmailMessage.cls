@isTest
private class TestHRS_EmailMessage {

    private static void HRS_TestHRS_CreateCase() {

        Case c = new Case();
        c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get('HR - Hire/Rehire/Transfer In').getRecordTypeId();
        c.Type = 'New Hire';
        c.subject = 'I have a new hire starts tomorrow';
        c.Description = 'Here is the description for the new Hire';
        c.Additional_Approver__c = TestHRS_Env_Setup.StandardUserMap.get('CEO').Id;
        c.Manager_Approver__c = TestHRS_Env_Setup.StandardUserMap.get('SVP').Id;
        c.HR_Approver__c = TestHRS_Env_Setup.StandardUserMap.get('HM').Id;
        insert c;

        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(c.id);
        
        // Submit on behalf of a specific submitter
        req1.setNextApproverIds(new Id[] { TestHRS_Env_Setup.StandardUserMap.get('CEO').Id }); 
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('HR_Dynamic_Approval_Eng');
        req1.setSkipEntryCriteria(true);

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        System.assert(result.isSuccess());

    }

	@isTest static void testEmailMessage() {

		TestHRS_Env_Setup.CreateHRSEnv();
		HRS_TestHRS_CreateCase();

		Case c = [select id, Status from case limit 1 ];
	
		EmailMessage[] newEmail = new EmailMessage[0];

		newEmail.add(new EmailMessage( FromAddress = 'standarduserceo@aecom.com', Incoming = True, ToAddress= 'standarduserceo@aecom.com', 
										Subject = 'Case Reference', TextBody = 'Approve', ParentId = c.Id )); 
		Test.startTest();
		insert newEmail;
		Test.stopTest();

	}
	
	@isTest static void ApprovedEmailMessage() {
		// Implement test code

		TestHRS_Env_Setup.CreateHRSEnv();
		HRS_TestHRS_CreateCase();

		Case c = [select id, Status from case limit 1 ];
		
		system.assertEquals( c.status, 'In Approval' );	

	    ProcessInstance pi = [SELECT Id,ProcessDefinitionId,Status,TargetObjectId FROM ProcessInstance WHERE TargetObjectId =: c.Id and status = 'Pending' ];

	    system.assertNotEquals( pi, null );

		EmailMessage[] newEmail = new EmailMessage[0];

		newEmail.add(new EmailMessage( FromAddress = 'standarduserceo@aecom.com', Incoming = True, ToAddress= 'standarduserceo@aecom.com', 
										Subject = 'Case Reference', TextBody = 'Approve', ParentId = c.Id)); 
		Test.startTest();
		insert newEmail;
		Test.stopTest();

		Case verifyc = [select id, Status from case where id =: c.Id ];

		system.assertEquals( 'In Approval', verifyc.status );		

	}

	@isTest static void FullApprovedEmailMessage() {
		// Implement test code
		TestHRS_Env_Setup.CreateHRSEnv();
		HRS_TestHRS_CreateCase();

		Case c = [select id, Status from case limit 1 ];
		
		system.assertEquals( c.status, 'In Approval' );	

	    ProcessInstance pi = [SELECT Id,ProcessDefinitionId,Status,TargetObjectId FROM ProcessInstance WHERE TargetObjectId =: c.Id and status = 'Pending' ];

	    system.assertNotEquals( pi, null );

		List<EmailMessage> newEmail = new List<EmailMessage>();

		newEmail.add(new EmailMessage( FromAddress = 'standarduserceo@aecom.com', Incoming = True, ToAddress= 'standarduserceo@aecom.com', 
										Subject = 'Case Reference', TextBody = 'Approve', ParentId = c.Id)); 

		newEmail.add(new EmailMessage( FromAddress = 'standarduser2@aecom.com', Incoming = True, ToAddress= 'standarduser2@aecom.com', 
										Subject = 'Case Reference', TextBody = 'Approve', ParentId = c.Id)); 

		newEmail.add(new EmailMessage( FromAddress = 'standarduser5@aecom.com', Incoming = True, ToAddress= 'standarduser5@aecom.com', 
										Subject = 'Case Reference', TextBody = 'Approve', ParentId = c.Id)); 

		Test.startTest();
		insert newEmail;
		Test.stopTest();

		Case verifyc = [select id, Status from case where id =: c.Id ];

		system.assertEquals( 'Approved', verifyc.status );		

	}

	@isTest static void RejectEmailMessage() {
				TestHRS_Env_Setup.CreateHRSEnv();
		HRS_TestHRS_CreateCase();

		// Implement test code
		Case c = [select id, Status from case limit 1 ];
		
		system.assertEquals( c.status, 'In Approval' );	

		EmailMessage[] newEmail = new EmailMessage[0];

		newEmail.add(new EmailMessage( FromAddress = 'standarduser5@aecom.com', Incoming = True, ToAddress= 'standarduser5@aecom.com', 
										Subject = 'Case Reference', TextBody = 'Reject', ParentId = c.Id)); 

		Test.startTest();
		insert newEmail;
		Test.stopTest();

		Case verifyc = [select id, Status from case where id =: c.Id ];

		system.assertEquals( 'Not Approved', verifyc.status );
	}

	@isTest static void WrongUserEmailMessage() {
		TestHRS_Env_Setup.CreateHRSEnv();
		HRS_TestHRS_CreateCase();		
		// Implement test code
		Case c = [select id, Status from case limit 1 ];
		
		system.assertEquals( c.status, 'In Approval' );	

		EmailMessage[] newEmail = new EmailMessage[0];

		newEmail.add(new EmailMessage( FromAddress = 'wato@aecom.com', Incoming = True, ToAddress= 'wato@aecom.com', 
										Subject = 'Case Reference', TextBody = 'Reject', ParentId = c.Id)); 

		Test.startTest();
		insert newEmail;
		Test.stopTest();

		Case verifyc = [select id, Status from case limit 1 ];
		
		system.assertEquals( 'In Approval', verifyc.status );			
	}	



}