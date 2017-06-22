public class ECO_Utils_Testing {
    
    public static list<ProjectRole__c> createProjectRoles(){
        list<ProjectRole__c> lstPR = new list<ProjectRole__c>();
        lstPR.add(new ProjectRole__c(Name = 'Project Approver 2', Active__c = true, SortOrder__c = 1, Type__c = 'Key Member'));
        lstPR.add(new ProjectRole__c(Name = 'Finance Lead', Active__c = true, SortOrder__c = 2, Type__c = 'Key Member'));
        lstPR.add(new ProjectRole__c(Name = 'CFO or Delegate', Active__c = true, SortOrder__c = 3, Type__c = 'Key Member'));
        lstPR.add(new ProjectRole__c(Name = 'Project Approver', Active__c = true, SortOrder__c = 4, Type__c = 'Key Member'));
        lstPR.add(new ProjectRole__c(Name = 'Project Accountant 2', Active__c = true, SortOrder__c = 5, Type__c = 'Key Member'));
        lstPR.add(new ProjectRole__c(Name = 'Finance Lead 2', Active__c = true, SortOrder__c = 6, Type__c = 'Key Member'));
        lstPR.add(new ProjectRole__c(Name = 'Project Accountant', Active__c = true, SortOrder__c = 7, Type__c = 'Key Member'));
        lstPR.add(new ProjectRole__c(Name = 'Project Manager', Active__c = true, SortOrder__c = 8, Type__c = 'Key Member'));
        lstPR.add(new ProjectRole__c(Name = 'Resilience Director', Active__c = true, SortOrder__c = 9, Type__c = 'Key Member'));
        lstPR.add(new ProjectRole__c(Name = 'Capture Manager', Active__c = true));
        lstPR.add(new ProjectRole__c(Name = 'Project Owner'));
        lstPR.add(new ProjectRole__c(Name = 'Project Worker', Active__c = true));
        lstPR.add(new ProjectRole__c(Name = 'Deliverable Approver', Active__c = true));
        lstPR.add(new ProjectRole__c(Name = 'Go/No Go Approver', Active__c = true));
        lstPR.add(new ProjectRole__c(Name = 'Other', Active__c = true));
        insert lstpr;

        return lstPR;
    }

    public static User createTestUser (String profileName) {
        Id profileId = ECO_Utils_Meta.getProfileId(profileName);
        
        Integer randomNumber = Integer.valueOf(Math.random()*1000);
        Integer randomNumber2 = Integer.valueOf(Math.random()*1000);
        
        User u = new User();
        u.FirstName = randomNumber + 'tuser';
        u.LastName = randomNumber + 'tuser';
        u.Email = randomNumber + 'tuser' + '.' +randomNumber2 + 'tuser_consultant' + '@aecom.co';
        u.Username =  randomNumber + 'tuser' + '.' +randomNumber2 + 'tuser' + '@aecom.co' + '.test';
        u.CommunityNickname = randomNumber + '' + randomNumber2 + 'tuser';
        u.Alias = randomNumber + '' + randomNumber2;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = profileId;
        u.LanguageLocaleKey = 'en_US';
        u.ECO_BusinessLine__c = 'Construction';
        u.ECO_Geography__c = 'United States';
        u.ECO_Region__c = '3';
        u.ECO_OrgId__c = '117';
        u.ECO_OUID__c = '147';
        return u;
    }

    public static void createTestDataForProjectSync(Integer numTestProjectTasks, Integer numTeamMembers){
        ECO_Service_DirtyScope.run = false;
        ECO_ProjectTriggers.syncProjectToOpportunity = true;

        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');

        Account testAccount = new Account();
        testAccount.Name = 'test Account';
        testAccount.OracleCustomerID__c = '123456';
        testAccount.OracleCustomerNumber__c = '999999';

        insert testAccount;

        OrganizationString__c testOrg = createTestOrg();
        insert testOrg;

        //create pm     
        Contact pm = new Contact();
        pm.Email = 'pm@test.ca';
        pm.FirstName = 'test';
        pm.LastName =  'pm';
        pm.Phone = '55555555555';
        pm.user__c = UserInfo.getUserId();
        //pm.RecordTypeId = recordTypeId;
        insert pm;  
    
        //team members
        ProjectRole__c projectRole = new ProjectRole__c();
        projectRole.Name = 'Project Manager';
        projectRole.Type__c = 'Key Member';
        projectRole.Active__c = true;

        ProjectRole__c projectCMRole = new ProjectRole__c();
        projectCMRole.Name = 'Capture Manager';
        projectCMRole.Type__c = 'Key Member';
        projectCMRole.Active__c = true;

        ProjectRole__c projectRole1 = new ProjectRole__c();
        projectRole1.Name = 'Resilience Director';
        projectRole1.Type__c = 'Key Member';
        projectRole1.Active__c = true;

        ProjectRole__c projectRole2 = new ProjectRole__c();
        projectRole2.Name = 'Project Owner';
        projectRole2.Type__c = 'Key Member';
        projectRole2.Active__c = true;

        list<ProjectRole__c> lstpr = new list<ProjectRole__c>();
        lstpr.add(projectRole);
        lstpr.add(projectRole1);
        lstpr.add(projectCMRole);
        lstpr.add(projectRole2);
        insert lstpr;
    
        opportunity oOpportunityToInsert = new opportunity();
        oOpportunityToInsert.name = 'Happy Test Opportunity';
        oOpportunityToInsert.Stagename = '1 Lead';
        oOpportunityToInsert.probability = 100;
        oOpportunityToInsert.accountid = testAccount.Id;
        oOpportunityToInsert.TO_Procurement_Method__c = 'Competitive Task Orders';
        oOpportunityToInsert.Capture_Manager_User__c = UserInfo.getUserId();
        oOpportunityToInsert.closeDate = Date.today();
        oOpportunityToInsert.Estimated_work_start_date__c = Date.today();
        oOpportunityToInsert.ValidateGo__c = false;
        insert oOpportunityToInsert;

        //create create source project      
        pse__Proj__c testProject = createTestProject('test project 1');
        //testProject.PrimaryOrganization__c = testOrg.Id;
        testProject.CarryingOutOrganization__c = testOrg.Id;
        testProject.pse__Account__c = testAccount.Id;
        //set some oracle classification fields
        testProject.clACLOfficeLocation__c = 'CAN - Burnaby';
        testProject.clBillableWorkersComp__c = 'Yes';
        testProject.pse__Project_Manager__c = pm.Id;
        testProject.pse__Opportunity__c = oOpportunityToInsert.id;
        insert testProject;

        //tasks
        List<pse__Project_Task__c> testProjectTasks = new List<pse__Project_Task__c>();
        for(Integer i =0; i<numTestProjectTasks; i++){
            pse__Project_Task__c task = new pse__Project_Task__c();
            task.Name = 'task' + i;
            //task.FinancialTask__c = true;
            task.pse__Project__c = testProject.Id;
            task.pse__Start_Date_Time__c = DateTime.now().addDays(i);
            task.pse__End_Date_Time__c = DateTime.now().addDays(i+1);
            task.pse__Status__c = 'Draft';
            task.ProjectTaskNumber__c = 'tasknumber' + i;
            task.pse__Description__c = 'task' + i + 'longname';
            task.WorkTypeName__c = 'Home Office';
            task.CostIndRateSCHID__c = '6748';

            testProjectTasks.add(task);
        }
            
        insert testProjectTasks;

        Integer randomNumber = Integer.valueOf(Math.random()*1000);
        Integer randomNumber2 = Integer.valueOf(Math.random()*1000);

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User testManager = new User();
        testManager.Alias = 'manager';
        testManager.Email = randomNumber + 'testmanager_consultant' + randomNumber2 + '@example.com';
        testManager.EmailEncodingKey ='UTF-8';
        testManager.FirstName = 'test';
        testManager.LastName ='manager';
        testManager.LanguageLocaleKey ='en_US';
        testManager.LocaleSidKey ='en_US';
        testManager.ProfileId = p.Id;
        testManager.TimeZoneSidKey ='America/Los_Angeles';
        testManager.UserName = randomNumber + 'testmanager' + randomNumber2 + '@example.com';
        insert testManager;

        List<User> testUsers = new List<User>();
        for(Integer i=0; i<numTeamMembers; i++){
            User testUser = new User();
            testUser.Alias = 'myuser' + i;
            testUser.Email = randomNumber + 'mytestuser' + i + '_consultant@example.com';
            testUser.EmailEncodingKey ='UTF-8';

            testUser.FirstName = 'test' + i;
            testUser.LastName ='Testing' + i;
            testUser.LanguageLocaleKey ='en_US';
            testUser.LocaleSidKey ='en_US';
            testUser.ProfileId = p.Id;
            testUSer.TimeZoneSidKey ='America/Los_Angeles';
            testUser.UserName = randomNumber + 'mytestuser' + i + '@example.com';
            testUser.EmployeeNumber = String.valueOf(i);
            testUser.PersonId__c = String.valueOf(i);
            testUser.ManagerId = testManager.Id;
            testUsers.add(testUser);
        }
        insert testUsers;

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
        insert contacts;

        List<ProjectTeamMember__c> testProjectTeamMembers = new List<ProjectTeamMember__c>();
        
        integer counter  = 0;

        for(Contact testContact : contacts){        
            testContact.User__c = testContact.pse__Salesforce_User__c;
            ProjectTeamMember__c member = new ProjectTeamMember__c();           
            member.Project__c = testProject.Id;         
            member.CurrencyIsoCode = 'USD'; 
            //member.Role__c = 'Project Manager';
            member.ProjectRole__c = projectRole.Id;
            member.Contact__c = testContact.Id;
            member.StartDate__c = Date.today().addDays(counter);
            member.EndDate__c = Date.today().addDays(counter + 1);
            testProjectTeamMembers.add(member);     
            counter = counter + 2;
        }
        insert testProjectTeamMembers;

        testProject = [SELECT Id, OUID__c FROM pse__Proj__c WHERE Id =: testProject.Id];
        
        //project sites
        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';
        testSite.OUID__c = testProject.OUID__c;
        insert testSite;

        Project_Site__c testProjectSite = new Project_Site__c();
        
        testProjectSite.BillingContactID__c = '1234';
        //testProjectSite.OracleProjectSiteId__c = '1111';
        testProjectSite.Project__c = testProject.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;

        insert testProjectSite;
    }

    public static pse__Proj__c createTestDataForProjectNumberRequest(){
        Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;

        OrganizationString__c testOrg = createTestOrg();
        insert testOrg;

        pse__Proj__c testProject = createTestProject('test project1');
        testProject.CarryingOutOrganization__c = testOrg.Id;
        testProject.pse__Account__c = testAccount.Id;
        insert testProject;
        return testProject;
    }
    
    public static pse__Proj__c createProjectWithAccountAndOrg() {
        createProjectRoles();
        return createTestDataForProjectNumberRequest();
    }

    public static pse__Proj__c createProjectWithAccountAndNoPrimaryOrg() {
        Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;
        
        createProjectRoles();

        pse__Proj__c testProject = createTestProject('test project1');
        testProject.pse__Account__c = testAccount.Id;
        insert testProject;
        return testProject;
    }
    
    public static pse__Proj__c createTestProject(String projName){
        pse__Proj__c testProject = new pse__Proj__c();
        testProject.Name = projName;    
        testProject.pse__Project_Type__c = 'Customer Project';
        testProject.pse__Billing_Type__c = 'Fixed Price';
        testProject.CurrencyIsoCode = 'USD';
        testProject.pse__Is_Active__c = true;
        testProject.ProjectLongName__c = projName + ' long name';
        testProject.ContractTypes__c = 'Fixed Priece - Hard Bid';
        testProject.DistributionRule__c = 'COST/WORK';
        testProject.ProjectFunctionalCurrencyCode__c = 'AUD';
        testProject.ProjectCurrencyCode__c = 'AUD';
        testProject.COSTINDRATESCHID__c = '6748';
        testProject.pse__Start_Date__c = Date.today();
        testProject.clAECOMProjectCity__c = 'Dallas';
        return testProject;
    }

    public static OrganizationString__c createTestOrg(){
        OrganizationString__c org = new OrganizationString__c();
        org.BusinessLineName__c = 'test business';
        org.Department__c = 'test dept';
        org.Description__c = 'test org string';
        org.District__c = 'test district';
        org.OrganizationName__c = '123456789';
        org.OrgID__c = '117';
        org.OUID__c = '147';
        org.TemplateIdCostWork__c = '1152536|T_ECO_CW_AUS';
        org.ContractTypes__c = 'Include';
        org.clAECOMFundingSource__c = 'Exclude';
        org.clAECOMPMCMFlag__c = 'Require';
        org.clAECOMClientType__c = 'Intercompany';
        org.clAECOMProjectCity__c = NULL;
        return org;
    }

/*
 *  @Author: Sujit Kumar
 *  @Created: Aug 10, 2015
 *  This is a utility class that provides data for test classes.
 *  All the builder nested classes are based on the Builder GoF design pattern.
 *  Advantages: 1) Prevent proliferation of constructors - telescoping constructor anti-pattern
                2) Reduced coupling on constructors.
                3) Defaults provided for most common attribute values
 * these methods were cloned over from ECO_TestData.cls - 6/13/2016 DJO
 */
    public class AccountBuilder {
        
        public AccountBuilder() {
            name = 'test account';
        }
        
        public String name { get; set; }
         
        public AccountBuilder withName(String name) {
            this.name = name;
            return this;
        }
        
        public Account build() {
            Account myAccount = new Account(name = this.name);
            insert myAccount;
            return myAccount;
        }
    }
    
    public class AgreementBuilder{
        public pse__Proj__c project { get; set; }
        public String agreementType { get; set; }

        public AgreementBuilder(pse__Proj__c project, String agreementType){
            this.project = project;
            this.agreementType = agreementType;
        }

        public Agreement__c build(){
            Id recordTypeId = [select Id from RecordType where Name =: this.agreementType limit 1].Id;
            Agreement__c agreement = new Agreement__c(
                RecordTypeId = recordTypeId,
                Account__c = new AccountBuilder().build().Id,
                Project__c = this.project.Id,
                FundingCurrencyCode__c = 'USD',
                Amount__c = 10000,
                TotalApprovedRevenueLimit__c = 11000
                );
            insert agreement;

            return agreement;            
        }
    }

    public class QuestionnaireBuilder{
        public pse__Proj__c project { get; set; }
        public QuestionnaireSet__c questionnaireSet { get; set; }
        public Integer sortOrder { get; set; }

        public QuestionnaireBuilder(pse__Proj__c project){
            this.project = project;
            sortOrder = 0;
        }


        public QuestionnaireBuilder addMarketAssessment(){
            if(this.questionnaireSet == null){ this.build(); }

            MarketAssessment__c ma = new MarketAssessment__c(
                QuestionnaireSet__c = this.questionnaireSet.Id,
                DocumentedBusinessPlan__c = 'True',
                DocumentedKeyAccount__c = 'True',
                StrongClientRelationship__c = 'True',
                RecentProjectExperience__c = 'True',
                RequiredTechnicalPersonnel__c = 'True',
                StrongPositiveWin__c = 'True',
                AwareofOpportunity__c = 'True',
                SufficientTimeandResources__c = 'True',
                Incumbent__c = 'True',
                DecisionMaker__c = 'True',
                DecisiontoAppoint__c = 'True',
                ExpertWitnessorLitigationSupport__c = 'True',
                JVinvolvement__c = 'True',
                ProgramManagementServices__c = 'True',
                RFPDevelopmentServices__c = 'True',
                StaffAugmentationorembeddedworkforce__c = 'True',
                Potentialconflictofinterestissues__c = 'True'
                );
            insert ma;
    
            return this;
        }

        public QuestionnaireBuilder addRisk(){

            if(this.questionnaireSet == null){ this.build(); }

            CountryRisk__c cr = new CountryRisk__c(Name = 'testCR', SafetyRating__c = 3.5);
            insert cr;

            ProjectCountry_Risk__c pcr = new ProjectCountry_Risk__c(
                CountryRisk__c = cr.Id,
                Project__c = this.project.Id
                );
            insert pcr;

            return this;
        }

        public QuestionnaireBuilder addQuestionnaire(){
            if(this.questionnaireSet == null){ this.build(); }

            QuestionnaireTemplate__c qt = new QuestionnaireTemplate__c(
                Name = 'test_qt2',
                SortOrder__c = sortOrder
                );
            insert qt;

            Questionnaire__c q = new Questionnaire__c(
                QuestionnaireSet__c = questionnaireSet.Id,
                QuestionnaireTemplate__c = qt.Id
                );
            insert q;

            return this;
        }

        public QuestionnaireSet__c build(){
            if(this.questionnaireSet != null){ return this.questionnaireSet; }

            QuestionnaireSet__c qs = new QuestionnaireSet__c(
                Name = 'test_qs', 
                Project__c = project.Id, 
                ApprovalStatus__c = 'Pending Approval', 
                GoNoGoRecommendation__c = 'Go'
                );
            insert qs;

            QuestionnaireTemplate__c qt = new QuestionnaireTemplate__c(
                Name = 'test_qt',
                SortOrder__c = sortOrder
                );
            insert qt;

            Questionnaire__c q = new Questionnaire__c(
                QuestionnaireSet__c = qs.Id,
                QuestionnaireTemplate__c = qt.Id
                );
            insert q;

            TemplateQuestion__c tq = new TemplateQuestion__c(
                QuestionnaireTemplate__c = qt.Id
                );
            insert tq;

            Answer__c a = new Answer__c(
                Complete__c = true,
                Value__c = 'Yes',
                Questionnaire__c = q.Id,
                TemplateQuestion__c = tq.Id
                );
            insert a; 
            
            tq = new TemplateQuestion__c(
                IsDoATrigger__c = true,
                isDOAmaster__c = true,
                QuestionnaireTemplate__c = qt.Id
                );
            insert tq;

            a = new Answer__c(
                Complete__c = true,
                Value__c = 'Yes',
                Questionnaire__c = q.Id,
                TemplateQuestion__c = tq.Id
                );
            insert a;
            
            this.questionnaireSet = [
                SELECT 
                    Id,
                    IsComplete__c,
                    Name,
                    ApprovalStatus__c,
                    GoNoGoRecommendation__c,
                    GoNoGo_Review__c,
                    Project__r.BusinessUnit__c,
                    UnansweredQuestionCount__c
                FROM QuestionnaireSet__c WHERE Id = :qs.Id][0];

            return this.questionnaireSet;
        }

        public Questionnaire__c getFirstQuestionnaire(){
            if(this.questionnaireSet == null){ this.build(); }

            List<Questionnaire__c> questionnaires = [
                SELECT 
                    Id,
                    Name,
                    QuestionnaireSet__c,
                    QuestionnaireSet__r.Project__c,
                    QuestionnaireTemplate__c
                FROM Questionnaire__c WHERE QuestionnaireSet__c = : this.questionnaireSet.Id LIMIT 1];
            return questionnaires[0];
        }

        public Questionnaire__c getQuestionnaire(Integer ordinal){
            if(this.questionnaireSet == null){ this.build(); }

            List<Questionnaire__c> questionnaires = [
                SELECT 
                    Id,
                    Name,
                    QuestionnaireSet__c,
                    QuestionnaireSet__r.Project__c,
                    QuestionnaireTemplate__c
                FROM Questionnaire__c WHERE QuestionnaireSet__c = : this.questionnaireSet.Id];
            return questionnaires[ordinal];
        }
    }

    public class ContactBuilder {       
        public ContactBuilder() {
            name = 'test contact';
        }
        
        public String name { get; set; }
        public User user { get; set; }
         
        public ContactBuilder withName(String name) {
            this.name = name;
            return this;
        }       

        public Contact build() {
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
            Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
            Account testAccount = new Account();
            testAccount.Name = 'test vendor account';
            testAccount.OracleVendorID__c = '30483';
            insert testAccount;

            User testUser = ECO_Utils_Testing.createTestUser('Standard User');
            insert testUser;
            this.user = testUser;
            //project sites
            Site__c testSite = new Site__c();
            testSite.Account__c = testAccount.Id;
            testSite.CurrencyIsoCode = 'USD';
            testSite.City__c = 'Winnipeg';      
            testSite.VendorSiteID__c = '654321';
            testSite.CustomerAccountSiteID__c = '666666';
            insert testSite;

            Contact testContact = new Contact();
            testContact.Email = testUser.Email;
            testContact.FirstName = testUser.FirstName;
            testContact.LastName =  testUser.LastName;
            testContact.Phone = '55555555555';
            testContact.pse__Salesforce_User__c = testUser.Id;
            testContact.RecordTypeId = recordTypeId;
            testContact.User__c = testUser.Id;
            testContact.OwnerId = testUser.Id;
            testContact.Site__c = testSite.Id;
            testContact.AccountId = testAccount.Id;
            testContact.pse__Is_Resource_Active__c = true;
            testContact.pse__Is_Resource__c = true;
            insert testContact;

            return testContact;
        }

        public Contact build(String trackingId) {
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
            Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'HR Pre-Hire');
            Account testAccount = new Account();
            testAccount.Name = 'test vendor account';
            testAccount.OracleVendorID__c = '30483';
            insert testAccount;

            //project sites
            Site__c testSite = new Site__c();
            testSite.Account__c = testAccount.Id;
            testSite.CurrencyIsoCode = 'USD';
            testSite.City__c = 'Winnipeg';      
            testSite.VendorSiteID__c = '654321';
            testSite.CustomerAccountSiteID__c = '666666';
            insert testSite;

            //insert of user creates a contact if one doesn't already exist, so we'll create our contact first in order to test the Pre-Hire flow
            User testUser = ECO_Utils_Testing.createTestUser('Standard User');
            testUser.TrackingId__c = trackingId;
            testUser.Email = testUser.Email.remove('consultant');

            Contact testContact = new Contact();
            testContact.Email = testUser.Email;
            testContact.FirstName = testUser.FirstName;
            testContact.LastName =  testUser.LastName;
            testContact.Phone = '55555555555';
            testContact.pse__Salesforce_User__c = testUser.Id;
            testContact.RecordTypeId = recordTypeId;
            //don't associate contact and User, only association is through the TrackingId
            testContact.OwnerId = UserInfo.getUserId();
            testContact.Site__c = testSite.Id;
            testContact.AccountId = testAccount.Id;
            testContact.pse__Is_Resource_Active__c = true;
            testContact.pse__Is_Resource__c = true;
            testContact.TrackingId__c = trackingId;
            insert testContact;

            insert testUser;
            this.user = testUser;

            return testContact;
        }
    }

    public class ProjectBuilder {
        public Account acct { get; set; }
        public Date startDate { get; set; }
        public Date endDate { get; set; }
        public List<pse__Project_Task__c> projectTasks { get; set; }
        Map<String, ProjectRole__c> projectRoles { get; set; }
        public String projectName { get; set; }
        public Opportunity opportunity { get; set; }
        public pse__Proj__c project { get; set; }
        
        public ProjectBuilder() {
            this.acct = new AccountBuilder().build();
            this.startDate = Date.today();
            this.endDate = startDate.addDays(56); // 8 weeks
            this.projectTasks = new List<pse__Project_Task__c>();
            this.projectName = 'testProject_' + TestCoverageSmokeMocks.generateRandomString(68);

            projectRoles = new Map<String, ProjectRole__c>();
            List<ProjectRole__c> insertProjectRoles = new List<ProjectRole__c>();

            /*for(ProjectRole__c role : [SELECT Name FROM ProjectRole__c WHERE Name IN(
                                        'Resilience Director', 
                                        'Project Manager', 
                                        'Project Owner', 
                                        'Capture Manager')])*/

            for(ProjectRole__c role : [SELECT Name FROM ProjectRole__c])                                        
            {
                projectRoles.put(role.Name, role);
            }

            if(!projectRoles.containsKey('Resilience Director')){
                ProjectRole__c rd = new ProjectRole__c(Name = 'Resilience Director', Type__c = 'Key Member', Active__c = true);
                insertProjectRoles.add(rd);
                projectRoles.put(rd.Name, rd);
            }

            if(!projectRoles.containsKey('Project Owner')){
                ProjectRole__c po = new ProjectRole__c(Name = 'Project Owner', Type__c = 'Key Member', Active__c = true);
                insertProjectRoles.add(po);
                projectRoles.put(po.Name, po);
            }

            if(!projectRoles.containsKey('Capture Manager')){
                ProjectRole__c cm = new ProjectRole__c(Name = 'Capture Manager', Type__c = 'Key Member', Active__c = true);
                insertProjectRoles.add(cm);
                projectRoles.put(cm.Name, cm);
            }

            if(!projectRoles.containsKey('Project Approver 2')){
                ProjectRole__c PA2 = new ProjectRole__c(Name = 'Project Approver 2', Active__c = true, SortOrder__c = 1, Type__c = 'Key Member');
                insertProjectRoles.add(PA2);
                projectRoles.put(PA2.Name, PA2);
            }

            if(!projectRoles.containsKey('Finance Lead')){
                ProjectRole__c FA = new ProjectRole__c(Name = 'Finance Lead', Active__c = true, SortOrder__c = 2, Type__c = 'Key Member');
                insertProjectRoles.add(FA);
                projectRoles.put(FA.Name, FA);
            }

            if(!projectRoles.containsKey('CFO or Delegate')){
                ProjectRole__c CoD = new ProjectRole__c(Name = 'CFO or Delegate', Active__c = true, SortOrder__c = 3, Type__c = 'Key Member');
                insertProjectRoles.add(CoD);
                projectRoles.put(CoD.Name, CoD);
            }

            if(!projectRoles.containsKey('Project Approver')){
                ProjectRole__c PA = new ProjectRole__c(Name = 'Project Approver', Active__c = true, SortOrder__c = 4, Type__c = 'Key Member');
                insertProjectRoles.add(PA);
                projectRoles.put(PA.Name, PA);
            }

            if(!projectRoles.containsKey('Project Accountant 2')){
                ProjectRole__c Pacc2 = new ProjectRole__c(Name = 'Project Accountant 2', Active__c = true, SortOrder__c = 5, Type__c = 'Key Member');
                insertProjectRoles.add(Pacc2);
                projectRoles.put(Pacc2.Name, Pacc2);
            }

            if(!projectRoles.containsKey('Finance Lead 2')){
                ProjectRole__c FL2 = new ProjectRole__c(Name = 'Finance Lead 2', Active__c = true, SortOrder__c = 6, Type__c = 'Key Member');
                insertProjectRoles.add(FL2);
                projectRoles.put(FL2.Name, FL2);
            }

            if(!projectRoles.containsKey('Project Accountant')){
                ProjectRole__c Pacc = new ProjectRole__c(Name = 'Project Accountant', Active__c = true, SortOrder__c = 7, Type__c = 'Key Member');
                insertProjectRoles.add(Pacc);
                projectRoles.put(Pacc.Name, Pacc);
            }

            if(!projectRoles.containsKey('Project Manager')){
                ProjectRole__c pm = new ProjectRole__c(Name = 'Project Manager', Active__c = true, SortOrder__c = 8, Type__c = 'Key Member');
                insertProjectRoles.add(pm);
                projectRoles.put(pm.Name, pm);
            }
            if(!projectRoles.containsKey('Deliverable Approver')){
                ProjectRole__c da = new ProjectRole__c(Name = 'Deliverable Approver', Active__c = true, SortOrder__c = 8, Type__c = 'Key Member');
                insertProjectRoles.add(da);
                projectRoles.put(da.Name, da);
            }



            if(projectRoles.size() > 0){

                upsert projectRoles.values();
            }
        }
        
        public ProjectBuilder addProjectSite(Boolean doInsert){
            if(this.project == null){ this.build(doInsert); }

            Account a = new AccountBuilder().build();

            Site__c site = new Site__c(
                Account__c = a.Id
                );
            insert site;

            Project_Site__c projectSite = new Project_Site__c(
                Project__c = this.project.Id, 
                Site__c = site.Id);
            insert projectSite;

            return this;
        }

        public pse__Proj__c get(){
            return project;
        }
         
        public ProjectBuilder withAccount(Account acct) {
            this.acct = acct;
            return this;
        }
        
        public ProjectBuilder withStartDate(Date startDate) {
            this.startDate = startDate;
            return this;
        }
        
        public ProjectBuilder withEndDate(Date endDate) {
            this.endDate = endDate;
            return this;
        }
        
        public ProjectBuilder withProjectTask(pse__Project_Task__c myTask) {
            this.projectTasks.add(myTask);
            return this;
        }

        //Creating the Opportunity after the Project results in 101 SOQL error
        public ProjectBuilder withOpportunity(){
            AECOM_Primary_Department__c primaryDept;
            List<AECOM_Primary_Department__c> departments;

            departments = [SELECT Lead_Region__c FROM AECOM_Primary_Department__c WHERE Name = 'test Lead Region' LIMIT 1];
            if(departments.size() == 0){
                Geography__c g = new Geography__c(Name = 'myGeo');
                insert g;

                primaryDept = new AECOM_Primary_Department__c(
                    Lead_Region__c = 'test Lead Region',
                    Geography_Lookup__c = g.Id
                    );
                insert primaryDept;
            }
            else{
                primaryDept = departments[0];
            }

            opportunity = new Opportunity(
                Name = 'projectName', 
                StageName = 'Open', 
                CloseDate = Date.today(), 
                AECOM_Primary_Dept_Lookup__c = primaryDept.Id,
                Enterprise_Service__c = 'Engineering',
                ValidateGo__c = false
                );
            insert opportunity;

            return this;
        }

        public pse__Proj__c build(Boolean doInsert) {
            Contact captureManager = new Contact(
                    FirstName='cm First', 
                    LastName='cm Last', 
                    Email='cm@nowhere.com',
                    user__c=UserInfo.getUserId()
                );
            insert captureManager;

            pse__Proj__c myProj = new pse__Proj__c  (
                                                        pse__Account__c = this.acct.Id, 
                                                        pse__Start_Date__c = this.startDate,
                                                        pse__End_Date__c = this.endDate,
                                                        CaptureManager__c = captureManager.Id,
                                                        EstAwardDate__c = this.startDate == null ? Date.today() : this.startDate,
                                                        ProjectFunctionalCurrencyCode__c = 'USD',
                                                        BusinessUnit__c = 'ANZ',
                                                        BudgetStrategy__c = 'Top Task',
                                                        pse__Opportunity__c = opportunity == null ? null : opportunity.Id  //Running into 101 SOQL error in triggers
                                                    );
            if(doInsert)
            {
                insert myProj;
                /*ProjectTeamMember__c teamMember = new ProjectTeamMember__c(
                    Contact__c = captureManager.Id, 
                    ProjectRole__c = projectRoles.get('Capture Manager').Id, 
                    Project__c = myProj.Id, 
                    StartDate__c = myProj.pse__Start_Date__c);
                insert teamMember;*/
            }
            this.project = myProj;

            return myProj;
        }
    }


    public class ProjectTaskBuilder {
        
        public ProjectTaskBuilder() {
            this.earnedValueCurve = 'Even';
            this.totalApprovedCost = 10000; // 8 weeks
        }
        
        public String taskName { get; set; }
        public Id projectId { get; set; }
        public String earnedValueCurve { get; set; }
        public Integer totalApprovedCost { get; set; }
        public String projectTaskNumber     { get; set; }
        public Date taskStartDate           { get; set; }
        public Date taskEndDate             { get; set; }
        
        public ProjectTaskBuilder withTaskName(String taskName) {
            this.taskName = taskName;
            return this;
        }
        
        public ProjectTaskBuilder withprojectId(Id projectId) {
            this.projectId = projectId;
            return this;
        }
        
        public ProjectTaskBuilder withTotalApprovedCost(Integer totalApprovedCost) {
            this.totalApprovedCost = totalApprovedCost;
            return this;
        }
        
        public ProjectTaskBuilder withEarnedValueCurve(String earnedValueCurve) {
            this.earnedValueCurve = earnedValueCurve;
            return this;
        }
        
        public ProjectTaskBuilder withTaskNumber(String taskNumber) {
            this.projectTaskNumber = taskNumber;
            return this;
        }

        public ProjectTaskBuilder withStartDate(Date startDate){
            this.taskStartDate = startDate;
            return this;
        }

        public ProjectTaskBuilder withEndDate(Date endDate){
            this.taskEndDate = endDate;
            return this;
        }

         public pse__Project_Task__c build() {
            pse__Project_Task__c myProjTask = new pse__Project_Task__c  
                                                    (
                                                        Name = this.taskName, 
                                                        pse__Project__c = this.projectId,
                                                        EarnedValueCurve__c = this.earnedValueCurve,
                                                        TotalApprovedCost__c = this.totalApprovedCost,
                                                        ProjectTaskNumber__c = this.projectTaskNumber,
                                                        pse__Start_Date_Time__c = this.taskStartDate,
                                                        pse__End_Date_Time__c = this.taskEndDate
                                                    );
            return myProjTask;
        }
    }


    public class EarnedValueReportBuilder {

        public EarnedValueReportBuilder() {
            // Add defaults here if any
            this.committed = false;
        }
        
        public String reportName { get; set; }
        public Id projectId { get; set; }
        public Date snapshotDate { get; set; }
        public Boolean committed { get; set; }
        
        public EarnedValueReportBuilder withReportName(String reportName) {
            this.reportName = reportName;
            return this;
        }
        
        public EarnedValueReportBuilder withprojectId(Id projectId) {
            this.projectId = projectId;
            return this;
        }
        
        public EarnedValueReportBuilder withSnapshotDate(Date snapshotDate) {
            this.snapshotDate = snapshotDate;
            return this;
        }
        
        public EarnedValueReportBuilder withCommitted(Boolean committed) {
            this.committed = committed;
            return this;
        }
        
         public EarnedValueHeader__c build() {
            EarnedValueHeader__c myReport = new EarnedValueHeader__c    
                                                    (
                                                        ReportName__c = this.reportName, 
                                                        Project__c = this.projectId,
                                                        SnapshotDate__c = this.snapshotDate,
                                                        Committed__c = this.committed
                                                    );
            insert myReport;
            return myReport;
        }
    }
    
    
    public class EarnedValueTaskBuilder {

        public EarnedValueTaskBuilder() {
            // Add defaults here if any
            this.committed = false;
            this.notifyTaskOwner = false;
            this.percentComplete = 0.00;
        }

        public Id taskId { get; set; }
        public Id reportId { get; set; }
        public Date snapshotDate { get; set; }
        public Boolean committed { get; set; }
        public Boolean notifyTaskOwner { get; set; }
        public Decimal percentComplete { get; set; }
        
        public EarnedValueTaskBuilder withTaskId(Id taskId) {
            this.taskId = taskId;
            return this;
        }
        
        public EarnedValueTaskBuilder withReportId(Id reportId) {
            this.reportId = reportId;
            return this;
        }
        
        public EarnedValueTaskBuilder withSnapshotDate(Date snapshotDate) {
            this.snapshotDate = snapshotDate;
            return this;
        }
        
        public EarnedValueTaskBuilder withCommitted(Boolean committed) {
            this.committed = committed;
            return this;
        }
        
        public EarnedValueTaskBuilder withNotifyTaskOwner(Boolean notifyTaskOwner) {
            this.notifyTaskOwner = notifyTaskOwner;
            return this;
        }
        
        public EarnedValueTaskBuilder withPercentComplete(Decimal percentComplete) {
            this.percentComplete = percentComplete;
            return this;
        }       
        
         public EarnedValueTask__c build() {
            EarnedValueTask__c myEVT = new EarnedValueTask__c   
                                                    (
                                                        ProjectTask__c = this.taskId, 
                                                        EarnedValueHeader__c = this.reportId,
                                                        SnapshotDate__c = this.snapshotDate,
                                                        Committed__c = committed,
                                                        NotifyTaskOwner__c = notifyTaskOwner,
                                                        PercentComplete__c = percentComplete
                                                    );
            return myEVT;
        }
    }

    public virtual class ProjectWrapper {
        
        public pse__Proj__c project { get; set; }
        public List<pse__Project_Task__c> listOfTasks { get; set; }
        
        public ProjectWrapper(pse__Proj__c project, List<pse__Project_Task__c> listOfTasks) {
            this.project = project;
            this.listOfTasks = listOfTasks;
        }
    }
    
    
    public class ReportWrapper extends ProjectWrapper {
        
        public EarnedValueHeader__c report { get; set; }
        public List<EarnedValueTask__c> listOfEVTs { get; set; }
        
        public ReportWrapper(ProjectWrapper pw, EarnedValueHeader__c report, List<EarnedValueTask__c> listOfEVTs) {
            super(pw.project, pw.listOfTasks);
            this.report = report;
            this.listOfEVTs = listOfEVTs;
        }
    }


    public static pse__Proj__c createProject() {
        pse__Proj__c testProject = new ProjectBuilder().build(true);
        testProject.ValidateGo__c = false;
        return testProject;
    }
    
    public static pse__Proj__c createProject(Date startDate, Date endDate) {
        pse__Proj__c testProject = new ProjectBuilder().withStartDate(startDate).withEndDate(endDate).build(true);
        testProject.ValidateGo__c = false;
        return testProject;
    }
    
    public static ProjectWrapper createProjectWithTasks(String prefix, Integer nTasks, Integer nWeeks) {
        Date startDate = Date.today();
        Date endDate = Date.today().addDays(7 * nWeeks); // nWeeks
        pse__Proj__c testProject = new ProjectBuilder().withStartDate(startDate).withEndDate(endDate).build(true);
//        pse__Proj__c testProject = new ProjectBuilder().withEndDate(endDate).build(true);
        
        List<pse__Project_Task__c> listOfTasks = new List<pse__Project_Task__c>();
        for (Integer i = 1; i <= nTasks; ++i) {
            pse__Project_Task__c projTask = new ProjectTaskBuilder().withTaskName(prefix + '-' + i)
                                                                    .withProjectId(testProject.Id)
                                                                    .build();
            listOfTasks.add(projTask);
        }

        System.debug('listOfTasks: ' + listOfTasks);
        insert listOfTasks;
        return new ProjectWrapper(testProject, listOfTasks);
    }

    public static ProjectWrapper createProjectWithTasksAndDates(String prefix, Integer nTasks, Integer nWeeks, Date startDate, Date endDate ) {
        pse__Proj__c testProject = new ProjectBuilder().withStartDate(startDate).withEndDate(endDate).build(true);
//        pse__Proj__c testProject = new ProjectBuilder().withEndDate(endDate).build(true);
        
        List<pse__Project_Task__c> listOfTasks = new List<pse__Project_Task__c>();
        for (Integer i = 1; i <= nTasks; ++i) {
            pse__Project_Task__c projTask = new ProjectTaskBuilder().withTaskName(prefix + '-' + i)
                                                                    .withProjectId(testProject.Id)
                                                                    .withTaskNumber(prefix + '.' + i)
                                                                    .withStartDate(startDate)
                                                                    .withEndDate(endDate)
                                                                    .build();
System.debug( LoggingLevel.WARN, '=====>projTask: ' + projTask);
            listOfTasks.add(projTask);
        }

        System.debug('listOfTasks: ' + listOfTasks);
        insert listOfTasks;
        return new ProjectWrapper(testProject, listOfTasks);
    }

    
    public static EarnedValueHeader__c createReport(ProjectWrapper myProjWrapper, Integer reportForNthWeek) {
        return createReport(myProjWrapper, reportForNthWeek, false);
    }
    
    public static EarnedValueHeader__c createReport(ProjectWrapper myProjWrapper, Integer reportForNthWeek, Boolean committed) {
//      Date startOfWeekOfStartDate = myProjWrapper.project.pse__Start_Date__c.toStartofWeek();
        Date startOfWeekOfStartDate = ECO_Service_Snapshots.getFirstDateOfWeek(myProjWrapper.project.pse__Start_Date__c);
        if (reportForNthWeek > 1) {
            startOfWeekOfStartDate = startOfWeekOfStartDate.addDays(7 * (reportForNthWeek - 1));
        }
        EarnedValueHeader__c myReport = new EarnedValueReportBuilder()
                                                .withProjectId(myProjWrapper.project.Id)
                                                .withSnapshotDate(startOfWeekOfStartDate)
                                                .withReportName(ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(startOfWeekOfStartDate))
                                                .withCommitted(committed)
                                                .build();
        return myReport;
    }
    
    public static List<EarnedValueTask__c> createEarnedValueTasks(ProjectWrapper myProjWrapper, EarnedValueHeader__c myReport, Integer basePercentComplete) {
        return  createEarnedValueTasks(myProjWrapper, myReport, basePercentComplete, false);
    }
    
    
    public static List<EarnedValueTask__c> createEarnedValueTasks(ProjectWrapper myProjWrapper, EarnedValueHeader__c myReport, Integer basePercentComplete, Boolean committed) {
        List<EarnedValueTask__c> listOfEVTs = new List<EarnedValueTask__c>();
        Integer i = 1;
        for (pse__Project_Task__c eachTask : myProjWrapper.listOfTasks) {
            EarnedValueTask__c evt = new EarnedValueTaskBuilder()
                                                .withTaskId(eachTask.Id)
                                                .withReportId(myReport.Id)
                                                .withSnapshotDate(ECO_Service_Snapshots.getFirstDateOfWeek(myProjWrapper.project.pse__Start_Date__c))
//                                              .withSnapshotDate(myProjWrapper.project.pse__Start_Date__c.toStartofWeek())
                                                .withCommitted(committed)
                                                .withPercentComplete(basePercentComplete + i)
                                                .build();
            listOfEVTs.add(evt);
            i = i + 1;
        }
        insert listOfEVTs;
        return listOfEVTs;
    }
    
    public static ReportWrapper createReportAndEarnedValueTasks(ProjectWrapper pw, Integer reportForNthWeek, Integer basePercentComplete, Boolean committed) {
        EarnedValueHeader__c evReport = createReport(pw, reportForNthWeek);
        List<EarnedValueTask__c> listOfEVTs = createEarnedValueTasks(pw, evReport, basePercentComplete);
        ReportWrapper rw = new ReportWrapper(pw, evReport, listOfEVTs);
        return rw;
    }
    
    public static ReportWrapper createProjectWithTasksAndEVReportAndEVTasks(Integer nTasks, Integer nWeeks, Integer reportForNthWeek, Integer basePercentComplete) {
        ProjectWrapper pw = createProjectWithTasks('A', nTasks, nWeeks);
        return createReportAndEarnedValueTasks(pw, reportForNthWeek, basePercentComplete, false);
    }

    public static SharedServicesRequest__c createSharedServicesRequest(Id recordTypeId){
        User approver = TestCoverageSmokeMocks.mockUser(true);
        
        Account testAccount = new Account(
            Name = 'test account');
        insert testAccount;

        Country__c c = new Country__c(
            Name = 'test');
        insert c;

        State_Province_Emirate__c p  = new State_Province_Emirate__c(
            Name = 'test',
            Country__c = c.id);
        insert p;

        SharedServicesRequest__c ssr = new SharedServicesRequest__c(
            Approver__c = approver.id,
            SkipValidation__c = true,
            GenerateObjects__c= true,
            AssigntoSharedServices__c = true,
            RecordTypeId = recordTypeId,
            CustomerName__c = 'test',
            ParentAccount__c = testAccount.id,
            ClientGroup__c = 'test',
            ClientSubgroup__c = 'test',
            Reach__c = 'test',
            SicCode__c = 'test',
            SicDescription__c = 'test',
            MKDenialStatus__c = 'test',
            IntercompanyCustomer__c = 'test',
            DBNumberDUNS__c = 'duns',
            DesktopCheckAsia__c = true,

            //vendor fields
            VendorType__c = 'test',
            SocioMinorityOwned__c = true,
            SocioNonProfit__c = true,
            OfficeEmail__c = 'a@b.com',

            SocioSmallBusinessSB__c = true,
            SocioLargeBusiness__c = true,
            SocioVeteranOwnedVO__c = true,
            SocioWomenOwnedWO__c = true,
            SocioServiceDisabledVeteranOwnedSDVO__c = true,
            Socio8aCertifiedFirms8a__c = true,
            SocioAbilityOne__c = true,
            SocioAlaskaNativeCorpandTriballyOwned__c = true,
            EcoEconomicallyDisadvantagedWomanOwned__c = true,
            SocioHistoricallyBlackCollegesandUniv__c = true,
            SocioSmallDisadvantagedBusinessSDB__c = true,
            SocioHUBZone__c = true,

            //Sites
            Address1StreetPOBox__c = 'test',
            City__c = 'test',
            Country__c = 'Afghanistan', 
            AddressIsPrimary__c = true,
            StateProvinceEmirate__c = p.id,

            BillingStreetPOBox__c = 'test',
            BillingAddressCity__c = 'billingCity',
            BillingAddressCountry__c = 'Afghanistan',   
            BillingAddress1isPrimary__c = false,
            BillingStateProvinceEmirate__c = p.id,


            RemitToAddressLine1__c = 'test',
            RemitToCity__c = 'test',
            RemitToCountry__c = 'Afghanistan',
            RemitIsPrimaryAddress__c = false,
            RemitToStateProvinceEmirate__c = p.id,


            //contacts
            BillingContactLastName__c = 'test',
            BillingContactFirstName__c = 'test',
            //BillingContactEmail__c = 'test@test.com',
            BillingContactPhone__c = '1111111',

            Contact1LastName__c = 'test1',
            Contact1FirstName__c = 'test1',
            Contact1EmailAddress__c = 'test@test2.com',
            Contact1Phone__c = '2222222',       

            Contact2LastName__c = 'test2',
            Contact2FirstName__c = 'test2',
            Contact2Email__c = 'test@test3.com',
            Contact2Phone__c = '3333333'
            );

        return ssr;

    }

    public static Agreement__c createPrimeAgreementForProject(pse__Proj__c project, String currencyCode, Id accountId)
    {
        Id primeRecordTypeId = [select Id from RecordType where Name = 'Prime Task Order' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
        agreement.Account__c = accountId;
        agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = currencyCode;
        agreement.Amount__c = 1000;
        agreement.TotalApprovedRevenueLimit__c = 1000;
        insert agreement;

        return agreement;
    }

    public static Billing__c createBillingForProject(pse__Proj__c project, Decimal amount)
    {
        Billing__c billing = new Billing__c(ProjectNumber__c = project.Id);
        billing.BalanceDueNumber__c = amount;
        insert billing;

        return billing;
    }

    public static Revenue__c createRevenueForProject(pse__Proj__c project, Decimal amount, pse__Project_Task__c task)
    {
        Revenue__c revenue = new Revenue__c(ProjectNumber__c = project.Id);
        revenue.Amount__c = amount;
        revenue.TaskNumber__c = task.Id;
        insert revenue;

        return revenue;
    }   

    public static Revenue__c createRevenueForProjectWithGLDate(pse__Proj__c project, Decimal amount, pse__Project_Task__c task, Date glDate)
    {
        Revenue__c revenue = new Revenue__c(ProjectNumber__c = project.Id);
        revenue.Amount__c = amount;
        revenue.TaskNumber__c = task.Id;
        revenue.GLDate__c = glDate;
        insert revenue;

        return revenue;
    }
    
    public static List<Contact> createTestDataForOrgFinder(){

        List<User> users; 
        List<Contact> contacts;

        list<DatedExchangeRate__c> lstDER = new list<DatedExchangeRate__c>();
        lstDER.add(new DatedExchangeRate__c(isoCode__c='USD', conversionrate__c = 1, startDate__c=Date.today().adddays(-30)) );
        lstDER.add(new DatedExchangeRate__c(isoCode__c='NZD', conversionrate__c = 1, startDate__c=Date.today().adddays(-30)) );

        insert lstDER;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 



        ECO_Utils_Testing.createProjectRoles();


        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');

        users = new List<User>();
        users.add(ECO_Utils_Testing.createTestUser('Standard User'));
        users.add(ECO_Utils_Testing.createTestUser('Standard User'));
        users.add(ECO_Utils_Testing.createTestUser('Standard User'));
        users.add(ECO_Utils_Testing.createTestUser('Standard User'));
        users.add(ECO_Utils_Testing.createTestUser('Standard User'));
        users.add(ECO_Utils_Testing.createTestUser('Standard User'));
        users.add(ECO_Utils_Testing.createTestUser('Standard User'));
        users.add(ECO_Utils_Testing.createTestUser('Standard User'));
        users.add(ECO_Utils_Testing.createTestUser('Standard User'));
        users.add(ECO_Utils_Testing.createTestUser('Standard User'));
        insert users;

        contacts = new List<Contact>();
        contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[0].Email, FirstName = users[0].FirstName, LastName = users[0].LastName, pse__Salesforce_User__c = users[0].Id, recordTypeId = recordTypeId, User__c = users[0].Id, OwnerId = users[0].Id, OracleContactID__c = 'EMPLOYEE-123'));
        contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[1].Email, FirstName = users[1].FirstName, LastName = users[1].LastName, pse__Salesforce_User__c = users[1].Id, recordTypeId = recordTypeId, User__c = users[1].Id, OwnerId = users[1].Id, OracleContactID__c = 'EMPLOYEE-1234'));
        contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[2].Email, FirstName = users[2].FirstName, LastName = users[2].LastName, pse__Salesforce_User__c = users[2].Id, recordTypeId = recordTypeId, User__c = users[2].Id, OwnerId = users[2].Id, OracleContactID__c = 'EMPLOYEE-12345'));
        contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[3].Email, FirstName = users[3].FirstName, LastName = users[3].LastName, pse__Salesforce_User__c = users[3].Id, recordTypeId = recordTypeId, User__c = users[3].Id, OwnerId = users[3].Id, OracleContactID__c = 'EMPLOYEE-123456'));
        contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[4].Email, FirstName = users[4].FirstName, LastName = users[4].LastName, pse__Salesforce_User__c = users[4].Id, recordTypeId = recordTypeId, User__c = users[4].Id, OwnerId = users[4].Id, OracleContactID__c = 'EMPLOYEE-1234567'));
        contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[5].Email, FirstName = users[5].FirstName, LastName = users[5].LastName, pse__Salesforce_User__c = users[5].Id, recordTypeId = recordTypeId, User__c = users[5].Id, OwnerId = users[5].Id, OracleContactID__c = 'EMPLOYEE-12345678'));
        contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[6].Email, FirstName = users[6].FirstName, LastName = users[6].LastName, pse__Salesforce_User__c = users[6].Id, recordTypeId = recordTypeId, User__c = users[5].Id, OwnerId = users[5].Id, OracleContactID__c = 'EMPLOYEE-123456789'));
        contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[7].Email, FirstName = users[7].FirstName, LastName = users[7].LastName, pse__Salesforce_User__c = users[7].Id, recordTypeId = recordTypeId, User__c = users[7].Id, OwnerId = users[7].Id, OracleContactID__c = 'EMPLOYEE-1234567890'));
        contacts.add(new Contact(pse__Is_Resource__c = true, Status__c = 'Active', Email = users[8].Email, FirstName = users[8].FirstName, LastName = users[8].LastName, pse__Salesforce_User__c = users[8].Id, recordTypeId = recordTypeId, User__c = users[8].Id, OwnerId = users[8].Id, OracleContactID__c = 'EMPLOYEE-12345678901'));

        insert contacts;




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
        Org1.PLManagerContact__c = contacts[0].id;
        Org1.FinanceandAccountingManagerContact__c = contacts[1].id;
        Org1.CFOorDelegateContact__c = contacts[2].id;
        Org1.ProjectApprover__c = contacts[3].id;
        Org1.ProjectAccountant__c = contacts[4].id;
        Org1.ProjectAccountant2__c = contacts[5].id;
        Org1.FinanceLead2__c = contacts[6].id;

        lOrgStrings.add(Org1);


        OrganizationString__c Org2 = ECO_Utils_Testing.createTestOrg();

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
        org2.InactiveDate__c = null;
        org2.ProjectOwning__c = true;
        org2.PLManagerContact__c = contacts[0].id;
        org2.FinanceandAccountingManagerContact__c = contacts[1].id;
        org2.CFOorDelegateContact__c = contacts[2].id;
        org2.ProjectApprover__c = contacts[3].id;
        org2.ProjectAccountant__c = contacts[4].id;
        org2.ProjectAccountant2__c = contacts[5].id;
        org2.FinanceLead2__c = contacts[6].id;
        lOrgStrings.add(Org2);
        insert lOrgStrings;     


        list<account> testAccounts = new list<account>();

        // Insert Test Account
        Account testAccount = new Account();
        testAccount.Name = 'test account';
        testAccount.OracleCustomerID__c = '1111';
        testAccounts.add(testAccount);

        Account testAccount2 = new Account();
        testAccount2.Name = 'another account';
        testAccount2.OracleCustomerID__c = '2222';
        testAccount2.Type__c = 'Vendor';  
        testAccounts.add(testAccount2);

        insert testAccounts;        

        Opportunity testOpp = new Opportunity();
        testOPP.ValidateGo__c = false;
        testOpp.accountid = testAccount.id;
        testOpp.name = 'test opp';
        testOpp.closeDate = date.today();
        testOpp.Stagename = '1 Lead';
        testOpp.probability = 100;
        testOpp.Estimated_work_start_date__c = Date.today().adddays(10);
        testOpp.TO_Procurement_Method__c = 'Competitive Task Orders';       
        testOpp.Contract_Est_Months__c = 5;   

        Opportunity testOpp2 = new Opportunity();
        testOpp2.ValidateGo__c = false;
        testOpp2.accountid = testAccount2.id;
        testOpp2.name = 'test opp2';
        testOpp2.closeDate = date.today();
        testOpp2.Stagename = '1 Lead';
        testOpp2.probability = 100;
        testOpp2.Estimated_work_start_date__c = Date.today().adddays(10);
        testOpp2.TO_Procurement_Method__c = 'Competitive Task Orders';  

        list<Opportunity> lstOpp = new list<Opportunity>();
        lstOpp.add(testOpp);
        lstOpp.add(testOpp2);

        insert lstOpp;

        // Insert Test Site Data
        list<site__c> testSites = new list<site__c>();

        Site__c s1 = new Site__c();
        s1.Account__c = testAccount.id;
        s1.City__c = 'Toronto';
        s1.Country__c = 'Canada';
        s1.State__c = 'Ontario';
        s1.CustomerSiteUseCode__c = 'BILL_TO';
        s1.OUID__c = Org1.OUID__c;
        s1.SiteStatus__c = 'A';

        testSites.add(s1);

        Site__c s2 = new Site__c();
        s2.Account__c = testAccount.id;
        s2.City__c = 'Toronto2';
        s2.Country__c = 'Canada2';
        s2.State__c = 'Ontario2';
        s2.CustomerSiteUseCode__c = 'SHIP_TO';
        s2.OUID__c = Org1.OUID__c;
        s2.SiteStatus__c = 'A';

        testSites.add(s2);

        Site__c s3 = new Site__c();
        s3.Account__c = testAccount.id;
        s3.City__c = 'Toronto3';
        s3.Country__c = 'Canada3';
        s3.State__c = 'Ontario3';
        s3.CustomerSiteUseCode__c = 'SHIP_TO';
        s3.OUID__c = Org1.OUID__c;
        s3.SiteStatus__c = 'A';

        testSites.add(s3);      

        Site__c s4 = new Site__c();
        s4.Account__c = testAccount2.id;
        s4.City__c = 'Vanc';
        s4.Country__c = 'Canada';
        s4.State__c = 'BC';
        s4.CustomerSiteUseCode__c = 'BILL_TO';
        s4.OUID__c = Org1.OUID__c;
        s4.SiteStatus__c = 'A';

        testSites.add(s4);  


        insert testSites;



        //create create source project 
        pse__Proj__c testProject = new ECO_Utils_Testing.ProjectBuilder().build(false);
        testProject.Name = '**********test project 1';
        testProject.pse__Opportunity__c = testOpp.id;
        testProject.pse__Account__c = testAccount.Id;
        testProject.pse__Project_Type__c = 'Customer Project';
        testProject.pse__Billing_Type__c = 'Fixed Price';
        testProject.CurrencyIsoCode = 'USD';
        testProject.pse__Is_Active__c = true;   
        testProject.CarryingOutOrganization__c = org1.id;
        testProject.EstAwardDate__c = date.today().adddays(-5);
        testProject.EstimatedStartDate__c = date.today();
        insert testProject;

        AECOM_Primary_Department__c test = new AECOM_Primary_Department__c(name='test', Lead_Region__c = 'test', Org_String__c = Org2.OrganizationName__c);
        insert test;

        return contacts;



    }
	
    public static void createExchangeRates() {
        ECO_Service_Delegation.run = false;
    	List<DatedExchangeRate__c> exchangeRates = new List<DatedExchangeRate__c>();
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'USD', ConversionRate__c = 1, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NZD', ConversionRate__c = 1.25, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AUD', ConversionRate__c = 1.50, StartDate__c = Date.today().addYears(-10)));
    	exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AED', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'ARS', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AFN', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'AZN', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BAM', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BDT', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BGN', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BHD', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BIF', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BMD', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BND', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BOB', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BRL', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BOB', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BSD', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BTN', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BWP', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'BYR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'CAD', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'CDF', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'CHF', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'CLP', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'EUR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NGN', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NOK', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'NPR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'OMR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'PEN', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'PGK', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'PHP', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'PKR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'PLN', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'PYG', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'QAR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'ROL', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'RON', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'RSD', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'RUB', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'RWF', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'SAR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'SBD', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'SEK', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'SGD', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'SLL', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'SZL', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'THB', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'TJS', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'TOP', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'TRY', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'TTD', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'TWD', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'TZS', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'UAH', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'UGX', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'UZS', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'VEB', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'VEF', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'VND', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'VUV', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'WST', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'XAF', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'XOF', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'ZAR', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
        exchangeRates.add(new DatedExchangeRate__c(IsoCode__c = 'ZMW', ConversionRate__c = 1.70, StartDate__c = Date.today().addYears(-10)));
    	insert exchangeRates;
    }
    
    public static void createTestDataForBudgets() {
        ECO_Service_DirtyScope.run = false;
        List<pse__Time_Period__c> timePeriods;
        List<pse__Proj__c> projects;
        List<Id> projectIds;
        pse__Proj__c proj1;
        List<pse__Project_Task__c> pTasks;

        createExchangeRates();
        List<ProjectRole__c> projectRoles = createProjectRoles();
                Contact con = new ECO_Utils_Testing.ContactBuilder().build();

                // Step 1-2: RecordType
                //Id rtId = [SELECT Id FROM RecordType WHERE DeveloperName='CustomerProjectUnapproved' LIMIT 1].Id; // Create RT ?
                //System.debug('___rtId='+rtId);
                RecordType rt1 = new RecordType();
                rt1.DeveloperName = 'TestRT-Dev';
                
                List<Account> accts = Test.loadData(Account.sObjectType, 'UT_Account');
                System.debug('__accts='+accts);
                List<Oracle_Expenditure_Types__c> CsOracleExpTypes = Test.loadData(Oracle_Expenditure_Types__c.sObjectType, 'UT_CS_Oracle_ExpTypes');

                List<ExpenditureType__c> expTypes = Test.loadData(ExpenditureType__c.sObjectType, 'UT_ExpenditureType');
                System.Debug(System.LoggingLevel.WARN, '___ExpenditureType 0='+expTypes[0]);
                System.Debug(System.LoggingLevel.WARN, '___ExpenditureType 5='+expTypes[5]);
                System.Debug(System.LoggingLevel.WARN, '___ExpenditureType: SOQL='+Limits.getQueries());
                
                // Step 3: TimePeriods
                timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
                
                // Step 4-7: CSV StaticResources setup offline (via Excel)        
                // Load the test data from the static resource
                //////// Step 8: PROJECT
                ECO_ProjectTriggers.run = false;
                projects = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
                //System.assert(projects.size() == 1);
                
                proj1 = (pse__Proj__c) projects[0];
                System.debug(System.LoggingLevel.WARN, '___proj1='+proj1+', proj1.Id='+proj1.Id);

                OrganizationString__c testOrg = ECO_Utils_Testing.createTestOrg();
                insert testOrg;

                List<pse__Proj__c> projsToUpdate = new List<pse__Proj__c>();

                for (pse__Proj__c proj : projects) {
                    proj.CarryingOutOrganization__c = testOrg.Id;      
                    projsToUpdate.add(proj);  
                }

                projsToUpdate[1].pse__Stage__c = 'Planning';
                update projsToUpdate;

                System.debug('___projectsv2='+projsToUpdate);
                // proj1.Is_Active__c = true;
                ProjectRole__c prl = [Select Id From ProjectRole__c Where Name = 'Project Manager'];
                ProjectTeamMember__c ptm = new ProjectTeamMember__c(Contact__c = con.id, ProjectRole__c = prl.id, Project__c = proj1.Id, StartDate__c = date.today());
                insert ptm;

                Site__c site  = [select id from Site__c where VendorSiteID__c = '654321' limit 1];
                VendorSite__c vendorSite = new VendorSite__c();
                vendorSite.Project__c = proj1.Id;
                vendorSite.Site__c = site.Id;
                vendorSite.Type__c = 'Sub';
                
                insert vendorSite;

                ///////////// Step 9: PROJECT TASK
                ECO_ProjectTaskTriggers.run = false;
                pTasks = Test.loadData(pse__Project_Task__c.sObjectType, 'UT_ProjectTask');
                //PSE__PROJECT__r:OracleProjectNumber__c = CT201601090001
                System.Debug(System.LoggingLevel.WARN, '___ProjectTask: SOQL='+Limits.getQueries());
                
                ///// Step 10: REVENUE
                ECO_RevenueTriggers.run = false;
                List<Revenue__c> revenues = Test.loadData(Revenue__c.sObjectType, 'UT_Revenue');
                System.Debug(System.LoggingLevel.WARN, '___Revenue: SOQL='+Limits.getQueries());
                
                ///// Step 11: EXPENDITURE ITEM
                ECO_ExpenditureItem_TriggerDispatcher.run = false;
                List<ExpendItem__c> expItems = Test.loadData(ExpendItem__c.sObjectType, 'UT_ExpenditureItem');
                //System.debug(System.LoggingLevel.WARN, '___ExpendItem__c='+expItems[0]);
                //System.assertEquals(expItems[0].ProjectTask__c, pTasks[0].Id);
                List<ExpendItem__c> expItemsToUpdate = new List<ExpendItem__c>();

                for (ExpendItem__c item : expItems) {
                    if (item.ExpenditureType__c == 'CON-Subcontractor Exempt') {
                        item.VendorId__c = '30483';
                        expItemsToUpdate.add(item);
                    }
                }
                update expItemsToUpdate;
                
                System.Debug(System.LoggingLevel.WARN, '___SOQL='+Limits.getQueries());
                

                //// Step 12: COST DIST LINE
                ECO_CostDistributionLineTriggers.run = false;
                List<CostDistLine__c> costDistLines = Test.loadData(CostDistLine__c.sObjectType, 'UT_CostDistLine');
                //System.debug(System.LoggingLevel.WARN, '___cdl='+cdl[0]);
                System.Debug(System.LoggingLevel.WARN, '___CDL SOQL='+Limits.getQueries());
                
                //// Step 13: BILLING
                List<Billing__c> billings = Test.loadData(Billing__c.sObjectType, 'UT_Billing');
                //System.debug(System.LoggingLevel.WARN, '___billing='+billing[0]);
                System.Debug(System.LoggingLevel.WARN, '___Billing SOQL='+Limits.getQueries());
                
                // Turn OFF all Budget triggers
                ECO_BudgetHeaderTriggers.run = false;
                ECO_BudgetTaskTriggers.run = false;
                ECO_BudgetResourceTriggers.run = false;
                ECO_BudgetAssignmentTriggers.run = false;
                
                //// Step 14: BUDGET HEADER
                List<BudgetHeader__c> bHeaders = Test.loadData(BudgetHeader__c.sObjectType, 'UT_BudgetHeader');
                system.debug('___bHeaders: ' + bHeaders);
                //System.debug(System.LoggingLevel.WARN, '___bHeader='+bHeader[0]);
                System.Debug(System.LoggingLevel.WARN, '___BH SOQL='+Limits.getQueries());
                List<BudgetHeader__c> tmpBHs = new List<BudgetHeader__c>();
                bHeaders[0].status__c = 'Approved';
                tmpBHs.add(bHeaders[0]);
                bHeaders[1].status__c = 'Unapproved';
                tmpBHs.add(bHeaders[1]);
                bHeaders[2].status__c = 'Forecast';
                tmpBHs.add(bHeaders[2]);
                bHeaders[3].status__c = 'Estimate';
                tmpBHs.add(bHeaders[3]);
                
                update tmpBHs;
                system.debug('___tmpBHs: ' + tmpBHs);

                //// Step 15: BUDGET TASK
                
                List<BudgetTask__c> bTasks = Test.loadData(BudgetTask__c.sObjectType, 'UT_BudgetTask');

                //System.debug(System.LoggingLevel.WARN, '___bTask='+bTask[0]);
                //System.debug(System.LoggingLevel.WARN, '___bTasks='+bTasks.size());
                System.Debug(System.LoggingLevel.WARN, '___BT SOQL='+Limits.getQueries());
                
                
                //// Step 16: BUDGET RESOURCE
                
                List<BudgetResource__c> bResources = Test.loadData(BudgetResource__c.sObjectType, 'UT_BudgetResource');
                //System.debug(System.LoggingLevel.WARN, '___bResource='+bResource[0]);
                //System.debug(System.LoggingLevel.WARN, '___bResources='+bResources.size());
                List<BudgetResource__c> tmpBRs = new List<BudgetResource__c>();
                bResources[0].PLReportCategory__c = 'ODC - Exps'; tmpBRs.add(bResources[0]);
                bResources[1].PLReportCategory__c = 'ODC - Subs'; tmpBRs.add(bResources[1]);
                bResources[2].PLReportCategory__c = 'ODC - Contingency'; tmpBRs.add(bResources[2]);
                bResources[3].PLReportCategory__c = 'Labor';  bResources[3].ProjectTeamMember__c = ptm.id; tmpBRs.add(bResources[3]);
                bResources[4].PLReportCategory__c = 'Fringe'; tmpBRs.add(bResources[4]);
                bResources[5].PLReportCategory__c = 'Overhead'; tmpBRs.add(bResources[5]);
                bResources[6].PLReportCategory__c = ''; tmpBRs.add(bResources[6]);
                bResources[7].PLReportCategory__c = 'ODC - Exps'; tmpBRs.add(bResources[7]);
                bResources[8].PLReportCategory__c = 'ODC - Subs'; bResources[8].VendorSite__c = vendorSite.Id; tmpBRs.add(bResources[8]);
                bResources[9].PLReportCategory__c = 'ODC - Contingency'; tmpBRs.add(bResources[9]);
                bResources[10].PLReportCategory__c = 'Labor'; tmpBRs.add(bResources[10]);
                bResources[11].PLReportCategory__c = 'Fringe'; tmpBRs.add(bResources[11]);
                bResources[12].PLReportCategory__c = 'Overhead'; tmpBRs.add(bResources[12]);
                bResources[13].PLReportCategory__c = ''; tmpBRs.add(bResources[13]);
                bResources[14].PLReportCategory__c = 'ODC - Exps'; tmpBRs.add(bResources[14]);
                bResources[15].PLReportCategory__c = 'ODC - Subs'; tmpBRs.add(bResources[15]);
                bResources[16].PLReportCategory__c = 'ODC - Contingency'; tmpBRs.add(bResources[16]);
                bResources[17].PLReportCategory__c = 'Labor'; tmpBRs.add(bResources[17]);
                bResources[18].PLReportCategory__c = 'Fringe'; tmpBRs.add(bResources[18]);
                bResources[19].PLReportCategory__c = 'Overhead'; tmpBRs.add(bResources[19]);
                bResources[20].PLReportCategory__c = ''; tmpBRs.add(bResources[20]);
                bResources[21].PLReportCategory__c = 'ODC - Exps'; tmpBRs.add(bResources[21]);
                bResources[22].PLReportCategory__c = 'ODC - Subs'; tmpBRs.add(bResources[22]);
                bResources[23].PLReportCategory__c = 'ODC - Contingency'; tmpBRs.add(bResources[23]);
                bResources[24].PLReportCategory__c = 'Labor'; tmpBRs.add(bResources[24]);
                bResources[25].PLReportCategory__c = 'Fringe'; tmpBRs.add(bResources[25]);
                bResources[26].PLReportCategory__c = 'Overhead'; tmpBRs.add(bResources[26]);
                bResources[27].PLReportCategory__c = ''; tmpBRs.add(bResources[27]);
                bResources[28].PLReportCategory__c = 'ODC - Exps'; tmpBRs.add(bResources[28]);
                bResources[29].PLReportCategory__c = 'ODC - Subs'; tmpBRs.add(bResources[29]);
                bResources[30].PLReportCategory__c = 'ODC - Contingency'; tmpBRs.add(bResources[30]);
                bResources[31].PLReportCategory__c = 'Labor'; tmpBRs.add(bResources[31]);
                bResources[32].PLReportCategory__c = 'Fringe'; tmpBRs.add(bResources[32]);
                bResources[33].PLReportCategory__c = 'Overhead'; tmpBRs.add(bResources[33]);
                bResources[34].PLReportCategory__c = ''; tmpBRs.add(bResources[34]);
                bResources[35].PLReportCategory__c = 'ODC - Exps'; tmpBRs.add(bResources[35]);
                bResources[36].PLReportCategory__c = 'ODC - Subs'; tmpBRs.add(bResources[36]);
                bResources[37].PLReportCategory__c = 'ODC - Contingency'; tmpBRs.add(bResources[37]);
                bResources[38].PLReportCategory__c = 'Labor'; tmpBRs.add(bResources[38]);
                bResources[39].PLReportCategory__c = 'Fringe'; tmpBRs.add(bResources[39]);
                bResources[40].PLReportCategory__c = 'Overhead'; tmpBRs.add(bResources[40]);     
                bResources[41].PLReportCategory__c = 'Forecast'; tmpBRs.add(bResources[41]); 

                for(BudgetResource__c br : tmpBRs) {
                    br.IsHidden__c = false;
                }
                update tmpBRs;
                System.Debug(System.LoggingLevel.WARN, '___BResource SOQL='+Limits.getQueries());
                
                //// Step 17: BUDGET ASSIGNMENT
               
                List<BudgetAssignment__c> bAssignments = Test.loadData(BudgetAssignment__c.sObjectType, 'UT_BudgetAssignment');
                
                for (BudgetAssignment__c ba : bAssignments) {
                    //To increase code coverage path:
                    if (ba.Status__c == 'Forecast') {
                        ba.OverrideTotalCost__c = 1; 
                        update ba;
                        break;
                    }
                }
                System.Debug(System.LoggingLevel.WARN, '___BAssignment SOQL='+Limits.getQueries());
                
                // Step 18: Generate WeeklyRollupEntries
                ECO_WeeklyRollupEntryTriggers.run = false;
                List<WeeklyRollupEntry__c> wklyRollupEntries = Test.loadData(WeeklyRollupEntry__c.sObjectType, 'UT_WeeklyRollupEntry');
                System.Debug(System.LoggingLevel.WARN, '___WRE SOQL='+Limits.getQueries());
                
                // Step 19-20: EarnedValueSnapshots
                ECO_EarnedValueSnapshotTriggers.run = false;
                List<EarnedValueSnapshot__c> evs = Test.loadData(EarnedValueSnapshot__c.sObjectType, 'UT_EarnedValueSnapshot');
                System.Debug(System.LoggingLevel.WARN, '___EVS SOQL='+Limits.getQueries());
                
        ///NEW:
                OrganizationString__c orgString = new OrganizationString__c();
                orgString.Name = '80.AECOM NZ LTD.NZHAM1.2594';
                orgString.Region__c = 'ANZ NZ';
                orgString.BusinessLineName__c = 'Water';
                insert orgString;
                OrganizationString__c os = [SELECT Id, Name, District__c, Region__c, BusinessLineName__c
                    FROM OrganizationString__c WHERE Name=: orgString.Name LIMIT 1];
                System.debug('___orgString='+orgString);
                
                Id sApproved = ECO_Utils_Meta.getRecordTypeId(pse__Proj__c.sObjectType, 'Customer Project (Approved)');

                List<ProjectOrganization__c> poList = new List<ProjectOrganization__c>();
                for (Pse__Proj__c proj : projects) {
                    ProjectOrganization__c po = new ProjectOrganization__c();
                    po.Project__c = proj.Id;
                    po.Type__c = 'Primary';
                    po.ContributionPercent__c = 100; 
                    po.OrganizationString__c = testOrg.Id;
                    proj.CarryingOutOrganization__c = testOrg.Id;
                    proj.DateLastCompletedBudgetQuestionnaire__c = Date.today();
                    proj.BudgetStrategy__c = 'Top Task';
                    proj.recordTypeId = sApproved;
                    poList.add(po);
                }
                insert poList;
                System.debug('___poList='+poList);
               

                List<Agreement__c> agList = new List<Agreement__c>();
                
                RecordType rt2 = new RecordType();
                rt2.Name = 'Prime';
                //RecordType rt2 = [SELECT Id, Name FROM RecordType WHERE Name='Prime' LIMIT 1];
                
                for (Pse__Proj__c proj : projects) {
                    Agreement__c ag = new Agreement__c();
                    ag.Project__c = proj.Id;
                    ag.AgreementType__c = 'AECOM Standard with Deviations';
                    ag.RecordType = rt2;
                    ag.Amount__c = 100;
                    agList.add(ag);
                }
                insert agList;
                System.debug('___agList='+agList);
                
                List<Agreement__c> agList2 = [SELECT Id, Project__c FROM Agreement__c];
                
                List<ProjectAgreement__c> paList = new List<ProjectAgreement__c>();
                for (Agreement__c ag : agList2) {
                    ProjectAgreement__c pa = new ProjectAgreement__c();
                    pa.Project__c = ag.Project__c;
                    pa.Agreement__c = ag.Id;
                    paList.add(pa);
                }
                insert paList;

                update projects;

    }
    
/* Some reusable methods added by Sujit 
 * Does not follow the builder pattern used above - lack of time
 * Used in ECO_ProjectPlanControllerPdfTest class
 */
 
    public static DOAApprovalRequest__c createDOAApprovalRequest(Id projectId) {
        DOAApprovalRequest__c dr = new DOAApprovalRequest__c(project__c=projectId);
        insert dr;
        return dr;
    }
    
    public static User createTestUserManager(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];

        User testUserManager = new User();
        testUserManager.Alias = 'manager';
        testUserManager.Email ='testmanager_consultant@example.com';
        testUserManager.EmailEncodingKey ='UTF-8';
        testUserManager.FirstName = 'test';
        testUserManager.LastName ='manager';
        testUserManager.LanguageLocaleKey ='en_US';
        testUserManager.LocaleSidKey ='en_US';
        testUserManager.ProfileId = p.Id;
        testUserManager.TimeZoneSidKey ='America/Los_Angeles';
        testUserManager.UserName ='testmanager@example.com';
        insert testUserManager;
        return testUserManager;
    }
    
    public static List<ProjectTeamMember__c> createProjectTeamMembers(Id profileId, Id projectId, Id projectRoleId, Id managerUserId, Integer numTeamMembers) {
        List<User> testUsers = new List<User>();
        for (Integer i=0; i < numTeamMembers; i++) {
            User testUser = new User();
            testUser.Alias = 'myuser' + i;
            testUser.Email ='mytestuser' + i + '_consultant@example.com';
            testUser.EmailEncodingKey ='UTF-8';

            testUser.FirstName = 'test' + i;
            testUser.LastName ='Testing' + i;
            testUser.LanguageLocaleKey ='en_US';
            testUser.LocaleSidKey ='en_US';
            testUser.ProfileId = profileId;
            testUSer.TimeZoneSidKey ='America/Los_Angeles';
            testUser.UserName ='mytestuser' + i + '@example.com';
            testUser.EmployeeNumber = String.valueOf(i);
            testUser.PersonId__c = String.valueOf(i);
            testUser.ManagerId = managerUserId;
            testUsers.add(testUser);
        }
        insert testUsers;

        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
        List<Contact> contacts = new List<Contact>();
        for (User testUser : testUsers) {
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
        insert contacts;

        List<ProjectTeamMember__c> testProjectTeamMembers = new List<ProjectTeamMember__c>();
        integer counter  = 0;
        for (Contact testContact : contacts) {        
            testContact.User__c = testContact.pse__Salesforce_User__c;
            ProjectTeamMember__c member = new ProjectTeamMember__c();           
            member.Project__c = projectId;         
            member.CurrencyIsoCode = 'USD'; 
            member.ProjectRole__c = projectRoleId;
            member.Contact__c = testContact.Id;
            member.StartDate__c = Date.today().addDays(counter);
            member.EndDate__c = Date.today().addDays(counter + 1);
            testProjectTeamMembers.add(member);     
            counter = counter + 2;
        }
        insert testProjectTeamMembers;
        return testProjectTeamMembers;
    }
    
    public static TemplateQuestion__c createTemplateQuestion(String title, Id quesTempId) {
        TemplateQuestion__c templateQuestion = new TemplateQuestion__c(RiskTitle__c = title, QuestionnaireTemplate__c = quesTempId);
        insert templateQuestion;
        return templateQuestion;
    }
    
    public static QuestionnaireTemplate__c createQuestionnaireTemplate() {
        QuestionnaireTemplate__c questionnaireTemplate = new QuestionnaireTemplate__c();
        insert questionnaireTemplate;
        return questionnaireTemplate;
    }
    
    public static Questionnaire__c createQuestionnaire(String questionnaireName, Id quesSetId) {
        Questionnaire__c questionnaire = new Questionnaire__c(Name = questionnaireName, QuestionnaireSet__c = quesSetId);
        insert questionnaire;
        return questionnaire;   
    }
    
    public static QuestionnaireSet__c createQuestionnaireSet(Id projectId) {
        QuestionnaireSet__c questionnaireSet = new QuestionnaireSet__c(Project__c = projectId);
        insert questionnaireSet;
        return questionnaireSet;
    }
    
    public static OrganizationString__c createOrgString(Id testContactId) {
        OrganizationString__c organizationString = new OrganizationString__c(Name = 'Test Organization', ProjectAccountant2__c = testContactId, PLManagerContact__c = testContactId);
        insert organizationString;
        return organizationString;
    }
    
    public static Account createAccount() {
        Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;
        return testAccount;
    }

    public static AECOM_Primary_Department__c createAecomPrimaryDept() {
        String description = 'testDescription';
        AECOM_Primary_Department__c primaryDept = new AECOM_Primary_Department__c(Lead_Region__c = 'test Lead Region');
        insert primaryDept;
        return primaryDept;
    }
    
    public static Opportunity createOpportunity(String stageName, Id aecomPrimaryDeptId) {
        Opportunity opp = new Opportunity(Name = 'source', StageName = stageName, CloseDate = Date.today(), AECOM_Primary_Dept_Lookup__c = aecomPrimaryDeptId);
        opp.Enterprise_Service__c = 'Engineering'; // Required field, using a picklist value
        opp.ValidateGo__c = false;
        insert opp;
        return opp;
    }
    
    public static pse__Proj__c createProject(Id orgId, Id testAcctId, Id oppId, Date startDate, Date endDate) {
        pse__Proj__c testProject = ECO_Utils_Testing.createTestProject('test project1');
        testProject.CarryingOutOrganization__c = orgId;
        testProject.pse__Account__c = testAcctId;
        testProject.pse__Opportunity__c = oppId;
        testProject.pse__Start_Date__c = startDate;
        testProject.pse__End_Date__c = endDate;
        testProject.ValidateGo__c = false;
        insert testProject;
        return testProject;
    }
    
    public static Site__c createSite(Id testAcctId) {
        Site__c testSite = new Site__c();
        testSite.Account__c = testAcctId;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';
        insert testSite;
        return testSite;
    }
    
    public static Contact createContact(User testUser, Account testAccount, Site__c testSite) {
        return createContact(testUser, testAccount, testSite, 'PSA Resource');
    }
        
    public static Contact createContact(User testUser, Account testAccount, Site__c testSite, String recordTypeName) {
        Contact testContact = new Contact();
        testContact.Email = testUser.Email;
        testContact.FirstName = testUser.FirstName;
        testContact.LastName =  testUser.LastName;
        testContact.Phone = '55555555555';
        testContact.pse__Salesforce_User__c = testUser.Id;
        
        testContact.RecordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, recordTypeName);
        
        testContact.User__c = testUser.Id;
        testContact.OwnerId = testUser.Id;
        testContact.Site__c = testSite.Id;
        testContact.AccountId = testAccount.Id;
        testContact.pse__Is_Resource_Active__c = true;
        testContact.pse__Is_Resource__c = true;
        insert testContact;
        return testContact;
    }

    public static Project_Site__c createProjectSite(Id testProjectId, Id testSiteId){
        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = testProjectId;
        testProjectSite.Site__c = testSiteId;
        testProjectSite.Contribution__c = 100;
        insert testProjectSite;
        return testProjectSite;
    }
    
    public static ProjectTeamMember__c createProjectTeamMember(Id projectId, Id projectRoleId, Id testContactId, Date startDate, Date endDate) {
        ProjectTeamMember__c projTeamMember = new ProjectTeamMember__c(Project__c = projectId, CurrencyIsoCode = 'USD', ProjectRole__c = projectRoleId, Contact__c = testContactId, StartDate__c = startDate, EndDate__c = endDate);
        return projTeamMember;
    }
    
    public static SurveySchedule__c createSurveySchedule(Id testAccountId, Id testSiteId, Id testContactId, Id projectId, Date scheduledDate) {
        SurveySchedule__c surveySchedule = new SurveySchedule__c(Account__c = testAccountId, Client__c = testSiteId, Contact__c = testContactId, Project__c = projectId, ScheduledDate__c = scheduledDate);
        insert surveySchedule;
        return surveySchedule;
    }
    
    public static Deliverable__c createDeliverable(Id projectId) {
        Deliverable__c oDeliver = new Deliverable__c();
        oDeliver.Project__c = projectId;
        oDeliver.Name = 'New Deliverable';
        insert oDeliver;
        return oDeliver;
    }
    
    public static ProjectReviewTemplate__c createProjectReviewTemplate() {
        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(TemplateType__c = 'BIM Healthy Start');
        insert prt;
        return prt;
    }
    
    public static List<pse__Project_Task__c> createTaskForProjectFunding(Id projectId, Integer numTestProjectTasks) {
        List<pse__Project_Task__c> testProjectTasks = new List<pse__Project_Task__c>();
        
        for (Integer i =0; i<numTestProjectTasks; i++) {
            pse__Project_Task__c task = new pse__Project_Task__c();
            task.Name = 'task' + i;
            task.pse__Project__c = projectId;
            task.pse__Start_Date_Time__c = DateTime.now().addDays(i);
            task.pse__End_Date_Time__c = DateTime.now().addDays(i+1);
            task.pse__Status__c = 'Draft';
            task.ProjectTaskNumber__c = 'tasknumber' + i;
            task.pse__Description__c = 'task' + i + 'longname';
            task.WorkTypeName__c = 'Home Office';
            task.CostIndRateSCHID__c = '6748';

            testProjectTasks.add(task);
        }
            
        insert testProjectTasks;
        return testProjectTasks;
    }
    
    public static Assumption__c createAssumption(Id projectId) {
        Assumption__c testAssumption = new Assumption__c();
        testAssumption.Project__c = projectId;
        testAssumption.Assumption__c = 'Test Assumption';
        testAssumption.PlanElement__c = 'Budget';
        insert testAssumption;
        return testAssumption;
    } 
    
    public static Funding__c createFundingForAgreements(Id projectId, Id agreementId, Id projectTaskId) {
        Funding__c funding = new Funding__c(Project__c = projectId, Agreement__c = agreementId);
        funding.AllocatedAmount__c = 10000;
        funding.DateAllocatedDate__c = Date.today();
        funding.ProjectTask__c = projectTaskId;
        insert funding;
        return funding;
    }
                                    
    public static Assumption__c addAssumptionsForProject(pse__Proj__c myProj) {
        Assumption__c assump1 = new Assumption__c(Assumption__c = 'assump_1', PlanElement__c = 'Budget', Project__c = myProj.Id);
        insert assump1;
        return assump1;
    }
    
    public static VendorSite__c createVendorandSiteAndVendorSite(Id projectId, Id accountId) {
        Site__c site = new Site__c();
        site.Account__c = accountId;
        site.PaymentTerms__c = 'Immediate';
        site.VendorSiteID__c  = '123456';
        insert site;

        VendorSite__c vendorSite = new VendorSite__c();
        vendorSite.Site__c = site.Id;
        vendorSite.Project__c = projectId;

        insert vendorSite;
        return vendorSite;
    }
    
    public static BudgetHeader__c createBudgetHeader(Id projectId) {
        BudgetHeader__c bh = new BudgetHeader__c(Project__c = projectId, Status__c ='Forecast');
        insert bh;
        return bh;
    }
    
    public static CountryRisk__c createCountryRisk(String name, String alias) {
        CountryRisk__c cr = new CountryRisk__c (name=name , alias__c=alias);
        insert cr;
        return cr;
    }
    
}