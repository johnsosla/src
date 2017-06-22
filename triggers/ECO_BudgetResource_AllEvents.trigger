trigger ECO_BudgetResource_AllEvents on BudgetResource__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    
    if (!ECO_BudgetResourceTriggers.run) return;
    
    if (ECO_BudgetResourceTriggers.run) {
        if (trigger.isBefore) {
            if (trigger.isInsert) {
                ECO_BudgetResourceTriggers.defaultCostRevenueValuesOnHeader(trigger.new);
                ECO_BudgetResourceTriggers.setCurrency(trigger.new);
                ECO_BudgetResourceTriggers.calculateMultiplier(trigger.new);
            }

            if (trigger.isUpdate) {
                ECO_BudgetResourceTriggers.areBurdenRatesRevised(trigger.oldMap, trigger.newMap);
            }
        }

        if (trigger.isAfter && !Trigger.isDelete) {
            ECO_BudgetResourceTriggers.setDefaultValues(trigger.newMap);
        }

        ECO_BudgetResource_TriggerDispatcher.Main(trigger.new, trigger.newMap, trigger.old, trigger.oldMap, 
            trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isExecuting);
    }
}