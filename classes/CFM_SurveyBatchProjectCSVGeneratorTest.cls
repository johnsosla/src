@isTest
public class CFM_SurveyBatchProjectCSVGeneratorTest {

    private static final String  AECOM_DEPT_NAME             = 'Test AECOM Dept Name';
    private static       String  AECOM_DEPT_REGION_EXEC_NAME = 'TestingLastName';
    private static       Profile mAdminProfile;
    
    public static testMethod void testColumnsAndFields() {
        setupColumns();
        List<String> testHeaders = new List<String> {
            'Survey Batch Number',
            'ID',
            'Survey_Batch_Project_Id',
            'Project_Name',
            'Project ID',
            'Business Line',
            'AECOM_Firm',
            'Survey Contact',
            'Contact ID',
            'Email',
            'Survey Contact Phone',
            'Survey Contact Language',
            'Oracle Client Name',
            'Account ID',
            'Oracle Client Number',
            'Geo',
            'Oracle District',
            'Oracle % Complete',
            'Oracle Department',
            'Oracle Project Director',
            'Oracle Project Manager',
            'Oracle Project Number',
            'Oracle Status',
            'Oracle Region',
            'Oracle Super Geography'
        };        

        System.assert(CFM_SurveyBatchProjectCSVGenerator.HEADER_EMAIL == 'Email');
        System.assertEquals(getTestHeaders(), CFM_SurveyBatchProjectCSVGenerator.COLUMN_HEADERS, 'Headers should be what was inserted in custom settings');
        System.assertEquals(getTestHeaderMap(), CFM_SurveyBatchProjectCSVGenerator.COLUMNS_TO_FIELDS, 'Mappings should be what was inserted in custom settings');
    }

    public static testMethod void testCSVGeneration() {
        Integer numBatchProjects = 2;
        Test.setMock(HttpCalloutMock.class, new CFM_QualtricsBaseResponseMock());
        CFM_Survey_Batch__c batch = setup(numBatchProjects);
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(batch);
        CFM_SurveyBatchController cont = new CFM_SurveyBatchController(sc);
        cont.submitAction();

        //---Make sure that the queued callouts finish
        Test.stopTest();

        List<CFM_SurveyBatchProject> batchProjects = CFM_SurveyBatchProject.find.findConfirmedProjects(batch.Id);
        System.assertEquals(numBatchProjects, batchProjects.size(), 'Should have found all the batch projects that were created');
        for (CFM_SurveyBatchProject sbp : batchProjects) {
            System.assertEquals(CFM_SurveyBatchProject.STATUS_SENT, sbp.obj.Status__c, 'Status__c should have been set properly');
            System.assertEquals('Ready For Transmission', sbp.obj.Qualtrics_Status__c, 'Qualtrics_Status__c should have been set properly');
        }

        List<CFM_IntegrationLog> logs = CFM_IntegrationLog.find.bySurveyBatchId(batch.Id);
        Boolean importPanelCalled = false;
        Boolean sendSurveyCalled  = false;

        for (CFM_IntegrationLog log : logs) {
            if (log.getMethodCalled() == CFM_IntegrationLog.METHOD_IMPORT_PANEL) {
                importPanelCalled = true;
            }
            else if (log.getMethodCalled() == CFM_IntegrationLog.METHOD_SEND_SURVEY) {
                sendSurveyCalled = true;
            }
        }

        System.assert(importPanelCalled, 'Should have sent request to Qualtrics, called importPanel, and created a log');
        System.assert(sendSurveyCalled, 'Should have sent request to Qualtrics, called sendSurveyToPanel, and created a log');

        List<CFM_Attachment> attachments = CFM_Attachment.find.byParentId(batch.Id);
        System.assert(attachments.size() == 1, 'Should have only created and inserted the generated CSV');

        String csv = attachments[0].getBody().toString();
        System.assert(csv != null, 'Attachment body should not be empty');

        List<String> rows = csv.split('[\n\r]+');
        System.assertEquals(numBatchProjects + 1, rows.size(), 'Should be one row for the header, and one row for each batch project');
        System.assertEquals(String.join(getTestHeaders(), ','), rows[0], 'Header from CSV attachment should match comma separated headers generated');

        checkRowIsCorrect(1, rows, batchProjects);
        checkRowIsCorrect(2, rows, batchProjects);

    }

    private static void checkRowIsCorrect(Integer rowNum, List<String> rows, List<CFM_SurveyBatchProject> batchProjects) {
        //---Suffix for row 1 was 0, because of headers
        Integer suffix = rowNum - 1;
        String testRow = rows[rowNum];
        CFM_SurveyBatchProject target = batchProjects[suffix];

        String targetRow = ''
            + String.valueof(target.obj.Survey_Batch__r.Name                               ).escapeCSV() + ','
            + String.valueof(target.obj.Survey_Batch__c                                    ).escapeCSV() + ','
            + String.valueof(target.obj.Id                                                 ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.Name                                    ).escapeCSV() + ','
            + String.valueof(target.obj.Project__c                                         ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.OracleBusinessLine__c                   ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.AECOM_Firm__c                           ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.CFM_Survey_Contact__r.Name              ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.CFM_Survey_Contact__c                   ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.CFM_Survey_Contact__r.Email             ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.CFM_Survey_Contact__r.Phone             ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.CFM_Survey_Contact__r.Survey_Language__c).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.OracleClientName__c                     ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.Owner__c                                ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.OracleClientNumber__c                   ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.Oracle_Geography__c                     ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.OracleAECOMDistrict__c                  ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.OraclePercentComplete__c                ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.OracleDepartment__c                     ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.Oracle_Project_Director__r.Name         ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.Oracle_Project_Manager_lookup__r.Name   ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.Oracle_Project_Number__c                ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.OracleStatus__c                         ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.Oracle_Region__c                        ).escapeCSV() + ','
            + String.valueof(target.obj.Project__r.Oracle_Super_Geography__c               ).escapeCSV() + ','
            + AECOM_DEPT_REGION_EXEC_NAME;
        CFM_DebugUtils.log('targetRow', targetRow);
        CFM_DebugUtils.log('testRow  ', testRow);
        System.assertEquals(targetRow, testRow, 'Row generated by CSV should match what is on the object for row ' + rowNum + ' (0 is the header row). ---testRow: ' + testRow);
    }


    private static CFM_Survey_Batch__c setup(Integer count) {
        setupColumns();
        setupAECOMDept();
        CFM_Survey_Batch__c surveybatch = setupSurveyBatch();
        List<User>    users    = setupUsers(count);
        List<Account> accounts = setupAccounts(count);
        List<Contact> contacts = setupContacts(accounts);

        List<Project__c> projects = setupProjects(users, accounts, contacts);

        setupBatchProjects(surveyBatch, projects);

        return surveyBatch;

    }

    private static void setupAECOMDept() {
        User u = createTestUser(0);
        u.Alias += 'de';
        u.Username += 'dept';
        insert u;

        AECOM_Primary_Department__c dept = new AECOM_Primary_Department__c();
        dept.Name = AECOM_DEPT_NAME;
        dept.Group_Division__c = 'Test Group';
        dept.Operating_Group__c = 'Test Operating Group';
        dept.CurrencyIsoCode = 'USD';
        dept.CFM_Region_Executive__c = u.Id;
        dept.Lead_District__c = 'Midwest';
        dept.Lead_Region__c = 'Test';

        insert dept;
    }

    private static CFM_Survey_Batch__c setupSurveyBatch() {
        CFM_Survey_Batch__c batch = new CFM_Survey_Batch__c();
        batch.Status__c = CFM_SurveyBatch.STATUS_PENDING_SUBMIT;
        batch.Target_Survey_Date__c = Date.today();
        insert batch;
        return batch;
    }

    private static List<User> setupUsers(Integer count) {

        List<User> users = new List<User>();
        //---Need twice as many users - project manager and project director
        for (Integer i = 0; i < count * 2; i++) {
            

            users.add(createTestUser(i));
        }
        insert users;
        return users;
    }

    private static User createTestUser(Integer i) {
        if (mAdminProfile == null) {
            mAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        }

        User u = new User();
        u.Alias            = 'tus' + i;
        u.Email            = 'testUser' + i + '@example.com';
        u.Emailencodingkey = 'UTF-8';
        u.Lastname         = AECOM_DEPT_REGION_EXEC_NAME;
        u.Languagelocalekey= 'en_US';
        u.Localesidkey     = 'en_US';
        u.Profileid        = mAdminProfile.Id;
        u.Timezonesidkey   = 'America/Los_Angeles';
        u.Username         = 'npsUnitTestUser12345@nps.com.' + i;

        return u;
    }

    private static List<Account> setupAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            Account a = new Account();
            a.Name = 'Fake Test Account' + i;
            accounts.add(a);
        }
        insert accounts;
        return accounts;

    }

    private static List<Contact> setupContacts(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>();

        for (Integer i = 0; i < accounts.size(); i++) {
            Contact c = new Contact();
            c.AccountId = accounts[i].Id;
            c.FirstName = 'Fake Unit Test Contact';
            c.LastName = 'Fake' + i;
            c.Email = 'fake@example.com.' + i;
            c.Phone = '5555555555';
            c.Survey_Language__c = 'EN';
            contacts.add(c);
        }

        insert contacts;
        return contacts;
    }

    private static List<Project__c> setupProjects(List<User> users, List<Account> accounts, List<Contact> contacts) {
        List<Project__c> projects = new List<Project__c>();
        for (Integer i = 0; i < accounts.size(); i++) {
            Project__c p = new Project__c();
            p.Name                             = 'Test Project ' + i;
            p.OracleBusinessLine__c            = 'Water';
            //p.AECOM_Firm__c                    = 'AECOM'; //---Formula field with return value of 'AECOM'
            p.CFM_Survey_Contact__c            = contacts[i].Id;
            p.OracleClientName__c              = 'REGIONAL TEST CLIENT' + i;
            p.Owner__c                         = accounts[i].Id;
            p.OracleClientNumber__c            = i + '';
            p.Oracle_Geography__c              = 'West';
            p.OracleAECOMDistrict__c           = 'District' + i;
            p.OraclePercentComplete__c         = i;
            p.OracleDepartment__c              = AECOM_DEPT_NAME;
            p.Oracle_Project_Director__c       = users[i * 2].Id;
            p.Oracle_Project_Manager_lookup__c = users[(i * 2) + 1].Id;
            p.Oracle_Project_Number__c         = i + '';
            p.OracleStatus__c                  = 'Approved';
            p.Oracle_Region__c                 = 'USA';
            p.Oracle_Super_Geography__c        = 'Americas';

            //---Required fields
            p.Project_Description__c           = 'Super cool project';
            projects.add(p);
        }
        insert projects;
        return projects;
    }

    private static List<CFM_Survey_Batch_Project__c> setupBatchProjects(CFM_Survey_Batch__c batch, List<Project__c> projects) {
        List<CFM_Survey_Batch_Project__c> batchProjects = new List<CFM_Survey_Batch_Project__c>();

        for (Project__c project : projects) {
            CFM_Survey_Batch_Project__c batchProject = new CFM_Survey_Batch_Project__c();
            batchProject.Project__c = project.Id;
            batchProject.Survey_Batch__c = batch.Id;
            batchProject.Status__c = CFM_SurveyBatchProject.STATUS_PENDING_QSUBMIT;
            batchProject.PM_Status__c = CFM_SurveyBatchProject.PM_STATUS_CONFIRM;
            batchProjects.add(batchProject);
        }
        insert batchProjects;
        return batchProjects;
    }

    private static void setupColumns() {
        List<CFM_Survey_Batch_CSV_Columns__c> columns = new List<CFM_Survey_Batch_CSV_Columns__c>();
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Survey Batch Number',     Column_Label__c='Survey Batch: Survey Batch Number',     Column_Field__c='Survey_Batch__r.Name'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='ID',                      Column_Label__c='Survey Batch: ID',                      Column_Field__c='Survey_Batch__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Survey_Batch_Project_Id', Column_Label__c='Survey_Batch_Project_Id',               Column_Field__c='Id'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Project_Name',            Column_Label__c='Project_Name',                          Column_Field__c='Project__r.Name'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Project ID',              Column_Label__c='Project ID',                            Column_Field__c='Project__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Business Line',           Column_Label__c='Project Name: Business Line',           Column_Field__c='Project__r.OracleBusinessLine__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='AECOM_Firm',              Column_Label__c='AECOM_Firm',                            Column_Field__c='Project__r.AECOM_Firm__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Survey Contact',          Column_Label__c='Survey Contact',                        Column_Field__c='Project__r.CFM_Survey_Contact__r.Name'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Contact ID',              Column_Label__c='Contact ID',                            Column_Field__c='Project__r.CFM_Survey_Contact__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Email',                   Column_Label__c='Email',                                 Column_Field__c='Project__r.CFM_Survey_Contact__r.Email', Is_Email_Column__c=true));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Survey Contact Phone',    Column_Label__c='Project Name: Survey Contact Phone',    Column_Field__c='Project__r.CFM_Survey_Contact__r.Phone'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Survey Contact Language', Column_Label__c='Project Name: Survey Contact Language', Column_Field__c='Project__r.CFM_Survey_Contact__r.Survey_Language__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Oracle Client Name',      Column_Label__c='Oracle Client Name',                    Column_Field__c='Project__r.OracleClientName__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Account ID',              Column_Label__c='Account ID',                            Column_Field__c='Project__r.Owner__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Oracle Client Number',    Column_Label__c='Oracle Client Number',                  Column_Field__c='Project__r.OracleClientNumber__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Geo',                     Column_Label__c='Geo',                                   Column_Field__c='Project__r.Oracle_Geography__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Oracle District',         Column_Label__c='Oracle District',                       Column_Field__c='Project__r.OracleAECOMDistrict__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Oracle % Complete',       Column_Label__c='Oracle % Complete',                     Column_Field__c='Project__r.OraclePercentComplete__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Oracle Department',       Column_Label__c='Project Name: Oracle Department',       Column_Field__c='Project__r.OracleDepartment__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Oracle Project Director', Column_Label__c='Project Name: Oracle Project Director', Column_Field__c='Project__r.Oracle_Project_Director__r.Name'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Oracle Project Manager',  Column_Label__c='Oracle Project Manager',                Column_Field__c='Project__r.Oracle_Project_Manager_lookup__r.Name'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Oracle Project Number',   Column_Label__c='Project Name: Oracle Project Number',   Column_Field__c='Project__r.Oracle_Project_Number__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Oracle Status',           Column_Label__c='Oracle Status',                         Column_Field__c='Project__r.OracleStatus__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Oracle Region',           Column_Label__c='Oracle Region',                         Column_Field__c='Project__r.Oracle_Region__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Oracle Super Geography',  Column_Label__c='Oracle Super Geography',                Column_Field__c='Project__r.Oracle_Super_Geography__c'));
        columns.add(new CFM_Survey_Batch_CSV_Columns__c(Name='Signatory Name',          Column_Label__c='Signatory Name',                        Column_Field__c='N/A', Is_Custom_Implementation__c=true));
        //---Leave room for columns in between
        Integer index = 10;
        for (CFM_Survey_Batch_CSV_Columns__c col : columns) {
            col.Index__c = index;
            index += 10;
        }
        insert columns;
    }

    private static List<String> getTestHeaders() {
        return new List<String> {
            'Survey Batch: Survey Batch Number',
            'Survey Batch: ID',
            'Survey_Batch_Project_Id',
            'Project_Name',
            'Project ID',
            'Project Name: Business Line',
            'AECOM_Firm',
            'Survey Contact',
            'Contact ID',
            'Email',
            'Project Name: Survey Contact Phone',
            'Project Name: Survey Contact Language',
            'Oracle Client Name',
            'Account ID',
            'Oracle Client Number',
            'Geo',
            'Oracle District',
            'Oracle % Complete',
            'Project Name: Oracle Department',
            'Project Name: Oracle Project Director',
            'Oracle Project Manager',
            'Project Name: Oracle Project Number',
            'Oracle Status',
            'Oracle Region',
            'Oracle Super Geography',
            'Signatory Name'
        };
    }

    private static Map<String, String> getTestHeaderMap() {
        return new Map<String, String> {
            'Survey Batch: Survey Batch Number'     => 'Survey_Batch__r.Name',
            'Survey Batch: ID'                      => 'Survey_Batch__c',
            'Survey_Batch_Project_Id'               => 'Id',
            'Project_Name'                          => 'Project__r.Name',
            'Project ID'                            => 'Project__c',
            'Project Name: Business Line'           => 'Project__r.OracleBusinessLine__c',
            'AECOM_Firm'                            => 'Project__r.AECOM_Firm__c',
            'Survey Contact'                        => 'Project__r.CFM_Survey_Contact__r.Name',
            'Contact ID'                            => 'Project__r.CFM_Survey_Contact__c',
            'Email'                                 => 'Project__r.CFM_Survey_Contact__r.Email',
            'Project Name: Survey Contact Phone'    => 'Project__r.CFM_Survey_Contact__r.Phone',
            'Project Name: Survey Contact Language' => 'Project__r.CFM_Survey_Contact__r.Survey_Language__c',
            'Oracle Client Name'                    => 'Project__r.OracleClientName__c',
            'Account ID'                            => 'Project__r.Owner__c',
            'Oracle Client Number'                  => 'Project__r.OracleClientNumber__c',
            'Geo'                                   => 'Project__r.Oracle_Geography__c',
            'Oracle District'                       => 'Project__r.OracleAECOMDistrict__c',
            'Oracle % Complete'                     => 'Project__r.OraclePercentComplete__c',
            'Project Name: Oracle Department'       => 'Project__r.OracleDepartment__c',
            'Project Name: Oracle Project Director' => 'Project__r.Oracle_Project_Director__r.Name',
            'Oracle Project Manager'                => 'Project__r.Oracle_Project_Manager_lookup__r.Name',
            'Project Name: Oracle Project Number'   => 'Project__r.Oracle_Project_Number__c',
            'Oracle Status'                         => 'Project__r.OracleStatus__c',
            'Oracle Region'                         => 'Project__r.Oracle_Region__c',
            'Oracle Super Geography'                => 'Project__r.Oracle_Super_Geography__c'
        };
    }
}