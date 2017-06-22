public class ECO_CalcualteBudgets {    
    
     public class TaskCostDetail {
          public String  taskName             {get; set;}
          public Id      taskId               {get; set;}
          public Decimal approvedRawCost      {get; set;}
          public Decimal forecastRawCost      {get; set;}
          public Decimal approvedBurdenedCost {get; set;}
          public Decimal forecastBurdenedCost {get; set;}
          public String  resourceListAlias    {get; set;}
          public String  resourceListName     {get; set;}
          public Decimal forecastQuantity     {get; set;}
          public Decimal approvedQuantity     {get; set;}

          public TaskCostDetail(Id taskId, String resourceListAlias, String resourceListName) {
               this.taskId = taskId;
               this.approvedRawCost = 0;
               this.forecastRawCost = 0;
               this.approvedBurdenedCost = 0;
               this.forecastBurdenedCost = 0;
               this.approvedQuantity = 0;
               this.forecastQuantity = 0;
               this.resourceListAlias = resourceListAlias;
               this.resourceListName = resourceListName;
          }
     }

    private class RevenueDetail {

        public Id      taskId               {get; set;}
        public Decimal approvedrevenue      {get; set;}
        public Decimal forecastRevenue      {get; set;}

        public RevenueDetail() {
            this.approvedRevenue = 0;
            this.forecastRevenue = 0;
        }

        public RevenueDetail(Id taskId) {
            this.taskId = taskId;
            this.approvedRevenue = 0;
            this.forecastRevenue = 0;
        }

     }    

     public static Map<String, TaskCostDetail> calcTotalBudgetHeaders(Id projectId, Map<Id, BudgetHeader__c> budgetHeaderMap) {
        Map<String, TaskCostDetail> costDetailMap = new Map<String, TaskCostDetail>();
        List<pse__Proj__c> projects = [select Id, BudgetStrategyRevenue__c, CurrencyIsoCode from pse__Proj__c where Id = :projectId];

        TaskCostDetail taskCostDetail;
        BudgetHeader__c budgetHeader;

        for(BudgetAssignment__c budgetAssignment:[Select BudgetTask__c, Status__c, AppliedTtlRawCst__c, FullyBurdenedCost__c, TotalOverhead__c, TotalFringe__c, BudgetResource__r.AppliedResourceAlias__c                                        
                                                , BudgetResource__r.AppliedResourceListName__c, BudgetTask__r.BudgetHeader__c, BudgetTask__r.ProjectTask__c, AppliedRawCost__c,
                                                Quantity__c, BudgetTask__r.ProjectTask__r.Name, BudgetTask__r.BudgetHeader__r.WorkAtRisk__c
                                                From BudgetAssignment__c 
                                                Where BudgetTask__r.BudgetHeader__c In :budgetHeaderMap.keySet()
                                                Order By BudgetTask__r.BudgetHeader__r.CreatedDate]) {

            budgetHeader = budgetHeaderMap.get(budgetAssignment.BudgetTask__r.BudgetHeader__c);
            String mapKey = budgetAssignment.BudgetTask__r.ProjectTask__c + budgetAssignment.BudgetResource__r.AppliedResourceAlias__c + budgetAssignment.BudgetResource__r.AppliedResourceListName__c;
            if(!costDetailMap.containsKey(mapKey)) {
                costDetailMap.put(mapKey, new TaskCostDetail(budgetAssignment.BudgetTask__r.ProjectTask__c, budgetAssignment.BudgetResource__r.AppliedResourceAlias__c, budgetAssignment.BudgetResource__r.AppliedResourceListName__c ));
            }
            taskCostDetail = costDetailMap.get(mapKey);
            taskCostDetail.taskName = budgetAssignment.BudgetTask__r.ProjectTask__r.Name;
            if(budgetAssignment.AppliedTtlRawCst__c != null) {
              taskCostDetail.forecastRawCost += budgetAssignment.AppliedTtlRawCst__c;
            }
            if(budgetAssignment.Quantity__c != null) {
                taskCostDetail.forecastQuantity += budgetAssignment.Quantity__c;
            }
            if(budgetHeader.MultiLineBurdened__c) {
                if(budgetAssignment.AppliedTtlRawCst__c != null) {
                  taskCostDetail.forecastBurdenedCost += budgetAssignment.AppliedTtlRawCst__c;  
                }
            }
            else {
                if(budgetAssignment.FullyBurdenedCost__c != null) {
                  taskCostDetail.forecastBurdenedCost += budgetAssignment.FullyBurdenedCost__c; 
                }
            }

            if(budgetHeader.Status__c == 'Approved') {
                taskCostDetail.approvedRawCost += ECO_Utils_Math.ifNull(budgetAssignment.AppliedTtlRawCst__c);
                if(budgetAssignment.Quantity__c != null) {
                    taskCostDetail.approvedQuantity += budgetAssignment.Quantity__c;
                }
                if(budgetHeader.MultiLineBurdened__c) {
                    if(budgetAssignment.AppliedTtlRawCst__c != null) {
                      taskCostDetail.approvedBurdenedCost += budgetAssignment.AppliedTtlRawCst__c;  
                    }
                }
                else {
                    if(budgetAssignment.FullyBurdenedCost__c != null) {
                      taskCostDetail.approvedBurdenedCost += budgetAssignment.FullyBurdenedCost__c; 
                    }
                }
            }

            if(budgetHeader.MultiLineBurdened__c && budgetAssignment.BudgetResource__r.AppliedResourceAlias__c == 'People' ) {
                String fringeMapKey = budgetAssignment.BudgetTask__r.ProjectTask__c + 'Fringe' + budgetAssignment.BudgetResource__r.AppliedResourceListName__c;
                if(!costDetailMap.containsKey(fringeMapKey)) {
                    costDetailMap.put(fringeMapKey, new TaskCostDetail(budgetAssignment.BudgetTask__r.ProjectTask__c, 'Fringe', budgetAssignment.BudgetResource__r.AppliedResourceListName__c ));
                }
                TaskCostDetail fringeCostDetail = costDetailMap.get(fringeMapKey);

                if(budgetAssignment.TotalFringe__c != null) {
                  fringeCostDetail.forecastRawCost += budgetAssignment.TotalFringe__c;
                  fringeCostDetail.forecastBurdenedCost += budgetAssignment.TotalFringe__c;  
                }

                if(budgetHeader.Status__c == 'Approved') {
                    fringeCostDetail.approvedRawCost += budgetAssignment.TotalFringe__c;
                    fringeCostDetail.approvedBurdenedCost += budgetAssignment.TotalFringe__c;  
                }

                String overHeadMapKey = budgetAssignment.BudgetTask__r.ProjectTask__c + 'Overhead' + budgetAssignment.BudgetResource__r.AppliedResourceListName__c;
                if(!costDetailMap.containsKey(overHeadMapKey)) {
                    costDetailMap.put(overHeadMapKey, new TaskCostDetail(budgetAssignment.BudgetTask__r.ProjectTask__c, 'Overhead', budgetAssignment.BudgetResource__r.AppliedResourceListName__c ));
                }
                TaskCostDetail overheadCostDetail = costDetailMap.get(overHeadMapKey);

                if(budgetAssignment.TotalOverhead__c != null) {
                  overheadCostDetail.forecastRawCost += budgetAssignment.TotalOverhead__c;
                  overheadCostDetail.forecastBurdenedCost += budgetAssignment.TotalOverhead__c;
                }  

                if(budgetHeader.Status__c == 'Approved') {
                    overheadCostDetail.approvedRawCost += budgetAssignment.TotalOverhead__c;
                    overheadCostDetail.approvedBurdenedCost += budgetAssignment.TotalOverhead__c;  
                }
            }
        }

        return costDetailMap;
     }


     public static void calculateBudgetsNew(Id projectId, Id sFBudgetIntegrationMessageQueueId, Id changeManagerId, Boolean isForecastChange, String newBudgetHeaderIds) 
     {
        Map<String, TaskCostDetail> costDetailMap = new Map<String, TaskCostDetail>();
        Map<String, RevenueDetail> revenueDetailMap = new Map<String, RevenueDetail>();
        List<BudgetSetDetail__c> budgetSetDetail = new List<BudgetSetDetail__c>();
        Map<Id, Map<Id, Decimal>> topLevelTaskCost = new Map<Id, Map<Id,Decimal>>();

        List<pse__Proj__c> projects = [select Id, BudgetStrategyRevenue__c, BudgetStrategy__c, CurrencyIsoCode from pse__Proj__c where Id = :projectId];

        Map<Id, BudgetHeader__c> budgetHeaderMap = new Map<Id, BudgetHeader__c>([Select Id, Status__c, AppliedTotalRevenue__c, Project__r.BudgetStrategyRevenue__c, Project__r.OracleProjectNumber__c,
                                                                                    Project__r.BudgetStrategy__c, MultiLineBurdened__c, WorkAtRisk__c, TotalCost__c
                                                                                From BudgetHeader__c Where Project__c = :projectId
                                                                                  And (Status__c = 'Approved'
                                                                                    Or Status__c = 'Forecast' or Status__c = 'Work at Risk')]);

        BudgetSet__c budgetSet = initBudgetSetParent(budgetHeaderMap.keySet(), sFBudgetIntegrationMessageQueueId, changeManagerId, projectId);
        budgetSet.CurrencyIsoCode = projects[0].CurrencyIsoCode;
        budgetSet.NewBudgetHeaderIds__c = newBudgetHeaderIds.left(200);
        budgetSet.NewBudgetHeaderIds2__c = newBudgetHeaderIds;
        budgetSet.Project__c = projectId;
        insert budgetSet;

        TaskCostDetail taskCostDetail;
        BudgetHeader__c budgetHeader;
        Id topLevelTaskId;
        Decimal topLevelTaskTotal;
        for(BudgetAssignment__c budgetAssignment:[Select BudgetTask__c, Status__c, AppliedTtlRawCst__c, FullyBurdenedCost__c, TotalOverhead__c, TotalFringe__c, BudgetResource__r.AppliedResourceAlias__c                                        
                                                , BudgetResource__r.AppliedResourceListName__c, BudgetTask__r.BudgetHeader__c, BudgetTask__r.ProjectTask__c, 
                                                BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__c, AppliedRawCost__c, Quantity__c, BudgetTask__r.TotalCost__c
                                                From BudgetAssignment__c 
                                                Where BudgetTask__r.BudgetHeader__c In :budgetHeaderMap.keySet()
                                                Order By BudgetTask__r.BudgetHeader__r.CreatedDate]) {

            if(budgetAssignment.BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__c == null) {
                topLevelTaskId = budgetAssignment.BudgetTask__r.ProjectTask__c;
            }
            else {
                topLevelTaskId = budgetAssignment.BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__c;
            }
            if(!topLevelTaskCost.containsKey(topLevelTaskId)) {
                topLevelTaskCost.put(topLevelTaskId, new Map<Id, Decimal>());
            }
            if(!topLevelTaskCost.get(topLevelTaskId).containsKey(budgetAssignment.BudgetTask__r.BudgetHeader__c)) {
                topLevelTaskCost.get(topLevelTaskId).put(budgetAssignment.BudgetTask__r.BudgetHeader__c, 0);   
            }


            topLevelTaskTotal = topLevelTaskCost.get(topLevelTaskId).get(budgetAssignment.BudgetTask__r.BudgetHeader__c) + budgetAssignment.FullyBurdenedCost__c; 
            topLevelTaskCost.get(topLevelTaskId).put(budgetAssignment.BudgetTask__r.BudgetHeader__c, topLevelTaskTotal);


            //System.Debug('BrentBrentBrent ' + topLevelTaskId + '-' + budgetAssignment.BudgetTask__r.BudgetHeader__c + ' ' + budgetAssignment.BudgetTask__r.TotalCost__c  + ' ' + topLevelTaskTotal);

/*            if(!topLevelTaskCost.containsKey(budgetAssignment.BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__c)) {
                topLevelTaskCost.put(budgetAssignment.BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__c, 0);
            }
            topLevelTaskCost.put(budgetAssignment.BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__c, topLevelTaskCost.get(budgetAssignment.BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__c) + budgetAssignment.FullyBurdenedCost__c);
*/
            budgetHeader = budgetHeaderMap.get(budgetAssignment.BudgetTask__r.BudgetHeader__c);
            String mapKey = budgetAssignment.BudgetTask__r.ProjectTask__c + budgetAssignment.BudgetResource__r.AppliedResourceAlias__c + budgetAssignment.BudgetResource__r.AppliedResourceListName__c;
            if(!costDetailMap.containsKey(mapKey)) {
                costDetailMap.put(mapKey, new TaskCostDetail(budgetAssignment.BudgetTask__r.ProjectTask__c, budgetAssignment.BudgetResource__r.AppliedResourceAlias__c, budgetAssignment.BudgetResource__r.AppliedResourceListName__c ));
            }
            taskCostDetail = costDetailMap.get(mapKey);

            taskCostDetail.forecastRawCost += budgetAssignment.AppliedTtlRawCst__c;
            if(budgetAssignment.Quantity__c != null) {
                taskCostDetail.forecastQuantity += budgetAssignment.Quantity__c;
            }
            if(budgetHeader.MultiLineBurdened__c) {
                taskCostDetail.forecastBurdenedCost += budgetAssignment.AppliedTtlRawCst__c;
            }
            else {
                taskCostDetail.forecastBurdenedCost += budgetAssignment.FullyBurdenedCost__c; 
            }

            if(budgetHeader.Status__c == 'Approved') {
                taskCostDetail.approvedRawCost += budgetAssignment.AppliedTtlRawCst__c;
                if(budgetAssignment.Quantity__c != null) {
                    taskCostDetail.approvedQuantity += budgetAssignment.Quantity__c;
                }
                if(budgetHeader.MultiLineBurdened__c) {
                    taskCostDetail.approvedBurdenedCost += budgetAssignment.AppliedTtlRawCst__c;  
                }
                else {
                    taskCostDetail.approvedBurdenedCost += budgetAssignment.FullyBurdenedCost__c; 
                }
            }

            if(budgetHeader.MultiLineBurdened__c && budgetAssignment.BudgetResource__r.AppliedResourceAlias__c == 'People' ) {
                String fringeMapKey = budgetAssignment.BudgetTask__r.ProjectTask__c + 'Fringe' + budgetAssignment.BudgetResource__r.AppliedResourceListName__c;
                if(!costDetailMap.containsKey(fringeMapKey)) {
                    costDetailMap.put(fringeMapKey, new TaskCostDetail(budgetAssignment.BudgetTask__r.ProjectTask__c, 'Fringe', budgetAssignment.BudgetResource__r.AppliedResourceListName__c ));
                }
                TaskCostDetail fringeCostDetail = costDetailMap.get(fringeMapKey);

                fringeCostDetail.forecastRawCost += budgetAssignment.TotalFringe__c;
                fringeCostDetail.forecastBurdenedCost += budgetAssignment.TotalFringe__c;  

                if(budgetHeader.Status__c == 'Approved') {
                    fringeCostDetail.approvedRawCost += budgetAssignment.TotalFringe__c;
                    fringeCostDetail.approvedBurdenedCost += budgetAssignment.TotalFringe__c;  
                }

                String overHeadMapKey = budgetAssignment.BudgetTask__r.ProjectTask__c + 'Overhead' + budgetAssignment.BudgetResource__r.AppliedResourceListName__c;
                if(!costDetailMap.containsKey(overHeadMapKey)) {
                    costDetailMap.put(overHeadMapKey, new TaskCostDetail(budgetAssignment.BudgetTask__r.ProjectTask__c, 'Overhead', budgetAssignment.BudgetResource__r.AppliedResourceListName__c ));
                }
                TaskCostDetail overheadCostDetail = costDetailMap.get(overHeadMapKey);

                overheadCostDetail.forecastRawCost += budgetAssignment.TotalOverhead__c;
                overheadCostDetail.forecastBurdenedCost += budgetAssignment.TotalOverhead__c;  

                if(budgetHeader.Status__c == 'Approved') {
                    overheadCostDetail.approvedRawCost += budgetAssignment.TotalOverhead__c;
                    overheadCostDetail.approvedBurdenedCost += budgetAssignment.TotalOverhead__c;  
                }
            }
        }

        for(TaskCostDetail costDetail:costDetailMap.values()){

            if(costDetail.forecastBurdenedCost != 0 || costDetail.forecastQuantity != 0 || costDetail.approvedBurdenedCost != 0 || costDetail.approvedQuantity != 0) {
                BudgetSetDetail__c forecastBudgetSetDetail = new BudgetSetDetail__c();
                forecastBudgetSetDetail.BudgetSet__c = budgetSet.Id;
                forecastBudgetSetDetail.ProjectTask__c = costDetail.taskId;
                forecastBudgetSetDetail.BudgetTypeCode__c = 'FC';
                forecastBudgetSetDetail.ActionCode__c = 'P';
                forecastBudgetSetDetail.BurdenedCost__c = costDetail.forecastBurdenedCost;
                forecastBudgetSetDetail.RawCost__c = costDetail.forecastRawCost;
                forecastBudgetSetDetail.Quantity__c = costDetail.forecastQuantity;
                forecastBudgetSetDetail.ResourceListAlias__c = costDetail.resourceListAlias;
                forecastBudgetSetDetail.ResourceListName__c = costDetail.resourceListName;
                forecastBudgetSetDetail.CurrencyIsoCode = projects[0].CurrencyIsoCode;
                budgetSetDetail.add(forecastBudgetSetDetail);    

                if(!isForecastChange){
                    BudgetSetDetail__c approvedBudgetSetDetail = new BudgetSetDetail__c();
                    approvedBudgetSetDetail.BudgetSet__c = budgetSet.Id;
                    approvedBudgetSetDetail.ProjectTask__c = costDetail.taskId;
                    approvedBudgetSetDetail.BudgetTypeCode__c = 'AC';
                    approvedBudgetSetDetail.ActionCode__c = 'P';
                    approvedBudgetSetDetail.BurdenedCost__c = costDetail.approvedBurdenedCost;
                    approvedBudgetSetDetail.RawCost__c = costDetail.approvedRawCost;
                    approvedBudgetSetDetail.Quantity__c = costDetail.approvedQuantity;
                    approvedBudgetSetDetail.ResourceListAlias__c = costDetail.resourceListAlias;
                    approvedBudgetSetDetail.ResourceListName__c = costDetail.resourceListName;
                    approvedBudgetSetDetail.CurrencyIsoCode = projects[0].CurrencyIsoCode;
                    budgetSetDetail.add(approvedBudgetSetDetail);
                }   
            }
        }

        if(projects[0].BudgetStrategyRevenue__c == 'Top Task') {
            RevenueDetail revenueDetail;
            for(BudgetTask__c budgetTask:[select Id, AppliedTotalRevenue__c, OverrideTotalRevenue__c, TotalCost__c, ProjectTask__c, BudgetHeader__c, ProjectTask__r.pse__Top_level_Parent_Task__c,
                                            BudgetHeader__r.Project__r.BudgetStrategy__c
                                            from BudgetTask__c where BudgetHeader__c in :budgetHeaderMap.keyset() and IsTopLevelTask__c = true]) {
                
                Decimal overrideTotalRevenue;
                Decimal totalCost = 0;

                if(budgetTask.OverrideTotalRevenue__c != null) {
                  overrideTotalRevenue = budgetTask.OverrideTotalRevenue__c;
                }
                else {
                  overrideTotalRevenue = 0;
                }

                //System.Debug('BrentBrentBrent ' + budgetTask.ProjectTask__c + ' ' + budgetTask.BudgetHeader__c);

                if(budgetTask.ProjectTask__r.pse__Top_level_Parent_Task__c != null){
                    topLevelTaskId = budgetTask.ProjectTask__r.pse__Top_level_Parent_Task__c;
                }
                else {
                    topLevelTaskId = budgetTask.ProjectTask__c;  
                }

                //if(budgetTask.BudgetHeader__r.Project__r.BudgetStrategy__c == 'Bottom Task') {
                if(topLevelTaskCost.containsKey(topLevelTaskId)){
                    if(topLevelTaskCost.get(topLevelTaskId).containsKey(budgetTask.BudgetHeader__c)) {
                        if(topLevelTaskCost.get(topLevelTaskId).get(budgetTask.BudgetHeader__c) != null) {
                            totalCost = topLevelTaskCost.get(topLevelTaskId).get(budgetTask.BudgetHeader__c);
                        }
                    }
                }
                //    }
                //}
                //else{
                //    if(topLevelTaskCost.containsKey(topLevelTaskId)){
                //        totalCost = topLevelTaskCost.get(topLevelTaskId).get(budgetTask.BudgetHeader__c);
                //    }
                //}

                if(!revenueDetailMap.containsKey(budgetTask.ProjectTask__c)) {
                    revenueDetailMap.put(budgetTask.ProjectTask__c, new RevenueDetail(budgetTask.ProjectTask__c)); 
                }
                revenueDetail = revenueDetailMap.get(budgetTask.ProjectTask__c);
                if(!budgetHeaderMap.get(budgetTask.BudgetHeader__c).WorkAtRisk__c && !(budgetHeaderMap.get(budgetTask.BudgetHeader__c).Status__c == 'Work at Risk')){
                  revenueDetail.forecastRevenue += overrideTotalRevenue;
                }
                else{
                    if(totalCost < overrideTotalRevenue) {
                        revenueDetail.forecastRevenue += totalCost;
                    }
                    else {
                        revenueDetail.forecastRevenue += overrideTotalRevenue;   
                    }
                }

                if(budgetHeaderMap.get(budgetTask.BudgetHeader__c).Status__c == 'Approved') {
                  revenueDetail.approvedrevenue += overrideTotalRevenue;  
                } 
            }

            for(RevenueDetail revDetail:revenueDetailMap.values()) {
                budgetSetDetail.add(new BudgetSetDetail__c(BudgetSet__c = budgetSet.Id, ProjectTask__c = revDetail.taskId, BudgetTypeCode__c = 'FR', Revenue__c = revDetail.forecastRevenue, ActionCode__c = 'P', CurrencyIsoCode = projects[0].CurrencyIsoCode));
                if(!isForecastChange) {
                    budgetSetDetail.add(new BudgetSetDetail__c(BudgetSet__c = budgetSet.Id, ProjectTask__c = revDetail.taskId, BudgetTypeCode__c = 'AR', Revenue__c = revDetail.approvedrevenue, ActionCode__c = 'P', CurrencyIsoCode = projects[0].CurrencyIsoCode));
                }
            }
        }
        else {
            RevenueDetail revenueDetail = new RevenueDetail();
            for(BudgetHeader__c revenueBudgetHeader:budgetHeaderMap.values()) {
                //revenueDetail.forecastRevenue += revenueBudgetHeader.AppliedTotalRevenue__c;
                if(!revenueBudgetHeader.WorkAtRisk__c && !(revenueBudgetHeader.Status__c == 'Work at Risk')){

                    revenueDetail.forecastRevenue += revenueBudgetHeader.AppliedTotalRevenue__c;
                }
                else{
                    if(revenueBudgetHeader.TotalCost__c < revenueBudgetHeader.AppliedTotalRevenue__c) {
                        revenueDetail.forecastRevenue += revenueBudgetHeader.TotalCost__c;
                    }
                    else {
                        revenueDetail.forecastRevenue += revenueBudgetHeader.AppliedTotalRevenue__c;    
                    }
                }                

                if(revenueBudgetHeader.Status__c == 'Approved'){
                    revenueDetail.approvedrevenue += revenueBudgetHeader.AppliedTotalRevenue__c;
                }
            }

            budgetSetDetail.add(new BudgetSetDetail__c(BudgetSet__c = budgetSet.Id, BudgetTypeCode__c = 'FR', Revenue__c = revenueDetail.forecastRevenue, ActionCode__c = 'P', CurrencyIsoCode = projects[0].CurrencyIsoCode));
            if(!isForecastChange){
                budgetSetDetail.add(new BudgetSetDetail__c(BudgetSet__c = budgetSet.Id, BudgetTypeCode__c = 'AR', Revenue__c = revenueDetail.approvedRevenue, ActionCode__c = 'P', CurrencyIsoCode = projects[0].CurrencyIsoCode));    
            }
        }

        if(!budgetSetDetail.isEmpty()){
            insert budgetSetDetail;
        }

    }

    /** 
     *
     * @Author  NTT Data - Scott Mantei
     * @Date    Nov 2016
     *
     * @param    
     * @return   
     **/
    private static BudgetSet__c initBudgetSetParent(Set<Id> budgetHeaderIds, String sFBudgetIntegrationMessageQueueId, Id changeManagerId, Id projectId) {
        // BudgetHeaderList__c field is a comma separated list of Budget Header Ids
        BudgetSet__c bs = new BudgetSet__c(IntegrationMessageQueue__c = sFBudgetIntegrationMessageQueueId);
        bs.budgetHeaderIds2__c = '';
        for (Id bhId : budgetHeaderIds) {
            bs.budgetHeaderIds2__c += bhId + ',';
        }
        bs.budgetHeaderIds2__c = bs.budgetHeaderIds2__c.removeEnd(','); 
        bs.Change__c = changeManagerId;
        bs.Project__c = projectId;   
        return bs;                
    }
}