/*****************************************
PR          ::  PR-05266
Requester   ::  Karishma Sharma
Purpose     ::  Test Functionality for Trigger named "PopulateAECOMPrimaryDepartment"
                Automatically populatedBased corresponding Lead Region, Lead district and
                Geography on the basis Primary Dept value selected by the user
Author      ::  Appirio Offshore(Shailendra Singh)
Date        ::  28-Jun-2010  
*****************************************/
@isTest
private class Test_PopulateAECOMPrimaryDepartment {
    static testMethod void testAECOMPrimaryDepartment(){
        //Case 1
        //AECOM_Primary_Department__c dept=[select ID,Geography__c from AECOM_Primary_Department__c LIMIT 1];
        AECOM_Primary_Department__c dept=[select ID,Geography__c from AECOM_Primary_Department__c WHERE Status__c = 'Active' LIMIT 1];
        AECOM_Employee__c emp=new AECOM_Employee__c(Name='abc def',First_name__c='abc',Last_Name__c='def',Employee_Id__c='11');
        insert emp;
        Opportunity op=new Opportunity(Legacy_OpportunityID__c='101');
        op.Name='Test case opportunity';
        op.CloseDate=Date.today().addDays(30);
        op.StageName='Prospecting';
        op.Amount=100;
        op.Win_Probability__c=10;
        op.CloseDate = Date.today().addDays(5);
        op.Book_date__c=Date.today().addDays(-1);
        op.AECOM_Primary_Dept_Lookup__c=dept.ID;
        //op.Contract_duration_in_Months__c=2.0;
        op.Capture_Manager__c = emp.id;
        op.Enterprise_Service__c = 'Engineering';

        // added to pass validation rule
        op.CS_Gross_Margin_Percent__c = 15;        

        insert op;
        
        ///op = [select id,Name,Geography__c from Opportunity where id =:op.Id];
        //System.assertEquals(op.Lead_District__c, dept.Lead_District__c);
        //System.assertEquals(op.Lead_Region__c, dept.Lead_Region__c);
        //System.assertEquals(op.Geography__c, dept.Geography__c);
        //Checking Update
        //update op;
        
        //op = [select id,Name,Geography__c from Opportunity where id =:op.Id];
        //System.assertEquals(op.Lead_District__c, dept.Lead_District__c);
        //System.assertEquals(op.Lead_Region__c, dept.Lead_Region__c);
        //System.assertEquals(op.Geography__c, dept.Geography__c);
        
        //.....................................//
        
        //Case 2
        
        AECOM_Primary_Department__c dept2 = dept.clone(false, true);    
       // AECOM_Primary_Department__c dept2=[select ID,Lead_District__c,Lead_Region__c,Geography__c from AECOM_Primary_Department__c where ID != :dept.ID LIMIT 1];
        if(dept2!=null){
            op.AECOM_Primary_Dept_Lookup__c=dept2.ID;
            update op;
            //op = [select id,Name,Geography__c from Opportunity where id =:op.Id];
            //System.assertEquals(op.Lead_District__c, dept2.Lead_District__c);
            //System.assertEquals(op.Lead_Region__c, dept2.Lead_Region__c);
            //System.assertEquals(op.Geography__c, dept2.Geography__c);
        }
    }
    
    static testMethod void testAECOMTeam(){
      Map<String,ID> recordTypesMap = new Map<String,ID>();
        for(RecordType r:[select id,Name from RecordType where sObjectType='AECOM_team__c' and isActive=true]){
            recordTypesMap.put(r.Name,r.Id);
            system.debug('###' + r.Name);
        }
        
        // Account
        Account acc1=new Account();
        acc1.Name='Test Account1';
        acc1.Type__c='Client';
        acc1.Client_Group__c='Industrial/Commercial';
        acc1.Client_Subgroup__c='Small - population under 500K';
        acc1.Legacy_AccountID__c='1221234';
        acc1.City__c='testCity';
        insert acc1;
        
        AECOM_Employee__c emp= new AECOM_Employee__c();
          emp.First_Name__c = 'EMP1';
          emp.Last_Name__c = 'Emp2';
          emp.Employee_ID__c ='001';
        insert emp;
          
        AECOM_team__c aecomTeam = new AECOM_team__c();
         aecomTeam.Account__c = acc1.id;
         aecomTeam.role__c = 'Other';
         aecomTeam.Employee__c = emp.id;
         aecomTeam.RecordTypeId=recordTypesMap.get('AECOM Team - Account');
         
         
        insert aecomTeam;
    }
}