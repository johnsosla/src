public with sharing class ECO_EarnedValueDto {
	public transient Date periodStartDate {get; set;}
    public transient String periodStartDateStr {get; set;}

	public transient Decimal estimatedCost {get; set;}
	public transient Decimal approvedCost {get; set;}
	public transient Decimal earnedValue {get; set;}
	public transient Decimal actualCost {get; set;}
    public transient Decimal accruedCost {get; set;}
	public transient Decimal estimatedCostCumulative {get; set;}
	public transient Decimal approvedCostCumulative {get; set;}
	public transient Decimal actualCostCumulative {get; set;}
    // no such thing as earnedValueCumulative nor accruedCostCumulative
	public transient Decimal cpi {get; set;}
	public transient Decimal spi {get; set;}
	public transient Boolean committed {get; set;}
	public transient String evString {get; set;}
	public transient String actualCostString {get; set;}
	public transient String percentCompleteString {get; set;}
	public transient Decimal percentComplete {get; set;}
    public transient Decimal lastCommittedEarnedValue {get; set;}
    public transient String fiscalMonth     { get; set; }  //DJO 4/27/2016
    public transient String currencyIsoCode { get; set; }  //DJO 4/27/2016
    
    public WeeklyRollupEntry__c oWeeklyRollupEntry {get; set;}

    public transient Boolean showData {get; set;}
    public transient Boolean isAfterToday {get; set;}

	public ECO_EarnedValueDto(WeeklyRollupEntry__c entry, Boolean committed) {
		this.committed = committed;

        oWeeklyRollupEntry = entry;
        
		periodStartDate = entry.PeriodStartDate__c.addDays(6);
        periodStartDateStr = periodStartDate.format();  // for Locale

        estimatedCost = (entry.AppliedEstimatedCost__c != null) ? entry.AppliedEstimatedCost__c : 0;
        approvedCost = (entry.AppliedApprovedCost__c != null) ? entry.AppliedApprovedCost__c : 0;
        earnedValue = (entry.EarnedValue__c != null) ? entry.EarnedValue__c : 0;
        //actualCost = (entry.AppliedAcctBurdenedCost__c != null) ? entry.AppliedAcctBurdenedCost__c : 0;
        actualCost = (entry.ProjectFunctionalBurdenedCost__c != null) ? entry.ProjectFunctionalBurdenedCost__c : 0;
        accruedCost = (entry.CostAccruals__c != null) ? entry.CostAccruals__c : 0;

        // CPI__c and SPI__c deprecated on WeeklyRollupEntry Oct 2016
        // now should be computed by the ITD accumulation routines
        cpi = 0.0d;
        spi = 0.0d;
        //cpi = (entry.CPI__c != null) ? entry.CPI__c : 0;
        //spi = (entry.SPI__c != null) ? entry.SPI__c : 0;

        evString = (committed) ? String.valueOf(earnedValue) : 'null';    

        if (committed) {
        	Decimal percent = 0;
            if(entry.Project__r.TotalApprovedCost__c != 0 && entry.Project__r.TotalApprovedCost__c != null){
            	percent = earnedValue / entry.Project__r.TotalApprovedCost__c * 100.0;
            }
            
        	percent = percent.setScale(2);

        	percentCompleteString = String.valueOf(percent) + '%';
        	percentComplete = percent;
        } else {
        	percentCompleteString = '';
        }

        showData = ((periodStartDate <= Date.today()) && (committed || (actualCost > 0)));
        isAfterToday = (periodStartDate > Date.today());

        actualCostString = showData ? String.valueOf(actualCost) : 'null';

        //DJO 4/27/2016
        fiscalMonth = entry.FiscalMonth__c;  
        currencyIsoCode = entry.CurrencyIsoCode;
	}
}