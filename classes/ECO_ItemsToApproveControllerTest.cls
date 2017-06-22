@isTest

public class ECO_ItemsToApproveControllerTest {


    static testMethod void test(){

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User mgr = new User(        
            Alias = 'standt', Email='standarduser@aecom.com',
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
              LocaleSidKey='en_US', ProfileId = p.Id,
              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@aecom.com',
              isActive=true
              
        );    
        insert mgr;
        
        User u = new User(    
            Alias = 'standt2', Email='standarduser2@aecom.com',
              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
              LocaleSidKey='en_US', ProfileId = p.Id,
              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@aecom.com',
            ManagerId = mgr.Id, isActive=true
        );    
        insert u; 
        
    
        System.runAs(mgr){

            //arrange

            ECO_ProjectTaskTriggers.run = false;
            ECO_ProjectTriggers.run = false;
            pse__Proj__c prj = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
            prj.ProjectApproverUserForProcess__c = mgr.Id;
            update prj;

            ECO_ProjectTriggers.run = true;
            ECO_ProjectTaskTriggers.run = true;

            // Create an approval request for the project
        
            Test.startTest();
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(prj.id);
            req1.setSubmitterId(u.Id);
            req1.setNextApproverIds(new Id[] {mgr.Id});        
            approval.ProcessResult result = Approval.process(req1);
               
            System.assert(result.isSuccess());        
        
        
            //act
            ECO_ItemsToApproveController controller = new ECO_ItemsToApproveController();
        
            //assert
            system.assertEquals(1, [SELECT ProcessInstance.TargetObjectId
                                                     , ActorId
                                                     , Actor.Name
                                                     , CreatedDate  
                                                     FROM ProcessInstanceWorkitem
                                                     ].size());     
            system.assertEquals(1, controller.pws.size()); 
            Test.stopTest();
                 
        }    
  
    }
    
    
   
}