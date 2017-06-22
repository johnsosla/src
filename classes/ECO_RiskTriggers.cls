public with sharing class ECO_RiskTriggers {
	public static Boolean run = true;
    
	public static void handleRiskBeforeUpdate(map<Id, Risk__c> oldRiskMap, list<Risk__c> updatedRisk)
	{
        if(UserInfo.getUserName().toLowerCase().contains('integration@aecom.com') || !run){
            return;
        }

		for(Risk__c risk:updatedRisk)
		{
			if(!oldRiskMap.get(risk.Id).ChangeManagerIsChanged__c)
				risk.ChangeManagerIsChanged__c = true;
		}	
	}
    
    public static void setCurrency(List<Risk__c> newRiskList) {
    	if (!run) {
    		return;
    	}

    	Id projId = newRiskList[0].Project__c;
    	// Get project currency
        pse__Proj__c proj = [Select Id, CurrencyIsoCode From pse__Proj__c Where Id = :projId];

        String projectCurrency = proj.CurrencyIsoCode;

        for (Risk__c risk : newRiskList) {
        	risk.CurrencyIsoCode = projectCurrency;            
        }
    }
}