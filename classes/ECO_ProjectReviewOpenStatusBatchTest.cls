@isTest
public class ECO_ProjectReviewOpenStatusBatchTest {

    static testMethod void testProjectReviewOpenStatusBatchBatch() {

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;

        Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;

        //create create source project 

        ECO_Utils_Testing.createProjectRoles();

        pse__Proj__c testProject = new pse__Proj__c();
        testProject.Name = 'test project 1';
        testProject.pse__Account__c = testAccount.Id;
        testProject.pse__Project_Type__c = 'Customer Project';
        testProject.pse__Billing_Type__c = 'Fixed Price';
        testProject.CurrencyIsoCode = 'USD';
        testProject.pse__Is_Active__c = true;
        testProject.pse__End_Date__c = Date.today().addDays(5);
        testProject.ValidateGo__c = false;
        insert testProject;
        
        ProjectReview__c projectReview = new ProjectReview__c(Project__c = testProject.Id, Status__c = 'Not Started', ReviewFrequency__c = 'Monthly');  
        insert projectReview;
                
        Test.StartTest();                
        ECO_ProjectReviewOpenStatusBatch projectReviewBatch = new ECO_ProjectReviewOpenStatusBatch(50);
        Id batchprocessid = Database.executeBatch(projectReviewBatch);    
        Test.StopTest(); 
        
        //Syster.AssertEquals('Not Started', projectReview)
        //System.AssertEquals(true, projectReview.isOpen__c);
        
        list<PortalMessage__c> portalMessage = [select Id from PortalMessage__c];
        
        System.AssertEquals(1, portalMessage.size());
    }
    
}