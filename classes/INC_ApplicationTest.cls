@isTest
public class INC_ApplicationTest {

/*
    testMethod static void PP_TandMEnrollmentProcess(){
        //START: Setup master data
        //Create running users
       
        ECO_TriggerSettings__c setting = new ECO_TriggerSettings__c();
        setting.Name = 'INC_IncentiveProject_AllEvents';
        setting.isEnabled__c = true;
        insert setting;

        ECO_TriggerSettings__c setting2 = new ECO_TriggerSettings__c();
        setting2.Name = 'INC_EnrollmentPlan_AllEvents';
        setting2.isEnabled__c = true;
        insert setting2;

        User oUser = INC_Utils_Testing.createUser();

        insert oUser;
        

        //Group dtwGroup = INC_Utils_Testing.createPublicGroup('DTW Admins');
        //insert dtwGroup;
        System.runAs(oUser){
             Group dtwGroup = [Select ID from Group where Name = 'DTW Admins'][0];
        
        GroupMember gm = new GroupMember(UserOrGroupId = oUser.ID
                                         ,GroupID = dtwGroup.id);
        insert gm;

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
        lIncentiveProjectsToInsert[0].ProjectManager__c = oUser.ID;
        update lIncentiveProjectsToInsert;
        
        //Check if DTW Admin was assigned
        list<IncentiveProject__c> lAssertCheck = new list<IncentiveProject__c>([SELECT Id, DTWAdmin__c FROM IncentiveProject__c WHERE Id = :oIncentiveProject.Id]);
        //System.AssertEquals(lAssertCheck.get(0).DTWAdmin__c, oUser.Id);
        
        //User interacts with page and assigns project manager
        oIncentiveProject.ProjectManager__c = oUser.Id;
        
        //User hits save button
        update oIncentiveProject;
        
        //User interacts with button on incentive project to generate enrollment app
        INC_IncentiveProjectCreateEnrollment.createEnrollmentForm(oIncentiveProject.Id);

        //Check if Enrollment Plan was created
        list<EnrollmentPlan__c> lAssertCheckEnrollment = new list<EnrollmentPlan__c>([SELECT Id
                                                                                      FROM EnrollmentPlan__c WHERE IncentiveProject__c = :oIncentiveProject.Id]);
        //System.Assert(lAssertCheckEnrollment.size() > 0);

        EnrollmentPlan__c oEnrollmentPlan;
        oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{lAssertCheckEnrollment[0].Id})[0];

        INC_EnrollmentApp_Controller oEnrollmentApplicationController = new INC_EnrollmentApp_Controller(new ApexPages.StandardController(oEnrollmentPlan));

        //Go to step two
        oEnrollmentApplicationController.stepTwo();

        //select Incentive Plan for app
        PageReference pageRef = Page.INC_Chose;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', oEnrollmentPlan.ID);
        ID currentPageID = oEnrollmentPlan.id;
        INC_ChoseIncentivePlanController oChoseIncentivePlanController = new INC_ChoseIncentivePlanController();
        //initailize controller and questions
        oChoseIncentivePlanController = new INC_ChoseIncentivePlanController(new ApexPages.StandardController(oEnrollmentPlan));
        oChoseIncentivePlanController.getYesNoOptions();
        oChoseIncentivePlanController.getSelectionMethods();
        oChoseIncentivePlanController.getIsAnzRegion();
        oChoseIncentivePlanController.getIsMultiPlanEligible();
        oChoseIncentivePlanController.returnHome();
        
        //Manual Selection
        oChoseIncentivePlanController.selectedSelectionMethod = 'Manual';
        oChoseIncentivePlanController.ManualSelection();
        List<INC_ChoseIncentivePlanController.PlanWrapper>lPlans = oChoseIncentivePlanController.availablePlans;
        
        for(INC_ChoseIncentivePlanController.PlanWrapper PW: lPlans){
            if(PW.plan.ID == oIncentivePlanTemplate.id){
                PW.Selected = true;
            }
        }
        //System.assert(oChoseIncentivePlanController.availablePlans.size() > 0,'Before setting');
        oChoseIncentivePlanController.availablePlans = lPlans;
        //System.assert(oChoseIncentivePlanController.availablePlans.size() > 0,'After setting');
        oChoseIncentivePlanController.selectPlanForEnrollment();

        //assert enrollment app plan is the plan I chose in test
        list<EnrollmentPlan__c> lCheckIncentivePlan = [Select ID, IncentivePlan__c, IncentivePlan__r.MinAllocationPer__c from EnrollmentPlan__c where id =: oEnrollmentPlan.ID];
        oEnrollmentPlan = lCheckIncentivePlan[0];
        //System.AssertEquals(oEnrollmentPlan.IncentivePlan__c,oIncentivePlanTemplate.ID);

        //No do Guided 
        oChoseIncentivePlanController.selectedSelectionMethod= 'Guided';
        oChoseIncentivePlanController.manualSelection();
        oChoseIncentivePlanController.question1Answer='Yes';
        oChoseIncentivePlanController.question2Answer='Yes';
        oChoseIncentivePlanController.question3Answer='Yes';
        oChoseIncentivePlanController.question4Answer='Yes';
        oChoseIncentivePlanController.submitQuestionnairre();
        
        oChoseIncentivePlanController.question3Answer='No';
        oChoseIncentivePlanController.question4Answer='Yes';
        oChoseIncentivePlanController.submitQuestionnairre();
        oChoseIncentivePlanController.question3Answer='Yes';
        oChoseIncentivePlanController.question4Answer='No';
        oChoseIncentivePlanController.submitQuestionnairre();
        oChoseIncentivePlanController.question2Answer='No';
        oChoseIncentivePlanController.submitQuestionnairre();
        oChoseIncentivePlanController.selectedSelectionMethod= 'Manual';
        oChoseIncentivePlanController.question1Answer='No';
        oChoseIncentivePlanController.submitQuestionnairre();
        
        //goto step 3 in wizard
        oEnrollmentApplicationController.stepThree();
        
        //First insert Contact Records
        //TO DO: Send in full users once we are creating different users.
        List<User> lUser = new list<User>();
        lUser.add(mUsers.values()[0]);
        list<Contact> lContacts = INC_Utils_Testing.createContactRecords(lUser);
        insert lContacts;

        Map<id,list<Contact>> mapContactsByEP = new map<id,List<Contact>>();
        mapContactsByEP.put(oEnrollmentPlan.Id,lContacts);

        //Create participant records for EnrollmentPlan
        
        pageRef = Page.INC_EnrollmentParticipantEntry;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', oEnrollmentPlan.ID);
        INC_EnrollmentParticipantEntryController oEnrollmentParticipantEntryController = new INC_EnrollmentParticipantEntryController(new ApexPages.StandardController(oEnrollmentPlan));
        oEnrollmentParticipantEntryController = new INC_EnrollmentParticipantEntryController();
        list<INC_EnrollmentParticipantEntryController.CommentWrapper> lParticipants = oEnrollmentParticipantEntryController.listParticipant;
        lParticipants[0].participant.EmployeeName__c = lContacts[0].Id;
        lParticipants[0].participant.EnrollmentPlan__c = oEnrollmentPlan.ID;
        lParticipants[0].participant.TargetIncentivePoolAllocated__c = 25;//(oEnrollmentPlan.IncentivePlan__r.MinAllocationPer__c == 0 ? 15:oEnrollmentPlan.IncentivePlan__r.MinAllocationPer__c);
        lParticipants[0].participant.ParticipantCategory__c = 'Deputy Project Manager';
        oEnrollmentParticipantEntryController.partComments = 'Comments';
        oEnrollmentParticipantEntryController.listParticipant = lParticipants;
       //System.assert(oEnrollmentParticipantEntryController.save());
        oEnrollmentParticipantEntryController.SaveandRecalc();
        oEnrollmentParticipantEntryController.SaveAndContinue();
        oEnrollmentParticipantEntryController.rowNumber = 1;
        oEnrollmentParticipantEntryController.RemoveEP();
        
        //Validate participants where created and attached to enrollment plan.
        list<EnrollmentParticipant__c> lParticipantAssertCheck = [Select Id from EnrollmentParticipant__c where EnrollmentPlan__c =:oEnrollmentPlan.Id];
        //System.assert(lParticipantAssertCheck.size() > 0);
        
        
         //Submit Application from Wizard
        oEnrollmentApplicationController.submitFromWizard();

        //test other participant methods
        oEnrollmentParticipantEntryController.addBlankRow();
        oEnrollmentParticipantEntryController.addParticipant();
        oEnrollmentParticipantEntryController.Cancel();
        oEnrollmentParticipantEntryController.oEnrollmentPlan.ApplicationType__c = 'PAY';
        oEnrollmentParticipantEntryController.addBlankRow();
        oEnrollmentParticipantEntryController.oEnrollmentPlan.ApplicationType__c = 'CCR';
        oEnrollmentParticipantEntryController.addBlankRow();
        lParticipants = oEnrollmentParticipantEntryController.listParticipant;

        lParticipants[0].participant.CurrencyIsoCode = null;
        oEnrollmentParticipantEntryController.listParticipant = lParticipants;
       // System.assert(oEnrollmentParticipantEntryController.save());
        lParticipants[0].participant.CurrencyIsoCode = 'USD';
        lParticipants[0].participant.EmployeeName__c = null;
        oEnrollmentParticipantEntryController.listParticipant = lParticipants;
        oEnrollmentParticipantEntryController.save();
        //System.assert(!oEnrollmentParticipantEntryController.save());
        lParticipants[0].participant.EmployeeName__c = lContacts[0].Id;
        lParticipants[0].participant.TargetIncentivePoolAllocated__c = -1;
        oEnrollmentParticipantEntryController.listParticipant = lParticipants;
        oEnrollmentParticipantEntryController.oEnrollmentPlan.ApplicationType__c = 'ENR';
        oEnrollmentParticipantEntryController.save();
        lParticipants[0].participant.TargetIncentivePoolAllocated__c = 15;//(oEnrollmentPlan.IncentivePlan__r.MinAllocationPer__c == 0 ? 15:oEnrollmentPlan.IncentivePlan__r.MinAllocationPer__c);
        lParticipants[0].participant.EmployeeName__c = null;
        oEnrollmentParticipantEntryController.listParticipant = lParticipants;
       // System.Assert(oEnrollmentParticipantEntryController.listParticipant[0].participant.EmployeeName__c == null);
        oEnrollmentParticipantEntryController.save();
        //System.assert(oEnrollmentParticipantEntryController.save() == false);
        lParticipants[0].participant.ParticipantCategory__c = '';
        oEnrollmentParticipantEntryController.listParticipant = lParticipants;
        Test.startTest();
        oEnrollmentParticipantEntryController.save();
        //System.assert(oEnrollmentParticipantEntryController.save() == false);
        //Validate Enrollment app in Pending Approver 1 && Approval Process Exists

        list<EnrollmentPlan__c> lPlansApprovalAssert = [Select ID,EnrollmentStatus__c                                                  
                                                        From EnrollmentPlan__c where id =: oEnrollmentPlan.id];
        oEnrollmentPlan = lPlansApprovalAssert[0];

        //System.assertEquals(oEnrollmentPlan.EnrollmentStatus__c,'Pending Approver 1 Action');

        //find out if approval process exists. Will also use this list later to push app through approval
        //process
        list<ProcessInstance> existingApprovals = [SELECT Id, TargetObjectId,Status
                                            FROM ProcessInstance 
                                            WHERE TargetObjectId  =:oEnrollmentPlan.ID];
        //System.Assert(existingApprovals.size() > 0);

           
        //

        //test starting wizard.
               update oEnrollmentPlan;

             oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{oEnrollmentPlan.id})[0];
             oEnrollmentPlan.EnrollmentStatus__c = 'Pending PM Action';
             oEnrollmentApplicationController = new INC_EnrollmentApp_Controller(new ApexPages.StandardController(oEnrollmentPlan));
             oEnrollmentPlan.WizardStatus__c = 'Step 1';
        // 
             oEnrollmentApplicationController = new INC_EnrollmentApp_Controller(new ApexPages.StandardController(oEnrollmentPlan));
             oEnrollmentPlan.WizardStatus__c = 'Step 2';
          //   update oEnrollmentPlan;
             oEnrollmentApplicationController = new INC_EnrollmentApp_Controller(new ApexPages.StandardController(oEnrollmentPlan));
             oEnrollmentPlan.WizardStatus__c = 'Step 3';
            // update oEnrollmentPlan;
             oEnrollmentApplicationController = new INC_EnrollmentApp_Controller(new ApexPages.StandardController(oEnrollmentPlan));
             oEnrollmentApplicationController.checkStatus();
             oEnrollmentApplicationController.getUserType();
            // oEnrollmentApplicationController.proposeOptOut();
             oEnrollmentApplicationController.enableNextButton();
             oEnrollmentApplicationController.stepOne();
             oEnrollmentApplicationController.save();
            // oEnrollmentApplicationController.submit();
             //oEnrollmentApplicationController.finalRejectButton();
             oEnrollmentApplicationController.saveAndReturnToBudget();
             oEnrollmentApplicationController.chooseplan();
             oEnrollmentApplicationController.showAppMetrics();
             oEnrollmentApplicationController.reassignApprovers();
             oEnrollmentApplicationController.closeApplication();
             //oEnrollmentApplicationController.updateCommentsfromApprovals();
             oEnrollmentPlan.IncentivePlan__c = null;
             oEnrollmentApplicationController.oEnrollmentApp = oEnrollmentPlan;
             oEnrollmentApplicationController.stepThree();
             oEnrollmentPlan.EnrollmentStatus__c = 'Enrolled';
             oEnrollmentApplicationController.oEnrollmentApp = oEnrollmentPlan;
             oEnrollmentApplicationController.createChangeRequest();
             oEnrollmentPlan.EnrollmentStatus__c = 'Enrolled';
             oEnrollmentApplicationController.oEnrollmentApp = oEnrollmentPlan;
             //oEnrollmentApplicationController.createPaymentRequest();
           
             //oEnrollmentPlan = [Select id from EnrollmentPlan__c where ApplicationType__c = 'PAY'][0];
             oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{oEnrollmentPlan.id})[0];
             
             System.debug(logginglevel.error,'oEnrollmentPlan in Test: ' + oEnrollmentPlan.ApplicationType__c);
             oEnrollmentApplicationController = new INC_EnrollmentApp_Controller(new ApexPages.StandardController(oEnrollmentPlan));
           //  oEnrollmentApplicationController.submit();
             //oEnrollmentApplicationController.closeNoAwardApplication();
             INC_AssignApproversController assignController = new INC_AssignApproversController(new ApexPages.StandardController(oEnrollmentPlan));
             assignController.selectedID = oUser.Id;
             //assignController.AssignApprover1();
             //assignController.AssignApprover2();
             //assignController.AssignApprover3();
             //assignController.Cancel();
             //assignController = new INC_AssignApproversController(new ApexPages.StandardController(oEnrollmentPlan));
             //assignController.selectedID = oUser.Id;
             //assignController.AssignApprover1();
             //assignController.AssignApprover2();
             //assignController.AssignApprover3();
             assignController.save();
             assignController.Cancel();
             oEnrollmentPlan.ApplicationType__c = 'ENR';
             oEnrollmentPlan.EnrollmentStatus__c = 'Enrolled';
             update oEnrollmentPlan;
             oEnrollmentPlan.EnrollmentStatus__c = 'Rejected';
             System.Debug(logginglevel.error,'Rejected in test');
             update oEnrollmentPlan;
            Test.stopTest();                     

        }

        //TO DO: Assert formula fields for Enrollment Application
        //

		//TO DO: Change Value on Incentive Project
		//
		//TO DO: Requery Enrollment Application to Reassert formula field values
		//
		//

        //Validate Enrollment Plan Page
       /* 
        INC_EnrollmentApp_Controller oEnrollmentApplicationController = new INC_EnrollmentApp_Controller(new ApexPages.StandardController(oEnrollmentPlan));

        //Go to step two
        oEnrollmentApplicationController.stepone();
        
        //TO DO: Fulfill step two actions
        PageReference pageRef = Page.INC_Chose;
        Test.setCurrentPage(pageRef);
        pexPages.currentPage().getParameters().put('id', oEnrollmentPlan.ID);
        //Finalize Application
        oEnrollmentApplicationController.submitFromWizard(); */
    //}
    testMethod static void PP_TandMEnrollmentProcess2(){ 
        ECO_TriggerSettings__c setting = new ECO_TriggerSettings__c();
        setting.Name = 'INC_IncentiveProject_AllEvents';
        setting.isEnabled__c = true;
        insert setting;

        ECO_TriggerSettings__c setting2 = new ECO_TriggerSettings__c();
        setting2.Name = 'INC_EnrollmentPlan_AllEvents';
        setting2.isEnabled__c = true;
        insert setting2;

        User oUser = INC_Utils_Testing.createUser();

        insert oUser;
        
        //Group dtwGroup = INC_Utils_Testing.createPublicGroup('DTW Admins');
        //insert dtwGroup;
        System.runAs(oUser){
       
         Group dtwGroup = [Select ID from Group where Name = 'DTW Admins'][0];
        
        GroupMember gm = new GroupMember(UserOrGroupId = oUser.ID
                                         ,GroupID = dtwGroup.id);
        insert gm;

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
            lIncentiveProjectsToInsert[0].ProjectManager__c = oUser.ID;
            update lIncentiveProjectsToInsert;
            
            //Check if DTW Admin was assigned
            list<IncentiveProject__c> lAssertCheck = new list<IncentiveProject__c>([SELECT Id, DTWAdmin__c FROM IncentiveProject__c WHERE Id = :oIncentiveProject.Id]);
            //System.AssertEquals(lAssertCheck.get(0).DTWAdmin__c, oUser.Id);
            
            //User interacts with page and assigns project manager
            oIncentiveProject.ProjectManager__c = oUser.Id;
            
            //User hits save button
            update oIncentiveProject;
            
            //User interacts with button on incentive project to generate enrollment app
            INC_IncentiveProjectCreateEnrollment.createEnrollmentForm(oIncentiveProject.Id);
             INC_IncentiveProjectCreateEnrollment.reviveEnrollmentForm(oIncentiveProject.Id);

            //Check if Enrollment Plan was created
            list<EnrollmentPlan__c> lAssertCheckEnrollment = new list<EnrollmentPlan__c>([SELECT Id
                                                                                          FROM EnrollmentPlan__c WHERE IncentiveProject__c = :oIncentiveProject.Id]);
            //System.Assert(lAssertCheckEnrollment.size() > 0);

            EnrollmentPlan__c oEnrollmentPlan;
            oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{lAssertCheckEnrollment[0].Id})[0];

            PageReference pageRef = Page.INC_Chose;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', oEnrollmentPlan.ID);
            ID currentPageID = oEnrollmentPlan.id;
            INC_EnrollmentCommentController oCommentController = new INC_EnrollmentCommentController();
            
            ID rejectedRecTypeID = Schema.SObjectType.EnrollmentPlan__c.getRecordTypeInfosByName().get('Rejected Application').getRecordTypeId();
            oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{currentPageID})[0];
            oEnrollmentPlan.recordTypeID = rejectedRecTypeID;
            update oEnrollmentPlan;
            oCommentController = new INC_EnrollmentCommentController();
            oCommentController.saveComments();
            oCommentController.sMessage = 'message';     
            oCommentController.oEnrollComment.Reason_Codes__c = 'Other';
            oCommentController.saveComments();
            oCommentController.oEnrollComment.Comments__c = 'Test Comments';
            oCommentController.saveComments();
            oCommentController.oEnrollComment.Reason_Codes__c = 'Project in Litigation';
            oCommentController.saveComments();
            oEnrollmentPlan.ApplicationType__c = 'Pay';
            update oEnrollmentPlan;
            oCommentController = new INC_EnrollmentCommentController();
            oCommentController.oEnrollComment.Reason_Codes__c = 'Other';
            oCommentController.oEnrollComment.Comments__c = 'Test Comments';
            oCommentController.oEnrollComment.Reason_Codes__c = 'Project in Litigation';
            oCommentController.saveComments();

            INC_EnrollmentPlanProgressController oProgressController = new INC_EnrollmentPlanProgressController();
            oProgressController = new INC_EnrollmentPlanProgressController(new ApexPages.StandardController(oEnrollmentPlan));
            oProgressController.onLoad();
            oProgressController.updateCommentsfromApprovals();

            oEnrollmentPlan.EnrollmentStatus__c = 'Pending Approver 1 Action';
            oProgressController.oEnrollmentPlan = oEnrollmentPlan;
            oProgressController.setToolTips();
            oProgressController.getAggregatedProject();
            oProgressController.sProgressMessage = 'Message';

            //interim payment controller
            INC_EnrollPlanInterimPay_Controller oInterimPayController = new INC_EnrollPlanInterimPay_Controller(new ApexPages.StandardController(oEnrollmentPlan));
            oInterimPayController.addBlankRow();
            oInterimPayController.addPaymentLine();
            oInterimPayController.Cancel();
            Interim_Payment_Schedule__c payLine = oInterimPayController.listPayments[0];
            payLine.MileStone__c = '10%';
            payLine.PaymentDate__c = Date.newInstance(2015, 10, 24);
            oInterimPayController.listPayments[0] = payLine;
            oInterimPayController.save();
            payLine.Description__c = 'Description';
            oInterimPayController.partComments = 'Comments';
            oInterimPayController.SaveAndContinue();
            //oInterimPayController = new INC_EnrollPlanInterimPay_Controller(new ApexPages.StandardController(oEnrollmentPlan));
            //oInterimPayController.listPayments = null;
            //oInterimPayController.addBlankRow();
        }
        

    }

    /*
    testMethod static void PP_TandMEnrollmentProcess3(){
        ECO_TriggerSettings__c setting = new ECO_TriggerSettings__c();
        setting.Name = 'INC_IncentiveProject_AllEvents';
        setting.isEnabled__c = true;
        insert setting;

        ECO_TriggerSettings__c setting2 = new ECO_TriggerSettings__c();
        setting2.Name = 'INC_EnrollmentPlan_AllEvents';
        setting2.isEnabled__c = true;
        insert setting2;

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
       
        //Group dtwGroup = INC_Utils_Testing.createPublicGroup('DTW Admins');
        //insert dtwGroup;
        System.runAs(oUser){
        Group dtwGroup = [Select ID from Group where Name = 'DTW Admins'][0];
        
        GroupMember gm = new GroupMember(UserOrGroupId = oUser.ID
                                         ,GroupID = dtwGroup.id);
        insert gm;

        map<string, User> mUsers = new map<string, User>();
        
        mUsers.put('Approver1', oUser);
        mUsers.put('Approver2', oUser);
        mUsers.put('Approver3', oUser);
        mUsers.put('DTW Admin', oUser);
        
        //Inser routing rules master data
       //Inser routing rules master data
            map<string, RoutingMember__c> mRoutingMember = INC_Utils_Testing.createRoutingMemberRules(mUsers);
            
            list<RoutingMember__c> lRoutingMembers = mRoutingMember.Values();

            mUsers.put('Approver1',oUser2);
            mUsers.put('Approver2',oUser2);
            mUsers.put('Approver3',oUser2);
            mUsers.put('DTW Admin',oUser2);

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
            lIncentiveProjectsToInsert[0].ProjectManager__c = oUser.ID;
            update lIncentiveProjectsToInsert;
            
            Inc_Match.FindApprover1(lIncentiveProjectsToInsert);

            //Check if DTW Admin was assigned
            list<IncentiveProject__c> lAssertCheck = new list<IncentiveProject__c>([SELECT Id, DTWAdmin__c FROM IncentiveProject__c WHERE Id = :oIncentiveProject.Id]);
           // System.AssertEquals(lAssertCheck.get(0).DTWAdmin__c, oUser.Id);
            
            //User interacts with page and assigns project manager
            oIncentiveProject.ProjectManager__c = oUser.Id;
            
            //User hits save button
            update oIncentiveProject;
            
            //User interacts with button on incentive project to generate enrollment app
            INC_IncentiveProjectCreateEnrollment.createEnrollmentForm(oIncentiveProject.Id);

            //Check if Enrollment Plan was created
            list<EnrollmentPlan__c> lAssertCheckEnrollment = new list<EnrollmentPlan__c>([SELECT Id
                                                                                          FROM EnrollmentPlan__c WHERE IncentiveProject__c = :oIncentiveProject.Id]);
            //System.Assert(lAssertCheckEnrollment.size() > 0);

            EnrollmentPlan__c oEnrollmentPlan;
            oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{lAssertCheckEnrollment[0].Id})[0];

            PageReference pageRef = Page.INC_Chose;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', oEnrollmentPlan.ID);
            ID currentPageID = oEnrollmentPlan.id;
            INC_EnrollmentCommentController oCommentController = new INC_EnrollmentCommentController();
            id ineligibleQueue;
            List<Group> lGroups = [Select Id from Group where name='DTW Ineligible Queue' and Type = 'Queue'];
            if(lGroups != null && lGroups.size() > 0){
                ineligibleQueue = lGroups[0].id;
            }
            lIncentiveProjectsToInsert[0].OwnerID = ineligibleQueue;
            lIncentiveProjectsToInsert[0].ProjectManager__c = oUser.id;
            update lIncentiveProjectsToInsert;

            INC_IncentiveSearch_Controller oSearchController = new INC_IncentiveSearch_Controller();
            oSearchController.search();
            oSearchController.searchCriteria[0].Criteria = 'PM';
            oSearchController.searchCriteria[0].IncProj.ProjectManager__c = oUser.id;
            oSearchController.addRow();
            oSearchController.searchCriteria[1].Criteria = 'CN';
            oSearchController.searchCriteria[1].Value='HOTEL CIRCLE';
            oSearchController.addRow();
            oSearchController.searchCriteria[2].Criteria = 'PN';
            oSearchController.searchCriteria[2].Value='TOWN & COUNTRY RESORT';
            oSearchController.addRow();
            oSearchController.searchCriteria[3].Criteria = 'PNUM';
            oSearchController.searchCriteria[3].Value='60329917';
            oSearchController.addRow();
            System.Debug(logginglevel.error,'search criteria: ' + oSearchController.searchCriteria);
            oSearchController.searchCriteria[4].Criteria = 'OW';
            oSearchController.searchCriteria[4].Value = String.ValueOf(ineligibleQueue);
            oSearchController.search();
            System.Debug(logginglevel.error,'results: ' + oSearchController.lResults);
            //oSearchController.lResults[0].newOwner = oUser.id;
            //oSearchController.changeOwner();
            oSearchController.removeRow = 5;
            oSearchController.removeRow();
            oSearchController.removeRow = 4;
            oSearchController.removeRow();
            oSearchController.removeRow = 3;
            oSearchController.removeRow();
            oSearchController.removeRow = 2;
            oSearchController.removeRow();
            oSearchController.search();
            System.Debug(logginglevel.error,'results: ' + oSearchController.lResults);
            
            pageRef = Page.INC_EnrollmentApp;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', oEnrollmentPlan.ID);
            INC_ObjectFieldHistory_Controller oFieldHistory = new INC_ObjectFieldHistory_Controller();
            oEnrollmentPlan.ActualContingencyBudgetatSnapshot__c = 100;
            update oEnrollmentPlan;
            oEnrollmentPlan.ActualContingencyBudgetatSnapshot__c = 300;
            oEnrollmentPlan.ActualFringeBudgetatSnapshot__c = 800;
            oEnrollmentPlan.IncentivePlan__c = oIncentivePlanTemplate.ID;
            update oEnrollmentPlan;
            
            System.Debug(logginglevel.error, 'Enrollment plan Id: ' + oEnrollmentPlan.ID);
          
            oFieldHistory.myObject = (sObject)oEnrollmentPlan;
            oFieldHistory.recordLimit = null;
            oFieldHistory.Showmorenumber = 5;
            oFieldHistory.getobjectHistory();
            
            INC_ShowEnrollmentMetricsController oShowMetricsCotroller = new INC_ShowEnrollmentMetricsController();
            oShowMetricsCotroller.getPanelToRender();
            oShowMetricsCotroller.getEACvsBaseline();
            oShowMetricsCotroller.close();
            oShowMetricsCotroller.updateFlag();
            lIncentiveProjectsToInsert[0].ContractType__c = 'AMPS - Fixed Price';
            update lIncentiveProjectsToInsert;

            oShowMetricsCotroller = new INC_ShowEnrollmentMetricsController();
            System.Debug(logginglevel.error,'oUser id: ' + oUser.id);
            oEnrollmentPlan.Approver1__c = oUser.id;
            oEnrollmentPlan.Approver2__c = oUser.id;
            oEnrollmentPlan.Approver3__c = oUser.id;
            oEnrollmentPlan.isInWorkFlow__c = 'Yes';
            update oEnrollmentPlan;
            list<Contact> lContacts = INC_Utils_Testing.createContactRecords(new list<User>{oUser});
            insert lContacts;
            EnrollmentParticipant__c ep = new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.id,EmployeeName__c = lContacts[0].id);
            ep.targetIncentivePoolAllocated__c = 25;
            ep.ParticipantCategory__c = 'Dave';
            insert ep;
        
            INC_EnrollmentLetterController oEnrollmentLetterController = new INC_EnrollmentLetterController();
            oEnrollmentLetterController.epID = ep.id;
            System.debug(logginglevel.error,'oEnrollmentLetterController.oEp: ' + oEnrollmentLetterController.epID);
            System.Debug(logginglevel.error,'ep: ' + ep);
            oEnrollmentLetterController.getoCH();

            System.debug(logginglevel.error,'Updateing routing member in App Test');
            for(RoutingMember__c rt: mRoutingMember.Values()){
                rt.Approver1__c = oUser2.id;
                rt.Approver2__c = oUser2.id;
                rt.Approver3__c = oUser2.id;
                rt.DtwAdmin__c = oUser2.id;
            SYSTEM.debug(LoggingLevel.ERROR,'Routing Member: ' + rt);
            }
            System.debug(logginglevel.error,'ouser2: ' + oUser2.id);
            update mRoutingMember.Values();

            for(RoutingMember__c rt: mRoutingMember.Values()){
                rt.DTW_Approver_Group__c = 'DTW Southeast Approvers';
            SYSTEM.debug(LoggingLevel.ERROR,'Routing Member: ' + rt);
            }
            
            update mRoutingMember.values();


            oEnrollmentPlan.ExceptionComments__c = 'Comments';
            oEnrollmentPlan.Ma_Comments__c = 'Ma Comments';
            //update oEnrollmentPlan;

            //create a comment
            Enrollment_Comments__c ec = new Enrollment_Comments__c(Comments__c = 'Comment', EnrollmentApplication__c= oEnrollmentPlan.ID,Type__c='Management Adjustment',ApplicationType__c = oEnrollmentPlan.ApplicationType__c);
            insert ec;

            Interim_Payment_Schedule__c ip = new Interim_Payment_Schedule__c(EnrollmentApplication__c = oEnrollmentPlan.ID);
            insert ip;

            test.startTest();
            INC_Service_EnrollmentPlan.assignIneligibleQueue(lIncentiveProjectsToInsert);
            INC_Service_EnrollmentPlan.createEnrollmentComment(new list<EnrollmentPlan__c>{oEnrollmentPlan});
            map<id,IncentiveProject__c> mapProjects = new map<id,IncentiveProject__c>();
            mapProjects.put(lIncentiveProjectsToInsert[0].id,lIncentiveProjectsToInsert[0]);
            INC_Service_EnrollmentPlan.FindApprover1(mapProjects);
            INC_Service_EnrollmentPlan.updateBaselineChangedFlagforParticipants(new set<id>{oEnrollmentPlan.Id});
            INC_Service_EnrollmentPlan.CloneEnrollment(oEnrollmentPlan.ID,INC_Service_EnrollmentPlan.RequestType.Change);
            EnrollmentPlan__c oChangePlan = [Select id, ApplicationType__c from EnrollmentPlan__c where ApplicationType__c = 'CCR'][0];
            INC_Service_EnrollmentPlan.CloneEnrollment(oChangePlan.ID,INC_Service_EnrollmentPlan.RequestType.Change);
            oChangePlan.EnrollmentStatus__c = 'Enrolled';
            update oChangePlan;
            INC_Service_EnrollmentPlan.CloneEnrollment(oChangePlan.ID,INC_Service_EnrollmentPlan.RequestType.Payment);
            EnrollmentPlan__c oPayPlan = [Select id, ApplicationType__c from EnrollmentPlan__c where ApplicationType__c = 'PAY'][0];
            INC_Service_EnrollmentPlan.CloneEnrollment(oPayPlan.ID,INC_Service_EnrollmentPlan.RequestType.Payment);
            lPlanTemplates[0].ContractType__c = 'Fixed Price';
            update lPlanTemplates;
            update oEnrollmentPlan;
            test.stopTest();
        }

    }
*/


     // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().07
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   static testmethod void dtwAdminSchedule() {
        ECO_TriggerSettings__c setting = new ECO_TriggerSettings__c();
        setting.Name = 'INC_IncentiveProject_AllEvents';
        setting.isEnabled__c = true;
        insert setting;

        ECO_TriggerSettings__c setting2 = new ECO_TriggerSettings__c();
        setting2.Name = 'INC_EnrollmentPlan_AllEvents';
        setting2.isEnabled__c = true;
        insert setting2;

      Test.startTest();
      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP,
                        new INC_IncentiveDTWAdminSchedule());
          
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
 
      // Verify the expressions are the same
    //  System.assertEquals(CRON_EXP,
    //     ct.CronExpression);
      // Verify the job has not run
    //  System.assertEquals(0, ct.TimesTriggered);
      // Verify the next time the job will run
    //  System.assertEquals('2022-03-15 00:00:00',
    //  String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.
      Test.stopTest();
    
   }

}