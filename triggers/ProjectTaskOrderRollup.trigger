/*******************************************************************
  Name        :   ProjectTaskOrderRollup
  Author      :   Created from the Opportunity trigger written by Virendra  (Appirio Off)
  Version     :   1.0 
  Purpose     :   This Trigger is used  to calculate Task Order Rollup fields on Project update insert
  Date        :   24 July 2012
  ********************************************************************/

trigger ProjectTaskOrderRollup on Project__c (After insert,After update, before delete){
  
 
  
  // check if we not need to run trigger if data loading operation is performed
  ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('ProjectTaskOrderRollup');
  if(ext != null) {
      if(UserInfo.getName() == 'NA System User' && ext.NotRunTrigger__c) {
          return; 
      }       
  }
  
  // if record type not = task order do not run this trigger
  // *******************************************************
  List<Project__C> taskOrderProjectList = new List<Project__C>(); 
    ID taskOrderRecType =  [select id from RecordType where DeveloperName = 'Task_Order' and RecordType.SobjectType ='Project__c'].ID;
  if((trigger.IsInsert) || trigger.IsUpdate){
     taskOrderProjectList = Trigger.new;
  }
  else{
     taskOrderProjectList  = Trigger.Old;
  }
  //  above load the taskorderprojectlist with the updated/inserted data or the deleted task order data
  
  Set<Id> parentProjList = new Set<Id>();
  List<id>childProj = new List<id>();
  for(Project__c Proj:taskOrderProjectList){
    if (Proj.RecordTypeId == taskOrderRecType) {
    
          if(Proj.Program_Master_Contract_Name__c!=null){
            parentProjList.add(Proj.Program_Master_Contract_Name__c);
            childProj.add(Proj.id);
          }
          if(trigger.IsUpdate){
             string oldparent = trigger.oldMap.get(Proj.Id).Program_Master_Contract_Name__c; 
             if(oldparent!=null && oldParent!='' && Proj.Program_Master_Contract_Name__c!=oldparent)
                 parentProjList.add(oldparent);
          }
    }
  }

  if((trigger.IsInsert) || trigger.IsUpdate)
      childProj = new List<id>();
  if(parentProjList.size()>0)
    ProjectTaskOrderRollup.calculateTaskOrderRollupTasks(parentProjList,childProj);
    
}