@isTest
private class INC_EnrollmentApprovalTest
{
	@isTest
	public static void PP_TandMEnrollmentProcess4(){

		ECO_TriggerSettings__c setting = new ECO_TriggerSettings__c();
		setting.Name = 'INC_IncentiveProject_AllEvents';
		setting.isEnabled__c = true;
		insert setting;

		ECO_TriggerSettings__c setting2 = new ECO_TriggerSettings__c();
		setting2.Name = 'INC_EnrollmentPlan_AllEvents';
		setting2.isEnabled__c = true;
		insert setting2;

		list<user> lUsers = new list<user>();
        
        for(Integer i = 0; i < 8; i++) {
            User oUser = INC_Utils_Testing.createUser();
            oUser.UserName = oUser.UserName + i;
            oUser.Email = i +  'consultant' + oUser.Email;
            oUser.CommunityNickname = oUser.CommunityNickname + i;
            oUser.FederationIdentifier = oUser.FederationIdentifier + i;
            oUser.OracleEmployeeId__c = oUser.OracleEmployeeId__c + i;
            oUser.TrackingID__c = oUser.TrackingID__c + i;
            oUser.URS_FIM_GUID__c = oUser.URS_FIM_GUID__c + i;
            oUser.FirstName = oUser.FirstName + i;
            lUsers.add(oUser);
        }
        insert lUsers;
        
        //Group dtwGroup = INC_Utils_Testing.createPublicGroup('DTW Admins');
        //insert dtwGroup;
        System.runAs(lUsers[0]){
        Group dtwGroup = [Select ID from Group where Name = 'DTW Admins'][0];
        
        GroupMember gm = new GroupMember(UserOrGroupId = lUsers[0].Id
                                         ,GroupID = dtwGroup.id);
        insert gm;

        map<string, User> mUsers = new map<string, User>();
        
        mUsers.put('Approver1', lUsers[0]);
        mUsers.put('Approver2', lUsers[1]);
        mUsers.put('Approver3', lUsers[2]);
        mUsers.put('DTW Admin', lUsers[3]);
        
        //Inser routing rules master data
       //Inser routing rules master data
        map<string, RoutingMember__c> mRoutingMember = INC_Utils_Testing.createRoutingMemberRules(mUsers);
        list<RoutingMember__c> lRoutingMembers = mRoutingMember.Values();

        mUsers.put('Approver1', lUsers[4]);
        mUsers.put('Approver2', lUsers[5]);
        mUsers.put('Approver3', lUsers[6]);
        mUsers.put('DTW Admin', lUsers[7]);

        map<String,RoutingMember__c> mRoutingMember2 = INC_Utils_Testing.createRoutingMemberRules(mUsers);
		
        RoutingMember__c rm = mRoutingMember2.get('LA Metro');
        rm.districtDescription__c = null;
        rm.GlobalDefault__c = true;
        lRoutingMembers.add(rm);
            insert lRoutingMembers;
            


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
            lIncentiveProjectsToInsert[0].ProjectManager__c = lUsers[0].Id;
            update lIncentiveProjectsToInsert;
            
            Inc_Match.FindApprover1(lIncentiveProjectsToInsert);

            //Check if DTW Admin was assigned
            list<IncentiveProject__c> lAssertCheck = new list<IncentiveProject__c>([SELECT Id, DTWAdmin__c FROM IncentiveProject__c WHERE Id = :oIncentiveProject.Id]);
            System.AssertEquals(lAssertCheck.get(0).DTWAdmin__c, lUsers[3].Id);
            
            //User interacts with page and assigns project manager
            oIncentiveProject.ProjectManager__c = lUsers[0].Id;
            
            //User hits save button
            update oIncentiveProject;
            
            //User interacts with button on incentive project to generate enrollment app
            INC_IncentiveProjectCreateEnrollment.createEnrollmentForm(oIncentiveProject.Id);

            //Check if Enrollment Plan was created
            list<EnrollmentPlan__c> lAssertCheckEnrollment = new list<EnrollmentPlan__c>([SELECT Id
                                                                                          FROM EnrollmentPlan__c WHERE IncentiveProject__c = :oIncentiveProject.Id]);
            System.Assert(lAssertCheckEnrollment.size() > 0);


            EnrollmentPlan__c oEnrollmentPlan;
            oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{lAssertCheckEnrollment[0].Id})[0];

            oEnrollmentPlan.IncentivePlan__c = oIncentivePlanTemplate.id;
            update oEnrollmentPlan;

            List<User> lUser = new list<User>();
            lUser.add(mUsers.values()[0]);
            list<Contact> lContacts = INC_Utils_Testing.createContactRecords(lUser);
            insert lContacts;

            Map<id,list<Contact>> mapContactsByEP = new map<id,List<Contact>>();
            mapContactsByEP.put(oEnrollmentPlan.Id,lContacts);


            EnrollmentParticipant__c ep = new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.ID,
                                                                       EmployeeName__c = mapContactsByEP.get(oEnrollmentPlan.Id)[0].id,
                                                                       ParticipantCategory__c = 'Client Account Manager',
                                                                       TargetIncentivePoolAllocated__c = 15);
            insert ep;
            //now start the approval process
            /*
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
            //Approve all steps
            ID workItem = INC_EnrollmentCommentController.getWorkItemId(oEnrollmentPlan.ID);
            System.Debug(logginglevel.error,'Approving records in test class');
            While(workItem != null){
                 Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('System generated final rejection.');
                req.setAction('Approve');
                //req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                req.setWorkitemId(workItem);
                  // Submit the request for approval
                result =  Approval.process(req);
                workItem = INC_EnrollmentCommentController.getWorkItemId(oEnrollmentPlan.id);
            }
            */
          TEST.STARTTEST();
         		INC_EnrollmentPlanTriggers EPTriggers = new INC_EnrollmentPlanTriggers();
          	 	oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{oEnrollmentPlan.id})[0];
          	 	//system.assert(oEnrollmentPlan.EnrollmentStatus__c == 'Enrolled');
          	 	EnrollmentPlan__c oEnrollmentPlan2 = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{oEnrollmentPlan.id})[0];
    	      	oEnrollmentPlan2.EnrollmentStatus__c = 'Pending Approver 1 Action';
    	      	 
    	      	map<id,EnrollmentPlan__c> mapNew = new map<id,EnrollmentPlan__c>();
    	      	map<id,EnrollmentPlan__c> mapOld = new map<id,EnrollmentPlan__c>();
    	       	mapNew.put(oEnrollmentPlan.id,oEnrollmentPlan);
    	      	mapOld.put(oEnrollmentPlan2.id,oEnrollmentPlan2);
    	      	EPTriggers.updateParticipants(mapNew, mapOld);
    	      	EPTriggers.createParticipantAcknowledgement(mapNew, mapOld);
    	      	oEnrollmentPlan.EnrollmentStatus__c = 'Rejected';
    	      	EPTriggers.setIDOnStatusChange(mapNew, mapOld);
    	      	 
    	      	oEnrollmentPlan.ApplicationType__c = 'CCR';
    	      	oEnrollmentPlan2.ApplicationType__c = 'CCR';
    	      	EPTriggers.finishenrollmentOfChangeRequest(mapNew, mapOld);

    	      	oEnrollmentPlan.EnrollmentStatus__c = 'Closed - No Award';
    	      	EPTriggers.updateParticipants(mapNew, mapOld);
    	      	 
    	      	INC_Service_EnrollmentPlan.CloneEnrollment(oEnrollmentPlan.ID,INC_Service_EnrollmentPlan.RequestType.Change);
    	        EnrollmentPlan__c oChangePlan = [Select id, ApplicationType__c from EnrollmentPlan__c where ApplicationType__c = 'CCR'][0];
    	      	
    	      	EnrollmentPlan__c oChangePlan2 = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{oChangePlan.id})[0];

    	      	mapNew.Clear();
    	      	mapOld.Clear();
    	      	oChangePlan.EnrollmentStatus__c = 'Enrolled';
    	      	oChangePlan.ParentApplication__c = oEnrollmentPlan.Id;
    	      	mapNew.put(oChangePlan.id,oChangePlan);
    	      	mapOld.put(oChangePlan2.id,oChangePlan2);
    	      	EPTriggers.finishenrollmentOfChangeRequest(mapNew,mapOld);
    	      	EPTriggers.createParticipantAcknowledgement(mapNew,mapOld);

    	      	oEnrollmentPlan.ActualContingencyBudgetatSnapshot__c = 100;
    	      	update oEnrollmentPlan; //create some history
            	oEnrollmentPlan.ActualFringeBudgetatSnapshot__c = 2000;
            	oEnrollmentPlan.ActualNSRBudgetatSnapshot__c = 10000;
            	update oEnrollmentPlan;
    	      	PageReference pageRef = new PageReference('/apex/Inc_EnrollmentAp?id=' + oEnrollmentPlan.ID);
            	Test.setCurrentPage(pageRef);
            	ApexPages.currentPage().getParameters().put('id', oEnrollmentPlan.ID);

            	INC_ObjectFieldHistory_Controller objHistory = new INC_ObjectFieldHistory_Controller();
            	objHistory.myObject = oEnrollmentPlan;
            	System.debug(logginglevel.error,'oenrollmenPlan before get history ' + oEnrollmentPlan.ID);
            	objHistory.getObjectHistory();
            	objHistory.showmorenumber = 15;
            	objHistory.recordLimit = null;
            	objHistory.getObjectHistory();
            	objHistory.showMore();


          	 System.debug(logginglevel.error,'Enrollment status after approval: ' + oEnrollmentPlan.EnrollmentStatus__c);
          
      }
    }

    @isTest
    public static void PP_TestUserInactive(){
        User oUser = INC_Utils_Testing.createUser();
        User oUser2 = INC_Utils_Testing.createUser();
        oUser2.UserName = oUser2.UserName + '2';
        oUser2.Email = '2' + oUser2.Email;
        oUser2.CommunityNickname = oUser2.CommunityNickname + '2';
        oUser2.FederationIdentifier = oUser2.FederationIdentifier + '2';
        oUser2.OracleEmployeeId__c = oUser2.OracleEmployeeId__c + '2';
        oUser2.TrackingID__c = oUser2.TrackingID__c + '2';
        oUser2.URS_FIM_GUID__c = oUser2.URS_FIM_GUID__c + '2';
        list<user> lUsers = new list<user>{oUser,oUser2};
        insert lUsers;
        System.RunAs(oUser){
            oUser2.isActive = false;
            update oUser2;
        }
    }

}