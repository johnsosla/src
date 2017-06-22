public class ECO_DTO_BudgetHeader {
	public BudgetHeader__c oBudgetHeader {get; set;}
    
    public Map<String, String> budgetHeaderChangeManagerMap {get; set;}
    
    public static final String STATUS_APPROVED = 'Approved';
    public static final String STATUS_FORECAST = 'Forecast';
    public static final String STATUS_WORKATRISK = 'Work at Risk';
    public static final String STATUS_ESTIMATE = 'Draft';
    public static final String STATUS_ARCHIVE = 'Archive';

    public static final String STATUS_SUBMITTED_APPROVAL = 'Submitted for Approval';
    public static final String STATUS_SUBMITTED_FORECAST = 'Submitted for Forecast';
    public static final String STATUS_SUBMITTED_CONVERTED = '';

    public String budgetName{
        get {return oBudgetHeader.BudgetName__c;}
        private set;
    }
    
    public Decimal directPersonnelExpenses {
        get {
            Decimal totalRawCost = oBudgetHeader.TotalRawCost__c;
            Decimal totalFringe = oBudgetHeader.TotalFringe__c;
            Decimal dpe = 0;

            totalRawCost = totalRawCost != null ? totalRawCost : 0;
            totalFringe = totalFringe != null ? totalFringe : 0;

            return totalRawCost + totalFringe;
        }
    }

    public Decimal salaryCostMultiplier {
        get {

            if(directPersonnelExpenses == 0)
                return 0.00;

            return oBudgetHeader.NetServicesRevenue__c / directPersonnelExpenses;
        }
    }
    
    public Decimal averageLabourRatePerHour {
        get {
            if(oBudgetHeader.TotalLaborHours__c == 0)
                return 0.00;
            return oBudgetHeader.NetServicesRevenue__c / oBudgetHeader.TotalLaborHours__c;
        }
    }
    
    public DateTime createdDate {
        get {return oBudgetHeader.CreatedDate;}
        private set;
    }
    
    public String status {
        get {return oBudgetHeader.WorkAtRisk__c ? STATUS_WORKATRISK  : oBudgetHeader.Status__c;}
        private set;
    }
    
    public String approvalStatus {
        get {return oBudgetHeader.ApprovalStatus__c;}
        private set;
    }

    public decimal dTotalCost {
        get {return oBudgetHeader.TotalCost__c;}
        private set;
    }
    
    public decimal dTotalRevenue {
        get {return oBudgetHeader.AppliedTotalRevenueDisplay__c;}
        private set;
    }
    
    public decimal dTotalApprovedCost {
        get{
            if(oBudgetHeader.Status__c == STATUS_APPROVED)
                return oBudgetHeader.TotalCost__c;
            
            return 0.0;
        }
        
        private set;
    }
    
    public decimal dTotalApprovedRevenue {
        get{
            if(oBudgetHeader.Status__c == STATUS_APPROVED)
                return oBudgetHeader.AppliedTotalRevenue__c;
            
            return 0.0;
        }
        
        private set;
    }
    
    public decimal dTotalForecastCost {
        get{
            if(oBudgetHeader.Status__c == STATUS_APPROVED || oBudgetHeader.Status__c == STATUS_FORECAST || oBudgetHeader.Status__c == STATUS_WORKATRISK)
                return oBudgetHeader.TotalCost__c;
            
            return 0.0;
        }
        
        private set;
    }
    
    public decimal dTotalForecastRevenue {
        get{
            if(oBudgetHeader.Status__c == STATUS_APPROVED || oBudgetHeader.Status__c == STATUS_FORECAST ) {
                return oBudgetHeader.AppliedTotalRevenue__c;
            }  else if (oBudgetHeader.Status__c == STATUS_WORKATRISK) {
                return dTotalWorkAtRiskRevenue;
            }    
            
            return 0.0;
        }
        
        private set;
    }
    
    public decimal dTotalWorkAtRiskCost {
        get{
            if(oBudgetHeader.Status__c == STATUS_WORKATRISK)
                return oBudgetHeader.TotalCost__c;
            
            return 0.0;
        }
        
        private set;
    }
    
    private decimal pdTotalWorkAtRiskRevenue = null;
    public decimal dTotalWorkAtRiskRevenue {
        get{
            if (pdTotalWorkAtRiskRevenue != null) return pdTotalWorkAtRiskRevenue;
            if(oBudgetHeader.Status__c == STATUS_WORKATRISK) {
                    pdTotalWorkAtRiskRevenue = calcWorkAtRiskRevenue(); 

                } else {
                    pdTotalWorkAtRiskRevenue = 0.0;
                }
            
            return pdTotalWorkAtRiskRevenue;
        }
        
        private set;
    }
    
    public Decimal calcWorkAtRiskRevenue() {
        if (oBudgetHeader.Project__r.BudgetStrategyRevenue__c == 'Project Level') {
            return minimum(oBudgetHeader.AppliedTotalRevenue__c, oBudgetHeader.TotalCost__c);
        } else {
            if (oBudgetHeader.Project__r.BudgetStrategy__c == 'Bottom Task') {
                Decimal totalWarRevenue = 0.0;
                Map<Id, Decimal> mapCostRollupByProjectTask = new Map<Id, Decimal>();

                List<BudgetTask__c> bts = [Select Id, ProjectTask__c, ProjectTask__r.pse__Parent_Task__c, ProjectTask__r.pse__Top_level_Parent_Task__c,  TotalCost__c, OverrideTotalRevenue__c FROM BudgetTask__c Where BudgetHeader__c = :oBudgetHeader.Id];
                for (BudgetTask__c bt : bts) {
                    Decimal totalCostRollup = ECO_Utils_Math.ifNull(mapCostRollupByProjectTask.get(bt.ProjectTask__r.pse__Top_level_Parent_Task__c));

                    totalCostRollup += ECO_Utils_Math.ifNull(bt.TotalCost__c);
                    mapCostRollupByProjectTask.put(bt.ProjectTask__r.pse__Top_level_Parent_Task__c, totalCostRollup);
                }

                for (BudgetTask__c bt : bts) {
                    if (bt.ProjectTask__r.pse__Parent_Task__c != null) continue;
                    Decimal totalCostRollup = ECO_Utils_Math.ifNull(mapCostRollupByProjectTask.get(bt.ProjectTask__c));
                    
                    // totalCostRollup += ECO_Utils_Math.ifNull(bt.TotalCost__c);
                    totalWarRevenue += minimum(totalCostRollup, ECO_Utils_Math.ifNull(bt.OverrideTotalRevenue__c));

                    system.debug(LoggingLevel.INFO, ' --- totalCostRollup: ' + bt.ProjectTask__c + ' - ' + totalCostRollup + ' - ' + bt.OverrideTotalRevenue__c );
                    
                }

                return totalWarRevenue;
            } else {
                return oBudgetHeader.TotalTopLevelWorkAtRiskRevenue__c;
            }
        }
    }
    
    public Decimal displayRevenue {
        get {
            if (oBudgetHeader.Status__c == STATUS_WORKATRISK) {
                return dTotalWorkAtRiskRevenue;
            } else {
                return dTotalRevenue;
            }
        }

        private set;
    } 

    public Decimal changeValueRevenue {
        get {
            return dTotalRevenue;
        }

        private set;
    }
    public List<SelectOption> lstActions {
        get {
            List<SelectOption> listOptions = new List<SelectOption>();
            listOptions.add(new SelectOption('',Label.Task_Detail_Select_Task_Select_Action));

            if(!oBudgetHeader.CreatedBy.Username.contains('integration@aecom.com') && !oBudgetHeader.CreatedBy.Username.contains('integrations@aecom.com')) {
                if(oBudgetHeader.Status__c == STATUS_ESTIMATE && String.IsEmpty(budgetHeaderChangeManagerMap.get('Internal Change'))&& String.IsEmpty(budgetHeaderChangeManagerMap.get('External Change')) && String.IsEmpty(budgetHeaderChangeManagerMap.get('Work at Risk Change')) ) {
                    if (oBudgetHeader.RecordType.DeveloperName == 'Change_Order') {
                        listOptions.add(new SelectOption('SubmitWorkAtRiskChange','Submit Work At Risk'));
                    } else {
                        listOptions.add(new SelectOption('SubmitInternalChange','Submit Forecasted Change'));
                    }
                }
                
                String recordTypeName = '';
                if (oBudgetHeader.RecordType != null) {
                    recordTypeName = oBudgetHeader.RecordType.DeveloperName;
                }
                if((recordTypeName != 'EAC') && 
                   (oBudgetHeader.Status__c == STATUS_ESTIMATE || oBudgetHeader.Status__c == STATUS_FORECAST || oBudgetHeader.Status__c == STATUS_WORKATRISK) && 
                   String.IsEmpty(budgetHeaderChangeManagerMap.get('External Change'))) {
                    listOptions.add(new SelectOption('SubmitExternalChange','Submit Approved Change'));
                }
            }
            if(oBudgetHeader.Status__c != STATUS_APPROVED && oBudgetHeader.Status__c != STATUS_FORECAST 
                && oBudgetHeader.Status__c != STATUS_ARCHIVE) {
                listOptions.add(new SelectOption('ArchiveBudget','Archive Budget'));
            }

            if(oBudgetHeader.Status__c == STATUS_ARCHIVE) {
                listOptions.add(new SelectOption('UnArchiveBudget','UnArchive Budget'));
            }
           
            if(!String.IsEmpty(budgetHeaderChangeManagerMap.get('Internal Change'))) {
                listOptions.add(new SelectOption('ViewInternalChange','View Change Record (Forecast/WaR)'));
            }
            
            if(!String.IsEmpty(budgetHeaderChangeManagerMap.get('External Change'))) {
                listOptions.add(new SelectOption('ViewExternalChange','View Change Record (As Sold)'));
            }

            if(!String.IsEmpty(budgetHeaderChangeManagerMap.get('Work at Risk Change'))) {
                listOptions.add(new SelectOption('ViewWorkAtRiskChange','View Change Record (Forecast/WaR)'));
            }

            
            return listOptions;
        }
        
        private set;
    }
    
    public String strSelectedAction { get; set;}
    
    public Decimal minimum(Decimal val1, Decimal val2) {
        if (val1 == null && val2 != null) return val2;
        if (val1 != null && val2 == null) return val1;
        return val1 < val2 ? val1 : val2;
    }

    public Map<String, Decimal> values {get; set;}
    public Decimal NetServicesRevenue { get; set; }
    public Decimal GrossMargin { get; set; }
    public Decimal NetMargin { get; set; }
    public Decimal GMNSR { get; set; }
    public Decimal NMNSR { get; set; }

    public void calcMetrics() {
        Decimal revenue = displayRevenue;
        BudgetHeader__c ob = oBudgetHeader;
        values = new Map<String, Decimal> ();
        values.put('NetServicesRevenue__c', revenue - ob.TotalSubAmount__c - ob.TotalFeeAmount__c - ob.TotalContingencyAmount__c);
        values.put('GrossMargin__c', revenue - (ob.TotalRawCost__c + ob.TotalFringe__c + ob.TotalFeeAmount__c + ob.TotalSubAmount__c + ob.TotalContingencyAmount__c));
        values.put('NetMargin__c', revenue - ob.TotalCost__c);
        values.put('GMNSR__c', values.get('NetServicesRevenue__c') == 0 ? 0: values.get('GrossMargin__c') / values.get('NetServicesRevenue__c'));
        values.put('NMNSR__c', values.get('NetServicesRevenue__c') == 0 ? 0: values.get('NetMargin__c') / values.get('NetServicesRevenue__c'));
        
        values.put('AppliedTotalRevenue__c', displayRevenue);
        values.put('AppliedTotalRevenueDisplay__c', displayRevenue);


        values.put('ChangeValueNetServicesRevenue__c', changeValueRevenue - ob.TotalSubAmount__c - ob.TotalFeeAmount__c - ob.TotalContingencyAmount__c);
        values.put('ChangeValueGrossMargin__c', changeValueRevenue - (ob.TotalRawCost__c + ob.TotalFringe__c + ob.TotalFeeAmount__c + ob.TotalSubAmount__c + ob.TotalContingencyAmount__c));
        values.put('ChangeValueNetMargin__c', changeValueRevenue - ob.TotalCost__c);
        values.put('ChangeValueGMNSR__c', values.get('ChangeValueNetServicesRevenue__c') == 0 ? 0: values.get('ChangeValueGrossMargin__c') / values.get('ChangeValueNetServicesRevenue__c'));
        values.put('ChangeValueNMNSR__c', values.get('ChangeValueNetServicesRevenue__c') == 0 ? 0: values.get('ChangeValueNetMargin__c') / values.get('ChangeValueNetServicesRevenue__c'));
        
        values.put('ChangeValueAppliedTotalRevenueDisplay__c', changeValueRevenue);

    }

    public ECO_DTO_BudgetHeader(BudgetHeader__c o_BudgetHeader){
        oBudgetHeader = o_BudgetHeader;
        calcMetrics();

        budgetHeaderChangeManagerMap = new Map<String, String>();
        budgetHeaderChangeManagerMap.put('Internal Change', '');
        budgetHeaderChangeManagerMap.put('External Change', '');
        budgetHeaderChangeManagerMap.put('Work at Risk Change', '');

        for(changeManager__c change : oBudgetHeader.Change_Manager__r) {
            budgetHeaderChangeManagerMap.put(change.RecordType.Name, change.Id);   
        }
        
        for(ChangeManagerSelectedObject__c selectedObject : oBudgetHeader.Change_Manager_Selected_Objects__r) {
            budgetHeaderChangeManagerMap.put(selectedObject.ChangeManager__r.RecordType.Name, selectedObject.ChangeManager__c);
        }
        
    }
}