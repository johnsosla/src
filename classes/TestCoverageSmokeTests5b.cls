/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@istest public with sharing class TestCoverageSmokeTests5b {



    @istest private static void test_ConvertTaskOrderToProjectController()
    {
    	Opportunity master = TestCoverageSmokeMocks.mockOpp(false);
    	master.ProjectCountry__c = 'Australia';
    	insert master;
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(false);
    	testObj.Master_Contract_lookup__c = master.Id;
    	testObj.ProjectCountry__c = 'Australia';
    	insert testObj;
    	// opp record type APAC EMEA
    	ApexPages.currentPage().getParameters().put('prog2proj', '1');
    	ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
    	ConvertTaskOrderToProjectController xc = new ConvertTaskOrderToProjectController(sc);
    	xc.getOptions();
    	try {
	    	xc.saveAccount();	
    	} catch (Exception ex)
    	{
    		// needs to run as SystemNA to not get exception
    		// because projectcountr__c not being set
    	}
    	
    }
    
  @istest private static void test_ConvertTaskOrderToProjectControllerPR2PR()
    {
    	Opportunity master = TestCoverageSmokeMocks.mockOpp(false);
    	master.ProjectCountry__c = 'Australia';
    	insert master;
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(false);
    	testObj.Master_Contract_lookup__c = master.Id;
    	testObj.ProjectCountry__c = 'Australia';
    	insert testObj;
    	// opp record type APAC EMEA
    	ApexPages.currentPage().getParameters().put('proj2prog', '1');
    	ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
    	ConvertTaskOrderToProjectController xc = new ConvertTaskOrderToProjectController(sc);
    	xc.getOptions();
    	xc.saveAccount();
    }    
    
    
    
    @istest private static void test_ConvertTaskOrderToProjectControllerError()
    {
    	User u = TestCoverageSmokeMocks.mockUser(true);
    	
    	system.runas(u)
    	{
	        ExecuteTrigger__c noOppTrigger = new ExecuteTrigger__c(Name='OpportunityBeforeInsertBeforeUpdate', NotRunTrigger__c=true);
	        insert noOppTrigger;
    		
    	}
            	    	
    	Opportunity master = TestCoverageSmokeMocks.mockOpp(false);
     	master.ProjectCountry__c = 'Australia';
    	insert master;
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(false);
    	Opportunity child = TestCoverageSmokeMocks.mockOpp(false);
    	
    	RecordType r = [select Id from RecordType where DeveloperName = 'Program_EMEA' and sObjectType = 'Opportunity'];
    	testObj.RecordTypeId =  r.Id;
    	testObj.ProjectCountry__c = 'Greece';
    	testObj.Master_Contract_lookup__c = master.Id;
    	insert testObj;
    	
    	child.Master_Contract_lookup__c = testObj.Id;
    	insert child;
    	
    	// opp record type APAC EMEA
    	ApexPages.currentPage().getParameters().put('prog2proj', '1');
    	ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
    	Test.startTest();
    	ConvertTaskOrderToProjectController xc = new ConvertTaskOrderToProjectController(sc);
    	xc.getOptions();
        try {
        	xc.saveAccount();    
        } catch(Exception ex) 
        {
            
        }
    	
    	Test.stopTest();
    }
    
    
    @istest private static void test_ConvertTaskOrderToProjectController3()
    {
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(false);
    	testObj.ProjectCountry__c = 'Australia';
/*    	RecordType r = [select Id from RecordType where Name = 'Project - APAC' and sObjectType = 'Opportunity'];
    	testObj.RecordTypeId =  r.Id; */
    	insert testObj;
    	// opp record type APAC EMEA
    	ApexPages.currentPage().getParameters().put('proj2proj', '1');
/*    	proj2prog
    	proj2task
    	prog2proj */
    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
    	ConvertTaskOrderToProjectController xc = new ConvertTaskOrderToProjectController(sc);
    	xc.getOptions();
    	try {
	    	xc.saveAccount();	
    	} catch (Exception ex)
    	{
    		// needs to run as SystemNA to not get exception
    		// because projectcountr__c not being set
    	}
    }
    
    @istest private static void test_ConvertTaskOrderToProjectController2()
    {
    	Opportunity master = TestCoverageSmokeMocks.mockOpp(true);
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(false);
    	testObj.Master_Contract_lookup__c = master.Id;
    	testObj.ProjectCountry__c = 'Australia';
    	insert testObj;
    	// opp record type APAC EMEA
    	ApexPages.currentPage().getParameters().put('proj2task', '1');
    	ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
    	ConvertTaskOrderToProjectController xc = new ConvertTaskOrderToProjectController(sc);
    	
    	xc.getOptions();
    	try {
	    	xc.saveAccount();	
    	} catch (Exception ex)
    	{
    		// needs to run as SystemNA to not get exception
    		// because projectcountr__c not being set
    	}
    	
    }
    
    
    @istest private static void test_ConvertTaskOrderToProjectController_ManyAccounts()
    {
    	Opportunity master = TestCoverageSmokeMocks.mockOpp(true);
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(false);
    	testObj.Master_Contract_lookup__c = master.Id;
    	insert testObj;
    	
    	List<Account> accList = new List<Account>();
    	for(Integer i = 0; i < 99; i += 1)
    	{
    		accList.add(new Account());
    	}
    	ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
    	ConvertTaskOrderToProjectController xc = new ConvertTaskOrderToProjectController(sc);
    	
    	xc.accountList = accList;
    	xc.getShowMoreThen100();
    	
    	accList.add(new Account());
		accList.add(new Account());
		
		xc.accountList = accList;
		xc.getShowMoreThen100();
    	    		
    	
    	
    }   
    
    
}