@isTest
private class ECO_WeeklyRollupEntryTriggersTest {
	@isTest static void testStaticMethods() {
		pse__Proj__c testProj = ECO_Utils_Testing.createProject();

		WeeklyRollupEntry__c wrRec = new WeeklyRollupEntry__c(COMPOSITEKEY__C='a321800000058cLAAQ__2015-WK14',REVENUE__C=100.0,Project__c = testProj.Id);
		insert wrRec;

		List<WeeklyRollupEntry__c> theList = new List<WeeklyRollupEntry__c>();
		theList.add(wrRec);

    	ECO_WeeklyRollupEntryTriggers.checkCurrencyDoWork(theList);
    	ECO_WeeklyRollupEntryTriggers.calculateFiscalMonths(theList);
	}
}