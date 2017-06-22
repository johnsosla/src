trigger ECO_PermissionControl_AllEvents on pse__Permission_Control__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	if (trigger.isAfter && trigger.isInsert) {
		ECO_PermissionControlTriggers.setProjectOwner(trigger.new);		
	}
}