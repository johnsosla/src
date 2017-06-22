@isTest
/** ------------------------------------------------------------------------------------------------------
 * @Description The test class for all the ECO_Mapper_ProjectTask class, to get coverage on the code that will be 
 *              running in production and gets the data from a DB record, not a JSON string
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        September 2016
 *-----------------------------------------------------------------------------------------------------*/
private class ECO_Mapper_ProjectTaskTest {

        /*
    Given:
        a unsaved project task
    When:
        the constructor is instanciated
    Then:
        data is set in mapper record as expected
        NOTE - not all fields are setable via the db, aka rollup summary or formula fields
    */
    private static testMethod void projectTaskTest() {
        pse__Project_Task__c testRecord = new pse__Project_Task__c(Id = 'a3Ea00000019WCPEA2');
        testRecord.Name = 'testing';
        testRecord.pse__Project__c = 'a32a0000000kCqxAAE';              
        testRecord.ProjectTaskNumber__c = 'testing';
        testRecord.MetricsDate__c = Date.newInstance(2016, 8, 24);
        testRecord.RevenueBudgetOriginal__c = 10.0;
        testRecord.RevenueBudgetCurrent__c = 20.0;
        testRecord.CostBudgetOriginal__c = 30.0;
        testRecord.CostPrevMTD__c = 40.0;
        testRecord.CostMTD__c = 50.0;
        testRecord.TotalEstimateCost__c = 60.0;
        testRecord.TotalApprovedCost__c = 70.0;
        testRecord.TotalForecastCostPrevME__c = 80.0;
        testRecord.EarnedValue__c = 90.0;
        //testRecord.CPI__c = 10.0;
        //testRecord.SPI__c = 20.0;
        testRecord.MonthEndDate3FiscalMonthsAgo__c = Date.newInstance(2016, 8, 30);
        testRecord.CostITD3FiscalMonthEndsAgo__c = 40.0;
        testRecord.EndDateFiscalMonth__c = '50.0';
        testRecord.EndDatePreviousFiscalMonth__c = '60.0';
        testRecord.TotalActualCost__c = 70.0;
        testRecord.PlannedCost__c = 80.0;
        testRecord.PlannedValue__c = 90.0;
        testRecord.pse__Parent_Task__c = 'a3Ea00000019WCPEA2';
        testRecord.PercentComplete__c = 10.0;
        //testRecord.TotalHours__c;
        testRecord.PMD_TotalHours__c = 20.0;
        //testRecord.NetMarginBudgetCurrent__c = 30.0;
        //testRecord.NetMarginBudgetOriginal__c = 40.0;
        testRecord.PMD_RevenueBudgetOriginal__c = 50.0;
        testRecord.PMD_CostBudgetOriginal__c = 60.0;
        testRecord.PMD_RevenueBudgetCurrent__c = 70.0;
        testRecord.PMD_TotalApprovedCost__c = 80.0;
        testRecord.PMD_TotalEstimateCost__c = 90.0;
        testRecord.PMD_CostPrevMTD__c = 10.0;
        testRecord.PMD_TotalForecastCostPrevME__c = 20.0;
        testRecord.PMD_CostMTD__c = 30.0;
        testRecord.PMD_TotalActualCost__c = 40.0;
        testRecord.PMD_EarnedValue__c = 60.0;
        testRecord.PMD_PlannedCost__c = 70.0;
        testRecord.PMD_CostITD3FiscalMonthEndsAgo__c = 80.0;
        testRecord.PMD_NetMarginBudgetOriginal__c = 80.0;
        testRecord.PMD_NetMarginBudgetCurrent__c = 10.0;
        testRecord.PMD_PlannedValue__c = 20.0;
        testRecord.IsWorkPlanTask__c = false;
        //testRecord.pse__Start_Date__c = Date.newInstance(2015, 8, 25);
        //testRecord.pse__End_Date__c = Date.newInstance(2016, 8, 30);
        testRecord.ForecastStartDate__c = Date.newInstance(2015, 8, 30);
        testRecord.ForecastEndDate__c = Date.newInstance(2016, 8, 30);

        ECO_Mapper_ProjectTask dbRecord;
        Test.startTest();
        try {
            dbRecord = new ECO_Mapper_ProjectTask(testRecord);              
        } catch (Exception e){
            System.assert(False, '*****>Error in projectTaskTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
        Test.stopTest();

        //test a couple of values to ensure it's working ok
        System.assertEquals( 'a3Ea00000019WCPEA2', dbRecord.id, '*****Error in projectTaskTest: id should be "a3Ea00000019WCPEA2"');
        System.assertEquals( 'testing', dbRecord.name, '*****Error in projectTaskTest: name should be "testing"');
        System.assertEquals( 'a32a0000000kCqxAAE', dbRecord.projectId, '*****Error in projectTaskTest: projectId should be "a32a0000000kCqxAAE"');
        System.assertEquals( 'a3Ea00000019WCPEA2', dbRecord.parentTaskId, '*****Error in projectTaskTest: parentTaskId should be "a3Ea00000019WCPEA2"');
        System.assertEquals( false, dbRecord.isWorkPlanTask, '*****Error in projectTaskTest: isWorkPlanTask should be false');
        
    }

    /*
    Given:
        a JSON string representing a project task record
    When:
        the constructor is instanciated
    Then:
        data is set in mapper record as expected
    */
    private static testMethod void projectTaskJsonStringTest() {
        String jsonMockData = '{"attributes":{"type":"pse__Project_Task__c","url":"/services/data/v38.0/sobjects/pse__Project_Task__c/a3Ea00000019WCPEA2"},"PMD_CostBudgetOriginal__c":987,"PMD_RevenueBudgetCurrent__c":876,';
            jsonMockData += '"Id":"a3Ea00000019WCPEA2","pse__Project__c":"a32a0000000kCb6AAE","MetricsDate__c":"2016-09-12","RevenueBudgetOriginal__c":0.00,"RevenueBudgetCurrent__c":0.00,"CostBudgetOriginal__c":0.00,"CostPrevMTD__c":0.00,';
            jsonMockData += '"CostAccruals__c":101.01,"TotalHours__c":202.02,"CostMTD__c":0.00,"NetMarginBudgetCurrent__c":303.03,"NetMarginBudgetOriginal__c":404.04,';
            jsonMockData += '"EarnedValue__c":0.00,"CPI__c":1.00,"MonthEndDate3FiscalMonthsAgo__c":"2016-07-01","CostITD3FiscalMonthEndsAgo__c":948.39,"CurrencyIsoCode":"NZD",';
            jsonMockData += '"SPI__c":90,"PMD_CPI__c":30,"PMD_SPI__c":40,"pse__Start_Date__c":"2016-09-16","pse__End_Date__c":"2016-06-17","PlannedCost__c":909,"PMD_RevenueBudgetOriginal__c":404,';
            jsonMockData += '"PMD_CostAccruals__c":707.07,"ForecastStartDate__c":"2016-09-09","ForecastEndDate__c":"2016-12-30","CostITD3FiscalMonthEndsAgo__c":808,"stepOverTest":"getting stepOver coverage"}';

        ECO_Mapper_ProjectTask dbRecord;
        Test.startTest();
        try {
            dbRecord = new ECO_Mapper_ProjectTask(jsonMockData);                
        } catch (Exception e){
            System.assert(False, '*****>Error in projectTaskJsonStringTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
        Test.stopTest();

        //test a couple of values to ensure it's working ok
        System.assertEquals( 'a3Ea00000019WCPEA2', dbRecord.id, '*****Error in projectTaskJsonStringTest: id should be "a3Ea00000019WCPEA2"');
        System.assertEquals( Date.newInstance(2016, 09, 12), dbRecord.metricsDate, '*****Error in projectTaskJsonStringTest: metricsDate should be "9/12/2016"');
        
    }

    /*
    Given:
        
    When:
        the empty constructor is instanciated
    Then:
        an empty ECO_Mapper_ProjectTask object is returned
    */
    private static testMethod void projectTaskEmptyConstructorTest() {
        ECO_Mapper_ProjectTask dbRecord;
        
        Test.startTest();
        try {
            dbRecord = new ECO_Mapper_ProjectTask();                
        } catch (Exception e){
            System.assert(False, '*****>Error in projectTaskEmptyConstructorTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
        Test.stopTest();

        //test a couple of values to ensure it's working ok
        System.assert( dbRecord != null, '*****Error in projectTaskEmptyConstructorTest: return object should not be null');        
    }

    /*
    Given:
        a unsaved project task
        the constructor is instanciated
    When:
        call unmapToSOject method to convert the mapped record back to a pse__Project_Task__c object
    Then:
        data is set in pse__Project_Task__c record as expected
    */
    private static testMethod void projectTaskUnmapTest() {
        pse__Project_Task__c testRecord = new pse__Project_Task__c(Id = 'a3Ea00000019WCPEA2');
        testRecord.Name = 'testing';
        testRecord.pse__Project__c = 'a32a0000000kCqxAAE';              
        testRecord.ProjectTaskNumber__c = 'testing';
        testRecord.MetricsDate__c = Date.newInstance(2016, 8, 24);
        testRecord.RevenueBudgetOriginal__c = 10.0;
        testRecord.RevenueBudgetCurrent__c = 20.0;
        testRecord.CostBudgetOriginal__c = 30.0;
        testRecord.CostPrevMTD__c = 40.0;
        testRecord.CostMTD__c = 50.0;
        testRecord.TotalEstimateCost__c = 60.0;
        testRecord.TotalApprovedCost__c = 70.0;
        testRecord.TotalForecastCostPrevME__c = 80.0;
        testRecord.EarnedValue__c = 90.0;
        testRecord.MonthEndDate3FiscalMonthsAgo__c = Date.newInstance(2016, 8, 30);
        testRecord.CostITD3FiscalMonthEndsAgo__c = 40.0;
        testRecord.EndDateFiscalMonth__c = '50.0';
        testRecord.EndDatePreviousFiscalMonth__c = '60.0';
        testRecord.TotalActualCost__c = 70.0;
        testRecord.PlannedCost__c = 80.0;
        testRecord.PlannedValue__c = 90.0;
        testRecord.pse__Parent_Task__c = 'a3Ea00000019WCPEA2';
        testRecord.PercentComplete__c = 10.0;
        testRecord.PMD_TotalHours__c = 20.0;
        testRecord.PMD_RevenueBudgetOriginal__c = 50.0;
        testRecord.PMD_CostBudgetOriginal__c = 60.0;
        testRecord.PMD_RevenueBudgetCurrent__c = 70.0;
        testRecord.PMD_TotalApprovedCost__c = 80.0;
        testRecord.PMD_TotalEstimateCost__c = 90.0;
        testRecord.PMD_CostPrevMTD__c = 10.0;
        testRecord.PMD_TotalForecastCostPrevME__c = 20.0;
        testRecord.PMD_CostMTD__c = 30.0;
        testRecord.PMD_TotalActualCost__c = 40.0;
        testRecord.PMD_EarnedValue__c = 60.0;
        testRecord.PMD_PlannedCost__c = 70.0;
        testRecord.PMD_CostITD3FiscalMonthEndsAgo__c = 80.0;
        testRecord.PMD_NetMarginBudgetOriginal__c = 80.0;
        testRecord.PMD_NetMarginBudgetCurrent__c = 10.0;
        testRecord.PMD_PlannedValue__c = 20.0;
        testRecord.IsWorkPlanTask__c = false;
        //testRecord.pse__Start_Date__c = Date.newInstance(2015, 8, 25);
        //testRecord.pse__End_Date__c = Date.newInstance(2016, 8, 30);
        testRecord.ForecastStartDate__c = Date.newInstance(2015, 8, 30);
        testRecord.ForecastEndDate__c = Date.newInstance(2016, 8, 30);

        ECO_Mapper_ProjectTask dbRecord;
        dbRecord = new ECO_Mapper_ProjectTask(testRecord);
        pse__Project_Task__c returnRecord;

        Test.startTest();
            returnRecord = dbRecord.unmapToSOject( new List<String>{'Id', 'Name', 'pse__Project__c'});
        try {
        } catch (Exception e){
            System.assert(False, '*****>Error in projectTaskUnmapTest: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
        Test.stopTest();

        //test a couple of values to ensure it's working ok
        System.assertEquals( 'a3Ea00000019WCPEA2', returnRecord.Id, '*****Error in projectTaskUnmapTest: Id should be "a3Ea00000019WCPEA2"');
        System.assertEquals( 'testing', returnRecord.name, '*****Error in projectTaskUnmapTest: Name should be "testing"');
        System.assertEquals( 'a32a0000000kCqxAAE', returnRecord.pse__Project__c, '*****Error in projectTaskUnmapTest: pse__Project__c should be "a32a0000000kCqxAAE"');
        //ensure that the other fields are not in the object
        Map<String, Object> fieldsInRecord = returnRecord.getPopulatedFieldsAsMap();
        System.assert( !fieldsInRecord.containsKey('PMD_PlannedValue__c'), '*****Error in projectTaskUnmapTest: PMD_PlannedValue__c should not be populated');
        System.assert( !fieldsInRecord.containsKey('TotalActualCost__c'), '*****Error in projectTaskUnmapTest: TotalActualCost__c should not be populated');
        
    }
}