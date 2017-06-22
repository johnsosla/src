/*******************************************************************
  Name        :   TaskOrderRollup
  Author      :   Virendra  (Appirio Off)
  Version     :   1.0 
  Purpose     :   This Trigger is used  to calculate Task Order Rollup fields on opportunity update insert
  Date        :   05 Aug, 2010 
********************************************************************/

trigger TaskOrderRollup on Opportunity (After insert,After update, before delete){
  /*
  // check if we not need to run trigger if data loading operation is performed
  ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('TaskOrderRollup');
  if(ext != null) {
      if(ext.NotRunTrigger__c) {
          return;  
      }   
  }
  
  
  system.debug('*********SUMIT In Opportunity TaskRollup Trigger*******************'+Trigger.IsInsert+'***'+Trigger.IsBefore );
  List<Opportunity> taskOrderOpportunityList = new List<Opportunity>(); 
  
  if((trigger.IsInsert) || trigger.IsUpdate){
     taskOrderOpportunityList = Trigger.new;
  }
  else{
     taskOrderOpportunityList  = Trigger.Old;
  }
  
  Set<Id> parentOppList = new Set<Id>();
  List<id>childOpp = new List<id>();
  for(Opportunity opp:taskOrderOpportunityList){
      if(opp.Master_Contract_Lookup__c!=null){
        parentOppList.add(opp.Master_Contract_Lookup__c);
        childOpp.add(opp.id);
      }
      if(trigger.IsUpdate){
         string oldparent = trigger.oldMap.get(opp.Id).Master_Contract_Lookup__c; 
         if(oldparent!=null && oldParent!='' && opp.Master_Contract_Lookup__c!=oldparent)
             parentOppList.add(oldparent);
      }
  }
  if((trigger.IsInsert) || trigger.IsUpdate)
      childOpp = new List<id>();
  if(parentOppList.size()>0)
    TaskOrderRollup.calculateTaskOrderRollupTasks(parentOppList,childOpp);
    
        system.debug('*********SUMIT out OpportunityTaskRollup Trigger*******************'+Trigger.IsInsert+'***'+Trigger.IsBefore );
  
  */
}