/*******************************************************************
  Name        :   SyncContactMailingAddress
  Author      :   Ganesh(Appirio Off)
  Version     :   1.0 
  Purpose     :   Used in SyncContactMailingAddress Trigger
  PR-No.      :   PR-05613    
  Date        :   3-Aug-2010
********************************************************************/
public class SyncContactMailingAddress 
{ 
    public static void afterAccountUpdate(Map<Id, Account> accountList, Map<Id, Account> oldAccountList)
    {
        //syncAccountStandardMailingAddress(accountList);
        Map<Id, Account> updateContactOfAccounMap = new Map<Id, Account>();
        for(Account account : accountList.values()) 
        {
            Account oldAcc = oldAccountList.get(account.Id);
            if(oldAcc.BillingCity  != account.BillingCity  || oldAcc.BillingStreet != account.BillingStreet 
              || oldAcc.BillingCountry  != account.BillingCountry  
              || oldAcc.BillingState  != account.BillingState  || oldAcc.BillingPostalCode  != account.BillingPostalCode) 
            {
                updateContactOfAccounMap.put(account.ID, account);
            }
        }
        if(updateContactOfAccounMap.size() > 0) 
            syncContactMailingAddress(accountList);
    }
    //Copy Account's standard address fields to ALL of its associated Contacts' standard Mailing address fields.
    private static void syncContactMailingAddress(Map<Id, Account> accountMap) 
    {
        Set<ID> accountIds = accountMap.keySet();
        List<Contact> contactToUpdate = new List<Contact>();
        boolean isUpdateContact = false;
        Account account;
        for(List<Contact> contactList : [Select Id, AccountId, MailingStreet, MailingState, 
                                            MailingPostalCode, MailingCountry, MailingCity 
                                        From Contact where AccountId in :accountIds]) {
            for(Contact contact : contactList) {
                account = accountMap.get(contact.AccountId);
                if(account != null) {
                    isUpdateContact = false;
                    if(contact.MailingCity != account.BillingCity ) {
                        contact.MailingCity = account.BillingCity ;
                        isUpdateContact = true;
                    }
                    if(contact.MailingStreet != account.BillingStreet) 
                    {
                        contact.MailingStreet = account.BillingStreet;
                        isUpdateContact = true;
                    }
                    if(contact.MailingCountry != account.BillingCountry ) {
                        contact.MailingCountry = account.BillingCountry ;
                        isUpdateContact = true;
                    }
                    if(contact.MailingState != account.BillingState ) {
                        contact.MailingState = account.BillingState ;
                        isUpdateContact = true;
                    }
                    if(contact.MailingPostalCode != account.BillingPostalCode) {
                        contact.MailingPostalCode = account.BillingPostalCode;
                        isUpdateContact = true;
                    }
                    
                    if(isUpdateContact == true) {
                        contactToUpdate.add(contact);
                    }
                }
                if(contactToUpdate.size() > 200) {
                    update contactToUpdate;
                    contactToUpdate.clear();
                }
            }
        }
        if(contactToUpdate.size() > 0)
            update contactToUpdate;
    }
}