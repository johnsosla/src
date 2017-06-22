public class ECO_BillRateManagement {
	
	String agreementId = '';
	public list<BillRate__c> billRates {get;set;}
	public Map<Id, String> laborCategoryMap {get; set;}

	public BillRate__c newBillRate {get; set;}
	public BillRateLaborCategory__c newLaborCategory {get; set;}
	public BillRate__c updateBillRate {get; set;}

	public BillRatePeriod__c newBillRatePeriod {get; set;}
	public Boolean creatingNewBillRatePeriod {get; set;}
	public Boolean creatingNewBillRate {get; set;}
	public Agreement__c agreement {get;set;}
	public map<String, list<BillRatePeriod__c>> laborCategoryToBillRatePeriodMap;
	public map<Id,BillRatePeriod__c> billRatePeriodMap;
	//public map<String, list<BillRate__c>> laborCategoryBillRateMap {get; set;}
	public map<String, BillRate__c> billRatePeriodCategoryRateMap {get; set;}
	public String updatedKey {get; set;}
	public Decimal updatedValue {get; set;}
	public String laborCategoryToDelete {get; set;}
	public String billRatePeriodToDelete {get; set;}
	
	public ECO_BillRateManagement()
	{
		agreementId = ApexPages.currentPage().getParameters().get('AgreementId');

		init();
	}

	/**
     * initializes bill rate objects to be displayed on the bill rate page for msa
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    May 2016
     *
     * @param   none
     * @return  void
     **/
	public void init()
	{
		billRatePeriodCategoryRateMap = new map<String, BillRate__c>();
		laborCategoryToBillRatePeriodMap = new map<String, list<BillRatePeriod__c>>();
		laborCategoryMap = new Map<Id, String>();

		agreement = [select Id, Name, ContractTitle__c, FundingCurrencyCode__c, AgreementNumber__c from Agreement__c where Id = :agreementId];
		billRates = [select Id, Name, BillRatePeriod__c, LaborCategory__c, BillRate__c, BillRateNew__c, BillRateLaborCategory__c from BillRate__c where Agreement__c = :agreement.Id];
		for(BillRateLaborCategory__c laborCategory:[select Id, Name from BillRateLaborCategory__c where Agreement__c = :agreement.Id])
		{
			laborCategoryMap.put(laborCategory.Id, laborCategory.Name);
		}

		billRatePeriodMap = new map<Id,BillRatePeriod__c>([select Id, BillRateStart__c, BillRateEnd__c from BillRatePeriod__c where Agreement__c = :agreement.Id]);
		for(BillRate__c billRate:billRates)
		{
			if(billRatePeriodCategoryRateMap.get(billRate.BillRatePeriod__c + '-' + billRate.BillRateLaborCategory__c) == null)
				billRatePeriodCategoryRateMap.put(billRate.BillRatePeriod__c + '-' + billRate.BillRateLaborCategory__c, billRate);
			
			if(laborCategoryToBillRatePeriodMap.get(billRate.BillRateLaborCategory__c) == null)
				laborCategoryToBillRatePeriodMap.put(billRate.BillRateLaborCategory__c, new list<BillRatePeriod__c>());	
			if(billRate.BillRatePeriod__c != null)
				laborCategoryToBillRatePeriodMap.get(billRate.BillRateLaborCategory__c).add(billRatePeriodMap.get(billRate.BillRatePeriod__c));		
		}
		creatingNewBillRate = false;
		creatingNewBillRatePeriod = false;		
	}

	/**
     * deletes labor category for msa bill rates
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    May 2016
     *
     * @param   none
     * @return  PageReference
     **/
	public PageReference deleteLaborCategory()
	{
		List<BillRateLaborCategory__c> billRateCategory = [select Id from BillRateLaborCategory__c where Id = :laborCategoryToDelete];

		if(!billRateCategory.isEmpty())
		{
			try{
				delete billRateCategory;	
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.formatPageError(e, 'Problem Deleting Labor Category');
				return null;
			}
		}

		init();

		return null;
	}

	/**
     * deletes bill rate period for msa bill rates
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    May 2016
     *
     * @param   none
     * @return  PageReference
     **/
	public PageReference deleteBillRatePeriod()
	{
		List<BillRatePeriod__c> billRatePeriodsToDelete = [select Id from BillRatePeriod__c where Id = :billRatePeriodToDelete];

		if(!billRatePeriodsToDelete.isEmpty())
		{
			try{
				delete billRatePeriodsToDelete;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.formatPageError(e, 'Problem Deleting Bill Rate Period');
				return null;
			}
		}

		init();

		return null;
	}

	/**
     * create a new bill rate labor category
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    May 2016
     *
     * @param   none
     * @return  void
     **/
	public void createNewLaborCategory()
	{
		newLaborCategory = new BillRateLaborCategory__c(Agreement__c = agreement.Id);
	}


	/**
     * saves new labor category.  will also create the associated bill rates for each of the existing bill rate
     * periods
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    May 2016
     *
     * @param   none
     * @return  PageReference
     **/
	public PageReference saveNewLaborCategory()
	{
		try
		{
			insert newLaborCategory;
		}
		catch(Exception e)
		{
			ECO_Service_ErrorLog.formatPageError(e, 'Problem saving new Labor Category');
			return null;
		}

		List<BillRate__c> lBillRates = new List<BillRate__c>();
		List<BillRatePeriod__c> billRatePeriods = [select Id from BillRatePeriod__c where Agreement__c = :agreement.Id];

		for(BillRatePeriod__c billRatePeriod:billRatePeriods)
		{
			newBillRate = new BillRate__c();
			newBillRate.BillRate__c = 0;
			newBillRate.BillRatePeriod__c = billRatePeriod.Id;
			newBillRate.BillRateLaborCategory__c = newLaborCategory.Id;
			newBillRate.Agreement__c = agreement.Id;	
			lBillRates.add(newBillRate);			
		}

		if(!lBillRates.isEmpty())
		{
			try
			{
				insert lBillRates;
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.formatPageError(e, 'Problem saving bill reates for new labor category');
				return null;
			}
		}

		init();

		return null;
	}

	/**
     * DEPRECATE - create new bill rate, no longer used
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    May 2016
     *
     * @param   none
     * @return  void
     **/
	public void createNewBillRate()
	{
		newBillRate = new BillRate__c(Agreement__c = agreementId);		
	}
	
	/**
     * create new bill rate period
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    May 2016
     *
     * @param   none
     * @return  void
     **/
	public void createNewBillRatePeriod()
	{
		newBillRatePeriod = new BillRatePeriod__c(Agreement__c = agreement.Id);	
	}	
	
	/**
     * return to related agreement
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    May 2016
     *
     * @param   none
     * @return  PageReference
     **/
	public PageReference returnToAgreement()
	{
		return new PageReference('/apex/ECO_AgreementView?Id=' + agreement.Id);
	}
	

	/**
     * update the bill rate that was modified on the page
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    May 2016
     *
     * @param   none
     * @return  void
     **/
	public void updateBillRateApex()
	{
		if(billRatePeriodCategoryRateMap.get(updatedKey) != null)
			billRatePeriodCategoryRateMap.get(updatedKey).BillRate__c = updatedValue;
	}
	
	/**
     * set flag that no longer creating new bill rate
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    May 2016
     *
     * @param   none
     * @return  void
     **/
	public void cancelNewBillRate()
	{
		creatingNewBillRate = false;
	}
	
	/*public void saveNewBillRate()
	{
		if(billRatePeriodMap.values().size() == 0)
			insert newBillRate;
		else
		{
			string laborCategory = newBillRate.LaborCategory__c;
			list<BillRate__c> lBillRates = new list<BillRate__c>();
			for(BillRatePeriod__c lbillRatePeriod:billRatePeriodMap.values())
			{
				newBillRate.BillRate__c = 0;
				newBillRate.BillRatePeriod__c = lbillRatePeriod.Id;
				lBillRates.add(newBillRate);
				if(laborCategoryToBillRatePeriodMap.get(newBillRate.LaborCategory__c)==null)
					laborCategoryToBillRatePeriodMap.put(newBillRate.LaborCategory__c, new list<BillRatePeriod__c>());
				laborCategoryToBillRatePeriodMap.get(newBillRate.LaborCategory__c).add(lbillRatePeriod);

				//if(laborCategoryBillRateMap.get(newBillRate.LaborCategory__c)==null)
				//	laborCategoryBillRateMap.put(newBillRate.LaborCategory__c, new list<BillRate__c>());
				//laborCategoryBillRateMap.get(newBillRate.LaborCategory__c).add(newBillRate);
				billRatePeriodCategoryRateMap.put(lbillRatePeriod.Id +'-' + laborCategory, newBillRate);	
				newBillRate = new BillRate__c(Agreement__c = agreementId, LaborCategory__c = laborCategory);					
			}
			if(lBillRates.size() > 0)
				upsert lBillRates;
		}				
		creatingNewBillRate = false;
	}*/
	
	/**
     * return set of labor categories related to the msa
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    May 2016
     *
     * @param   none
     * @return  Set of String
     **/
	public Set<String> getLaborCategories()
	{
		Set<String> keysetValues = new Set<String>();
		if(laborCategoryToBillRatePeriodMap.keyset() != null)
			return laborCategoryToBillRatePeriodMap.keyset();
		return keysetValues;
	}
	
	/**
     * returns list of bill rate periods
     *
     * @Author  NTT Data - Brent Kendall - brent.kendall@nttdata.com
     * @Date    May 2016
     *
     * @param   none
     * @return  List of BillRatePeriod__c
     **/
	public List<BillRatePeriod__c> getPeriods()
	{
		if(billRatePeriodMap.values() != null)
			return billRatePeriodMap.values();
		return new List<BillRatePeriod__c>();
	}
	
	public PageReference saveBillRates()
	{
		try{
			update billRatePeriodCategoryRateMap.values();
		}
		catch(Exception e)
		{
			ECO_Service_ErrorLog.formatPageError(e, 'Problem saving new Bill Rate Period');
			return null;	
		}

		return null;
	}
	
	public void cancelNewBillRatePeriod()
	{
		creatingNewBillRatePeriod = false;
	}
	
	public PageReference saveNewBillRatePeriod()
	{
		try{
			insert newBillRatePeriod;
		}
		catch(Exception e)
		{
			ECO_Service_ErrorLog.formatPageError(e, 'Problem saving new Bill Rate Period');
			return null;	
		}

		List<BillRate__c> lBillRates = new List<BillRate__c>();
		for(BillRateLaborCategory__c laborCategory:[select Id from BillRateLaborCategory__c where Agreement__c = :agreement.Id])
		{
			newBillRate = new BillRate__c(Agreement__c = agreement.Id, BillRatePeriod__c = newBillRatePeriod.Id, BillRateLaborCategory__c = laborCategory.Id, BillRate__c = 0);
			lBillRates.add(newBillRate);
		}	
		if(!lBillRates.isEmpty())
		{
			try{
				insert lBillRates;	
			}
			catch(Exception e)
			{
				ECO_Service_ErrorLog.formatPageError(e, 'Problem saving new Bill Rates for new bill rate period.');
				return null;
			}
		}

		init();
				
		creatingNewBillRatePeriod = false;	

		return null;
	}	
}