public class ECO_PMD_EarnedValueChart_Controller {

     public ECO_PMD_EarnedValueChart_Controller(){}
    
    @RemoteAction
    public static EarnedValueDetails ProjectSnapshot(String projectNum)
    {
        Id projectId = projectNum;
        EarnedValueDetails results = new EarnedValueDetails();
        ECO_EarnedValueDTO_local earnedValueDto;
        try {
            pse__Proj__c project = [
                SELECT id, pse__End_Date__c, RevisedEndDate__c 
                FROM pse__Proj__c 
                WHERE id = :projectId LIMIT 1];
            earnedValueDto = new ECO_EarnedValueDTO_local(projectId);
            results.currencyCode = earnedValueDto.currencyIsoCode;
            results.earnedValueData = earnedValueDto.evMonths.values();
            results.mostRecent = earnedValueDto.mostRecentMonth;
            results.scheduleDaysVariance = project.RevisedEndDate__c.daysBetween( project.pse__End_Date__c);
        }
        catch (Exception ex){
            results.error = ex.getMessage() + ' ' + ex.getLineNumber();
            results.nodata = true;
        }
        return results;
    }

    public class EarnedValueDetails{ 
        public EarnedValueDetails()
        {
            error = '';
            nodata = false;
            currencyCode = '';
            earnedValueData = null;
            mostRecent = new EarnedValueMonth();
        }     
        public String error;
        public Boolean nodata;
        public String currencyCode;
        public Integer scheduleDaysVariance;
        public EarnedValueMonth mostRecent;

        public List<EarnedValueMonth>  earnedValueData;
    }

    /*
        // ECO_EarnedValueDto:[
        //  actualCost=0.00, actualCostCumulative=0.00, actualCostString=null
        //, approvedCost=4569.73, approvedCostCumulative=4569.73
        //, committed=false, cpi=0, earnedValue=0
        //, estimatedCost=4569.73, estimatedCostCumulative=4569.73
        //, evString=null, isAfterToday=false
        //, lastCommittedEarnedValue=0
        //, oWeeklyRollupEntry=WeeklyRollupEntry__c:{Id=a70180000008g2hAAA, PeriodStartDate__c=2015-10-17 00:00:00
        //                                          , AppliedEstimatedCost__c=4569.73, AppliedAcctBurdenedCost__c=0.00
        //                                          , AppliedAcctRawCost__c=0.00, ProjectFunctionalBurdenedCost__c=0.00
        //                                          , AppliedApprovedCost__c=4569.73, CPI__c=0.0, SPI__c=0.0
        //                                          , CompositeKey__c=a321800000055nfAAA__2015-WK43
        //                                          , ApprovedCost__c=4569.73, Project__c=a321800000055nfAAA, CurrencyIsoCode=NZD}
        //, percentComplete=null, percentCompleteString=, periodStartDate=2015-10-23 00:00:00, showData=false, spi=0E+2]
    */

    public class ECO_EarnedValueDTO_local {

        public List<ECO_EarnedValueDTO> evWeeks {get;set;}
        public Map<String,EarnedValueMonth> evMonths {get;set;}
        public EarnedValueMonth mostRecentMonth {get;set;}
        public String currencyIsoCode {get;set;}
        
        public ECO_EarnedValueDTO_local() {
            // use this in bulkified comsumer 
            // -- use initialize to pass in WRE and EVH for this project
            // -- use getWRE and getEVH( list<Id> ) to get all the related WRE and EVH with the right fields
            //    then pass back in the ones
        }
        public ECO_EarnedValueDTO_local(String sProjectId) {
            ECO_EarnedValueFlyoutController ctrl = new ECO_EarnedValueFlyoutController();
            ctrl.sProjectId = sProjectId;
            ctrl.reload(true);
            evWeeks = ctrl.values;
            if ( evWeeks!=null && evWeeks[0]!=null && evWeeks[0].oWeeklyRollupEntry !=null)
                currencyIsoCode = evWeeks[0].CurrencyISOCode;
            evMonths = new Map<String,EarnedValueMonth>();
            calculateEarnedValueSeries(ctrl.values, evMonths);
        }
        private void calculateEarnedValueSeries(List<ECO_EarnedValueDTO> evWeeks, Map<String,EarnedValueMonth> evMonths) {
            if (evWeeks==null)
                return;
            for (ECO_EarnedValueDTO evWeek:evWeeks) {
                String wreFiscalMonth;
                wreFiscalMonth = evWeek.fiscalMonth;
                if (evMonths == null)
                    evMonths = new Map<String, EarnedValueMonth>();
                if (!evMonths.keySet().contains(wreFiscalMonth))
                    evMonths.put(wreFiscalMonth, new EarnedValueMonth());
                EarnedValueMonth evMonth = evMonths.get(wreFiscalMonth);
                evMonth.FiscalMonth = wreFiscalMonth;
                evMonth.ThruWeekending = evWeek.periodStartDate; // in ECO_EarnedValueDTO, the periodStartDate value is in fact period end .addDays(6);
                evMonth.PlannedITD = evWeek.approvedCostCumulative;
                evMonth.EstimatedITD = evWeek.estimatedCostCumulative;
                evMonth.EarnedValueLastCommitted = evWeek.lastCommittedEarnedValue;
                if (evWeek.committed != null && evWeek.committed )
                    evMonth.EarnedITD = evWeek.earnedValue;
                if (!evWeek.isAfterToday){
                    evMonth.ActualITD = evWeek.actualCostCumulative;
                    evMonth.CPI = evWeek.cpi;
                    evMonth.SPI = evWeek.spi;
                    mostRecentMonth = evMonth;
                }
            }
        }
    }

    public class EarnedValueMonth{
        
        public String FiscalMonth {get; set;}
        public Date ThruWeekending {get; set;}
        public Decimal PlannedITD {get; set;}
        public Decimal EstimatedITD {get; set;}
        public Decimal EarnedITD {get; set;}   
        public Decimal ActualITD {get; set;}
        public Decimal EarnedValueLastCommitted {get;set;}
        public Decimal CPI {get; set;}
        public Decimal SPI {get; set;}

        public EarnedValueMonth()
        {
            PlannedITD = 0;
            EstimatedITD = null;
            EarnedITD = null;
            ActualITD = null;
            EarnedValueLastCommitted = null;
            CPI = null;
            SPI = null;
        }     
    }
}