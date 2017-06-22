@isTest
private class INC_DeliverToWinLandingTest {
	
	@isTest static void test_method_one() {

        ECO_TriggerSettings__c setting = new ECO_TriggerSettings__c();
        setting.Name = 'INC_IncentiveProject_AllEvents';
        setting.isEnabled__c = true;
        insert setting;

        ECO_TriggerSettings__c setting2 = new ECO_TriggerSettings__c();
        setting2.Name = 'INC_EnrollmentPlan_AllEvents';
        setting2.isEnabled__c = true;
        insert setting2;
        
        User oUser = INC_Utils_Testing.createUser();
        oUser.Email = '3.consultant' + oUser.email;
        oUser.FirstName = 'TestBlan' + Math.random();
        oUser.UserName = oUser.UserName + '3';
        oUser.CommunityNickname = oUser.CommunityNickname + '3';
        oUser.FederationIdentifier = oUser.FederationIdentifier + '3';
        oUser.OracleEmployeeId__c = oUser.OracleEmployeeId__c + '3';
        oUser.TrackingID__c = oUser.TrackingID__c + '3';
        oUser.URS_FIM_GUID__c = oUser.URS_FIM_GUID__c + '3';
        insert oUser;
        
        map<string, User> mUsers = new map<string, User>();
        
        mUsers.put('Approver1', oUser);
        mUsers.put('Approver2', oUser);
        mUsers.put('Approver3', oUser);
        mUsers.put('DTW Admin', oUser);
        
        //Inser routing rules master data
        map<string, RoutingMember__c> mRoutingMember = INC_Utils_Testing.createRoutingMemberRules(mUsers);
        
        insert mRoutingMember.values();
        
        list<IncentivePlanTemplate__c> lPlanTemplates = INC_Utils_Testing.createIncentivePlan();
        
        insert lPlanTemplates;
        
        IncentivePlanTemplate__c oIncentivePlanTemplate = lPlanTemplates[0];

        //END: Setup Master Data
        
        //Initialize starting position
        IncentiveProject__c oIncentiveProject = INC_Utils_Testing.createIncentiveProject_TownAndCountry();
        
        //To Do: Implement RunAs for integration administrator user
        insert oIncentiveProject;
        
        //Find and Assign DTW Admin (Assume Batch Job is Run)
        INC_Service_Matching Inc_Match = new INC_Service_Matching();
        list<IncentiveProject__c> lIncentiveProjectsToInsert = Inc_Match.FindDTWAdmin(new list<IncentiveProject__c>{oIncentiveProject});
        
        update lIncentiveProjectsToInsert;
        
        //Check if DTW Admin was assigned
        list<IncentiveProject__c> lAssertCheck = new list<IncentiveProject__c>([SELECT Id, DTWAdmin__c FROM IncentiveProject__c WHERE Id = :oIncentiveProject.Id]);
        System.AssertEquals(lAssertCheck.get(0).DTWAdmin__c, oUser.Id);
        
        //User interacts with page and assigns project manager
        oIncentiveProject.ProjectManager__c = oUser.Id;
        
        //User hits save button
        update oIncentiveProject;
        
        //User interacts with button on incentive project to generate enrollment app
        INC_IncentiveProjectCreateEnrollment.createEnrollmentForm(oIncentiveProject.Id);
        list<EnrollmentPlan__c> lAssertCheckEnrollment = new list<EnrollmentPlan__c>([SELECT Id
                                                                                      FROM EnrollmentPlan__c WHERE IncentiveProject__c = :oIncentiveProject.Id]);
        System.Assert(lAssertCheckEnrollment.size() > 0);

        EnrollmentPlan__c oEnrollmentPlan;
        oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{lAssertCheckEnrollment[0].Id})[0];
        oEnrollmentPlan.ConfirmBaseline__c = 'Yes';
        oEnrollmentPlan.DSOTarget__c = 61;
        update oEnrollmentPlan;

         // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(oEnrollmentPlan.ID);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(oUser.Id); 
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('DTW_Incentives_App_Approval_Process');
        req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        System.assert(result.isSuccess());

        list<IncentiveProject__c> lstIP = new list<IncentiveProject__c>();
        //lstIP.add(INC_Utils_Testing.createIncentiveProject());
        //lstIP.add(INC_Utils_Testing.createIncentiveProject());
        //lstIP.add(INC_Utils_Testing.createIncentiveProject());
        //lstIP.add(INC_Utils_Testing.createIncentiveProject());
        //lstIP.add(INC_Utils_Testing.createIncentiveProject());
        //lstIP.add(INC_Utils_Testing.createIncentiveProject());

        //for(IncentiveProject__c ip: lstIP){
        //	ip.EnrollmentPlan__c = ePlan.id;
        //}

        //insert lstIP;
        list<Contact> lContacts = INC_Utils_Testing.createContactRecords(new List<User>{oUser});
        insert lContacts;
        Contact employee = lContacts[0];
        System.assertNotEquals(employee.Id, Null);
        
        EnrollmentParticipant__c ePart = INC_Utils_testing.createEnrollmentParticipant(oEnrollmentPlan, employee);
        insert ePart;

		list<ParticipantAcknowledgement__c> lpa = new list<ParticipantAcknowledgement__c>();
		lpa.add(new ParticipantAcknowledgement__c(ParticipantID__c = ePart.id));
		//lpa.add(new ParticipantAcknowledgement__c(ParticipantID__c = ePart.id));
		//lpa.add(new ParticipantAcknowledgement__c(ParticipantID__c = ePart.id));
		//lpa.add(new ParticipantAcknowledgement__c(ParticipantID__c = ePart.id));
		//lpa.add(new ParticipantAcknowledgement__c(ParticipantID__c = ePart.id));
		//lpa.add(new ParticipantAcknowledgement__c(ParticipantID__c = ePart.id));
		//lpa.add(new ParticipantAcknowledgement__c(ParticipantID__c = ePart.id));

		insert(lpa);

        System.runAs(oUser){
    		INC_DeliverToWinLandingController ctr = new INC_DeliverToWinLandingController();

    		//system.assertEquals(ctr.lstApprovalItemShortPA.size(), 5);
    		//system.assertEquals(ctr.lstIPShort.size(), 5);

    		ctr.more();
    		//system.assertEquals(ctr.bMore, true);

    		ctr.less();
    		//system.assertEquals(ctr.bMore, false);

    		ctr.moreAck();
    		//system.assertEquals(ctr.bMoreAck, true);

    		ctr.lessAck();
    		//system.assertEquals(ctr.bMoreAck, false);

    		ctr.moreProj();
    		//system.assertEquals(ctr.bMoreProj, true);

    		ctr.lessProj();
    		//system.assertEquals(ctr.bMoreProj, false);
        }
	}

	
}