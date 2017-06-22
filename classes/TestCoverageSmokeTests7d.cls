/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@istest
public with sharing class TestCoverageSmokeTests7d {

	
	@istest static void test_generateExcel()
	{
		List<User> userList = new List<User>();
		List<User> mm = TestCoverageSmokeMocks.mockUsers(50, true); 
		
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0,new rsSearch.Condition('Test','c','User|LastName'));
		cont.getSearch().setConditions(advCond);
		SelectOption so = new SelectOption('User|Bio__c', 'User|Bio__c');
		cont.getSearch().getSelectedFieldOptions().add(so);
		system.runAs(mm[0])
		{
			
			cont.basicSearch();
			cont.setSelectAll(true);
			cont.selectAllSearchResults();
			
			Test.startTest();
			cont.generateExcel();
			Test.stopTest();
			
		}
	}	
	
	
	@istest static void test_generateExcel_long()
	{
		List<User> userList = new List<User>();
		List<User> mm = TestCoverageSmokeMocks.mockUsers(200, false); 
		
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0,new rsSearch.Condition('Test','c','User|LastName'));
		cont.getSearch().setConditions(advCond);
		SelectOption so = new SelectOption('User|Bio__c', 'User|Bio__c');
		cont.getSearch().getSelectedFieldOptions().add(so);
		system.runAs(mm[0])
		{
			
			cont.basicSearch();
			cont.setSelectAll(true);
			cont.selectAllSearchResults();
			
			Test.startTest();
			cont.generateExcel();
			Test.stopTest();
			
		}
	}	
	
	
	@istest static void test_generateExcel_no_results()
	{
		List<User> userList = new List<User>();
		List<User> mm = TestCoverageSmokeMocks.mockUsers(1, false); 
		
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0,new rsSearch.Condition('no_results_for_this','c','User|LastName'));
		cont.getSearch().setConditions(advCond);
		system.runAs(mm[0])
		{
			
			cont.basicSearch();
			Test.startTest();
			cont.generateExcel();
			Test.stopTest();
			
		}
	}		
	

}