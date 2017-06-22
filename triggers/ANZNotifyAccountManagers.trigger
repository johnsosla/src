/*******************************************************************
  Name        :   ANZNotifyAccountManagers
  Requester   :   ANZ Requirements GAP 
  Author      :   AECOM - Luke Farbotko
  Version     :   1.0 
  Purpose     :   This Trigger is used  to alert account managers
                , client directors and client managers that an opportunitcy 
                has been created for the account
  Date        :   20 Jul, 2014 
********************************************************************/
trigger ANZNotifyAccountManagers on Opportunity (after insert) {
    
    /*
    // Check if user that created the opportunity is from ANZ
    // issue: hardcoded ANZ value, is there another way?
    // 
    try
    {
        Id userId =userinfo.getUserId();
        //String geography =[Select Id,Geography_Allocation__c from User where Id=:userId].Geography_Allocation__c;
        String geography = [select Geography_Allocation__c from User where id = :UserInfo.getUserId()].Geography_Allocation__c;
        
        if(geography == 'ANZ')
        {
            for(Opportunity opp:Trigger.New)
            {
                //get account managers, client directors and client managers  from account team
                List<AECOM_team__c> team = [SELECT Account__c, Email__c, IsDeleted, Role__c FROM AECOM_team__c
                                            WHERE  Account__c = : opp.AccountId 
                                            AND (Role__c = 'Client Manager' OR Role__c =  'Account Manager' OR Role__c =  'Client Director')
                                            AND IsDeleted = false
                                            AND Employee__r.Office_Country__c in ('AU', 'NZ')];
           
                //add team to list
                List<String> toAddresses = new List<String>();
                for(AECOM_team__c member : team)
                {
                    toAddresses.add(member.Email__c);
                }
                 
               //Opportunity o = [select id from Opportunity where id = '006e0000005QhNz' limit 1];
               HelperMethods.sendTemplatedEmail(toAddresses, null, 'ANZ_Client_Bid_Activity_Template', null, opp.id, null, false, null);
            }
            
        }
          
    }
    catch (Exception e){}
    */
}