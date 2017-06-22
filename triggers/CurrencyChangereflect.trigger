trigger CurrencyChangereflect on Opportunity (after update) 
{/*
    Set<id> oppSet = new Set<id>();
    for(Opportunity opp:Trigger.New)
    {
        if(opp.CurrencyIsoCode!=Trigger.oldMap.get(opp.id).CurrencyIsoCode)
            oppSet.add(opp.Id);
    }
    if(oppSet.size()>0)
    {
        for(List<Opportunity_Department__c> lst:[Select id,Opportunity__c, CurrencyISOCode from 
                                            Opportunity_Department__c where Opportunity__c in : oppSet])
        {
            for(Opportunity_Department__c od:lst)
                od.CurrencyISOCode = Trigger.newMap.get(od.Opportunity__c).CurrencyISOCode;
            update lst;
        }
    }
    */
}