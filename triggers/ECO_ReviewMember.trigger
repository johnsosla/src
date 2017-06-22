trigger ECO_ReviewMember on ReviewMember__c (before insert, before update, after insert, after update, before delete) {

    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        set<id> listTeamMembers = new set<id>();
        map<id, ReviewMember__c> mapRM = new map<id, ReviewMember__c>();

        for(ReviewMember__c rm: trigger.new){
            listTeamMembers.add(rm.TechnicalQualityTeamMember__c);
            mapRM.put(rm.TechnicalQualityTeamMember__c, rm);
        }

        list<TechnicalQualityTeam__c> lstTQM = [select id, TechnicalQualityTeamMember__c from TechnicalQualityTeam__c where id IN: listTeamMembers];

        for(TechnicalQualityTeam__c TQM: lstTQM) {
            if(mapRM.containskey(TQM.id)) {
                mapRM.get(TQM.id).User_Stamp__c = TQM.TechnicalQualityTeamMember__c;
            }
        }
    }

    if( trigger.isBefore && ( trigger.isUpdate || trigger.isInsert || trigger.isDelete) ){       
        if(trigger.isDelete)        
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.old );
        else
            ECO_Service_RecordAccess.getProjectRecordAccess( trigger.new );
    }

    // ******* DELEGATION TRIGGER LOGIC
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        ECO_Service_Delegation.insertDelegations(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isInsert){
        ECO_ReviewMember_TriggerHandler.handleEmailNotification(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isInsert){

        ECO_Service_Delegation.evaluateDelegation(trigger.new, null);
    }

    if(trigger.isBefore && trigger.isUpdate){
        ECO_Service_Delegation.evaluateDelegation(trigger.new, trigger.oldMap);
    }
    //******* END OF THE DELEGATION TRIGGER LOGIC     

}