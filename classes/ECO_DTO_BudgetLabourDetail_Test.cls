@isTest
private class ECO_DTO_BudgetLabourDetail_Test {
    
    //Load test data
    @testSetup static void setupTestData() {    
        ECO_Utils_Testing.createTestDataForBudgets();
    }

    static testMethod void testConstructor() {
        
        BudgetResource__c br = [SELECT Id, BudgetHeader__c, ResourceName__c, OverrideFringeMultiplier__c, 
            OverrideFringeMultiplierField__c, OverrideOverheadMultiplier__c, OverrideOverheadMultiplierField__c
            FROM BudgetResource__c LIMIT 1];

        List<BudgetAssignment__c> baList = [SELECT Id, BudgetTask__c, BudgetResource__c, EACForecastRevenueNumber__c,
            OverrideTotalRevenue__c, EACForecastTotalCost__c, FullyBurdenedCost__c FROM BudgetAssignment__c]; 

        ECO_DTO_BudgetLabourDetail dto = new ECO_DTO_BudgetLabourDetail(br, baList);
        System.assert(dto.oBudgetResource != null);
    }

    //Test the properties
    static testMethod void testProperties() {
        
        BudgetResource__c br = [SELECT Id, BudgetHeader__c, ResourceName__c, OverrideFringeMultiplier__c, 
            OverrideFringeMultiplierField__c, OverrideOverheadMultiplier__c, OverrideOverheadMultiplierField__c,
            ResourceType__c, ColumnHeader__c, JobName__c, ExpenditureType__c, UnitType__c, UnitCost__c,
            MarkupPercentage__c, CostRate__c, OverrideRawCost__c, MarginType__c, CostCalcType__c, IsQuoted__c,
            IsEstimated__c, IsBillable__c, TotalCost__c, TotalRevenue__c, TotalQuantity__c, TotalHours__c,
            ProjectTeamMember__c, SubsAndVendors__c, IsBurdenRateRevised__c
            FROM BudgetResource__c LIMIT 1];

        List<BudgetAssignment__c> baList = [SELECT Id, BudgetTask__c, BudgetResource__c, EACForecastRevenueNumber__c,
            OverrideTotalRevenue__c, EACForecastTotalCost__c, FullyBurdenedCost__c FROM BudgetAssignment__c]; 

        ProjectTeamMember__c ptm = [SELECT Id FROM ProjectTeamMember__c LIMIT 1];
        pse__Proj__c testProject = [SELECT Id FROM pse__Proj__c LIMIT 1];

        ECO_DTO_BudgetLabourDetail dto = new ECO_DTO_BudgetLabourDetail(br, baList);
        
        System.assert(dto.resourceType == br.ResourceType__c);
        System.assert(dto.columnHeader == br.ColumnHeader__c);
        System.assert(dto.jobName == br.JobName__c);
        dto.expenditureType = 'ChristmasGift';
        System.assert(dto.expenditureType == br.ExpenditureType__c);
        dto.unitType = 'ut';
        System.assert(dto.unitType == br.UnitType__c);
        dto.unitCost = 1;
        System.assert(dto.unitCost == br.UnitCost__c);
        
        dto.markupPercentage = 2;
        System.assert(dto.markupPercentage == br.MarkupPercentage__c);
        
        System.assert(dto.costRate == dto.setScaling(br.CostRate__c));

        dto.raw = 3;
        System.assert(dto.raw == dto.setScaling(br.OverrideRawCost__c));

        Decimal d;
        d = dto.costRateField;

        dto.fringe = 4;
        System.assert(dto.fringe == br.OverrideFringeMultiplier__c);

        dto.overhead = 5;
        System.assert(dto.overhead == br.OverrideOverheadMultiplier__c);

        dto.fringeField = 6;
        System.assert(dto.fringeField == br.OverrideFringeMultiplierField__c);

        dto.overheadField = 7;
        System.assert(dto.overheadField == br.OverrideOverheadMultiplierField__c);

        //br.AppliedBillRate__c = 0;
        //br.CostRate__c = 0;
        dto.marginType = '';
        d = dto.revenueRate;

        dto.marginType = 'Amount';
        d = dto.revenueRate;
        d = dto.billRateOrMarkup;
        dto.billRateOrMarkup = 8;

        //dto.marginType = 'Percent';
        //d = dto.revenueRate;

        d = dto.billRateOrMarkup;
        dto.billRateOrMarkup = 9;

        dto.marginType = 'Multiplier';
        br.ResourceType__c = 'Labor/Person';
        d = dto.revenueRate;


        System.assert(dto.marginType == br.MarginType__c);

        dto.costCalcType = 'cct';
        System.assert(dto.costCalcType == br.CostCalcType__c);

        dto.IsQuoted = true;
        System.assert(dto.IsQuoted == br.IsQuoted__c);

        dto.IsEstimated = true;
        System.assert(dto.IsEstimated == br.IsEstimated__c);

        dto.IsBillable = true;
        System.assert(dto.IsBillable == br.IsBillable__c);


        d = br.TotalCost__c;

        d = br.TotalRevenue__c;

        d = br.TotalQuantity__c;

        d = br.TotalHours__c;

        br.ProjectTeamMember__c = ptm.Id;
        System.assert(dto.uniqueId == br.ProjectTeamMember__c);

        br.ProjectTeamMember__c = null;
        VendorSub__c vs = new VendorSub__c(Project__c = testProject.Id);
        insert vs;
        br.SubsAndVendors__c = vs.Id;
        System.assert(dto.uniqueId == br.SubsAndVendors__c);


        br.SubsAndVendors__c = null;
        br.JobName__c = 'jn';
        System.assert(dto.uniqueId == br.JobName__c);

        br.JobName__c = null;
        System.assert(dto.uniqueId == br.Id);

        // Boolean b = dto.isBurdenRateRevised;
    }
}