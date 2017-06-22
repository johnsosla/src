/** ------------------------------------------------------------------------------------------------------
* @Description The service class provides exchange rate queries
*
* @Author      NTT Data - 
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
public  class ECO_Service_ExchangeRate {

	private static map<Id, DatedConversionRate> dcrIdToDcrMap;
	private static map<String, List<DatedConversionRate>> isoCodeToDcrMap;
	private static Map<String, List<DatedExchangeRate__c>> isoCodeToDCRMapCustomDatedExchange;
	private static Map<string, CurrencyType> isoCodeToCurrencyType;
	private static String defaultOrgCurrency;

	/**
	 *
	 * @Author  NTT Data
	 * @Date    July 2016
	 *
	 **/
	public static void getCodeMap() {
		isoCodeToDcrMap = new Map<String, List<DatedConversionRate>>();
		List <DatedConversionRate> dcrs = [select id, isoCode, conversionrate, nextStartDate, startDate from DatedConversionRate];
		
		for (DatedConversionRate dcr : dcrs) {
			List<DatedConversionRate> isoDcr = isoCodeToDcrMap.get(dcr.isoCode);

			if (isoDcr == null) {
				isoDcr = new List<DatedConversionRate>();
				isoCodeToDcrMap.put(dcr.isoCode, isoDcr);
			}

			isoDcr.add(dcr);
		}	             
	}

	/**
	 *
	 * @Author  NTT Data
	 * @Date    July 2016
	 *
	 **/
	public static void getCodeMapCustomDatedExchange(Set<String> isoCodes) {
		
		List <DatedExchangeRate__c> dcrs = [select id, isoCode__c, conversionrate__c, nextStartDate__c, startDate__c from DatedExchangeRate__c where isoCode__c in :isoCodes order by StartDate__c desc];
		
		for (DatedExchangeRate__c dcr : dcrs) {
			List<DatedExchangeRate__c> isoDcr = isoCodeToDCRMapCustomDatedExchange.get(dcr.isoCode__c);

			if (isoDcr == null) {
				isoDcr = new List<DatedExchangeRate__c>();
				isoCodeToDCRMapCustomDatedExchange.put(dcr.isoCode__c, isoDcr);
			}

			isoDcr.add(dcr);
		}	             
	}	

	/**
	 *
	 * @Author  NTT Data
	 * @Date    July 2016
	 *
	 **/
	public static String getDefaultOrgCurrency()
	{
		List<CurrencyType> currencyType = [select Id, IsoCode from CurrencyType where IsActive=true and IsCorporate =true];

		if(!currencyType.isEmpty())
			return currencyType[0].IsoCode;
		return 'USD';
	}

	/**
	 * Create a planned currency map
	 *
	 * @Author  NTT Data
	 * @Date    July 2016
	 *
	 **/
	public static void setPlannedCurrency(){

		if(isoCodeToCurrencyType != null){
			return;
		} else {
			isoCodeToCurrencyType = new Map<string, CurrencyType>();
		}

		for(CurrencyType currencyType: [select Id, IsoCode, ConversionRate from CurrencyType]){
			isoCodeToCurrencyType.put(currencyType.IsoCode, currencyType);
		}
	}

	/**
	 * Get Exchange Rate between two planned currencies
	 *
	 * @Author  NTT Data
	 * @Date    July 2016
	 *
	 **/
	public static Decimal getPlannedExchangeRate(String orginCurrencyCode, String destCurrencyCode)
	{
		System.Debug('Orgin Currency Code ' + orginCurrencyCode);
		System.Debug('Destination Currency Code ' + destCurrencyCode);


		if(orginCurrencyCode == destCurrencyCode)
		{
			System.Debug('Returning 1 for Currency');
			return 1;
		}

		setPlannedCurrency();


		if(isoCodeToCurrencyType.containskey(orginCurrencyCode) && isoCodeToCurrencyType.containskey(destCurrencyCode)){

			decimal originalRate = isoCodeToCurrencyType.get(orginCurrencyCode).ConversionRate;
			decimal destinationRate = isoCodeToCurrencyType.get(destCurrencyCode).ConversionRate;

			if(originalRate == null || originalRate == 0 || destinationRate == null || destinationRate == 0){
				System.Debug('Returning 1 for Currency due to missing planned rate for ' + orginCurrencyCode + ' or ' + destCurrencyCode);
				return 1;
			}

			decimal returnRate = (1/originalRate) * destinationRate;

			system.debug('Returning ' + returnRate + ' conversion between ' + orginCurrencyCode + ' and ' + destCurrencyCode + '( ' + originalRate + ' , ' + destinationRate + ' )');
			return returnRate;

		} else {
			System.Debug('Returning 1 for Currency due to missing ISOCode');
			return 1;
		}

	}	

	/**
	 * Get Exchange Rate conversion details between two currencies
	 *
	 * @Author  NTT Data
	 * @Date    July 2016
	 *
	 **/
	public static string getPlannedExchangeRateStringForMessage(String orginCurrencyCode, String destCurrencyCode)
	{
		System.Debug('Orgin Currency Code ' + orginCurrencyCode);
		System.Debug('Destination Currency Code ' + destCurrencyCode);

		string returnString = orginCurrencyCode + '-->' + destCurrencyCode + ': ';

		if(orginCurrencyCode == destCurrencyCode)
		{
			System.Debug('Returning 1 for Currency');
			return returnString + '1';
		}

		setPlannedCurrency();


		if(isoCodeToCurrencyType.containskey(orginCurrencyCode) && isoCodeToCurrencyType.containskey(destCurrencyCode)){

			decimal originalRate = isoCodeToCurrencyType.get(orginCurrencyCode).ConversionRate;
			decimal destinationRate = isoCodeToCurrencyType.get(destCurrencyCode).ConversionRate;

			if(originalRate == null || originalRate == 0 || destinationRate == null || destinationRate == 0){
				System.Debug('Returning 1 for Currency due to missing planned rate for ' + orginCurrencyCode + ' or ' + destCurrencyCode);
				return returnString + 'Returning 1 for Currency due to missing planned rate for ' + orginCurrencyCode + ' or ' + destCurrencyCode;
			}

			decimal returnRate = (1/originalRate) * destinationRate;

			system.debug('Returning ' + returnRate.setscale(6) + ' conversion between ' + orginCurrencyCode + ' and ' + destCurrencyCode + '( ' + originalRate + ' , ' + destinationRate + ' )');
			return returnString + returnRate.setscale(6) + '   (1/' + originalRate + ') * ' + destinationRate;

		} else {
			System.Debug('Returning 1 for Currency due to missing ISOCode');
			return returnString + '1';
		}

	}	

	/**
	 *
	 * @Author  NTT Data
	 * @Date    July 2016
	 *
	 **/
	public static Decimal getExchangeRate(String orginCurrencyCode, String destCurrencyCode, Date conversionDate)
	{
		System.Debug('Orgin Currency Code ' + orginCurrencyCode);
		System.Debug('Destination Currency Code ' + destCurrencyCode);

		if(defaultOrgCurrency == null)
			defaultOrgCurrency = getDefaultOrgCurrency();

		if(orginCurrencyCode == destCurrencyCode)
		{
			System.Debug('Returning 1 for Currency');
			return 1;
		}

		Set<String> isoCodesToConvert = new Set<String>();
		if(isoCodeToDCRMapCustomDatedExchange == null)
		{
			isoCodeToDCRMapCustomDatedExchange = new Map<String, List<DatedExchangeRate__c>>();
			isoCodeToDCRMapCustomDatedExchange.put(defaultOrgCurrency, new List<DatedExchangeRate__c>());
			isoCodeToDCRMapCustomDatedExchange.get(defaultOrgCurrency).add(new DatedExchangeRate__c(IsoCode__c = defaultOrgCurrency, StartDate__c = Date.today().addYears(-100), ConversionRate__c = 1));
			isoCodesToConvert.add(orginCurrencyCode);
			isoCodesToConvert.add(destCurrencyCode);
		}
		else if(!isoCodeToDCRMapCustomDatedExchange.containsKey(orginCurrencyCode))
			isoCodesToConvert.add(orginCurrencyCode);
		else if(!isoCodeToDCRMapCustomDatedExchange.containsKey(destCurrencyCode))
			isoCodesToConvert.add(destCurrencyCode);
		
		if(!isoCodesToConvert.isEmpty())	
			getCodeMapCustomDatedExchange(isoCodesToConvert);

		Decimal rateOrginCurrencyToOrgCurrency = convertToOrgCurrencyCustomDatedExchange(orginCurrencyCode, 1, conversionDate);
		Decimal rateOrgCurrencyToDestCurrency  = convertFromOrgCurrencyCustomDatedExchange(destCurrencyCode, rateOrginCurrencyToOrgCurrency, conversionDate);
		//Decimal rateOrginCurrencyToOrgCurrency = convertToOrgCurrency(orginCurrencyCode, 1, conversionDate);
		//Decimal rateOrgCurrencyToDestCurrency  = convertFromOrgCurrency(destCurrencyCode, rateOrginCurrencyToOrgCurrency, conversionDate);

		System.Debug('Rate Being Returned for ' + orginCurrencyCode + ' ' + destCurrencyCode + ' ' + rateOrgCurrencyToDestCurrency);
		return rateOrgCurrencyToDestCurrency;
	}

	/*public static Decimal getExchangeRateOld(String orginCurrencyCode, String destCurrencyCode, Date conversionDate)
	{
		if(orginCurrencyCode == destCurrencyCode)
			return 1;
		
		Decimal rateOrginCurrencyToOrgCurrency = convertToOrgCurrency(orginCurrencyCode, 1, conversionDate);
		Decimal rateOrgCurrencyToDestCurrency  = convertFromOrgCurrency(destCurrencyCode, rateOrginCurrencyToOrgCurrency, conversionDate);
		return rateOrgCurrencyToDestCurrency;
	}*/

	/**
	 *
	 * @Author  NTT Data
	 * @Date    July 2016
	 *
	 **/
	public static Decimal convertToOrgCurrencyByCurrencyCode(String currencyIso, Decimal currencyVal, Date currencyDate) {
	    Decimal res;
	    //dcrIdToDcrMap = new Map<ID,DatedConversionRate>();
	    
	    if (currencyIso == null || currencyVal == null) {
	    	return 0;
	    }

	    else {
             // build the map only once for life of the transaoction
	       	//dcrIdToDcrMap = new Map<ID,DatedConversionRate> ([select id, isoCode, conversionrate, nextStartDate, startDate from DatedConversionRate]);
	        dcrIdToDcrMap = new map<ID,DatedConversionRate> ([select id, isoCode, conversionrate, nextStartDate, startDate from DatedConversionRate where isoCode = :currencyIso]);
	        for (DatedConversionRate dcr: dcrIdToDcrMap.values()) {
	            if (dcr.isoCode != currencyIso)                                         
	            	continue;   // look for a match in table against input currency
	            if (currencyDate < dcr.startDate || currencyDate >= dcr.nextStartDate)  
	            	continue;   // not in the range of effective dates
	            System.debug(LoggingLevel.INFO,'Converting using dcr: ' + dcr);
	            res =  currencyVal / dcr.conversionRate;
	            break;  
	        }
	    }
	    return res;	
	}

	/**
	 *
	 * @Author  NTT Data
	 * @Date    July 2016
	 *
	 **/
	public static Decimal convertToOrgCurrency(String currencyIso, Decimal currencyVal, Date currencyDate) {
		
	    Decimal res;
	    //dcrIdToDcrMap = new Map<ID,DatedConversionRate>();
	    
	    if (currencyIso == null || currencyVal == null) {
	    	return 0;
	    }
	    else {
	        if (isoCodeToDcrMap == null) {             // build the map only once for life of the transaoction
	        	//dcrIdToDcrMap = new Map<ID,DatedConversionRate> ([select id, isoCode, conversionrate, nextStartDate, startDate from DatedConversionRate]);
	            //dcrIdToDcrMap = new map<ID,DatedConversionRate> ();
	            getCodeMap();
	        }

	        for (DatedConversionRate dcr: isoCodeToDcrMap.get(currencyIso)) {
	            if (dcr.isoCode != currencyIso)                                         
	            	continue;   // look for a match in table against input currency
	            if (currencyDate < dcr.startDate || currencyDate >= dcr.nextStartDate)  
	            	continue;   // not in the range of effective dates
	            System.debug(LoggingLevel.INFO,'Converting using dcr: ' + dcr);
	            res =  currencyVal / dcr.conversionRate;
	            break;  
	        }
	    }
	    return res;
	}	

	/**
	 *
	 * @Author  NTT Data
	 * @Date    July 2016
	 *
	 **/
	public static Decimal convertToOrgCurrencyCustomDatedExchange(String currencyIso, Decimal currencyVal, Date currencyDate) {
		
	    Decimal res = 0;
	    //dcrIdToDcrMap = new Map<ID,DatedConversionRate>();
	    
	    if (currencyIso == null || currencyVal == null) {
	    	return 0;
	    }
	   	//else if(currencyIso == defaultOrgCurrency)
	    //	return 1;
	    else {
	        /*if (isoCodeToDcrMapCustomDatedExchange == null) {             // build the map only once for life of the transaoction
	        	//dcrIdToDcrMap = new Map<ID,DatedConversionRate> ([select id, isoCode, conversionrate, nextStartDate, startDate from DatedConversionRate]);
	            //dcrIdToDcrMap = new map<ID,DatedConversionRate> ();
	            getCodeMapCustomDatedExchange();
	        }*/

	        System.Debug(currencyIso);
	        for (DatedExchangeRate__c dcr: isoCodeToDcrMapCustomDatedExchange.get(currencyIso)) {
	            if (dcr.isoCode__c != currencyIso)                                         
	            	continue;   // look for a match in table against input currency
	            //if (currencyDate < dcr.startDate__c || currencyDate >= dcr.nextStartDate)  
	            if (currencyDate < dcr.startDate__c) 
	            	continue;   // not in the range of effective dates
	            System.debug(LoggingLevel.INFO,'Converting using dcr: ' + dcr);
	            res =  currencyVal / dcr.conversionRate__c;
	            break;  
	        }
	    }
	    return res;
	}	
	
	/**
	 *
	 * @Author  NTT Data
	 * @Date    July 2016
	 *
	 **/
	public static Decimal convertFromOrgCurrency(String currencyIso, Decimal currencyVal, Date currencyDate) {
    	Decimal res;
    	//Map<Id,DatedConversionRate> dcrIdToDcrMap;
    	if (currencyIso == null || currencyVal == null) {
    		return 0;
    	}
    	else {
        	if (isoCodeToDcrMap == null) {             // build the map only once for life of the transaoction
            	//dcrIdToDcrMap = new Map<ID,DatedConversionRate> ([select id, isoCode, conversionrate, nextStartDate, startDate from DatedConversionRate]);
            	//dcrIdToDcrMap = new map<ID,DatedConversionRate> ([select id, isoCode, conversionrate, nextStartDate, startDate from DatedConversionRate]);
            	getCodeMap();
            }
        	for (DatedConversionRate dcr : isoCodeToDcrMap.get(currencyIso)) {
            	if (dcr.isoCode != currencyIso)                                         
            		continue;   // look for a match in table against input currency
            	if (currencyDate < dcr.startDate || currencyDate >= dcr.nextStartDate)  
            		continue;   // not in the range of effective dates
            	System.debug(LoggingLevel.INFO,'Converting using dcr: ' + dcr);
            	res =  currencyVal * dcr.conversionRate;
            	break;  
        	}
    	}
    	return res;
	}	

	/**
	 *
	 * @Author  NTT Data
	 * @Date    July 2016
	 *
	 **/
	public static Decimal convertFromOrgCurrencyCustomDatedExchange(String currencyIso, Decimal currencyVal, Date currencyDate) {

    	Decimal res = 0;
    	//Map<Id,DatedConversionRate> dcrIdToDcrMap;
    	if (currencyIso == null || currencyVal == null) {
    		return 0;
    	}
    	//else if(currencyIso == defaultOrgCurrency)
	   // 	return 1;
    	else {
        	/*if (isoCodeToDcrMapCustomDatedExchange == null) {             // build the map only once for life of the transaoction
            	//dcrIdToDcrMap = new Map<ID,DatedConversionRate> ([select id, isoCode, conversionrate, nextStartDate, startDate from DatedConversionRate]);
            	//dcrIdToDcrMap = new map<ID,DatedConversionRate> ([select id, isoCode, conversionrate, nextStartDate, startDate from DatedConversionRate]);
            	getCodeMapCustomDatedExchange();
            }*/
        	for (DatedExchangeRate__c dcr : isoCodeToDcrMapCustomDatedExchange.get(currencyIso)) {
            	if (dcr.isoCode__c != currencyIso)                                         
            		continue;   // look for a match in table against input currency
            	//if (currencyDate < dcr.startDate__c || currencyDate >= dcr.nextStartDate) 
            	if(currencyDate < dcr.StartDate__c) 
            		continue;   // not in the range of effective dates
            	System.debug(LoggingLevel.INFO,'Converting using dcr: ' + dcr);
            	res =  currencyVal * dcr.conversionRate__c;
            	break;  
        	}
    	}
    	return res;
	}


}