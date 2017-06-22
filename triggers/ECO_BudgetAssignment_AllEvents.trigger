trigger ECO_BudgetAssignment_AllEvents on BudgetAssignment__c (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete) {

	if (!ECO_BudgetAssignmentTriggers.run) return;
	
    if (Trigger.isBefore && Trigger.isInsert) {
        ECO_BudgetAssignmentTriggers.setRateDefaults(trigger.new);
    } else if (Trigger.isAfter) {
        if ((trigger.isInsert) || (trigger.isUpdate)) {
            /* Disabled by Omar 1/14/2016 - Would throw error 'Class.ECO_BudgetAssignmentTriggers.calculateMultiplier: line 149, column 1'
            try{
             ECO_BudgetAssignmentTriggers.calculateMultiplier(trigger.new);
            }catch(Exception e){
             System.Debug(LOGGINGLEVEL.ERROR, e.getStackTraceString());
            }
            */
        }
    }

    if (Trigger.isBefore && 
        (Trigger.isInsert || Trigger.isUpdate))  {
            String type = Trigger.isInsert ? 'Insert' : 'Update';
            system.debug('In setEACDefaults: ' + type);
            ECO_BudgetAssignmentTriggers.setEACDefaults(trigger.new);
            ECO_BudgetAssignmentTriggers.calculateMultiplierOmar(trigger.new);
    }

    if (Trigger.isBefore && !Trigger.isDelete) {
        ECO_BudgetAssignmentTriggers.setCurrency(trigger.new);
        ECO_BudgetAssignmentTriggers.calculateFiscalMonths(trigger.new);
    }
}