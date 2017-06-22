/*******************************************************************
  Name        :   OpportunityNameCopyTrigger
  Requester   :   CRS Requirments
  Author      :   AECOM - Luke Farbotko
  Version     :   1.0 
  Purpose     :   Populate Opportunity_Name_Searchable__c with the opportunities name
                  when opp is changed. This uses a static boolean to prevent 
                  trigger loopback (StaticHelper.runME==true)
  Date        :   12 Feb, 2015 

********************************************************************/
trigger OpportunityNameCopyTrigger on Opportunity (after insert, after update) {

 // check if we not need to run trigger if data loading operation is performed
    ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('OpportunityNameCopyTrigger');
    if(ext != null) {
        if(ext.NotRunTrigger__c) {
            return;    
        }
        
    }
    if(StaticHelper.runME==true){
         Map<Id, Go_No_Go_Conversation__c> gngMap = new Map<Id, Go_No_Go_Conversation__c>();                                
         List<Id> listIds = new List<Id>();
    
         //get list of gngs
        for (Opportunity opp: Trigger.new){          
    
                listIds.add(opp.Id);       
        }
          
        List<Go_No_Go_Conversation__c> gngList = new List<Go_No_Go_Conversation__c>([select id, Opportunity_Name__c, Opportunity__c, Opportunity_Name_Searchable__c
                                                FROM Go_No_Go_Conversation__c
                                                where Opportunity__c IN :listIds]);
                                                
                                                
        for(Go_No_Go_Conversation__c gng : gngList)
        {
            gng.Opportunity_Name_Searchable__c = gng.Opportunity_Name__c;
        }
        
        StaticHelper.runME = false;
        try{
            update gngList;
        }
        catch(Exception e)
        {}
        StaticHelper.runME = true;
        
    }
}