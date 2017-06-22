trigger ECO_WeeklyRollupEntry_AllEvents on WeeklyRollupEntry__c (before insert, before update, after insert, after update, after delete, after undelete, before delete) { 
  
  if(trigger.isAfter){
  	if(trigger.isDelete){
  		ECO_Service_DirtyScope.setProjectDirty(trigger.old, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
  	} else {
  		ECO_Service_DirtyScope.setProjectDirty(trigger.new, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
  	}
  }

  if (!ECO_WeeklyRollupEntryTriggers.run) return;
  
  if(trigger.isbefore && !trigger.isdelete)
  {
      ECO_WeeklyRollupEntryTriggers.calculateFiscalMonths(trigger.new);
  }
       

  if (trigger.isAfter && !trigger.isdelete) {
//  if (!trigger.isdelete) {
  	ECO_WeeklyRollupEntryTriggers.checkCurrency(trigger.new);
  }
}