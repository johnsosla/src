@isTest
private class ECO_DTO_BudgetHeaderTest {
    @testSetup static void initData() {
        ECO_Utils_Testing.createTestDataForBudgets();
    }
    @isTest static void testClass() {
        BudgetHeader__c testHeader = [SELECT 
                                                    Id, 
                                                    BudgetName__c, 
                                                    TotalCost__c, 
                                                    TotalRevenue__c,
                                                    AppliedTotalRevenue__c, 
                                                    AppliedTotalRevenueDisplay__c,
                                                    TotalLaborHours__c,
                                                    TotalFeeAmount__c, 
                                                    TotalLaborAmount__c, 
                                                    TotalSubAmount__c, 
                                                    TotalContingencyAmount__c, 
                                                    TotalResourceAmount__c,
                                                    TotalRawCost__c,
                                                    TotalFringe__c,
                                                    TotalOverhead__c,
                                                    NetServicesRevenue__c,
                                                    GrossMargin__c,
                                                    NetMargin__c,
                                                    GMNSR__c,
                                                    NMNSR__c,
                                                    Status__c,
                                                    ApprovalStatus__c,
                                                    OriginalBudget__c,
                                                    CreatedDate,
                                                    CreatedBy.Username,
                                                    WorkAtRisk__c, 
                                                    RecordType.DeveloperName,
                                                    BudgetTaskCount__c,
                                                    TotalTopLevelWorkAtRiskRevenue__c,
                                                    Project__r.BudgetStrategy__c, Project__r.BudgetStrategyRevenue__c,
                                                    (SELECT Id, RecordType.Name FROM Change_Manager__r),
                                                    (select Id, ChangeManager__r.RecordType.Name From Change_Manager_Selected_Objects__r)
            FROM BudgetHeader__c LIMIT 1];

        Test.startTest();

        ECO_DTO_BudgetHeader dtoHeader = new ECO_DTO_BudgetHeader(testHeader);
        String s;

        s = dtoHeader.budgetName;
        System.assert(s == testHeader.BudgetName__c);

        Decimal d;

        d = dtoHeader.directPersonnelExpenses;
        d = dtoHeader.salaryCostMultiplier;
        d = dtoHeader.averageLabourRatePerHour;

        DateTime dt;
        dt = dtoHeader.createdDate;
        System.assert(dt == testHeader.CreatedDate);

        s = dtoHeader.status;

        s = dtoHeader.approvalStatus;
        System.assert(s == testHeader.ApprovalStatus__c);

        Test.stopTest();
    }
}