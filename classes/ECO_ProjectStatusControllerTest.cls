@isTest
private class ECO_ProjectStatusControllerTest {
    static testmethod void controllerTestMethod(){
    
        OrganizationString__c testOrg =  ECO_Utils_Testing.createTestOrg();
        insert testOrg;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        User testUser = new User();
        testUser.Alias = 'myuser';
        testUser.Email = 'mytestuser1@aecom.com';
        testUser.EmailEncodingKey ='UTF-8';

        testUser.FirstName = 'test';
        testUser.LastName ='Testing';
        testUser.LanguageLocaleKey ='en_US';
        testUser.LocaleSidKey ='en_US';
        testUser.ProfileId = p.Id;
        testUSer.TimeZoneSidKey ='America/Los_Angeles';
        testUser.UserName = 'mytestuser1@aecom.com';
        testUser.EmployeeNumber = '123';
        testUser.PersonId__c = '123';
        testUser.ECO_OrganizationName__c = testOrg.name;
        insert testUser;

        list<account> testAccounts = new list<account>();

        //Insert Test Account
        Account testAccount = new Account();
        testAccount.Name = 'test account';
        testAccount.OracleCustomerID__c = '1111';
        testAccounts.add(testAccount);
        insert testAccounts;

        List<OrganizationString__c> lOrgStrings = new List<OrganizationString__c>();
        OrganizationString__c Org1 = ECO_Utils_Testing.createTestOrg();
        Org1.OrganizationName__c = 'Test Organization';
        Org1.Name = 'Test Organization';
        Org1.BusinessLineName__c = 'test';
        Org1.Department__c = 'test Department';
        Org1.District__c = 'tet District';
        Org1.Description__c = 'test org string';
        Org1.GeographyName__c = 'test Geo';
        Org1.Region__c = 'test Region';
        Org1.OrgID__c = '111';
        Org1.OUID__c = '111';
        Org1.InactiveDate__c = null;
        Org1.ProjectOwning__c = true;

        lOrgStrings.add(Org1);

        insert lOrgStrings; 
        
        //team members
        ProjectRole__c projectRole = new ProjectRole__c();
        projectRole.Name = 'Project Manager';
        projectRole.Type__c = 'Key Member';
        projectRole.Active__c = true;

        ProjectRole__c projectRole1 = new ProjectRole__c();
        projectRole1.Name = 'Resilience Director';
        projectRole1.Type__c = 'Key Member';
        projectRole1.Active__c = true;

        ProjectRole__c projectRole2 = new ProjectRole__c();
        projectRole2.Name = 'Capture Manager';
        projectRole2.Type__c = 'Team Member';
        projectRole2.Active__c = true;
        
        ProjectRole__c projectRole3 = new ProjectRole__c();
        projectRole3.Name = 'Project Owner';
        projectRole3.Type__c = 'Team Member';
        projectRole3.Active__c = true;

        ProjectRole__c projectRole4 = new ProjectRole__c();
        projectRole4.Name = 'ORM Contact';
        projectRole4.Type__c = 'Team Member';
        projectRole4.Active__c = true;

        list<ProjectRole__c> lstpr = new list<ProjectRole__c>();
        lstpr.add(projectRole);
        lstpr.add(projectRole1);
        lstpr.add(projectRole2);
        lstpr.add(projectRole3);
        lstpr.add(projectRole4);
        insert lstpr;

        OrganizationString__c Org = [Select Id from OrganizationString__c Limit 1];
        System.debug('Org id::'+Org.Id);
        //create create source project 
        pse__Proj__c testProject = new pse__Proj__c();
        testProject.Name = 'test project 1';
        testProject.pse__Account__c = testAccount.Id;
        testProject.pse__Project_Type__c = 'Customer Project';
        testProject.pse__Billing_Type__c = 'Fixed Price';
        testProject.CurrencyIsoCode = 'USD';
        testProject.pse__Is_Active__c = true;   
        testProject.CarryingOutOrganization__c = Org.Id;
        testProject.ProgBarPrelimPlanApproval__c = 'NotStarted';
        testProject.pse__Stage__c = 'Planning';
        testProject.ProgressBarExecutionApproval__c = 'NotStarted';
        testProject.ProposalSubmittedDate__c = date.today();
        testProject.RM_Button_Clicked__c = false;
        ECO_Service_Delegation.run = false;
        test.startTest();
        insert testProject;
        test.stopTest();
        
        pse__Proj__c testProj = [select id, CarryingOutOrganization__c from pse__Proj__c limit 1];
        System.debug('testProj org:::'+testProj.CarryingOutOrganization__c);
        PageReference pageRef = new PageReference('/apex/ECO_ProjectStatus');
        test.setCurrentPage(pageRef);
        
        ECO_ProjectStatusController con = new ECO_ProjectStatusController(new ApexPages.StandardController(testProj));
        //system.assertEquals(testProj, con.currentProject);
        RecordType rt = new RecordType();
        rt = [Select Id From RecordType Where DeveloperName = 'PerformanceReview' and SobjectType = 'ProjectReview__c' LIMIT 1];
        
        List <ProjectReview__c> prList= new List <ProjectReview__c>();
        ProjectReview__c pr1 = new ProjectReview__c(Project__c = testProj.Id, RecordTypeId = rt.Id, Status__c ='NotStarted');
        ProjectReview__c pr2 = new ProjectReview__c(Project__c = testProj.Id, RecordTypeId = rt.Id, Status__c ='Assessing');
        ProjectReview__c pr3 = new ProjectReview__c(Project__c = testProj.Id, RecordTypeId = rt.Id, Status__c ='Approved');
        ProjectReview__c pr4 = new ProjectReview__c(Project__c = testProj.Id, RecordTypeId = rt.Id, Status__c ='Rejected');
        
        RecordType rtHealth = new RecordType();
        rtHealth = [Select Id From RecordType Where DeveloperName = 'HealthyStart' and SobjectType = 'ProjectReview__c' LIMIT 1];
        List <ProjectReview__c> prListH= new List <ProjectReview__c>();
        ProjectReview__c prH = new ProjectReview__c(Project__c = testProj.Id, RecordTypeId = rtHealth.Id, Status__c ='Approved');
        ProjectReview__c prH2 = new ProjectReview__c(Project__c = testProj.Id, RecordTypeId = rtHealth.Id, Status__c ='Rejected');
        //prListH.add(prH);
        //prListH.add(prH2);
        //insert prListH;
        
        RecordType rtKick = new RecordType();
        rtKick = [Select Id From RecordType Where DeveloperName = 'ProjectKickoff' and SobjectType = 'ProjectReview__c' LIMIT 1];
        //List <ProjectReview__c> prListK= new List <ProjectReview__c>();
        ProjectReview__c prK = new ProjectReview__c(Project__c = testProj.Id, RecordTypeId = rtKick.Id, Status__c ='Approved');
        ProjectReview__c prK2 = new ProjectReview__c(Project__c = testProj.Id, RecordTypeId = rtKick.Id, Status__c ='Rejected');
        //prListH.add(prK);
        //prListH.add(prK2);
        //insert prListH;
        prList.add(pr1);
        prList.add(pr2);
        prList.add(pr3);
        prList.add(pr4);
        prList.add(prH);
        prList.add(prH2);
        prList.add(prK);
        prList.add(prK2);
        insert prList;
       
        String locResilience = con.locationsResilienceStatus;
        // xxCity__c city = new xxCity__c(Name = 'testingCity');
        
        ProjectCity__c pCity = new ProjectCity__c(Project__c = testProj.Id);
       // insert city;
        insert pCity;
        
        String rmAssess = con.rmAssessStatus;
        String rmAssessDecision = con.rmAssessDecisionStatus;
        QuestionnaireSet__c qSet2 = new QuestionnaireSet__c(Project__c = testProj.Id, ApprovalStatus__c = 'Approved', GoNoGoRecommendation__c = 'Go');
        QuestionnaireSet__c qSet1 = new QuestionnaireSet__c(Project__c = testProj.Id, ApprovalStatus__c = 'Approved', GoNoGoRecommendation__c = 'Go');
        //qSet1.ApprovalStatus__c = 'Approved';
        //QuestionnaireSet__c qSet3 = new QuestionnaireSet__c(Project__c = testProj.Id, ApprovalStatus__c = 'Approved', GoNoGoRecommendation__c = 'Go');
        List<QuestionnaireSet__c> lRMA = new List<QuestionnaireSet__c> ();
        /*insert qSet1;
        rmAssess = con.rmAssessStatus;
        insert qSet2;
        qSet1.ApprovalStatus__c = 'Complete';
        update qSet1;
        rmAssess = con.rmAssessStatus;
        rmAssessDecision = con.rmAssessDecisionStatus;*/
        lRMA.add(qSet1);
        lRMA.add(qSet2);
        //lRMA.add(qSet3);
        
        //test.stopTest();
        //insert qSet1;
        
        System.debug('rmAssessDecision::::'+rmAssessDecision);
        String goNogo = con.goNoGoStatus;
        String doaManager = con.doaManagerStatus;
        DOAApprovalRequest__c doa = new DOAApprovalRequest__c(Project__c = testProj.Id, ApprovalStatus__c='Submitted');
        
        insert lRMA;
        insert doa;
        
        rmAssess = con.rmAssessStatus;
        goNogo = con.goNoGoStatus;
        rmAssessDecision = con.rmAssessDecisionStatus;
        /*qSet1.ApprovalStatus__c = 'Approved';
        ECO_QuestionnaireSet_TriggerDispatcher.run = false;
        update qset1;
        rmAssessDecision = con.rmAssessDecisionStatus;*/
        DOARegister__c doar1 = new DOARegister__c(Project__c = testProj.Id, DOAApprovalRequest__c = doa.Id);
        DOARegister__c doar2 = new DOARegister__c(Project__c = testProj.Id, DOAApprovalRequest__c = doa.Id);
        DOARegister__c doar3 = new DOARegister__c(Project__c = testProj.Id, DOAApprovalRequest__c = doa.Id);
        
        /*insert doar2;
        doaManager = con.doaManagerStatus;
        doa.ApprovalStatus__c = 'Rejected';
        update doa;
        insert doar3;
        doaManager = con.doaManagerStatus;
        doa.ApprovalStatus__c = 'Approved';
        update doa;
        insert doar1;*/
        
        List<DOARegister__c> lDOAR = new List<DOARegister__c>();
        lDOAR.add(doar1);
        lDOAR.add(doar2);
        lDOAR.add(doar3);
        insert lDOAR;
        doaManager = con.doaManagerStatus;    
            
        //System.assertEquals('Complete', con.rmAssessDecisionStatus);
        String preliminaryProjectPlan = con.preliminaryProjectPlan;
        //String submitBidStatus = con.submitBidStatus;
        //String projInitiationStatus = con.projInitiationStatus;
        //String projExecMonitorStatus = con.projExecMonitorStatus;
        //String executeApprovalStatus = con.executeApprovalStatus;
        String executeApprovalStatus = con.executeApprovalStatus;
        String planApprovalStatus = con.planApprovalStatus;
        testProj.ProgBarPrelimPlanApproval__c = 'Complete';
        testProj.isConverted__c = true;
        //test.startTest();
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_TriggerSettings.overrideTriggerSetting('Proj_ALL', false);

        update testProj;

        //test.stopTest();
        con.currentProject = testProj;
        planApprovalStatus = con.planApprovalStatus;
        //System.assertEquals('Complete', con.planApprovalStatus);
        
        String contractReview = con.contractReviewStatus;
        RecordType rtAgrement = [Select Id From RecordType Where DeveloperName = 'Prime' AND SobjectType = 'Agreement__c' LIMIT 1];
        Agreement__c agr1 = new Agreement__c(Project__c = testProj.Id, AgreementStatus__c = 'Executed', RecordTypeId = rtAgrement.Id );
        Agreement__c agr2 = new Agreement__c(Project__c = testProj.Id, AgreementStatus__c = 'In Review', RecordTypeId = rtAgrement.Id);
        List<Agreement__c> lAGR = new List<Agreement__c>();
        lAGR.add(agr1);
        lAGR.add(agr2);
        ECO_Service_Delegation.run = false;
        ECO_TriggerSettings.overrideTriggerSetting('AGREEMENT_segmentationApproval', false);
        insert lAGR;
        //test.stopTest();
        contractReview = con.contractReviewStatus;
        String negotiationProjectPlan = con.negotiationProjectPlan;
        String submitBidStatus = con.submitBidStatus;
        
        //testProj.pse__Stage__c = 'Execution';
        //update testProj;
        con.currentProject = testProj;
        
        executeApprovalStatus = con.executeApprovalStatus;
        String projInitiationStatus = con.projInitiationStatus;
        String submitExecutionButtonStatus = con.submitExecutionButtonStatus;
        String projExecMonitorStatus = con.projExecMonitorStatus;
        //String preliminaryProjectPlanApprovalStatus = con.preliminaryProjectPlanApprovalStatus;
        String scopeApproachStatus = con.scopeApproachStatus;
        String riskRegisterStatus = con.riskRegisterStatus;
        String reviewMeetingStatus = con.reviewMeetingStatus;
        String assumptionStatus = con.assumptionStatus;
        String scheduleWBSStatus = con.scheduleWBSStatus;
        String deliverableStatus = con.deliverableStatus;
        String budgetStatus = con.budgetStatus;
        BudgetHeader__c bh = new BudgetHeader__c(Project__c = testProj.Id, Status__c ='Approved');
        BudgetHeader__c bh2 = new BudgetHeader__c(Project__c = testProj.Id, Status__c ='Forecast');
        List<BudgetHeader__c> lBH = new List<BudgetHeader__c>();
        lBH.add(bh);
        lBH.add(bh2);
        ECO_BudgetHeaderTriggers.run = false;
        insert lBH;
        budgetStatus = con.budgetStatus;
        
        String documentMgmtStatus = con.documentMgmtStatus;
        String agreementStatus = con.agreementStatus;
        String safeHealthEnvStatus = con.safeHealthEnvStatus;
        String healthyStartStatus = con.healthyStartStatus;
        /*RecordType rtHealth = new RecordType();
        rtHealth = [Select Id From RecordType Where DeveloperName = 'HealthyStart' and SobjectType = 'ProjectReview__c' LIMIT 1];
        List <ProjectReview__c> prListH= new List <ProjectReview__c>();
        ProjectReview__c prH = new ProjectReview__c(Project__c = testProj.Id, RecordTypeId = rtHealth.Id, Status__c ='Approved');
        ProjectReview__c prH2 = new ProjectReview__c(Project__c = testProj.Id, RecordTypeId = rtHealth.Id, Status__c ='Rejected');
        prListH.add(prH);
        prListH.add(prH2);*/
                
        String projectKickOffStatus = con.projectKickOffStatus;
        /*RecordType rtKick = new RecordType();
        rtKick = [Select Id From RecordType Where DeveloperName = 'ProjectKickoff' and SobjectType = 'ProjectReview__c' LIMIT 1];
        //List <ProjectReview__c> prListK= new List <ProjectReview__c>();
        ProjectReview__c prK = new ProjectReview__c(Project__c = testProj.Id, RecordTypeId = rtKick.Id, Status__c ='Approved');
        ProjectReview__c prK2 = new ProjectReview__c(Project__c = testProj.Id, RecordTypeId = rtKick.Id, Status__c ='Rejected');
        prListH.add(prK);
        prListH.add(prK2);
        insert prListH;
        projectKickOffStatus = con.projectKickOffStatus;
        healthyStartStatus = con.healthyStartStatus;*/
        
        System.debug('org strig:::'+ testProj.CarryingOutOrganization__c );
        String classificationStatus = con.classificationStatus;
        String projTeamStakeStatus = con.projTeamStakeStatus;
        String subsVendorStatus = con.subsVendorStatus;
        String changeMgmtStatus = con.changeMgmtStatus;
        
        String earnedValueStatus = con.earnedValueStatus;
        Date todayDate = date.today();
//        Date startDate = todayDate.toStartOfWeek();
        Date startDate = ECO_Service_Snapshots.getFirstDateOfWeek(todayDate);

        //List<EarnedValueHeader__c> lEarnedVal = new List<EarnedValueHeader__c>([Select id, SnapshotDate__c, Committed__c From EarnedValueHeader__c Where SnapshotDate__c =:startDate AND Project__c =:currentProject.id]);
        EarnedValueHeader__c ev = new EarnedValueHeader__c(Project__c = testProj.Id, SnapshotDate__c = startDate);
        insert ev;
        earnedValueStatus = con.earnedValueStatus;
        String monthlyReviewStatus = con.monthlyReviewStatus;
        String performanceDashboardStatus = con.performanceDashboardStatus;
        String projectCloseHoldStatus = con.projectCloseHoldStatus;
        String projectCloseButtonStatus = con.projectCloseButtonStatus;
        List <ChangeManager__c> cmList = new List<ChangeManager__c>();
        ChangeManager__c cm1 = new ChangeManager__c(Project__c = testProj.Id, IntExtProjectClosure__c = true, ApprovalStatus__c = 'Submitted');
        ChangeManager__c cm2 = new ChangeManager__c(Project__c = testProj.Id, IntExtProjectClosure__c = true, ApprovalStatus__c = 'Submitted');
        cmList.add(cm1);
        cmList.add(cm2);
        ECO_ChangeManagerTriggerHandler.run = false;
        insert cmList;
        projectCloseButtonStatus = con.projectCloseButtonStatus;
        projectCloseHoldStatus = con.projectCloseHoldStatus;
        
        con.healthyStartClicked();
        con.submitPlanApprovalDummy();
        con.submitPlanApproval();
        con.escalateApproval();
        
        //System.debug('rmAssessDecision::::'+rmAssessDecision);

        ECO_Project_TeamMember_Triggers.run = false;
        ProjectRole__c projectRolePA = new ProjectRole__c();
        projectRolePA.Name = 'Project Approver';
        projectRolePA.Type__c = 'Key Member';
        projectRolePA.Active__c = true;
        insert projectRolePA;
        Contact contact = new Contact(
                    FirstName='cm First', 
                    LastName='cm Last', 
                    Email='cm@nowhere.com'
                );
        insert contact;
        
        /*
        ProjectTeamMember__c teamMember = new ProjectTeamMember__c(
                    Contact__c = contact.Id, 
                    ProjectRole__c = projectRolePA.Id, 
                    Project__c = testProj.Id, 
                    Status__c = 'Approved',
                    StartDate__c = Date.today().addDays(-1));
                insert teamMember;
                */
        String sTeamApprovedCheckStatus = con.sTeamApprovedCheck;
    }
}