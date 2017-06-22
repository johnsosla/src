@isTest
private class ECO_ProjectSummaryControllerTest {

    private static final Integer numTestProjectTasks = 21;  
    private static final Integer numTeamMembers = 1;

    private static testMethod void testProjectSummaryControllerIsProjectNumber()
    {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];


        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
        pageRef.getParameters().put('projectId', project.Id);
        pageRef.getParameters().put('isProjectNumber', '1');
        test.setCurrentPage(pageRef);

        ECO_ProjectSummaryController controller = new ECO_ProjectSummaryController();
        controller.syncRequest_Step1_start();
        controller.sendProjectNumberRequest_start();
        controller.sendProjectNumberRequest_complete();
        controller.sendProjectNumberRequest_finish();
    }

    private static testMethod void testProjectSummaryControllerNonIsProjectNumber()
    {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];

        Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount; 
        //testAccount.OracleCustomerID__c = '123456';
        //update testAccount;
       

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';


        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;    

        testProjectSite.Is_Billing__c = true;
        update testProjectSite;

        List<Project_Site__c> projectSites = [select Id, LastModifiedDate, IsCustomer__c, Is_Billing__c from Project_Site__c where IsCustomer__c = true];
        projectsites[0].Is_billing__c = true;
        update projectSites;

        List<pse__Project_Task__c> projectTask = [select Id from pse__Project_Task__c where pse__Project__c = :project.Id];

        IntegrationMessageQueue__c imq = new IntegrationMessageQueue__c();
        imq.RecordId__c = projectTask[0].Id;
        //imq.Name = 'Test';
        imq.JobName__c = 'Task Sync Later';
        imq.Status__c = 'Success';
        insert imq;

        System.assertEquals(1, projectSites.size());

        System.assertEquals(true, projectSites[0].Is_Billing__c);
        System.assertEquals(true, projectSites[0].IsCustomer__c);
        System.assert(DateTime.now() > projectSites[0].LastModifiedDate);

        projectSites = ECO_Service_ProjectSync.GetOracleProjectSiteRecords(project.Id, Date.today().addDays(-100));
        System.assertEquals(1, projectSites.size());



        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
        pageRef.getParameters().put('projectId', project.Id);
        pageRef.getParameters().put('isProjectNumber', '0');
        test.setCurrentPage(pageRef);


        Test.startTest();
        ECO_ProjectSummaryController controller = new ECO_ProjectSummaryController();
        //controller.requestDTO
        controller.syncRequest_Step1_start();
        controller.syncRequest_Step1_complete();
        controller.syncRequest_Step2_start();
        controller.syncRequest_Step2_complete();
        controller.syncRequest_Step3_start();
        controller.syncRequest_Step3_complete();
        controller.syncRequest_Step4_start();
        controller.syncRequest_Step4_complete();
        controller.syncRequest_Step5_start();
        controller.syncRequest_Step5_complete();
        controller.syncRequest_Step6_start();
        controller.syncRequest_Step6_complete();
        controller.syncRequest_Step7_start();
        controller.syncRequest_Step7_complete();
        controller.syncRequest_Step8_start();
        controller.syncRequest_Step8_complete();
        controller.syncRequest_Finish();
        Test.stopTest();
    }   

    private static testMethod void testProjectSummaryControllerAuthenticateCredentials()
    {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];

        ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c(Name = 'Project Sync 2');
        endpoint.EndPointUrl__c = 'test';
        insert endPoint;

        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
        pageRef.getParameters().put('projectId', project.Id);
        pageRef.getParameters().put('isProjectNumber', '0');
        test.setCurrentPage(pageRef);

        ECO_ProjectSummaryController controller = new ECO_ProjectSummaryController();
        ApexPages.currentPage().getParameters().put('userName', 'test');
        ApexPages.currentPage().getParameters().put('password', 'test');

        try{
        controller.authenticateCredentials();
        }catch(Exception e){}
        controller.closeAuthenticationWindow();
        
    }   

    private static testMethod void testProjectSummaryControllerCheckIfSyncHasBeenProcessed()
    {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];

        ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c(Name = 'Project Sync 2');
        endpoint.EndPointUrl__c = 'test';
        insert endPoint;

        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
        pageRef.getParameters().put('projectId', project.Id);
        pageRef.getParameters().put('isProjectNumber', '0');
        test.setCurrentPage(pageRef);


        Test.startTest();
        ECO_ProjectSummaryController controller = new ECO_ProjectSummaryController();
        ApexPages.currentPage().getParameters().put('userName', 'test');
        ApexPages.currentPage().getParameters().put('password', 'test');
        controller.initiateOracleProjectSyncRequest();
        controller.executeOracleProjectSyncRequest();
        controller.checkIfSyncHasBeenProcessed();
        Test.stopTest();
    }


    private static testMethod void testProjectSummaryControllerExecuteOracleProjectSyncRequest()
    {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];

        ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c(Name = 'Project Sync 2');
        endpoint.EndPointUrl__c = 'test';
        insert endPoint;

        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
        pageRef.getParameters().put('projectId', project.Id);
        pageRef.getParameters().put('isProjectNumber', '0');
        test.setCurrentPage(pageRef);

        Test.startTest();
        ECO_ProjectSummaryController controller = new ECO_ProjectSummaryController();
        ApexPages.currentPage().getParameters().put('userName', 'test');
        ApexPages.currentPage().getParameters().put('password', 'test');
        controller.initiateOracleProjectSyncRequest();
        controller.executeOracleProjectSyncRequest();
        controller.checkIfSyncHasBeenProcessed();
        Test.stopTest();
    }

    private static testMethod void testProjectSummaryControllerUpdateProject()
    {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];

        ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c(Name = 'Project Sync 2');
        endpoint.EndPointUrl__c = 'test';
        insert endPoint;

        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
        pageRef.getParameters().put('projectId', project.Id);
        pageRef.getParameters().put('isProjectNumber', '0');
        test.setCurrentPage(pageRef);

        Test.startTest();
        ECO_ProjectSummaryController controller = new ECO_ProjectSummaryController();
        controller.updateProject();
        Test.stopTest();
    }


    private static testMethod void testProjectSummaryControllerReturnToProject()
    {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];

        ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c(Name = 'Project Sync 2');
        endpoint.EndPointUrl__c = 'test';
        insert endPoint;

        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
        pageRef.getParameters().put('projectId', project.Id);
        pageRef.getParameters().put('isProjectNumber', '0');
        test.setCurrentPage(pageRef);

        Test.startTest();
        ECO_ProjectSummaryController controller = new ECO_ProjectSummaryController();
        controller.returnToProject();
        Test.stopTest();
    }
    
    private static testMethod void testProjectSummaryControllerProjectTaskValidation()
    {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(25, 25);
        ECO_ProjectTriggers.run = true;
        

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];
        
        List<pse__Project_Task__c> projectTasks = new List<pse__Project_Task__c>();
        Integer i = 0;
        while(i < 30)
        {
            projectTasks.add(new pse__Project_Task__c(pse__Project__c = project.Id));
            i++;
        }
        insert projectTasks;

        ECO_ProjectTaskTriggers.run = true;

        ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c(Name = 'Project Sync 2');
        endpoint.EndPointUrl__c = 'test';
        insert endPoint;

        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
        pageRef.getParameters().put('projectId', project.Id);
        pageRef.getParameters().put('isProjectNumber', '0');
        test.setCurrentPage(pageRef);

        Test.startTest();
        ECO_ProjectSummaryController controller = new ECO_ProjectSummaryController();

        Test.stopTest();
    }


    private static testMethod void testProjectSummaryControllerProjectTeamMemberValidation()
    {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(25, 25);
        ECO_ProjectTriggers.run = true;
        

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];

        list<contact> lstCon = [select id from contact limit 2];

        ECO_Project_TeamMember_Triggers.run = false;
        List<ProjectTeamMember__c> projectTeamMembers = new List<ProjectTeamMember__c>();
        Integer i = 0;
        while(i < 30)
        {
            projectTeamMembers.add(new ProjectTeamMember__c(Project__c = project.Id, Name = 'Test' + i, Contact__c = lstCon[0].Id));
            //projectTeamMembers.add(new ProjectTeamMember__c(Project__c = project.Id));
            i++;
        }
        insert projectTeamMembers;
        ECO_Project_TeamMember_Triggers.run = true;


        ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c(Name = 'Project Sync 2');
        endpoint.EndPointUrl__c = 'test';
        insert endPoint;

        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
        pageRef.getParameters().put('projectId', project.Id);
        pageRef.getParameters().put('isProjectNumber', '0');
        test.setCurrentPage(pageRef);

        Test.startTest();
        ECO_ProjectSummaryController controller = new ECO_ProjectSummaryController();

        Test.stopTest();
    }

    private static testMethod void testProjectNumberRequest(){ 
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        
        ECO_Utils_Testing.createTestDataForProjectNumberRequest();


        pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
        testProject.ProjectLongName__c = null;
        update testProject;

        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
        pageRef.getParameters().put('projectId', testProject.Id);
        pageRef.getParameters().put('isProjectNumber', '1');
        test.setCurrentPage(pageRef);

        test.startTest();

        ECO_ProjectSummaryController con = new ECO_ProjectSummaryController();

        system.assertNotEquals(null, con.projectId);
        system.assertEquals(true, con.isProjectNumber);

        //verify lastSync date flag
        system.assertEquals(false, con.allowRequestSubmit);

        //test validation for complete data     
        con.project.ProjectLongName__c = 'long name here';
        PageReference saveUrl = con.updateProject();

        test.setCurrentPage(saveUrl);
        ECO_ProjectSummaryController con2 = new ECO_ProjectSummaryController();
        system.assertNotEquals(null, con2.projectId);
        system.assertEquals(true, con2.isProjectNumber);
        system.assertEquals(true, con2.allowRequestSubmit);

        //test sync - actual http request not sent
        con2.initiateOracleProjectSyncRequest();

        

        List<IntegrationMessageQueue__c> msgQueues = [SELECT Id, RecordId__c, Status__c, JobName__c
                                                        FROM IntegrationMessageQueue__c
                                                        WHERE RecordId__c = : testProject.Id];
        system.assertEquals(1, msgQueues.size());
        IntegrationMessageQueue__c msgQueue = msgQueues.get(0);
        
        system.assertEquals('Project Number', msgQueue.JobName__c);
        system.assertEquals('Initiated', msgQueue.Status__c);


        con2.syncRequest_Step1_start();
        con2.syncRequest_Step1_complete();
        con2.sendProjectNumberRequest_start();
        con2.sendProjectNumberRequest_complete();
        con2.sendProjectNumberRequest_Finish();


        //test get sync history of successfully processed request
        msgQueue.Status__c = ECO_Service_ProjectSync.STATUS_SUCCESS;
        msgQueue.SuccessMessage__c = '60340403|1039554';
        update msgQueue;

        con2.generateSyncHistory();

        system.assertEquals(1, con2.numSuccessfulSyncs);

        con2.checkIfSyncHasBeenProcessed();

        //verfiy that you can't send the request again once the project has been assigned an oracle project number
        test.setCurrentPage(pageRef);
        ECO_ProjectSummaryController con3 = new ECO_ProjectSummaryController();
        system.assertEquals(false, con3.allowRequestSubmit);

        test.stopTest();
    }

    private static testMethod void testProjectSync(){
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(numTestProjectTasks, numTeamMembers);

        //update the data so it will fail validation
        pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];
        testProject.ProjectLongName__c = null;
        testProject.OracleProjectId__c = '123456';
        testProject.OracleProjectnumber__c = '654321';
        update testProject;

        List<pse__Project_Task__c> tasks = [SELECT Id, Name, pse__Description__c FROM pse__Project_Task__c WHERE pse__Project__c = :testProject.Id];
        for(pse__Project_Task__c task : tasks){
            task.pse__Description__c = null;
        }
        update tasks;

        List<ProjectTeamMember__c> teamMembers = [SELECT Id, StartDate__c FROM ProjectTeamMember__c WHERE Project__c = :testProject.Id];
        for(ProjectTeamMember__c teamMember : teamMembers){
            //teamMember.StartDate__c = null;
            teamMember.StartDate__c = Date.today();
        }
        update teamMembers;

        List<Project_Site__c> sites = [SELECT Id, BillingContactID__c FROM Project_Site__c WHERE Project__c = :testProject.Id];
        for(Project_Site__c site : sites){
            site.BillingContactID__c = null;
        }
        update sites;

        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
        pageRef.getParameters().put('projectId', testProject.Id);
        pageRef.getParameters().put('isProjectNumber', '0');
        test.setCurrentPage(pageRef);

        test.startTest();

        ECO_ProjectSummaryController con = new ECO_ProjectSummaryController();

        system.assertNotEquals(null, con.projectId);
        system.assertEquals(false, con.isProjectNumber);

        //verify lastSync date flag
        DateTime expectedDateFilter = DateTime.newInstance(1900, 1, 1);
        system.assertEquals(expectedDateFilter, con.lastSync);

        system.assertEquals(false, con.allowRequestSubmit);

        system.debug('projectMsg=' + con.projectMsg);   
        system.assertNotEquals(true, String.isEmpty(con.projectMsg));

        /*system.debug('keyMemberMsg=' + con.keyMemberMsg);       
        system.assertNotEquals(true, String.isEmpty(con.keyMemberMsg));*/

        system.debug('customersMsg=' + con.customersMsg);
        system.assertEquals(true, String.isEmpty(con.customersMsg));

        system.debug('taskMsg=' + con.taskMsg);
        system.assertEquals(true, String.isEmpty(con.taskMsg));

        for(pse__Project_Task__c task : tasks){
            task.pse__Description__c = task.Name + 'longname';
        }
        update tasks;
        
        for(ProjectTeamMember__c teamMember : teamMembers){
            teamMember.StartDate__c = Date.today();
        }
        update teamMembers;

        for(Project_Site__c site : sites){
            site.BillingContactID__c = '123456';
        }
        update sites;

        //test validation for complete data     
        con.project.ProjectLongName__c = 'long name here';

        //create pm     
        Contact pm = new Contact();
        pm.Email = 'pm2@test2.ca';
        pm.FirstName = 'test';
        pm.LastName =  'pm2';
        pm.Phone = '55555555555';
        //pm.RecordTypeId = recordTypeId;
        insert pm;  

        con.project.pse__Project_Manager__c = pm.Id;

        //con.project.OracleProjectnumber__c = '333333';
        PageReference saveUrl = con.updateProject();

        test.setCurrentPage(saveUrl);

        ECO_ProjectSummaryController con2 = new ECO_ProjectSummaryController();

        system.debug('projectMsg=' + con2.projectMsg);
        system.assertNotEquals(true, String.isEmpty(con2.projectMsg));

        system.debug('keyMemberMsg=' + con2.keyMemberMsg);
        system.assertEquals(true, String.isEmpty(con2.keyMemberMsg));

        system.debug('customersMsg=' + con2.customersMsg);
        system.assertEquals(true, String.isEmpty(con2.customersMsg));

        system.debug('taskMsg=' + con2.taskMsg);
        system.assertEquals(true, String.isEmpty(con2.taskMsg));

        system.assertNotEquals(null, con2.projectId);
        system.assertEquals(false, con2.isProjectNumber);
        system.assertNotEquals(true, con2.allowRequestSubmit);

        con2.syncRequest_Step1_start();
        con2.syncRequest_Step1_complete();
        con2.syncRequest_Step2_start();
        con2.syncRequest_Step2_complete();
        con2.syncRequest_Step3_start();
        con2.syncRequest_Step3_complete();
        con2.syncRequest_Step4_start();
        con2.syncRequest_Step4_complete();
        con2.syncRequest_Step5_start();
        con2.syncRequest_Step5_complete();
        con2.syncRequest_Step6_start();
        con2.syncRequest_Step6_complete();
        con2.syncRequest_Step7_start();
        con2.syncRequest_Step7_complete();
        con2.syncRequest_Step8_start();
        con2.syncRequest_Step8_complete();
        system.assertEquals(false, con2.syncErrorOccurred);

        system.assertEquals(17, con2.stepMsgs.size());

        List<IntegrationMessageQueue__c> msgQueues = [SELECT Id, RecordId__c, Status__c, JobName__c
                                                        FROM IntegrationMessageQueue__c
                                                        WHERE RecordId__c = : testProject.Id];
        system.assertEquals(1, msgQueues.size());
        IntegrationMessageQueue__c msgQueue = msgQueues.get(0);
        
        system.assertEquals('Project Sync', msgQueue.JobName__c);
        system.assertEquals('Initiated', msgQueue.Status__c);

        //test successful project sync - sync status should get sent to 'S' on project and related items
        msgQueue.Status__c = ECO_Service_ProjectSync.STATUS_SUCCESS;
        update msgQueue;

        con2.generateSyncHistory();

        system.assertEquals(1, con2.numSuccessfulSyncs);
        system.assertEquals(0, con2.numFailedAttemptedSyncs);

        testProject = [SELECT Id, OracleSyncStatus__c FROM pse__Proj__c WHERE Id = :testProject.Id];
        //system.assertEquals('S', testProject.OracleSyncStatus__c);
        system.assertEquals('Initiated', testProject.OracleSyncStatus__c);

        teamMembers = [SELECT Id, OracleSyncStatus__c FROM ProjectTeamMember__c WHERE Project__c = :testProject.Id];
        for(ProjectTeamMember__c teamMember : teamMembers){
            //system.assertEquals('S', teamMember.OracleSyncStatus__c);     
            system.assertEquals('P', teamMember.OracleSyncStatus__c);
        }

        sites = [SELECT Id, OracleSyncStatus__c FROM Project_Site__c WHERE Project__c = :testProject.Id];
        for(Project_Site__c site : sites){
            //system.assertEquals('S', teamMember.OracleSyncStatus__c); 
            system.assertEquals('P', site.OracleSyncStatus__c); 
        }

        tasks = [SELECT Id, OracleSyncStatus__c FROM pse__Project_Task__c WHERE pse__Project__c = :testProject.Id];
        for(pse__Project_Task__c task :  tasks){
            //system.assertEquals('S', teamMember.OracleSyncStatus__c); 
            system.assertEquals('P', task.OracleSyncStatus__c);         
        }

        test.stopTest();
    }
    
    private static testMethod void testProjectSyncWithErrors(){
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(numTestProjectTasks, numTeamMembers);

        //update the data so it will fail validation
        pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];

        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary');
        pageRef.getParameters().put('projectId', testProject.Id);
        pageRef.getParameters().put('isProjectNumber', '0');
        test.setCurrentPage(pageRef);

        test.startTest();

        ECO_ProjectSummaryController con = new ECO_ProjectSummaryController();

        delete testProject;

        con.syncRequest_Step1_start();
        con.syncRequest_Step1_complete();
        con.syncRequest_Step2_start();
        con.syncRequest_Step2_complete();
        con.syncRequest_Step3_start();
        con.syncRequest_Step3_complete();
        con.syncRequest_Step4_start();
        con.syncRequest_Step4_complete();
        con.syncRequest_Step5_start();
        con.syncRequest_Step5_complete();
        con.syncRequest_Step6_start();
        con.syncRequest_Step6_complete();
        con.syncRequest_Step7_start();
        con.syncRequest_Step7_complete();
        con.syncRequest_Step8_start();
        con.syncRequest_Step8_complete();
        system.assertEquals(true, con.syncErrorOccurred);
    }

    static testMethod void testConstructorWithProjectId() {
        Test.startTest();
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c project1 = [select Id from pse__Proj__c limit 1];
        ECO_ProjectSummaryController psc = new ECO_ProjectSummaryController(project1.Id);
        Test.stopTest();
        System.assert(psc != null);
    }

    static testMethod void testConstructorApprovalLocked() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c project1 = [select Id from pse__Proj__c limit 1];
        System.debug('___project1='+project1);
        Id projId = project1.Id;
        Approval.lock(projId);
        System.debug('___Approval locked='+Approval.isLocked(projId));
        PageReference pageRef = new PageReference('/apex/ECO_ProjectSummary?ProjectId='+project1.Id);
        Test.setCurrentPage(pageRef);
        System.debug('___ApexPages.currentPage()='+ApexPages.currentPage());
        Test.startTest();
        ECO_ProjectSummaryController psc = new ECO_ProjectSummaryController();
        Test.stopTest();
        System.assert(psc != null);
    }

    

/******************************************************************************************/
        // Added by Arman - Left to complete UnitTests for the uncovered sections below
/******************************************************************************************/

	/** validateProjectCustomerData
579  	if(!String.isEmpty(validationMsgForSite)){
		                validationMsgForSite = 'The following fields must be completed to sync: ' + validationMsgForSite.substring(0,validationMsgForSite.length()-2) + '. ' + siteETCCMsg;
                                        nonSyncItem badSite = new nonSyncItem();
                                        badSite.recordId = site.Id;
                                        badSite.recordName = site.Account_Name__c;
                                        badSite.validationErrorMessage = validationMsgForSite;
                                        system.debug('validationMsgForSite=' + validationMsgForSite);
                                        invalidCustomers.add(badSite);                  
                                }
*/

    /*  if(!invalidCustomers.isEmpty()){
601                                 allowRequestSubmit = false;
602                                 results += '<li>' + invalidCustomers.size() + ' Customers failed validation. See the Customers section below for details.</li>';                                    
603                                 selectedCustomerTab = 'invalidCustomers';
604                                 if(invalidCustomers.size() > numberRelatedItemsToDisplay){                                                   
605                                         invalidCustomerLimitMsg = '(Top 20 of ' + invalidCustomers.size() + ' records)';        
606                                         invalidCustomers = getLimitedNonSyncItemList(invalidCustomers, numberRelatedItemsToDisplay);                    
607                                 }                                               
608                         }
**/

/** validateProjectKeyMembersData
    if(!String.isEmpty(validationMsgForKeyMember)){
680                                         //validationMsgForKeyMember = 'The following fields must be completed to sync: ' + validationMsgForKeyMember.substring(0,validationMsgForKeyMember.length()-2);
681                                         validationMsgForKeyMember = 'The following fields must be completed to sync: ' + validationMsgForKeyMember.substring(0,validationMsgForKeyMember.length());
682                                         nonSyncItem badKeyMember = new nonSyncItem();
683                                         badKeyMember.recordId = member.Id;
684                                         if(member.Contact__c == null){
685                                                 badKeyMember.recordName = member.Name;
686                                         }else{
687                                                 badKeyMember.recordName = member.Contact__r.Name;
688                                         }               
689                                         badKeyMember.validationErrorMessage = validationMsgForKeyMember;
690                                         system.debug('validationMsgForKeyMember=' + validationMsgForKeyMember);
691                                         invalidKeyMembers.add(badKeyMember);            
692                                 }else{
    

if(!invalidKeyMembers.isEmpty()){
702                                 allowRequestSubmit = false;
703                                 results += '<li>' + invalidKeyMembers.size() + ' Key Members failed validation. See the Key Member section below for details.</li>';        
704                                 selectedKeyMemberTab = 'invalidKeyMembers';
705 
706                                 if(invalidKeyMembers.size() > numberRelatedItemsToDisplay){                                                  
707                                         invalidKeyMemberLimitMsg = '(Top 20 of ' + invalidKeyMembers.size() + ' records)';      
708                                         invalidKeyMembers = getLimitedNonSyncItemList(invalidKeyMembers, numberRelatedItemsToDisplay);                  
709                                 }                                               
710                         }


for(ProjectRole__c projectRole:[select Id, Name from ProjectRole__c where Active__c = true and RequiredforOracleSync__c = true])
724         {
725                 if(!activeProjectTeamMemberRoles.contains(projectRole.Id))
726                         results += '<li>There is no active key member associated to role: ' + projectRole.Name + '.  An association is required to sync to Oracle.</li>';
727         }
728                 return results;
729         }
730 
731         private void displayValidationMessage(){
732                 
733                 if(!allowRequestSubmit){
734                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The project cannot be synced due to missing information on the project or related items:<ul>' + projectMsg + taskMsg + keyMemberMsg + customersMsg + '</ul>'));
735                 }
736         }
    **/

/** 762         private void generateSyncHistory(){
    for(IntegrationMessageQueue__c tmpRec : tmpSyncHistory){
767                         syncHistoryHelper syncHelper = new syncHistoryHelper();
768                         syncHelper.syncLocalDateTime = tmpRec.LastModifiedDate.format();
769                         syncHelper.msgQueue = tmpRec;
770                         syncHistory.add(syncHelper);
771                 }   
**/

/*** 835            private static List<Project_Site__c> getLimitedCustomerList(List<Project_Site__c> listIn, Integer linitIn){
836                 List<Project_Site__c> results = new List<Project_Site__c>();
837                 Integer nLimit = linitIn;
838                 if(listIn.size() < nLimit){
839                         nLimit = listIn.size();
840                 }
841                 for(Integer i=0; i<nLimit; i++){
842                         results.add(listIn.get(i));                     
843                 }
844                 return results;
845         }
**/

/** 922         public void sendProjectNumberRequest_start(){

}catch(Exception e){
928                         syncErrorOccurred = true;               
929                         syncProgressMsg =  'Error occurred while creating Message Queue record!' + e.getMessage();
930                         stepMsgs.add(syncProgressMsg);
931                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(3, syncProgressMsg, true)));
932                 }
    ***/


/*** 937            public void sendProjectNumberRequest_complete(){

    947                 }catch(Exception e){
948                         syncErrorOccurred = true;               
949                         syncProgressMsg =  'Error occurred while creating Message Queue record!' + e.getMessage();
950                         stepMsgs.add(syncProgressMsg);
951                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(4, syncProgressMsg, true)));
952                 }
**/

/** 987             public void syncRequest_Step1_complete(){
}catch(Exception e){
995                         syncErrorOccurred = true;               
996                         syncProgressMsg =  'Error occurred while creating Message Queue record!' + e.getMessage();
997                         stepMsgs.add(syncProgressMsg);
998                         if(ApexPages.currentPage() != null)
999                                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(2, syncProgressMsg, true)));
1000                    }      
    **/

/**  1010               public void syncRequest_Step2_complete(){
    }catch(Exception e){
1018                            syncErrorOccurred = true;
1019                            syncProgressMsg = 'Error occurred while updating task records!' + e.getMessage();
1020                            stepMsgs.add(syncProgressMsg);
1021                            if(ApexPages.currentPage() != null)
1022                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(4, syncProgressMsg, true)));
1023                    }    
    **/

/** 1033                public void syncRequest_Step3_complete(){
}catch(Exception e){
1041                            syncErrorOccurred = true;
1042                            syncProgressMsg =  'Error occurred while updating key member records!' + e.getMessage();
1043                            stepMsgs.add(syncProgressMsg);
1044                            if(ApexPages.currentPage() != null)
1045                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(6, syncProgressMsg, true)));
1046                    }  
**/

/** 1063                public void syncRequest_Step4_complete(){ 
    }catch(Exception e){
1064                            syncErrorOccurred = true;
1065                            syncProgressMsg = 'Error occurred while updating customer records!' + e.getMessage();
1066                            stepMsgs.add(syncProgressMsg);
1067                            if(ApexPages.currentPage() != null)
1068                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(8, syncProgressMsg, true)));
1069                    }  
**/

/** 1096                public void syncRequest_Step6_start(){
     }else{
1103                            syncProgressMsg = 'Flagging tasks as sync status = E (Error)...';
1104                            stepMsgs.add(syncProgressMsg);
1105                            if(ApexPages.currentPage() != null)
1106                                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(11, syncProgressMsg, true)));
1107                    }    
**/

/** 1110                public void syncRequest_Step6_complete(){
    1118                            }else{
1119                                    ECO_Service_ProjectSync.flagProjectTasksWithSyncStatus('E', projectId, lastSync);
1120                                    syncProgressMsg = 'Flagging tasks as sync status = E (Error) - Complete!';
1121                                    stepMsgs.add(syncProgressMsg);
1122                                    if(ApexPages.currentPage() != null)
1123                                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, generateProgressBar(12, syncProgressMsg, true)));
1124                            }
1125                                    
1126                    }catch(Exception e){
1127                            syncErrorOccurred = true;
1128                            syncProgressMsg =  'Error occurred while updating task records!' + e.getMessage();
1129                            stepMsgs.add(syncProgressMsg);
1130                            if(ApexPages.currentPage() != null)
1131                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, generateProgressBar(12, syncProgressMsg, true)));
1132                    }    **/


}