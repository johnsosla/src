global with sharing class ECO_PMD_Risk_Register_Controller {
	public ECO_PMD_Risk_Register_Controller() {
		
	}

	@RemoteAction
    global static RiskRegister ProjectRiskRegister(String projectNum)
    {
        
        Id projectId = projectNum;
        
		RiskRegister riskreg = new RiskRegister();

		
		try
		{
			Decimal rawTotal = 0;
						//riskreg.risks = [select Id,Name,RiskDescription__c,Project__c , 
			//                        ContingencyDollars__c,RiskScore__c,CurrentStatus__c, CurrencyIsoCode
			//				from Risk__c
			//				where CurrentStatus__c <> 'Cancelled' and CurrentStatus__c <> 'Expired'
			//				and Project__c = :projectId
			//				order by ContingencyDollars__c	desc nulls last,
			//				         RiskScore__c desc nulls last];

			//AggregateResult[] contingency = 
			//[select sum(ContingencyDollars__c)sumd
			//				from Risk__c
			//				where CurrentStatus__c <> 'Cancelled' and CurrentStatus__c <> 'Expired'
			//				and Project__c = :projectId
			//				group by Project__c
			//				having sum(ContingencyDollars__c) > 0
			//	
			riskreg.risks = [select Id,Name,RiskDescription__c,Project__c,PostmitigationContingencyTotal__c,
			                        ContingencyDollars__c,PostMitigationScore__c,CurrentStatus__c,CurrencyIsoCode
							from Risk__c
							where CurrentStatus__c <> 'Cancelled' and CurrentStatus__c <> 'Expired'
							and Project__c = :projectId
							order by PostmitigationContingencyTotal__c	desc nulls last,
							         RiskScore__c desc nulls last];

			AggregateResult[] contingency = 
			[select sum(PostmitigationContingencyTotal__c)sumd
							from Risk__c
							where CurrentStatus__c <> 'Cancelled' and CurrentStatus__c <> 'Expired'
							and Project__c = :projectId
							group by Project__c
							having sum(PostmitigationContingencyTotal__c) > 0
							limit 1];

			if (contingency.size()>0) {
			    rawTotal = (Decimal)contingency[0].get('sumd');
			}

			Decimal conversionRate = [SELECT conversionrate FROM currencytype 
						                       WHERE isocode = :riskreg.risks[0].CurrencyIsoCode LIMIT 1].conversionRate;

			riskreg.conversionRate = conversionRate;
			riskreg.total = rawTotal * conversionRate;                                 
		}
		catch (Exception ex)
		{
			riskreg.error = ex.getMessage() + ' ' + ex.getLineNumber();
            riskreg.nodata = true;

		}
        return riskreg;
    }
    
    global class RiskRegister
	{
		public RiskRegister()
		{

			risks = null;
            total = 0;
            error = '';
            nodata = false;
		}
		public String error;
        public Boolean nodata;
		List<Risk__c> risks;
		Decimal total;
		Decimal conversionRate;
	}    
}