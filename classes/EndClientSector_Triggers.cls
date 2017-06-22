public without sharing class EndClientSector_Triggers {
   public static void setEndClientSector(List<Id> Ids){
       if (System.isFuture() || System.isBatch() || System.isScheduled()) {
           System.debug('isFuture::::TRUE:::' + System.isFuture() );
            doEndClientSectorFuture(Ids);
       }
       else
       {
           doEndClientSector(Ids);
           System.debug('isFuture::::FALSE:::' + System.isFuture() );
       }
    }
    
    @future
    private static void doEndClientSectorFuture(List<Id> Ids){
        doEndClientSector(Ids);
    }
    
    private static void doEndClientSector(List<Id> Ids){
        List<Account> lAccounts = new List<Account>([select Id from account where Id IN: Ids]);

        System.debug('lAccounts::::' + lAccounts);
        List<Opportunity> opportunities = new List<Opportunity>([select id, End_Client_Sector_Text__c 
            from Opportunity where AccountId IN :lAccounts]);
        
        //UPDATE TO TRIGGER WORKFLOW RULE THAT WILL UPDATE THE END-CLIENT SECTOR
        try{
            database.update(opportunities,false);
        }
        catch(exception ex){
            System.debug(ex);
        }
                           
    }
}