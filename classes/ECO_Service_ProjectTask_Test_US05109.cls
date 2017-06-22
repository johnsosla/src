// DEPRECATED -- TO BE DELETED -- Jake White, 13-Sep-2016
@isTest private class ECO_Service_ProjectTask_Test_US05109{}
/*
* @isTest(SeeAllData=true)
* /** ---------------------------------------------------------------------------------------
* * @Description Acceptance Test of US-05109
* * Uses known data (as of 11-Aug-2016 in EPMDEV) to validate correct performance of revised
* * ECO_Service_ProjectTask per US-05109
* *
* * @Author AECOM - Jake White
* * @Date 11-Aug-2016
* *----------------------------------------------------------------------------------------* /
* private class ECO_Service_ProjectTask_Test_US05109 {
* 	
* 	/** ---------------------------------------------------------------------------------------
* 	* @Description Acceptance Test of US-05109
* 	* Uses known data (as of 11-Aug-2016 in EPMDEV) to validate correct performance of revised
* 	* ECO_Service_ProjectTask per US-05109
* 	*
* 	* @Author AECOM - Jake White
* 	* @Date 11-Aug-2016
* 	*----------------------------------------------------------------------------------------* /
* 	@isTest(SeeAllData=true)
* 	static void SummarizeProjectTasksForSeveralDates() {
* 		Test.startTest();
* 		Id projectId = 'a32a0000000kCb6AAE';
* 
* 		// a32a0000000kCb6AAE -- has commits for 12/11, 6/3, 6/10
* 		
* 		List<Date> asOfs = new List<Date>{ 
* 			Date.newInstance(2015,12,10),
* 			Date.newInstance(2015,12,11),
* 			Date.newInstance(2015,12,12),
* 			Date.newInstance(2016, 6, 3),
* 			Date.newInstance(2016, 6, 5),
* 			Date.newInstance(2016, 6,10)};
* 		/*
* 		 *                      %Comp   AppvCost   EV    x Cost  eac1     eac2
* 		 * 12/11/2015	Task 1	 50%	X	7,400.37	=	3,700	 	3,520	17,350	12,375
* 		 * 06/03/2016	Task 1	115%	X	7,400.37	=	8,510	 	8,133	 7,544	 7,565
* 		 * 06/10/2016	Task 1	100%	X	7,400.37	=	7,400	 	8,133	 8,675	 8,675
* 		 * /
* 
* 		Map<id, pse__Project_Task__c> projectTasks = new Map<id, pse__Project_Task__c>([SELECT ID FROM pse__Project_Task__c WHERE pse__Project__c = :projectId]);
* 		Set<Id> projectTaskIds = new Set<Id>();
* 		projectTaskIds.addAll(projectTasks.keyset());
*         
* 		for(Date asOf : asOfs){
* 			ECO_Service_ProjectTask svc = new ECO_Service_ProjectTask(projectTaskIds,asOf);
* 			
* 			List<pse__Project_Task__c> processedTasks = svc.summerizeProjectTasks();
* 			System.debug('============ AsOf ' + svc.AsOfDate);
* 			for(pse__Project_Task__c pt : processedTasks ) {
* 				
* 				System.debug(System.LoggingLevel.Fine,'============ task ' + pt.ID);
* 				System.debug(System.LoggingLevel.Fine,'RevenueBudgetOriginal__c=' + pt.RevenueBudgetOriginal__c);
* 				System.debug(System.LoggingLevel.Fine,'CostBudgetOriginal__c = ' + pt.CostBudgetOriginal__c);
* 				System.debug(System.LoggingLevel.Fine,'RevenueBudgetCurrent__c=' + pt.RevenueBudgetCurrent__c);
* 				System.debug(System.LoggingLevel.Fine,'TotalApprovedCost__c=' + pt.TotalApprovedCost__c);
* 				System.debug(System.LoggingLevel.Fine,'CostMTD__c='+pt.CostMTD__c);
* 				System.debug(System.LoggingLevel.Fine,'CostPrevMTD__c='+pt.CostPrevMTD__c);
* 				System.debug(System.LoggingLevel.Fine,'CostForecast__c='+pt.CostForecast__c);
* 				System.debug(System.LoggingLevel.Fine,'TotalForecastCostPrevME__c='+pt.TotalForecastCostPrevME__c);
* 				System.debug(System.LoggingLevel.Fine,'TotalActualCost__c='+pt.TotalActualCost__c);
* 				System.debug(System.LoggingLevel.Fine,'CostITD3FiscalMonthEndsAgo__c='+pt.CostITD3FiscalMonthEndsAgo__c);
* 				System.debug(System.LoggingLevel.Fine,'EarnedValue__c='+pt.EarnedValue__c);
* 				System.debug(System.LoggingLevel.Fine,'PlannedCost__c='+pt.PlannedCost__c);
* 				System.debug(System.LoggingLevel.Fine,'PlannedValue__c='+pt.PlannedValue__c);
* 				
* 				if (pt.id == 'a3Ea00000019WCTEA2') {
* 					if (asOf == asOfs[0]) {AssertExpectedResultForUS5109(pt,asOf, 7400.37, 7400.37, 0, 0, null, 0);} // 12/10
* 					if (asOf == asOfs[1]) {AssertExpectedResultForUS5109(pt,asOf, 7400.37, 7400.37, 0, 0, 3700, 0);} // 12/11
* 					if (asOf == asOfs[2]) {AssertExpectedResultForUS5109(pt,asOf, 7400.37, 7400.37, 0, 0, 3700, 0);} // 12/12
* 					if (asOf == asOfs[4]) {AssertExpectedResultForUS5109(pt,asOf, 7400.37, 7400.37, 0, 0, 8510, 0);} // 6/5
* 					if (asOf == asOfs[5]) {AssertExpectedResultForUS5109(pt,asOf, 7400.37, 7400.37, 0, 0, 7400, 0);} // 6/10
* 			 	}
* 			 	if (pt.id == 'a3Ea00000019WCQEA2') {
* 					if (asOf == asOfs[0]) {AssertExpectedResultForUS5109(pt,asOf, 0, 0, 264.16, 1825.99, null, 2090.15);} // costs resolution is whole-week, so 12/11 costs hit 12/10 asOf
* 					if (asOf == asOfs[1]) {AssertExpectedResultForUS5109(pt,asOf, 0, 0, 264.16, 1825.99, 0, 2090.15);}
* 					if (asOf == asOfs[2]) {AssertExpectedResultForUS5109(pt,asOf, 0, 0, 264.16, 1825.99, 0, 2090.15);}
* 					if (asOf == asOfs[4]) {AssertExpectedResultForUS5109(pt,asOf, 0, 0,      0,  361.47, 0, 5623.81);}
* 					if (asOf == asOfs[5]) {AssertExpectedResultForUS5109(pt,asOf, 0, 0,      0,  361.47, 0, 5623.81);}
* 			 	}
* 			}
* 		}
* 		Test.stopTest();
* 	}
* 
* 	static void AssertExpectedResultForUS5109(
* 		  pse__Project_Task__c pt
* 		, Date asOfDate
* 		, Decimal CostBudgetOriginal
* 		, Decimal TotalApprovedCost
* 		, Decimal CostMTD
* 		, Decimal CostPrevMTD
* 		, Decimal EarnedValue
* 		, Decimal TotalActualCost
* 		){
* 		System.assertEquals( CostBudgetOriginal, pt.CostBudgetOriginal__c);
* 		System.assertEquals( TotalApprovedCost, pt.TotalApprovedCost__c);
* 		System.assertEquals( CostMTD, pt.CostMTD__c);
* 		System.assertEquals( CostPrevMTD, pt.CostPrevMTD__c);
* 		System.assertEquals( EarnedValue, pt.EarnedValue__c);
* 		System.assertEquals( TotalActualCost, pt.TotalActualCost__c);
* 	}
* }
*/