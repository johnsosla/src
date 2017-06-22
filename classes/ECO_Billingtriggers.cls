public class ECO_Billingtriggers{

    public static void updateCurrencyCode(List<Billing__c> billings)
    {
        Set<String> projectIds = new Set<String>();

        for(Billing__c billing:billings)
        {
            projectIds.add(billing.ProjectNumber__c);
        }

        Map<Id, pse__Proj__c> projectsMap = new Map<Id, pse__Proj__c>([select Id, ProjectFunctionalCurrencyCode__c from pse__Proj__c where Id in :projectIds]);

        for(Billing__c billing:billings)
        {
            billing.CurrencyIsoCode = projectsMap.get(billing.ProjectNumber__c).ProjectFunctionalCurrencyCode__c;
        }
    }

public static void updateCustomername(list<billing__c> billinglist){
  /*  list<string> Accountnumlist = new list<string>();
    map<string,string> Accountmap = new map<string,string>();
    for(Billing__c b:billinglist){
        if(b.customernumber__c !=null)
        {
            Accountnumlist.add(b.customernumber__c);
        }
    }
    if(Accountnumlist.size()>0)
    {
        for(Account acc:[select id,name,OracleCustomerNumber__c from account where  OracleCustomerNumber__c IN:Accountnumlist]){
            Accountmap.put(acc.OracleCustomerNumber__c,acc.name);
        }
        for(Billing__c b:billinglist){
            if(accountmap.containskey(b.customernumber__c))
            {
                b.customername__c = accountmap.get(b.customernumber__c);
            }
        }
    
    }
    */
    
}



}