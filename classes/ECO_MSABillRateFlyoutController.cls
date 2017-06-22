public class ECO_MSABillRateFlyoutController {

	public Id sProjectId {get; set;}
//	public list<BillRate__c> billRates {get;set;}
//	public map<Id,BillRatePeriod__c> billRatePeriodMap {get; set;}
	//public map<String, BillRate__c> billRatePeriodCategoryRateMap {get; set;}
	//public map<String, list<BillRatePeriod__c>> laborCategoryToBillRatePeriodMap;
	//public list<Agreement__c> flyOutAgreements {get; set;}
	//public list<String> msaIds  {get; set;}
	

	
	public ECO_MSABillRateFlyoutController()
	{	
		//billRates = new list<BillRate__c>();	
		//billRatePeriodCategoryRateMap = new map<String, BillRate__c>();
		//billRatePeriodMap = new map<Id,BillRatePeriod__c>();
		//String ProjectIdString = String.ValueOf(ProjectId).substring(0, 15);
		//msaIds = new list<String>();
		
		
/*		for(Agreement__c flyoutAgreement:flyoutAgreements)
		{
			//if(flyoutAgreement.MSAReference__c != null)
				msaIds.add(flyoutAgreement.MSAReference__c);
			//if(flyoutAgreement.MSAReference__c == null || flyoutAgreement.MSAReference__c == '' )
			//{
				
			//}
			//else
				//msaIds.add(flyoutAgreement.MSAReference__c);
		}
		
		if(!msaIds.isEmpty())	
		{
			billRates = [select Id, Name, BillRatePeriod__c, LaborCategory__c, BillRate__c from BillRate__c where Agreement__c = :msaIds[0]];
			billRatePeriodMap = new map<Id,BillRatePeriod__c>([select Id, BillRateStart__c, BillRateEnd__c from BillRatePeriod__c where Agreement__c = :msaIds[0]]);
			for(BillRate__c billRate:billRates)
			{
				if(billRatePeriodCategoryRateMap.get(billRate.BillRatePeriod__c + '-' + billRate.LaborCategory__c) == null)
					billRatePeriodCategoryRateMap.put(billRate.BillRatePeriod__c + '-' + billRate.LaborCategory__c, billRate);
			
				if(laborCategoryToBillRatePeriodMap.get(billRate.LaborCategory__c) == null)
					laborCategoryToBillRatePeriodMap.put(billRate.LaborCategory__c, new list<BillRatePeriod__c>());	
				if(billRate.BillRatePeriod__c != null)
					laborCategoryToBillRatePeriodMap.get(billRate.LaborCategory__c).add(billRatePeriodMap.get(billRate.BillRatePeriod__c));				
			}
		}*/
	}
	
	public class BillRateWrapper
	{
		public set<String> laborCategories {get; set;}
		public list<BillRatePeriod__c> periods {get; set;}
		public map<String, BillRate__c> billRatePeriodCategoryRateMap {get; set;}
	}
	
	public BillRateWrapper getBillRates()
	{
		BillRateWrapper wrapper = new BillRateWrapper();
		
		list<Agreement__c> agreements = [select Id, Name, FundingCurrencyCode__c, MSAReference__c, MSAReference__r.Id, AgreementNumber__c from Agreement__c where Project__r.Id = :sProjectId and MSAReference__c != null];
		list<BillRate__c> billRates = [select Id, Name, BillRatePeriod__c, LaborCategory__c, BillRate__c from BillRate__c where Agreement__c = :agreements[0].MSAReference__c order by BillRatePeriod__r.BillRateStart__c];	
		map<Id,BillRatePeriod__c> billRatePeriodMap = new map<Id,BillRatePeriod__c>([select Id, BillRateStart__c, BillRateEnd__c from BillRatePeriod__c where Agreement__c = :agreements[0].MSAReference__c order by BillRateStart__c]);
		
		map<String, BillRate__c> billRatePeriodCategoryRateMap = new map<String, BillRate__c>();
		map<String, list<BillRatePeriod__c>> laborCategoryToBillRatePeriodMap = new map<String, list<BillRatePeriod__c>>();

		for(BillRate__c billRate:billRates)
		{
			if(billRatePeriodCategoryRateMap.get(billRate.BillRatePeriod__c + '-' + billRate.LaborCategory__c) == null)
				billRatePeriodCategoryRateMap.put(billRate.BillRatePeriod__c + '-' + billRate.LaborCategory__c, billRate);
			
			if(laborCategoryToBillRatePeriodMap.get(billRate.LaborCategory__c) == null)
				laborCategoryToBillRatePeriodMap.put(billRate.LaborCategory__c, new list<BillRatePeriod__c>());	
			if(billRate.BillRatePeriod__c != null)
				laborCategoryToBillRatePeriodMap.get(billRate.LaborCategory__c).add(billRatePeriodMap.get(billRate.BillRatePeriod__c));				
		}
		
		if(billRatePeriodMap.values() != null)
			wrapper.periods = billRatePeriodMap.values();
				
		if(laborCategoryToBillRatePeriodMap.keyset() != null)
			wrapper.laborCategories = laborCategoryToBillRatePeriodMap.keyset();
			
		if(billRatePeriodCategoryRateMap != null)
			wrapper.billRatePeriodCategoryRateMap = billRatePeriodCategoryRateMap;
			
		


		return wrapper;
	}
	
	public list<Agreement__c> getFlyoutAgreements()
	{
		list<Agreement__c> agreements = [select Id, Name, FundingCurrencyCode__c, MSAReference__c, MSAReference__r.Id, AgreementNumber__c from Agreement__c where Project__r.Id = :sProjectId];	
		if(agreements.size() == 0)
			return new list<Agreement__c>();
		return agreements;
	}
	
	//public set<String> getLaborCategories()
	//{
	//	set<String> keysetValues = new set<String>();
	//	if(laborCategoryToBillRatePeriodMap.keyset() != null)
	//		return laborCategoryToBillRatePeriodMap.keyset();
	//	return keysetValues;
	//}	
	
	//public list<BillRatePeriod__c> getPeriods()
	//{
	//	if(billRatePeriodMap.values() != null)
	//		return billRatePeriodMap.values();
	//	return new list<BillRatePeriod__c>();
	//}
}