trigger QuestionnaireSet on QuestionnaireSet__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) 
{

    if (!ECO_QuestionnaireSet_TriggerDispatcher.run) return;
    
	ECO_QuestionnaireSet_TriggerDispatcher.Main(trigger.new, trigger.newMap, trigger.old, trigger.oldMap, trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isExecuting);

    // ******* DELEGATION TRIGGER LOGIC
    /*if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        ECO_Service_Delegation.insertDelegations(trigger.new);
    }
        
    if(trigger.isBefore && trigger.isInsert){

        ECO_Service_Delegation.evaluateDelegation(trigger.new, null);
    }

    if(trigger.isBefore && trigger.isUpdate){
        ECO_Service_Delegation.evaluateDelegation(trigger.new, trigger.oldMap);
    }*/
    //******* END OF THE DELEGATION TRIGGER LOGIC

}