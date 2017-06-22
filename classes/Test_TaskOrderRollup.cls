/*******************************************************************
  Name        :   Test_TaskOrderRollup
  Author      :   Virendra  (Appirio Off)
  Version     :   1.0 
  Purpose     :   Test Class for Trigger TaskOrderRollup and Apex Class taskOrderRollup
  Date        :   05 Aug, 2010 
********************************************************************/
@istest
public class Test_TaskOrderRollup {

public static testMethod void testTaskOrderRollupProcess1() 
{
    Account c = new Account();
    c.Name = 'Abc Corp';
    c.Phone = '1234567';
    c.Type = 'Client';
    c.Client_Group__c = 'Municipal';
    c.Legacy_AccountID__c = '112211'; 
    insert c; 
     List<RecordType> programRecordType = [select id,name from RecordType where Name = 'Program - APAC' limit 200];
     Test.startTest();
    Opportunity new1Opprtunity = new Opportunity(Legacy_OpportunityID__c='101');
    new1Opprtunity.Name = 'TestOpp1';
    new1Opprtunity.Account = c;
    new1Opprtunity.StageName = '8 No-Go';
    new1Opprtunity.CloseDate = System.today();
    new1Opprtunity.RecordTypeId = programRecordType.get(0).Id;
    //new1Opprtunity.Market_Segment__c = 'Aviation';
    new1Opprtunity.Ceiling_Amount_Total__c = 50;
    new1Opprtunity.amount = 50;
     new1Opprtunity.Probability = 50;
    //new1Opprtunity.Primary_Business_Line__c = 'PDD';
    //new1Opprtunity.Contract_duration_in_Months__c=2.0;
    new1Opprtunity.Estimated_work_start_date__c=date.today();
    new1Opprtunity.Date_lost_cancelled_no_go__c = System.today();
    new1Opprtunity.Date_No_Go__c = date.today();
    new1Opprtunity.Enterprise_Service__c = 'None';
    insert new1Opprtunity;
    Opportunity new4Opprtunity = new Opportunity(Legacy_OpportunityID__c='102');
    new4Opprtunity.Name = 'TestOpp1';
    new4Opprtunity.Account = c;
    new4Opprtunity.StageName = '8 No-Go';
    new4Opprtunity.CloseDate = System.today();  
    new4Opprtunity.Master_Contract_lookup__c = new1Opprtunity.id;
    //new4Opprtunity.Market_Segment__c = 'Aviation';  
    //new4Opprtunity.Primary_Business_Line__c = 'PDD';
    //new4Opprtunity.Contract_duration_in_Months__c=2.0;
    new4Opprtunity.Estimated_work_start_date__c=date.today();
    new4Opprtunity.Probability = 50;
    new4Opprtunity.ProjectCountry__c = 'United States';
    new4Opprtunity.Date_lost_cancelled_no_go__c = System.today();
    new4Opprtunity.Enterprise_Service__c = 'None';
    new4Opprtunity.Date_No_Go__c = date.today();
    insert new4Opprtunity;
    Test.stopTest();
    new4Opprtunity.Ceiling_Amount_Total__c = 100;
    new4Opprtunity.Amount = 100;
    
    update new4Opprtunity;
    
    //for(Opportunity opp : [select id,Task_Orders_Open_Revenue__c from Opportunity where id=:new1Opprtunity.Id limit 200]){
    //    //System.assertEquals(200,opp.Task_Orders_Open_Revenue__c);
    //} 
        
    System.debug('--- Opp 1 '+new1Opprtunity.Task_Orders_Open_Revenue__c); 
    System.debug('--- Opp 1 '+new1Opprtunity.Task_Orders_Booked_Revenue__c);
    System.debug('--- Opp 1 '+new1Opprtunity.Task_Orders_Lost_Revenue__c);
    
    
}    
 public static testMethod void testTaskOrderRollupProcess() {
    Account c = new Account();
    c.Name = 'Abc Corp';
    c.Phone = '1234567';
    c.Type = 'Client';
    c.Client_Group__c = 'Municipal';
    c.Legacy_AccountID__c = '112211'; 
    insert c; 
        
    List<RecordType> programRecordType = [select id,name from RecordType where Name = 'Program - APAC' limit 200];
    
    
    System.debug('Record Type name is ::'+programRecordType.get(0));
    Opportunity new2Opprtunity = new Opportunity(Legacy_OpportunityID__c='103');
    new2Opprtunity.Name = 'TestOpp1';
    new2Opprtunity.Account = c;
    new2Opprtunity.StageName = '8 No-Go';
    new2Opprtunity.CloseDate = System.today();
    new2Opprtunity.RecordTypeId = programRecordType.get(0).Id;
    //new2Opprtunity.Market_Segment__c = 'Aviation';
    new2Opprtunity.Master_Contract_lookup__c = null;
    //new2Opprtunity.Primary_Business_Line__c = 'PDD';
    //new2Opprtunity.Contract_duration_in_Months__c=2.0;
    new2Opprtunity.Estimated_work_start_date__c=date.today();
    new2Opprtunity.Probability = 50;
    new2Opprtunity.Date_lost_cancelled_no_go__c = System.today();
    new2Opprtunity.Date_No_Go__c = date.today();
    new2Opprtunity.Enterprise_Service__c = 'None';
    insert new2Opprtunity;
 
    //Opportunity new1Opprtunity = new Opportunity(Legacy_OpportunityID__c='104');
    //new1Opprtunity.Name = 'TestOpp1';
    //new1Opprtunity.Account = c;
    //new1Opprtunity.StageName = '8 No-Go';
    //new1Opprtunity.CloseDate = System.today();
    //new1Opprtunity.RecordTypeId = programRecordType.get(0).Id;
    //new1Opprtunity.Master_Contract_lookup__c = new2Opprtunity.id;
    ////new1Opprtunity.Market_Segment__c = 'Aviation';
    //new1Opprtunity.Ceiling_Amount_Total__c = 50;
    //new1Opprtunity.amount = 50;
    ////new1Opprtunity.Primary_Business_Line__c = 'PDD';
    ////new1Opprtunity.Contract_duration_in_Months__c=2.0;
    //new1Opprtunity.Estimated_work_start_date__c=date.today();
    //new1Opprtunity.Probability = 50;
    //new1Opprtunity.Date_lost_cancelled_no_go__c = System.today();
    //insert new1Opprtunity;
    
    //for(Opportunity opp : [select id,Task_Orders_Open_Revenue__c from Opportunity where id=:new2Opprtunity.Id limit 200]){
        //System.assertEquals(50,opp.Task_Orders_Open_Revenue__c);
    //}

    Test.startTest(); 
    new2Opprtunity.Ceiling_Amount_Total__c = 100;
    update new2Opprtunity;
    
    Opportunity new3Opprtunity = new Opportunity(Legacy_OpportunityID__c='105');
    new3Opprtunity.Name = 'TestOpp1';
    new3Opprtunity.Account = c;
    new3Opprtunity.StageName = '8 No-Go';
    new3Opprtunity.CloseDate = System.today();  
    new3Opprtunity.Master_Contract_lookup__c = new2Opprtunity.id;
    //new3Opprtunity.Market_Segment__c = 'Aviation';  
    //new3Opprtunity.Primary_Business_Line__c = 'PDD';
    //new3Opprtunity.Contract_duration_in_Months__c=2.0;
    new3Opprtunity.Estimated_work_start_date__c=date.today();
    new3Opprtunity.Probability = 50;
    new3Opprtunity.ProjectCountry__c = 'United States';
    new3Opprtunity.Date_lost_cancelled_no_go__c = System.today();
    new3Opprtunity.Enterprise_Service__c = 'None';
    new3Opprtunity.Date_No_Go__c = date.today();
    insert new3Opprtunity;
    new3Opprtunity.Ceiling_Amount_Total__c = 100;
    new3Opprtunity.Amount = 100;
    Test.stopTest();
    update new3Opprtunity;
    //for(Opportunity opp : [select id,Task_Orders_Open_Revenue__c from Opportunity where id=:new1Opprtunity.Id limit 200]){
        //System.assertEquals(100,opp.Task_Orders_Open_Revenue__c);
   //}
    delete new2Opprtunity;
    
 }
 
 static testMethod void testProjectTaskOrderRollup() {
    ID taskOrderRecType =  [select id from RecordType where DeveloperName = 'Task_Order' and RecordType.SobjectType ='Project__c'].ID;
    ID programRecType =  [select id from RecordType where DeveloperName = 'Program' and RecordType.SobjectType ='Project__c'].ID;
    Account acct = new Account(Name='Test Account');
    insert acct; 


    Project__c parentProject = new Project__c(Name='Test', RecordTypeId=programRecType, Owner__c=acct.Id);
    parentProject.Project_Description__c = 'Test';
    parentProject.Owner__c=acct.Id;
    insert parentProject;
    
    Project__c taskOrder1 = new Project__c(Name='Task Order 1', RecordTypeId=taskOrderRecType);
    taskOrder1.Program_Master_Contract_Name__c = parentProject.id;
    taskOrder1.Modified_fee_value__c = 100;
    taskOrder1.subcontracted_amount__c = 200;
    taskOrder1.Project_Description__c = 'Test';
    taskOrder1.Owner__c = acct.Id;
    insert taskOrder1;
    
    parentProject = [select Id
                        , Sum_of_Task_Order_Fees__c
                        , Sum_of_Task_Order_Subcontracted_Cost__c
                        FROM Project__c WHERE ID = :parentProject.ID];
                        
    System.assertEquals(100, parentProject.Sum_of_Task_Order_Fees__c);      
    System.assertEquals(200, parentProject.Sum_of_Task_Order_Subcontracted_Cost__c);                    
    
    taskOrder1.Modified_fee_value__c = 300;
    taskOrder1.subcontracted_amount__c = 500;
    update taskOrder1;
    
    parentProject = [select Id
                        , Sum_of_Task_Order_Fees__c
                        , Sum_of_Task_Order_Subcontracted_Cost__c
                        FROM Project__c WHERE ID = :parentProject.ID];
                        
    System.assertEquals(300, parentProject.Sum_of_Task_Order_Fees__c);      
    System.assertEquals(500, parentProject.Sum_of_Task_Order_Subcontracted_Cost__c);
    
    delete taskOrder1;
    
    parentProject = [select Id
                        , Sum_of_Task_Order_Fees__c
                        , Sum_of_Task_Order_Subcontracted_Cost__c
                        FROM Project__c WHERE ID = :parentProject.ID];
                        
    System.assertEquals(0, parentProject.Sum_of_Task_Order_Fees__c);        
    System.assertEquals(0, parentProject.Sum_of_Task_Order_Subcontracted_Cost__c);                  
    
 }
  
 public static testMethod void testgetCurrentUser() 
 {
        TaskOrderRollup.getCurrentUser();    
 }
}