@isTest
public class AcctandResponseTreeTest {
    static testmethod void testComponent() {
        // Create test account and projects
        List<Project__c> projects = CFM_TestUtils.createTestProjects(1);
        
        Account a = [Select Id from Account limit 1];
        
        CFM_Survey_Response__c surveyResponse = new CFM_Survey_Response__c(Account__c=a.Id);
        insert surveyResponse;
        
        Test.startTest();
        
        System.currentPageReference().getParameters().put('id', a.Id);
        
        AcctandResponseTree cont = new AcctandResponseTree();
        List<AcctandResponseTree.ObjectStructureMap> osm = cont.getObjectStructure();
        
        Test.stopTest();
    }
}