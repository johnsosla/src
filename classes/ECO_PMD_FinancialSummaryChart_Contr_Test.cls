@isTest
private class ECO_PMD_FinancialSummaryChart_Contr_Test {
	
	// Have to leave SnapshotRefresh behind?  Batch job generator

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

	static testMethod void initWithNullConstructor(){
        Test.startTest();  
        ECO_PMD_FinancialSummaryChart_Controller cont = new ECO_PMD_FinancialSummaryChart_Controller();
        Test.stopTest();

        // nothing to test
    }
    static testMethod void initWithStdController(){
        Test.startTest();  
        pse__Proj__c testProj = [select id from pse__Proj__c LIMIT 1];
        ApexPages.StandardController std = new ApexPages.StandardController(testProj);
        ECO_PMD_FinancialSummaryChart_Controller cont = new ECO_PMD_FinancialSummaryChart_Controller(std);
        Test.stopTest();

        System.assertEquals('en-US', cont.locale);
        System.assertEquals(testProj.Id, cont.projectId);
    }

	static testMethod void test_static_ProjectSnapshot(){
		test.startTest();
		ProjectSnapshot__c seed = [select Project__c from ProjectSnapshot__c LIMIT 1];
        ECO_PMD_FinancialSummaryChart_Controller.FinancialSummaryDetails item = ECO_PMD_FinancialSummaryChart_Controller.ProjectSnapshot((String) seed.Project__c);
		test.stopTest();
		System.assert(item.financialSummaryData.size() >0 );
		System.assertEquals(null,item.financialSummaryPlanData );
	}

}