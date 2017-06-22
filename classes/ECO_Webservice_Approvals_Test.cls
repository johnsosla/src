@isTest
private class ECO_Webservice_Approvals_Test
{

	Static List<User> users; 
	Static List<Contact> contacts;
	static user testUser;
	static Approval.ProcessResult result;


	@isTest
	static void TestMethods()
	{
		ECO_Webservice_Approvals.ServiceResponse sr = new ECO_Webservice_Approvals.ServiceResponse(true, 'test');
		ECO_Webservice_Approvals.DTO_TriggeredKPI kpi = new ECO_Webservice_Approvals.DTO_TriggeredKPI('test', 'test');

		test.starttest();
		initializeSites();
		test.stoptest();

        system.runAs(testUser){

        	list<ECO_Webservice_Approvals.DTO_Approval> lstDTO = ECO_Webservice_Approvals.getPendingApprovals();

			string sCMComments = lstDTO[0].sCMComments;
			string sPOVendorName = lstDTO[0].sCMComments;
			string sCMOutgoingPM = lstDTO[0].sCMOutgoingPM;
			string sCMIncomingingPM = lstDTO[0].sCMIncomingingPM;
			string sQSGoNoGo = lstDTO[0].sQSGoNoGo;
			string sSegmentationPage = lstDTO[0].sSegmentationPage;
			string sMSANumber = lstDTO[0].sMSANumber;
			string sMSAName = lstDTO[0].sMSAName;
			date dCMScheduledClosureDate = lstDTO[0].dCMScheduledClosureDate;

		}
	}

/*	@isTest
	static void ApproveTest()
	{

		test.starttest();
		initializeSites();
		test.stoptest();


        system.runAs(testUser){

        	list<ECO_Webservice_Approvals.DTO_Approval> lstDTO = ECO_Webservice_Approvals.getPendingApprovals();
        	ECO_Webservice_Approvals.approve(result.instanceid);
			ECO_Webservice_Approvals.approve(lstDTO[0].sApprovalId);

		}
	}

	@isTest
	static void RejectTest()
	{

		test.starttest();
		initializeSites();
		test.stoptest();

        testUser.Managerid = contacts[5].pse__Salesforce_User__c;
		update testUser;



        Id recordTypeId2 = ECO_Utils_sObject.getRecordTypeId(Delegate__c.sObjectType, 'Key Roles');

        
		Delegate__c delegate2 = new Delegate__c(
												Key_Member_Role__c = 'Accountant Approver', 
												age_Change_in_Forecast_Net_Margin_lt__c = 1, 
												age_Change_in_Forecast_Net_Margin__c = 5,
												Agreement_Amount_estimated__c = 5000,
												Agreement_Amount_estimated_lt__c = 0,
												Backlog_Value_lt__c = 1000,
												Backlog_Value__c = 5000,
												Project_Net_Margin_age_of_NSR_lt__c = 1,
												Project_Net_Margin_age_of_NSR__c = 5,
												Project_Net_Margin_Value_lt__c = 1000,
												Project_Net_Margin_Value__c = 5000,
												Project_Revenue_Budget_lt__c = 1000,
												Project_Revenue_Budget__c = 5000,
												Value_change_in_Forecast_Net_Margin_lt__c = 1000,
												Value_change_in_Forecast_Net_Margin__c = 5000,
												Project_Review_Category_C_4_Bypass__c = true,
												Project_Review_Category_C_4__c = false,
												Start_Date__c = datetime.now().dateGMT(),
												End_Date__c = null
												);
		delegate2.Delegate__c = contacts[0].Id;
		delegate2.RecordTypeId = recordTypeId2;
		delegate2.Delegator__c = contacts[3].Id;

		insert delegate2;


		delegate2.CreatedbyAdmin__c = true;
		delegate2.Approval_Status__c = 'Submitted';
		update delegate2;


        Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
        req2.setObjectId(delegate2.id);
        Approval.ProcessResult result2 = Approval.process(req2);		
   

        system.runAs(testUser){
        	list<ECO_Webservice_Approvals.DTO_Approval> lstDTO = ECO_Webservice_Approvals.getPendingApprovals();
        	ECO_Webservice_Approvals.reject(result2.instanceid);
			ECO_Webservice_Approvals.reject(lstDTO[0].sApprovalId);
		}
	}


	@isTest
	static void ApproveCommentsTest()
	{

		test.starttest();
		initializeSites();
		test.stoptest();

   

        system.runAs(testUser){

        	list<ECO_Webservice_Approvals.DTO_Approval> lstDTO = ECO_Webservice_Approvals.getPendingApprovals();
        	ECO_Webservice_Approvals.approveWithComment(result.instanceid, 'test');
			ECO_Webservice_Approvals.approveWithComment(lstDTO[0].sApprovalId, 'test');

		}
	}

	@isTest
	static void RejectCommentsTest()
	{

		test.starttest();
		initializeSites();
		test.stoptest();


        system.runAs(testUser){
        	list<ECO_Webservice_Approvals.DTO_Approval> lstDTO = ECO_Webservice_Approvals.getPendingApprovals();
        	ECO_Webservice_Approvals.rejectWithComment(result.instanceid, 'test');
			ECO_Webservice_Approvals.rejectWithComment(lstDTO[0].sApprovalId, 'test');
		}
	}*/




	static void initializeSites(){

		contacts = ECO_Utils_Testing.createTestDataForOrgFinder();

        pse__Proj__c proj = [select id, CarryingOutOrganization__c from pse__Proj__c where Name = '**********test project 1' limit 1];

        proj.clAECOMProjectReviewCategory__c = 'C-4';
        proj.PnLManager__c = contacts[2].id;
        proj.ProjectApprover__c = contacts[3].id;
        proj.ProjectApproverUserForProcess__c = contacts[3].pse__Salesforce_User__c;
        proj.pse__Project_Manager__c = contacts[7].id;
        proj.CaptureManager__c = contacts[8].id;

        pse__Proj__Share ps = new pse__Proj__Share();
		ps.AccessLevel = 'Edit';
		ps.ParentId = proj.id;
		ps.UserOrGroupId =  contacts[3].pse__Salesforce_User__c;  
		ps.RowCause = Schema.pse__Proj__Share.RowCause.KeyMember__c;        
		insert ps;

        proj.EscalationApprover__c = null;
        proj.FlagForEscalate__c = true;

        update proj;


        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(proj.id);
        result = Approval.process(req);

   
        testUser = [select id from user where id =: contacts[3].pse__Salesforce_User__c];

	}

}