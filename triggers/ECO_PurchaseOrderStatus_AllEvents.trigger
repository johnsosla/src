trigger ECO_PurchaseOrderStatus_AllEvents on POStatus__c (before insert) {
    if(Trigger.isBefore && Trigger.isInsert) {
        ECO_Service_PurchaseOrders.setPurchaseOrderForPurchaseOrderStatuses(Trigger.New);
    }
}