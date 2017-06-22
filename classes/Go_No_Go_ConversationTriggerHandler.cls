public class Go_No_Go_ConversationTriggerHandler {
    public static Boolean run = true;

    public static void handleAfterUpdate(Map<Id, Go_No_Go_Conversation__c> oldGngConversations, List<Go_No_Go_Conversation__c> newGngConversations){
        Set<ID> oppIds = new Set<ID>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
    
        for(Go_No_Go_Conversation__c gos : newGngConversations) {
            Go_No_Go_Conversation__c oldGo = oldGngConversations.get(gos.Opportunity__c);
            
            oppIds.add(gos.Opportunity__c);
            if(oldGo != null) {
                oppIds.add(oldGo.Opportunity__c);    
            }
        }
        List<Opportunity> affectedOpps = [SELECT ID
                                         , Name
                                         , Go_No_Go_approval_date__c
                                         , Bid_Proposal_Charge__c
                                         , RecordTypeText__c
                                         , (SELECT ID, Opportunity__c, B_P_Charge_Number__c from G_NG_Conversations__r WHERE B_P_Charge_Number__c != null LIMIT 1)
                                         FROM Opportunity
                                         WHERE ID in :oppIds];

        for(Opportunity opp : affectedOpps) {
            if(opp.G_NG_Conversations__r.size() > 0 && !opp.RecordTypeText__c.contains('EMEA')) {
                if(opp.Bid_Proposal_Charge__c != opp.G_NG_Conversations__r[0].B_P_Charge_Number__c  && !opp.RecordTypeText__c.contains('EMEA')) {
                    opp.Bid_Proposal_Charge__c = opp.G_NG_Conversations__r[0].B_P_Charge_Number__c;
                    oppsToUpdate.add(opp);
                }
                //opp.Bid_Proposal_Charge_Type__c = 'Generic charge number';
            } else {
                if(opp.Bid_Proposal_Charge__c != null && !opp.RecordTypeText__c.contains('EMEA')) {
                    opp.Bid_Proposal_Charge__c = null;
                    oppsToUpdate.add(opp);
                }   
            }
        }
        if(oppsToUpdate.size() > 0) update oppsToUpdate;

/*************************************************************************
*
* PURPOSE: Trigger on GNG records that update opportunities (e.g. GNG Status)
*
* CLASS: gng_GNGToOpp
* CREATED: 12/17/2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
* Steve MunLeeuw - I moved this from a separate trigger into this handler
* There are two updates to Opportunity collection, need to be mindful of keys, but a single collection should be kept and updated.
***************************************************************************/

    Map<Id, Go_No_Go_Conversation__c> updateMap = new Map<Id, Go_No_Go_Conversation__c>();
    Map<String,String> gngStatusToOppStatus = new Map<String, String>{
        'Not Submitted' => 'Pending',
        'Submitted for Approval - Pending' => 'In Process',                 
        'Approved' => 'Approved',
        'Rejected' => 'Rejected'
    };

    for(Go_No_Go_Conversation__c gng : newGngConversations) {
        if(oldGngConversations.get(gng.Id).Approval_Status__c != gng.Approval_Status__c)  updateMap.put(gng.Opportunity__c,gng);
    }

    List<Opportunity> opps = [Select Id,GNG_Status__c from Opportunity where Id IN: updateMap.keySet()];

    for(Opportunity opp : opps) {
        opp.GNG_Status__c = gngStatusToOppStatus.get(updateMap.get(opp.Id).Approval_Status__c);
        // comment out since trigger still active also nb 9/2016 and if we aren't setting date can't set stage
        //if(opp.GNG_Status__c == 'Rejected') {
            //opp.StageName = '8 No-Go';
            //In production there is still an active trigger gng_GNGToOpp which has active development.
            //The following line was changed to the Date_No_Go__c
            //opp.Date_Lost_Cancelled_No_Go__c = Date.today();
       // }
    }

    update opps;

/*************************************************************************
*
* End
*
***************************************************************************/



        run = false;
    }
}