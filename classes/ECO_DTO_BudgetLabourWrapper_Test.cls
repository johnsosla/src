@isTest
private class ECO_DTO_BudgetLabourWrapper_Test {
    
    @testSetup static void setupTestData() {    
        ECO_Utils_Testing.createTestDataForBudgets();
    }

    static testMethod void testConstructors() {
        
        BudgetHeader__c budgetHeader = [SELECT Id From BudgetHeader__c LIMIT 1];
        List<BudgetResource__c> brList = [SELECT Id, BudgetHeader__c, ResourceName__c, OverrideFringeMultiplier__c, 
            OverrideFringeMultiplierField__c, OverrideOverheadMultiplier__c, OverrideOverheadMultiplierField__c,
            ResourceType__c, ColumnHeader__c, JobName__c, ExpenditureType__c, UnitType__c, UnitCost__c,
            MarkupPercentage__c, CostRate__c, OverrideRawCost__c, MarginType__c, CostCalcType__c, IsQuoted__c,
            IsEstimated__c, IsBillable__c, TotalCost__c, TotalRevenue__c, TotalQuantity__c, TotalHours__c,
            ProjectTeamMember__c, SubsAndVendors__c, IsBurdenRateRevised__c
            FROM BudgetResource__c WHERE BudgetHeader__c = :budgetHeader.Id];
        

        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(brList);
        ECO_DTO_BudgetLabourWrapper cont = new ECO_DTO_BudgetLabourWrapper(ssc, budgetHeader.Id, brList[0].ResourceType__c);
        System.assertEquals(budgetHeader.Id, cont.budgetHeaderId);
    }
}