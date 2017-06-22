@isTest

public class BatchDeleteProjectSharingTest {
    
    static testMethod void TestBatchDeleteProjectSharing()
    {
        
        User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
		insert testUser;
        
        User user1 = ECO_Utils_Testing.createTestUser('System Administrator');
        User user2 = ECO_Utils_Testing.createTestUser('Standard User');
        List<User> lUser = new List<User>();
        lUser.add(user1);
        lUser.add(user2);
        insert lUser;
        
        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
        Contact testContact = new Contact();
        testContact.Email = user1.Email;
        testContact.FirstName = user1.FirstName;
        testContact.LastName =  user1.LastName;
        testContact.Phone = '55555555555';
        testContact.pse__Salesforce_User__c = user1.Id;
        testContact.RecordTypeId = recordTypeId;
        testContact.User__c = user1.Id;
        insert testContact;
        
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;                
        ECO_Utils_Testing.createTestDataForProjectSync( 2, 90 );
        ECO_ProjectTaskTriggers.run = true;
        ECO_ProjectTriggers.run = true;
        
        ProjectRole__c projectRole = new ProjectRole__c();
        projectRole.Name = 'Deliverable Approver';
        projectRole.Type__c = 'Team Member';
        projectRole.Active__c = true;
        insert projectRole;
        
        pse__Proj__c testProject = [select Id, pse__Account__c, pse__Stage__c from pse__Proj__c limit 1];
        
        Date endDate = Date.today()-1;
        test.starttest();
        ProjectTeamMember__c ptm = new ProjectTeamMember__c (Contact__c = testContact.Id, ProjectRole__c = projectRole.Id, Project__c = testProject.Id, Processed_by_DeleteShareBatch__c = false, EndDate__c = endDate);
        insert ptm;
        
        List<SObject> projectTeamMemberItemsToProcess = [SELECT Active__c, StartDate__c, EndDate__c, Contact__c, Id, Project__c, contact__r.name, contact__r.pse__Salesforce_User__c 
                                                         FROM ProjectTeamMember__c 
                                                         where Processed_by_DeleteShareBatch__c = false 
                                                         and Active__c = false 
                                                         and EndDate__c <= TODAY 
                                                         order by EndDate__c desc];
    	BatchDeleteProjectSharing myBatchObject = new BatchDeleteProjectSharing();
        myBatchObject.execute(null, projectTeamMemberItemsToProcess);
        myBatchObject.execute(null);

        
		Database.executeBatch(myBatchObject);
        test.stoptest();
	}    
}