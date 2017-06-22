trigger End_Client_Sector_Update on Account (after update) {
	if (trigger.isAfter && trigger.isUpdate) { 
        Account oldAccount;
        Account newAccount;
        List<Id> Ids = new List<Id>();
        for(Account account:trigger.new){ 	  
  	      	oldAccount = trigger.oldMap.get(account.Id);
            newAccount= account;
            Ids.add(account.Id);
        }
		if (oldAccount.Client_Subgroup__c != newAccount.Client_Subgroup__c) { 
			EndClientSector_Triggers.setEndClientSector(Ids); 
		} 
	}
    
}