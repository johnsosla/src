trigger ECO_ProjectAgreement_AllEvents on ProjectAgreement__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		//system.debug('@@@DEBUG: START');
		if (Trigger.isAfter) {

			//system.debug('@@@DEBUG: INAFTER');
	        if(trigger.isDelete){
	            ECO_Service_DirtyScope.setProjectDirty(trigger.old, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
	        } else {

	        	//system.debug('@@@DEBUG: NOTDELETE');
	            ECO_Service_DirtyScope.setProjectDirty(trigger.new, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
	        }
		}
}