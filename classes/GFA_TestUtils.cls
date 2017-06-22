/*******************************************************************************
*
* PURPOSE: Test Utility class
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
@isTest
public class GFA_TestUtils {

    //Used to make sure we have unique usernames in calls to this class' methods
    private Static Integer userCount = 0;

    private static final Map<String, Schema.RecordTypeInfo> mLibSubtaskInfo =
        GFA_Library_Subtask__c.SObjectType.getDescribe().getRecordTypeInfosByName();

    public static List<GFA_LibraryPhase> createTestLibraryPhases(Integer numOfPhases) {
        List<GFA_LibraryPhase> phases = new List<GFA_LibraryPhase>();
        for (Integer i = 0; i < numOfPhases; i++) {
            GFA_Library_Phase__c phase = new GFA_Library_Phase__c(
                Name = 'Test Phase ' + i,
                Description__c = 'Test'
            );
            phases.add(new GFA_LibraryPhase(phase));
        }
        GFA_BaseModel.save(phases);
        return phases;
    }

    public static List<GFA_LibrarySubtask> createTestLibrarySubtasks(Integer numOfTasks) {
        if (!GFA_User.getCurrentUser().getIsAdminUser()) {
            GFA_User.getCurrentUser().setIsAdminUser();
            
            /*PermissionSet adminSet = [Select Id from PermissionSet where Name = : GFA_User.ADMIN_PERMISSION_SET];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = adminSet.Id,
                    AssigneeId = UserInfo.getUserId());
            insert psa;*/
        }
		
        // GFA_User.clearCurrentUser();
        
        List<GFA_LibrarySubtask> subtasks = new List<GFA_LibrarySubtask>();
        for (Integer i = 0; i < numOfTasks; i++) {
            GFA_Library_Subtask__c subtask = new GFA_Library_Subtask__c (
                Name = 'Test Library Subtask ' + i,
                Discipline__c = 'Business Development',
                Description__c = 'Test',
                Impact_Level__c = 'Normal',
                Risk_Level__c = 'Low',
                Scope_of_Service__c = 'Engineering',
                Group__c = 'Construction Services',
                Operating_Group__c =  'CS-EIC',
                Project_Sponsor__c = 'Client',
                RecordTypeId = mLibSubtaskInfo.get(GFA_LibrarySubtask.RT_PENDING).getRecordTypeId()
            );
            subtasks.add(new GFA_LibrarySubtask(subtask));
        }
        GFA_BaseModel.save(subtasks);

        return subtasks;
    }

    public static List<GFA_LibraryTask> createTestLibraryTasks(Integer numOfTasks) {
        List<GFA_LibraryTask> tasks = new List<GFA_LibraryTask>();
        for (Integer i = 0; i < numOfTasks; i++) {
            GFA_Library_TAsk__c task = new GFA_Library_Task__c(
                Name = 'Test Library Task ' + i
            );
            tasks.add(new GFA_LibraryTask(task));
        }
        GFA_BaseModel.save(tasks);
        return tasks;
    }

    public static List<GFA_Template> createTestTemplate(Integer numOfTemplates) {
        List<GFA_LibraryTask> libTasks = createTestLibraryTasks(numOfTemplates);
        List<GFA_LibraryPhase> libPhases = createTestLibraryPhases(numOfTemplates);
        List<GFA_LibrarySubtask> libSubtasks = createTestLibrarySubtasks(numOfTemplates);

        List<GFA_Template> templates = new List<GFA_Template>();

        for (Integer i = 0; i < numOfTemplates; i++) {
            GFA_Template__c template = new GFA_Template__c(
                Template_Name__c = 'Test Template ' + i,
                Operating_Group__c = 'CS-EIC',
                Group__c = 'Construction Services',
                Project_Sponsor__c = 'Client',
                Status__c = 'Pending'
            );
            templates.add(new GFA_Template(template));
        }
        GFA_BaseModel.save(templates);

        //---TODO for the future put the lists in the correct templates
        //---to avoid SOQL calls to setup
        List<GFA_TemplatePhase> tempPhases = createTestTemplatePhases(templates, libPhases);
        List<GFA_TemplateTask> tempTasks = createTestTemplateTasks(tempPhases, libTasks);
        List<GFA_TemplateSubtask> tempSubtasks = createTestTemplateSubtasks(tempTasks, libSubtasks);

        return templates;
    }

    public static List<GFA_TemplatePhase> createTestTemplatePhases(List<GFA_Template> templates, List<GFA_LibraryPhase> libPhases) {
        List<GFA_TemplatePhase> tempPhases = new List<GFA_TemplatePhase>();

        Integer seq = 1;
        for (GFA_Template template : templates) {
            for (GFA_LibraryPhase phase : libPhases) {
                GFA_Template_Phase__c tPhase = new GFA_Template_Phase__c(
                    Library_Phase__c = phase.getId(),
                    Sequence__c = seq,
                    Template__c = template.getId()
                );
                tempPhases.add(new GFA_TemplatePhase(tPhase));
                seq++;
            }
            seq = 1;
        }
        GFA_BaseModel.save(tempPhases);
        return tempPhases;
    }

    public static List<GFA_TemplateTask> createTestTemplateTasks(List<GFA_TemplatePhase> tempPhases, List<GFA_LibraryTask> libTasks) {
        Integer seq = 1;
        List<GFA_TemplateTask> tempTasks = new List<GFA_TemplateTask>();
        for (GFA_TemplatePhase tempPhase : tempPhases) {
            for (GFA_LibraryTask libTask : libTasks) {
                GFA_Template_Task__c tempTask = new GFA_Template_Task__c(
                    Library_Task__c = libTask.getId(),
                    Template_Phase__c = tempPhase.getId(),
                    Sequence__c = seq
                );
                tempTasks.add(new GFA_TemplateTask(tempTask));
                seq++;
            }
            seq = 1;
        }
        GFA_BaseModel.save(tempTasks);
        return tempTasks;
    }

    public static List<GFA_TemplateSubtask> createTestTemplateSubtasks(List<GFA_TemplateTask> tempTasks, List<GFA_LibrarySubtask> libSubtasks) {
        Integer seq = 1;
        List<GFA_TemplateSubtask> tempSubtasks = new List<GFA_TemplateSubtask>();

        for (GFA_TemplateTask tempTask : tempTasks) {
            for (GFA_LibrarySubtask libSubtask : libSubtasks) {
                GFA_Template_Subtask__c tempSubtask = new GFA_Template_Subtask__c(
                    Name = 'Test Template Subtask ' + seq,
                    Library_Subtask__c = libSubtask.getId(),
                    Template_Task__c = tempTask.getId(),
                    Sequence__c = seq
                );
                tempSubtasks.add(new GFA_TemplateSubtask(tempSubtask));
                seq++;
            }
            seq = 1;
        }
        GFA_BaseModel.save(tempSubtasks);
        return tempSubtasks;
    }

    public static List<GFA_LibrarySubtaskContent> createTestLibrarySubtaskContents(Integer numOfContents, List<GFA_LibrarySubtaskVersion> libSubtaskVersions) {
        List<GFA_LibrarySubtaskContent> lscList = new List<GFA_LibrarySubtaskContent>();

        for (Integer i = 0; i < numOfContents; i++) {
            for (GFA_LibrarySubtaskVersion libSubtaskVersion : libSubtaskVersions) {
                GFA_Library_Subtask_Content__c lsc = new GFA_Library_Subtask_Content__c(
                    Name = 'Doc' + i,
                    Library_Subtask_Version__c = libSubtaskVersion.getId(),
                    Hidden_Deliverable__c = false,
                    Link__c = 'www.google.com'
                );
                lscList.add(new GFA_LibrarySubtaskContent(lsc));
            }
        }
        GFA_BaseModel.save(lscList);
        return lscList;
    }

    public static GFA_Library_Subtask__c getTestLibrarySubtask() {
        GFA_Library_Subtask__c ls = new GFA_Library_Subtask__c (
            Name = 'Test Library Subtask',
            Discipline__c = 'Business Development',
            Description__c = 'Test',
            Impact_Level__c = 'Normal',
            Risk_Level__c = 'Low',
            Scope_of_Service__c = 'Engineering',
            Group__c = 'Construction Services',
            Operating_Group__c =  'CS-EIC',
            Project_Sponsor__c = 'Client'
        );
        insert ls;
        return ls;
    }

    public static List<GFA_LibrarySubtaskVersion> createTestLibrarySubtaskVersions(Integer numOfVersions, List<GFA_LibrarySubtask> libSubtasks) {
        List<GFA_LibrarySubtaskVersion> lsvList = new List<GFA_LibrarySubtaskVersion>();

        for (Integer i = 0; i < numOfVersions; i++) {
            for (GFA_LibrarySubtask libSubtask : libSubtasks) {
                GFA_Library_Subtask_Version__c lsv = new GFA_Library_Subtask_Version__c(
                    Library_Subtask__c = libSubtask.getId(),
                    Discipline__c = 'Business Development',
                    Description__c = 'Test',
                    Impact_Level__c = 'Normal',
                    Risk_Level__c = 'Low',
                    Scope_of_Service__c = 'Engineering',
                    Group__c = 'Construction Services',
                    Operating_Group__c =  'CS-EIC',
                    Project_Sponsor__c = 'Client',
                    Version_Status__c = 'Pending'
                );
                lsvList.add(new GFA_LibrarySubtaskVersion(lsv));
            }
        }
        GFA_BaseModel.save(lsvList);
        return lsvList;
    }

    public static List<GFA_Project> createTestProjects(Integer numOfProjects) {
        List<GFA_LibraryTask> libTasks = createTestLibraryTasks(numOfProjects);
        List<GFA_LibraryPhase> libPhases = createTestLibraryPhases(numOfProjects);
        List<GFA_LibrarySubtask> libSubtasks = createTestLibrarySubtasks(numOfProjects);
        List<GFA_LibrarySubtaskVersion> libSubtaskVersions = createTestLibrarySubtaskVersions(numOfProjects, libSubtasks);

        List<GFA_Project> projects = new List<GFA_Project>();

        for (Integer i = 0; i < numOfProjects; i++) {
            GFA_Project__c project = new GFA_Project__c(
                Bid_Award_Date__c = Date.today(),
                Bid_Submission_Date__c = Date.today(),
                Business_Line__c = '',
                Chargeback_Setoff__c = 'TEST Chargeback',
                Client_Contact__c = null,
                Client__c = null,
                Complexity__c = 'Low',
                Consequential_Damages__c = 'TEST Damages',
                Contract_Terms__c = 'Test Contract Terms',
                Contract_Value__c = 1234,
                Contracted_To__c = null,
                Contractor_Contact__c = null,
                Errors_Omissions__c = 'Test errors omissions',
                Geographic_Region__c = 'Test Geo Region',
                Group__c = 'Construction Services',
                Holdback__c = 'Test Holdback',
                Included_Services__c = 'Test Included Services',
                Indemnity_Liability__c = 'Test Indemnity Liability',
                Insurance__c = 'Test Insurance',
                Is_Confidential_Project__c = true,
                Is_Key_Account__c = true,
                Is_Not_Known_Yet__c = true,
                Lifecycle_Stage__c = 'Proposal',
                Liquidated_Damages__c = 'Test Liquidated Damages',
                Operating_Group__c = 'CS-EIC',
                Opportunity__c = null,
                Other__c = 'Test Other',
                Payment_Terms__c = 'Test Payment terms',
                Performance_Guarantee__c = 'Test Perf Guarantee',
                Primary_Service__c = 'Test Primary Service',
                Project_End_Date_Actual__c = Date.today(),
                Project_End_Date_Forecast__c = Date.today(),
                Project_End_Date_Scheduled__c = Date.today(),
                Project_Name__c = 'Test Project Name',
                Project_Profile__c = null,
                Project_Sponsor__c = 'Client',
                Project_Start_Date_Actual__c = Date.today(),
                Project_Start_Date_Forecast__c = Date.today(),
                Project_Start_Date_Scheduled__c = Date.today(),
                Project_Status__c = 'Not Started',
                Province_State__c = 'Arizona',
                Risk_Level__c = 'Low',
                Scope_Summary__c = 'Test Scope Summary',
                Scope_of_Service__c = 'Engineering',
                Service_Line__c = 'Test Service Line',
                Site_City_Town__c = 'Phoenix',
                Site_Name__c = 'Test Site Name',
                Site_Street_Address__c = '1234 E Fake St.',
                Template__c = null,
                Type__c = 'Greenfield',
                Warranty__c = 'Test Warranty'
            );
            projects.add(new GFA_Project(project));
        }
        GFA_BaseModel.save(projects);

        //---TODO for the future put the lists in the correct Projects
        //---to avoid SOQL calls to setup
        List<GFA_ProjectPhase> tempPhases = createTestProjectPhases(projects, libPhases);
        List<GFA_ProjectTask> tempTasks = createTestProjectTasks(tempPhases, libTasks);
        List<GFA_ProjectSubtask> tempSubtasks = createTestProjectSubtasks(tempTasks, libSubtaskVersions);

        return projects;
    }

    public static List<GFA_ProjectPhase> createTestProjectPhases(List<GFA_Project> projects, List<GFA_LibraryPhase> libPhases) {
        List<GFA_ProjectPhase> tempPhases = new List<GFA_ProjectPhase>();

        Integer seq = 1;
        for (GFA_Project project : projects) {
            for (GFA_LibraryPhase phase : libPhases) {
                GFA_Project_Phase__c tPhase = new GFA_Project_Phase__c(
                    Name = 'Test Project Phase ' + seq,
                    Library_Phase__c = phase.getId(),
                    GFA_Project__c = project.getId(),
                    Scheduled_Completion_Date__c = Date.today().addDays(10),
                    Forecast_Completion_Date__c = Date.today().addDays(5),
                    Actual_Completion_Date__c = Date.today(),
                    Phase_Status__c = 'Not Started'
                );
                tempPhases.add(new GFA_ProjectPhase(tPhase));
                seq++;
            }
            seq = 1;
        }
        GFA_BaseModel.save(tempPhases);
        return tempPhases;
    }

    public static List<GFA_ProjectTask> createTestProjectTasks(List<GFA_ProjectPhase> tempPhases, List<GFA_LibraryTask> libTasks) {
        Integer seq = 1;
        List<GFA_ProjectTask> tempTasks = new List<GFA_ProjectTask>();
        for (GFA_ProjectPhase tempPhase : tempPhases) {
            for (GFA_LibraryTask libTask : libTasks) {
                GFA_Project_Task__c tempTask = new GFA_Project_Task__c(
                    Name = 'Test Project Task ' + seq,
                    Library_Task__c = libTask.getId(),
                    Project_Phase__c = tempPhase.getId()
                );
                tempTasks.add(new GFA_ProjectTask(tempTask));
                seq++;
            }
            seq = 1;
        }
        GFA_BaseModel.save(tempTasks);
        return tempTasks;
    }

    public static List<GFA_ProjectSubtask> createTestProjectSubtasks(List<GFA_ProjectTask> tempTasks, List<GFA_LibrarySubtaskVersion> libSubtaskVersions) {
        Integer seq = 1;
        List<GFA_ProjectSubtask> tempSubtasks = new List<GFA_ProjectSubtask>();

        for (GFA_ProjectTask tempTask : tempTasks) {
            for (GFA_LibrarySubtaskVersion libSubtaskVersion : libSubtaskVersions) {
                GFA_Project_Subtask__c tempSubtask = new GFA_Project_Subtask__c(
                    Name = 'Test Project Subtask ' + seq,
                    Library_Subtask_Version__c = libSubtaskVersion.getId(),
                    Project_Task__c = tempTask.getId(),
                    Status__c = 'Not Started',
                    Is_PM_Visible__c = true
                );
                tempSubtasks.add(new GFA_ProjectSubtask(tempSubtask));
                seq++;
            }
            seq = 1;
        }
        GFA_BaseModel.save(tempSubtasks);

        List<GFA_ProjectDeliverable> tempPDs = createTestProjectDeliverables(2, tempSubtasks);

        return tempSubtasks;
    }

    public static List<GFA_ProjectDeliverable> createTestProjectDeliverables(Integer numOfProjDeliverables, List<GFA_ProjectSubtask> projSubtasks) {
        Integer seq = 1;
        List<GFA_ProjectDeliverable> tempPDs = new List<GFA_ProjectDeliverable>();


        for (GFA_ProjectSubtask projSubtask : projSubtasks) {
            for (Integer i = 0; i < numOfProjDeliverables; i++) {
                GFA_Project_Deliverable__c tempPD = new GFA_Project_Deliverable__c(
                    Name = 'Test Project Deliverable ' + seq,
                    Project_Subtask__c = projSubtask.getId(),
                    Link__c = 'www.google.com',
                    Hidden_Deliverable__c = true
                );
                tempPDs.add(new GFA_ProjectDeliverable(tempPD));
                seq++;
            }
            seq = 1;
        }

        GFA_BaseModel.save(tempPDs);
        return tempPDs;
    }

    public static Account createTestAccount() {
        Account account = new Account (
            Name = 'Shell Oil Test'
        );

        return account;
    }

    public static Contact createTestContact() {
        Contact contact = new Contact (
            LastName = 'LostName',
            AccountId = createTestAccount().Id,
            Phone = '111-111-1111',
            Email = 'Abc.LostName@xyz.com',
            User__c = UserInfo.getUserId()
        );
        insert contact;
        return contact;
    }

    public static List<GFA_ProjectRoster> createTestProjectRosters(Integer numOfProjRosters, List<GFA_Project> projects) {
        Integer seq = 1;
        List<GFA_ProjectRoster> tempRosters = new List<GFA_ProjectRoster>();

        for (GFA_Project project : projects) {
            for (Integer i = 0; i < numOfProjRosters; i++) {
                GFA_Project_Roster__c tempRoster = new GFA_Project_Roster__c(
                    GFA_Project__c = project.getId(),
                    Is_Acting_Project_Manager__c = false,
                    Role__c = 'Proposal Manager',
                    Team_Member_Name__c = createTestContact().Id
                );
                tempRosters.add(new GFA_ProjectRoster(tempRoster));
                seq++;
            }
            seq = 1;
        }

        GFA_BaseModel.save(tempRosters);
        return tempRosters;
    }

    public static List<User> createTestAppUsers(Integer numUsers) {
        Profile testProfile = [Select Id, Name from Profile where Name = 'System Administrator'];

        List<User> userList = new List<User>();
        for (Integer i = 0; i < numUsers; i++) {
            
            Integer rand = Math.round(Math.random()*10000);
            
            User tempUser = new User();
            tempUser.FirstName = 'test';
            tempUser.LastName = 'lastName' + String.ValueOf(userCount + i);
            tempUser.Alias = 'test' + String.ValueOf(userCount + i);
            tempUser.Email = 'SFDCTestCase' + String.ValueOf(userCount + i) + '@aecom.com';
            tempUser.Username = 'rMaG2470@test.com' + String.ValueOf(userCount + i)+rand;
            tempUser.CommunityNickname = 'testNick' + String.ValueOf(userCount + i);
            tempUser.ProfileId = testProfile.Id;
            tempUser.EmailEncodingKey = 'UTF-8';
            tempUser.LanguageLocaleKey = 'en_US';
            tempUser.LocaleSidKey = 'en_US';
            tempUser.TimeZoneSidKey = 'America/Los_Angeles';
            tempUser.Status__c = rsProfile.S_PENDING;
            tempUser.IsActive = true;
            tempUser.AboutMe = 'test test test';
            userList.add(tempUser);
        }
        userCount += numUsers;
        insert userList;

        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        for (User u : userList) {
            PermissionSet appUser = [Select Id from PermissionSet where Name = : GFA_User.APP_USER_PERMISSION_SET];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = appUser.Id,
                    AssigneeId = u.Id);
            assignments.add(psa);
        }
        insert assignments;

        return userList;
    }

}