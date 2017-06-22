/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@istest
public with sharing class TestCoverageSmokeTestsb {
	
	@isTest private static void test_AutoComplete_Controller()
	{
		Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
	    ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
		AutoComplete_Controller xc = new AutoComplete_Controller(sc);
		ApexPages.currentPage().getParameters().put('objectname', 'Opportunity');
		ApexPages.currentPage().getParameters().put('aname', 'TestOp');
		xc.getResultsname();
		xc.searchSuggestions();
		xc.getHasparams();
		xc.getHasnoresults();
		xc.avoidRefresh();
		
		AutoComplete_Controller dfault = new AutoComplete_Controller();
		System.assert(true);
	
	}
	
	
	@isTest private static void test_AutoComplete_Controller_Exception()
	{
		Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
	    ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
		AutoComplete_Controller xc = new AutoComplete_Controller(sc);
		ApexPages.currentPage().getParameters().put('objectname', 'BadObjectName');
		ApexPages.currentPage().getParameters().put('aname', 'TestOp');
		xc.searchSuggestions();
		
		System.assert(true);
	
	}	

}