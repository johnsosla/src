@isTest
private class ECO_PMD_RunRateETCChart_Contr_Test {

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
        ECO_Service_ProjectSnapshots ps = new ECO_Service_ProjectSnapshots();
        //ps.computeSnapshots(Date.today(), projects);
        ps.computeSnapshots(Date.newInstance(2015,12,15), projects, ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END);
        System.debug('____ps.projectSnapshots.values()'+ps.projectSnapshots.values());
        upsert ps.projectSnapshots.values() Snapshot_Project_Key__c;
        System.debug('____ps.projectSnapshots.values().size()='+ps.projectSnapshots.values().size());
	}

	static testMethod void test_static_ProjectSnapshot(){
		test.startTest();
		ProjectSnapshot__c seed = [select Project__c from ProjectSnapshot__c LIMIT 1];
        ECO_PMD_RunRateETCChart_Controller.RunRateDetails item = ECO_PMD_RunRateETCChart_Controller.ProjectSnapshot(seed.Project__c);
		test.stopTest();
		System.assert(item.runRateData.size() >0 );
	}
}