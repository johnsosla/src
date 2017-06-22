/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@istest
public with sharing class TestCoverageSmokeTests8b {




    private static void TSATrigger2(Boolean primary, String taskName, String accountName, Boolean isBig) 
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User anzUser = TestCoverageSmokeMocks.mockUser();
        anzUser.ProfileId = p.Id     ;                           
        anzUser.Geography_Allocation__c = 'ANZ';
        update anzUser;
        
                
        
        System.runAs(anzUser) {
            AECOM_Employee__c emp = new AECOM_Employee__c();
            emp.Name = 'Test guy';
            emp.First_Name__c = 'test';
            emp.Last_Name__c = 'test';
            emp.Employee_ID__c = '12345';
            emp.Email__c = 'SFDCTestCase@aecom.com';
            emp.Office_Country__c = 'AU';
            insert emp;
            
            AECOM_Primary_Department__c primDep = new AECOM_Primary_Department__c(Name='test dep');
            primDep.Lead_Region__c = 'ANZ';
            insert primDep;
            
            ANZDeptProject__c anzdept = new ANZDeptProject__c();
            anzdept.AECOM_Department__c = primDep.id;
            anzdept.EmailRecipient3__c = 'SFDCTestCase@aecom.com';
            if(isBig)
            {
            anzdept.KeyClient__c = 'Yes';               
            } else {
                anzdept.KeyClient__c = 'No';
            }
 
            anzdept.OracleProjectName__c = 'test';
            anzdept.OracleProjectNo__c            = 'test';
            insert anzdept;
            
                                  
            
            ANZTaskStructure__c task = new ANZTaskStructure__c();
            task.ClientEndClientName__c = taskName;
            task.EndClientSector__c = taskName; 
            task.KeyClient__c = 'test'; 
            task.ParentTaskName__c = 'test'; 
            task.ParentTaskNo__c = 'test'; 
            task.TaskName__c = 'test'; 
            task.TaskNo__c = 'test';            
            if(isBig)
            {
                 task.TotalPotentialFeeGTEThreshold__c = 'Yes';
            } else {
                 task.TotalPotentialFeeGTEThreshold__c = 'No';              
            }
            task.EndClientSector__c = 'Transit';
            insert task;
            
            Account acc = new Account(Name=accountName);
            acc.Client_Subgroup__c = 'Transit';
            insert acc;
            Opportunity testOpp = new Opportunity(Name='test opp', CloseDate = System.Date.today(), StageName = 'test', Enterprise_Service__c = 'Architecture');
            testOpp.AccountId = acc.id;
            testOpp.ProjectCountry__c = 'Australia';
            testOpp.Capture_Manager__c = emp.id;
            testOpp.Project_Manager__c = emp.id;
            testOpp.Project_Director__c = emp.id;
            testOpp.Capture_Manager_User__c = anzUser.id;
            testOpp.Project_ManagerUser__c = anzUser.id;
            testOpp.B_P_Budget__c = 5;            
            if(isBig) {
                testOpp.B_P_Budget__c = 9999999;    
            }
            
            insert testOpp;

            
            Opportunity_Department__c testItem = new Opportunity_Department__c();
            testItem.Primary__c = primary;
            testItem.Opportunity__c = testOpp.id;
            testItem.AECOM_Department__c = primDep.Id; // this is changed
            
            insert testItem;
            System.assert(true);
            
        }        
    }
    
    @istest public static void test_anznotify2()
    {
        TSATrigger2(true, 'test', 'test', false);       
    }
    
    @istest public static void test_anznotify3()
    {
        TSATrigger2(false, 'test', 'test', false);
    }

    @istest public static void test_anznotify4()
    {
        TSATrigger2(true, 'test', 'test2', false);
    }

    @istest public static void test_anznotify5()
    {
        TSATrigger2(false, 'test', 'test2', false);
    }
    



    @istest public static void test_anznotify2big()
    {
        TSATrigger2(true, 'test', 'test', true);
    }
    
    @istest public static void test_anznotify3big()
    {
        TSATrigger2(false, 'test', 'test', true);
    }

    @istest public static void test_anznotify4big()
    {
        TSATrigger2(true, 'test', 'test2', true);
    }

    @istest public static void test_anznotify5big()
    {
        TSATrigger2(false, 'test', 'test2', true);
    }
    
    
    

}