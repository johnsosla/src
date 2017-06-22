trigger ECO_POLineItem_AllEvents on POLineItem__c (after insert) {

	Boolean isTriggerEnabled = ECO_TriggerSettings.getIsTriggerEnabled('ECO_POLineItem_AllEvents');

	 if (trigger.isAfter && isTriggerEnabled && trigger.isInsert) {

        ECO_POLineItemTriggers handler = new ECO_POLineItemTriggers();

        //create distribution for polineitem
        handler.createDistributions(trigger.new);

     }
}