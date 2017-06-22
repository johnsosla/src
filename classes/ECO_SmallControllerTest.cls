@isTest
private class ECO_SmallControllerTest
{

	Static List<Contact> contacts;
	static user testUser;

	@isTest
	static void ECO_DelegateOrgStringTableControllerTest()
	{
		contacts = ECO_Utils_Testing.createTestDataForOrgFinder();
   
        Id recordTypeId2 = ECO_Utils_sObject.getRecordTypeId(Delegate__c.sObjectType, 'Key Roles');


        list<OrganizationString__c> lstos = [select id from OrganizationString__c];


        string strAllowedOrgs = '';

        for(OrganizationString__c o: lstos){
        	strAllowedOrgs += o.id + ';';
        }


        
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
												End_Date__c = null,
												Allowed_Organizations__c = strAllowedOrgs
												);
		delegate2.Delegate__c = contacts[0].Id;
		delegate2.RecordTypeId = recordTypeId2;
		delegate2.Delegator__c = contacts[3].Id;

		insert delegate2;		


		ECO_DelegateOrgStringTableController ctr = new ECO_DelegateOrgStringTableController();
		ctr.delID = delegate2.id;
		ctr.getrelatedTo();

		system.assertEquals(ctr.getOrgs().size(), 2);

	}

	@isTest
	static void ECO_ApprovalCommentsControllerTest()
	{
		ECO_ProjectTriggers.run = false;
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
        Approval.ProcessResult result = Approval.process(req);		

		List<ProcessInstanceStep> steps = [Select StepStatus, p.Comments, p.ProcessInstance.TargetObjectId, ActorId, Actor.firstname, Actor.lastname from ProcessInstanceStep p];
		System.assertEquals('Started', steps[0].StepStatus);
		System.Debug('BrentBrentBrentBrent' + steps + steps[0].StepStatus);


		ECO_ApprovalCommentsController ctr = new  ECO_ApprovalCommentsController();
		ctr.objId = proj.id;
		ctr.StepStatusMessage = 'Started';
		try
		{
			ctr.getQuoteApprovalComment();
		}catch(Exception e){}
		try{
			ctr.getQuoteApprovalPerson();
		}
		catch(Exception e){}




	}

	@isTest
	static void ECO_RiskFlyoutControllerTest()
	{
		contacts = ECO_Utils_Testing.createTestDataForOrgFinder();
		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];

		ECO_RiskFlyoutController rfc = new ECO_RiskFlyoutController();
		rfc.sProjectId = projectOne.id;

		rfc.saveRisk();
		rfc.refresh();
		rfc.viewRegister();

		risk__c oRisk = rfc.oRisk;

		list<SelectOption> lPlanElements = rfc.lPlanElements;

		list<Risk__c> lRisks = rfc.lRisks;

		List<DOARegister__c> lDOARegisters = rfc.lDOARegisters;


		rfc.sFilterCriteria = 'DOA';

		lPlanElements = rfc.lPlanElements;

		lRisks = rfc.lRisks;

		lDOARegisters = rfc.lDOARegisters;




	}

}