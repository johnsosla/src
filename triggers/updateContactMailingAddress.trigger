/*******************************************************************************************
PR          :  PR-06193
Requester   :  Karishma Sharma
Author      :  Appirio Offshore (Sumit)
Date        :  Sept 15, 2010
Purpose     :  Update Contacts mailing address with related Account's mailing address
*********************************************************************************************/
trigger updateContactMailingAddress on Contact (before update) 
{
    // check if we not need to run trigger if data loading operation is performed
    ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('updateContactMailingAddress');
    if(ext != null) {
        if(ext.NotRunTrigger__c) {
            return;      
        }
    }
    
    
    
    // varibale
    set<id> actIds = new set<id>();
    
    // update.. prepare account id set
    for(Contact con:Trigger.New)
    {
        if(Trigger.IsInsert && Con.AccountId != null)
            actIds.add(Con.AccountId);
        else if(Trigger.IsUpdate && Con.AccountId != null)
        {
            if(Con.AccountId!=Trigger.Oldmap.get(Con.Id).AccountId)
            {
                actIds.add(Con.AccountId);
            }
        }
    }
    
    // Query billing address info for the related set of Account ids
    Map<id,Account> mapAccount = new map<id,Account>([Select id,BillingStreet,BillingState ,
                                                             BillingCity, BillingPostalCode,BillingCountry 
                                                                from Account where id in:actIds]);  
    
    // set account billing address to contacts address
    for(Contact con:Trigger.New)
    {
        if(Con.AccountId!=null && mapAccount.get(Con.AccountId)!=null)
        {
            Account account= mapAccount.get(Con.AccountId);
            con.MailingCity = account.BillingCity;
            con.MailingStreet = account.BillingStreet;
            con.MailingCountry = account.BillingCountry ;
            con.MailingState = account.BillingState;
            con.MailingPostalCode = account.BillingPostalCode;
        }
    }
}