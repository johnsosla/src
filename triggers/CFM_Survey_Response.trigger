trigger CFM_Survey_Response on CFM_Survey_Response__c (after insert, before insert) 

{
	//ability to control, turn off triggers by managing the ECO_TriggerSettings custom setting, remember to update git ECO_TriggerSettings__c.csv
    if (!ECO_TriggerSettings.getIsTriggerEnabled('CFM_ALL')) {
        return;
    }   
	
    CFM_Survey_Response_TriggerDispatcher.Main(trigger.new, trigger.newMap, trigger.old, trigger.oldMap, trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isExecuting);
    
}