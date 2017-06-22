/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@istest
public with sharing class TestCoverageSmokeTests6b {


    @istest private static void test_CollectionManagerController2()
    {
        Practice_Area_Collection__c pac = new Practice_Area_Collection__c();
        insert pac;
        
        CollectionManagerController testClass = new CollectionManagerController();
        testClass.Filter();
        testClass.Save();
        
        Integer listCount = testClass.getUpdateList().size();
        for(Integer i = 0; i < listCount; i += 1)
        {
            testClass.getUpdateList()[i].isDelete = true;
        }
        for(Integer i = 0; i < testClass.NewcollectionList.size(); i += 1)
        {
            testClass.NewcollectionList[i].isDelete = true;
        }
        testClass.DeleteSelected();
        
        
    }
    
    @istest private static void test_CollectionManagerController3()
    {
        // test case where collection size = 300
        List<Practice_Area_Collection__c> pacList = new List<Practice_Area_Collection__c>();
        for(Integer i = 0; i <= 301; i += 1) {
            pacList.add(new Practice_Area_Collection__c());
        }
        insert pacList;
        
        CollectionManagerController testClass = new CollectionManagerController();
        testClass.Filter();
        
    }    
    
    
    @istest private static void test_rsAutoCompleteController1()
    {
        
        rs_Profile_Part__c pp = new rs_Profile_Part__c();
        pp.License_Registration_Name__c = 'testLicense';
        pp.State_Province__c = 'AZ';
        pp.Country__c = 'USA';
        pp.Registration_Number__c = '12345';
        pp.Issued_Date__c = Date.parse('12/03/2013');
        pp.Expiration_Date__c = Date.parse('01/01/2016');
        pp.Skill__c = 'prefix1';
        pp.Skill_Area__c = 'prefix2';
        insert pp;
        
        rs_Profile_Part__c pp2 = new rs_Profile_Part__c();
        pp2.License_Registration_Name__c = 'testLicense';
        pp2.State_Province__c = 'AZ';
        pp2.Country__c = 'USA';
        pp2.Registration_Number__c = '12345';
        pp2.Issued_Date__c = Date.parse('12/03/2013');
        pp2.Expiration_Date__c = Date.parse('01/01/2016');
        pp2.Skill__c = 'prefix1';
        pp2.Skill_Area__c = null;
        insert pp2;
        
        
        rsAutoCompleteController.getValues('prefix', 'Skill__c', 'rs_Profile_Part__c', String.valueOf(UserInfo.getUserId()), 'User__c');
        
        
    }
    
    
    
        

@isTest private static void test_ConvertProjectToTaskOrderControllerEMEA(){
        Opportunity testObj = TestCoverageSmokeMocks.mockOpp(false);
        RecordType r = [select Id from RecordType where DeveloperName = 'Program_EMEA' and sObjectType = 'Opportunity'];
        testObj.RecordTypeId = r.Id;
        insert testObj;
        ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
        ConvertProjectToTaskOrderController xc = new ConvertProjectToTaskOrderController(sc);
        xc.opportunityName = 'test';
        xc.searchOpportunities1();
        
}
    
@isTest private static void test_ConvertProjectToTaskOrderControllerAmericas(){
        Opportunity testObj = TestCoverageSmokeMocks.mockOpp(false);
        RecordType r = [select Id from RecordType where DeveloperName = 'Program_Americas' and sObjectType = 'Opportunity'];
        testObj.RecordTypeId = r.Id;
        testObj.TO_Procurement_Method__c = 'test';
        insert testObj;
        ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
        ConvertProjectToTaskOrderController xc = new ConvertProjectToTaskOrderController(sc);
        xc.opportunityName = 'test';
        xc.searchOpportunities1();
        
}


    
    
        @isTest private static void test_ConvertProjectToTaskOrderController(){
            Opportunity testObj = TestCoverageSmokeMocks.mockOpp(false);
            
            insert testObj;
        /*    Opportunity newOpp = TestCoverageSmokeMocks.mockOpp(true); */
         
            ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
            ConvertProjectToTaskOrderController xc = new ConvertProjectToTaskOrderController(sc);
            xc.masterContracts = null;
            System.assert(! xc.getShowMoreThen100() );
            
            List<Opportunity> oppList = new List<Opportunity>();
            
            for(Integer i = 0; i <= 100; i +=  1)
            {
                oppList.add(new Opportunity());
            }
            
            xc.masterContracts = oppList;
            System.assert( xc.getShowMoreThen100() );
            xc.masterContracts = null;
            
            xc.opportunityName  = null;
            xc.selectedOption = '!sameAccount';
            System.assert(! xc.searchOpportunities1() );
            
            xc.opportunityName = 'test';
            xc.selectedOption  = 'sameAccount';
            xc.goNext();
            
        }   
        



    

}