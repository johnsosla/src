/** ------------------------------------------------------------------------------------------------------
* @Description 
*	Trigger for the GBS or SharedServicesRequest object
*   Not fully frameworked, lacks ability to turn it off via config
*   Oct 2016 added HandleStatusChange, Removed After_Update -> UpdateAccountDB, this can be handled in the before trigger, changed name to updateEntities and improved code
* 
* @Author Steve MunLeeuw AECOM
* @Date   Oct 2016
*-----------------------------------------------------------------------------------------------------*/
trigger ECO_SharedServicesRequest on SharedServicesRequest__c (before insert, after insert, before update, after update) {
    if(trigger.isUpdate && trigger.isBefore){
		ECO_SharedServicesRequestTrigger.HandleStatusChange(trigger.newMap, trigger.oldMap);    
		ECO_SharedServicesRequestTrigger.HandleOwnerhipChange(trigger.newMap, trigger.oldMap);
        ECO_SharedServicesRequestTrigger.HandleGeneration(trigger.new);
		ECO_SharedServicesRequestTrigger.HandleInApprovalProcess(trigger.newMap, trigger.oldMap);    
    }
}