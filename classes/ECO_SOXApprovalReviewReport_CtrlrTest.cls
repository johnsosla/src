@isTest(SeeAllData=false)
private class ECO_SOXApprovalReviewReport_CtrlrTest {

        static testMethod void initializeData(){ 

            User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
            insert testUser;
                        
            Test.startTest(); 
            System.runAs(testUser ){
            ECO_SOXApprovalReviewReport_Controller c = new ECO_SOXApprovalReviewReport_Controller();
            c.callBatch();
            
            }
            
            //ECO_SOXApprovalReviewReport_Controller cont = new ECO_SOXApprovalReviewReport_Controller();                
            //cont.initializeReport();
             
            
            
            Test.stopTest();


        } 


}