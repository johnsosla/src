@isTest
private class ECO_PMD_Helpers_Test {
	@TestSetup static void testSetup(){
		ECO_PMD_Utils_Testing.setupTestData();

		List<pse__Proj__c> projects = [
			SELECT Id, Name,
				CurrencyIsoCode,RecordTypeId,pse__Account__c,
	            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
	            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
	            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
	            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c
        ];
        System.debug('___projects='+projects);
	}
	
	static testMethod void test_static_sortProjecTasks(){
		Test.startTest();  
        
        //Get a project that has tasks
        pse__Project_Task__c seed = [select id, pse__Project__c FROM pse__Project_Task__c LIMIT 1];
        Id projectId = seed.pse__Project__c;
        
        List<pse__Project_Task__c> evs = [select id
        	,pse__Hierarchy_Depth__c, pse__Parent_Task__r.Id, pse__Project__c 
        	FROM pse__Project_Task__c
        	WHERE pse__Project__c = :projectId];

		List<pse__Project_Task__c> ordered_evs = ECO_PMD_Helpers.sortProjecTasks(evs);
		
		System.AssertEquals(evs.size(),ordered_Evs.size());
    }

    static testMethod void test_static_getFiscal(){
    	// ECO_PMD_Helpers.getFiscal IS NOT USED IN THE LIVE SYSTEM - REMOVE IT AT FIRST CHANCE IT"S BAD
    	System.AssertEquals('FY201411', ECO_PMD_Helpers.getFiscal(Date.newInstance(2014, 10, 15)));
    	System.AssertEquals('FY201510', ECO_PMD_Helpers.getFiscal(Date.newInstance(2015, 9, 15)));
    }

    static testMethod void test_static_validDecimal(){
    	System.AssertEquals(0,ECO_PMD_Helpers.validDecimal((Decimal) null));
        System.AssertEquals(1.23d,ECO_PMD_Helpers.validDecimal(1.23d));
    }
}