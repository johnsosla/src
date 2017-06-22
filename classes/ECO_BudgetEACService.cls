public without sharing class ECO_BudgetEACService {

    // NOTE: For efficiency, AVOID System.Debug(), UNLESS they are within try/catch, 
    // OR calling Limits.getHeapSize()

    public class EacException extends Exception {}

    private static string EXPLABOR_UNIQUE_PREFIX = '$%$%LaborFringe/Overhead$%$%';

    private static BudgetHeader__c oBudgetHeader;
    private static pse__Proj__c project;
    private static Map<Id, BudgetTask__c> mBudgetTask;

    private static final String uniqueDelim = ':-:';
    private static Map<String, BudgetResource__c> mapResourceByPTMId;
    private static Map<String, BudgetResource__c> mapResourceBySubId;
    private static Map<String, BudgetResource__c> mapResourceByContingencyName;
    private static Map<String, BudgetResource__c> mapResourceByExpType;
    private static Map<String, List<BudgetAssignment__c>> mapAssignmentsByPTMId;
    private static Map<String, List<BudgetAssignment__c>> mapAssignmentsBySubId;
    private static Map<String, List<BudgetAssignment__c>> mapAssignmentsByContingencyName;
    private static Map<String, List<BudgetAssignment__c>> mapAssignmentsByExpType;

    private static Map<String, BudgetAssignment__c> mapAssignmentByUniqueId;
    private static Map<String, BudgetResource__c> mapResourcesByPersonId;

    private static BudgetResource__c labExpResource;
    private static BudgetResource__c labExpFringeResource;
    private static BudgetResource__c labExpOverheadResource;
    private static List<BudgetAssignment__c> labExpAssignments;

    private static ECO_ProjectTaskService ets = new ECO_ProjectTaskService();

    public static Boolean topTaskCostBudget;
    public static Boolean topTaskRevenueBudget;

    public static Map <Id, Id> mapTopBudgetTaskById = new Map <Id, Id>();
    
    public class EACActualTotal {
        public Decimal cost;
        public Decimal quantity;
        public Decimal fringe;
        public Decimal overhead;

        public EACActualTotal() {
            this(0,0,0,0);
        }

        public EACActualTotal(Decimal cost, Decimal quantity, Decimal fringe, Decimal overhead) {
            this.cost  = cost;
            this.quantity = quantity;
            this.overhead = overhead;
            this.fringe = fringe;
        }

        public void add(EACActualTotal totalsToAdd) {
            this.cost += ifNull(totalsToAdd.cost);
            this.quantity += ifNull(totalsToAdd.quantity);
            this.overhead += ifNull(totalsToAdd.overhead);
            this.fringe += ifNull(totalsToAdd.fringe);
        }
    }

    public static List<ECO_ProjectTask> projectTasks; 
    public static Map <Id,ECO_ProjectTask> mapTasks; 
    public static Map <Id, Id> mapPtIdByBtId = new Map <Id, Id>();

    public static void rollupTotals() {        
        //system.debug('topTaskCostBudget: ' + topTaskCostBudget);
        rollupActualsByType(mapAssignmentsByPTMId, mapResourceByPTMId);
        rollupActualsByType(mapAssignmentsBySubId, mapResourceBySubId);
        rollupActualsByType(mapAssignmentsByContingencyName, mapResourceByContingencyName);
        rollupActualsByType(mapAssignmentsByExpType, mapResourceByExpType);

        rollupActualsByType(new Map<String, List<BudgetAssignment__c>> { 'labexp' => labExpAssignments }, 
                            new Map<String, BudgetResource__c> { 'labexp' => labExpResource });        
    }

    public static EACActualTotal rollupTotals(ECO_ProjectTask ecoTask, Map<Id, BudgetAssignment__c> mapByTaskId) {
        EACActualTotal result = new EACActualTotal();

        // ets.projectTaskMap.get(mapTopBudgetTaskById.get(budgetTask.Id))

        BudgetAssignment__c ba = mapByTaskId.get(ecoTask.Id);
        if (ba != null) {
            result.cost = ifNull(ba.EACActualCost__c);
            result.quantity = ifNull(ba.EACActualQuantity__c);
            result.fringe = ifNull(ba.EACActualFringe__c);
            result.overhead = ifNull(ba.EACActualOverhead__c);
        }
         

        for (ECO_ProjectTask ecoTaskChild : ecoTask.children) {
            result.add(rollupTotals(ecoTaskChild, mapByTaskId));
        }

        return result;
    }

    private static void rollupActualsByType(Map<String, List<BudgetAssignment__c>> mapListAssignments, Map<String, BudgetResource__c> mapResourceByString) {
        

        Map <BudgetAssignment__c, List<BudgetAssignment__c>> mapAssignmentsByParent = new Map <BudgetAssignment__c, List<BudgetAssignment__c>>();

        for (String brKey : mapListAssignments.keySet()) {
            Map<Id, BudgetAssignment__c> mapByTaskId = new Map<Id, BudgetAssignment__c>();
            List<BudgetAssignment__c> bas = mapListAssignments.get(brKey);
            List<BudgetAssignment__c> tempBas = new List<BudgetAssignment__c>();

            //system.debug('brKey: ' + brKey + ' - ' + (bas != null ? bas.size() : -1));
            if (bas == null) continue;
            for (BudgetAssignment__c ba : bas) {
                if (!topTaskCostBudget) {
                    ba.EACActualCostRollup__c = ba.EACActualCost__c;
                    ba.EACActualQuantityRollup__c = ba.EACActualQuantity__c;
                    ba.EACActualOverheadRollup__c = ba.EACActualOverhead__c;
                    ba.EACActualFringeRollup__c = ba.EACActualFringe__c;
                } else {
                    mapByTaskId.put(mapPtIdByBtId.get(ba.BudgetTask__c), ba);

                }
            }
        
            //system.debug('mapByTaskId size: ' + mapByTaskId.size() );
            // If we're not a top task cost budget then don't waste time calculating rollups
            if (!topTaskCostBudget) continue;
            

            for (ECO_ProjectTask ecoTask : mapTasks.values()) {
                if (ecoTask.parent == null) {
                    BudgetAssignment__c topBa = mapByTaskId.get(ecoTask.Id);
                    EACActualTotal totalRollup = rollupTotals(ecoTask, mapByTaskId);

                    if ( topBa == null) {
                        // handle creating new budget assignments if they don't exist

                        topBa = new BudgetAssignment__c();
                        topBa.EACApprovedTotalCost__c = 0;
                        topBa.EACForecastTotalCost__c = 0;
                        topBa.EACForecastFringe__c = 0;
                        topBa.EACForecastOverhead__c = 0;
                        topBa.EACActualCostRollup__c = 0;
                        topBa.EACActualQuantityRollup__c = 0;
                        topBa.EACActualOverheadRollup__c = 0;
                        topBa.EACActualFringeRollup__c = 0;
                        topBa.BudgetResource__c = mapResourceByString.get(brKey).Id;
                        topBa.BudgetTask__c = mBudgetTask.get(ecoTask.Id).Id;
                        // mapAssignmentByUniqueId.put('' + topBa.BudgetTask__c + topBa.BudgetResource__c, topBa);
                        BudgetAssignment__c topBaReplace = mapAssignmentByUniqueId.put('' + topBa.BudgetTask__c + brKey, topBa);

                        /*if (topBaReplace != null) {
                            system.debug(brKey + ' - topBaReplace: ' + topBaReplace);
                        }*/
                        tempBas.add(topBa);
                    }

                    // Assign final calculated rollup values
                    //system.debug('totalRollup: ' + totalRollup);

                    topBa.EACActualCostRollup__c = topBa.EACActualCostRollup__c == null ? 0 : topBa.EACActualCostRollup__c;
                    topBa.EACActualQuantityRollup__c = topBa.EACActualQuantityRollup__c == null ? 0 : topBa.EACActualQuantityRollup__c;
                    topBa.EACActualOverheadRollup__c = topBa.EACActualOverheadRollup__c == null ? 0 : topBa.EACActualOverheadRollup__c;
                    topBa.EACActualFringeRollup__c = topBa.EACActualFringeRollup__c == null ? 0 : topBa.EACActualFringeRollup__c;

                    topBa.EACActualCostRollup__c += ifNull(totalRollup.cost);
                    topBa.EACActualQuantityRollup__c += ifNull(totalRollup.quantity);
                    topBa.EACActualOverheadRollup__c += ifNull(totalRollup.overhead);
                    topBa.EACActualFringeRollup__c += ifNull(totalRollup.fringe);
                    
                }
            }

            bas.addAll(tempBas);
            //system.debug('brKey: ' + brKey + ' bas size - ' + bas.size());
        }
    }


    public static void createProjectTasks(Id sProjectId, String budgetType) {
        oBudgetHeader = new BudgetHeader__c();
        oBudgetHeader.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(BudgetHeader__c.sObjectType, 'EAC');
        oBudgetHeader.Project__c = sProjectId;
        oBudgetHeader.Status__c = ECO_DTO_BudgetHeader.STATUS_ESTIMATE;
        oBudgetHeader.BudgetType__c = budgetType;

        list<BudgetHeader__c> lBudgetHeader = new list<BudgetHeader__c>([SELECT Id FROM BudgetHeader__c WHERE Project__c = :sProjectId]);

        project = [select id, DefaultBillRate__c, DefaultUpliftLabor__c, DefaultUpliftSubs__c, DefaultUpliftODCs__c, DefaultMarginType__c from pse__Proj__c where id = :sProjectId];

        oBudgetHeader.BudgetName__c = 'EAC ' + lBudgetHeader.size();
        ECO_TriggerSettings.overrideTriggerSetting('BH_updateTier1ReportBudgetFields', false);
        ECO_TriggerSettings.overrideTriggerSetting('BH_rollUpToProject', false);
        
        ECO_BudgetHeaderTriggers.run = false;
        insert oBudgetHeader;
        ECO_BudgetHeaderTriggers.run = true;
        mBudgetTask = new Map<Id, BudgetTask__c>();

        String budgetStrategyCost;
        String budgetStrategyRevenue;
        projectTasks = ets.getProjectTaskList(oBudgetHeader.Project__c, 'FinancialTask__c = true AND IsWorkPlanTask__c = false');
        mapTasks = ets.projectTaskMap;

       /* for (pse__Project_Task__c oProjectTask : ets.getProjectTaskList(sProjectId)) { */
       for ( ECO_ProjectTask ecoProjectTask : projectTasks
        /*[SELECT Id, Name, pse__Project__r.BudgetStrategy__c 
                FROM pse__Project_Task__c
                WHERE pse__Project__c = :sProjectId AND FinancialTask__c = true]*/) { 
            pse__Project_Task__c oProjectTask = ecoProjectTask.oprojectTask;

            if (oProjectTask.FinancialTask__c) {
                BudgetTask__c oBudgetTask = new BudgetTask__c();
                oBudgetTask.ProjectTask__c = oProjectTask.Id;
                oBudgetTask.BudgetHeader__c = oBudgetHeader.Id;
                oBudgetTask.TaskName__c = oProjectTask.Name;
                mBudgetTask.put(oProjectTask.Id, oBudgetTask);
                budgetStrategyCost = oProjectTask.pse__Project__r.BudgetStrategy__c;
                budgetStrategyRevenue = oProjectTask.pse__Project__r.BudgetStrategyRevenue__c;
            }            
        }

       

        topTaskCostBudget = (budgetStrategyCost == 'Top Task');
        topTaskRevenueBudget = (budgetStrategyRevenue == 'Top Task');

        //system.debug('topTaskCostBudget: ' + topTaskCostBudget);
        if (!mBudgetTask.isEmpty()) {
            // There's no amounts to rollup on the initial create
            // Saves projectTasks from having to update
            ECO_TriggerSettings.bypass('BT_rollup');
            insert mBudgetTask.values();
            ECO_TriggerSettings.clearBypass('BT_rollup');

            // After initialization there's no reason Budget Tasks should do any more calculation
            // Other triggers may inadvertently still trigger budget task due to rollups on budget assignments
            // So we disable it here
            ECO_TriggerSettings.bypassTrigger('BT');

            for ( ECO_ProjectTask ecoProjectTask : projectTasks) {
                pse__Project_Task__c oProjectTask = ecoProjectTask.oprojectTask;
                mapPtIdByBtId.put(mBudgetTask.get(ecoProjectTask.Id).Id, ecoProjectTask.Id);
            }
        }
    }
    
    private static BudgetAssignment__c addExpBA(String expType, Id projectTaskId) {
       BudgetTask__c btTest = mBudgetTask.get(projectTaskId);
       //if (btTest == null) system.debug('btTest ' + projectTaskId);

        Id budgetTaskId = btTest.Id;
        BudgetResource__c budgetResource = mapResourceByExpType.get(expType);

        if (budgetResource == null) {
            budgetResource = new BudgetResource__c();

            budgetResource.BudgetHeader__c = oBudgetHeader.id;
            budgetResource.OverrideRatesOnLines__c = true;
            budgetResource.ResourceType__c = 'ODC/FEE';
            budgetResource.MarginType__c = 'Percent';
            budgetResource.OverrideUplift__c = project.DefaultUpliftODCs__c;
            budgetResource.OverrideFringeMultiplier__c = 0.0;
            budgetResource.OverrideOverheadMultiplier__c = 0.0;
            budgetResource.OverrideFringeMultiplierField__c = 0.0;
            budgetResource.OverrideOverheadMultiplierField__c = 0.0;

            budgetResource.ExpenditureType__c = expType == null ? 'MISC-Materials' : expType;
            // TODO: ???
            /*      newBudgetColumn.OverrideUplift__c = markupPercentage;
                            newBudgetColumn.ResourceName__c = jobName;
                            
                            newBudgetColumn.CostCalcType__c = unitType;
                            newBudgetColumn.OverrideRawCost__c = unitCost;
                            newBudgetColumn.OverrideFringeMultiplier__c = 0.0;
                            newBudgetColumn.OverrideOverheadMultiplier__c = 0.0;

                            newBudgetColumn.isBillable__c = isBillable;
                            newBudgetColumn.isEstimated__c = isEstimated;
                            newBudgetColumn.isQuoted__c = isQuoted;
                            */
            budgetResource.ResourceName__c = expType;

            mapResourceByExpType.put(expType, budgetResource);
        }

        List<BudgetAssignment__c> oAssignments = mapAssignmentsByExpType.get(expType);

        if (oAssignments == null) {
            oAssignments = new List<BudgetAssignment__c> ();
            mapAssignmentsByExpType.put(expType, oAssignments);
        }

        String uniqueId = 'ODC' + expType + uniqueDelim + projectTaskId;
        BudgetAssignment__c ba = mapAssignmentByUniqueId.get(uniqueId);
        if (ba == null) {
            ba = new BudgetAssignment__c();
            ba.EACActualQuantity__c = 0;
            ba.EACActualCost__c = 0;
            ba.EACApprovedTotalCost__c = 0;
            ba.EACForecastTotalCost__c = 0;
            mapAssignmentByUniqueId.put(uniqueId, ba);
            oAssignments.add(ba); // make sure we only the BA once
        }

        ba.BudgetTask__c = budgetTaskId;

        return ba;
    }

    private static BudgetAssignment__c addSubBA(String subId, Id projectTaskId) {
        return addSubBA(subId, projectTaskId, null);
    }

    private static BudgetAssignment__c addSubBA(String subId, Id projectTaskId, String vendorId) {
        Id budgetTaskId = mBudgetTask.get(projectTaskId).Id;
        BudgetResource__c budgetResource = mapResourceBySubId.get(subId);

        if (budgetResource == null) {
            budgetResource = new BudgetResource__c();
            budgetResource.BudgetHeader__c = oBudgetHeader.id;
            budgetResource.OverrideRatesOnLines__c = true;
            budgetResource.ResourceType__c = 'Subcontractor';
            budgetResource.OverrideFringeMultiplier__c = 0.0;
            budgetResource.OverrideOverheadMultiplier__c = 0.0;
            budgetResource.OverrideFringeMultiplierField__c = 0.0;
            budgetResource.OverrideOverheadMultiplierField__c = 0.0;
            budgetResource.OverrideBillRate__c = project.DefaultBillRate__c;
            budgetResource.OverrideUplift__c = project.DefaultUpliftSubs__c;
            // TODO: ???
            // budgetResource.OverrideBillRate__c = theProject.DefaultBillRate__c;
            // budgetResource.OverrideUplift__c = theProject.DefaultUpliftLabor__c;
            budgetResource.JobName__c = null;

            budgetResource.VendorSite__c  = subId;
            mapResourceBySubId.put(subId, budgetResource);
        }

        List<BudgetAssignment__c> oAssignments = mapAssignmentsBySubId.get(subId);

        if (oAssignments == null) {
            oAssignments = new List<BudgetAssignment__c> ();
            mapAssignmentsBySubId.put(subID, oAssignments);
        }

        String uniqueId = 'Subcontractor' + subId + uniqueDelim + projectTaskId;
        BudgetAssignment__c ba = mapAssignmentByUniqueId.get(uniqueId);
        if (ba == null) {
            ba = new BudgetAssignment__c();
            ba.EACApprovedTotalCost__c = 0;
            ba.EACForecastTotalCost__c = 0;
            ba.EACActualCost__c = 0;
            ba.EACApprovedRawCost__c = 0;
            ba.EACApprovedRevenue__c = 0;
            ba.EACForecastRawCost__c = 0;
            ba.EACForecastTotalCost__c = 0;
            ba.EACForecastRevenueNumber__c = 0;
            mapAssignmentByUniqueId.put(uniqueId, ba);
            oAssignments.add(ba); // make sure we only the BA once
        }

        ba.BudgetTask__c = budgetTaskId;

        return ba;
    }

    private static BudgetAssignment__c addLabExp(Id projectTaskId) {
        Id budgetTaskId = mBudgetTask.get(projectTaskId).Id;

        if (labExpResource == null) {
            labExpResource = new BudgetResource__c();
            labExpResource.BudgetHeader__c = oBudgetHeader.id;
            labExpResource.OverrideRatesOnLines__c = true;
            labExpResource.ResourceType__c = 'Labor/Person';
            labExpResource.JobName__c = 'Labor Fringe/Overhead';
            labExpResource.isHidden__c = true;
        }

        if (labExpAssignments == null) {
            labExpAssignments = new List<BudgetAssignment__c> ();
        }

        String uniqueId = EXPLABOR_UNIQUE_PREFIX + uniqueDelim + projectTaskId;
        //system.debug('-- Omar - In addLabExp(): ' + uniqueId);
        
        BudgetAssignment__c ba = mapAssignmentByUniqueId.get(uniqueId);
        if (ba == null) {
            ba = new BudgetAssignment__c();
            ba.EACApprovedTotalCost__c = 0;
            ba.EACForecastTotalCost__c = 0;
            ba.EACForecastFringe__c = 0;
            ba.EACForecastOverhead__c = 0;
            /*
            ba.OverrideTotalFringe__c = 0;
            ba.OverrideTotalOverhead__c = 0;
            */
            mapAssignmentByUniqueId.put(uniqueId, ba);
            labExpAssignments.add(ba); 
        }

        ba.BudgetTask__c = budgetTaskId;

        return ba;
    }

    private static void defaultBillRates(BudgetResource__c budgetResource) {
        budgetResource.OverrideBillRate__c = project.DefaultBillRate__c;
        budgetResource.OverrideUplift__c = project.DefaultUpliftLabor__c;


        if (project.DefaultBillRate__c != null && project.DefaultBillRate__c != 0 ) {
            budgetResource.MarginType__c = 'Amount';
        }
    }

    private static BudgetAssignment__c addLaborBA(String ptmId, Id projectTaskId, Boolean isGeneric) {
        Id budgetTaskId = mBudgetTask.get(projectTaskId).Id;

        BudgetResource__c budgetResource;

        budgetResource = mapResourceByPTMId.get(ptmId);
        if (budgetResource == null) {
            budgetResource = new BudgetResource__c();
            budgetResource.BudgetHeader__c = oBudgetHeader.id;
            budgetResource.OverrideRatesOnLines__c = true;
            budgetResource.ResourceType__c = 'Labor/Person';
            // TODO: ???
            // budgetResource.OverrideBillRate__c = theProject.DefaultBillRate__c;
            // budgetResource.OverrideUplift__c = theProject.DefaultUpliftLabor__c;
            budgetResource.ProjectTeamMember__c = ptmId;

            defaultBillRates(budgetResource);

            mapResourceByPTMId.put(ptmId, budgetResource);
        }

        List<BudgetAssignment__c> oAssignments = mapAssignmentsByPTMId.get(ptmId);

        if (oAssignments == null) {
            oAssignments = new List<BudgetAssignment__c> ();
            mapAssignmentsByPTMId.put(ptmID, oAssignments);
        }

        String uniqueId = 'Person' + ptmId + '' + projectTaskId;
        BudgetAssignment__c ba = mapAssignmentByUniqueId.get(uniqueId);
        if (ba == null) {
            ba = new BudgetAssignment__c();
            ba.EACApprovedTotalCost__c = 0;
            ba.EACForecastTotalCost__c = 0;
            ba.EACApprovedQuantity__c = 0;
            ba.EACForecastQuantity__c = 0;
            ba.EACForecastFringe__c = 0;
            ba.EACForecastOverhead__c = 0;
            ba.EACForecastRawCost__c = 0;
            ba.EACForecastRevenueNumber__c = 0;
            mapAssignmentByUniqueId.put(uniqueId, ba);
            oAssignments.add(ba); // make sure we only the BA once
        }

        ba.BudgetTask__c = budgetTaskId;



        return ba;
    }

    private static List<String> oracleSubsName;
    private static List<String> oracleLabNames;
    private static List<String> oracleExpNames;
    private static List<String> oracleLabExpNames;
    private static List<String> oracleLabExpFringeNames;
    private static List<String> oracleLabExpOverheadNames;

    private static void createExpTypes() {
        oracleSubsName = new List<String>();
        oracleLabNames = new List<String>();
        oracleExpNames = new List<String>();
        oracleLabExpNames = new List<String>();
        oracleLabExpFringeNames = new List<String>(); 
        oracleLabExpOverheadNames = new List<String>();

        Map<String, Oracle_Expenditure_Types__c> typesMap = Oracle_Expenditure_Types__c.getAll();
        for (Oracle_Expenditure_Types__c expType : typesMap.values()) {
            String rollupType = expType.Rollup_Type_1__c;
            String name = expType.Name;
            String category = expType.Expenditure_Category__c;
            
            if (category == 'Fringe') {
                oracleLabExpFringeNames.add(name);
                oracleLabExpNames.add(name);
            } else if (category == 'Overhead') {
                oracleLabExpOverheadNames.add(name);
                oracleLabExpNames.add(name);
            }
            else if (rollupType == 'SUBS') {
                oracleSubsName.add(name);
            } else if (rollupType == 'LAB') {
                oracleLabNames.add(name);
            } else if (rollupType == 'EXPS') {
                oracleExpNames.add(name);
            }
        }
    }

    public static void calculateApprovedForecastDiffDefaults() {

        for (BudgetAssignment__c ba : mapAssignmentByUniqueId.values()) {
            ba.EACForecastTotalCost__c = ifNull(ba.EACApprovedTotalCost__c) - ifNull(ba.EACForecastTotalCost__c);
            ba.EACForecastRawCost__c = ifNull(ba.EACApprovedRawCost__c) - ifNull(ba.EACForecastRawCost__c);
            ba.EACForecastQuantity__c = ifNull(ba.EACApprovedQuantity__c) - ifNull(ba.EACForecastQuantity__c);
            ba.EACForecastRevenueNumber__c = ifNull(ba.EACApprovedRevenue__c) - ifNull(ba.EACForecastRevenueNumber__c);
        }

        List<BudgetAssignment__c> genericBudgetAssignments = mapAssignmentsByPTMId.get(null);

        if (genericBudgetAssignments == null) return;
        BudgetResource__c genericBR = mapResourceByPTMId.get(null);
        Decimal totalRawCost = 0;
        Decimal totalQuantity = 0;
        Decimal totalFringe = 0;
        Decimal totalOverhead = 0;

        for(BudgetAssignment__c ba : genericBudgetAssignments) {
            totalQuantity += ba.EACForecastQuantity__c;
            totalRawCost += ba.EACForecastRawCost__c;
            totalFringe += ifNull(ba.EACForecastFringe__c);
            totalOverhead += ifNull(ba.EACForecastOverhead__c);            
        }

        genericBR.OverrideRawCost__c = calcAvgRate(totalRawCost, totalQuantity);
        genericBR.OverrideFringeMultiplier__c = 100*calcAvgRate(totalFringe, totalRawCost);
        genericBR.OverrideFringeMultiplierField__c = genericBR.OverrideFringeMultiplier__c; 
        genericBR.OverrideOverheadMultiplier__c = 100*calcAvgRate(totalOverhead, totalRawCost);
        genericBR.OverrideOverheadMultiplierField__c = genericBR.OverrideOverheadMultiplier__c; 

        //system.debug(LoggingLevel.INFO, 'Generic Raw Rate: ' + genericBR.OverrideRawCost__c );
        //system.debug(LoggingLevel.INFO, 'Generic OverrideFringeMultiplier__c: ' + genericBR.OverrideFringeMultiplier__c );
        //system.debug(LoggingLevel.INFO, 'Generic OverrideOverheadMultiplier__c: ' + genericBR.OverrideOverheadMultiplier__c );

    }

    public static void calculateDefaults() {
        calculateDefaults(false);
    }

    public static void calculateDefaults(Boolean isCloseout) {

        System.Debug('BrentBrentBrent before rollupTotals' + Limits.getHeapSize());
        rollupTotals();
        System.Debug('BrentBrentBrent after rollupTotals' + Limits.getHeapSize());

        for (String uniqueId : mapAssignmentByUniqueId.keySet()) {
            BudgetAssignment__c ba  = mapAssignmentByUniqueId.get(uniqueId);
            ba.useEACCalc__c = true; // Set Budget Assignment as EAC
            ba.EACForecastTotalCost__c = ifNull(ba.EACApprovedTotalCost__c) + ifNull(ba.EACForecastTotalCost__c);
            ba.EACForecastRawCost__c = ifNull(ba.EACApprovedRawCost__c) + ifNull(ba.EACForecastRawCost__c);
            ba.EACForecastQuantity__c = ifNull(ba.EACApprovedQuantity__c) + ifNull(ba.EACForecastQuantity__c);
            ba.EACForecastRevenueNumber__c = ifNull(ba.EACApprovedRevenue__c) + ifNull(ba.EACForecastRevenueNumber__c);
            if (isCloseout && !uniqueId.contains(EXPLABOR_UNIQUE_PREFIX)) {
                //if (resourceType == TYPE_LABOR || resourceType == TYPE_SUB) {
                    ba.Quantity__c = ifNull(ba.EACActualQuantityRollup__c) - ifNull(ba.EACForecastQuantity__c);
                //}
                //if (resourceType != TYPE_LABOR) {
                    ba.OverrideTotalRawCost__c = ifNull(ba.EACActualCostRollup__c) - ifNull(ba.EACForecastTotalCost__c);
                //}
                // ba.OverrideTotalRawCost__c = ifNull(ba.EACActualCost__c) - ifNull(ba.EACForecastRawCost__c);                
                // ba.Quantity__c = ifNull(ba.EACActualCost__c) - ifNull(ba.EACForecastQuantity__c);
            }
        }

        System.Debug('BrentBrentBrent before generic budget assignments' + Limits.getHeapSize());
        List<BudgetAssignment__c> genericBudgetAssignments = mapAssignmentsByPTMId.get(null);
        System.Debug('BrentBrentBrent after generic budget assignments' + Limits.getHeapSize());
        if (genericBudgetAssignments == null) return;
        BudgetResource__c genericBR = mapResourceByPTMId.get(null);
        Decimal totalRawCost = 0;
        Decimal totalQuantity = 0;
        Decimal totalFringe = 0;
        Decimal totalOverhead = 0;

        for(BudgetAssignment__c ba : genericBudgetAssignments) {
            totalQuantity += ifNull(ba.EACForecastQuantity__c);
            totalRawCost += ifNull(ba.EACForecastRawCost__c);
            totalFringe += ifNull(ba.EACForecastFringe__c);
            totalOverhead += ifNull(ba.EACForecastOverhead__c);            
        }

        genericBR.OverrideRawCost__c = calcAvgRate(totalRawCost, totalQuantity);
        genericBR.OverrideFringeMultiplier__c = 100*calcAvgRate(totalFringe, totalRawCost);
        genericBR.OverrideFringeMultiplierField__c = genericBR.OverrideFringeMultiplier__c; 
        genericBR.OverrideOverheadMultiplier__c = 100*calcAvgRate(totalOverhead, totalRawCost);
        genericBR.OverrideOverheadMultiplierField__c = genericBR.OverrideOverheadMultiplier__c; 

        //system.debug(LoggingLevel.INFO, 'Generic Raw Rate: ' + totalRawCost + ' / ' + totalQuantity + '=' + genericBR.OverrideRawCost__c );
        //system.debug(LoggingLevel.INFO, 'Generic OverrideFringeMultiplier__c: ' + totalFringe + ' / ' + totalRawCost + '=' + genericBR.OverrideFringeMultiplier__c );
        //system.debug(LoggingLevel.INFO, 'Generic OverrideOverheadMultiplier__c: ' + totalOverhead + ' / ' + totalRawCost + '=' + genericBR.OverrideOverheadMultiplier__c );
    }

    public static Decimal calcAvgRate(Decimal cost, Decimal hours) {
        Decimal rate = hours == 0 ? 0 : cost / hours;

        return rate.setScale(4);
    }

    public static Id createGenericECO(Id sProjectId) {
        return createGenericECO(sProjectId, false, null);
    }
    public static Id createGenericECO(Id sProjectId, Boolean isCloseout, Decimal overrideRevenueAmount) {
        // Bypass Project Task Triggers
        ECO_TriggerSettings.bypass('PR_handleApprovalStageChanges');
        ECO_TriggerSettings.bypassTrigger('PT');

        createExpTypes();

        mapAssignmentByUniqueId = new Map <String, BudgetAssignment__c> ();
        mapResourceByPTMId = new Map <String, BudgetResource__c> ();
        mapResourceBySubId = new Map <String, BudgetResource__c> ();
        mapResourceByContingencyName = new Map <String, BudgetResource__c> ();
        mapResourceByExpType = new Map <String, BudgetResource__c> ();
        // Stores BAs so we can set the BudgetResource__c Id after the records are inserted
        mapAssignmentsByPTMId = new Map <String, List<BudgetAssignment__c>> ();
        mapAssignmentsBySubId = new Map <String, List<BudgetAssignment__c>> ();
        mapAssignmentsByContingencyName = new Map <String, List<BudgetAssignment__c>> ();
        mapAssignmentsByExpType = new Map <String, List<BudgetAssignment__c>> ();

        mapAssignmentByUniqueId = new Map <String, BudgetAssignment__c> ();

        mapResourcesByPersonId = new Map<String, BudgetResource__c>();

        BudgetResource__c brLabor = new BudgetResource__c();
        List<BudgetAssignment__c> baLabors = new List<BudgetAssignment__c>();
        BudgetResource__c brSub = new BudgetResource__c();
        List< BudgetAssignment__c> baSubs = new List<BudgetAssignment__c>();
        BudgetResource__c brContingency = new BudgetResource__c();
        BudgetAssignment__c baContingency = new BudgetAssignment__c();

        String eacName = isCloseout ? 'Project Closeout EAC' : 'Generic EAC';
        createProjectTasks(sProjectId, eacName);

        system.debug(LoggingLevel.INFO, 'SOQL Queries used: ' + Limits.getQueries());
        system.debug(LoggingLevel.INFO, '### - SOQL Rows used: ' + Limits.getQueryRows());

        AggregateResult[] arLabor = [Select Sum(Quantity__c) Quantity__c, Sum(AppliedTtlRawCstNm__c) TotalRawCost, Sum(TotalFringeNum__c) TotalFringe__c, Sum(TotalOverheadNum__c) TotalOverhead__c, Sum(FullyBurdenedCostNumber__c) FullyBurdenedCost__c, Sum(CalculatedRevenueNumber__c) TotalRevenue, BudgetTask__r.ProjectTask__c, BudgetTask__r.BudgetHeader__r.Status__c
                                     From BudgetAssignment__c
                                     Where BudgetTask__r.ProjectTask__r.pse__Project__c = :sProjectId AND ResourceType__c = 'Labor/Person' AND BudgetResource__r.IsHidden__c = false AND
                                             (BudgetTask__r.BudgetHeader__r.Status__c = 'Forecast' OR BudgetTask__r.BudgetHeader__r.Status__c = 'Approved')
                                             GROUP BY BudgetTask__r.ProjectTask__c, BudgetTask__r.BudgetHeader__r.Status__c
                                    ];
        
        system.debug(LoggingLevel.INFO, '--- SOQL Queries used: ' + Limits.getQueries());
        system.debug(LoggingLevel.INFO, '### - SOQL Rows used: ' + Limits.getQueryRows());
        AggregateResult[] arLaborHidden = [Select Sum(Quantity__c) Quantity__c, Sum(AppliedTtlRawCstNm__c) TotalRawCost, Sum(TotalFringeNum__c) TotalFringe__c, Sum(TotalOverheadNum__c) TotalOverhead__c, Sum(FullyBurdenedCostNumber__c) FullyBurdenedCost__c, Sum(CalculatedRevenueNumber__c) TotalRevenue, BudgetTask__r.ProjectTask__c
                                     From BudgetAssignment__c
                                     Where BudgetTask__r.ProjectTask__r.pse__Project__c = :sProjectId AND ResourceType__c = 'Labor/Person' AND BudgetResource__r.IsHidden__c = true AND
                                             (BudgetTask__r.BudgetHeader__r.Status__c = 'Forecast' OR BudgetTask__r.BudgetHeader__r.Status__c = 'Approved')
                                             GROUP BY BudgetTask__r.ProjectTask__c
                                    ];
        system.debug(LoggingLevel.INFO, '--- SOQL Queries used: ' + Limits.getQueries());    
        system.debug(LoggingLevel.INFO, '### - SOQL Rows used: ' + Limits.getQueryRows());                                                        
        AggregateResult[] arSubs = [Select Sum(AppliedTtlRawCstNm__c) AppliedTtlRawCstNum, Sum(CalculatedRevenueNumber__c) TotalRevenue, BudgetTask__r.ProjectTask__c, BudgetResource__r.VendorSite__c, BudgetTask__r.BudgetHeader__r.Status__c
                                    From BudgetAssignment__c
                                    Where BudgetTask__r.ProjectTask__r.pse__Project__c = :sProjectId AND ResourceType__c = 'Subcontractor' AND
                                            (BudgetTask__r.BudgetHeader__r.Status__c = 'Forecast' OR BudgetTask__r.BudgetHeader__r.Status__c = 'Approved')
                                            GROUP BY BudgetTask__r.ProjectTask__c, BudgetResource__r.VendorSite__c, BudgetTask__r.BudgetHeader__r.Status__c
                                   ];

        system.debug(LoggingLevel.INFO, '--- SOQL Queries used: ' + Limits.getQueries());
        system.debug(LoggingLevel.INFO, '### - SOQL Rows used: ' + Limits.getQueryRows());
        AggregateResult[] arExp = [Select Sum(AppliedTtlRawCstNm__c) AppliedTtlRawCstNum, Sum(CalculatedRevenueNumber__c) TotalRevenue,
                                    BudgetTask__r.ProjectTask__c, BudgetTask__r.BudgetHeader__r.Status__c
                                   From BudgetAssignment__c
                                   Where BudgetTask__r.ProjectTask__r.pse__Project__c = :sProjectId AND ResourceType__c = 'ODC/FEE' AND
                                           (BudgetTask__r.BudgetHeader__r.Status__c = 'Forecast' OR BudgetTask__r.BudgetHeader__r.Status__c = 'Approved')
                                           GROUP BY BudgetTask__r.ProjectTask__c, BudgetTask__r.BudgetHeader__r.Status__c];

        system.debug(LoggingLevel.INFO, '--- SOQL Queries used: ' + Limits.getQueries());  
        system.debug(LoggingLevel.INFO, '### - SOQL Rows used: ' + Limits.getQueryRows());                                         
        AggregateResult[] arContingency = [Select Sum(AppliedTtlRawCstNm__c) AppliedTtlRawCstNum, Sum(CalculatedRevenueNumber__c) TotalRevenue, BudgetTask__r.ProjectTask__c, BudgetResource__r.JobName__c, BudgetTask__r.BudgetHeader__r.Status__c
                                           From BudgetAssignment__c
                                           Where BudgetTask__r.ProjectTask__r.pse__Project__c = :sProjectId AND ResourceType__c = 'Contingency' AND
                                                   (BudgetTask__r.BudgetHeader__r.Status__c = 'Forecast' OR BudgetTask__r.BudgetHeader__r.Status__c = 'Approved')
                                                   GROUP BY BudgetTask__r.ProjectTask__c, BudgetResource__r.JobName__c, BudgetTask__r.BudgetHeader__r.Status__c
                                          ];

        system.debug(LoggingLevel.INFO, '--- SOQL Queries used: ' + Limits.getQueries());
        system.debug(LoggingLevel.INFO, '### - SOQL Rows used: ' + Limits.getQueryRows());
        /*
        AggregateResult[] arLaborActuals = [SELECT SUM(Quantity__c) Quantity__c, SUM(ProjectFunctionalBurdenedCost__c) totalRawCost, ProjectTask__c
                                            FROM ExpendItem__c Where Project__c = :sProjectId AND ExpenditureType__c IN :oracleLabNames
                                                    GROUP BY ProjectTask__c
                                           ];

        AggregateResult[] arSubActuals = [SELECT SUM(Quantity__c) Quantity__c, SUM(ProjectFunctionalBurdenedCost__c) totalRawCost, ProjectTask__c
                                          FROM ExpendItem__c Where Project__c = :sProjectId AND ExpenditureType__c IN :oracleSubsName
                                                  GROUP BY ProjectTask__c
                                         ];


        AggregateResult[] arExpActuals = [SELECT SUM(Quantity__c) Quantity__c, SUM(ProjectFunctionalBurdenedCost__c) totalRawCost, ProjectTask__c
                                          FROM ExpendItem__c Where Project__c = :sProjectId AND ExpenditureType__c IN :oracleExpNames
                                                  GROUP BY ProjectTask__c
                                         ];
         
        AggregateResult[] arLabExpFringeActuals = [SELECT SUM(Quantity__c) Quantity__c, SUM(ProjectFunctionalBurdenedCost__c) totalRawCost, ProjectTask__c
                                          FROM ExpendItem__c Where Project__c = :sProjectId AND ExpenditureType__c IN :oracleLabExpFringeNames
                                                  GROUP BY ProjectTask__c
                                         ];

        AggregateResult[] arLabExpOverheadActuals = [SELECT SUM(Quantity__c) Quantity__c, SUM(ProjectFunctionalBurdenedCost__c) totalRawCost, ProjectTask__c
                                          FROM ExpendItem__c Where Project__c = :sProjectId AND ExpenditureType__c IN :oracleLabExpOverheadNames
                                                  GROUP BY ProjectTask__c
                                         ];
         */                                


        /*
        for (AggregateResult ar : arLabExpFringeActuals) {
            Decimal quantity = (Decimal)ar.get('Quantity__c');
            Decimal totalCost = (Decimal)ar.get('totalRawCost');
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            BudgetAssignment__c ba = addLabExp(projectTaskId);
            // ba.EACActualQuantity__c = quantity;
            ba.EACActualFringe__c = totalCost;
            // if (isCloseout) ba.OverrideTotalFringe__c = totalCost;
        }

        for (AggregateResult ar : arLabExpOverheadActuals) {
            Decimal quantity = (Decimal)ar.get('Quantity__c');
            Decimal totalCost = (Decimal)ar.get('totalRawCost');
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            BudgetAssignment__c ba = addLabExp(projectTaskId);
            // ba.EACActualQuantity__c = quantity + ifNull(ba.EACActualQuantity__c);
            ba.EACActualOverhead__c = totalCost; //  + ifNull(ba.EACActualCost__c);
            // if (isCloseout) ba.OverrideTotalOverhead__c = totalCost;
        }

        for (AggregateResult ar : arLaborActuals) {
            Decimal quantity = (Decimal)ar.get('Quantity__c');
            Decimal totalCost = (Decimal)ar.get('totalRawCost');
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            BudgetAssignment__c ba = addLaborBA(null, projectTaskId, true);

            ba.EACActualQuantity__c = quantity;
            ba.EACActualCost__c = totalCost;
        }
        */

        pse__Project_Task__c[] arActuals = 
            [
                SELECT Id,
                    ActualProjectHours__c,
                    ActualRawCostLaborNum__c,
                    ActualFringeNum__c,
                    ActualOverheadNum__c,
                    ActualCostODCSUBSNum__c,
                    ActualCostODCEXPSNum__c
                FROM pse__Project_Task__c 
                WHERE pse__Project__c = :sProjectId
            ];

        for (pse__Project_Task__c ar : arActuals) {
            Id projectTaskId = ar.Id;
            Decimal totalProjectHours = ar.ActualProjectHours__c ;
            Decimal totalActualRawCostLabor = ar.ActualRawCostLaborNum__c ;
            Decimal totalActualFringe = ar.ActualFringeNum__c ;
            Decimal totalActualOverhead = ar.ActualOverheadNum__c ;
            Decimal totalActualCostODCSUBS = ar.ActualCostODCSUBSNum__c ;
            Decimal totalActualCostODCEXPS = ar.ActualCostODCEXPSNum__c ;

            if (totalActualRawCostLabor != 0.0 || totalProjectHours != 0.0 ) {
                BudgetAssignment__c ba = addLaborBA(null, projectTaskId, true);
                ba.EACActualCost__c = totalActualRawCostLabor;
                ba.EACActualQuantity__c = totalProjectHours;
            }

            if (totalActualFringe != 0.0) {
                BudgetAssignment__c ba = addLabExp(projectTaskId);
                ba.EACActualFringe__c = totalActualFringe;
            }

            if (totalActualOverhead != 0.0) {
                BudgetAssignment__c ba = addLabExp(projectTaskId);
                ba.EACActualOverhead__c = totalActualOverhead;
            }

            if (totalActualCostODCSUBS != 0.0) {
                BudgetAssignment__c ba = addSubBA(null, projectTaskId);
                ba.EACActualCost__c = totalActualCostODCSUBS;
            }

            if (totalActualCostODCEXPS != 0.0) {
                BudgetAssignment__c ba = addExpBA(null, projectTaskId);
                ba.EACActualCost__c = totalActualCostODCEXPS;
            }
        }

        for (AggregateResult ar : arLaborHidden) {
            Decimal quantity = (Decimal)ar.get('Quantity__c');
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            // String status = (String)ar.get('Status__c');
            Decimal totalCost = (Decimal)ar.get('FullyBurdenedCost__c');
            totalCost = totalCost == null ? 0 : totalCost;

            BudgetAssignment__c ba = addLabExp(projectTaskId);

            ba.EACForecastFringe__c = ifNull((Decimal)ar.get('TotalFringe__c'));
            ba.EACForecastOverhead__c = ifNull((Decimal)ar.get('TotalOverhead__c'));
            ba.EACForecastTotalCost__c = ba.EACForecastFringe__c + ba.EACForecastOverhead__c;
            ba.OverrideRawCost__c = 0;

        }

        for (AggregateResult ar : arLabor) {
            Decimal quantity = (Decimal)ar.get('Quantity__c');
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            String status = (String)ar.get('Status__c');
            Decimal totalCost = (Decimal)ar.get('FullyBurdenedCost__c');
            totalCost = totalCost == null ? 0 : totalCost;

            BudgetAssignment__c ba = addLaborBA(null, projectTaskId, true);

            ba.EACForecastFringe__c += ifNull((Decimal)ar.get('TotalFringe__c'));
            ba.EACForecastOverhead__c += ifNull((Decimal)ar.get('TotalOverhead__c'));

            if (status == 'Approved') {
                ba.EACApprovedQuantity__c = quantity;
                ba.EACApprovedTotalCost__c = totalCost;
                ba.EACApprovedRawCost__c = (Decimal)ar.get('TotalRawCost');
                ba.EACApprovedRevenue__c = (Decimal)ar.get('TotalRevenue');
            } else if (status == 'Forecast') {
                ba.EACForecastQuantity__c = quantity;
                ba.EACForecastTotalCost__c = totalCost;
                ba.EACForecastRawCost__c = (Decimal)ar.get('TotalRawCost');
                ba.EACForecastRevenueNumber__c = (Decimal)ar.get('TotalRevenue');
            }
        }

        /*
        for (AggregateResult ar : arSubActuals) {
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            if (projectTaskId == null) continue;


            Decimal totalRawCost = (Decimal)ar.get('totalRawCost');

            BudgetAssignment__c ba = addSubBA(null, projectTaskId);

            ba.EACActualCost__c = totalRawCost;
        }
        */
        for (AggregateResult ar : arSubs) {
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            if ( projectTaskId == null) continue;
            String status = (String)ar.get('Status__c');
            Decimal quantity = (Decimal)ar.get('AppliedTtlRawCstNum');


            BudgetAssignment__c ba = addSubBA(null, projectTaskId);

            
            if (status == 'Approved') {
                ba.EACApprovedTotalCost__c += quantity;
                ba.EACApprovedRawCost__c  += quantity;
                ba.EACApprovedRevenue__c += (Decimal)ar.get('TotalRevenue');
            } else if (status == 'Forecast') {
                ba.EACForecastRawCost__c  += quantity;
                ba.EACForecastTotalCost__c += quantity;
                ba.EACForecastRevenueNumber__c += (Decimal)ar.get('TotalRevenue');
            }

        }

        /*
         for (AggregateResult ar : arExpActuals) {
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            if (projectTaskId == null) continue;

            Decimal totalRawCost = (Decimal)ar.get('totalRawCost');

            BudgetAssignment__c ba = addExpBA(null, projectTaskId);

            ba.EACActualCost__c = totalRawCost;
        }
        */

        for (AggregateResult ar : arExp) {
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            if ( projectTaskId == null) continue;
            String status = (String)ar.get('Status__c');
            Decimal quantity = (Decimal)ar.get('AppliedTtlRawCstNum');

            BudgetAssignment__c ba = addExpBA(null, projectTaskId);

            
            if (status == 'Approved') {
                ba.EACApprovedRawCost__c  = quantity;
                ba.EACApprovedTotalCost__c = quantity;
                ba.EACApprovedRevenue__c = (Decimal)ar.get('TotalRevenue');
            } else if (status == 'Forecast') {
                ba.EACForecastRawCost__c  = quantity;
                ba.EACForecastTotalCost__c = quantity;
                ba.EACForecastRevenueNumber__c = (Decimal)ar.get('TotalRevenue');
            }

        }

        for (AggregateResult ar : arContingency) {
            Id projectTaskId = (Id)ar.get('ProjectTask__c');
            // String contName = (String)ar.get('JobName__c');
            String contName = null;
            if (projectTaskId == null) continue;
            String status = (String)ar.get('Status__c');
            Decimal quantity = (Decimal)ar.get('AppliedTtlRawCstNum');
            Id budgetTaskId = mBudgetTask.get(projectTaskId).Id;
            BudgetResource__c budgetResource = mapResourceByContingencyName.get(contName);

            if (budgetResource == null) {
                budgetResource = new BudgetResource__c();
                budgetResource.BudgetHeader__c = oBudgetHeader.id;
                budgetResource.OverrideRatesOnLines__c = true;
                budgetResource.ResourceType__c = 'Contingency';
                // TODO: ???
                // budgetResource.OverrideBillRate__c = theProject.DefaultBillRate__c;
                // budgetResource.OverrideUplift__c = theProject.DefaultUpliftLabor__c;
                budgetResource.JobName__c = null;

                mapResourceByContingencyName.put(contName, budgetResource);
            }

            List<BudgetAssignment__c> oAssignments = mapAssignmentsByContingencyName.get(contName);

            if (oAssignments == null) {
                oAssignments = new List<BudgetAssignment__c> ();
                mapAssignmentsByContingencyName.put(contName, oAssignments);
            }

            String uniqueId = 'Contingency' + contName + uniqueDelim + projectTaskId;
            BudgetAssignment__c ba = mapAssignmentByUniqueId.get(uniqueId);
            if (ba == null) {
                ba = new BudgetAssignment__c();
                ba.EACApprovedTotalCost__c = 0;
                ba.EACForecastTotalCost__c = 0;
                mapAssignmentByUniqueId.put(uniqueId, ba);
                oAssignments.add(ba); // make sure we only the BA once
            }

            ba.BudgetTask__c = budgetTaskId;
            
            if (status == 'Approved') {
                ba.EACApprovedTotalCost__c = quantity;
                ba.EACApprovedRawCost__c  = quantity;
                ba.EACApprovedRevenue__c = (Decimal)ar.get('TotalRevenue');
            } else if (status == 'Forecast') {
                ba.EACForecastRawCost__c  = quantity;
                ba.EACForecastTotalCost__c = quantity;
                ba.EACForecastRevenueNumber__c = (Decimal)ar.get('TotalRevenue');
            }

        }

        // rollupActuals();
        // Insert All budgetResources
        List<BudgetResource__c> allBudgets = new List<BudgetResource__c>();
        allBudgets.addAll(mapResourceByPTMId.values());
        allBudgets.addAll(mapResourceByContingencyName.values());
        allBudgets.addAll(mapResourceBySubId.values());
        allBudgets.addAll(mapResourceByExpType.values());
        if(labExpResource != null) allBudgets.add(labExpResource);
        
        /*** Set default values on all Budget Assignments And Budget Resources ***/
        calculateDefaults(isCloseout);

        insert allBudgets;
        
        if (labExpResource != null) {
            for (BudgetAssignment__c ba : labExpAssignments) {
                ba.BudgetResource__c = labExpResource.Id;
            }
        }
        //insert mapResourceBySubId.values();
        //insert mapResourceByContingencyName.values();

        for (String contName : mapResourceByContingencyName.keySet()) {
            Id brId = mapResourceByContingencyName.get(contName).Id;

            for (BudgetAssignment__c ba : mapAssignmentsByContingencyName.get(contName)) {
                ba.BudgetResource__c = brId;
            }
        }

        for (String expType : mapResourceByExpType.keySet()) {
            Id brId = mapResourceByExpType.get(expType).Id;

            for (BudgetAssignment__c ba : mapAssignmentsByExpType.get(expType)) {
                ba.BudgetResource__c = brId;
            }
        }

        for (String subId : mapResourceBySubId.keySet()) {
            Id brId = mapResourceBySubId.get(subId).Id;

            for (BudgetAssignment__c ba : mapAssignmentsBySubId.get(subId)) {
                ba.BudgetResource__c = brId;
            }
        }

        for (String ptmId : mapResourceByPTMId.keySet()) {
            Id brId = mapResourceByPTMId.get(ptmId).Id;

            for (BudgetAssignment__c ba : mapAssignmentsByPTMId.get(ptmId)) {
                ba.BudgetResource__c = brId;
            }
        }

        // Insert All Budget Asssignments
        insert mapAssignmentByUniqueId.values();

        if(isCloseout)
        {
            if(topTaskRevenueBudget)
            {
                BudgetTask__c budgetTask = mBudgetTask.get(projectTasks[0].Id);
                budgetTask.OverrideTotalRevenue__c = overrideRevenueAmount;

                try
                {
                    update budgetTask;
                }
                catch (Exception e)
                {
                    ECO_Service_ErrorLog.formatPageError(e, 'Error while updating closeout budget revenue: ' + e.getMessage());
                }
            }
            else
            {
                oBudgetHeader.OverrideTotalRevenue__c = overrideRevenueAmount;
                ECO_BudgetHeaderTriggers.run = false;
                try
                {
                    update oBudgetHeader;
                }
                catch (Exception e)
                {
                    ECO_Service_ErrorLog.formatPageError(e, 'Error while updating closeout budget revenue: ' + e.getMessage());
                }
                ECO_BudgetHeaderTriggers.run = true;
            }
        }

        // Clear Bypass All Project Task Triggers
        ECO_TriggerSettings.clearBypassTrigger('PT');
        ECO_TriggerSettings.clearBypass('PR_handleApprovalStageChanges');
        
        // Set zero ETC if closeout budget
        /*
        if (isCloseout) {
            Id jobId = AsyncSetZeroETC.run(oBudgetHeader.Id);
        }
        */
        return oBudgetHeader.Id;
    }
    
// Return Id of new budget header created
    public static Id createInitECO(Id sProjectId) {
        // Clear Bypass All Project Task Triggers
        System.Debug('BrentBrentBrent createInitECO' + Limits.getHeapSize());
        ECO_TriggerSettings.bypass('PR_handleApprovalStageChanges');
        ECO_TriggerSettings.bypassTrigger('PT');
        createExpTypes();

        mapResourceByPTMId = new Map <String, BudgetResource__c> ();
        mapResourceBySubId = new Map <String, BudgetResource__c> ();
        mapResourceByContingencyName = new Map <String, BudgetResource__c> ();
        mapResourceByExpType = new Map <String, BudgetResource__c> ();
        // Stores BAs so we can set the BudgetResource__c Id after the records are inserted
        mapAssignmentsByPTMId = new Map <String, List<BudgetAssignment__c>> ();
        mapAssignmentsBySubId = new Map <String, List<BudgetAssignment__c>> ();
        mapAssignmentsByContingencyName = new Map <String, List<BudgetAssignment__c>> ();
        mapAssignmentsByExpType = new Map <String, List<BudgetAssignment__c>> ();

        mapAssignmentByUniqueId = new Map <String, BudgetAssignment__c> ();

        mapResourcesByPersonId = new Map<String, BudgetResource__c>();

        Map<String, ProjectTeamMember__c> mapPTMByPersonId = new Map<String, ProjectTeamMember__c> ();
        Map<String, VendorSite__c> mapVSbyVendorId = new Map<String, VendorSite__c> ();


        Set<String> PersonIdsInBudget = new Set<String>();
        Set<Id> VendorIdsInBudget = new Set<Id>();


        createProjectTasks(sProjectId, 'Specific EAC');
        // list<RecordType> lstRT = [select id from recordtype where sObjectType='ChangeManager__c' and developername='InternalChange'];

        // TODO: Make sure assumption that every Account and User has an associated oracle id is true. if not we should account for it in the code.
        // Link Person Ids from PTMs
        for (ProjectTeamMember__c ptm : [Select Id, OraclePersonId__c, Project__c, Contact__c From ProjectTeamMember__c Where Project__c = :sProjectId Order By Is_Active__c]) {
            // If there's an active role that will take precedent over in_active ptms
            mapPTMByPersonId.put(ptm.OraclePersonId__c, ptm);
        }

        // Link Vendor Ids from VS
        for (VendorSite__c vs : [Select Id, Site__r.Account__r.OracleVendorID__c, Project__c From VendorSite__c Where Project__c = :sProjectId]) {
            mapVSbyVendorId.put(vs.Site__r.Account__r.OracleVendorID__c, vs);
        }

        AggregateResult[] arTotals = [Select Sum(Quantity__c) Quantity__c, Sum(AppliedTtlRawCstNm__c) TotalRawCost, Sum(FullyBurdenedCostNumber__c) FullyBurdenedCost__c, 
                            SUM(TotalFringeNum__c) TotalFringe__c, SUM(TotalOverheadNum__c) TotalOverhead__c, Sum(CalculatedRevenueNumber__c) TotalRevenue,
                                        BudgetTask__r.ProjectTask__c, BudgetResource__r.ProjectTeamMember__r.Contact__r.Person_ID__c, BudgetTask__r.BudgetHeader__r.Status__c
                                      From BudgetAssignment__c
                                      Where BudgetTask__r.ProjectTask__r.pse__Project__c = :sProjectId AND ResourceType__c = 'Labor/Person' 
                                        AND BudgetResource__r.IsHidden__c = false
                                        AND (BudgetTask__r.BudgetHeader__r.Status__c = 'Forecast' OR BudgetTask__r.BudgetHeader__r.Status__c = 'Approved')
                                              GROUP BY BudgetTask__r.ProjectTask__c, BudgetResource__r.ProjectTeamMember__r.Contact__r.Person_ID__c, BudgetTask__r.BudgetHeader__r.Status__c
                                     ];

        AggregateResult[] arTotalsHidden = [Select Sum(Quantity__c) Quantity__c, Sum(AppliedTtlRawCstNm__c) TotalRawCost, Sum(FullyBurdenedCostNumber__c) FullyBurdenedCost__c, 
                            SUM(TotalFringeNum__c) TotalFringe__c, SUM(TotalOverheadNum__c) TotalOverhead__c, Sum(CalculatedRevenueNumber__c) TotalRevenue,
                                        BudgetTask__r.ProjectTask__c, BudgetTask__r.BudgetHeader__r.Status__c
                                      From BudgetAssignment__c
                                      Where BudgetTask__r.ProjectTask__r.pse__Project__c = :sProjectId AND ResourceType__c = 'Labor/Person' 
                                        AND BudgetResource__r.IsHidden__c = true
                                        AND (BudgetTask__r.BudgetHeader__r.Status__c = 'Forecast' OR BudgetTask__r.BudgetHeader__r.Status__c = 'Approved')
                                              GROUP BY BudgetTask__r.ProjectTask__c, BudgetTask__r.BudgetHeader__r.Status__c
                                     ];

        AggregateResult[] arSubs = [Select Sum(AppliedTtlRawCstNm__c) AppliedTtlRawCstNm__c, Sum(CalculatedRevenueNumber__c) TotalRevenue,
                                        BudgetTask__r.ProjectTask__c, BudgetResource__r.VendorSite__c, BudgetTask__r.BudgetHeader__r.Status__c
                                    From BudgetAssignment__c
                                    Where BudgetTask__r.ProjectTask__r.pse__Project__c = :sProjectId AND ResourceType__c = 'Subcontractor' AND
                                            (BudgetTask__r.BudgetHeader__r.Status__c = 'Forecast' OR BudgetTask__r.BudgetHeader__r.Status__c = 'Approved')
                                            GROUP BY BudgetTask__r.ProjectTask__c, BudgetResource__r.VendorSite__c, BudgetTask__r.BudgetHeader__r.Status__c
                                   ];

        AggregateResult[] arContingency = [Select Sum(AppliedTtlRawCstNm__c) AppliedTtlRawCstNm__c, Sum(CalculatedRevenueNumber__c) TotalRevenue,
                                        BudgetTask__r.ProjectTask__c, BudgetResource__r.JobName__c, BudgetTask__r.BudgetHeader__r.Status__c
                                           From BudgetAssignment__c
                                           Where BudgetTask__r.ProjectTask__r.pse__Project__c = :sProjectId AND ResourceType__c = 'Contingency' AND
                                                   (BudgetTask__r.BudgetHeader__r.Status__c = 'Forecast' OR BudgetTask__r.BudgetHeader__r.Status__c = 'Approved')
                                                   GROUP BY BudgetTask__r.ProjectTask__c, BudgetResource__r.JobName__c, BudgetTask__r.BudgetHeader__r.Status__c
                                          ];

        AggregateResult[] arExp = [Select Sum(AppliedTtlRawCstNm__c) AppliedTtlRawCstNm__c, Sum(CalculatedRevenueNumber__c) TotalRevenue,
                                    BudgetTask__r.ProjectTask__c, BudgetResource__r.ExpenditureType__c, BudgetTask__r.BudgetHeader__r.Status__c
                                   From BudgetAssignment__c
                                   Where BudgetTask__r.ProjectTask__r.pse__Project__c = :sProjectId AND ResourceType__c = 'ODC/FEE' AND
                                           (BudgetTask__r.BudgetHeader__r.Status__c = 'Forecast' OR BudgetTask__r.BudgetHeader__r.Status__c = 'Approved')
                                           GROUP BY BudgetTask__r.ProjectTask__c, BudgetResource__r.ExpenditureType__c, BudgetTask__r.BudgetHeader__r.Status__c];

        AggregateResult[] arLaborActuals = [SELECT PersonId__c, SUM(Quantity__c) Quantity__c, SUM(ProjectFunctionalBurdenedCost__c) totalRawCost, ProjectTask__c, VendorId__c
                                            FROM ExpendItem__c Where Project__c = :sProjectId AND ExpenditureType__c IN :oracleLabNames
                                                    GROUP BY ProjectTask__c, VendorId__c, PersonId__c
                                           ];

        AggregateResult[] arSubActuals = [SELECT PersonId__c, SUM(Quantity__c) Quantity__c, SUM(ProjectFunctionalBurdenedCost__c) totalRawCost, ProjectTask__c, VendorId__c
                                          FROM ExpendItem__c Where Project__c = :sProjectId AND ExpenditureType__c IN :oracleSubsName
                                                  GROUP BY ProjectTask__c, VendorId__c, PersonId__c
                                         ];

        AggregateResult[] arExpActuals = [SELECT SUM(Quantity__c) Quantity__c, SUM(ProjectFunctionalBurdenedCost__c) totalRawCost, ProjectTask__c, ExpenditureType__c
                                          FROM ExpendItem__c Where Project__c = :sProjectId AND ExpenditureType__c IN :oracleExpNames
                                                  GROUP BY ProjectTask__c, ExpenditureType__c
                                         ];

        /*
        AggregateResult[] arLabExpActuals = [SELECT SUM(Quantity__c) Quantity__c, SUM(ProjectFunctionalBurdenedCost__c) totalCost, ProjectTask__c
                                          FROM ExpendItem__c Where Project__c = :sProjectId AND ExpenditureType__c IN :oracleLabExpNames
                                                  GROUP BY ProjectTask__c
                                         ];
        */
        AggregateResult[] arLabExpFringeActuals = [SELECT SUM(Quantity__c) Quantity__c, SUM(ProjectFunctionalBurdenedCost__c) totalRawCost, ProjectTask__c
                                          FROM ExpendItem__c Where Project__c = :sProjectId AND ExpenditureType__c IN :oracleLabExpFringeNames
                                                  GROUP BY ProjectTask__c
                                         ];

        AggregateResult[] arLabExpOverheadActuals = [SELECT SUM(Quantity__c) Quantity__c, SUM(ProjectFunctionalBurdenedCost__c) totalRawCost, ProjectTask__c
                                          FROM ExpendItem__c Where Project__c = :sProjectId AND ExpenditureType__c IN :oracleLabExpOverheadNames
                                                  GROUP BY ProjectTask__c
                                         ];
        System.Debug('BrentBrentBrent after aggregates' + Limits.getHeapSize());

        /*
        for (AggregateResult ar : arLabExpActuals) {
            Decimal quantity = (Decimal)ar.get('Quantity__c');
            Decimal totalCost = (Decimal)ar.get('totalCost');
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            BudgetAssignment__c ba = addLabExp( projectTaskId);

            ba.EACActualQuantity__c = quantity;
            ba.EACActualCost__c = totalCost;
        }
        */
        
        for (AggregateResult ar : arLabExpFringeActuals) {
            Decimal quantity = (Decimal)ar.get('Quantity__c');
            Decimal totalCost = (Decimal)ar.get('totalRawCost');
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            BudgetAssignment__c ba = addLabExp(projectTaskId);
            // ba.EACActualQuantity__c = quantity;
            ba.EACActualFringe__c = totalCost;
            // if (isCloseout) ba.OverrideTotalFringe__c = totalCost;
        }

        for (AggregateResult ar : arLabExpOverheadActuals) {
            Decimal quantity = (Decimal)ar.get('Quantity__c');
            Decimal totalCost = (Decimal)ar.get('totalRawCost');
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            BudgetAssignment__c ba = addLabExp(projectTaskId);
            // ba.EACActualQuantity__c = quantity + ifNull(ba.EACActualQuantity__c);
            ba.EACActualOverhead__c = totalCost; //  + ifNull(ba.EACActualCost__c);
            // if (isCloseout) ba.OverrideTotalOverhead__c = totalCost;
        }

        for (AggregateResult ar : arTotalsHidden) {

            String status = (String)ar.get('Status__c');
            Decimal quantity = (Decimal)ar.get('Quantity__c');
            Decimal totalCost = (Decimal)ar.get('FullyBurdenedCost__c');
            Id projectTaskId = (Id)ar.get('ProjectTask__c');

            BudgetAssignment__c ba = addLabExp(projectTaskId);
             
            ba.EACForecastFringe__c = ifNull((Decimal)ar.get('TotalFringe__c'));
            ba.EACForecastOverhead__c = ifNull((Decimal)ar.get('TotalOverhead__c'));
            ba.EACForecastTotalCost__c = ba.EACForecastFringe__c + ba.EACForecastOverhead__c;
            ba.OverrideRawCost__c = 0;
            /* [TESTING]
            if (status == 'Approved') {
                ba.EACApprovedQuantity__c = ifNull(quantity);
                ba.EACApprovedTotalCost__c = ifNull(totalCost);
                ba.EACApprovedRawCost__c = ifNull((Decimal)ar.get('TotalRawCost'));
                ba.EACApprovedRevenue__c = ifNull((Decimal)ar.get('TotalRevenue'));
            } else if (status == 'Forecast') {
                ba.EACForecastQuantity__c = ifNull(quantity);
                ba.EACForecastTotalCost__c = ifNull(totalCost);
                ba.EACForecastRawCost__c = ifNull((Decimal)ar.get('TotalRawCost'));
                ba.EACForecastRevenueNumber__c = ifNull((Decimal)ar.get('TotalRevenue'));
            }
            */
        }

        for (AggregateResult ar : arSubs) {
            String subId = (String)ar.get('VendorSite__c');

            if (subId != null) VendorIdsInBudget.add(subId);
        }

        Set<String> vendorIdsToAdd = new Set<String>();

        // List<ProjectTeamMember__c> vendorSitesToAdd = new List<ProjectTeamMember__c>();

        for (AggregateResult ar : arSubActuals) {
            String vendorId = (String)ar.get('VendorId__c');

            if (vendorId == null) {
                throw new EacException('VendorId is null on Expenditure Item');
            }

            VendorSite__c vs = mapVSbyVendorId.get(vendorId);

            if (vs == null) {
                vendorIdsToAdd.add(vendorId);
            }
        }

        if (!vendorIdsToAdd.isEmpty()) {
            // create map of sites to vendor Id
            // TODO: Implement adding vendor site

            //throw new EacException('Vendor Site found on expenditure item not in budget');
            //ProjectRole__c prl = [select id from ProjectRole__c where Name = 'Task Manager'];
            List<VendorSite__c> vendorSitesToAdd = new List<VendorSite__c>();

            for (Account acc : [Select Id, OracleVendorID__c, (Select Id From Sites__r Limit 1) From Account Where OracleVendorID__c in :vendorIdsToAdd]) {
                VendorSite__c vendorSite = new VendorSite__c();
                vendorSite.Project__c = sProjectId;
                vendorSite.Site__c = acc.Sites__r[0].Id;
                vendorSite.Type__c = 'Sub';

                vendorSitesToAdd.add(vendorSite);
                mapVSbyVendorId.put(acc.OracleVendorID__c, vendorSite);
            }

            System.Debug('BrentBrentBrent vendor sites' + Limits.getHeapSize());
            insert vendorSitesToAdd;
        }


        for (AggregateResult ar : arSubActuals) {
            Id projectTaskId = (Id)ar.get('ProjectTask__c');
            String vendorId = (String)ar.get('VendorId__c');

            if (vendorId == 'null' || projectTaskId == null) continue;

            VendorSite__c vs = mapVSByVendorId.get(vendorId);

            Id subId = vs == null ? null : vs.Id;

            Decimal totalRawCost = (Decimal)ar.get('totalRawCost');

            BudgetAssignment__c ba = addSubBA(subId, projectTaskId);

            ba.EACActualCost__c += totalRawCost;
        }


        for (AggregateResult ar : arSubs) {
            Id projectTaskId = (Id)ar.get('ProjectTask__c');
            String subId = (String)ar.get('VendorSite__c');

            if (projectTaskId == null) continue;
            String status = (String)ar.get('Status__c');
            Decimal quantity = (Decimal)ar.get('AppliedTtlRawCstNm__c');


            BudgetAssignment__c ba = addSubBA(subId, projectTaskId);

            
            if (status == 'Approved') {
                ba.EACApprovedRawCost__c += quantity;
                ba.EACApprovedTotalCost__c  += quantity;
                ba.EACApprovedRevenue__c += (Decimal)ar.get('TotalRevenue');
            } else if (status == 'Forecast') {
                ba.EACForecastRawCost__c  += quantity;
                ba.EACForecastTotalCost__c  += quantity;
                ba.EACForecastRevenueNumber__c += (Decimal)ar.get('TotalRevenue');
            }

        }

        for (AggregateResult ar : arExpActuals) {
            Id projectTaskId = (Id)ar.get('ProjectTask__c');
            String expType = (String)ar.get('ExpenditureType__c');

            if (expType == 'null' || projectTaskId == null) continue;

            Decimal totalRawCost = (Decimal)ar.get('totalRawCost');

            BudgetAssignment__c ba = addExpBA(expType, projectTaskId);

            ba.EACActualCost__c = totalRawCost;
        }

        for (AggregateResult ar : arExp) {
            Id projectTaskId = (Id)ar.get('ProjectTask__c');
            String expType = (String)ar.get('ExpenditureType__c');

            if (expType == null || projectTaskId == null) continue;
            String status = (String)ar.get('Status__c');
            Decimal totalRawCost = (Decimal)ar.get('AppliedTtlRawCstNm__c');

            BudgetAssignment__c ba = addExpBA(expType, projectTaskId);
            
            if (status == 'Approved') {
                ba.EACApprovedRawCost__c  = totalRawCost;
                ba.EACApprovedTotalCost__c  = totalRawCost;
                ba.EACApprovedRevenue__c = (Decimal)ar.get('TotalRevenue');
            } else if (status == 'Forecast') {
                ba.EACForecastRawCost__c  = totalRawCost;
                ba.EACForecastTotalCost__c  = totalRawCost;
                ba.EACForecastRevenueNumber__c = (Decimal)ar.get('TotalRevenue');
            }
        }

        for (AggregateResult ar : arContingency) {
            Id projectTaskId = (Id)ar.get('ProjectTask__c');
            String contName = (String)ar.get('JobName__c');

            if (projectTaskId == null) continue;
            String status = (String)ar.get('Status__c');
            Decimal quantity = (Decimal)ar.get('AppliedTtlRawCstNm__c');
            Id budgetTaskId = mBudgetTask.get(projectTaskId).Id;
            BudgetResource__c budgetResource = mapResourceByContingencyName.get(contName);

            if (budgetResource == null) {
                budgetResource = new BudgetResource__c();
                budgetResource.BudgetHeader__c = oBudgetHeader.id;
                budgetResource.OverrideRatesOnLines__c = true;
                budgetResource.ResourceType__c = 'Contingency';
                // TODO: ???
                // budgetResource.OverrideBillRate__c = theProject.DefaultBillRate__c;
                // budgetResource.OverrideUplift__c = theProject.DefaultUpliftLabor__c;
                budgetResource.JobName__c = contName;

                mapResourceByContingencyName.put(contName, budgetResource);
            }

            List<BudgetAssignment__c> oAssignments = mapAssignmentsByContingencyName.get(contName);

            if (oAssignments == null) {
                oAssignments = new List<BudgetAssignment__c> ();
                mapAssignmentsByContingencyName.put(contName, oAssignments);
            }

            String uniqueId = 'Contingency' + contName + uniqueDelim + projectTaskId;
            BudgetAssignment__c ba = mapAssignmentByUniqueId.get(uniqueId);
            if (ba == null) {
                ba = new BudgetAssignment__c();
                ba.EACApprovedTotalCost__c = 0;
                ba.EACForecastTotalCost__c = 0;
                mapAssignmentByUniqueId.put(uniqueId, ba);
                oAssignments.add(ba); // make sure we only the BA once
            }

            ba.BudgetTask__c = budgetTaskId;
            
            if (status == 'Approved') {
                ba.EACApprovedRawCost__c  = quantity;
                ba.EACApprovedTotalCost__c  = quantity;
                ba.EACApprovedRevenue__c = (Decimal)ar.get('TotalRevenue');
            } else if (status == 'Forecast') {
                ba.EACForecastRawCost__c  = quantity;
                ba.EACForecastTotalCost__c  = quantity;
                ba.EACForecastRevenueNumber__c = (Decimal)ar.get('TotalRevenue');
            }

        }



        for (AggregateResult ar : arTotals) {
            String personId = (String)ar.get('Person_ID__c');

            if (personId != null) PersonIdsInBudget.add(personId);
        }

        Set<String> personIdsToAdd = new Set<String>();

        List<ProjectTeamMember__c> ptmsToAdd = new List<ProjectTeamMember__c>();

        for (AggregateResult ar : arLaborActuals) {
            String personId = (String)ar.get('PersonId__c');

            if (personId == null) {
                continue;
                throw new EacException('PersonId is null on Expenditure Item');
            }

            ProjectTeamMember__c ptm = mapPTMByPersonId.get(personId);

            if (ptm == null) {
                mapPTMByPersonId.put(personId, null);
                personIdsToAdd.add(personId);
            } 
        }

        System.Debug('BrentBrentBrent before personIdsToAdd' + Limits.getHeapSize());
        if (!personIdsToAdd.isEmpty()) {
            ProjectRole__c prl = [select id from ProjectRole__c where Name = 'Other'];

            for (Contact con : [Select Id, Person_ID__c From Contact Where Person_ID__c in :personIdsToAdd]) {
                ProjectTeamMember__c ptm = new ProjectTeamMember__c();
                ptm.contact__c = con.Id;
                ptm.project__c = sProjectId;
                ptm.ProjectRole__c = prl.id;

                ptmsToAdd.add(ptm);
                mapPTMByPersonId.put(con.Person_ID__c, ptm);
            }

            ECO_Project_TeamMember_Triggers.run = false;
            insert ptmsToAdd;
            ECO_Project_TeamMember_Triggers.run = true;
        }

        Integer formerEmployeeCount = 0;
        for (AggregateResult ar : arLaborActuals) {
            String personId = (String)ar.get('PersonId__c');
            Decimal quantity = (Decimal)ar.get('Quantity__c');
            Decimal totalRawCost = (Decimal)ar.get('totalRawCost');
            Id projectTaskId = (Id)ar.get('ProjectTask__c');
            Id budgetTaskId = mBudgetTask.get(projectTaskId).Id;
            ProjectTeamMember__c ptm =  mapPTMByPersonId.get(personId);
            BudgetResource__c budgetResource;
            String ptmId;

            if(quantity == null) {
                quantity = 0;
            }

            if (ptm != null) {
                ptmId = ptm.Id;
            } else {
                ptmId = 'FormerEmployees'; // + (formerEmployeeCount++);
                //system.debug('No personId: ' + personId + ' - ptmId: ' + ptmId);
                personId = 'FormerEmployees';
            }

            budgetResource = mapResourceByPTMId.get(personId);

            if (budgetResource == null) {
                budgetResource = new BudgetResource__c();
                budgetResource.BudgetHeader__c = oBudgetHeader.id;
                budgetResource.OverrideRatesOnLines__c = true;
                budgetResource.ResourceType__c = 'Labor/Person';
                /* if (quantity != 0 && quantity != null) {
                    budgetResource.OverrideRawCost__c = totalRawCost / quantity;
                    }*/
                // TODO: ???
                // budgetResource.OverrideBillRate__c = theProject.DefaultBillRate__c;
                // budgetResource.OverrideUplift__c = theProject.DefaultUpliftLabor__c;

                defaultBillRates(budgetResource);
                
                if (ptm != null) {
                    budgetResource.ProjectTeamMember__c = ptmId;
                    budgetResource.Resource__c = ptm.Contact__c;
                } else {
                    budgetResource.JobName__c = 'Former Employees';
                    budgetResource.OverrideRawCost__c = 0;
                    budgetResource.OverrideFringeMultiplier__c = 0;
                    budgetResource.OverrideOverheadMultiplier__c = 0;
                    budgetResource.OverrideFringeMultiplierField__c = 0;
                    budgetResource.OverrideOverheadMultiplierField__c = 0;
                }

                mapResourceByPTMId.put(ptmId, budgetResource);
            }

            List<BudgetAssignment__c> oAssignments = mapAssignmentsByPTMId.get(ptmId);

            if (oAssignments == null) {
                oAssignments = new List<BudgetAssignment__c> ();
                mapAssignmentsByPTMId.put(ptmID, oAssignments);
            }

            String uniqueId = 'Person' + personId + uniqueDelim + projectTaskId;
            BudgetAssignment__c ba = mapAssignmentByUniqueId.get(uniqueId);
            if (ba == null) {
                ba = new BudgetAssignment__c();
                ba.EACApprovedTotalCost__c = 0;
                ba.EACForecastTotalCost__c = 0;
                ba.EACApprovedQuantity__c = 0;
                ba.EACForecastQuantity__c = 0;
                ba.EACForecastFringe__c = 0;
                ba.EACForecastOverhead__c = 0;
                ba.EACActualQuantity__c = 0;
                ba.EACActualCost__c = 0;
                ba.EACForecastRawCost__c = 0;
                ba.EACForecastRevenueNumber__c = 0;
                mapAssignmentByUniqueId.put(uniqueId, ba);
                oAssignments.add(ba); // make sure we only the BA once
            }

            ba.BudgetTask__c = budgetTaskId;

            /* if (quantity != 0 && quantity != null) {
                budgetResource.OverrideRawCost__c = totalRawCost / quantity;
            }
            */

            //if (ba.EACActualCost__c != 0) system.debug('ptmId - ' + ptmId + ': ba.EACActualCost__c = ' + ba.EACActualCost__c + ' + ' +  totalRawCost);
            ba.EACActualQuantity__c += quantity;
            ba.EACActualCost__c += totalRawCost;
        }

        for (AggregateResult ar : arTotals) {
            Id projectTaskId = (Id)ar.get('ProjectTask__c');
            String personId = (String)ar.get('Person_ID__c');
            ProjectTeamMember__c ptm = mapPTMByPersonId.get(personId);

            Id ptmId = ptm != null ? ptm.Id : null;

            if (projectTaskId == null) continue;

            if (personId != null) PersonIdsInBudget.add(personId);

            String status = (String)ar.get('Status__c');
            Decimal quantity = (Decimal)ar.get('Quantity__c');
            Decimal totalCost = (Decimal)ar.get('FullyBurdenedCost__c');
            totalCost = totalCost == null ? 0 : totalCost;

            Id budgetTaskId = mBudgetTask.get(projectTaskId).Id;
            BudgetResource__c budgetResource = mapResourceByPTMId.get(ptmId);

            if (budgetResource == null) {
                budgetResource = new BudgetResource__c();
                budgetResource.BudgetHeader__c = oBudgetHeader.id;
                budgetResource.OverrideRatesOnLines__c = true;
                budgetResource.ResourceType__c = 'Labor/Person';
                defaultBillRates(budgetResource);
                // TODO: ???
                // budgetResource.OverrideBillRate__c = theProject.DefaultBillRate__c;
                // budgetResource.OverrideUplift__c = theProject.DefaultUpliftLabor__c;
                budgetResource.JobName__c = null;

                budgetResource.ProjectTeamMember__c = ptmId;
                budgetResource.Resource__c = ptm == null ? null : ptm.Contact__c;
                mapResourceByPTMId.put(ptmId, budgetResource);
            }

            List<BudgetAssignment__c> oAssignments = mapAssignmentsByPTMId.get(ptmId);

            if (oAssignments == null) {
                oAssignments = new List<BudgetAssignment__c> ();
                mapAssignmentsByPTMId.put(ptmID, oAssignments);
            }

            String uniqueId = 'Person' + personId + uniqueDelim + projectTaskId;
            BudgetAssignment__c ba = mapAssignmentByUniqueId.get(uniqueId);
            if (ba == null) {
                ba = new BudgetAssignment__c();
                ba.EACApprovedTotalCost__c = 0;
                ba.EACForecastTotalCost__c = 0;
                ba.EACApprovedQuantity__c = 0;
                ba.EACForecastQuantity__c = 0;
                ba.EACForecastFringe__c = 0;
                ba.EACForecastOverhead__c = 0;
                ba.EACApprovedRawCost__c = 0;
                ba.EACApprovedRevenue__c = 0;
                ba.EACForecastRawCost__c = 0;
                ba.EACForecastRevenueNumber__c = 0;
                mapAssignmentByUniqueId.put(uniqueId, ba);
                oAssignments.add(ba); // make sure we only the BA once
            }

            ba.BudgetTask__c = budgetTaskId;
            
            ba.EACForecastFringe__c += ifNull((Decimal)ar.get('TotalFringe__c'));
            ba.EACForecastOverhead__c += ifNull((Decimal)ar.get('TotalOverhead__c'));


            if (status == 'Approved') {
                ba.EACApprovedRawCost__c = ifNull(ba.EACApprovedRawCost__c);
                ba.EACApprovedRevenue__c = ifNull(ba.EACApprovedRevenue__c);
                ba.EACApprovedQuantity__c += ifNull(quantity);
                ba.EACApprovedTotalCost__c += ifNull(totalCost);
                ba.EACApprovedRawCost__c += ifNull((Decimal)ar.get('TotalRawCost'));
                ba.EACApprovedRevenue__c += ifNull((Decimal)ar.get('TotalRevenue'));
            } else if (status == 'Forecast') {
                ba.EACForecastRawCost__c = ifNull(ba.EACForecastRawCost__c);
                ba.EACForecastRevenueNumber__c = ifNull(ba.EACForecastRevenueNumber__c);
                ba.EACForecastQuantity__c += ifNull(quantity);
                ba.EACForecastTotalCost__c += ifNull(totalCost);
                ba.EACForecastRawCost__c += ifNull((Decimal)ar.get('TotalRawCost'));
                ba.EACForecastRevenueNumber__c += ifNull((Decimal)ar.get('TotalRevenue'));
            }

        }

        // Insert All budgetResources
        List<BudgetResource__c> allBudgets = new List<BudgetResource__c>();
        allBudgets.addAll(mapResourceByPTMId.values());
        allBudgets.addAll(mapResourceByContingencyName.values());
        allBudgets.addAll(mapResourceBySubId.values());
        allBudgets.addAll(mapResourceByExpType.values());

        if(labExpResource != null) allBudgets.add(labExpResource);
        
        /*** Set default values on all Budget Assignments And Budget Resources ***/
        //system.debug('mapAssignmentByUniqueId size before: ' + mapAssignmentByUniqueId.size());
        System.Debug('BrentBrentBrent before calculate defaults' + Limits.getHeapSize());
        calculateDefaults();
        System.Debug('BrentBrentBrent after calculate defaults 1' + Limits.getHeapSize());
        
        System.Debug('BrentBrentBrent after calculate defaults 2' + Limits.getHeapSize());
        //system.debug('mapAssignmentByUniqueId size after: ' + mapAssignmentByUniqueId.size());        

        System.Debug('BrentBrentBrent before insert all budgets' + Limits.getHeapSize());

        insert allBudgets;

        System.Debug('BrentBrentBrent after insert all budgets' + Limits.getHeapSize());
        
        if (labExpResource != null) {
            for (BudgetAssignment__c ba : labExpAssignments) {
                ba.BudgetResource__c = labExpResource.Id;
            }
        }

        //insert mapResourceBySubId.values();
        //insert mapResourceByContingencyName.values();

        for (String contName : mapResourceByContingencyName.keySet()) {
            Id brId = mapResourceByContingencyName.get(contName).Id;

            for (BudgetAssignment__c ba : mapAssignmentsByContingencyName.get(contName)) {
                ba.BudgetResource__c = brId;
            }
        }

        for (String expType : mapResourceByExpType.keySet()) {
            Id brId = mapResourceByExpType.get(expType).Id;

            for (BudgetAssignment__c ba : mapAssignmentsByExpType.get(expType)) {
                ba.BudgetResource__c = brId;
            }
        }

        for (String subId : mapResourceBySubId.keySet()) {
            Id brId = mapResourceBySubId.get(subId).Id;

            for (BudgetAssignment__c ba : mapAssignmentsBySubId.get(subId)) {
                ba.BudgetResource__c = brId;
            }
        }

        for (String ptmId : mapResourceByPTMId.keySet()) {
            Id brId = mapResourceByPTMId.get(ptmId).Id;
            //system.debug('mapResourceByPTMId key: ' + ptmId);
            for (BudgetAssignment__c ba : mapAssignmentsByPTMId.get(ptmId)) {
                ba.BudgetResource__c = brId;
            }
        }
       
        // Insert All Budget Asssignments

        insert mapAssignmentByUniqueId.values();
        // Clear Bypass All Triggers
        ECO_TriggerSettings.clearBypassTrigger('PT');
        ECO_TriggerSettings.bypassTrigger('BT');
        ECO_TriggerSettings.clearBypass('PR_handleApprovalStageChanges');
        return oBudgetHeader.Id;
    }

    private static Decimal ifNull(Decimal val) {
        return val == null ? 0 : val;
    }
}