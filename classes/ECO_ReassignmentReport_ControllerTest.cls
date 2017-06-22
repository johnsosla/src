@isTest(SeeAllData=true)
private class ECO_ReassignmentReport_ControllerTest {

        static testMethod void initializeData(){ 

            User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
            insert testUser;
               
            Test.startTest();     
            System.runAs(testUser){            	
            	ECO_ReassignmentReport_Controller c = new ECO_ReassignmentReport_Controller();  
            	c.callBatch();
            	System.assertEquals(true, c.bIsRunning);              
            }           
            
            Test.stopTest();
        }        

}