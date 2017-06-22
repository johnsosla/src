@isTest
public class ECO_ProjectLotteryPickBatchTest {

    static testMethod void testProjectLotteryPickBatch()
    {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        
        Account account = new Account();
        account.Name = 'test Account';
        insert account;

        ECO_Utils_Testing.createProjectRoles();

        list<pse__Proj__c> projects = new list<pse__Proj__c>();
        //create create source project 
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj1', clAECOMProjectReviewCategory__c = 'C-0', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj2', clAECOMProjectReviewCategory__c = 'C-0', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj3', clAECOMProjectReviewCategory__c = 'C-1', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj4', clAECOMProjectReviewCategory__c = 'C-1', ValidateGo__c = false));
        
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj5', clAECOMProjectReviewCategory__c = 'C-2', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj6', clAECOMProjectReviewCategory__c = 'C-2', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj25', clAECOMProjectReviewCategory__c = 'C-2', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj26', clAECOMProjectReviewCategory__c = 'C-2', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj235', clAECOMProjectReviewCategory__c = 'C-2', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj236', clAECOMProjectReviewCategory__c = 'C-2', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj225', clAECOMProjectReviewCategory__c = 'C-2', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj226', clAECOMProjectReviewCategory__c = 'C-2', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj45', clAECOMProjectReviewCategory__c = 'C-2', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj46', clAECOMProjectReviewCategory__c = 'C-2', ValidateGo__c = false));


        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj7.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj8.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj9.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj27.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj28.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj29.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj37.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj38.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj39.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj47.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj48.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj49.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj307.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj308.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj309.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj407.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj408.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj409.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj507.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj508.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj509.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj607.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj608.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj609.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj707.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj708.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        projects.add(new pse__Proj__c(pse__Account__c = account.Id, Name = 'proj709.3', clAECOMProjectReviewCategory__c = 'C-3', ValidateGo__c = false));
        
        insert projects;
        
        list<ProjectReview__c> projectReviews = [select Id from ProjectReview__c];
        //System.AssertEquals(4, projectReviews.size());
        Test.StartTest();                
        ECO_ProjectLotteryPickBatch projectLotteryBatch = new ECO_ProjectLotteryPickBatch(100);
        Id batchprocessid = Database.executeBatch(projectLotteryBatch);    
        Test.StopTest();        
        
        Id recordTypeId = ECO_Utils_Meta.getRecordTypeId(ProjectReview__c.sObjectType, 'Project Performance Review');
        projectReviews = [select Id from ProjectReview__c where RecordTypeId = :recordTypeId];
        //System.AssertEquals(7, projectReviews.size());
        
    }

}