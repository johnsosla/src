@istest
public with sharing class Test_ChatterTriggers {
	
	@istest (seealldata=true)
	static void testChatterProjectTriggers() {
        Project_Settings__c settings = Project_Settings__c.getInstance();
        settings.Review_Request_On_Chatter__c = true;
        upsert settings;
		
        Account acct = new Account(Name='Test Account');
        insert acct;
        
        Project__c proj = new Project__c();
        proj.Name='Test';
        proj.Project_Name__c = 'Testing';
        proj.Owner__c=acct.Id;
        proj.Project_Description__c = 'Test';
        insert proj;
        
        FeedItem fi = new FeedItem(parentId=proj.Id);
        fi.Body = 'Test';
        fi.Type = 'TextPost';
        fi.Title = 'Test';
        insert fi;
        
        proj = [SELECT ID, Review_Requested__c FROM Project__c WHERE ID = :proj.ID];
        System.assertEquals(true, proj.Review_Requested__c);
        proj.Review_Requested__c = false;
        update proj;
        
        FeedComment fc = new FeedComment();
        fc.FeedItemId = fi.ID;
        fc.CommentBody = 'Test';
        fc.CommentType = 'TextComment';
        
        insert fc;
        proj = [SELECT ID, Review_Requested__c FROM Project__c WHERE ID = :proj.ID];
        System.assertEquals(true, proj.Review_Requested__c);
        
		
	}
}