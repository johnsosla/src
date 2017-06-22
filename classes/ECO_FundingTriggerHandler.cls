public class ECO_FundingTriggerHandler {

	public static boolean run = true;

	public static void handleFundingBeforeUpdate(List<Funding__c> newFunding, Map<Id, Funding__c> oldFundingMap)
	{
		if(!run)
			return;
			
		for(Funding__c funding:newFunding)
		{
			if(funding.OracleSyncStatus__c == 'E' && oldFundingMap.get(funding.Id).OracleSyncStatus__c != 'E')
				funding.ChangeManagerIsChanged__c = true;
		}

	}
}