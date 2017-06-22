/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Warning ProjectOpportunityExtension can produce some strange errors when tested in conjuction
with other classes
***************************************************************************/
@isTest
private class TestCoverageSmokeTests10 {

    @istest private static void test_ProjectOpportunityExtension_Task()
    {
            RecordType r = [Select Id FROM RecordType where Name like '%Task%' AND sObjectType='Opportunity' LIMIT 1];
            
            Opportunity testObj = setup(r.Id);
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
            ProjectOpportunityExtension xc = new ProjectOpportunityExtension(sc);
            xc.saveProject();
            Test.stopTest();
    }
    
    @istest private static void test_ProjectOpportunityExtension_Project()
    {
            RecordType r = [Select Id FROM RecordType where Name like '%Project%' AND sObjectType='Opportunity' LIMIT 1];
            
            Opportunity testObj = setup(r.Id);
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
            ProjectOpportunityExtension xc = new ProjectOpportunityExtension(sc);
            xc.saveProject();
            Test.stopTest();
    }
    
    
    @istest private static void test_ProjectOpportunityExtension_ExistingProject()
    {
            Project__c mockProj = TestCoverageSmokeMocks.mockProject();
            
            Opportunity testObj = setup(null);
            
            mockProj.Opportunity__c = testObj.Id;
            update mockProj;
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
            ProjectOpportunityExtension xc = new ProjectOpportunityExtension(sc);
            xc.saveProject();
            Test.stopTest();
    }   
    
    @istest private static void test_ProjectOpportunityExtension_ExistingProject2()
    {
            Project__c mockProj = TestCoverageSmokeMocks.mockProject();
            
            Opportunity testObj = setup(null);
            
            mockProj.Oracle_Project_Number__c = testObj.AECOM_Job_number__c;
            update mockProj;
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
            ProjectOpportunityExtension xc = new ProjectOpportunityExtension(sc);
            xc.saveProject();
            
            
            Test.stopTest();
    }   
    
    
    @istest private static void test_ProjectOpportunityExtension_ExistingProject3()
    {
            Opportunity testObj = setup(null);
            testObj.AECOM_Job_number__c = null;
            testObj.Name = 'test';
            update testObj;
            
            User u = TestCoverageSmokeMocks.mockUser();
            
            
            Test.startTest();
            
            system.runAs(u)
            {
            ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
            ProjectOpportunityExtension xc = new ProjectOpportunityExtension(sc);
            xc.saveProject();
            
            
                
            }
            
            Test.stopTest();
    }   
    
        
    
    @istest private static void test_ProjectOpportunityExtension_InvalidStage()
    {
            
            Opportunity testObj = setup(null);
            testObj.StageName = '1 xxx';
            
            update testObj;
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
            ProjectOpportunityExtension xc = new ProjectOpportunityExtension(sc);
            Test.stopTest();
    }
        
    
    
    private static Opportunity setup(Id recordId)
    {
            Opp_Project_Field_Map__c xx = new Opp_Project_Field_Map__c();
            xx.Name = 'AECOM_Job_number__c';
            xx.Project_Field_Name__c = 'Project_Name__c';
            xx.Default_Value__c = '12345';
            insert xx;
        
            Opp_Project_Field_Map__c xxy = new Opp_Project_Field_Map__c();
            xxy.Name = 'Description';
            xxy.Project_Field_Name__c = 'Project_Description__c';
            xxy.Default_Value__c = '12345';
            insert xxy;     
            
            Opp_Project_Field_Map__c acc = new Opp_Project_Field_Map__c();
            acc.Name = 'AccountId';
            acc.Project_Field_Name__c = 'Owner__c';
            acc.Default_Value__c = '000000000000000000';
            insert acc;                
            
            Opp_Project_Field_Map__c xxx = new Opp_Project_Field_Map__c();
            xxx.Name = 'Name';
            xxx.Project_Field_Name__c = 'Name';
            xxx.Default_Value__c = 'Project Name';
            insert xxx; 
        
            Opp_Project_Field_Map__c abc = new Opp_Project_Field_Map__c();
            abc.Name = 'Project_City__c';
            abc.Project_Field_Name__c = 'Project_City__c';
            abc.Default_Value__c = 'Project city';
            insert abc; 

            Opp_Project_Field_Map__c abc2 = new Opp_Project_Field_Map__c();
            abc2.Name = 'ProjectCountry__c';
            abc2.Project_Field_Name__c = 'Project_Country__c';
            abc2.Default_Value__c = 'Project country';
            insert abc2;            
            
            ValidState__c state = new ValidState__c();
            state.State__c = null;
            state.Country__c = 'Australia';
            insert state;
            
            Opportunity testObj = TestCoverageSmokeMocks.mockOpp(false);
            testObj.Name = 'a'.repeat('', 81);
            if(recordId != null)
            {
                testObj.RecordTypeId = recordId;
                
            }
            testObj.StageName = '6 xxx';
            testObj.CloseDate = System.Date.today();
            testObj.AECOM_Job_number__c = '123456789';
            testObj.Contract_Est_Days__c = 1;
            testObj.WinDate__c = Datetime.now().date();
            //testObj.Project_State_Province__c = 'Victoria';
            testObj.ProjectCountry__c = 'Australia';
            testObj.Reason_Won_or_Lost__c = 'Technical Team';
            insert testObj;
            
            return testObj;
        
    }
}