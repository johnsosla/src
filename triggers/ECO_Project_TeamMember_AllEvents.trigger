trigger ECO_Project_TeamMember_AllEvents on ProjectTeamMember__c ( after update, after insert, before insert, before update, after delete , before delete) {
    if(trigger.isBefore){
        // added for record lock
        if(trigger.isUpdate || trigger.IsInsert){
            ECO_ServiceProjectLock.checkProjectLock(trigger.new, trigger.oldMap);
        } else if(trigger.isDelete){
            ECO_ServiceProjectLock.checkProjectLock(trigger.old, null);
        }
    }

    if(trigger.isAfter && trigger.isInsert){
        ECO_Project_TeamMember_Triggers.permissionGanttView(trigger.new);
    }


    if(trigger.isAfter && (!trigger.isDelete) ){ 
        ECO_Project_TeamMember_Triggers.CreateSharingForTeamMembers(trigger.new);

    }
    
    if(trigger.isAfter && trigger.isUpdate){ 
        ECO_Project_TeamMember_Triggers.DeleteSharingForTeamMembers( trigger.new,  trigger.oldMap, trigger.newMap );
        ECO_Project_TeamMember_Triggers.createPortalAlertForChangedKeyMember(trigger.oldMap, trigger.new);
    }    
    
    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert ) ){
        // OAL - US-7174
        // ECO_Project_TeamMember_Triggers.handleBeforeInsert(trigger.new);
        ECO_Project_TeamMember_Triggers.setProjectFields(trigger.new);
        ECO_Project_TeamMember_Triggers.checkDuplicateCM(trigger.new,  trigger.oldMap, trigger.newMap );
        if( trigger.isUpdate )
        {            
        	ECO_Service_RecordAccess.getProjectRecordAccess( ECO_Service_RecordAccess.getListofCheckableObjects(trigger.new, trigger.oldMap ) );
            ECO_Project_TeamMember_Triggers.setChangeManagerIsChangedFlag(trigger.new);

        } 
        if(trigger.isInsert){
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
        }           
    }      
	if( trigger.isBefore && trigger.isDelete ){
        ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
    }
    if( trigger.isAfter && ( trigger.isUpdate || trigger.isInsert ) ){
        ECO_Project_TeamMember_Triggers.handleAfterInsertValidation(trigger.newmap);
    }

    if(trigger.isAfter && trigger.isUpdate){ 
        //For updating Permission Controls when Project Team Member is updated for all roles 
        ECO_Project_TeamMember_Triggers.permissionGanttViewChangeCaptureManager(trigger.old, trigger.newMap);
    }    

}