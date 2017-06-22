@isTest (seeAllData=false) 

private class Eco_Project_TeamMember_Trigger_Test {


    	static testMethod void testCreateSharingForTeamMembers(){

            ECO_Service_Delegation.run = false;
    		User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
    		
    		insert testUser;
                        
            ECO_ProjectTriggers.run = false;
            ECO_ProjectTaskTriggers.run = false;
            ECO_Utils_Testing.createTestDataForProjectSync( 2, 2 );
            ECO_ProjectTriggers.run = true;
            ECO_ProjectTaskTriggers.run = true;

            //pse__Proj__c projectOne = ECO_Utils_Testing.createTestProject('Project One');
            //Insert projectOne;
            
            list<ProjectTeamMember__c> lptm = [select id from ProjectTeamMember__c];
            
            system.debug( 'lp size ' + lptm.size() );

            for(ProjectTeamMember__c p : lptm)
            {
                p.StartDate__c = Date.today().addDays(-1);
                p.EndDate__c = Date.today().addDays(100);
                
            }
            
            try
            {
                update lptm;
            }
            catch(Exception e){}
            
            Test.startTest();
            BatchDeleteProjectSharing myBatchObject = new BatchDeleteProjectSharing();
            Database.executeBatch(myBatchObject);            
            Test.stopTest();

        }
}