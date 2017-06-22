public without sharing class ECO_BudgetTaskTriggers {
    public static Boolean run = true;
    
    public static void rollUpBudgetTaskValues (Map<Id, BudgetTask__c> btOld, Map<Id, BudgetTask__c> btNew) {
        if (!run || ECO_TriggerSettings.isBypassed('BT_rollup')) {
            return;
        }
        
        Set<Id> projectTaskIds = new Set<Id>();
        if (btOld != null) {
            for (BudgetTask__c bt : btOld.values()) {
                if (bt.ProjectTask__c != null) projectTaskIds.add(bt.ProjectTask__c);
            }
        }
        if (btNew != null) {
            for (BudgetTask__c bt : btNew.values()) {
                if (bt.ProjectTask__c != null) projectTaskIds.add(bt.ProjectTask__c);
            }
        }

        List<pse__Project_Task__c> projectTasksToUpdate = new List<pse__Project_Task__c>();
        
        Map<Id, Decimal> approvedCostAmountMap = new Map<Id, Decimal>();
        Map<Id, Decimal> estimateCostAmountMap = new Map<Id, Decimal>();

        List<BudgetTask__c> budgetTasks = [select ProjectTask__c, (select id, FullyBurdenedCost__c from BudgetAssignments__r), BudgetHeader__r.Status__c from BudgetTask__c where ProjectTask__c in :projectTaskIds AND BudgetHeader__r.Status__c != 'Archive'];
        
        for (BudgetTask__c budgetTask : budgetTasks) {
            Decimal approvedCost = approvedCostAmountMap.get(budgetTask.ProjectTask__c);

            if (approvedCost == null) {
                approvedCost = Decimal.valueOf(0).setScale(2);
            }

            Decimal estimateCost = estimateCostAmountMap.get(budgetTask.ProjectTask__c);

            if (estimateCost == null) {
                estimateCost = Decimal.valueOf(0).setScale(2);
            }

            for (BudgetAssignment__c budgetAssignment : budgetTask.BudgetAssignments__r) {
                if ((budgetTask.BudgetHeader__r.Status__c != null) && budgetTask.BudgetHeader__r.Status__c.equals('Approved')) {
                    approvedCost += budgetAssignment.FullyBurdenedCost__c;
                }

                estimateCost += budgetAssignment.FullyBurdenedCost__c;
            }

            //approvedCost += budgetTask.TotalApprovedCost__c;
            approvedCostAmountMap.put(budgetTask.ProjectTask__c, approvedCost);

            estimateCostAmountMap.put(budgetTask.ProjectTask__c, estimateCost);
        }

        Map<Id, pse__Project_Task__c> projectTasksToCheck = new Map<Id, pse__Project_Task__c> (
            [Select Id, TotalApprovedCost__c, TotalEstimateCost__c 
            FROM pse__Project_Task__c
            Where Id IN :projectTaskIds ]);

        for (Id idx : approvedCostAmountMap.keySet()) {
            pse__Project_Task__c ptToUpdate = projectTasksToCheck.get(idx);
            Boolean isChanged = false; 

            Decimal approvedCost = approvedCostAmountMap.get(idx);
            Decimal estimateCost = estimateCostAmountMap.get(idx);
            
            if (ptToUpdate.TotalApprovedCost__c != approvedCost) {
                ptToUpdate.TotalApprovedCost__c = approvedCost;
                isChanged = true;
            }

            if(ptToUpdate.TotalEstimateCost__c !=  estimateCost) {
                ptToUpdate.TotalEstimateCost__c = estimateCost;
                isChanged = true;
            }

            if (isChanged) {
                projectTasksToUpdate.add(ptToUpdate);
            }
        }       
        
        // Makes sure that only Earned value functions run
        ECO_TriggerSettings.bypassTrigger('PT');
        ECO_TriggerSettings.bypassOverride('PT_CalcEV');
        ECO_TriggerSettings.bypassOverride('PT_BatchSnaps');
        ECO_TriggerSettings.bypassOverride('PT_setProjectDates');
        update projectTasksToUpdate;
        ECO_TriggerSettings.clearOverride('PT_setProjectDates');
        ECO_TriggerSettings.clearOverride('PT_BatchSnaps');
        ECO_TriggerSettings.clearOverride('PT_CalcEV');
        ECO_TriggerSettings.clearBypassTrigger('PT');
    }   

    public static Map<Id, BudgetHeader__c> mapBudgetHeaders = new Map<Id, BudgetHeader__c>();
   
    public static void setCurrency(List<BudgetTask__c> newBTasksList) {
        if (!run || ECO_TriggerSettings.isBypassed('BT_setCurrency')) {
            return;
        }

        Set<Id> btIds = new Set<Id>();
        Set<Id> bhIds = new Set<Id>();
        
        Map<Id, String> mapCurrencies = new Map<Id, String>();

        for (BudgetTask__c bt : newBTasksList) {
            if (!mapBudgetHeaders.containsKey(bt.BudgetHeader__c)) {
                bhIds.add(bt.BudgetHeader__c);
            }
        }

        if (bhIds.size() > 0) {
            mapBudgetHeaders.putAll([Select Id, Project__r.ProjectFunctionalCurrencyCode__c From BudgetHeader__c Where Id in :bhIds]);
        }

        // Optimized away. Using the same currency map in ECO_BudgetAssignmentTriggers to save heap and even more SOQL
        /*
        for(BudgetHeader__c budgetHeader : [Select Id, Project__r.ProjectFunctionalCurrencyCode__c From BudgetHeader__c Where Id in :bhIds]) {
            mapCurrencies.put(budgetHeader.Id, budgetHeader.Project__r.ProjectFunctionalCurrencyCode__c);
        }
        */

        for (BudgetTask__c bt : newBTasksList) {
            bt.CurrencyIsoCode = mapBudgetHeaders.get(bt.BudgetHeader__c).Project__r.ProjectFunctionalCurrencyCode__c;          
        }
    }
}