trigger INC_RoutingMember_AllEvents on RoutingMember__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

		INC_RoutingMemberTriggers handler = new INC_RoutingMemberTriggers();
		boolean isTriggerEnabled = ECO_TriggerSettings.getIsTriggerEnabled('INC_RoutingMember_AllEvents');
    	boolean bisRunning = false;
   		System.Debug(logginglevel.error,'Trigger Running for Routing Member');
   		if(!bisRunning && isTriggerEnabled){
   			bisRunning=true;
   			if (Trigger.isAfter && !Trigger.isDelete) {
	    		handler.updateGroups(Trigger.newMap, Trigger.oldMap);	

			}//end is before
			if(Trigger.isAfter && Trigger.isUpdate) {
				handler.updateProjectsAndPlans(Trigger.newMap, Trigger.oldMap);
			}
		}

}