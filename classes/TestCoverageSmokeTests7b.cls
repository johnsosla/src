/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@istest
public with sharing class TestCoverageSmokeTests7b {

    
    
    static testMethod void test_noCriteria()
    {
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		cont.getSearch().setConditions(advCond);
		cont.getSearch().setFilter('1 OR 2');
		try {
					cont.basicSearch();
		} catch(Exception ex)
    	{
    		
    	}

    }
        
   static testMethod void test_userSearch2()
    {
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0,new rsSearch.Condition('Test','e','User|LastName'));
		advCond.set(1,new rsSearch.Condition('Test','e','User|LastName'));
		cont.getSearch().setConditions(advCond);
		cont.basicSearch();
    }
    
    static testMethod void test_userSearch()
    {
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0,new rsSearch.Condition('Test','e','User|LastName'));
		advCond.set(1,new rsSearch.Condition('User','e','User|LastName'));
		cont.getSearch().setConditions(advCond);
		cont.getSearch().setFilter('1 AND 2');
		cont.basicSearch();
    	
    }    
    static testMethod void test_userSearch_bad_searches()
    {
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0,new rsSearch.Condition('Test','ne','User|LastName'));
		advCond.set(1,new rsSearch.Condition('user','ne','User|LastName'));
		cont.getSearch().setConditions(advCond);
		cont.getSearch().setFilter('1 OR 2 AND 1 1A');
		cont.basicSearch();
		cont.getSearch().setFilter('1 OR 2 AND 1 123');
		cont.basicSearch();
		cont.getSearch().setFilter('1 OR 2 AND 1 12');
    	cont.basicSearch();
    	
    	
    	advCond.set(2,new rsSearch.Condition('basic','ne','User|LastName'));
    	cont.getSearch().setConditions(advCond);
    	
		cont.getSearch().setFilter('1 OR 2 1A');
		cont.basicSearch();
		cont.getSearch().setFilter('1 OR 2 123');
		cont.basicSearch();
		cont.getSearch().setFilter('1 OR 2 12');
    	cont.basicSearch();
    	
    	    	
    }     
    
       	
   static testMethod void test_shouldPPSearch()
    {
    	User u = TestCoverageSmokeMocks.mockUser(false);
    	insert u;
    	
    	system.runAs(u)
    	{
			rs_Profile_Part__c pp = new rs_Profile_Part__c();
			pp.License_Registration_Name__c = 'XYZ';
			pp.State_Province__c = 'AZ';
			pp.Country__c = 'USA';
			pp.Registration_Number__c = '12345';
			pp.Issued_Date__c = Date.parse('12/03/2013');
			pp.Expiration_Date__c = Date.parse('01/01/2016');
			pp.Skill__c = 'prefix1';
			pp.Skill_Area__c = 'prefix2';
			pp.User__c = u.Id;
			insert pp;
    	}
    	
		
		    	
    	rsSearchResumesController c = new rsSearchResumesController();
    	c.getSearch().setTextSearch('test');
    	c.getSearch().setLicenseRegistration('XYZ');
    	c.basicSearch();
    	
    }
}