public class ECO_DTO_BudgetTask {
    public transient BudgetTask__c obudgetTask {get; set;}
    public Id budgetTaskId { get; set; }
    public Id id {
        get{return obudgetTask.ProjectTask__c;}
        private set;
    }
    private Id pParentTaskId;
    public Id parentTaskId {
        get { 
            if(obudgetTask != null) pParentTaskId = obudgetTask.ProjectTask__r.pse__Parent_Task__c;
            return pParentTaskId;
        } 
        private set;
    }
    
    public String name {
        get{return obudgetTask.Name;} 
        private set;
    }
    
    private String pTaskNumber;
    public String taskNumber {
        get{if(obudgetTask != null) pTaskNumber = obudgetTask.ProjectTask__r.ProjectTaskNumber__c;
            return pTaskNumber;
        } 
        private set;
    }
    
    private String pTaskName;
    public String taskName {
        get{ if(obudgetTask != null) pTaskName = obudgetTask.ProjectTask__r.Name;
            return pTaskName;

        } 
        private set;
    }

    private String pBudgetCostStrategy;

    public  String budgetCostStrategy {
        get {
            if (pBudgetCostStrategy == null) pBudgetCostStrategy = obudgetTask.ProjectTask__r.pse__Project__r.BudgetStrategy__c; 
            return pBudgetCostStrategy;
        }
        private set;
    }

    public Decimal pageOverrideTotalRevenue { get; set; }

    public Decimal OverrideTotalRevenue {
        get { 
            if(obudgetTask.OverrideTotalRevenue__c != null) {

            } 
            return obudgetTask.OverrideTotalRevenue__c;
        }

        set {
            obudgetTask.OverrideTotalRevenue__c = value;
        }
    }
    private transient Map<String, Decimal> values;

    private transient Decimal  pTotalContingency;
    public Decimal totalContingency {
    	get { return pTotalContingency; }

    	set {
    		values.put('totalContingency', value);
    		pTotalContingency = value;
    	}
    }

    private transient Decimal  ptotalContingencyRevenue;
    public Decimal totalContingencyRevenue {
    	get { return ptotalContingencyRevenue; }

    	set {
    		values.put('totalContingencyRevenue', value);
    		ptotalContingencyRevenue = value;
    	}
    }

    private transient Decimal  ptotalCost;
    public Decimal totalCost {
    	get { return ptotalCost; }

    	set {
    		values.put('totalCost', value);
    		ptotalCost = value;
    	}
    }

    private transient Decimal  ptotalComputedCost;
    public Decimal totalComputedCost {
    	get { return ptotalComputedCost; }

    	set {
    		values.put('totalComputedCost', value);
    		ptotalComputedCost = value;
    	}
    }
    
    private transient Decimal  ptotalFringe;
    public Decimal totalFringe {
    	get { return ptotalFringe; }

    	set {
    		values.put('totalFringe', value);
    		ptotalFringe = value;
    	}
    }
    
    private transient Decimal  ptotalFullyBurdenedLaborRate;
    public Decimal totalFullyBurdenedLaborRate {
    	get { return ptotalFullyBurdenedLaborRate; }

    	set {
    		values.put('totalFullyBurdenedLaborRate', value);
    		ptotalFullyBurdenedLaborRate = value;
    	}
    }
    
    private transient Decimal  ptotalLaborHours;
    public Decimal totalLaborHours {
    	get { return isNull(ptotalLaborHours).setScale(2); }

    	set {
    		values.put('totalLaborHours', value);
    		ptotalLaborHours = value;
    	}
    }
    
    private transient Decimal  ptotalODCCost;
    public Decimal totalODCCost {
    	get { return isNull(ptotalODCCost).setScale(2); }

    	set {
    		values.put('totalODCCost', value);
    		ptotalODCCost = value;
    	}
    }

    private transient Decimal  ptotalODCRevenue;
    public Decimal totalODCRevenue {
    	get { return isNull(ptotalODCRevenue).setScale(2); }
    	
    	set {
    		values.put('totalODCRevenue', value);
    		ptotalODCRevenue = value;
    	}
    }

    private transient Decimal  ptotalOverhead;
    public Decimal totalOverhead {
    	get { return isNull(ptotalOverhead).setScale(2); }

    	set {
    		values.put('totalOverhead', value);
    		ptotalOverhead = value;
    	}
    }
    
    private transient Decimal  ptotalRawCost;
    public Decimal totalRawCost {
    	get { return isNull(ptotalRawCost).setScale(2); }

    	set {
    		values.put('totalRawCost', value);
    		ptotalRawCost = value;
    	}
    }
    
    private transient Decimal  ptotalRevenue;
    public Decimal totalRevenue {
    	get { return isNull(ptotalRevenue).setScale(2); }

    	set {
    		values.put('totalRevenue', value);
    		ptotalRevenue = value;
    	}
    }
    
    private transient Decimal  ptotalSubCost;
    public Decimal totalSubCost {
    	get { return isNull(ptotalSubCost).setScale(2); }

    	set {
    		values.put('totalSubCost', value);
    		ptotalSubCost = value;
    	}
    }

    private transient Decimal  ptotalSubRevenue;
    public Decimal totalSubRevenue {
    	get { return isNull(ptotalSubRevenue).setScale(2); }

    	set {
    		values.put('totalSubRevenue', value);
    		ptotalSubRevenue = value;
    	}
    }
    
    private transient Decimal  ptotalLabourCost;
    public Decimal totalLabourCost {
    	get { return isNull(ptotalLabourCost).setScale(2); }
    
    	set {
    		values.put('totalLabourCost', value);
    		ptotalLabourCost = value;
    	}
    }

    private transient Decimal  ptotalLabourRevenue;
    public Decimal totalLabourRevenue {
        get { return isNull(ptotalLabourRevenue).setScale(2); }

        set {
            values.put('totalLabourRevenue', value);
            ptotalLabourRevenue = value;
        }   
    }

    private transient Decimal  ptotalEACActualCost;
    public Decimal totalEACActualCost {
    	get { return isNull(ptotalEACActualCost).setScale(2); }

    	set {
    		values.put('totalEACActualCost', value);
    		ptotalEACActualCost = value;
    	}
    }

    private transient Decimal  ptotalEACActualQuantity;
    public Decimal totalEACActualQuantity {
        get { return isNull(ptotalEACActualQuantity).setScale(2); }

        set {
            values.put('totalEACActualQuantity', value);
            ptotalEACActualQuantity = value;
        }
    }

    private transient Decimal  ptotalEACApprovedQuantity;
    public Decimal totalEACApprovedQuantity {
        get { return isNull(ptotalEACApprovedQuantity).setScale(2); }

        set {
            values.put('totalEACApprovedQuantity', value);
            ptotalEACApprovedQuantity = value;
        }
    }

    private transient Decimal  ptotalEACApprovedTotalCost;
    public Decimal totalEACApprovedTotalCost {
        get { return isNull(ptotalEACApprovedTotalCost).setScale(2); }

        set {
            values.put('totalEACApprovedTotalCost', value);
            ptotalEACApprovedTotalCost = value;
        }
    }

    private transient Decimal  ptotalEACApprovedRevenue;
    public Decimal totalEACApprovedRevenue {
        get { return isNull(ptotalEACApprovedRevenue).setScale(2); }

        set {
            values.put('totalEACApprovedRevenue', value);
            ptotalEACApprovedRevenue = value;
        }
    }
    
    private transient Decimal  ptotalEACRevisedRevenue;
    public Decimal totalEACRevisedRevenue {
        get { return isNull(ptotalEACRevisedRevenue).setScale(2); }

        set {
            values.put('totalEACRevisedRevenue', value);
            ptotalEACRevisedRevenue = value;
        }
    }

    private transient Decimal  ptotalEACForecastQuantity;
    public Decimal totalEACForecastQuantity {
        get { return isNull(ptotalEACForecastQuantity).setScale(2); }

        set {
            values.put('totalEACForecastQuantity', value);
            ptotalEACForecastQuantity = value;
        }
    }

    private transient Decimal  ptotalEACForecastRevenue;
    public Decimal totalEACForecastRevenue {
        get { return isNull(ptotalEACForecastRevenue).setScale(2); }

        set {
            values.put('totalEACForecastRevenue', value);
            ptotalEACForecastRevenue = value;
        }
    }

    private transient Decimal  ptotalEACAppliedEtcRevenue;
    public Decimal totalEACAppliedEtcRevenue {
        get { return isNull(ptotalEACAppliedEtcRevenue).setScale(2); }

        set {
            values.put('totalEACAppliedEtcRevenue', value);
            ptotalEACAppliedEtcRevenue = value;
        }
    }
    
    private transient Decimal  ptotalEACForecastTotalCost;
    public Decimal totalEACForecastTotalCost {
        get { return isNull(ptotalEACForecastTotalCost).setScale(2); }

        set {
            values.put('totalEACForecastTotalCost', value);
            ptotalEACForecastTotalCost = value;
        }
    }

    private transient Decimal  ptotalEACEtcQuantity;
    public Decimal totalEACEtcQuantity {
        get { return isNull(ptotalEACEtcQuantity).setScale(2); }

        set {
            values.put('totalEACEtcQuantity', value);
            ptotalEACEtcQuantity = value;
        }
    }

    private transient Decimal  ptotalEACEtcCost;
    public Decimal totalEACEtcCost{
        get { return isNull(ptotalEACEtcCost).setScale(2); }

        set {
            values.put('totalEACEtcCost', value);
            ptotalEACEtcCost = value;
        }
    }

    private transient Boolean pIncludeThis;
    public Boolean includeThis {
        get {
            if (pIncludeThis == null) pIncludeThis = getIsEditable();
            return pIncludeThis;
        }
        private set;
    }

    public Decimal isNull(Decimal val) {
        Decimal retVal = val == null ? 0.00 : val;

        return retVal;
    }

    private Boolean pHasChildren;
    public Boolean hasChildren {
        get {
            if(pHasChildren == null) pHasChildren = children.size() > 0 ? true: false;
            return pHasChildren;
        }
        private set;
    }

    public Boolean getIsRollupVisible() {
        if (budgetCostStrategy == 'Project Level') 
            return false;

        return hasChildren;
    }

    public Boolean getIsEditable() {
        
        if (budgetCostStrategy == 'Project Level') 
            return false;

        if (!hasChildren && 
            budgetCostStrategy == 'Bottom Task') 
        {
            return true;
        }

        if (parentTaskId == null && 
            budgetCostStrategy == 'Top Task') 
        {
            return true;
        }

        return false;
    }

    public Boolean getIsVisible() {

        if (budgetCostStrategy == 'Project Level') 
            return false;

        if (hasChildren && 
            budgetCostStrategy == 'Bottom Task')
                return true;

        return false;
        /*
        if (parentTaskId == null &&
            obudgetTask.ProjectTask__r.pse__Project__r.BudgetStrategy__c == 'Top Task') 
        {
            return true;
        }

        return false;
        */
    }

    public Boolean showProject {
        get {
            return obudgetTask.ProjectTask__r.pse__Project__r.BudgetStrategy__c == 'Project Level';
        }
        private set;
    }
    public ECO_DTO_BudgetTask parent {get; set;}
    public transient List<ECO_DTO_BudgetTask> children {get; set;}
    public transient Integer indentLevel {get; set;}

    public transient String parentClasses {get; set;}

    public ECO_DTO_BudgetTask() {
    	values = new Map<String, Decimal>();
        children = new List<ECO_DTO_BudgetTask>();

        totalComputedCost = 0;
    }

    public ECO_DTO_BudgetTask(pse__Project_Task__c projectTask) {
        this();
        obudgetTask = new BudgetTask__c();
        obudgetTask.ProjectTask__c = projectTask.Id;
        obudgetTask.ProjectTask__r = projectTask;

        totalComputedCost = 0;
    }
    
    public ECO_DTO_BudgetTask(BudgetTask__c budgetTask) {
        obudgetTask = budgetTask;

    	values = new Map<String, Decimal>();

    	totalComputedCost = 0;
        budgetTaskId = obudgetTask.Id;
        totalContingency = obudgetTask.TotalContingency__c;
        totalContingencyRevenue = obudgetTask.TotalContingencyRevenue__c;
        totalCost = budgetTask.TotalCost__c;
        totalFringe = budgetTask.TotalFringe__c;
        totalFullyBurdenedLaborRate = budgetTask.TotalFullyBurdenedLaborRate__c;
        totalLaborHours = budgetTask.TotalLaborHours__c;
        totalODCCost = budgetTask.TotalODCCost__c;
        totalODCRevenue = budgetTask.TotalODCRevenue__c;
        totalOverhead = budgetTask.TotalOverhead__c;
        totalRawCost = budgetTask.TotalRawCost__c;
        totalRevenue = budgetTask.TotalRevenue__c;
        totalSubCost = budgetTask.TotalSubCost__c;
        totalSubRevenue = budgetTask.TotalSubRevenue__c;
        totalLabourCost = budgetTask.TotalLaborCost__c;
        totalLabourRevenue = budgetTask.TotalLaborRevenue__c;
        pageOverrideTotalRevenue = budgetTask.OverrideTotalRevenue__c;

        children = new List<ECO_DTO_BudgetTask>();
    }

    public Decimal getValueByName(String name) {
    	Decimal result = values.get(name);

    	if (result == null)
    		result = 0.0;

    	return result;
    }

    public void addChild(ECO_DTO_BudgetTask child) {
        children.add(child);
        child.parent = this;
    }

    public Decimal getSubtaskTotal(String fieldName) {
        return getSubtaskTotal(fieldName, true);
    }

    public Decimal getSubtaskTotal(String fieldName, boolean includeThis) {
        return getSubtaskTotal(fieldName, includeThis, true);
    }

    public Decimal getSubtaskTotal(String fieldName, boolean includeThis, Boolean includeChildren) {
        Decimal result = 0;


        if (this.includeThis || !hasChildren) {
            result += getValueByName(fieldName);
        }

        if (children.size() > 0 && includeChildren) {
            for (ECO_DTO_BudgetTask child : children) {
                result += child.getSubtaskTotal(fieldName, true, true);
            }
        }

        return result;
    }
}