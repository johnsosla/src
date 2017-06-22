@isTest
public class ECO_ProjectHealthCheckBatchTest {

    static testMethod void testProjectHealthCheckBatch() {
        final Integer numTestRisks = 50;

        Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;

        //create create source project 
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        pse__Proj__c testProject = [select Id, isClosed__c, Name from pse__Proj__c limit 1];
        
        list<KPI_Metric__c> kpiMetrics = new list<KPI_Metric__c>();
        KPI_Metric__c metric1 = new KPI_Metric__c(Name='Is PM certified', Data_Type__c = 'Boolean', Is_Active__c = true, Unit_Of_Measure__c = 'true/false'); //a5ne00000004ENqAAM
        KPI_Metric__c metric2 = new KPI_Metric__c(Name='Scheduled end date < today', Data_Type__c = 'Boolean', Is_Active__c = true, Unit_Of_Measure__c = 'true/false');
        kpiMetrics.add(metric1); //a5ne00000004ENqAAM
        kpiMetrics.add(metric2); //a5ne00000004ENvAAM
        insert kpiMetrics;

//      list<Project_Review_Trigger__c> projectReviewTriggers = new list<Project_Review_Trigger__c>();      
//      projectReviewTriggers.add(new Project_Review_Trigger__c(Name='Project Manager', Alert_Message__c = 'PM not certified', Comparator_1__c = 'false', Comparator_2__c = null, 
//                                  Evaluation_Frequency__c = null, Is_Active__c = true, KPI_Metric__c = metric1.Id, Operator__c = 'equal to'));
//      projectReviewTriggers.add(new Project_Review_Trigger__c(Name='Scheduled End Date', Alert_Message__c = 'Scheduled end date occurs in the past', Comparator_1__c='false', Comparator_2__c = null, 
//                                  Evaluation_Frequency__c = null, Is_Active__c = true, KPI_Metric__c = metric2.Id, Operator__c = 'equal to'));
//      insert projectReviewTriggers;
                
        Test.StartTest();                
        ECO_ProjectHealthCheckBatch projectHealthCheckBatch = new ECO_ProjectHealthCheckBatch(Null);
        Id batchprocessid = Database.executeBatch(projectHealthCheckBatch);    
        Test.StopTest(); 
        
        System.AssertEquals(false, testProject.isClosed__c);
        
        list<PortalMessage__c> portalMessage = [select Id from PortalMessage__c];
        
        System.AssertEquals(0, portalMessage.size());
        //System.AssertEquals('Test', portalMessage[0]);
        //System.AssertEquals(true,  portalMessages[0])  
    }
    
    static testMethod void testProjectHealthCheckBatch2() {
        final Integer numTestRisks = 50;

        Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;

        //create create source project 
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        pse__Proj__c testProject = [select Id, Name, isClosed__c from pse__Proj__c limit 1];
        
        list<KPI_Metric__c> kpiMetrics = new list<KPI_Metric__c>();
        kpiMetrics.add( new KPI_Metric__c(Name='Is PM certified', Data_Type__c = 'Boolean', Is_Active__c = true, Unit_Of_Measure__c = 'true/false')); //a5ne00000004ENqAAM
        kpiMetrics.add( new KPI_Metric__c(Name='Scheduled end date < today', Data_Type__c = 'Boolean', Is_Active__c = true, Unit_Of_Measure__c = 'true/false')); //a5ne00000004ENvAAM
        insert kpiMetrics;

        list<Project_Review_Trigger__c> projectReviewTriggers = new list<Project_Review_Trigger__c>();      
        projectReviewTriggers.add(new Project_Review_Trigger__c(Name='Project Manager', Alert_Message__c = 'PM not certified', Comparator_1__c = 'true', Comparator_2__c = null, 
                                    Evaluation_Frequency__c = null, Is_Active__c = true, KPI_Metric__c = kpiMetrics[0].Id, Operator__c = 'equal to'));
/*      projectReviewTriggers.add(new Project_Review_Trigger__c(Name='Scheduled End Date', Alert_Message__c = 'Scheduled end date occurs in the past', Comparator_1__c='false', Comparator_2__c = null, 
                                    Evaluation_Frequency__c = null, Is_Active__c = true, KPI_Metric__c = kpiMetrics[1].Id, Operator__c = 'equal to'));
    */  insert projectReviewTriggers;
        
        Test.StartTest();                
        ECO_ProjectHealthCheckBatch projectHealthCheckBatch = new ECO_ProjectHealthCheckBatch(Null);
        Id batchprocessid = Database.executeBatch(projectHealthCheckBatch);    
        Test.StopTest(); 
        
        System.AssertEquals(false, testProject.isClosed__c);
        
        list<PortalMessage__c> portalMessage = [select Id, Name from PortalMessage__c];
        
        System.AssertEquals(0, portalMessage.size());
        //System.AssertEquals('Test', portalMessage[0].Name);
        
        //System.AssertEquals(true,  portalMessages[0])  
    }

    static testMethod void testExecute() {
        Test.startTest();
        ECO_ProjectHealthCheckBatch batch = new ECO_ProjectHealthCheckBatch();
        String chron = '0 0 23 * * ?';
        System.schedule('Test Sched', chron, batch);
        Test.stopTest();
    }
}