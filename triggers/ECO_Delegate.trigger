/*
	Purpose: - Trigger on the Delegate__c object

	Created By: Aaron Pettitt (NTT Data)

	Revision Log: 
		v1.0 - (AP 10/30/2015) -- created 
*/
trigger ECO_Delegate on Delegate__c (before insert, after insert, after update) {
	
	if(trigger.isBefore){
		ECO_DelegateTrigger.HandleBeforeInsert(trigger.new);
	}

	if(trigger.isAfter){
		ECO_DelegateTrigger.ValidateDates(trigger.new);
	}
}