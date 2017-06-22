/*******************************************************************
  Name        :   SyncContactMailingAddress
  Author      :   Ganesh(Appirio Off)
  Version     :   1.0 
  Purpose     :   Copy Account's custom address fields to Account's standard address fields : Billing Address fields. 
                  Copy Account's standard address fields to ALL of its associated Contacts' standard Mailing address fields.
                  Copy Account's custom address fields to ALL of its associated Contacts' custom address fields.
  PR-No.      :   PR-05613   
  Date        :   3-Aug-2010, Updated 1--Apr-2013 KS. Country/State/Province Lookup support
********************************************************************/
trigger SyncContactMailingAddress on Account (before insert,before Update, after update) 
{ 
    // check if we not need to run trigger if data loading operation is performed
    ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('SyncContactMailingAddress');
    if(ext != null) {
        if(ext.NotRunTrigger__c) {
            return;    
        }
    }
    
    
    if(Trigger.isBefore) 
    {
    	//Loop through all records and build a set of country and province ids
    	Set<ID> countryIds = new Set<ID>();    	
    	Set<ID> stateIds = new Set<ID>();
    	for(Account nAccount : Trigger.New) {
    		if (nAccount.CountryLookup__c != null) countryIds.add(nAccount.CountryLookup__c);	
    		if (nAccount.State_Province_Emerate__c != null) stateIds.add(nAccount.State_Province_Emerate__c);	    		
    	}
    	
    	//build a map of referenced country and province records
    	Map<ID, Country__c> countryMap = new Map<ID, Country__c>([SELECT ID, Name FROM Country__c WHERE ID IN :countryIds]);
    	Map<ID, State_Province_Emirate__c> stateMap = new Map<ID, State_Province_Emirate__c>([SELECT ID, Name FROM State_Province_Emirate__c WHERE ID IN :stateIds]);
    	
        for(Account nAccount : Trigger.New)
        {
                /*if(nAccount.Street__c!=null)
                    nAccount.BillingStreet = nAccount.Street_1__c;
                else if(nAccount.Street_1__c==null && nAccount.Street_2__c!=null)
                    nAccount.BillingStreet = nAccount.Street_2__c;
                else if(nAccount.Street_1__c!=null && nAccount.Street_2__c!=null)
                    nAccount.BillingStreet = nAccount.Street_1__c +  '\n' + nAccount.Street_2__c;
                else*/
                
                string recordTypeName = '';
                if(nAccount.RecordTypeId!=null)
                    recordTypeName = TaskOrderRollup.getAccountRecordtypeMapById().get(nAccount.RecordTypeId).Name;
                else
                    recordTypeName = 'Account Record Type - North America';
                    
                
                //Set the Billing State    
                if(recordTypeName.indexOf('Asia')>=0) {
                    nAccount.BillingState = nAccount.StateAsia__c;
                } else {
                	//Set the state from the previously queried State_Province_Emerate__c map
	                if (nAccount.State_Province_Emerate__c != null) {
		                State_Province_Emirate__c state = stateMap.get(nAccount.State_Province_Emerate__c);	                
		                nAccount.BillingState = (state != null ? state.Name : null);
	                } else {
	                	nAccount.BillingState = null;
	                }
                }
                    
                nAccount.BillingStreet = nAccount.Street__c;
                nAccount.BillingCity = nAccount.City__c;
                nAccount.BillingPostalCode = nAccount.Zip__c;
                //Set the country from the previously queried country__c map
                if (nAccount.CountryLookup__c != null) {
	                Country__c cntry = countryMap.get(nAccount.CountryLookup__c);	                
	                nAccount.BillingCountry = (cntry != null ? cntry.Name : null);
                } else {
                	nAccount.BillingCountry = null;
                }
        }
    } 
    else if(Trigger.isUpdate && Trigger.isAfter) 
    {
        SyncContactMailingAddress.afterAccountUpdate(Trigger.newmap, Trigger.oldmap);
    }
}