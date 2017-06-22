@isTest
private class ECO_DTO_BudgetHeaderWrapper_Test {
    
    @testSetup static void setupTestData() {    
        ECO_Utils_Testing.createTestDataForBudgets();
    }

    static testMethod void testConstructors() {
        
        pse__Proj__c testProject = [SELECT Id FROM pse__Proj__c LIMIT 1];       

        
        ECO_DTO_BudgetHeaderWrapper cont = new ECO_DTO_BudgetHeaderWrapper(testProject.Id);

        List<BudgetHeader__c> budgetHeaders = [SELECT 
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
                                                    (SELECT Id, RecordType.Name FROM Change_Manager__r),
                                                    (select Id, ChangeManager__r.RecordType.Name From Change_Manager_Selected_Objects__r)
                                                FROM 
                                                    BudgetHeader__c
                                                WHERE 
                                                    Project__c = :testProject.Id
                                                ORDER BY 
                                                    CreatedDate ASC];
        ECO_DTO_BudgetHeaderWrapper cont2 = new ECO_DTO_BudgetHeaderWrapper(budgetHeaders, true);
    }

    static testMethod void testProperties() {
        
        pse__Proj__c testProject = [SELECT Id FROM pse__Proj__c LIMIT 1];       

        
        ECO_DTO_BudgetHeaderWrapper cont = new ECO_DTO_BudgetHeaderWrapper(testProject.Id);

        Decimal d;

        d = cont.getOriginalTotalRawLabour;

        d = cont.getBudgetTotalRawLabour;
        
        d = cont.getForecastTotalRawLabour;
        
        d = cont.getWorkAtRiskTotalRawLabour;
        
        d = cont.getEstimateTotalRawLabour;
        
        d = cont.getChangeValueTotalRawLabour;
        
        d = cont.getOriginalTotalFBLR;

        d = cont.getBudgetTotalFBLR;
        
        d = cont.getForecastTotalFBLR;
        
        d = cont.getWorkAtRiskTotalFBLR;
        
        d = cont.getEstimateTotalFBLR;

        d = cont.getChangeValueTotalFBLR;
        
        d = cont.getOriginalTotalFringe;

        d = cont.getBudgetTotalFringe;

        d = cont.getForecastTotalFringe;

        d = cont.getWorkAtRiskTotalFringe;
        
        d = cont.getEstimateTotalFringe;

        d = cont.getChangeValueTotalFringe;
        
        d = cont.getOriginalTotalOverhead;

        d = cont.getBudgetTotalOverhead;

        d = cont.getForecastTotalOverhead;

        d = cont.getWorkAtRiskTotalOverhead;
        
        d = cont.getEstimateTotalOverhead;

        d = cont.getChangeValueTotalOverhead;
        
        d = cont.getOriginalTotalSubAmount;

        d = cont.getBudgetTotalSubAmount;

        d = cont.getForecastTotalSubAmount;

        d = cont.getWorkAtRiskTotalSubAmount;
        
        d = cont.getEstimateTotalSubAmount;

        d = cont.getChangeValueTotalSubAmount;
        
        d = cont.getOriginalTotalFeeAmount;

        d = cont.getBudgetTotalFeeAmount;

        d = cont.getForecastTotalFeeAmount;

        d = cont.getWorkAtRiskTotalFeeAmount;
        
        d = cont.getEstimateTotalFeeAmount;

        d = cont.getChangeValueTotalFeeAmount;

        d = cont.getOriginalTotalContingencyAmount;

        d = cont.getBudgetTotalContingencyAmount;

        d = cont.getForecastTotalContingencyAmount;

        d = cont.getWorkAtRiskTotalContingencyAmount;
        
        d = cont.getEstimateTotalContingencyAmount;

        d = cont.getChangeValueTotalContingencyAmount;
        
        d = cont.getOriginalTotalCost;
        
        d = cont.getBudgetTotalCost;

        d = cont.getForecastTotalCost;

        d = cont.getWorkAtRiskTotalCost;
        
        d = cont.getEstimateTotalCost;

        d = cont.getChangeValueTotalCost;
        
        d = cont.getOriginalTotalRevenue;

        d = cont.getBudgetTotalRevenue;

        d = cont.getForecastTotalRevenue;

        d = cont.getWorkAtRiskTotalRevenue;
        
        d = cont.getEstimateTotalRevenue;

        d = cont.getChangeValueTotalRevenue;
            
        d = cont.getOriginalTotalNetServiceRevenue;
     
        d = cont.getBudgetTotalNetServiceRevenue;

        d = cont.getForecastTotalNetServiceRevenue;

        d = cont.getWorkAtRiskTotalNetServiceRevenue;
        
        d = cont.getEstimateTotalNetServiceRevenue;

        d = cont.getChangeValueTotalNetServiceRevenue;
        
        d = cont.getOriginalTotalGrossMargin;

        d = cont.getBudgetTotalGrossMargin;

        d = cont.getForecastTotalGrossMargin;

        d = cont.getWorkAtRiskTotalGrossMargin;
        
        d = cont.getEstimateTotalGrossMargin;

        d = cont.getChangeValueTotalGrossMargin;
        
        d = cont.getOriginalTotalNetMargin;

        d = cont.getBudgetTotalNetMargin;

        d = cont.getForecastTotalNetMargin;

        d = cont.getWorkAtRiskTotalNetMargin;
        
        d = cont.getEstimateTotalNetMargin;

        d = cont.getChangeValueTotalNetMargin;
        
        d = cont.getOriginalTotalGMNSR;

        d = cont.getBudgetTotalGMNSR;

        d = cont.getForecastTotalGMNSR;

        d = cont.getWorkAtRiskTotalGMNSR;
        
        d = cont.getEstimateTotalGMNSR;

        d = cont.getChangeValueTotalGMNSR;

        d = cont.getOriginalTotalNMNSR;

        d = cont.getBudgetTotalNMNSR;
        
        //ToDo:       

        BudgetHeader__c testHeader = [SELECT Id, BudgetType__c, Status__c, ApprovalStatus__c, OriginalBudget__c FROM BudgetHeader__c WHERE Project__c = :testProject.Id LIMIT 1];

        cont.getReportingStatus(testHeader);
    }
}