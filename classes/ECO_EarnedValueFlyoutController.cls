/** ------------------------------------------------------------------------------------------------------
* @Description 
*
* @Author      NTT Data - Graham MacRobie, Deborah Orth
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_EarnedValueFlyoutController {
    public List<WeeklyRollupEntry__c> lWeeklyRollupEntries {get; set;}
    Transient public String chartData {get; set;}  //DJO 4/22/2016
    Transient public String chartData2 {get; set;} //DJO 4/22/2016

    Transient public List<ECO_EarnedValueDto> values {get; set;} //DJO 4/22/2016

    public Decimal plannedCostTotal {get; set;}
    public Decimal cashInTotal {get; set;}
    public Decimal percentageMargin {get; set;}

    public id sProjectId {
        get;

        set {
            sProjectId = value;

            reload(false);
        }
    }

    /**
     * @Description 
     *
     * @Author  NTT Data - Graham MacRobie, Deborah Orth
     * @Date    2015
     *
     * @param    
     * @return     
     **/
    public void reload(Boolean force) {
        plannedCostTotal = 0;
        cashInTotal = 0;
        percentageMargin = 0;
        
        if ((lWeeklyRollupEntries == null) || force) {
            lWeeklyRollupEntries = new list<WeeklyRollupEntry__c>([
                SELECT Id
                     , PeriodStartDate__c
                     , FiscalMonth__c 
                     , AppliedEstimatedCost__c
                     //, AppliedRevenue__c DJO 4/23/2016
                     //, AppliedAcctBurdenedCost__c DJO 4/23/2016
                     //, AppliedAcctRawCost__c DJO 4/23/2016
                     , ProjectFunctionalBurdenedCost__c
                     , AppliedApprovedCost__c
                     , CostAccruals__c
                     , EarnedValue__c
                     , CPI__c
                     , SPI__c
                     //, CompositeKey__c
                     , OverrideApprovedCost__c 
                     , OverrideRevenue__c 
                     , ApprovedCost__c 
                     , Project__r.PercentageMargin__c
                     , Project__r.TotalApprovedCost__c
                     , Revenue__c 
                     , CurrencyIsoCode
                FROM WeeklyRollupEntry__c
                WHERE
                    Project__c = :sProjectId
                ORDER BY
//                    CompositeKey__c ASC]);
                    PeriodStartDate__c ASC]);
        }

        List<EarnedValueHeader__c> headers = [select id, SnapshotDate__c, Committed__c from EarnedValueHeader__c where Project__c = :sProjectId];

        Map<Date, Boolean> committedMap = new Map<Date, Boolean>();

        for (EarnedValueHeader__c header : headers) {
//            committedMap.put(header.SnapshotDate__c.addDays(-1), header.Committed__c);
            committedMap.put(ECO_Service_Snapshots.getFirstDateOfWeek(header.SnapshotDate__c), header.Committed__c);
        }

        
        
//        chartData += '["Week", "Planned", "Estimate", "Actual", "Earned Value"],';
        
        chartData2 = '[';
        chartData = '[';
//        chartData2 += '["Week", "CPI", "SPI"],';
        
        Decimal estimatedCostCumm = 0;
        Decimal approvedCostCumm = 0;
        Decimal actualCostCumm = 0;
        // no accruedCostCum

        values = new List<ECO_EarnedValueDto>();
        
        system.debug('chartData: ' + chartData);

        Decimal lastCommittedEarnedValue = 0;

        for (WeeklyRollupEntry__c entry : lWeeklyRollupEntries) {
            // TODO - not sure why this was forced to true, but I'm putting it back to a lookup - GM - 4/18/2016
            //Boolean committed = true;  // committedMap.get(entry.PeriodStartDate__c);
            Boolean committed = committedMap.get(ECO_Service_Snapshots.getFirstDateOfWeek(entry.PeriodStartDate__c));

            System.debug('committed - ' + committed);
            System.debug('period start date - ' + entry.PeriodStartDate__c);
            System.debug('first date period start date - ' + ECO_Service_Snapshots.getFirstDateOfWeek(entry.PeriodStartDate__c));

            if (committed == null)
                committed = false;

            ECO_EarnedValueDto evdto = new ECO_EarnedValueDto(entry, committed);
            values.add(evdto);

            system.debug('___evdto before: ' + evdto);
            
            Decimal estimatedCost = evdto.estimatedCost;
            Decimal approvedCost = evdto.approvedCost;
            Decimal earnedValue = evdto.earnedValue;
            Decimal actualCost = evdto.actualCost;
            Decimal accruedCost = evdto.accruedCost;

            if (committed)
                lastCommittedEarnedValue = earnedValue;
            
            //System.debug('weeklyrollupentry - ' + entry.id);
            //System.debug('earnedvalue - ' + entry.EarnedValue__c);

            estimatedCostCumm += estimatedCost;
            approvedCostCumm += approvedCost;
            actualCostCumm += actualCost;

            evdto.estimatedCostCumulative = estimatedCostCumm;
            evdto.approvedCostCumulative = approvedCostCumm;
            evdto.actualCostCumulative = actualCostCumm;
            evdto.lastCommittedEarnedValue = lastCommittedEarnedValue;

            String evString = evdto.evString;

            Date periodStartDate = entry.PeriodStartDate__c.addDays(6);
            evdto.periodStartDateStr = periodStartDate.format(); // for Locale specific

            String actualCostCummString = (periodStartDate <= Date.today()) ? String.valueOf(actualCostCumm) : 'null';

            Decimal actualCostITDWithWeeksAccrualIfAny = actualCostCumm + accruedCost;
            Decimal cpiValue = ((actualCostITDWithWeeksAccrualIfAny > 0) && (lastCommittedEarnedValue != null)) ? (lastCommittedEarnedValue / actualCostITDWithWeeksAccrualIfAny) : 0;
            Decimal spiValue = ((approvedCostCumm > 0) && (lastCommittedEarnedValue != null)) ? (lastCommittedEarnedValue / approvedCostCumm) : 0;

            evdto.cpi = cpiValue;
            evdto.spi = spiValue;

            String cpiString = (periodStartDate <= Date.today()) ? String.valueOf(cpiValue) : 'null';
            String spiString = (periodStartDate <= Date.today()) ? String.valueOf(spiValue) : 'null';
            String accrualString = accruedCost != 0 ? accruedCost.toPlainString() : '';

            evString = (evdto.isAfterToday) ? 'null' : String.valueOf(lastCommittedEarnedValue);

            // chartData += '["' + entry.PeriodStartDate__c.format() + '", ' + approvedCostCumm + ', ' + estimatedCostCumm + ', ' + evdto.actualCostString + ', ' + evString + '],';
            
            // google chart data for planned value chart
            chartData += '["' + periodStartDate.format() + '", ' + approvedCostCumm + ', ' + estimatedCostCumm + ', ' + actualCostCummString + ', ' + evString + '],';
            
            // google chart data for cpi/spi chart
            chartData2 += '["' + periodStartDate.format() + '", ' + cpiString + ', ' + spiString + '],';
                        
            plannedCostTotal += (entry.ApprovedCost__c != null) ? entry.ApprovedCost__c : 0;            

            system.debug('___evdto after: ' + evdto);
        }

        chartData = chartData.substringBeforeLast(',');
        chartData2 = chartData2.substringBeforeLast(',');
        
        chartData += ']';
        chartData2 += ']';
        
        system.debug('chartData: ' + chartData);
    }

    /**
     * @Description 
     *
     * @Author  NTT Data - Graham MacRobie, Deborah Orth
     * @Date    2015
     *
     * @param    
     * @return     
     **/
    public PageReference save() {
        //list<WeeklyRollupEntry__c> lWeeklyRollupEntriesToUpdate = new list<WeeklyRollupEntry__c>();
        for (WeeklyRollupEntry__c entry : lWeeklyRollupEntries) {
            if ((entry.OverrideApprovedCost__c != null) && (entry.OverrideApprovedCost__c < 0))
                entry.OverrideApprovedCost__c = null;
        }
        
        //update lWeeklyRollupEntriesToUpdate;
        try {
           update lWeeklyRollupEntries;
        } catch (Exception e){
            ECO_Service_ErrorLog.logException(e);
        }

        reload(true);

        return null;
    }

    /**
     * @Description 
     *
     * @Author  NTT Data - Graham MacRobie, Deborah Orth
     * @Date    2015
     *
     * @param    
     * @return     
     **/
    public PageReference clearAllOverrides() {
        for (WeeklyRollupEntry__c entry : lWeeklyRollupEntries) {
            entry.OverrideApprovedCost__c = null;
            entry.OverrideRevenue__c = null;
        }

        try {
            update lWeeklyRollupEntries;
        } catch (Exception e){
            ECO_Service_ErrorLog.logException(e);
        }

        reload(true);

        return null;
    }
}