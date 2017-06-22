@isTest
public class ECO_AddPermControlForProjectAcctTest {

    static testMethod void test(){

        //Set up
        ECO_ProjectTriggers.run = false;
        ECO_Project_TeamMember_Triggers.run = false;

        ProjectRole__c pr = new ProjectRole__c(Name='Project Accountant');
        insert pr;
        
        pse__Proj__c p = new pse__Proj__c(pse__Stage__c='Execution');
        insert p;
        
        Contact c = new Contact(User__c=UserInfo.getUserId(), LastName='test');
        insert c;
        
        ProjectTeamMember__c ptm = new ProjectTeamMember__c(Project__c=p.Id, ProjectRole__c=pr.Id, Contact__c=c.Id);
        insert ptm;

        //Run
        Test.startTest();
        Database.executeBatch(new ECO_AddPermControlForProjectAccountant());
        Test.stopTest();

        //Assert
        List<pse__Permission_Control__c> pcs = [Select Id
                                                    , pse__Project__c
                                                    , pse__User__c
                                                    , pse__View_Task_Manager__c
                                                    , pse__Edit_Task_Manager__c
                                                    , AccessReason__c 
                                                    From pse__Permission_Control__c];
                                                    
        system.assertEquals(1, pcs.size()); 
        system.assertEquals(p.Id, pcs[0].pse__Project__c); 
        system.assertEquals(UserInfo.getUserId(), pcs[0].pse__User__c); 
        system.assertEquals(true, pcs[0].pse__View_Task_Manager__c); 
        system.assertEquals(true, pcs[0].pse__Edit_Task_Manager__c); 
        system.assertEquals('Project Accountant', pcs[0].AccessReason__c); 
                     
    }

}