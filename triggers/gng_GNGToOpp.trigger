/*************************************************************************
*
* PURPOSE: Trigger on GNG records that update opportunities (e.g. GNG Status)
*
* CLASS: gng_GNGToOpp
* CREATED: 12/17/2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/

trigger gng_GNGToOpp on Go_No_Go_Conversation__c (after update) {

    Map<Id, Go_No_Go_Conversation__c> updateMap = new Map<Id, Go_No_Go_Conversation__c>();
    Map<String,String> gngStatusToOppStatus = new Map<String, String>{
        'Not Submitted' => 'Pending',
        'Submitted for Approval - Pending' => 'In Process',                 
        'Approved' => 'Approved',
        'Rejected' => 'Rejected'
    };

    for(Go_No_Go_Conversation__c gng : Trigger.new) {
        if(Trigger.oldMap.get(gng.Id).Approval_Status__c != Trigger.newMap.get(gng.Id).Approval_Status__c)  updateMap.put(gng.Opportunity__c,gng);
    }
    
    List<Opportunity> opps = new List<Opportunity> ();

    if (opps.size()>0)
        opps = [Select Id,GNG_Status__c from Opportunity where Id IN: updateMap.keySet()];

    for(Opportunity opp : opps) {
        opp.GNG_Status__c = gngStatusToOppStatus.get(updateMap.get(opp.Id).Approval_Status__c);
        if(opp.GNG_Status__c == 'Rejected') {
            opp.StageName = '8 No-Go';
            opp.Date_No_Go__c = Date.today();
//opp.Date_Lost_Cancelled_No_Go__c = Date.today();
        }
    }

    update opps;


}