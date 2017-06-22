/** ---------------------------------------------------------------------------------------
* @Description Wrapper class for BudgetHeader objects
*
* @Author Omar.Abdellatief@nttdata.com, Arman.Shah@nttdata.com
* @Date September 2016
*----------------------------------------------------------------------------------------*/

public class ECO_DTO_BudgetHeaderWrapper {
    public List<ECO_DTO_BudgetHeader> dtoBudgetHeaders{get; set;}
    
    public Decimal getOriginalTotalRawLabour {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalRawCost__c', true);}
    }

    public Decimal getBudgetTotalRawLabour {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalRawCost__c');}
    }
    
    public Decimal getForecastTotalRawLabour {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalRawCost__c');}
    }
    
    public Decimal getWorkAtRiskTotalRawLabour {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalRawCost__c');}
    }
    
    public Decimal getEstimateTotalRawLabour {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'TotalRawCost__c', true);}
    }
    
    public Decimal getChangeValueTotalRawLabour {
        get{return calculateTotal(null, 'TotalRawCost__c');}
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalFBLR {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalLaborAmount__c', true);}
    }

    public Decimal getBudgetTotalFBLR {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalLaborAmount__c');}
    }
    
    public Decimal getForecastTotalFBLR {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalLaborAmount__c');}
    }
    
    public Decimal getWorkAtRiskTotalFBLR {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalLaborAmount__c');}
    }
    
    public Decimal getEstimateTotalFBLR {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'TotalLaborAmount__c');}
    }

    public Decimal getChangeValueTotalFBLR {
        get{return calculateTotal(null, 'TotalLaborAmount__c');}
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalFringe {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalFringe__c', true);}
    }

    public Decimal getBudgetTotalFringe {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalFringe__c');}
    }

    public Decimal getForecastTotalFringe {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalFringe__c');}
    }

    public Decimal getWorkAtRiskTotalFringe {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalFringe__c');}
    } 
    
    public Decimal getEstimateTotalFringe {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'TotalFringe__c');}
    }

    public Decimal getChangeValueTotalFringe {
        get{return calculateTotal(null, 'TotalFringe__c');}
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalOverhead {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalOverhead__c', true);}
    }

    public Decimal getBudgetTotalOverhead {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalOverhead__c');}
    }

    public Decimal getForecastTotalOverhead {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalOverhead__c');}
    }

    public Decimal getWorkAtRiskTotalOverhead {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalOverhead__c');}
    }
    
    public Decimal getEstimateTotalOverhead {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'TotalOverhead__c');}
    }

    public Decimal getChangeValueTotalOverhead {
        get{return calculateTotal(null, 'TotalOverhead__c');}
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalSubAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalSubAmount__c', true);}
    }

    public Decimal getBudgetTotalSubAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalSubAmount__c');}
    }

    public Decimal getForecastTotalSubAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalSubAmount__c');}
    }

    public Decimal getWorkAtRiskTotalSubAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalSubAmount__c');}
    }
    
    public Decimal getEstimateTotalSubAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'TotalSubAmount__c');}
    }

    public Decimal getChangeValueTotalSubAmount {
        get{return calculateTotal(null, 'TotalSubAmount__c');}
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalFeeAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalFeeAmount__c', true);}
    }

    public Decimal getBudgetTotalFeeAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalFeeAmount__c');}
    }

    public Decimal getForecastTotalFeeAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalFeeAmount__c');}
    }

    public Decimal getWorkAtRiskTotalFeeAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalFeeAmount__c');}
    }
    
    public Decimal getEstimateTotalFeeAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'TotalFeeAmount__c');}
    }

    public Decimal getChangeValueTotalFeeAmount {
        get{return calculateTotal(null, 'TotalFeeAmount__c');}
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////

    public Decimal getOriginalTotalContingencyAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalContingencyAmount__c', true);}
    }

    public Decimal getBudgetTotalContingencyAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalContingencyAmount__c');}
    }

    public Decimal getForecastTotalContingencyAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalContingencyAmount__c');}
    }

    public Decimal getWorkAtRiskTotalContingencyAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalContingencyAmount__c');}
    }
    
    public Decimal getEstimateTotalContingencyAmount {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'TotalContingencyAmount__c');}
    }

    public Decimal getChangeValueTotalContingencyAmount {
        get{return calculateTotal(null, 'TotalContingencyAmount__c');}
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalCost {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalCost__c', true);}
    }

    public Decimal getBudgetTotalCost {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalCost__c');}
    }

    public Decimal getForecastTotalCost {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalCost__c');}
    }

    public Decimal getWorkAtRiskTotalCost {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalCost__c');}
    }
    
    public Decimal getEstimateTotalCost {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'TotalCost__c');}
    }

    public Decimal getChangeValueTotalCost {
        get{return calculateTotal(null, 'TotalCost__c');}
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalRevenue {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'AppliedTotalRevenueDisplay__c', true);}
    }

    public Decimal getBudgetTotalRevenue {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'AppliedTotalRevenueDisplay__c');}
    }

    public Decimal getForecastTotalRevenue {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'AppliedTotalRevenue__c');}
    }

    public Decimal getWorkAtRiskTotalRevenue {
        get {
            return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'AppliedTotalRevenue__c');
        }
    }
    
    public Decimal getEstimateTotalRevenue {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'AppliedTotalRevenue__c');}
    }

    public Decimal getChangeValueTotalRevenue {
        get{return calculateTotal(null, 'AppliedTotalRevenueDisplay__c');}
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalNetServiceRevenue {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'NetServicesRevenue__c', true);}
    }

    public Decimal getBudgetTotalNetServiceRevenue {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'NetServicesRevenue__c');}
    }

    public Decimal getForecastTotalNetServiceRevenue {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'NetServicesRevenue__c');}
    }

    public Decimal getWorkAtRiskTotalNetServiceRevenue {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'NetServicesRevenue__c');}
    }
    
    public Decimal getEstimateTotalNetServiceRevenue {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'NetServicesRevenue__c');}
    }

    public Decimal getChangeValueTotalNetServiceRevenue {
        get{return calculateTotal(null, 'NetServicesRevenue__c');}
    }    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalGrossMargin {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'GrossMargin__c', true);}
    }

    public Decimal getBudgetTotalGrossMargin {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'GrossMargin__c');}
    }

    public Decimal getForecastTotalGrossMargin {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'GrossMargin__c');}
    }

    public Decimal getWorkAtRiskTotalGrossMargin {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'GrossMargin__c');}
    }
    
    public Decimal getEstimateTotalGrossMargin {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'GrossMargin__c');}
    }

    public Decimal getChangeValueTotalGrossMargin {
        get{return calculateTotal(null, 'GrossMargin__c');}
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalNetMargin {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'NetMargin__c', true);}
    }

    public Decimal getBudgetTotalNetMargin {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'NetMargin__c');}
    }

    public Decimal getForecastTotalNetMargin {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'NetMargin__c');}
    }

    public Decimal getWorkAtRiskTotalNetMargin {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'NetMargin__c');}
    }
    
    public Decimal getEstimateTotalNetMargin {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'NetMargin__c');}
    }

    public Decimal getChangeValueTotalNetMargin {
        get{return calculateTotal(null, 'NetMargin__c');}
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalGMNSR {
        get{
            Decimal NSR = calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'NetServicesRevenue__c', true);
            
            if(NSR != 0) {
                Decimal GM = calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'GrossMargin__c', true);    
                return (100*GM/NSR).setScale(2);
            }
            return 0.0;
        }
    }

    public Decimal getBudgetTotalGMNSR {
        get{
            Decimal NSR = calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'NetServicesRevenue__c');
            
            if(NSR != 0) {
                Decimal GM = calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'GrossMargin__c');    
                return (100*GM/NSR).setScale(2);
            }
            return 0.0;
        }
    }

    public Decimal getForecastTotalGMNSR {
        get{
            Decimal NSR = calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'NetServicesRevenue__c');
            
            if(NSR != 0) {
                Decimal GM = calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'GrossMargin__c');    
                return (100*GM/NSR).setScale(2);
            }
            return 0.0;
        }
    }

    public Decimal getWorkAtRiskTotalGMNSR {
        get{
            Decimal NSR = calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'NetServicesRevenue__c');
            
            if(NSR != 0) {
                Decimal GM = calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'GrossMargin__c');    
                return (100*GM/NSR).setScale(2);
            }            
            return 0.0;
        }
    }
    
    public Decimal getEstimateTotalGMNSR {
        get{
            Decimal NSR = calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'NetServicesRevenue__c');
            
            if(NSR != 0) {
                Decimal GM = calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'GrossMargin__c');    
                return (100*GM/NSR).setScale(2);
            }
            return 0.0;
        }
    }

    public Decimal getChangeValueTotalGMNSR {
        get{
            Decimal NSR = calculateTotal(null, 'NetServicesRevenue__c');
            
            if(NSR != 0) {
                Decimal GM = calculateTotal(null, 'GrossMargin__c');    
                return (100*GM/NSR).setScale(2);
            }
            return 0.0;
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalNMNSR {
        get{
            Decimal NSR = calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'NetServicesRevenue__c', true);
            
            if(NSR != 0) {
                Decimal NM = calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'NetMargin__c', true);    
                return (100*NM/NSR).setScale(2);
            }
            return 0.0;
        }
    }

    public Decimal getBudgetTotalNMNSR {
        get{
            Decimal NSR = calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'NetServicesRevenue__c');
            
            if(NSR != 0) {
                Decimal NM = calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'NetMargin__c');    
                return (100*NM/NSR).setScale(2);
            }
            return 0.0;
        }
    }

    public Decimal getForecastTotalNMNSR {
        get{
            Decimal NSR = calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'NetServicesRevenue__c');
            
            if(NSR != 0) {
                Decimal NM = calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'NetMargin__c');    
                return (100*NM/NSR).setScale(2);
            }
            return 0.0;
        }
    }

    public Decimal getWorkAtRiskTotalNMNSR {
        get{
            Decimal NSR = calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'NetServicesRevenue__c');
            
            if(NSR != 0) {
                Decimal NM = calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'NetMargin__c');    
                return (100*NM/NSR).setScale(2);
            }

            return 0.0;
        }
    }
    
    public Decimal getEstimateTotalNMNSR {
        get{
            Decimal NSR = calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'NetServicesRevenue__c');
            
            if(NSR != 0) {
                Decimal NM = calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'NetMargin__c');    
                return (100*NM/NSR).setScale(2);
            }
            return 0.0;
        }
    }

    public Decimal getChangeValueTotalNMNSR {
        get{
            Decimal NSR = calculateTotal(null, 'NetServicesRevenue__c');
            
            if(NSR != 0) {
                Decimal NM = calculateTotal(null, 'NetMargin__c');    
                return (100*NM/NSR).setScale(2);
            }
            return 0.0;
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalSalaryCostMultiplier {
        get{
            return calculateTotalDTOproperty(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'salaryCostMultiplier', true).setScale(1);
        }
    }
    
    public Decimal getBudgetTotalSalaryCostMultiplier {
        get{
            return calculateTotalDTOproperty(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'salaryCostMultiplier').setScale(1);
        }
    }
    
    public Decimal getForecastTotalSalaryCostMultiplier {
        get{
            return calculateTotalDTOproperty(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'salaryCostMultiplier').setScale(1);
        }
    }
    
    public Decimal getWorkAtRiskTotalSalaryCostMultiplier {
        get{
            return calculateTotalDTOproperty(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'salaryCostMultiplier').setScale(1);
        }
    }
    
    public Decimal getEstimateTotalSalaryCostMultiplier {
        get{
            return calculateTotalDTOproperty(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'salaryCostMultiplier').setScale(1);
        }
    }

    public Decimal getChangeValueTotalSalaryCostMultiplier {
        get{
            return calculateTotalDTOproperty(null, 'salaryCostMultiplier').setScale(1);
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalTotalAverageLabourRatePerHour {
        get{
            return calculateTotalDTOproperty(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'averageLabourRatePerHour', true).setScale(2);
        }
    }
    
    public Decimal getBudgetTotalAverageLabourRatePerHour {
        get{
            return calculateTotalDTOproperty(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'averageLabourRatePerHour').setScale(2);
        }
    }
    
    public Decimal getForecastTotalAverageLabourRatePerHour {
        get{
            return calculateTotalDTOproperty(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'averageLabourRatePerHour').setScale(2);
        }
    }
    
    public Decimal getWorkAtRiskTotalAverageLabourRatePerHour {
        get{
            return calculateTotalDTOproperty(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'averageLabourRatePerHour').setScale(2);
        }
    }
    
    public Decimal getEstimateTotalAverageLabourRatePerHour {
        get{
            return calculateTotalDTOproperty(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'averageLabourRatePerHour').setScale(2);
        }
    }

    public Decimal getChangeValueTotalAverageLabourRatePerHour {
        get{
            return calculateTotalDTOproperty(null, 'averageLabourRatePerHour').setScale(2);
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal getOriginalHours {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalLaborHours__c', true);}
    }

    public Decimal getBudgetHours {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED, 'TotalLaborHours__c');}
    }

    public Decimal getForecastHours {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST + ',' + ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalLaborHours__c');}
    }

    public Decimal getWorkAtRiskHours {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_WORKATRISK, 'TotalLaborHours__c');}
    }
    
    public Decimal getEstimateHours {
        get{return calculateTotal(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, 'TotalLaborHours__c');}
    }

    public Decimal getChangeValueHours {
        get{return calculateTotal(null, 'TotalLaborHours__c');}
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    public Decimal calculateTotal(String statuses, String field) {
        return calculateTotal(statuses, field, null);
    }
    public Decimal calculateTotal(String statuses, String field, Boolean isOriginal) {
        return calculateTotal(statuses, field, null, null);
    }
    public Decimal calculateTotal(String statuses, String field, String approvalStatuses, Boolean isOriginal) {
        
        Decimal total = 0.0;
        for(ECO_DTO_BudgetHeader budgetHeader : dtoBudgetHeaders) {
            if(filterBudgets(budgetHeader, statuses, approvalStatuses, isOriginal)) { // if(statusList.contains(budgetHeader.status)) {
                String prefix = statuses == null ? 'ChangeValue' : '';
                Decimal value = budgetHeader.values.get(prefix + field);

                if (value == null) {
                    value = (Decimal)budgetHeader.oBudgetHeader.get(field);
                }
                total = total + value;
            }
        }
        
        return total;
    }

    public Decimal calculateTotalRevenue(String statuses) {
        return calculateTotalRevenue(statuses, null);
    }

    public Decimal calculateTotalRevenue(String statuses, Boolean isOriginal) {
        
        Decimal total = 0.0;
        for(ECO_DTO_BudgetHeader budgetHeader : dtoBudgetHeaders) {
            if(filterBudgets(budgetHeader, statuses, null, isOriginal)) { // if(statusList.contains(budgetHeader.status)) {
                total = total + (Decimal)budgetHeader.displayRevenue;
            }
        }
        
        return total;
    }

    public Decimal calculateTotalDTOproperty(String statuses, String property) {
        return calculateTotalDTOproperty(statuses, property, null);
    }
    public Decimal calculateTotalDTOproperty(String statuses, String property, Boolean isOriginal) {
        return calculateTotalDTOproperty(statuses, property, null, null, null);
    }
    public Decimal calculateTotalDTOproperty(String statuses, String property, String approvalStatuses, Boolean isOriginal, Id bhId) {
        
        Decimal totalNum = 0.0;
        Decimal totalDen = 0.0;

        for(ECO_DTO_BudgetHeader budgetHeader : dtoBudgetHeaders) {
            if(filterBudgets(budgetHeader,statuses, approvalStatuses, isOriginal) || (budgetHeader.oBudgetHeader.Id == bhId)) { // if(statusList.contains(budgetHeader.status)) {
                totalNum = totalNum + budgetHeader.oBudgetHeader.NetServicesRevenue__c;
                if(property == 'salaryCostMultiplier'){
                    totalDen = totalDen + budgetHeader.directPersonnelExpenses;
                }
                else if(property == 'averageLabourRatePerHour') {
                    totalDen = totalDen + budgetHeader.oBudgetHeader.TotalLaborHours__c;
                }                
            }
        }
        
        if (totalDen != 0.0) {
            return totalNum/totalDen;
        }
        return 0.0;        
    }
    
    public Integer calculateRecordsWithStatus(String statuses) {
        return calculateRecordsWithStatus(statuses,null);
    }
    public Integer calculateRecordsWithStatus(String statuses, Boolean isOriginal) {
        return calculateRecordsWithStatus(statuses,'',isOriginal);
    }
    public Integer calculateRecordsWithStatus(String statuses, String approvalStatuses, Boolean isOriginal) {
        Integer total = 0;
        for(ECO_DTO_BudgetHeader budgetHeader : dtoBudgetHeaders) {
            if(filterBudgets(budgetHeader, statuses, approvalStatuses, isOriginal)) { // if(statusList.contains(budgetHeader.status)) {
                total = total + 1;
            }
        }
        
        return total;
    }

    private Boolean filterBudgets(ECO_DTO_BudgetHeader budgetHeader, String statuses, String approvalStatuses, Boolean isOriginal){
        Set<String> statusList = (statuses==null||statuses=='')?null:new Set<String>(statuses.split(','));
        Set<String> approvalStatusList = (approvalStatuses==null||approvalStatuses=='')?null:new Set<String>(approvalStatuses.split(','));
        
        Boolean okStatus = (statusList == null || statusList.contains(budgetHeader.status));
        Boolean okApproval = (approvalStatusList == null || approvalStatusList.contains(budgetHeader.approvalStatus));
        Boolean okOriginal = (isOriginal == null || (budgetHeader.oBudgetHeader.OriginalBudget__c == isOriginal));
        Boolean result = (okStatus && okApproval && okOriginal);
        return result;
    }

    public ECO_DTO_BudgetHeader findBudgetHeaderDTOById(Id budgetHeaderId) {
        
        for(ECO_DTO_BudgetHeader dtoBudgetHeader : dtoBudgetHeaders) {
            if(dtoBudgetHeader.oBudgetHeader.Id == budgetHeaderId) {
                return dtoBudgetHeader;        
            }
        }
        
        return null;
    }

    private static List<String> displayStatuses(Boolean showArchived) {
        List <String> displayStatus = new List<String>();

        if (showArchived ) {
            displayStatus.add(ECO_DTO_BudgetHeader.STATUS_ARCHIVE); 
        } else {
            displayStatus.add(ECO_DTO_BudgetHeader.STATUS_APPROVED);  
            displayStatus.add(ECO_DTO_BudgetHeader.STATUS_FORECAST); 
            displayStatus.add(ECO_DTO_BudgetHeader.STATUS_WORKATRISK); 
            displayStatus.add(ECO_DTO_BudgetHeader.STATUS_ESTIMATE); 
        }
        return displayStatus;
    }

    public Decimal minimum(Decimal val1, Decimal val2) {
        return val1 < val2 ? val1 : val2;
    }

    //TODO -- These are under development Apr 19 2016 Jake
    public enum ReportingStatus { ARCHIVED, APPROVED_ORIGINAL
        , DRAFT_CHANGE, SUBMITTED_CHANGE, APPROVED_CHANGE, UNAPPROVED_CHANGE
        , DRAFT_FORECAST, SUBMITTED_FORECAST, APPROVED_FORECAST, UNAPPROVED_FORECAST
    }
    public Boolean filterBudgets(BudgetHeader__c budget, Set<ReportingStatus> statuses) {
        // use as if (filterBudgets( thisHeader, new Set<ReportingStatus){ReportingStatus.APPROVED_CHANGE, ReportingStatus.APPROVED_ORIGINAL})
        return statuses.contains(getReportingStatus(budget));
    }
    // END under dev
    
    public ReportingStatus getReportingStatus(BudgetHeader__c budget) {
        Boolean isChange = (budget.BudgetType__c == 'Change Order');
        Boolean isForecast = (budget.BudgetType__c == 'Forecast');
        Boolean isEstimate = (budget.Status__c == ECO_DTO_BudgetHeader.STATUS_ESTIMATE);
        Boolean isSubmitted = (budget.ApprovalStatus__c == ECO_DTO_BudgetHeader.STATUS_SUBMITTED_APPROVAL || budget.ApprovalStatus__c == ECO_DTO_BudgetHeader.STATUS_SUBMITTED_FORECAST);
        Boolean isUnapproved = (budget.Status__c == 'Rejected');
        Boolean isApproved = (budget.Status__c == ECO_DTO_BudgetHeader.STATUS_FORECAST || budget.Status__c == ECO_DTO_BudgetHeader.STATUS_APPROVED);
        Boolean isArchived = (budget.Status__c == ECO_DTO_BudgetHeader.STATUS_ARCHIVE);
        Boolean isOriginal = (budget.OriginalBudget__c);
        Boolean appearsConverted = (budget.ApprovalStatus__c == '' 
            && (budget.OriginalBudget__c || budget.Status__c == 'Forecast'));
        
        ReportingStatus reportingStatus;
        if (isArchived) {
            reportingStatus = ECO_DTO_BudgetHeaderWrapper.ReportingStatus.ARCHIVED;
        } else if (isApproved) {
            reportingStatus = (isChange ? (isOriginal ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_ORIGINAL : ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_CHANGE) : (isForecast ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.APPROVED_FORECAST : null));
        } else if (isUnapproved) {
            reportingStatus = (isChange ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.UNAPPROVED_CHANGE : (isForecast ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.UNAPPROVED_FORECAST : null ));
        } else if (isSubmitted) {
            reportingStatus = (isChange ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.SUBMITTED_CHANGE : (isForecast ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.SUBMITTED_FORECAST : null ));
        } else if (isEstimate) {
            reportingStatus = (isChange ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.DRAFT_CHANGE : (isForecast ? ECO_DTO_BudgetHeaderWrapper.ReportingStatus.DRAFT_FORECAST :null ));            
        }
        return reportingStatus;
    }

    public ECO_DTO_BudgetHeaderWrapper(Id projectId) {
        this(projectId, false);
    }

    public ECO_DTO_BudgetHeaderWrapper(Id projectId, Boolean showArchived) {
        dtoBudgetHeaders = new List<ECO_DTO_BudgetHeader>();

        List <String> displayStatus = displayStatuses(showArchived);

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
                                                    BudgetTaskCount__c,
                                                    TotalTopLevelWorkAtRiskRevenue__c,
                                                    Project__r.BudgetStrategy__c, Project__r.BudgetStrategyRevenue__c,
                                                    (SELECT Id, RecordType.Name FROM Change_Manager__r),
                                                    (select Id, ChangeManager__r.RecordType.Name From Change_Manager_Selected_Objects__r)
                                                FROM 
                                                    BudgetHeader__c
                                                WHERE 
                                                    Project__c = :projectId AND Status__c IN :displayStatus
                                                ORDER BY 
                                                    CreatedDate ASC];
        for(BudgetHeader__c budgetHeader : budgetHeaders) {
            if (budgetHeader.WorkAtRisk__c) {
                budgetHeader.Status__c = ECO_DTO_BudgetHeader.STATUS_WORKATRISK;
            }

            ECO_DTO_BudgetHeader dtoBudgetHeader = new ECO_DTO_BudgetHeader(budgetHeader);
            dtoBudgetHeaders.add(dtoBudgetHeader);
        }
    }
    
    public ECO_DTO_BudgetHeaderWrapper(List<BudgetHeader__c> allBudgetHeadersForProject, Boolean showArchived) {
        dtoBudgetHeaders = new List<ECO_DTO_BudgetHeader>();
        
        List <String> displayStatus = displayStatuses(showArchived);

        Set<String> displayStatusSet = new Set<String>(displayStatus);        
        for(budgetHeader__c budgetHeader : allBudgetHeadersForProject ) {
        
            if (displayStatusSet.contains(budgetHeader.Status__c)) {
                ECO_DTO_BudgetHeader dtoBudgetHeader = new ECO_DTO_BudgetHeader(budgetHeader);
                dtoBudgetHeaders.add(dtoBudgetHeader);
            }
        }
    }
}