trigger ECO_PurchaseOrder_AllEvents on POHeader__c (after insert, after update, before insert, before update, before delete) {
    
    if (!ECO_Service_PurchaseOrders.run) return;
    
    Id userId = UserInfo.getUserId();
/*
    if(trigger.isBefore && trigger.isInsert){
        
        //auto approve po if submitted by PM
        for(POHeader__c poHeader : trigger.new){
            if(userId == poHeader.ProjectManager__c){
                poHeader.Status__c = 'APPROVED';
            }else{
                poHeader.Status__c = 'Pending';
            }       
        }
    }

    if(trigger.isAfter && trigger.isInsert){
        
        //auto approve po if submitted by PM
        for(POHeader__c poHeader : trigger.new){
            if(userId == poHeader.ProjectManager__c){
                ECO_Service_PurchaseOrders.submitForApproval(poHeader, userId);
            }           
        }
    }
*/	
    if(Trigger.isAfter && Trigger.isUpdate) {
        ECO_Service_PurchaseOrders.lockPurchaseOrderLineItems(Trigger.NewMap, Trigger.OldMap);
    }
    
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){
        if(trigger.isInsert){
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
        }

        if(trigger.isUpdate){
            ECO_Service_RecordAccess.getProjectRecordAccess( ECO_Service_RecordAccess.getListofCheckableObjects(trigger.new, trigger.oldMap ) );
        }
        if(trigger.isDelete){
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        }
    }
    
	// ******* DELEGATION TRIGGER LOGIC
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        ECO_Service_Delegation.insertDelegations(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isInsert){

        ECO_Service_Delegation.evaluateDelegation(trigger.new, null);
    }
	
    if(trigger.isBefore && trigger.isUpdate){
        ECO_Service_Delegation.evaluateDelegation(trigger.new, trigger.oldMap);
    }
    //******* END OF THE DELEGATION TRIGGER LOGIC
}