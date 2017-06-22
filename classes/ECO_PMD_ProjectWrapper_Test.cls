@isTest
private class ECO_PMD_ProjectWrapper_Test {
	
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



	static testMethod void test_static_ProjectSnapshot(){
		test.startTest();
		WeeklyRollupEntry__c seed = [select id, Project__c from WeeklyRollupEntry__c LIMIT 1];
		Id projectId = seed.Project__c;
        pse__Proj__c project = [select id from pse__Proj__c where id = :projectId];
		ECO_PMD_ProjectWrapper item = new ECO_PMD_ProjectWrapper(project);
		test.stopTest();
		System.assertNotEquals('',item.getChartJSONEV() );
		System.assertNotEquals('',item.getChartJSONCPISPI() );
	}

}