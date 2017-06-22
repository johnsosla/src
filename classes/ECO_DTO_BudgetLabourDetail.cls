public class ECO_DTO_BudgetLabourDetail {

    public BudgetResource__c oBudgetResource {get; set;}
    
    public Map<Id, BudgetAssignment__c> mAssignmentMap {get; set;}
    
    public Map<Id, Decimal> mapRevisedForecast {get; set;}
    public Map<Id, Decimal> mapRevisedForecastCost {get; set;}
    
    public Map<Id, Decimal> mapForecastRevenue {get; set;}
    public Map<Id, Decimal> mapCostToComplete {get; set;}
    
    // Each Task will have Children. In the Wrapper class create a Map<String, Number>, where String is the combination of BudgetTaskId + BudgetResourceId
    // and this will add up the total from the Budget Assignments. 
    // In the Visualforce page will retrive the total if BudgetTask has childrean based on BudgetTaskId + BudgetResourceId
    
    public static Decimal ifNull(Decimal val) {
        return val == null ? 0 : val;
    }
    public Decimal setScaling(Decimal val) {
        return setScaling(val, 2);
    }

    public Decimal setScaling(Decimal val, Integer precision) {
        val = val == null ? 0 : val;
        val = val.setScale(precision);

        return val;
    }

    public String resourceType{
        get{return oBudgetResource.ResourceType__c;}
        private set;
    }
    
    
    public String columnHeader{
        get{return oBudgetResource.ColumnHeader__c;}
        private set;
    }
    
    public String jobName {
        get{return oBudgetResource.JobName__c;}
        set{oBudgetResource.JobName__c = value;}
    }

    public String expenditureType {
        get{return oBudgetResource.ExpenditureType__c;}
        set{oBudgetResource.ExpenditureType__c = value;}
    }
    
    public String unitType {
        get{return oBudgetResource.UnitType__c;}
        set{oBudgetResource.UnitType__c = value;}
    }

    public Decimal unitCost {
        get{return oBudgetResource.UnitCost__c;}
        set{oBudgetResource.UnitCost__c = value;}
    } 

    public Decimal markupPercentage {
        get{return oBudgetResource.MarkupPercentage__c;}
        set{oBudgetResource.MarkupPercentage__c = value;}
    }

    public Decimal costRate {
        get{return setScaling(oBudgetResource.CostRate__c);}
        private set;
    }
    
    public Decimal costRateField {
        get{return setScaling((raw == null ? 0 : raw) * ( 1 + ((fringeField == null) ? 0 : fringeField)/100 + ((overheadField == null) ? 0 : overheadField)/100));}
        private set;
    }

    public Decimal raw {
        get{
            Integer precision = resourceType == 'ODC/FEE' ? 3 : 2;
            return setScaling(oBudgetResource.OverrideRawCost__c, precision);
        }
        set{oBudgetResource.OverrideRawCost__c = value;}
    }
    
    public Decimal fringe {
        get{return oBudgetResource.OverrideFringeMultiplier__c;}
        set{oBudgetResource.OverrideFringeMultiplier__c = value;}
    }
    
    public Decimal overhead {
        get{return oBudgetResource.OverrideOverheadMultiplier__c;}
        set{oBudgetResource.OverrideOverheadMultiplier__c = value;}
    }

    public Decimal fringeField {
        get{return oBudgetResource.OverrideFringeMultiplierField__c;}
        set{oBudgetResource.OverrideFringeMultiplierField__c = value;}
    }
    
    public Decimal overheadField {
        get{return oBudgetResource.OverrideOverheadMultiplierField__c;}
        set{oBudgetResource.OverrideOverheadMultiplierField__c = value;}
    }
    
    public Decimal revenueRate {
        get {
            if(oBudgetResource.MarginType__c == 'Amount') {
                return setScaling(oBudgetResource.AppliedBillRate__c);
            } else if (oBudgetResource.MarginType__c == 'Percent') {
                return setScaling(oBudgetResource.AppliedBillRate__c + oBudgetResource.CostRate__c);
            }
            else if(oBudgetResource.MarginType__c == 'Multiplier' && resourceType == 'Labor/Person') {
                return setScaling(ifNull(raw) * ifNull(oBudgetResource.OverrideUplift__c));
            }

            return 0.0;
        }
        private set;
    }
    
    public String marginType {
        get{return oBudgetResource.MarginType__c;}
        set{oBudgetResource.MarginType__c = value;}
    }

    public String costCalcType {
        get{return oBudgetResource.CostCalcType__c;}
        set{oBudgetResource.CostCalcType__c = value;}
    }
    
    public Boolean IsQuoted {
        get{return oBudgetResource.IsQuoted__c;}
        set{oBudgetResource.IsQuoted__c = value;}
    }
    
    public Boolean IsEstimated {
        get{return oBudgetResource.IsEstimated__c;}
        set{oBudgetResource.IsEstimated__c = value;}
    }
    
    public Boolean IsBillable {
        get{return oBudgetResource.IsBillable__c;}
        set{oBudgetResource.IsBillable__c = value;}
    }
    
    public Decimal billRateOrMarkup{
        get{
            if(oBudgetResource.MarginType__c == 'Amount') {
                return setScaling(oBudgetResource.OverrideBillRate__c);
            }
            else if(oBudgetResource.MarginType__c == 'Percent' || oBudgetResource.MarginType__c == 'Multiplier') {
                return oBudgetResource.OverrideUplift__c;
            }
            
            return 0.0;
        }
        set{
            if(oBudgetResource.MarginType__c == 'Amount') {
                oBudgetResource.OverrideBillRate__c = value;
            }
            else if(oBudgetResource.MarginType__c == 'Percent' || oBudgetResource.MarginType__c == 'Multiplier') {
                oBudgetResource.OverrideUplift__c = value;
            }
        }
    }
    
    public Decimal totalCostByPerson {
        get{return oBudgetResource.TotalCost__c;}
        private set;
    }
    
    public Decimal totalRevenueByPerson {
        get{return oBudgetResource.TotalRevenue__c;}
        private set;
    }

    public Decimal totalQuantityByPerson {
        get{return oBudgetResource.TotalQuantity__c;}
        private set;
    }
    
    public Integer totalHours {
        get{return (Integer) oBudgetResource.TotalHours__c;}
        private set;
    }

    public String uniqueId {
        get {
            if(oBudgetResource.ProjectTeamMember__c != null) { return oBudgetResource.ProjectTeamMember__c; }
            else if(oBudgetResource.SubsAndVendors__c != null) { return oBudgetResource.SubsAndVendors__c; }
            else if(oBudgetResource.JobName__c != null) { return oBudgetResource.JobName__c; }

            return oBudgetResource.Id;
        }
        private set;
    }

    public Boolean isBurdenRateRevised {
        get {
            return oBudgetResource.IsBurdenRateRevised__c;
        }
        private set;
    }

    public ECO_DTO_BudgetLabourDetail(BudgetResource__c o_budgetResource, List<BudgetAssignment__c> budgetAssignments) {
    	System.debug('ECO_DTO_BudgetLabourDetail Constructor BEGIN');

        oBudgetResource = o_budgetResource;
        oBudgetResource.OverrideFringeMultiplier__c = setScaling(o_budgetResource.OverrideFringeMultiplier__c);
        oBudgetResource.OverrideFringeMultiplierField__c = setScaling(o_budgetResource.OverrideFringeMultiplierField__c);  
        oBudgetResource.OverrideOverheadMultiplier__c = setScaling(o_budgetResource.OverrideOverheadMultiplier__c);
        oBudgetResource.OverrideOverheadMultiplierField__c = setScaling(o_budgetResource.OverrideOverheadMultiplierField__c);  
        
        mAssignmentMap = new Map<Id, BudgetAssignment__c>();
        mapForecastRevenue = new Map<Id, Decimal>();
        mapCostToComplete = new Map<Id, Decimal>();
        
        for(BudgetAssignment__c budgetAssignment: budgetAssignments) {
            Decimal EACForecastRevenue = budgetAssignment.EACForecastRevenueNumber__c == null ? 0.0 : budgetAssignment.EACForecastRevenueNumber__c;
            Decimal OverrideTotalRevenue = budgetAssignment.OverrideTotalRevenue__c == null ? 0.0 : budgetAssignment.OverrideTotalRevenue__c;
            Decimal EACForecastCost = budgetAssignment.EACForecastTotalCost__c == null ? 0.0 : budgetAssignment.EACForecastTotalCost__c;
            Decimal TotalCost = budgetAssignment.FullyBurdenedCost__c == null ? 0.0 : budgetAssignment.FullyBurdenedCost__c;
            
            mAssignmentMap.put(budgetAssignment.BudgetTask__c, budgetAssignment);
            mapForecastRevenue.put(budgetAssignment.BudgetTask__c, EACForecastRevenue + OverrideTotalRevenue);
            mapCostToComplete.put(budgetAssignment.BudgetTask__c, EACForecastCost + TotalCost);
        }
        System.debug('ECO_DTO_BudgetLabourDetail Constructor END');
    }
    
}