trigger ECO_Agreements_AllEvents on Agreement__c (before update, after update, before insert, after insert, after delete, before delete) {
    


    if(trigger.isBefore){
        // added for record lock
        if(trigger.isUpdate || trigger.IsInsert){
            ECO_ServiceProjectLock.checkProjectLock(trigger.new, trigger.oldMap);
        } else if(trigger.isDelete){
            ECO_ServiceProjectLock.checkProjectLock(trigger.old, null);
        }
    }

    if(trigger.isBefore && trigger.isUpdate)
    {
        ECO_AgreementTriggerHandler.handleAgreementBeforeUpdate(trigger.oldMap, trigger.newMap);
        ECO_AgreementTriggerHandler.handleChangedScopePackage(trigger.newMap, trigger.oldMap);
    }
    if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert))
    {
        //AECOMAgrmntDelegetionActions.AgreementRecords(trigger.new);
        ECO_AgreementTriggerHandler.calculateTaskOrderValueForMSA(trigger.new);        
        if(trigger.isUpdate)
            ECO_AgreementTriggerHandler.handleSegmentationApproval(trigger.oldMap, trigger.newMap); 
           // AECOMAgrmntDelegetionActions.UpdateAgreementRecords(trigger.oldMap, trigger.newMap);          
    }
    if(trigger.isAfter && trigger.isDelete)
        ECO_AgreementTriggerHandler.calculateTaskOrderValueForMSA(trigger.old);
    
    //Security Matrix validation for record access
    // bak commenting out as this is causing issues with converted America's data of one agreement to many projects
    // the agreement project__c field can be invalid in that scneario as we have a projectAgreement__c object 
	/*if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){
        system.debug( 'ECO_Agreements_AllEvents executed' );
        if(trigger.isDelete)        
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
      	else
        	ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    } */


    if(trigger.isAfter){
        if(trigger.isDelete){
            ECO_Service_DirtyScope.setProjectDirty(trigger.old, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
        } else if (!trigger.IsInsert) {
            ECO_Service_DirtyScope.setProjectDirty(trigger.new, ECO_Service_DirtyScope.PROJECT_DIRTY_FLAG_SNAPSHOT_MTD);
        }
    }

    // ******* DELEGATION TRIGGER LOGIC
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        //bak I am disabling for the time being.  need to talk to tim and brian about this.  this is failing
        //on non MSA Agreements because it doesnt have the segmentation designee for those types 2/4
        ECO_Service_Delegation.insertDelegations(trigger.new);
    }
        
    if(trigger.isBefore && trigger.isInsert){

        ECO_Service_Delegation.evaluateDelegation(trigger.new, null);
        //ECO_AgreementTriggerHandler.handleChangedScopePackage(trigger.newMap, trigger.oldMap);
    }

    if(trigger.isBefore && trigger.isUpdate){
        ECO_Service_Delegation.evaluateDelegation(trigger.new, trigger.oldMap);
    }
    //******* END OF THE DELEGATION TRIGGER LOGIC


}