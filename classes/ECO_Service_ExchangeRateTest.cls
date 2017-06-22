@isTest
public class ECO_Service_ExchangeRateTest {
	

	static testMethod void testServiceExchangeRate() {

		DatedExchangeRate__c exchangeRate1 = new DatedExchangeRate__c(isoCode__c = 'NZD', StartDate__c = Date.today().addDays(-1), ConversionRate__c = 2);
		DatedExchangeRate__c exchangeRate2 = new DatedExchangeRate__c(isoCode__c = 'AUD', StartDate__c = Date.today().addDays(-1), ConversionRate__c = 4);
		
		//DatedConversionRate exchangeRate3 = new DatedConversionRate(isoCode = 'NZD', StartDate = Date.today().addDays(-1), ConversionRate = 2);
		//DatedConversionRate exchangeRate4 = new DatedConversionRate(isoCode = 'AUD', StartDate = Date.today().addDays(-1), ConversionRate = 4);
		insert exchangeRate1;
		insert exchangeRate2;
		//insert exchangeRate3;
		//insert exchangeRate4;

		//ECO_Service_ExchangeRate.convertFromOrgCurrency('AUD', 1, Date.today());
		//ECO_Service_ExchangeRate.convertToOrgCurrency('AUD', 1, Date.today());
		ECO_Service_ExchangeRate.getExchangeRate('AUD', 'NZD', Date.today());
		try
		{
			ECO_Service_ExchangeRate.getCodeMap();
			ECO_Service_ExchangeRate.convertToOrgCurrency('AUD', 1, Date.today());
			ECO_Service_ExchangeRate.convertFromOrgCurrency('AUD', 1, Date.today());
			ECO_Service_ExchangeRate.convertToOrgCurrencyByCurrencyCode('AUD', 1, Date.today());

			ECO_Service_ExchangeRate.getPlannedExchangeRate('AUD', 'NZD');
			ECO_Service_ExchangeRate.getPlannedExchangeRateStringForMessage('AUD', 'NZD');

		}
		catch(Exception e)
		{
		}
	}
}