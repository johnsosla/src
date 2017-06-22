public without sharing class ECO_CostDistributionLineTriggers {
    
    public static Boolean run = true;
    
    public static void rollUpCosts (List<CostDistLine__c> tOld, List<CostDistLine__c> tNew) {
        try {
            if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('CDL_rollup')) {
                return;
            }
            
            Set<String> costDistLineSet = new Set<String>();
            Set<String> ExpenditureItemSet = new Set<String>();
            
            Map<String, CostDistLine__c> costDistMap = new Map<String, CostDistLine__c>();
            Map<String, CostDistLine__c> oldCostDistMap = new Map<String, CostDistLine__c>();
            Map<String, Decimal> mFunctionalRawCost = new Map<String, Decimal>();
            Map<String, Decimal> mFunctionalBurdenedCost = new Map<String, Decimal>();
            Map<String, Decimal> snapshotQtyMap = new Map<String, Decimal>();
            Map<String, Decimal> oldSnapshotQtyMap = new Map<String, Decimal>();
            Map<String, Decimal> snapshotResourceTypeMap = new Map<String, Decimal>();
            Map<String, Decimal> oldSnapshotResourceTypeMap = new Map<String, Decimal>();
            Map<String, Decimal> costProductCostMap = new Map<String, Decimal>();
            Map<String, Decimal> oldCostProductCostMap = new Map<String, Decimal>();
            Map<String, Decimal> costProductBurdenedMap = new Map<String, Decimal>();
            Map<String, Decimal> oldCostProductBurdenedMap = new Map<String, Decimal>();
            Map<String, Boolean> RecalculateEVSMetricsmap = new Map<String, Boolean>();
            Map<String, Decimal> snapshotResourceTypeBurdenedMap = new Map<String, Decimal>();
            Map<String, Decimal> oldSnapshotResourceTypeBurdenedMap = new Map<String, Decimal>();
            Map<String, Date> snapshotKeyPADateMap = new Map<String, Date>();
            Set<Id> allProjectIds = new Set<Id>();
            Set<Id> allProjectTaskIds = new Set<Id>();

            Map<Id, String> currencyMap = new Map<Id, String>();
          
             // if CDL_RemoveAmountsFromEarnedValueSnapshots is bypassed, treat CDL updates as an insert
            // this is a double negative! if the bypass is set, we do not want to subtract amounts
            // if the bypass is NOT set, we DO want to subtract the old amounts before adding the new
            boolean subtractAmountsFromEarnedValueSnapshots = ! ECO_TriggerSettings.isBypassed('CDL_SubtractAmountsFromEarnedValueSnapshots');
    
            if (tNew != null) {
                //System.debug('__tNew=' + tNew);
                System.debug('__tNew.size=' + tNew.size());
                
                for (CostDistLine__c oCDL : tNew) {

                    costDistLineSet.add(ocdl.id);
                                      
                    String projectnumber = (id) oCDL.ProjectNumber__c;
                    String tasknumber = (id) oCDL.TaskNumber__c;
                    allProjectIds.add(projectnumber);
                    allProjectTaskIds.add(tasknumber);

                    String sSnapshotKey = 
                        ECO_Service_Snapshots.DateToSnapshotKey(oCDL.PADate__c, projectNumber, tasknumber);
                    //System.debug('__sSnapshotKey=' + sSnapshotKey);
                    
                    snapshotKeyPADateMap.put(sSnapshotKey, oCDL.PADate__c); // Used for creating new EVS entries
                    
                    ExpenditureItemSet.add(oCDL.ExpenditureItem__c);
                    Decimal dFunctionalRawCost = 
                        ECO_Utils_String.NullCheck(mFunctionalRawCost.get(sSnapshotKey)) + 
                        ECO_Utils_String.NullCheck(oCDL.ProjectFunctionalRawCost__c);
                    mFunctionalRawCost.put(sSnapshotKey, dFunctionalRawCost);
                    
                    Decimal dFunctionalBurdenedCost = 
                        ECO_Utils_String.NullCheck(mFunctionalBurdenedCost.get(sSnapshotKey)) + 
                        ECO_Utils_String.NullCheck(oCDL.ProjectFunctionalBurdenedCost__c);
                    mFunctionalBurdenedCost.put(sSnapshotKey, dFunctionalBurdenedCost);
                    //System.debug('__tNEW 0: sSnapshotKey='+sSnapshotKey+
                      //  ', dFunctionalBurdenedCost='+dFunctionalBurdenedCost);
                     
                    RecalculateEVSMetricsmap.put(sSnapshotKey, ocdl.RecalculateEVSMetrics__c);
                    
                    //System.debug('oCDL.PLReportCategory__c--------'+oCDL.PLReportCategory__c);
                    if (oCDL.PLReportCategory__c != null)
                    {
                        costDistMap.put(sSnapshotKey, oCDL);
                        String strkey = sSnapshotKey + oCDL.PLReportCategory__c;
                        RecalculateEVSMetricsmap.put(strkey,ocdl.RecalculateEVSMetrics__c);
    
                        Decimal dQuantity = 
                            ECO_Utils_String.NullCheck(snapshotQtyMap.get(strkey)) + 
                            ECO_Utils_String.NullCheck(oCDL.Quantity__c);
                        if (ocdl.Quantity__c != null)
                            snapshotQtyMap.put(strkey, dQuantity);
                         
                        if (costProductCostMap.containsKey(strkey))
                        {
                           Decimal d = 0;
                           if (oCDL.ProjectFunctionalRawCost__c != null) {
                               d = costProductCostMap.get(strkey) + oCDL.ProjectFunctionalRawCost__c;
                               costProductCostMap.put(strkey, d);
                           }
                        }
                        else
                        {
                            Decimal d = 0;
                            if (oCDL.ProjectFunctionalRawCost__c != null)
                            {
                                d = oCDL.ProjectFunctionalRawCost__c;
                                costProductCostMap.put(strkey,d);
                            }
                        }
                        
                        if (costProductBurdenedMap.containsKey(strkey))
                        {
                            Decimal d = 0;
                            if (oCDL.ProjectFunctionalBurdenedCost__c != null)                            {
                                
                                d = costProductBurdenedMap.get(strkey) + oCDL.ProjectFunctionalBurdenedCost__c;
                                costProductBurdenedMap.put(strkey ,d);
                            }
                        }
                        else
                        {
                            Decimal d = 0;
                            if (oCDL.ProjectFunctionalBurdenedCost__c != null)
                            {
                                d = oCDL.ProjectFunctionalBurdenedCost__c;
                                costProductBurdenedMap.put(strkey,d);
                            }
                        }
                    }
                    //System.debug('__tNew: costProductBurdenedMap=' + costProductBurdenedMap);
                   
                    //System.debug('__tNew: oCDL.CostReportCategory__c='+oCDL.CostReportCategory__c);
                    if (oCDL.CostReportCategory__c != null)
                    {    
                         String key;
                         if (oCDL.CostReportCategory__c =='LABOR')
                            key = sSnapshotKey+'LAB';
                         else
                            key = sSnapshotKey+'NonLAB';
                    
                         //System.debug('__tNew: key='+key);
                
                         RecalculateEVSMetricsmap.put(key,ocdl.RecalculateEVSMetrics__c);  
                     
                         if (snapshotResourceTypeMap.containsKey(key))
                         {
                             if (oCDL.ProjectFunctionalRawCost__c != null)
                             {
                                 Decimal d = snapshotResourceTypeMap.get(key) + oCDL.ProjectFunctionalRawCost__c;
                                 //System.Debug(System.LoggingLevel.WARN, '___oCDL.ProjectFunctionalRawCost__c='+
                                 //    oCDL.ProjectFunctionalRawCost__c);
                                 //System.Debug(System.LoggingLevel.WARN, '___key='+key);
                                 snapshotResourceTypeMap.put(key,d);
                             }
                         }
                         else
                         {
                             Decimal d = 0;
                             if (oCDL.ProjectFunctionalRawCost__c != null)
                                 d = oCDL.ProjectFunctionalRawCost__c;
                                 
                             //System.Debug(System.LoggingLevel.WARN, '___oCDL.ProjectFunctionalRawCost__c='+
                             //    oCDL.ProjectFunctionalRawCost__c);
                             //System.Debug(System.LoggingLevel.WARN, '___sSnapshotKey='+sSnapshotKey);
                             snapshotResourceTypeMap.put(Key,d);
                         }
                     
                         if (snapshotResourceTypeBurdenedMap.containsKey(key))
                         {
                             if (oCDL.ProjectFunctionalBurdenedCost__c != null)
                             {
                                 Decimal d = snapshotResourceTypeBurdenedMap.get(key) + 
                                     oCDL.ProjectFunctionalBurdenedCost__c;                           
                                 snapshotResourceTypeBurdenedMap.put(key,d);
                             }
                         }
                         else
                         {
                             Decimal d = 0;                        
                             if (oCDL.ProjectFunctionalBurdenedCost__c != null)
                             {
                                 d = oCDL.ProjectFunctionalBurdenedCost__c;
                                 snapshotResourceTypeBurdenedMap.put(Key,d);
                             }
                         }
                         
                         // System.debug('__tNew: snapshotResourceTypeBurdenedMap='+snapshotResourceTypeBurdenedMap);
                    }
                }

                List<pse__Proj__c> projectList = [select id, ProjectFunctionalCurrencyCode__c from pse__Proj__c where id in :allProjectIds];

                for (pse__Proj__c theProject : projectList) {
                    if (theProject.ProjectFunctionalCurrencyCode__c != null)
                        currencyMap.put(theProject.id, theProject.ProjectFunctionalCurrencyCode__c);
                }
            }
                
            System.debug('__costProductCostMap= '+costProductCostMap);
            
            if (tOld != null && subtractAmountsFromEarnedValueSnapshots) {
                //System.debug('__tOld=' + tOld);
                System.debug('__tOld.size=' + tOld.size());
                
                for (CostDistLine__c oCDL : tOld) {
                    //System.debug('__tOld 0: mFunctionalBurdenedCost='+mFunctionalBurdenedCost);
                    costDistLineSet.add(ocdl.id);
                    String projectnumber = (id) oCDL.ProjectNumber__c;
                    String tasknumber = (id) oCDL.TaskNumber__c;
                    allProjectIds.add(projectnumber);
                    allProjectTaskIds.add(tasknumber);
                    
                    String sSnapshotKey = 
                        ECO_Service_Snapshots.DateToSnapshotKey(oCDL.PADate__c, projectnumber, tasknumber);
                    //System.debug('___tOld: sSnapshotKey='+sSnapshotKey);
                    
                    ExpenditureItemSet.add(oCDL.ExpenditureItem__c);
                    Decimal dFunctionalRawCost = 
                        ECO_Utils_String.NullCheck(mFunctionalRawCost.get(sSnapshotKey)) - 
                        ECO_Utils_String.NullCheck(oCDL.ProjectFunctionalRawCost__c);
                    mFunctionalRawCost.put(sSnapshotKey, dFunctionalRawCost);
    
                    Decimal dFunctionalBurdenedCost = 
                        ECO_Utils_String.NullCheck(mFunctionalBurdenedCost.get(sSnapshotKey)) - 
                        ECO_Utils_String.NullCheck(oCDL.ProjectFunctionalBurdenedCost__c);
                    
                    mFunctionalBurdenedCost.put(sSnapshotKey, dFunctionalBurdenedCost);
                    //System.debug('__tOLD 0: sSnapshotKey='+sSnapshotKey+
                      //  ', dFunctionalBurdenedCost='+dFunctionalBurdenedCost);
    
                    if (costDistLineSet.contains(oCDL.id))
                    {
                        if (oCDL.PLReportCategory__c != null)
                        {
                            oldCostDistMap.put(sSnapshotKey ,oCDL);
                            String strkey = sSnapshotKey + oCDL.PLReportCategory__c;
                            
                            if (!RecalculateEVSMetricsmap.containsKey(strkey))
                                RecalculateEVSMetricsmap.put(strkey,ocdl.RecalculateEVSMetrics__c);
                                
                            Decimal dQuantity = 
                                ECO_Utils_String.NullCheck(oldSnapshotQtyMap.get(strkey)) + 
                                ECO_Utils_String.NullCheck(oCDL.Quantity__c);
                            if (ocdl.Quantity__c != null)
                                oldSnapshotQtyMap.put(strkey, dQuantity);
                            
                            if (oldCostProductCostMap.containsKey(strkey))
                            {
                                Decimal d = 0;
                                if (oCDL.ProjectFunctionalRawCost__c != null)                            {
                                    
                                    d = oldCostProductCostMap.get(strkey) + oCDL.ProjectFunctionalRawCost__c;
                                    oldCostProductCostMap.put(strkey ,d);
                                }
                            }
                            else
                            {
                                Decimal d = 0;
                                if (oCDL.ProjectFunctionalRawCost__c != null)
                                {
                                    d = oCDL.ProjectFunctionalRawCost__c;
                                    oldCostProductCostMap.put(strkey,d);
                                }
                            }
                            
                            if (oldCostProductBurdenedMap.containsKey(strkey))
                            {
                                Decimal d = 0;
                                if (oCDL.ProjectFunctionalBurdenedCost__c != null)                            
                                {
                                    d = oldCostProductBurdenedMap.get(strkey) + oCDL.ProjectFunctionalBurdenedCost__c;
                                    oldCostProductBurdenedMap.put(strkey ,d);
                                }
                            }
                            else
                            {
                                Decimal d = 0;
                                if (oCDL.ProjectFunctionalBurdenedCost__c != null)
                                {
                                    d = oCDL.ProjectFunctionalBurdenedCost__c;
                                    oldCostProductBurdenedMap.put(strkey,d);
                                }
                            }
                        }
                    }
                    //System.debug('__tNew: oldCostProductBurdenedMap=' + oldCostProductBurdenedMap);
                    
                    if (oCDL.CostReportCategory__c != null)
                    {
                         String key;
                         if (oCDL.CostReportCategory__c == 'LABOR')
                            key = sSnapshotKey+'LAB';
                         else
                           key = sSnapshotKey+'NonLAB'; 
                           
                         if (oldSnapshotResourceTypeMap.containsKey(key))
                         {
                             if (oCDL.ProjectFunctionalRawCost__c != null)
                             {
                                 Decimal d = oldSnapshotResourceTypeMap.get(key) + oCDL.ProjectFunctionalRawCost__c;                           
                                 oldSnapshotResourceTypeMap.put(key,d);
                             }
                         }
                         else
                         {
                             Decimal d = 0;
                            
                             if (oCDL.ProjectFunctionalRawCost__c != null)
                             {
                                 d = oCDL.ProjectFunctionalRawCost__c;
                                 oldSnapshotResourceTypeMap.put(Key,d);
                             }
                         }
                         
                         if (oldSnapshotResourceTypeBurdenedMap.containsKey(key))
                         {
                             if (oCDL.ProjectFunctionalBurdenedCost__c != null)
                             {
                                 Decimal d = oldSnapshotResourceTypeBurdenedMap.get(key) + oCDL.ProjectFunctionalBurdenedCost__c;                           
                                 oldSnapshotResourceTypeBurdenedMap.put(key,d);
                             }
                         }
                         else
                         {
                             Decimal d = 0;                        
                             if (oCDL.ProjectFunctionalBurdenedCost__c != null)
                             {
                                 d = oCDL.ProjectFunctionalBurdenedCost__c;
                                 oldSnapshotResourceTypeBurdenedMap.put(Key,d);
                             }
                         }
                    }
                }
            }

            /* do-nothing loop across all CDLs for the ExpenditureItems for the CDL batch we're processing  -- 2016-06-08- jow
            if (ExpenditureItemSet.size()>0)
            {
                for (CostDistLine__c cd: [SELECT id,ExpenditureItem__c,PADate__c,ProjectFunctionalRawCost__c,
                    ProjectRawCost__c,ProjectNumber__c,TaskNumber__c,
                    CostReportCategory__c, ExpenditureItem__r.PLReportCategory__c, ExpenditureItem__r.Quantity__c  
                    FROM CostDistLine__c WHERE ExpenditureItem__c IN :ExpenditureItemSet ]) {
                    
                    //if (!projectFunctionalCurrencies.containsKey(cd.ProjectNumber__c))
                    //    projectFunctionalCurrencies.put(cd.ProjectNumber__c, cd.ExpenditureItem__r.Project__c.ProjectFunctionalCurrencyCode__c);
                    
                    String sSnapshotKey = 
                        ECO_Service_Snapshots.DateToSnapshotKey(cd.PADate__c, cd.ProjectNumber__c, cd.TaskNumber__c);
                }
            }
            */
                    
            
            Set<String> lSnapshotKeys = new Set<String>();
            //System.debug('costProductCostMap----------'+costProductCostMap);
            //System.debug('oldCostProductCostMap----------'+oldCostProductCostMap);
           
            for (String s : mFunctionalRawCost.keySet()) {
                lSnapshotKeys.add(s);
            }
    
            for (String s : mFunctionalBurdenedCost.keySet()) {
                lSnapshotKeys.add(s);
            }
    
            System.debug('__lSnapshotKeys='+lSnapshotKeys);
            
            List<EarnedValueSnapshot__c> lEarnedValueSnapshots = 
                new List<EarnedValueSnapshot__c>([SELECT Id
                                                        , SnapshotKey__c
                                                        , ProjectFunctionalRawCost__c
                                                        , ProjectFunctionalRawCostPLODCEXPS__c
                                                        , ProjectFunctionalRawCostPLODCSUBS__c
                                                        , ProjectFunctionalRawCostPLLabor__c
                                                        , ProjectFunctionalRawCostPLFringe__c
                                                        , ProjectFunctionalRawCostPLOverhead__c
                                                        , ProjectFunctionalRawCostResourceNonLabor__c
                                                        , ProjectFunctionalRawCostResourceLabor__c
                                                        , ProjectHours__c
                                                        , ProjectFunctionalBurdenedCost__c 
                                                        , ProjFuncBurdenedCostPLODCEXPS__c
                                                        , ProjFuncBurdenedCostPLODCSUBS__c
                                                        , ProjFuncBurdenedCostPLLabor__c
                                                        , ProjFuncBurdenedCostPLFringe__c
                                                        , ProjFuncBurdenedCostPLOverhead__c
                                                        , ProjFuncBurdenedCostReportNonLabor__c
                                                        , ProjFuncBurdenedCostReportLabor__c
                                                  FROM EarnedValueSnapshot__c 
                                                  WHERE SnapshotKey__c in :lSnapshotKeys]);
    
            System.debug('__3: lEarnedValueSnapshots.size='+lEarnedValueSnapshots.size());
            //System.debug('__3: lEarnedValueSnapshots'+lEarnedValueSnapshots);
            
            // Added to support US-4706
            Map<Id,String> projectFunctionalCurrencies = new Map<Id,String>();
            List<pse__Proj__c> allProjects = [Select ID, ProjectFunctionalCurrencyCode__c From pse__Proj__c WHERE ID in :allProjectIds];
            for(pse__Proj__c project:allProjects){
                projectFunctionalCurrencies.put(project.id,project.ProjectFunctionalCurrencyCode__c);
            }
            allProjects.clear();
            
            Map<Id,Date> projectTaskStartDateWeekStartDays = new Map<Id,Date>();
            List<pse__Project_Task__c> allProjectTasks = [Select ID, pse__Start_Date__c From pse__Project_Task__c WHERE ID in :allProjectTaskIds];
            for(pse__Project_Task__c projTask:allProjectTasks){
                projectTaskStartDateWeekStartDays.put(projTask.id,ECO_Service_Snapshots.getFirstDateOfWeek(projTask.pse__Start_Date__c));
            }
            allProjectTasks.clear();

            // START US-4706
            // DO WE HAVE AN EVS FOR EACH AND EVERY CDL? If not, create the WRE and EVS
            
            for (EarnedValueSnapshot__c oEarnedValueSnapshot : lEarnedValueSnapshots) {
                lSnapshotKeys.remove( oEarnedValueSnapshot.SnapshotKey__c);
                snapshotKeyPADateMap.remove(oEarnedValueSnapshot.SnapshotKey__c);
            }
            
            List<WeeklyRollupEntry__c> neededWREList = new List<WeeklyRollupEntry__c>();
            Set<String> neededKeyWRESet = new Set<String>();
            
            Map<String, EarnedValueSnapshot__c> neededEvsMap = 
                new Map<String, EarnedValueSnapshot__c>();
            
            Map<String, String> snapshotKeyValuesMap = new Map<String, String>();
            
            for (String neededKeyEVS: lSnapshotKeys) {
                snapshotKeyValuesMap = ECO_Service_Snapshots.snapshotKeyValues(neededKeyEVS);
                Date PADate = snapshotKeyPADateMap.get(neededKeyEVS);
                Date weekStartDateRunning = ECO_Service_Snapshots.getFirstDateOfWeek(PADate);
                Id projectId = snapshotKeyValuesMap.get('projectId');
                neededKeyWRESet.add(ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, 
                    projectId));
            }
            
            List<WeeklyRollupEntry__c> wreList = [SELECT CompositeKey__c, Id FROM WeeklyRollupEntry__c 
                    WHERE CompositeKey__c IN : neededKeyWRESet];
            
            Map<String, WeeklyRollupEntry__c> existingWREMap = 
                new Map<String, WeeklyRollupEntry__c>();
            
            for (WeeklyRollupEntry__c wre : wreList) {
                existingWREMap.put(wre.CompositeKey__c, wre);
            }    
            
            for (WeeklyRollupEntry__c wre : existingWREMap.values()) {
                neededKeyWRESet.remove(wre.CompositeKey__c);
            }
            
            Map<String, List<EarnedValueSnapshot__c>> wreToEvsMap = 
                new Map<String, List<EarnedValueSnapshot__c>>();
            
            for (String neededKeyEVS: lSnapshotKeys) {  
                //Create an empty EVS, add to lEarnedValueSnapshots
                //make sure the EVS has the right fields so it will create WRE, etc.
                 
                snapshotKeyValuesMap = ECO_Service_Snapshots.snapshotKeyValues(neededKeyEVS);
                Id projectId = snapshotKeyValuesMap.get('projectId');
                Id projectTaskId = snapshotKeyValuesMap.get('taskId');
                
                Date PADate = snapshotKeyPADateMap.get(neededKeyEVS);
                Date weekStartDateRunning = ECO_Service_Snapshots.getFirstDateOfWeek(PADate);
                Integer daysBetween = projectTaskStartDateWeekStartDays.get(projectTaskId).daysBetween(weekStartDateRunning);
                Integer weekNum = (daysBetween/7)+1;

                // EVS:
                // KEEP THIS FIELD LIST ALIGNED WITH ECO_SERVICE_EARNEDVALUE.CLS (two places there)
                EarnedValueSnapshot__c newEVSnap = new EarnedValueSnapshot__c();
                newEVSnap.CurrencyISOCode = projectFunctionalCurrencies.get(projectId);
                newEVSnap.ProjectTask__c = projectTaskId;
                newEVSnap.CompositeKey__c = newEVSnap.ProjectTask__c+'_'+weekNum;
                newEVSnap.SnapshotKey__c = neededKeyEVS;
                // newEVSnap.WeeklyRollupEntry__r // assigned later
                newEVSnap.WeekStartDate__c = weekStartDateRunning; //snapshotKeyPADateMap.get(neededKey);
                newEVSnap.ThisWeekNumber__c = weekNum;         
                newEVSnap.ThisWeekAmount__c = 0;       // there is by definition no plan for this week, so zero budgeted/planned cost
                newEVSnap.ThisWeekAmountEst__c = 0;    // there is by definition no plan for this week, so zero budgeted/planned cost
                newEVSnap.ProjectFunctionalBurdenedCost__c = mFunctionalBurdenedCost.get(neededKeyEVS);
                newEVSnap.ProjectFunctionalRawCost__c = mFunctionalRawCost.get(neededKeyEVS);

                /*
                EarnedValueSnapshot__c newEVSnap = new EarnedValueSnapshot__c();
                newEVSnap.CurrencyISOCode = projTask.pse__Project__r.ProjectFunctionalCurrencyCode__c;
                newEVSnap.ProjectTask__c = projTask.Id;
                newEVSnap.CompositeKey__c = projTask.Id+'_'+weekNum;
                newEVSnap.SnapshotKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c, projTask.Id);
                newEVSnap.WeeklyRollupEntry__r = new WeeklyRollupEntry__c(CompositeKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c));
                newEVSnap.WeekStartDate__c = weekStartDateRunning;
                newEVSnap.ThisWeekNumber__c = weekNum;
                newEVSnap.ThisWeekAmount__c = taskAmount;
                newEVSnap.ThisWeekAmountEst__c = taskAmountEstimate;
                // End cut-and-paste with eco_service_earnedValue.cls
                */
                
                String wreCompositeKey = 
                    ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projectId);
                
                /// WRE: 
                WeeklyRollupEntry__c wre = existingWREMap.get(wreCompositeKey);
                if (wre == null) { // Non-Existing WRE
                    if (!wreToEvsMap.containsKey(wreCompositeKey)){
                        wreToEvsMap.put(wreCompositeKey,new List<EarnedValueSnapshot__c>());

                        String currencyCode = currencyMap.get(projectId);

                        wre = new WeeklyRollupEntry__c(CompositeKey__c = wreCompositeKey,
                            Project__c = projectId, PeriodStartDate__c = weekStartDateRunning,
                            CurrencyISOCode = currencyCode);
                        
                        neededWREList.add(wre);
                    }
                    wreToEvsMap.get(wreCompositeKey).add(newEVSnap);
                }
                else {
                    newEVSnap.WeeklyRollupEntry__c = wre.Id; // Existing WRE
                }
                
                neededEVSMap.put(newEVSnap.SnapshotKey__c, newEVSnap);
            }
             
            if (! neededEVSMap.isEmpty()) {
                try {
                    insert neededWREList;
                    
                    // link the EVS to the generated WREs
                    for (WeeklyRollupEntry__c wre : neededWREList) {
                        for (EarnedValueSnapshot__c tmpEVSnap:wreToEvsMap.get(wre.CompositeKey__c)){
                            tmpEVSnap.WeeklyRollupEntry__c = wre.Id;
                        }
                    }
                    insert neededEVSMap.values();
                    lEarnedValueSnapshots.addAll(neededEVSMap.values());
                }
                catch(DMLException e){
                    ECO_Service_ErrorLog.logException(e);
                }
            }
            System.debug('__4: lEarnedValueSnapshots.size='+lEarnedValueSnapshots.size());
            
            // END US-4706
    
            List<EarnedValueSnapshot__c> lEarnedValueSnapshotsToUpdate = 
                new List<EarnedValueSnapshot__c>();
    
            for (EarnedValueSnapshot__c oEarnedValueSnapshot : lEarnedValueSnapshots) {
                String sSnapshotKey = oEarnedValueSnapshot.SnapshotKey__c;
                
                boolean bRecordToAdd = false;
    
                if (mFunctionalRawCost.containsKey(sSnapshotKey)) {
                    oEarnedValueSnapshot.ProjectFunctionalRawCost__c = 
                        ECO_Utils_String.NullCheck(oEarnedValueSnapshot.ProjectFunctionalRawCost__c) + 
                        ECO_Utils_String.NullCheck(mFunctionalRawCost.get(sSnapshotKey));
                    
                    bRecordToAdd = true;
                }
    
                //System.debug('__3: mFunctionalBurdenedCost='+mFunctionalBurdenedCost);
                if (mFunctionalBurdenedCost.containsKey(sSnapshotKey)) {
                    //System.debug('___oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c='+oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c);
                    //System.debug('___mFunctionalBurdenedCost='+mFunctionalBurdenedCost.get(sSnapshotKey));
                    Decimal a = oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c;
                    Decimal b = mFunctionalBurdenedCost.get(sSnapshotKey);
                    Decimal c = ECO_Utils_String.NullCheck(oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c);
                    Decimal d =  ECO_Utils_String.NullCheck(mFunctionalBurdenedCost.get(sSnapshotKey));
                    Decimal e = c + d;
                     
                    oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c = 
                        ECO_Utils_String.NullCheck(oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c) + 
                        ECO_Utils_String.NullCheck(mFunctionalBurdenedCost.get(sSnapshotKey));
                    //System.debug('___oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c='+oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c);
                    
                    bRecordToAdd = true;
                }
                //System.debug('__3: oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c='+
                //    oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c);
                
                if (costDistMap.containsKey(sSnapshotKey) || oldCostDistMap.containsKey(sSnapshotKey)) {
                     
                    String odckey = sSnapshotKey+'ODC - Exps';
                    //System.debug('ProjectFunctionalRawCostPLODCEXPS__c----------'+oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCEXPS__c);
                    //System.debug('ProjectFunctionalRawCostPLODCEXPS__c----------'+costProductCostMap.containsKey(odckey));
                    //System.debug('costProductCostMap.get(odckey)----------'+costProductCostMap.get(odckey));
                    //System.debug('oldCostProductCostMap---------'+oldCostProductCostMap.get(odckey));
                    
                    //System.debug('ProjFuncBurdenedCostPLODCEXPS__c----------'+oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c);
                     
                    if (oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCEXPS__c == null)
                      oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCEXPS__c = 0;
                    if (oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCSUBS__c == null)
                      oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCSUBS__c = 0;
                    if (oEarnedValueSnapshot.ProjectFunctionalRawCostPLLabor__c == null)
                      oEarnedValueSnapshot.ProjectFunctionalRawCostPLLabor__c = 0;
                    if (oEarnedValueSnapshot.ProjectFunctionalRawCostPLFringe__c == null)
                      oEarnedValueSnapshot.ProjectFunctionalRawCostPLFringe__c = 0;
                    if (oEarnedValueSnapshot.ProjectFunctionalRawCostPLOverhead__c == null)
                      oEarnedValueSnapshot.ProjectFunctionalRawCostPLOverhead__c = 0;
                    
                    if (oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c == null)
                      oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c = 0;
                    if (oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCSUBS__c == null)
                      oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCSUBS__c = 0;
                    if (oEarnedValueSnapshot.ProjFuncBurdenedCostPLLabor__c == null)
                      oEarnedValueSnapshot.ProjFuncBurdenedCostPLLabor__c = 0;
                    if (oEarnedValueSnapshot.ProjFuncBurdenedCostPLFringe__c == null)
                      oEarnedValueSnapshot.ProjFuncBurdenedCostPLFringe__c = 0;
                    if (oEarnedValueSnapshot.ProjFuncBurdenedCostPLOverhead__c == null)
                      oEarnedValueSnapshot.ProjFuncBurdenedCostPLOverhead__c = 0;
                    if (oEarnedValueSnapshot.ProjectHours__c ==null )
                        oEarnedValueSnapshot.ProjectHours__c = 0;
                
                    //System.debug('RecalculateEVSMetricsmap--------'+RecalculateEVSMetricsmap);     
                    if (oldCostProductCostMap.containsKey(odckey))
                    {
                        if (oldCostProductCostMap.get(odckey)!= null && oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCEXPS__c!= null) //&& RecalculateEVSMetricsmap.get(odckey) == false)                        
                            oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCEXPS__c =  oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCEXPS__c - oldCostProductCostMap.get(odckey);
                    }
                    if (costProductCostMap.containsKey(odckey))
                    {   
                        if (costProductCostMap.get(odckey)!= null) //&& oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCEXPS__c!= null)
                            oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCEXPS__c = oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCEXPS__c + costProductCostMap.get(odckey);                      
                    }
                    String odcsubkey = sSnapshotKey+'ODC - Subs';                   
                    if (oldCostProductCostMap.containsKey(odcsubkey))
                    {
                        if (oldCostProductCostMap.get(odcsubkey)!= null && oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCSUBS__c != null) //&& RecalculateEVSMetricsmap.get(odcsubkey) == false)
                            oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCSUBS__c =  oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCSUBS__c - oldCostProductCostMap.get(odcsubkey);
                    }
                    if (costProductCostMap.containsKey(odcsubkey))
                    {
                        if (costProductCostMap.get(odcsubkey)!= null)  //&&  oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCSUBS__c!= null)
                            oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCSUBS__c =  oEarnedValueSnapshot.ProjectFunctionalRawCostPLODCSUBS__c + costProductCostMap.get(odcsubkey);                   
                    }
                    
                    String Laborkey = sSnapshotKey+'Labor';                      
                    if (oldCostProductCostMap.containsKey(Laborkey))
                    {
                        if (oldCostProductCostMap.get(Laborkey)!= null && oEarnedValueSnapshot.ProjectFunctionalRawCostPLLabor__c  != null) //&& RecalculateEVSMetricsmap.get(Laborkey) == false)
                            oEarnedValueSnapshot.ProjectFunctionalRawCostPLLabor__c =  oEarnedValueSnapshot.ProjectFunctionalRawCostPLLabor__c - oldCostProductCostMap.get(Laborkey);
                    }
                    if (costProductCostMap.containsKey(Laborkey))
                    {
                        if (costProductCostMap.get(Laborkey)!= null) //&& oEarnedValueSnapshot.ProjectFunctionalRawCostPLLabor__c != null)
                            oEarnedValueSnapshot.ProjectFunctionalRawCostPLLabor__c = oEarnedValueSnapshot.ProjectFunctionalRawCostPLLabor__c +costProductCostMap.get(Laborkey);                   
                    }
                    
                    String Fringekey = sSnapshotKey+'Fringe';                   
                    if (oldCostProductCostMap.containsKey(Fringekey))
                    {
                        if (oldCostProductCostMap.get(Fringekey)!= null && oEarnedValueSnapshot.ProjectFunctionalRawCostPLFringe__c != null) //&& RecalculateEVSMetricsmap.get(Fringekey) == false)
                            oEarnedValueSnapshot.ProjectFunctionalRawCostPLFringe__c =  oEarnedValueSnapshot.ProjectFunctionalRawCostPLFringe__c - oldCostProductCostMap.get(Fringekey);
                    }
                    if (costProductCostMap.containsKey(Fringekey))
                    {
                        if (costProductCostMap.get(Fringekey)!= null) //&& oEarnedValueSnapshot.ProjectFunctionalRawCostPLFringe__c != null)
                            oEarnedValueSnapshot.ProjectFunctionalRawCostPLFringe__c =  oEarnedValueSnapshot.ProjectFunctionalRawCostPLFringe__c + costProductCostMap.get(Fringekey);
                    }
                    
                    String Overheadkey = sSnapshotKey+'Overhead';                   
                    if (oldCostProductCostMap.containsKey(Overheadkey))
                    {
                        if (oldCostProductCostMap.get(Overheadkey)!= null && oEarnedValueSnapshot.ProjectFunctionalRawCostPLOverhead__c != null) //&& RecalculateEVSMetricsmap.get(Overheadkey) == false)
                            oEarnedValueSnapshot.ProjectFunctionalRawCostPLOverhead__c =  oEarnedValueSnapshot.ProjectFunctionalRawCostPLOverhead__c - oldCostProductCostMap.get(Overheadkey);
                    }
                    if (costProductCostMap.containsKey(Overheadkey))
                    {
                        if (oldCostProductCostMap.get(Overheadkey)!= null) //&& oEarnedValueSnapshot.ProjectFunctionalRawCostPLOverhead__c != null)
                            oEarnedValueSnapshot.ProjectFunctionalRawCostPLOverhead__c =  oEarnedValueSnapshot.ProjectFunctionalRawCostPLOverhead__c +costProductCostMap.get(Overheadkey);
                    }  
                    
                    //System.debug('__odckey='+odckey);
                    //System.debug('__oldCostProductBurdenedMap='+oldCostProductBurdenedMap);  
                    if (oldCostProductBurdenedMap.containsKey(odckey))
                    {
                        if (oldCostProductBurdenedMap.get(odckey)!= null && oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c!= null) //&& RecalculateEVSMetricsmap.get(odckey) == false)
                            oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c = oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c - oldCostProductBurdenedMap.get(odckey);
                    }
                    //System.debug('__4a: oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c='+oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c); 
                        
                    //System.debug('__costProductBurdenedMap='+costProductBurdenedMap);   
                    if (costProductBurdenedMap.containsKey(odckey))
                    {   
                        if (costProductBurdenedMap.get(odckey)!= null) //&& oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c!= null)
                        oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c = oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c + costProductBurdenedMap.get(odckey);                      
                    }
                    //System.debug('__4b: oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c='+oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCEXPS__c); 
                    
                    if (oldCostProductBurdenedMap.containsKey(odcsubkey))
                    {
                        if (oldCostProductBurdenedMap.get(odcsubkey)!= null && oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCSUBS__c!= null) //&& RecalculateEVSMetricsmap.get(odcsubkey) == false)
                            oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCSUBS__c =  oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCSUBS__c - oldCostProductBurdenedMap.get(odcsubkey);
                    }
                    if (costProductBurdenedMap.containsKey(odcsubkey))
                    {   
                        if (costProductBurdenedMap.get(odcsubkey)!= null ) //&& oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCSUBS__c!= null)
                            oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCSUBS__c = oEarnedValueSnapshot.ProjFuncBurdenedCostPLODCSUBS__c + costProductBurdenedMap.get(odcsubkey);                      
                    }
                    
                    if (oldCostProductBurdenedMap.containsKey(Laborkey))
                    {
                        if (oldCostProductBurdenedMap.get(Laborkey)!= null && oEarnedValueSnapshot.ProjFuncBurdenedCostPLLabor__c!= null) //&& RecalculateEVSMetricsmap.get(Laborkey) == false)
                            oEarnedValueSnapshot.ProjFuncBurdenedCostPLLabor__c =  oEarnedValueSnapshot.ProjFuncBurdenedCostPLLabor__c - oldCostProductBurdenedMap.get(Laborkey);
                    }
                    if (costProductBurdenedMap.containsKey(Laborkey))
                    {   
                        if (costProductBurdenedMap.get(Laborkey)!= null) //&& oEarnedValueSnapshot.ProjFuncBurdenedCostPLLabor__c!= null)
                            oEarnedValueSnapshot.ProjFuncBurdenedCostPLLabor__c = oEarnedValueSnapshot.ProjFuncBurdenedCostPLLabor__c + costProductBurdenedMap.get(Laborkey);                      
                    }
                        
                    if (oldCostProductBurdenedMap.containsKey(Fringekey))
                    {
                        if (oldCostProductBurdenedMap.get(Fringekey)!= null && oEarnedValueSnapshot.ProjFuncBurdenedCostPLFringe__c!= null) //&& RecalculateEVSMetricsmap.get(Fringekey) == false)
                            oEarnedValueSnapshot.ProjFuncBurdenedCostPLFringe__c =  oEarnedValueSnapshot.ProjFuncBurdenedCostPLFringe__c - oldCostProductBurdenedMap.get(Fringekey);
                    }
                    if (costProductBurdenedMap.containsKey(Fringekey))
                    {   
                        if (costProductBurdenedMap.get(Fringekey)!= null) //&& oEarnedValueSnapshot.ProjFuncBurdenedCostPLFringe__c!= null)
                            oEarnedValueSnapshot.ProjFuncBurdenedCostPLFringe__c = oEarnedValueSnapshot.ProjFuncBurdenedCostPLFringe__c + costProductBurdenedMap.get(Fringekey);                      
                    }
                    
                    if (oldCostProductBurdenedMap.containsKey(Overheadkey))
                    {
                        if (oldCostProductBurdenedMap.get(Overheadkey)!= null && oEarnedValueSnapshot.ProjFuncBurdenedCostPLOverhead__c!= null) //&& RecalculateEVSMetricsmap.get(Overheadkey) == false)
                            oEarnedValueSnapshot.ProjFuncBurdenedCostPLOverhead__c =  oEarnedValueSnapshot.ProjFuncBurdenedCostPLOverhead__c - oldCostProductBurdenedMap.get(Overheadkey);
                    }
                    if (costProductBurdenedMap.containsKey(Overheadkey))
                    {   
                        if (costProductBurdenedMap.get(Overheadkey)!= null) //&& oEarnedValueSnapshot.ProjFuncBurdenedCostPLOverhead__c!= null)
                            oEarnedValueSnapshot.ProjFuncBurdenedCostPLOverhead__c = oEarnedValueSnapshot.ProjFuncBurdenedCostPLOverhead__c + costProductBurdenedMap.get(Overheadkey);                      
                    }                                    
                    
                    if (oldSnapshotQtyMap.containsKey(Laborkey)) {
                        //if (RecalculateEVSMetricsmap.get(sSnapshotKey) == false && oldSnapshotQtyMap.get(sSnapshotKey) != null)
                        if (oldSnapshotQtyMap.get(Laborkey) != null)
                        oEarnedValueSnapshot.ProjectHours__c = oEarnedValueSnapshot.ProjectHours__c - oldSnapshotQtyMap.get(Laborkey);
                    }  
                    if (snapshotQtyMap.containsKey(Laborkey)) {
                        if (snapshotQtyMap.get(Laborkey) != null)
                        oEarnedValueSnapshot.ProjectHours__c = oEarnedValueSnapshot.ProjectHours__c + snapshotQtyMap.get(Laborkey);
                    }      
                    
                    bRecordToAdd = true;              
                }
                
                //System.debug('oldSnapshotResourceTypeMap----------'+oldSnapshotResourceTypeMap);
                //System.debug('snapshotResourceTypeMap----------'+snapshotResourceTypeMap);
                
                if (oEarnedValueSnapshot.ProjectFunctionalRawCostResourceLabor__c == null)
                    oEarnedValueSnapshot.ProjectFunctionalRawCostResourceLabor__c = 0;
                if (oEarnedValueSnapshot.ProjectFunctionalRawCostResourceNonLabor__c == null)
                    oEarnedValueSnapshot.ProjectFunctionalRawCostResourceNonLabor__c = 0;
                if (oEarnedValueSnapshot.ProjFuncBurdenedCostReportLabor__c == null)
                     oEarnedValueSnapshot.ProjFuncBurdenedCostReportLabor__c =0;
                if (oEarnedValueSnapshot.ProjFuncBurdenedCostReportNonLabor__c == null)
                    oEarnedValueSnapshot.ProjFuncBurdenedCostReportNonLabor__c = 0; 
                    
                if (oldSnapshotResourceTypeMap.containsKey(sSnapshotKey+'LAB'))
                {
                    if (oldSnapshotResourceTypeMap.get(sSnapshotKey+'LAB') != null) //&& RecalculateEVSMetricsmap.get(sSnapshotKey+'LAB') == false)
                    oEarnedValueSnapshot.ProjectFunctionalRawCostResourceLabor__c = 
                        oEarnedValueSnapshot.ProjectFunctionalRawCostResourceLabor__c - oldSnapshotResourceTypeMap.get(sSnapshotKey+'LAB');
                    bRecordToAdd = true;  
                }
                
                if (oldSnapshotResourceTypeMap.containsKey(sSnapshotKey+'NonLAB'))
                {
                    if (oldSnapshotResourceTypeMap.get(sSnapshotKey+'NonLAB') != null) //&& RecalculateEVSMetricsmap.get(sSnapshotKey+'NonLAB') == false)
                    oEarnedValueSnapshot.ProjectFunctionalRawCostResourcenonLabor__c = 
                        oEarnedValueSnapshot.ProjectFunctionalRawCostResourcenonLabor__c - oldSnapshotResourceTypeMap.get(sSnapshotKey+'NonLAB');
                    bRecordToAdd = true;  
                }
                
                if (snapshotResourceTypeMap.containsKey(sSnapshotKey+'LAB'))
                {
                    oEarnedValueSnapshot.ProjectFunctionalRawCostResourceLabor__c = 
                        oEarnedValueSnapshot.ProjectFunctionalRawCostResourceLabor__c + snapshotResourceTypeMap.get(sSnapshotKey+'LAB');
                    bRecordToAdd = true;  
                }
                
                if (snapshotResourceTypeMap.containsKey(sSnapshotKey+'NonLAB'))
                {
                    oEarnedValueSnapshot.ProjectFunctionalRawCostResourcenonLabor__c = 
                        oEarnedValueSnapshot.ProjectFunctionalRawCostResourcenonLabor__c + snapshotResourceTypeMap.get(sSnapshotKey+'NonLAB');
                    bRecordToAdd = true;  
                }
                
                if (oldSnapshotResourceTypeBurdenedMap.containsKey(sSnapshotKey+'LAB'))
                {
                    if (oldSnapshotResourceTypeBurdenedMap.get(sSnapshotKey+'LAB') != null) //&& RecalculateEVSMetricsmap.get(sSnapshotKey+'LAB') == false)
                        oEarnedValueSnapshot.ProjFuncBurdenedCostReportLabor__c = oEarnedValueSnapshot.ProjFuncBurdenedCostReportLabor__c - oldSnapshotResourceTypeBurdenedMap.get(sSnapshotKey+'LAB');
                    bRecordToAdd = true;  
                }
                
                if (oldSnapshotResourceTypeBurdenedMap.containsKey(sSnapshotKey+'NonLAB'))
                {
                    if (oldSnapshotResourceTypeBurdenedMap.get(sSnapshotKey+'NonLAB') != null) //&& RecalculateEVSMetricsmap.get(sSnapshotKey+'NonLAB') == false)
                        oEarnedValueSnapshot.ProjFuncBurdenedCostReportNonLabor__c = oEarnedValueSnapshot.ProjFuncBurdenedCostReportNonLabor__c - oldSnapshotResourceTypeBurdenedMap.get(sSnapshotKey+'NonLAB');
                    bRecordToAdd = true;  
                }
                
                if (snapshotResourceTypeBurdenedMap.containsKey(sSnapshotKey+'LAB'))
                {
                    if (snapshotResourceTypeBurdenedMap.get(sSnapshotKey+'LAB') != null) {
                        oEarnedValueSnapshot.ProjFuncBurdenedCostReportLabor__c = 
                            oEarnedValueSnapshot.ProjFuncBurdenedCostReportLabor__c + 
                            snapshotResourceTypeBurdenedMap.get(sSnapshotKey+'LAB');
                    }
                    bRecordToAdd = true;  
                }
                
                if (snapshotResourceTypeBurdenedMap.containsKey(sSnapshotKey+'NonLAB'))
                {
                    if (snapshotResourceTypeBurdenedMap.get(sSnapshotKey+'NonLAB') != null) {
                        oEarnedValueSnapshot.ProjFuncBurdenedCostReportNonLabor__c = 
                            oEarnedValueSnapshot.ProjFuncBurdenedCostReportNonLabor__c + 
                            snapshotResourceTypeBurdenedMap.get(sSnapshotKey+'NonLAB');
                    }
                    bRecordToAdd = true;  
                }
                
                // If null, set to zero
                if (oEarnedValueSnapshot.ProjectFunctionalRawCostResourceNonLabor__c == null) {
                    oEarnedValueSnapshot.ProjectFunctionalRawCostResourceNonLabor__c = 0;
                }
                // If null, set to zero
                if (oEarnedValueSnapshot.ProjectFunctionalRawCostResourceLabor__c == null) {
                    oEarnedValueSnapshot.ProjectFunctionalRawCostResourceLabor__c = 0;
                }
                
                oEarnedValueSnapshot.ProjectFunctionalRawCost__c = 
                    oEarnedValueSnapshot.ProjectFunctionalRawCostResourcenonLabor__c + 
                    oEarnedValueSnapshot.ProjectFunctionalRawCostResourceLabor__c;
                
                //System.debug('__8: oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c='+
                //    oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c);
                   
                oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c = 
                    oEarnedValueSnapshot.ProjFuncBurdenedCostReportLabor__c + 
                    oEarnedValueSnapshot.ProjFuncBurdenedCostReportNonLabor__c;
                //System.debug('__9: oEarnedValueSnapshot.ProjFuncBurdenedCostReportLabor__c='+
                //    oEarnedValueSnapshot.ProjFuncBurdenedCostReportLabor__c);
                //System.debug('__9: oEarnedValueSnapshot.ProjFuncBurdenedCostReportNonLabor__c='+
                //    oEarnedValueSnapshot.ProjFuncBurdenedCostReportNonLabor__c);                   
                //System.debug('__9: oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c='+
                //    oEarnedValueSnapshot.ProjectFunctionalBurdenedCost__c);
                          
                if (bRecordToAdd)
                    lEarnedValueSnapshotsToUpdate.add(oEarnedValueSnapshot);
    
                //System.debug('__oEVS [After]='+oEarnedValueSnapshot);
            }
    
            if (!lEarnedValueSnapshotsToUpdate.isEmpty()) {
                //System.debug('lEarnedValueSnapshotsToUpdate----'+lEarnedValueSnapshotsToUpdate[0].id);
                System.debug('__lEarnedValueSnapshotsToUpdate.size----'+lEarnedValueSnapshotsToUpdate.size());
                update lEarnedValueSnapshotsToUpdate;
            }
        }
        catch( Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
    }
    
    public static void calculateFiscalMonths(List<CostDistLine__c> costDistLines) {
        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('CDL_calcFiscalMonths')) {
            return;
        }
        
        List<date> endDateList = new List<date>();
        Set<Date> datesToConvert = new Set<Date>();
        Map<Date, String> mapTimePeriodCodeByDate = new Map<Date, String> ();

        for (CostDistLine__c ba : costDistLines) {
            datesToConvert.add(ba.GLDate__c);
            datesToConvert.add(ba.PADate__c);

            if (ba.GLDate__c != null) {
                endDateList.add((ba.GLDate__c).addmonths(2));
                endDateList.add((ba.GLDate__c).addmonths(-3));
            }
        }
        datesToConvert.remove(null);

        System.debug('endDateList----' + endDateList);
        List<pse__Time_Period__c> timePeriods  = new  List<pse__Time_Period__c>();
        if (endDateList.size() > 0) {
            // Time period
            timePeriods = ECO_Utils_Date.calcTimePeriods(endDateList, 'Month');

            // Calculate all the timeperiod codes at once and cache the results
            pse__Time_Period__c fm = null;
            for (Date dt : datesToConvert) {
                fm = ECO_Utils_Date.getFiscalPeriod(dt, 0, timePeriods);
                if (fm != null) {
                    mapTimePeriodCodeByDate.put(dt, fm.TimePeriodCode__c);
                }
            }

            for (CostDistLine__c cdl : costDistLines) {
                for (Integer i = 0; i < timePeriods.size(); i++) {
                    if (cdl.GLDate__c != null) {
                        cdl.GLFiscalMonth__c = mapTimePeriodCodeByDate.get(cdl.GLDate__c);
                    }

                    if (cdl.PADate__c != null) {
                        cdl.PAFiscalMonth__c = mapTimePeriodCodeByDate.get(cdl.PADate__c);
                    }
                }
            }
        }
    }
}