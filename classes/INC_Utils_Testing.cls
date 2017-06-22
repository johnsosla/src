public without sharing class INC_Utils_Testing {
    
    public static OrganizationString__c createTestOrg(){
        return ECO_Utils_Testing.createTestOrg();
    }

    public static IncentiveProject__c createIncentiveProject(){
        Integer randomNumber = Integer.valueOf(Math.random()*1000);
        IncentiveProject__c Test_IncentiveProject = new IncentiveProject__c();
        Test_IncentiveProject.Name = 'MP' + randomNumber +'-PM CENTRAL SERVICE';
        Test_IncentiveProject.CustomerName__c = 'REGIONAL MUNICIPALITY OF YORK';
        
        return Test_IncentiveProject;
    }

    public static User createTestUser(String sProfileName){
        return ECO_Utils_Testing.createTestUser(sProfileName);
    }
 
    public static RoutingMember__c createRoutingMember(User DTW_Admin){
        RoutingMember__c member = new RoutingMember__c();
        member.DTWAdmin__c = DTW_Admin.ID;
        return member;
    }

    public static Group createPublicGroup(String sName){
        Group grp = new Group(Name=sName,
                              Type='Regular',
                              DeveloperName=sName.Replace(' ','_'));
        return grp;
    }

    public static list<OrganizationString__c> createOrganizationString(){

        List<OrganizationString__c> lOrgStrings = new List<OrganizationString__c>();
        OrganizationString__c Org1 = INC_Utils_Testing.createTestOrg();
        OrganizationString__c Org2 = INC_Utils_Testing.createTestOrg();
        Org1.Name = Org1.OrganizationName__c;
        Org1.Region__c = 'Test Region';

        Org2.OrganizationName__c = 'Water Organization';
        Org2.Name = 'Water Organization';
        Org2.BusinessLineName__c = 'Water';
        Org2.Department__c = 'Water Department';
        Org2.District__c = 'Water District';
        Org2.Description__c = 'Water org string';
        Org2.GeographyName__c = 'Water Geo';
        Org2.Region__c = 'Water Region';
        Org2.OrgID__c = '227';
        Org2.OUID__c = '999';

        return new list<OrganizationString__c>{Org1,Org2};

    }
    
    /**
     * This method is responsible for creating test Enrollment Application record
     */
    public static EnrollmentPlan__c createEnrollmentApplication(IncentiveProject__c incentiveProject) {
        EnrollmentPlan__c eP = new EnrollmentPlan__c();
        eP.RecordTypeId = Schema.SObjectType.EnrollmentPlan__c.getRecordTypeInfosByName().get('Edit Application').getRecordTypeId();
        eP.IncentiveProject__c = incentiveProject.Id;
        eP.Name = 'Test Enrollment Plan';
        eP.CurrencyIsoCode = 'USD';
        eP.EnrollmentStatus__c = 'Pending PM Action';
        return eP;
    }
    
    public static Contact createEmployee(){
        return createEmployee(true);
    }

    public static Contact createEmployee(boolean activeStatus) {
        User managerUser = INC_Utils_Testing.createUser();
        insert managerUser;
        
        User EmployeeUser = INC_Utils_Testing.createUser();
        EmployeeUser.Email = '2' + EmployeeUser.email;
        EmployeeUser.isActive = activeStatus;
        EmployeeUser.Username = '2' + EmployeeUser.Username;
        EmployeeUser.ManagerId = managerUser.Id;
        EmployeeUser.CommunityNickname = EmployeeUser.CommunityNickname + '2';
        EmployeeUser.FederationIdentifier = EmployeeUser.FederationIdentifier + '2';
        EmployeeUser.OracleEmployeeId__c = EmployeeUser.OracleEmployeeId__c + '2';
        EmployeeUser.TrackingID__c = EmployeeUser.TrackingID__c + '2';
        EmployeeUser.URS_FIM_GUID__c = EmployeeUser.URS_FIM_GUID__c + '2';
        insert EmployeeUser;
        User EmployeeUser2 = [Select id, IsActive from User where id =: EmployeeUser.id][0];
        System.Debug(logginglevel.error,'EmployeeUser Active: ' + EmployeeUser2.isActive);
        Account account = new Account();
        account.Name = 'AECOM Test';
        insert account;
        
        Contact contact = new Contact();
        contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('AECOM Employee').getRecordTypeId();
        contact.FirstName = 'FirstName';
        contact.LastName = 'LastName';
        contact.AccountId = account.Id;
        contact.Email = EmployeeUser.Email;
        contact.pse__Salesforce_User__c = EmployeeUser.Id;
        contact.User__c = EmployeeUser.ID;
        contact.Person_ID__c = '99999999';
        contact.Status__c = 'Active';                               
        
        return contact;        
    }
    
    public static EnrollmentParticipant__c createEnrollmentParticipant(EnrollmentPlan__c ePlan, Contact employee) {
        EnrollmentParticipant__c ePart = new EnrollmentParticipant__c();
        ePart.EnrollmentPlan__c = ePlan.Id;
        ePart.EmployeeName__c = employee.Id;
        ePart.ParticipantCategory__c = 'Technical Leader';
        ePart.TargetIncentivePoolAllocated__c = 25;
        
        return ePart;
    }
 
    public static IncentiveProject__c createIncentiveProject_TownAndCountry(){
        IncentiveProject__c oIncentiveProject = new IncentiveProject__c();
        
        //oIncent60329917iveProject.NoofParticipants__c = 1;
        //oIncentiveProject.X60DaysClosed__c = 'No';
        //oIncentiveProject.ActualContingencyBudgetITD__c = 0; Null
        oIncentiveProject.ActualPercentProjectCompleteITD__c = 62.74;
        oIncentiveProject.AcutalDirectLaborITD__c = 321092;
        oIncentiveProject.ActualLaborCostMultiplier__c = 2.8;
        oIncentiveProject.ActualDPEBudgetITD__c = 451964;
        oIncentiveProject.ActualFringeBudgetITD__c = 130872;
        oIncentiveProject.ActualGrossMarginITD__c = 447833;
        oIncentiveProject.ActualGrossRevenueITD__c = 1200000;
        oIncentiveProject.ActualNetMarginITD__c = 90799;
        //oIncentiveProject.ActualNMofNSRITD__c = 10.09;
        oIncentiveProject.ActualNSRITD__c = 899797;
        oIncentiveProject.ActualODCBudgetITD__c = 5969;
        oIncentiveProject.ActualOverheadITD__c = 357034;
        oIncentiveProject.ActualSubsBudgetITD__c = 95741;
        oIncentiveProject.ActualTotalCostsITD__c = 910708;
        //oIncentiveProject.AGGRAlerts__c = 0;
        //oIncentiveProject.AggregatedParentNumber__c = 0;
        //oIncentiveProject.Aggregated_Parent_Project__c = 0;
        oIncentiveProject.Aggregated_Project__c = 'No';
        //oIncentiveProject.AggregatorAutonumber__c = 0;
        //oIncentiveProject.AgreementAggregator__c = 60329917;
        //oIncentiveProject.AgreementNumber__c = 60329917; Need ID
        oIncentiveProject.ApprovedContingencyBudget__c = 1000; 
        oIncentiveProject.ApprovedDirectLaborBudget__c = 522033;
        oIncentiveProject.ApprovedDirectLaborMultiplier__c = 2.77;
        oIncentiveProject.ApprovedDPEBudget__c = 741286;
        oIncentiveProject.ApprovedFringeBudget__c = 219254;
        //oIncentiveProject.ApprovedGrossMarginofNSR__c = 69.68;
        oIncentiveProject.ApprovedGrossMarginBudget__c = 1703310;
        oIncentiveProject.ApprovedGrossRevenueBudget__c = 2496401;
        oIncentiveProject.ApprovedNetMarginBudget__c = 112476;
        //oIncentiveProject.ApprovedNMofNSR__c = 4.6;
        //oIncentiveProject.ApprovedNSRBacklog__c = 1544799;
        oIncentiveProject.ApprovedNSRBudget__c = 2443596;
        oIncentiveProject.ApprovedODCBudget__c = 76805;
        oIncentiveProject.ApprovedOverheadBudget__c = 590833;
        //oIncentiveProject.ApprovedSalaryCostMultiplier__c = 0; Null
        oIncentiveProject.ApprovedSubsBudget__c = 75000;
        oIncentiveProject.ApprovedCostBudget__c = 1483925;
        oIncentiveProject.BIEE__c = 66544;
        oIncentiveProject.BilledAR__c = 82439;
        oIncentiveProject.EndMarket__c = 'DP&E';
        //oIncentiveProject.ChangeRequest__c = 'a5xe00000008SoPAAU';
        oIncentiveProject.ContractType__c = 'T&M (with Cap)';
        //oIncentiveProject.ContractTypeShortName__c = 'Fixed PriceTime & Material';
        //oIncentiveProject.CountEnrollmentPlan__c = 1;
        //oIncentiveProject.CountofParticipants__c = 1;
        //oIncentiveProject.CRStatus__c = 'Pending Approver 1 Action';
        //oIncentiveProject.WorkflowOwner__c = 0; Null
        oIncentiveProject.CustomerName__c = 'HOTEL CIRCLE PROPERTY, LLC';
        //oIncentiveProject.DataRefreshDate__c = 0; Null
        //oIncentiveProject.DateSalesOutstandingITD__c = 0; Null
        oIncentiveProject.DistributionRule__c = 'COST/WORK';
        oIncentiveProject.DistrictDescription__c = 'Los Angeles Metro - AECOM';
        //oIncentiveProject.DTW_Complete__c = 62.74;
        oIncentiveProject.DTWAdminAttempted__c = TRUE;
        oIncentiveProject.DTWAdminInitiated__c = Date.newInstance(2015, 10, 24);
       // oIncentiveProject.DTWAdmin__c = '005a0000009IzepAAC';
        //oIncentiveProject.DTW_Admin_Status__c = 0; Null
        oIncentiveProject.EACasofDate__c = Date.newInstance(2015, 10, 1);
        //oIncentiveProject.EffectiveLoadDate__c = 0; Null
        //oIncentiveProject.EffectiveSentDate__c = 0; Null
        //oIncentiveProject.EligibleYN__c = 0; Null
        oIncentiveProject.EndMarket__c = 'Buildings & Places';
        //oIncentiveProject.EnrollmentPlan__c = 'a5xe00000008SoKAAU';
        //oIncentiveProject.EnrollmentApprover1__c = '005a0000009IzepAAC';
        //oIncentiveProject.EnrollmentStatus__c = 'Enrolled';
        //oIncentiveProject.EPStatusNumber__c = 6;
        //oIncentiveProject.EPURL__c = 'https://aecom--ecosysdev.cs15.my.salesforce.com/a5xe00000008SoK';
        //oIncentiveProject.FiscalPeriodNumber__c = 0; Null
        //oIncentiveProject.ForecastContingencyBudget__c = 0; Null
        oIncentiveProject.ForecastDirectLabor__c = 492384;
        oIncentiveProject.ForecastDirectLaborMultiplier__c = 2.79;
        oIncentiveProject.ForecastDPEBudget__c = 695378;
        oIncentiveProject.ForecastFringeBudget__c = 202993;
        //oIncentiveProject.ForecastGrossMarginofNSR__c = 49.39;
        oIncentiveProject.ForecastGrossMarginBudget__c = 678637;
        oIncentiveProject.ForecastNetMarginBudget__c = 144733;
        //oIncentiveProject.ForecastNMofNSR__c = 10.53;
        //oIncentiveProject.ForecastNSRBacklog__c = 474217;
        oIncentiveProject.ForecastNSRBudget__c = 1374014;
        oIncentiveProject.ForecastODCBudget__c = 71632;
        oIncentiveProject.ForecastOverheadBudget__c = 533903;
        oIncentiveProject.ForecastRevenueBudget__c = 1596401;
        //oIncentiveProject.ForecastSalaryCostMultiplier__c = 0; Null
        oIncentiveProject.ForecastSubsBudget__c = 150755;
        oIncentiveProject.ForecastCostBudget__c = 1451668;
        oIncentiveProject.FPPCompletionBacklogEligilbility__c = 'Yes';
        oIncentiveProject.FPPContractTypeEligibility__c = 'Yes';
        oIncentiveProject.FPPOverallEligibility__c = 'Yes';
        oIncentiveProject.FPPProjectSizeEligibility__c = 'Yes';
        oIncentiveProject.GeographyDescription__c = 'Pacific';
        oIncentiveProject.GMEACChange__c = 'No';
        oIncentiveProject.GRBacklog__c = 594894;
        //oIncentiveProject.IneligibleTextOld__c = 0; Null
        oIncentiveProject.IsClosed__c = 'Yes';
        oIncentiveProject.ITDDSO__c = 41;
        //oIncentiveProject.ActualGMofNSRITD__c = 49.77;
        //oIncentiveProject.LegalEntityDescription__c = 0; Null
        //oIncentiveProject.Location__c = 0; Null
        //oIncentiveProject.MetricWarning__c = 'Yes';
        //oIncentiveProject.NetARBalance__c = 0; Null
        //oIncentiveProject.OrganizationString__c = 0; Null
        //oIncentiveProject.ParentEnrollmentStatus__c = 0;
        //oIncentiveProject.PaymentRequest__c = 0; Null
        //oIncentiveProject.Pilot__c = 0; Null
        oIncentiveProject.ProjectAccountantEmail__c = 'stacy.mchargue@aecom.com';
        //oIncentiveProject.ProjectAccountant__c = 0; Null
        //oIncentiveProject.ProjectAccountantText__c = 0; Null
        oIncentiveProject.ProjectCreationDate__c = Date.newInstance(2014, 8, 13);
        oIncentiveProject.ProjectDirectorEmail__c = 'yara.fisher@aecom.com';
        //oIncentiveProject.ProjectDirector__c = 0; Null
        //oIncentiveProject.ProjectDirectorText__c = 0; Null
        oIncentiveProject.ProjectManagerEmail__c = 'christopher.kull@aecom.com';
        //oIncentiveProject.ProjectManagerEmpNo__c = 638020;
        //oIncentiveProject.ProjectManager__c = '005a0000009IzepAAC'; Null
        //oIncentiveProject.Project_ManagerText__c = 0; Null
        //oIncentiveProject.ProjectNameStatus__c = 'TOWN & COUNTRY RESORT - Approved';
        oIncentiveProject.ProjectNameText__c = 'TOWN & COUNTRY RESORT';
        oIncentiveProject.ProjectID__c = '60329917';
        oIncentiveProject.OrgCarryingOutProject__c = '41.ACM.USLAX1.0531';
        oIncentiveProject.ProjectStartDate__c = Date.newInstance(2014, 6, 20);
        oIncentiveProject.ProjectStatus__c = 'Approved';
        oIncentiveProject.FPPProjectStatusEligibility__c = 'Yes';
        //oIncentiveProject.PRStatus__c = 'N/A';
        //oIncentiveProject.ReplyTo__c = 'americasdtwincentiveplan@aecom.com';
        //oIncentiveProject.RoutingMemberRule__c = 'a6De0000000Ab4xEAC'; NULL
        oIncentiveProject.ScheduledFinishDate__c = Date.newInstance(2015, 10, 30);
        oIncentiveProject.RegionDescription__c = 'Los Angeles Metro';
        oIncentiveProject.SuperGeography__c = 'Americas';
        oIncentiveProject.TMPContractTypeEligibility__c = 'Yes';
        oIncentiveProject.TMPlanOverallEligibility__c = 'Yes';
        oIncentiveProject.TMPProjectSizeEligibility__c = 'Yes';
        //oIncentiveProject.TotalUnbilled__c = 0; Null
        oIncentiveProject.ACTUALGROSSREVENUEITD__C=1200000;
        oIncentiveProject.FORECASTREVENUEBUDGET__C=1596401;
        oIncentiveProject.APPROVEDGROSSREVENUEBUDGET__C=2496401;
        oIncentiveProject.ACTUALSUBSBUDGETITD__C=95741;
        oIncentiveProject.ACTUALODCBUDGETITD__C=5969;
        oIncentiveProject.ACTUALNSRITD__C=899797;
        oIncentiveProject.FORECASTNSRBUDGET__C=1374014;
        oIncentiveProject.APPROVEDNSRBUDGET__C=2543596;
        oIncentiveProject.ACTUALGROSSMARGINITD__C=447833;
        oIncentiveProject.FORECASTGROSSMARGINBUDGET__C=678637;
        oIncentiveProject.APPROVEDGROSSMARGINBUDGET__C=1703310;
        oIncentiveProject.ACTUALTOTALCOSTSITD__C=910708;
        oIncentiveProject.FORECASTCOSTBUDGET__C=1451668;
        oIncentiveProject.APPROVEDCOSTBUDGET__C=1483925;
        oIncentiveProject.ACTUALNETMARGINITD__C=90799;
        oIncentiveProject.FORECASTNETMARGINBUDGET__C=144733;
        oIncentiveProject.APPROVEDNETMARGINBUDGET__C=111476;
        oIncentiveProject.ACUTALDIRECTLABORITD__C=321092;
        oIncentiveProject.FORECASTDIRECTLABOR__C=492384;
        oIncentiveProject.APPROVEDDIRECTLABORBUDGET__C=522033;
        oIncentiveProject.FORECASTDIRECTLABORMULTIPLIER__C=2.79;
        oIncentiveProject.APPROVEDDIRECTLABORMULTIPLIER__C=2.77;
        oIncentiveProject.ACTUALFRINGEBUDGETITD__C=130872;
        oIncentiveProject.FORECASTFRINGEBUDGET__C=202993;
        oIncentiveProject.APPROVEDFRINGEBUDGET__C=219254;
        oIncentiveProject.FORECASTCONTINGENCYBUDGET__C=0;
        oIncentiveProject.TOTALUNBILLED__C=0;
        oIncentiveProject.BIEE__C=66544;
        oIncentiveProject.APPROVEDCONTINGENCYBUDGET__C=1000;
        oIncentiveProject.FORECASTODCBUDGET__C=71632;
        oIncentiveProject.FORECASTSUBSBUDGET__C=150755;
        oIncentiveProject.FORECASTDPEBUDGET__C=695378;
        oIncentiveProject.FORECASTOVERHEADBUDGET__C=533903;
        oIncentiveProject.APPROVEDODCBUDGET__C=85105;
        oIncentiveProject.APPROVEDSUBSBUDGET__C=97000;
        oIncentiveProject.APPROVEDDPEBUDGET__C=740286;
        oIncentiveProject.APPROVEDOVERHEADBUDGET__C=590833;
        oIncentiveProject.ACTUALOVERHEADITD__C=357034;
        oIncentiveProject.ACTUALLABORCOSTMULTIPLIER__C=2.8;
        oIncentiveProject.ITDDSO__C=41;
        return oIncentiveProject;
    }
    
    public static map<string, RoutingMember__c> createRoutingMemberRules(map<string, User> mUsers){
        map<string, RoutingMember__c> mRoutingMember = new map<string,RoutingMember__c>();

        RoutingMember__c oRoutingMember1 = new RoutingMember__c();
        
        //oRoutingMember1.A1Alert__c = 0
        //oRoutingMember1.A2Alert__c = 0
        //oRoutingMember1.A3Alert__c = 0
        //oRoutingMember1.App1Status__c = Active
        //oRoutingMember1.App2Status__c = Active
        //oRoutingMember1.App3Status__c = Active
        oRoutingMember1.Approver1__c = mUsers.get('Approver1').Id;
        oRoutingMember1.Approver2__c = mUsers.get('Approver2').Id;
        oRoutingMember1.Approver3__c = mUsers.get('Approver3').Id;
        //oRoutingMember1.Area__c = 0 NULL
        //oRoutingMember1.BusinessLineDescription__c = 0 NULL
        //oRoutingMember1.Description__c = 0 NULL
        oRoutingMember1.DistrictDescription__c = 'Los Angeles Metro - AECOM';
        oRoutingMember1.DTWAdmin__c = mUsers.get('DTW Admin').Id;
        oRoutingMember1.DTW_Approver_Group__c = 'DTW Northeast Approvers';
        //oRoutingMember1.FinanceManager__c = 0 NULL
        oRoutingMember1.GeographyDescription__c = 'Pacific';
        oRoutingMember1.GlobalDefault__c = FALSE;
        //oRoutingMember1.GlobalDefaultUnique__c = 0 NULL
        //oRoutingMember1.LegalEntityDescription__c = 0 NULL
        oRoutingMember1.RegionDescription__c = 'Los Angeles Metro';
        //oRoutingMember1.RoutingMemberTextUnique__c = 0 NULL
        //oRoutingMember1.SuperGeography__c = 0 NULL
        //oRoutingMember1.UniqueRoutingMemberFormula__c = PacificLos Angeles MetroLos Angeles Metro - AECOM

        mRoutingMember.put('LA Metro', oRoutingMember1);
        
        return mRoutingMember;
    }
    
    public static Id getProfileId(string sProfileName){
        list<Profile> lProfiles = new list<Profile>([SELECT Id FROM Profile WHERE Name = :sProfileName]);
    
        if(lProfiles.size() > 0){
            return lProfiles.get(0).Id;
        }
        
        return null;
    }
    
    public static List<IncentivePlanTemplate__c> createIncentivePlan(){
        list<IncentivePlanTemplate__c> lPlanTemplates = new list<IncentivePlanTemplate__c>();
        IncentivePlanTemplate__c oIncentivePlan = new IncentivePlanTemplate__c();
        
        oIncentivePlan.BaselineMetric__c = 'Gross margin dollars';
        //oIncentivePlan.DefaultBaselineThreshold__c = 0 NULL
        oIncentivePlan.EndDate__c = Date.newInstance(2018, 6, 9);
        oIncentivePlan.Estimated_Pool_Formula__c = 'MIN(200000 , 0.2*NSRBudget__c)';
        oIncentivePlan.GeographyAllocation__c = 'Americas';
        oIncentivePlan.HelpText__c = 'This plan rewards for organic growth on the enrolled project as measured by incremental gross margin earned above a predetermined baseline, which includes budgeted margin plus known or expected scope changes.  GM% of NSR at or better than a predetermined baseline must be achieved.  Gross margin is used as the financial metric when AECOM work is primarily completed by staff in one country.  Up to 5% of incremental margin is shared with plan participants.';
        //oIncentivePlan.InterimPlanPaymentEligibility__c = 0 NULL
        oIncentivePlan.ContractSubType__c = 'Gross Margin';
        //oIncentivePlan.MaxComplete__c = 0 NULL
        oIncentivePlan.MaxAllocationPool__c = 60;
        oIncentivePlan.MaxEACDays__c = 180;
        oIncentivePlan.MaxPool__c = 'Lesser of:  2% x NSR, or $200,000';
        oIncentivePlan.MaxPoolPercent__c = 0.02;
        oIncentivePlan.MaxPoolBaseline__c = 'Forecast NSR';
        //oIncentivePlan.MaxPoolCalculation__c = '(Forecast NSR x 2%) > (200000';
        oIncentivePlan.MaxPoolField2__c = 200000;
        //oIncentivePlan.MaxPoolField22__c = 0 NULL
        oIncentivePlan.MaxPoolOperator1__c = '>';
        oIncentivePlan.MaxPoolOperator__c = '>';
        oIncentivePlan.MaxPoolOperator2__c = '>';
        oIncentivePlan.MinAllocationAmount__c = 500;
        oIncentivePlan.MaxPoolCap__c = 200000;
        //oIncentivePlan.MinAllocationPer__c = 0 NULL
        oIncentivePlan.MinNSRBudget__c = 500000;
        //oIncentivePlan.OrgString__c = 0 NULL
        oIncentivePlan.ParticipantEligibility__c = 'Employees not part of AECOM\'s Annual Incentive Plan are eligible.';
        oIncentivePlan.PlanCriteria__c = '- Project Budget NSR > $500k\n- EAC updated within Last 90 days\n- Contract Type = T&M or CPFF or T&M w/Cap (see Top FAQs on the DTW webpage for other contract types)\n- AECOM work is primarily completed by staff in one country, and ANZ projects set up after';
        oIncentivePlan.ContractType__c = 'Time & Material';
        oIncentivePlan.ProfitSharingPercent__c = 5;
        oIncentivePlan.ProfitSharingDetails__c = '0.05';
        //oIncentivePlan.Region__c = 0 NULL
        //oIncentivePlan.ScheduledEndDateNotLessThanDays__c = 0 NULL
        oIncentivePlan.StartDate__c = Date.newInstance(2015, 1, 4);
        oIncentivePlan.Status__c = 'Active';
        oIncentivePlan.Threshold__c = 'Baseline';
        //oIncentivePlan.ThresholdPercent__c = 0 NULL
        oIncentivePlan.ThresholdBaseline__c = 'Gross Margin Dollars';
        //oIncentivePlan.ThresholdCalculation__c = 'Gross Margin Dollars';
        //oIncentivePlan.ThresholdOperator1__c = 0 NULL
        oIncentivePlan.VarianceAlert__c = 5;
        oIncentivePlan.Version__c = '1';
        
        lPlanTemplates.add(oIncentivePlan);
        
        //Fixed Price Template
        IncentivePlanTemplate__c oIncentivePlan2 = new IncentivePlanTemplate__c();
        oIncentivePlan2.BaselineMetric__c='Net margin % of NSR';
        oIncentivePlan2.CurrencyIsoCode='USD';
        oIncentivePlan2.DefaultBaselineThreshold__c=3;
        //oIncentivePlan2.IsDeleted=FALSE;
        oIncentivePlan2.EndDate__c = Date.newInstance(2018, 6, 9);
        oIncentivePlan2.Estimated_Pool_Formula__c='';
        oIncentivePlan2.GeographyAllocation__c='Americas';
        oIncentivePlan2.HelpText__c='This plan rewards for incremental net margin earned above a predetermined threshold, which is typically set at 2% above budgeted NM % of NSR.  This plan should be selected when the project leadership team has an opportunity to manage costs and risks in a way that generates incremental profitability for AECOM (e.g. through management of Direct Personnel Expenses).  Net margin percent is used as the financial metric for ANZ projects set up prior to November 2, 2015, and where AECOM work is performed by staff in multiple countries.  Up to 50% of incremental margin above the baseline is shared with plan participants.';
        oIncentivePlan2.Name='FP-NM-Americas Plan';
        oIncentivePlan2.InterimPlanPaymentEligibility__c='$10m or more Budgeted NSR and scheduled end date at least 3 years from time of Enrollment';
        oIncentivePlan2.ContractSubType__c='Net Margin';
        oIncentivePlan2.MaxComplete__c=85;
        oIncentivePlan2.MaxAllocationPool__c=60;
        oIncentivePlan2.MaxEACDays__c=90;
        oIncentivePlan2.MaxPool__c='3% x NSR x (1 - % complete at enrollment)';
        oIncentivePlan2.MaxPoolPercent__c=3;
        oIncentivePlan2.MaxPoolBaseline__c='Forecast NSR';
        //oIncentivePlan2.MaxPoolCalculation__c='(Forecast NSR x 3) x (1 -  Adjusted % Complete)';
        oIncentivePlan2.MaxPoolField2__c=1;
        oIncentivePlan2.MaxPoolField22__c='Adjusted % Complete';
        oIncentivePlan2.MaxPoolOperator__c='x';
        oIncentivePlan2.MaxPoolOperator1__c='x';
        oIncentivePlan2.MaxPoolOperator2__c='-';
        oIncentivePlan2.MinAllocationPer__c=1;
        oIncentivePlan2.MinAllocationAmount__c=2000;
        oIncentivePlan2.MinNSRBudget__c=500000;
        oIncentivePlan2.OrgString__c='';
        oIncentivePlan2.ParticipantEligibility__c='Employees not part of AECOM\'s Annual Incentive Plan are eligible.';
        oIncentivePlan2.PlanCriteria__c='- Project Budget NSR > $500k \n- Project % Complete <85% \n- EAC updated within Last 90 days\n- Contract Type = Fixed Price or T&M w/Cap (see Top FAQs on the DTW webpage for other contract types)\n- AECOM work is performed by staff in multiple countries, and ANZ projects set up prior November 2, 2015';
        oIncentivePlan2.ContractType__c='Fixed Price';
        oIncentivePlan2.ProfitSharingPercent__c=50;
        oIncentivePlan2.ProfitSharingDetails__c='3% x NSR x (1 - % complete )';
        oIncentivePlan2.Region__c='';
        oIncentivePlan2.ScheduledEndDateNotLessThanDays__c=120;
        oIncentivePlan2.StartDate__c = Date.newInstance(2015, 1, 4);
        oIncentivePlan2.Status__c='Active';
        oIncentivePlan2.Threshold__c='Baseline NM% + 2%';
        oIncentivePlan2.ThresholdPercent__c=0.02;
        oIncentivePlan2.ThresholdBaseline__c='Baseline NM % of NSR';
        //oIncentivePlan2.ThresholdCalculation__c='Baseline NM % of NSR + 2%';
        oIncentivePlan2.ThresholdOperator1__c='+';
        oIncentivePlan2.VarianceAlert__c=5;
        oIncentivePlan2.Version__c='1';
        lPlanTemplates.add(oIncentivePlan2);
        return lPlanTemplates;
    }
       
    public static User createUser(){
        User oUser = new User();

        Id sProfileId = INC_Utils_Testing.getProfileId('System Administrator');
        
        //oUser.IsActive = TRUE;
        oUser.ReceivesAdminInfoEmails = FALSE;
        oUser.Alias = 'TEST.Chr';
        oUser.ForecastEnabled = FALSE;
        oUser.ProfileId = sProfileId;
        //oUser.MobilePhone = 0; NULL
        oUser.DigestFrequency = 'N';
        oUser.CompanyName = 'AECOM';
        oUser.DefaultCurrencyIsoCode = 'USD';
        oUser.DefaultGroupNotificationFrequency = 'N';
        oUser.Department = '0278 - 41.CORP.SHARED SERVICES - RICHMOND';
        //oUser.Division = 0; NULL
        oUser.Email = 'christopher.kull@aecom.com';
        oUser.EmailEncodingKey = 'ISO-8859-1';
        //oUser.SenderEmail = 0; NULL
        //oUser.SenderName = 0; NULL
        //oUser.Signature = 0; NULL
        oUser.EmployeeNumber = '673899';
        //oUser.Extension = 0; NULL
        //oUser.Fax = 0; NULL
        oUser.ReceivesInfoEmails = FALSE;
        oUser.CurrencyIsoCode = 'USD';
        oUser.LanguageLocaleKey = 'en_US';
        oUser.LocaleSidKey = 'en_US';
        oUser.FirstName = 'Christopher';
        oUser.LastName = 'Kull';
        oUser.CommunityNickname = 'Christopher.Kull1.dtwtest';
        //oUser.Phone = 0; NULL
        //oUser.PortalRole = 0; NULL
        oUser.FederationIdentifier = 'Christopher.Kull@aecom.com.dtwtest';
        //oUser.StayInTouchNote = 0; NULL
        //oUser.StayInTouchSignature = 0; NULL
        //oUser.StayInTouchSubject = 0; NULL
        oUser.TimeZoneSidKey = 'America/New_York';
        oUser.Title = 'Project Billing Specialist III, Project Accounting';
        oUser.Username = 'christopher.kull@aecom.com.dtwtest';

        oUser.Adjusted_Service_Date__c = Date.newInstance(2012, 11, 12);
        //oUser.AD_MobilePhone__c = 0; NULL
        //oUser.AD_WorkPhone__c = 0; NULL
        //oUser.AECOM_Projects_Summary__c = 0; NULL
        oUser.AffectedByAECOM__c = TRUE;
        oUser.AffectedByURS__c = FALSE;
        //oUser.Allocation_Subcategory__c = 0; NULL
        oUser.AME_Akkurat_Font_user__c = FALSE;
        oUser.AssignmentCategory__c = 'Full Time';
        oUser.Assignment_Status__c = 'A';
        oUser.AssignmentUserStatus__c = 'A';
        oUser.Auto_Deactivation_Exception__c = FALSE;
        //oUser.Award_Summary__c = 0; NULL
        //oUser.Bio__c = 0; NULL
        oUser.Business_Card_Title__c = 'UNASSIGNED';
        oUser.Business_Line__c = 'Support/Cross Services';
        //oUser.Certification_Summary__c = 0; NULL
        //oUser.Certified_PM__c = 0; NULL
        oUser.Cisco_IP_Phone__c = '1034293';
        //oUser.Citizenship__c = 0; NULL
        oUser.CMC__c = FALSE;
        //oUser.Comment_on_User__c = 0; NULL
        oUser.Confidentiality_Agreement_Complete__c = FALSE;
        //oUser.Corporate_Title__c = 0; NULL
        oUser.CostRate__c = 1;
        //oUser.Date_of_Birth__c = 0; NULL
        //oUser.Date_Proxy_Added__c = 0; NULL
        //oUser.Date_Time_Sent_for_Review__c = 0; NULL
        //oUser.DEManager__c = 0; NULL
        oUser.District__c = 'NA - Corporate US (960)';
        oUser.DTWApplicationLevel__c = 'Corporate';
        //oUser.ECO_OUID__c = 0; NULL
        oUser.EcoBusinessGroup__c = 'Design and Consulting Services Group (DCS)';
        oUser.ECO_BusinessLine__c = 'Geography OH';
        oUser.ECO_Geography__c = 'NA - Mgmt';
        oUser.ECO_OrganizationName__c = '41.ACM.USNYC1.0278';
        oUser.ECO_Region__c = 'NA - Corporate US';
        //oUser.Education_Summary__c = 0; NULL
        //oUser.EffectiveEndDate__c = 0; NULL
        oUser.EffectiveStartDate__c = Date.newInstance(2012, 11, 12);
        oUser.Employee_Category__c = 'Non Exempt';
        oUser.ExpenditureType__c = 'LAB - Support Staff';
        oUser.F_A__c = FALSE;
        //oUser.Gender__c = 0; NULL
        oUser.Geography__c = 'Americas';
        oUser.Geography_Allocation__c = 'Americas';
        oUser.Global_Position_Title__c = 'Project Billing Specialist III, Project Accounting';
        oUser.HasDefaultApplicationsSet__c = FALSE;
        oUser.HR_Discipline__c = 'Project Accounting';
        oUser.HR_Full_Name__c = 'Kull, Christopher';
        oUser.HR_Job_Title__c = 'Project Billing Specialist III, Project Accounting';
        oUser.Interest_Regions__c = 'Europe';
        oUser.Interest_Relocating_Current_Country__c = 'Yes';
        oUser.Interest_Relocating_Different_Country__c = 'Yes';
        //oUser.International_Assignment_Status__c = 0; NULL
        oUser.isDoaAdmin__c = FALSE;
        oUser.Is_Profile_Locked__c = FALSE;
        oUser.IsValidGBSQueueMember__c = FALSE;
        oUser.Job_Family_Meaning__c = 'Finance and Accounting';
        oUser.JobName__c = 'ACCOUNTING CLERK.II.FINANCE/ACCOUNTING';
        //oUser.Languages_Summary__c = 0; NULL
        oUser.Last_Processed_Payroll_Run__c = Date.newInstance(2014, 12, 5);
        oUser.LeadVerifier__c = FALSE;
        oUser.Legal__c = FALSE;
        //oUser.LegalEntity__c = 0; NULL
        oUser.Length_of_Time_Abroad__c = '12 months to 5 years';
        //oUser.Manager_Email__c = 0;
        oUser.ManagerID__c = '660675';
        oUser.Manager_Name__c = 'McPherson, Stacy W';
        //oUser.ME_Go_NoGo_Approver__c = 0;
        //oUser.Middle_Names__c = 0;
        oUser.NA_GNG_Approver__c = FALSE;
        oUser.Resume_Name__c = 'Christopher Kull';
        //oUser.Names_Suffix__c = 0; NULL
        //oUser.Nationality__c = 0; NULL
        //oUser.No_Interest_Countries__c = 0; NULL
        //oUser.No_Interest_Regions__c = 0; NULL
        //oUser.Non_AECOM_Projects_Summary__c = 0; NULL
        oUser.Non_employee__c = FALSE;
        //oUser.NormalTransDateTime__c = 0; NULL
        oUser.Office__c = 'US - Arlington, VA - 2101 Wilson Boulevard - Suite 800';
        oUser.OfficeAddress1__c = '2101 Wilson Boulevard';
        oUser.OfficeAddress2__c = 'Suite 800';
        oUser.OfficeAddress3__c = 'UNASSIGNED';
        oUser.OfficeCity__c = 'Arlington';
        oUser.OfficeCountry__c = 'United States';
        oUser.OfficePostalCode__c = '22201';
        oUser.OfficeState__c = 'VA';
        oUser.OracleEmployeeId__c = '673899';
        oUser.Original_Hire_Date__c = Date.newInstance(2012, 11, 12);
        //oUser.PLManager__c = 0;
        oUser.PersonId__c = '357750';
        oUser.PersonType__c = 'Employee';
        //oUser.PL_Manager__c = 0; NULL
        //oUser.PM__c = 0; NULL
        //oUser.Preferred_Name__c = 0; NULL
        //oUser.Professional_Affiliation_Summary__c = 0; NULL
        //oUser.Profile_Proxy__c = 0; NULL
        //oUser.Profile_Reviewer__c = 0; NULL
        oUser.ProjectAccountantAuthority__c = FALSE;
        //oUser.Project_Approver__c = 0; NULL
        //oUser.Project_Director__c = 0; NULL
        oUser.ProjectManagerAuthority__c = FALSE;
        //oUser.Publication_Summary__c = 0; NULL
        //oUser.Region__c = Southeast; NULL
        //oUser.Registration_Summary__c = 0; NULL
        oUser.Rehire_Date__c = Date.newInstance(2012, 11, 12);
        //oUser.Service_Line__c = 0; NULL
        oUser.SF254_Summary__c = '[SF254 Discipline]: Administrative';
        oUser.SF330_Summary__c = '[SF330 Discipline]: Administrative';
        //oUser.ShaKey__c = 0; NULL
        oUser.Shared_Services_Is_Executive__c = FALSE;
        //oUser.smartSearchMyRecentlyViewed__c = 0; NULL
        //oUser.smartSearchMyRecentSearch__c = 0; NULL
        //oUser.Status__c = 0; NULL
        oUser.Sub_Business_Line__c = 'MGT - Group Mgmt';
        oUser.Supergeography__c = 'Americas';
        oUser.Resume_Title__c = 'Project Billing Specialist';
        oUser.TrackingID__c = '67389999';
        //oUser.Training_Summary__c = 0; NULL
        //oUser.Translations_Summary__c = 0; NULL
        oUser.URS_Employee__c = FALSE;
        //oUser.URS_Employee_Number__c = 0; NULL
        //oUser.URS_FIM_GUID__c = 0; NULL
        oUser.User_Name__c = 'KULLC';
        oUser.xxPMAccredited__c = FALSE;
        //oUser.Years_with_Other_Firms__c = 0 NULL;

        return oUser;
    }
    
    public static List<Contact> createContactRecords(List<User> testUsers){
       
        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');

        List<Contact> contacts = new List<Contact>();
        for(User testUser : testUsers){
            Contact testContact = new Contact();
            testContact.Email = testUser.Email;
            testContact.FirstName = testUser.FirstName;
            testContact.LastName =  testUser.LastName;
            testContact.Phone = '55555555555';
            testContact.pse__Salesforce_User__c = testUser.Id;
            testContact.RecordTypeId = recordTypeId;
            testContact.User__c = testUser.Id;
            
            contacts.add(testContact);
        }
        return contacts;
    }

    public static Map<ID,List<EnrollmentParticipant__c>> createParticipants(map<id,list<Contact>> mapContactsByEP){
        map<id,list<EnrollmentParticipant__c>> mapReturn = new map<id,list<EnrollmentParticipant__c>>();

        for(ID EnrollmentID : mapContactsByEP.Keyset()){
            list<EnrollmentParticipant__c> lTemp = new list<EnrollmentParticipant__c>();
            for(Contact testContact: mapContactsByEP.get(EnrollmentID)){
                lTemp.add(new EnrollmentParticipant__c(EmployeeName__c = testContact.Id,
                                                       EnrollmentPlan__c = EnrollmentID));
            }
            mapReturn.put(EnrollmentID,lTemp);
        }

        return mapReturn;
    }



























}