@isTest //(seeAllData=True)
private class ECO_Service_ProjectTaskSnapshots_Test {

	@TestSetup static void testSetup(){
		System.debug('Limits 0='+Limits.getLimitQueries());
		ECO_PMD_Utils_Testing.setupTestData();
		System.debug('Limits 1='+Limits.getLimitQueries());
	}

	/*
	@isTest static void test_testDisplayWithDataFromUatDpl() {
		Test.startTest();  
    	ECO_Service_ProjectTaskSnapshots.testDisplay();
		Test.stopTest();
	}
	*/
	
 	@isTest static void test_testDisplayWithDataFromResources(){
 		Test.startTest();
 		System.Debug(Limits.getLimitQueries());
 		pse__Project_Task__c task = [
			SELECT ID, pse__Project__c
			FROM pse__Project_Task__c LIMIT 1
		];
		Id projectId = task.pse__Project__c;

        ECO_Service_ProjectTaskSnapshots svc = new ECO_Service_ProjectTaskSnapshots();
        List<Id> projectIds = new List<Id>{projectId};
        
        svc.computeSnapshots(projectIds, Date.newInstance(2016, 4, 1));
        
        svc.displayResults();
        Test.stopTest();
    }

    
	@isTest static void test_Class_AgingMetrics() {
		Test.startTest();
		ECO_Service_ProjectTaskSnapshots.AgingMetrics item = new ECO_Service_ProjectTaskSnapshots.AgingMetrics();
		Date dayZero = Date.today(); //Date.newInstance(2015, 1, 1);
		
		item.accumulate(0.4d, dayZero.addDays(1));
		item.accumulate(0.2d, dayZero.addDays(0));
		item.accumulate(0.1d, dayZero.addDays(-1));
		item.accumulate(29.0d, dayZero.addDays(-29));
		item.accumulate(30.0d, dayZero.addDays(-30));
		item.accumulate(31.0d, dayZero.addDays(-31));
		item.accumulate(59.0d, dayZero.addDays(-59));
		item.accumulate(60.0d, dayZero.addDays(-60));
		item.accumulate(61.0d, dayZero.addDays(-61));
		item.accumulate(89.0d, dayZero.addDays(-89));
		item.accumulate(90.0d, dayZero.addDays(-90));
		item.accumulate(91.0d, dayZero.addDays(-91));
		item.accumulate(179.0d, dayZero.addDays(-179));
		item.accumulate(180.0d, dayZero.addDays(-180));
		item.accumulate(181.0d, dayZero.addDays(-181));
		Test.stopTest();

		System.AssertEquals(item.Amount_0_30, 0.2d+0.1d+29.0d+30.0d);
		System.AssertEquals(item.Amount_31_60, 31.0d+59.0d+60.0d);
		System.AssertEquals(item.Amount_61_90, 61.0d+89.0d+90.0d);
		System.AssertEquals(item.Amount_91_180, 91.0d+179.0d+180.0d);
		System.AssertEquals(item.Amount_181_plus, 181.0d);
		//System.AssertEquals(item.Amount_Future, 0.4d);
		System.AssertEquals(item.Amount_0_plus, 0.2d+0.1d+29.0d+30.0d + 31.0d+59.0d+60.0d + 61.0d+89.0d+90.0d + 91.0d+179.0d+180.0d + 181.0d);
		System.AssertEquals(item.Amount_0_60, 0.2d+0.1d+29.0d+30.0d + 31.0d+59.0d+60.0d );
		System.AssertEquals(item.Amount_61_plus, 61.0d+89.0d+90.0d + 91.0d+179.0d+180.0d + 181.0d);
		System.AssertEquals(item.Amount_91_plus, 91.0d+179.0d+180.0d + 181.0d);
	}

	@isTest static void test_class_EarnedValueMetrics(){
		Test.startTest();
		ECO_Service_ProjectTaskSnapshots.EarnedValueMetrics item = 
			new ECO_Service_ProjectTaskSnapshots.EarnedValueMetrics();
	    item.DateEVCommitted = Date.today();
	    Test.stopTest();
	    System.assertEquals(item.DateEVCommitted, Date.today());
	    
	    item.EarnedValue = 100.0d;
	    item.PercentComplete = 100.0d;
	    system.assertEquals(item.CPI,0.0d);
	    system.assertEquals(item.SPI,0.0d);
	    
	    item.ActualCost = 2.0d;
	    item.Plannedvalue = 4.0d;
	    system.assertEquals(item.CPI,50.0d);
	    system.assertEquals(item.SPI,25.0d);
	}

	@isTest static void test_Class_SnapshotDates(){
		Test.startTest();
		ECO_Service_ProjectTaskSnapshots.SnapshotDates item = 
			new ECO_Service_ProjectTaskSnapshots.SnapshotDates(Date.newInstance(2016, 2, 15), Date.newInstance(2016, 1, 15), 
				Date.newInstance(2016, 3, 15));
		pse__Time_Period__c tp = item.getMonth(Date.newInstance(2015, 9, 15));
		String etp = item.estimatedFiscalMonth(Date.newInstance(2017, 9, 15));
		Test.stopTest();

		system.assertEquals('FY2015-12', tp.TimePeriodCode__c);
		system.assertEquals('FY2017-12', etp);
	}

	@isTest static void test_static_getISO8601StringFromDate(){
		Test.startTest();
		String datestr = ECO_Service_ProjectTaskSnapshots.getISO8601StringFromDate(Date.newInstance(2015, 9, 25));
		Test.stopTest();
		System.AssertEquals(datestr,'2015-09-25');
	}

	@isTest static void test_static_getDateFromISO8601String(){
		Test.startTest();
		String datestr = '2015-09-25';
		Date dateval = ECO_Service_ProjectTaskSnapshots.getDateFromISO8601String(datestr);
		Test.stopTest();
		System.AssertEquals(dateval, Date.newInstance(2015, 9, 25));
	}

	@isTest static void test_static_getFiscalMonthsBetween(){
		Test.startTest();
		Integer months = ECO_Service_ProjectTaskSnapshots.getFiscalMonthsBetween('FY2015-01', 'FY2016-06');
		Test.stopTest();
		System.assertEquals(months, 17);
	}

	@isTest static void test_static_dumpPT(){
		Test.startTest();
		System.Debug(Limits.getLimitQueries());
		pse__Project_Task__c task = [
			SELECT ID
			,ProjectTaskNumber__c, MetricsDate__c,RevenueBudgetOriginal__c, RevenueBudgetCurrent__c, TotalApprovedCost__c, CostBudgetOriginal__c
			,CostMTD__c, CostPrevMTD__c, CostForecast__c, TotalForecastCostPrevME__c, TotalActualCost__c, MonthEndDate3FiscalMonthsAgo__c
			,CostITD3FiscalMonthEndsAgo__c, EarnedValue__c, PlannedCost__c, PlannedValue__c 
			FROM pse__Project_Task__c LIMIT 1
		];
		ECO_Service_ProjectTaskSnapshots.dumpPT(task);
		test.stopTest();
	}

	// private loadValuesFromSnapshot
	// private loadProjectTasks

	@isTest static void test_prepareSnapshotsForDisplay(){	

		Test.startTest();
		System.Debug(Limits.getLimitQueries());

		pse__Project_Task__c task = [
			SELECT ID, pse__Project__c
			FROM pse__Project_Task__c LIMIT 1
		];
		Id projectId = task.pse__Project__c;

		ECO_Service_ProjectTaskSnapshots item = new ECO_Service_ProjectTaskSnapshots();
	    item.prepareSnapshotsForDisplay(projectId,Date.today());
	    Test.stopTest();
		System.assert(item.getUpdateableTasks().size()>0);
		System.assert(item.getDisplayTasks().size()>0);
	}
}