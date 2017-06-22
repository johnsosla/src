/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@isTest
private class TestCoverageSmokeTests7 {
    


    @istest static void test_advancedConditionsFilterWithBad()
    {
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0,new rsSearch.Condition('Test','e','rs_Profile_Part__c|Training_Name__c'));
		advCond.set(1,new rsSearch.Condition('Test','ne','User|LastName'));
		advCond.set(2,new rsSearch.Condition('Test','sw','PR_Team_Employee__c|Location_City__c'));
		advCond.set(3,new rsSearch.Condition('Test','dnc','rs_Profile_Part__c|Training_Name__c'));
		advCond.set(4,new rsSearch.Condition('Test','lt','rs_Profile_Part__c|Training_Name__c'));
		advCond.add(new rsSearch.Condition('Test','gt','rs_Profile_Part__c|Training_Name__c'));
		advCond.add(new rsSearch.Condition('Test','loe','rs_Profile_Part__c|Training_Name__c'));
		advCond.add(new rsSearch.Condition('Test','BAD','rs_Profile_Part__c|Training_Name__c'));
		advCond.add(new rsSearch.Condition('Test','goe','rs_Profile_Part__c|Training_Name__c'));
		advCond.add(new rsSearch.Condition('Test','c','User|AboutMe')); // text area fields
		advCond.add(new rsSearch.Condition('Test','dnc','User|AboutMe'));
		cont.getSearch().setConditions(advCond);
		
		cont.getSearch().setFilter('1 OR 2');
		cont.basicSearch();
		
    }

    
    
    
    @istest  static  void test_PRTSearch()
    {
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0,new rsSearch.Condition('Test','sw','PR_Team_Employee__c|Location_City__c'));
		advCond.set(1,new rsSearch.Condition('Test','sw','PR_Team_Employee__c|Location_City__c'));
		cont.getSearch().setConditions(advCond);
		cont.getSearch().setFilter('1 OR 2');
		cont.basicSearch();
    }    
    
   @istest  static  void test_BuildUserCriteria() {
    	rsSearchResumesController c = new rsSearchResumesController();
    	c.getSearch().setFirstName('first');
    	c.getSearch().setLastName('last');
    	c.getSearch().setGeography('geo');
    	c.getSearch().setOfficeLocation('office');
    	c.getSearch().setBusinessLine('bl');
    	c.getSearch().setCountry('country');
 	    c.getSearch().setLicenseRegistration('country');
    	c.getSearch().setLicenseRegistrationCountry('country');
    	 	    
    	c.basicSearch();
    }            


    @istest  static  void test_advancedConditionsPRT_AND_PP()
    {
		rsSearchResumesController cont = new rsSearchResumesController();
		cont.setupAdvanced();
		List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
		advCond.set(0,new rsSearch.Condition('Test','e','rs_Profile_Part__c|Training_Name__c'));
		advCond.set(1,new rsSearch.Condition('Test','ne','User|LastName'));
		advCond.set(2,new rsSearch.Condition('Test','sw','PR_Team_Employee__c|Location_City__c'));
		advCond.set(3,new rsSearch.Condition('Test','dnc','rs_Profile_Part__c|Training_Name__c'));
		advCond.set(4,new rsSearch.Condition('Test','lt','rs_Profile_Part__c|Training_Name__c'));
		
		advCond.add(new rsSearch.Condition('Test','gt','rs_Profile_Part__c|Training_Name__c'));
		advCond.add(new rsSearch.Condition('Test','loe','rs_Profile_Part__c|Training_Name__c'));
		
//		advCond.add(new rsSearch.Condition('Test','BAD','rs_Profile_Part__c|Training_Name__c'));
		
		
		advCond.add(new rsSearch.Condition('Test','goe','rs_Profile_Part__c|Training_Name__c'));
		advCond.add(new rsSearch.Condition('Test','c','User|AboutMe')); // text area fields
		advCond.add(new rsSearch.Condition('Test','dnc','User|AboutMe'));
		
		cont.getSearch().setConditions(advCond);
		cont.getSearch().setFilter('1 OR 2');
		cont.basicSearch();
		
    }	
    
  
    
}