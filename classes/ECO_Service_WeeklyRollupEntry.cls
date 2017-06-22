public with sharing class ECO_Service_WeeklyRollupEntry {
    public static void recalculate(Set<Id> projectIds) {
        List<WeeklyRollupEntry__c> oldEntries = [select id from WeeklyRollupEntry__c where Project__c in :projectIds];
        delete oldEntries;

        List<EarnedValueSnapshot__c> snaps = [select id from EarnedValueSnapshot__c where ProjectTask__r.pse__Project__c in :projectIds];
        delete snaps;

        List<pse__Project_Task__c> taskList = [select id, pse__Project__c, pse__Start_Date__c, pse__End_Date__c from pse__Project_Task__c where pse__Project__c in :projectIds];

        ECO_ProjectTaskTriggers.setProjectDates(taskList);

        // ECO_ProjectTaskTriggers.recalculateProjects(projectIds, true, false);  // deprecated per Omar

        id firstelement = new list<id>(projectIds)[0];

        Id batchJobId = Database.executeBatch(new ECO_RecalculateEVSBatch(firstelement), 10);
/*
        String query = 'Select ' + ECO_ProjectTasksSelector.csvFields +' FROM pse__Project_Task__c where pse__Project__c in :projectIds';
        
        List<pse__Project_Task__c> tasks = Database.query(query);

        ECO_Service_EarnedValue.processTasks(tasks);


        List<EarnedValueSnapshot__c> snaps1 = [select id, WeekStartDate__c, ProjectTask__c from EarnedValueSnapshot__c where ProjectTask__r.pse__Project__c in :projectIds];

        Map<String, EarnedValueSnapshot__c> snapsMap = new Map<String, EarnedValueSnapshot__c>();

        for (EarnedValueSnapshot__c snap : snaps1) {
            Date dtx = snap.WeekStartDate__c;
            dtx = Eco_Service_Snapshots.getFirstDateOfWeek(dtx);
            Datetime dt = datetime.newInstance(dtx.year(), dtx.month(),dtx.day());

            String key = snap.ProjectTask__c + dt.format('yyyyMMdd');
            System.debug('putkey - ' + key);

            snapsMap.put(key, snap);

            snap.AcctBurdenedCost__c = 0;
            snap.AcctRawCost__c = 0;
            snap.ProjectFunctionalBurdenedCost__c = 0;
            snap.ProjectFunctionalRawCost__c = 0;
        }

        List<ExpendItem__c> items = [select id, CurrentPADate__c, ProjectTask__c, ProjectBurdenedCost__c, ProjectRawCost__c, ProjectFunctionalBurdenedCost__c, ProjectFunctionalRawCost__c from ExpendItem__c where Project__c in :projectIds];
        
        boolean useExpItems = true;
        boolean useCDLs = true;
        
        if (useExpItems) {  // For now, use CDLs ONLY to compute EVS for actuals
            System.debug(LoggingLevel.WARN,'___Using ExpendItem__c for snapshots');

            for (ExpendItem__c item : items) {
                Date dtx = item.CurrentPADate__c;

                if(dtx == null)
                    continue;

                dtx = Eco_Service_Snapshots.getFirstDateOfWeek(dtx);
                Datetime dt = datetime.newInstance(dtx.year(), dtx.month(),dtx.day());

                String key = item.ProjectTask__c + dt.format('yyyyMMdd');

                System.debug('key - ' + key);

                EarnedValueSnapshot__c snapLookup = snapsMap.get(key);

                if (snapLookup != null) {
                    snapLookup.AcctBurdenedCost__c += ECO_Utils_String.NullCheck(item.ProjectBurdenedCost__c);
                    snapLookup.AcctRawCost__c += ECO_Utils_String.NullCheck(item.ProjectRawCost__c);
                    snapLookup.ProjectFunctionalBurdenedCost__c += ECO_Utils_String.NullCheck(item.ProjectFunctionalBurdenedCost__c);
                    snapLookup.ProjectFunctionalRawCost__c += ECO_Utils_String.NullCheck(item.ProjectFunctionalRawCost__c);
                }
            }

            update snaps1;
        }
       
        if (useCDLs) {
            System.debug(LoggingLevel.WARN,'___Using CostDistLine__c for snapshots');

            update snaps1;

            ECO_TriggerSettings.bypass('CDL_SubtractAmountsFromEarnedValueSnapshots');

            List<CostDistLine__c> lines = [SELECT Name, CostReportCategory__c, CreatedById, CreatedDate, CurrencyIsoCode, DENOMBurdenedCost__c, DENOMCurrencyCode__c, DENOMRawCost__c, IsDeleted, ExpenditureItem__c, ExpenditureResourceType__c, ExternalId__c, GLDate__c, GLFiscalMonth__c, GLPeriodName__c, LastModifiedById, LastModifiedDate, LineNumber__c, OracleSyncError__c, OracleSyncStatus__c, PADate__c, PAFiscalMonth__c, PAPeriodName__c, PLReportCategory__c, ProjectBurdenedCost__c, ProjectCurrencyCode__c, ProjectFunctionalBurdenedCost__c, ProjectFunctionalCurrencyCode__c, ProjectFunctionalRawCost__c, ProjectNumber__c, ProjectRawCost__c, Quantity__c, RecalculateEVSMetrics__c, Id, SystemModstamp, TaskNumber__c FROM CostDistLine__c where ExpenditureItem__r.Project__c in :projectIds];
            System.debug(LoggingLevel.WARN,'lines.size()='+lines.size());
            ECO_CostDistributionLineTriggers.rollupCosts(lines, lines);
        }
        */
    }
}