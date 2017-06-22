public without sharing class ECO_BudgetAssignmentTriggers {
    public static Boolean run = true;
    public static Integer runCount = 0;
    public static Map<Id, BudgetTask__c> mapBudgetTasks = new Map<Id, BudgetTask__c>();
    
    public static void setCurrency(List<BudgetAssignment__c> baNew) {
        if (!run || ECO_TriggerSettings.isBypassed('BA_setCurrency')) {
            return;
        }

        Set<Id> btIds = new Set<Id>();

        for (BudgetAssignment__c ba : baNew) {
            // Check if we already cached it before we add it to the list to query
            if (!mapBudgetTasks.containsKey(ba.budgetTask__c)) {
                btIds.add(ba.budgetTask__c);
            }
        }   

        // Save the SOQL hit if we already have everything we need cached
        if (btIds.size() > 0) {
            // Get project currency and work type to assign to budget assignments later
            mapBudgetTasks.putAll( [Select Id, ProjectTask__r.WorkTypeName__c, BudgetHeader__r.Project__r.ProjectFunctionalCurrencyCode__c 
                                            From BudgetTask__c 
                                            Where Id IN :btIds]);
        }

        for (BudgetAssignment__c ba : baNew) {
            BudgetTask__c budgetTask = mapBudgetTasks.get(ba.BudgetTask__c);
            ba.CurrencyIsoCode = budgetTask.BudgetHeader__r.Project__r.ProjectFunctionalCurrencyCode__c;
            ba.WorkTypeName__c = budgetTask.ProjectTask__r.WorkTypeName__c;
        }
    }

    public static void setRateDefaults(List<BudgetAssignment__c> baNew) {
        if (!run || ECO_TriggerSettings.isBypassed('BA_setRateDefaults')) {
            return;
        }

        Set<Id> budgetResourceIds = new Set<Id>();
        for (BudgetAssignment__c ba : baNew) {
            budgetResourceIds.add(ba.BudgetResource__c);
        }
        
        Map<Id, BudgetResource__c> mapBudgetResourceById = new Map<Id, BudgetResource__c> (
                                                            [SELECT Id, 
                                                                OverrideRatesOnLines__c, 
                                                                OverrideRawCost__c, 
                                                                OverrideFringeMultiplier__c,
                                                                OverrideOverheadMultiplier__c,
                                                                OverrideFringeMultiplierField__c,
                                                                OverrideOverheadMultiplierField__c,
                                                                MarginType__c,
                                                                OverrideBillRate__c,
                                                                OverrideUplift__c,
                                                                SetZeroETC__c 
                                                            FROM BudgetResource__c 
                                                            WHERE Id IN :budgetResourceIds]);
       if ( ! mapBudgetResourceById.isEmpty() ) System.debug(mapBudgetResourceById);
            
        for (BudgetAssignment__c ba : baNew) {
            BudgetResource__c br = mapBudgetResourceById.get(ba.BudgetResource__c);
            ECO_BudgetResourceTriggers.setRatesEqual(br, ba);
        }
    }

    public static Decimal ifNull(Decimal val) {
        return val == null ? 0 : val;
    }

    public static BudgetAssignment__c customClone(BudgetAssignment__c ba, Set<String> fieldsToClone) {
        BudgetAssignment__c newBa = new BudgetAssignment__c();
        for (String fieldName : fieldsToClone) {
            newBa.put(fieldName, ba.get(fieldName));
        }

        return newBa;
    }

   public static void setEACDefaults (List<BudgetAssignment__c> baNew) {
        /*
        if (!run || ECO_TriggerSettings.isBypassed('BA_setEAcDefaults')) {
            return;
        }
        */
        Set<Id> baNewIds = new Set<ID>();
        for (BudgetAssignment__c ba : baNew) {
            baNewIds.add(ba.Id);
        }

        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.BudgetAssignment__c.fields.getMap();
        Set<String> fieldsToClone = new Set<String> ();

        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult dfr = fieldMap.get(fieldName).getDescribe();
            List <Schema.sObjectType> refs = dfr.getReferenceTo();
            if (refs.size() == 0 && (dfr.isUpdateable() || dfr.isCreateable()) ){
                fieldsToClone.add(fieldName);
            }
        }
        system.debug('fieldsToClone: ' + fieldsToClone);
        // [TODO] Get rid ofsoql query and instantiate new sobject instead
         // Map <Id, BudgetAssignment__c> mapBaByIds = new Map <Id, BudgetAssignment__c> ([Select Id, AppliedTtlRawCst__c FROM BudgetAssignment__c WHERE Id IN :baNewIds]);
         for (BudgetAssignment__c ba : baNew) {  
            /*  
            Oracle won't import a change order if the quantity is zero so we have to make sure
            that ePM matches by setting all the costs to 0
            */
            /*
            if (ba.Quantity__c == 0) {
                ba.OverrideTotalFringe__c = 0;
                ba.OverrideTotalOverhead__c = 0;
            } else {
                // Reset fringe and overhead in case quantity goes back to being non-zero //
                ba.OverrideTotalFringe__c = null;
                ba.OverrideTotalOverhead__c = null;
            }
            */
            if (ba.useEACCalc__c == true) {
                /** Calc cost **/
               // if (ba.Quantity__c != 0) {
                    ba.AppliedTtlRawCst__c = ifNull(ba.EACActualCostRollup__c) 
                        + ifNull(ba.EACAppliedETCRawCost__c)
                        - ifNull(ba.EACForecastRawCost__c);
                //} else {
                  //  ba.AppliedTtlRawCst__c = 0;
               // }

                /** Calc Revenue **/
                ba.CalcRevTrigger__c = ifNull(ba.EACRevisedRevenue__c) - ifNull(ba.EACForecastRevenueNumber__c);
            } else {
                Decimal oldAppliedTtlRawCst = ba.AppliedTtlRawCst__c;
                // system.debug('ba.TotalRawCost__c - ' + ba.TotalRawCost__c);
                ba.AppliedTtlRawCst__c = ifNull(ba.TotalRawCost__c);

                
                /*
                fakeBa.AppliedTtlRawCst__c = ba.AppliedTtlRawCst__c;
                fakeBa.OverrideUplift__c = ba.OverrideUplift__c;
                fakeBa.Quantity__c = ba.Quantity__c;
                fakeBa.OverrideBillRate__c = ba.OverrideBillRate__c;
                fakeBa.OverrideRawCost__c = ba.OverrideRawCost__c;
                fakeBa.OverrideTotalRawCost__c = ba.OverrideTotalRawCost__c;
                fakeBa.MarginType__c = ba.MarginType__c;
                */

                

                /*
                system.debug(LoggingLevel.DEBUG, '+++Real BA: ' + ba );
                system.debug(LoggingLevel.DEBUG, '---Fake BA: ' + fakeBa );
                system.debug(LoggingLevel.DEBUG, 'OverrideUplift__c: ' + ba.MarginAmountCostTimesUplift__c + ' (fake)' + fakeBa.MarginAmountCostTimesUplift__c );

                system.debug(LoggingLevel.DEBUG, 'OverrideUplift__c: ' + ba.OverrideUplift__c + ' (fake)' + fakeBa.OverrideUplift__c );
                */
                if (ba.OverrideTotalRevenue__c == null) {
                    BudgetAssignment__c fakeBa;
                    if (oldAppliedTtlRawCst != ba.AppliedTtlRawCst__c) {
                        fakeBa = customClone(ba, fieldsToClone);
                        fakeBa.recalculateFormulas();
                    } else {
                        fakeBa = ba;
                    }

                    if (ba.MarginType__c == 'Percent') {
                        ba.CalcRevTrigger__c = fakeBa.MarginAmountCostTimesUplift__c;
                    } else if (ba.MarginType__c == 'Multiplier') {
                        ba.CalcRevTrigger__c = (ifNull(fakeBa.TotalRawCost__c)*(ifNull(fakeBa.OverrideUplift__c))) /* + ifNull(fakeBa.TotalFringe__c) + ifNull(fakeBa.TotalOverhead__c) */ ;
                    } else {
                        ba.CalcRevTrigger__c = ifNull(fakeBa.MarginAmountQtyTimesRate__c);
                    }
                } else {
                    ba.CalcRevTrigger__c = ba.OverrideTotalRevenue__c;
                }
            }
         }
         
    }

    public static void setDefaults (List<BudgetAssignment__c> baNew) {
        if (!run || ECO_TriggerSettings.isBypassed('BA_setDefaults')) {
            return;
        }
        
        Set<Id> budgetResourceIds = new Set<Id>();
        for (BudgetAssignment__c ba : baNew) {
            budgetResourceIds.add(ba.BudgetResource__c);
        }
        
        Map<Id, String> budgetResourceIdToApprovalStatusMap = new Map<Id, String>();
        for (BudgetResource__c br : [SELECT Id 
                                        , BudgetHeader__r.Status__c
                                    FROM BudgetResource__c 
                                    WHERE Id IN :budgetResourceIds]) {
            budgetResourceIdToApprovalStatusMap.put(br.Id, br.BudgetHeader__r.Status__c);
        }
        
        for (BudgetAssignment__c ba : baNew) {
            ba.ApprovalStatus__c = budgetResourceIdToApprovalStatusMap.get(ba.BudgetResource__c);

        }
    }


    public static void calculateMultiplierOmar(List<BudgetAssignment__c> baNew) {
        if (!run || ECO_TriggerSettings.isBypassed('BA_calculateMultiplier')) {
            return;
        }

        Set<Id> baIds = new Set<Id>();
        Set<String> allExpenditureTypes = new Set<String>();

        /*
        for (BudgetAssignment__c ba : baNew) {
            baIds.add(ba.id);
        }

        List<BudgetAssignment__c> budgetAssignments = [select id, ProjectTask__r.OrgID__c, BudgetTask__r.ProjectTask__r.Burden_Reference_Schedule_Name__c, BudgetResource__r.Resource__r.User__r.ExpenditureType__c from BudgetAssignment__c where id in :baIds];
        */
        Set<String> scheduleNames = new Set<String>();
        Map<String, String> mapParentOrgs = new Map<String, String>();
        Set<String> orgIds = new Set<String>();
        Set<String> needed = new Set<String>();

        for (BudgetAssignment__c ba : baNew) {
            if (ba.OracleRateScheduleName__c != null) {
                scheduleNames.add(ba.OracleRateScheduleName__c);
                orgIds.add(ba.OrgId__c);
                needed.add(ba.OrgId__c);
                orgIds.add(ba.Project_OrgId__c);
                needed.add(ba.Project_OrgId__c);
            }
            allExpenditureTypes.add(ba.ExpenditureType__c);
        }

        // If there's no budget assignments with burden schedules then we can skip processing
        if (scheduleNames.size() == 0) {
            return;
        }

        List<BurdenSchedule__c> burdenSchedules = [select id, CostCode__c, CostPlusStructure__c, Multiplier__c, OracleRateScheduleName__c, OrgId__c from BurdenSchedule__c where OracleRateScheduleName__c in :scheduleNames];
        Set<String> costPlusStructures = new Set<String>();
        Map<String, Set<String>> scheduleNameToCostPlusStructures = new Map<String, Set<String>>();
        Map<String, String> scheduleNameToCostPlusStructure = new Map<String, String>();

        Map<String, Decimal> costCodeMap2 = new Map<String, Decimal>();

        for (BurdenSchedule__c burdenSchedule : burdenSchedules) {
            String keyx = burdenSchedule.CostCode__c + '~' + burdenSchedule.OracleRateScheduleName__c +'~' + burdenSchedule.OrgId__c;
            costCodeMap2.put(keyx, burdenSchedule.Multiplier__c);
            costPlusStructures.add(burdenSchedule.CostPlusStructure__c);
            scheduleNameToCostPlusStructure.put(burdenSchedule.OracleRateScheduleName__c, burdenSchedule.CostPlusStructure__c);
        }


        /** Query Burden Structure with with cost plus Structure and the Expenditure type (from the user) **/
        List<BurdenStructure__c> burdenStructures = [select id, ExpenditureType__c, CostCode__c, CostPlusStructure__c from BurdenStructure__c where CostPlusStructure__c in :costPlusStructures];

        Map<String, Set<String>> costCodeMap = new Map<String, Set<String>>();

        for (BurdenStructure__c burdenStructure : burdenStructures) {
            String key = burdenStructure.CostPlusStructure__c + '~' + burdenStructure.ExpenditureType__c;

            Set<String> costCodes = costCodeMap.get(key);

            if (costCodes == null) {
                costCodes = new Set<String>();

                costCodeMap.put(key, costCodes);
            }

            system.debug(' burdenStructure.CostCode__c -  ' + key + ': ' + burdenStructure.CostCode__c);
            costCodes.add(burdenStructure.CostCode__c);
        }

        List<Burden_Org_Hierarchy__c> hierarchy = [select organization_id__c, parent_organization_id__c from burden_org_hierarchy__c where organization_id__c in :needed];

        while (hierarchy.size() > 0) {
            needed = new Set<String>();

            for (Burden_Org_Hierarchy__c level : hierarchy) {
                System.debug('here - ' + level.organization_id__c + ' - ' + level.parent_organization_id__c);

                orgIds.add(level.organization_id__c);

                if (level.parent_organization_id__c != null) {
                    needed.add(level.parent_organization_id__c);

                    mapParentOrgs.put(level.organization_id__c, level.parent_organization_id__c);

                    System.debug('putting parent map - ' + level.organization_id__c + ' - ' + level.parent_organization_id__c);
                }
            }

            hierarchy = [select organization_id__c, parent_organization_id__c from burden_org_hierarchy__c where organization_id__c in :needed and organization_id__c not in :orgIds];
        }

        orgIds.addAll(needed);

        for (BudgetAssignment__c ba : baNew) {
            if ( ba.ResourceType__c != 'Labor/Person' ) continue;
            String scheduleName = ba.OracleRateScheduleName__c;
            String orgId = (ba.OrgId__c == null) ? ba.Project_OrgId__c : ba.OrgId__c;

            system.debug(' scheduleName ' + scheduleName + ' - ' + orgId);

            String firstStructure = scheduleNameToCostPlusStructure.get(scheduleName);

            // all the cost structures are the same for a given burden schedule
            String costCodeKey = firstStructure + '~' + ba.ExpenditureType__c;
            // String key1 = budgetAssignment.OracleRateScheduleName__c + '~' + orgId;

            Set<String> costCodes = costCodeMap.get(costCodeKey);

            system.debug('---costCodes: ' + costCodes);
            
            if (costCodes == null || costCodes.size() == 0) continue;
            
            String costCode1 = new List<String>(costCodes)[0];

            while (orgId != null) {
                String keyx = costCode1 + '~' + scheduleName + '~' + orgId;
                Decimal multiplier = costCodeMap2.get(keyx);

                if (multiplier == null) {
                    orgId = mapParentOrgs.get(orgId);
                    System.debug('no code list found - going to parent - ' + orgId);

                    continue;
                } else {
                    system.debug('Found Multiplier');
                    break;
                }
            }

            for (String costCode : costCodes) {
                String keyx = costCode + '~' + scheduleName + '~' + orgId;
                Decimal multiplier = costCodeMap2.get(keyx);
                if ( multiplier == null) multiplier = 0;
                if (costCode.containsIgnoreCase('fringe')) {
                    ba.OverrideFringeMultiplier__c = 100*multiplier;
                    ba.OverrideFringeMultiplierField__c = 100*multiplier;
                } else if (costCode.containsIgnoreCase('overhead')) {
                    ba.OverrideOverheadMultiplier__c = 100*multiplier;
                    ba.OverrideOverheadMultiplierField__c = 100*multiplier;
                }
            }
        }

        Set<String> allCostCodes = new Set<String>();
        // Do we need this?
        /*
        for (BudgetAssignment__c budgetAssignment : budgetAssignments) {
            // [TODO]: Change reference scheduleName
            String scheduleName = budgetAssignment.BudgetTask__r.ProjectTask__r.Burden_Reference_Schedule_Name__c;
            String expenditureType = budgetAssignment.BudgetResource__r.Resource__r.User__r.ExpenditureType__c;
            
            Set<String> costPlusStructures2 = scheduleNameToCostPlusStructures.get(scheduleName);

            for (String costPlusStructure : costPlusStructures2) {
                String key = costPlusStructure + '~' + expenditureType;

                Set<String> costCodes = costCodeMap.get(key);

                allCostCodes.addAll(costCodes);
            }
        }

        */
    }

    public static void calculateMultiplier(List<BudgetAssignment__c> baNew) {
        if (!run || ECO_TriggerSettings.isBypassed('BA_calculateMultiplier')) {
            return;
        }

        Set<Id> baIds = new Set<Id>();

        for (BudgetAssignment__c ba : baNew) {
            baIds.add(ba.id);
        }

        List<BudgetAssignment__c> budgetAssignments = [select id, ProjectTask__r.OrgID__c, BudgetTask__r.ProjectTask__r.Burden_Reference_Schedule_Name__c, BudgetResource__r.Resource__r.User__r.ExpenditureType__c from BudgetAssignment__c where id in :baIds];

        Set<String> scheduleNames = new Set<String>();

        for (BudgetAssignment__c budgetAssignment : budgetAssignments) {
            scheduleNames.add(budgetAssignment.BudgetTask__r.ProjectTask__r.Burden_Reference_Schedule_Name__c);
        }

        List<BurdenSchedule__c> burdenSchedules = [select id, CostCode__c, CostPlusStructure__c, OracleRateScheduleName__c, Multiplier__c from BurdenSchedule__c where OracleRateScheduleName__c in :scheduleNames];

        Set<String> costPlusStructures = new Set<String>();
        Map<String, Set<String>> scheduleNameToCostPlusStructures = new Map<String, Set<String>>();
        // Map<String, List<BurdenSchedule__c>> costCodeMap = new Map<String, List<BurdenSchedule__c>>();

        for (BurdenSchedule__c burdenSchedule : burdenSchedules) {
            costPlusStructures.add(burdenSchedule.CostPlusStructure__c);
            
            Set<String> costPlusStructureSet = scheduleNameToCostPlusStructures.get(burdenSchedule.CostPlusStructure__c);

            if (costPlusStructureSet == null) {
                costPlusStructureSet = new Set<String>();

                scheduleNameToCostPlusStructures.put(burdenSchedule.CostPlusStructure__c, costPlusStructureSet);
            }

            costPlusStructureSet.add(burdenSchedule.OracleRateScheduleName__c);
        }

        List<BurdenStructure__c> burdenStructures = [select id, ExpenditureType__c, CostCode__c, CostPlusStructure__c from BurdenStructure__c where CostPlusStructure__c in :costPlusStructures];

        Map<String, Set<String>> costCodeMap = new Map<String, Set<String>>();

        for (BurdenStructure__c burdenStructure : burdenStructures) {
            String key = burdenStructure.CostPlusStructure__c + '~' + burdenStructure.ExpenditureType__c;

            Set<String> costCodes = costCodeMap.get(key);

            if (costCodes == null) {
                costCodes = new Set<String>();

                costCodeMap.put(key, costCodes);
            }

            costCodes.add(burdenStructure.CostCode__c);
        }

        Set<String> allCostCodes = new Set<String>();

        for (BudgetAssignment__c budgetAssignment : budgetAssignments) {
            String scheduleName = budgetAssignment.BudgetTask__r.ProjectTask__r.Burden_Reference_Schedule_Name__c;
            String expenditureType = budgetAssignment.BudgetResource__r.Resource__r.User__r.ExpenditureType__c;
            
            Set<String> costPlusStructures2 = scheduleNameToCostPlusStructures.get(scheduleName);

            for (String costPlusStructure : costPlusStructures2) {
                String key = costPlusStructure + '~' + expenditureType;

                Set<String> costCodes = costCodeMap.get(key);

                allCostCodes.addAll(costCodes);
            }
        }


        List<BurdenSchedule__c> burdenSchedules2 = [select id, CostCode__c, OrgID__c from BurdenSchedule__c where CostCode__c in :allCostCodes];

        Map<String, Set<String>> orgMap = new Map<String, Set<String>>();

        for (BurdenSchedule__c burdenSchedule : burdenSchedules2) {
            Set<String> orgIds = orgMap.get(burdenSchedule.CostCode__c);

            if (orgIds == null) {
                orgIds = new Set<String>();

                orgMap.put(burdenSchedule.CostCode__c, orgIds);
            }

            orgIds.add(burdenSchedule.OrgID__c);
        }

        for (BudgetAssignment__c budgetAssignment : budgetAssignments) {
            String scheduleName = budgetAssignment.BudgetTask__r.ProjectTask__r.Burden_Reference_Schedule_Name__c;
            String expenditureType = budgetAssignment.BudgetResource__r.Resource__r.User__r.ExpenditureType__c;
            
            Set<String> costPlusStructures2 = scheduleNameToCostPlusStructures.get(scheduleName);

            for (String costPlusStructure : costPlusStructures2) {
                String key = costPlusStructure + '~' + expenditureType;

                Set<String> costCodes = costCodeMap.get(key);

                for (String costCode : costCodes) {
                    Set<String> orgIds = orgMap.get(costCode);

                    for (String orgId : orgIds) {
                        if (orgId == budgetAssignment.ProjectTask__r.OrgID__c) {
                            System.debug('hey - ' + orgId + ' - ' + costCode + ' - ' + budgetAssignment.id);
                        }
                    }
                }
            }
        }

    }

    public static void calculateFiscalMonths(list<BudgetAssignment__c> budgetAssignments)
    {
    	if (!run || ECO_TriggerSettings.isBypassed('BA_calculateFiscalMonths')) {
            return;
        }
        
        /*list<date> enddatelist = new list<date>();
        for (BudgetAssignment__c ba : budgetAssignments){
             if (ba.EndDate__c != null){ 
                 
                 enddatelist.add((ba.EndDate__c).addmonths(2));
                 enddatelist.add((ba.EndDate__c).addmonths(-3));
             }
        }*/
        
        Set<Date> endDateSet = new Set<Date>();
        Set<Date> datesToConvert = new Set<Date>();
        Map<Date, String> mapTimePeriodCodeByDate = new Map<Date, String> ();
        Map<Date, String> mapPrevTimePeriodCodeByDate = new Map<Date, String> ();

        for (BudgetAssignment__c ba : budgetAssignments){
             if (ba.EndDate__c != null){ 
                datesToConvert.add(ba.EndDate__c);

                 endDateSet.add((ba.EndDate__c).addmonths(2));
                 endDateSet.add((ba.EndDate__c).addmonths(1));
                 endDateSet.add((ba.EndDate__c).addmonths(0));
                 endDateSet.add((ba.EndDate__c).addmonths(-1));
                 endDateSet.add((ba.EndDate__c).addmonths(-2));
                 endDateSet.add((ba.EndDate__c).addmonths(-3));
             }
        }
		System.Debug('___endDateSet size='+endDateSet.size());
        
       // System.Debug('endDateSet----'+endDateSet);
         List<pse__Time_Period__c> timePeriods  = new  List<pse__Time_Period__c>();

        if(endDateSet.size()>0)
        {
            // Time period
          List<Date> endDateList = new List<Date>(endDateSet);
          timePeriods = ECO_Utils_Date.calcTimePeriods(endDateList,'Month');

           // Calculate all the timeperiod codes at once and cache the results 
           // so the same dates don't have to get processed more than once
            pse__Time_Period__c fm = null;
            pse__Time_Period__c fm1 = null;

            for (Date dt : datesToConvert) {
                // could probably be optimized later IF NEEDED to combine both function calls to just 1
                fm = ECO_Utils_Date.getFiscalPeriod(dt, 0, timePeriods);
                fm1 = ECO_Utils_Date.getFiscalPeriod(dt, 1, timePeriods);
                if (fm != null) {
                    mapTimePeriodCodeByDate.put(dt, fm.TimePeriodCode__c);
                }
                if (fm1 != null) {
                    mapPrevTimePeriodCodeByDate.put(dt, fm1.TimePeriodCode__c);
                }
            }

            for (BudgetAssignment__c ba : budgetAssignments){
                if (ba.EndDate__c != null){ 
                    ba.EndDateFiscalMonth__c = mapTimePeriodCodeByDate.get(ba.EndDate__c);
                    ba.EndDatePreviousFiscalMonth__c = mapPrevTimePeriodCodeByDate.get(ba.EndDate__c);
                }
            }
        }
    }
}