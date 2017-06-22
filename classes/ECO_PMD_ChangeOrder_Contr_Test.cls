@isTest
private class ECO_PMD_ChangeOrder_Contr_Test {
	
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

	static testMethod void test_static_getChangeOrderDetails(){
		test.startTest();

		BudgetHeader__c seed = [SELECT Id, Project__c FROM BudgetHeader__c LIMIT 1];
		ECO_PMD_ChangeOrder_Controller.ChangeOrderDetails item = ECO_PMD_ChangeOrder_Controller.getChangeOrderDetails((String) seed.Project__c);
		test.stopTest();
		System.assert(item.codata.size() >0 );
	}
	
}