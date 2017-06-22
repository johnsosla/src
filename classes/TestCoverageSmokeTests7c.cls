/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@istest
public with sharing class TestCoverageSmokeTests7c {

  
  static testMethod void test_buildUserSOQLWhereCriteria_text_Split()
    {
    	rsSearchResumesController c = new rsSearchResumesController();
    	c.getSearch().setTextSearch('test');
    	c.basicSearch();
    	c.getSearch().setTextSearch('test test');
    	c.basicSearch();
    	c.getSearch().setTextSearch('test test test');
    	c.basicSearch();
    	
    	
    	
    }    
    
    
    static testMethod void test_simpletests() {
    	rsSearchResumesController c = new rsSearchResumesController();
    	c.getSearchDuration();
    	c.setResultsMap(c.getResultsMap());
    	c.getIsContentManager();
    	c.clearDownload();
    	c.beginning();
    	c.previous(); // follow up on this
    	c.next();
    	c.end();
        // TO DO: implement unit test
    }
    
   static testMethod void test_BasicShortKeyword() {
    	rsSearchResumesController c = new rsSearchResumesController();
    	c.getSearch().setTextSearch('a');
    	c.basicSearch();
    
    }    
    
    
	@istest static void test_generateResume()
	{
		
		Test.setMock(HttpCalloutMock.class, new rsGenerationMockResp());
		
		List<User> mm = TestCoverageSmokeMocks.mockUsers(6, false); 
		
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0,new rsSearch.Condition('Test','c','User|LastName'));
		cont.getSearch().setConditions(advCond);
//		SelectOption so = new SelectOption('User|Bio__c', 'User|Bio__c');
		system.runAs(mm[0])
		{
			cont.basicSearch();
			cont.setSelectAll(true);
			cont.selectAllSearchResults();
			
			Test.startTest();
			cont.generateResumes();
			Test.stopTest();
			
		}
	}	
    
    
	@istest static void test_generateResumeNoResults()
	{
		List<User> mm = TestCoverageSmokeMocks.mockUsers(6, false); 
		
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0,new rsSearch.Condition('no_results_search_term','c','User|LastName'));
		cont.getSearch().setConditions(advCond);
//		SelectOption so = new SelectOption('User|Bio__c', 'User|Bio__c');
		system.runAs(mm[0])
		{
			cont.basicSearch();
			cont.setSelectAll(true);
			cont.selectAllSearchResults();
			
			Test.startTest();
			cont.generateResumes();
			Test.stopTest();
			
		}
	}	
	
	@istest static void test_generateResumeOver30()
	{
		List<User> mm = TestCoverageSmokeMocks.mockUsers(31, false); 
		
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0,new rsSearch.Condition('test','c','User|LastName'));
		cont.getSearch().setConditions(advCond);
//		SelectOption so = new SelectOption('User|Bio__c', 'User|Bio__c');
		system.runAs(mm[0])
		{
			cont.basicSearch();
			cont.setSelectAll(true);
			cont.selectAllSearchResults();
			
			Test.startTest();
			cont.generateResumes();
			Test.stopTest();
			
		}
	}	

}