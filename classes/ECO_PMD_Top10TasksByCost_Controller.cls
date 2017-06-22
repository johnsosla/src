global with sharing class ECO_PMD_Top10TasksByCost_Controller {

      private final pse__Proj__c oProject ;

      public string locale { get {return UserInfo.getLocale().replace('_', '-');} }
      
      public ECO_PMD_ProjectWrapper wrapper { get; set; }
      
      public ECO_PMD_Top10TasksByCost_Controller (ApexPages.StandardController oStandardController) {
            this.oProject = (pse__Proj__c)oStandardController.getRecord();
        this.wrapper = new ECO_PMD_ProjectWrapper(this.oProject);
      }

        @RemoteAction
    global static TaskCostDetails getTop10TasksByCost(String projectNum )
    {
        Id projectId = projectNum;

        TaskCostDetails taskCostDetails = new TaskCostDetails();
        
      
        
        List<pse__Project_Task__c> tasks = [SELECT TotalActualCost__c
                        , TotalApprovedCost__c
                        , Name, ProjectTaskNumber__c, CurrencyIsoCode 
                        FROM pse__Project_Task__c
                                WHERE pse__Project__c = :projectId and IsChargeable__c = true
                                    and IsTopLevelTask__c=false and IsWorkPlanTask__c = false
                                ORDER BY TotalActualCost__c DESC, TotalApprovedCost__c DESC];

                List<TaskCost> taskCosts = new List<TaskCost>();
        Integer i = 0;


        //Integer listsize = tasks.size();

        //if (listsize > 0)
        //{
        //    taskCostDetails.currencyCode = tasks[listsize-1].CurrencyIsoCode;
        //    System.debug('currencyCode::::' + taskCostDetails.currencyCode);
        //}

        for (pse__Project_Task__c task : tasks)
        {
                Decimal totalActualCost = NullToZero(task.TotalActualCost__c);
                Decimal totalApprovedCost = NullToZero(task.TotalApprovedCost__c);

             if (i < 10)
             {
                 // Variance field is currently unknown
                 taskCosts.add(
                    new TaskCost(
                        task.ProjectTaskNumber__c
                        , task.Name
                        , totalActualCost
                        , totalApprovedCost
                        , totalApprovedCost - totalActualCost
                        , (i + 1)  
                        , task.CurrencyIsoCode
                    ));
             }
             else
             {
                taskCostDetails.actualOther += totalActualCost;
                taskCostDetails.planOther += totalApprovedCost;
                taskCostDetails.varianceOther += (totalApprovedCost - totalActualCost ); // need field                 
             } 
             taskCostDetails.actualTotal += totalActualCost;
             taskCostDetails.planTotal += totalApprovedCost;
             taskCostDetails.varianceTotal += (totalApprovedCost - totalActualCost );// need field 
             
             i++;
        }

        taskCostDetails.taskCosts = taskCosts;
        return taskCostDetails;
       
    }

    global static Decimal NullToZero(Decimal val)  
    {

        if (val == null )
        {
                return 0;
        }
        else 
        {
                return val;
        }
    }

        global class TaskCost
    {
        public TaskCost(string ltaskNo , string ltaskName, Decimal lactual, Decimal lplan,  Decimal lvariance, Integer lorder, String lcurrencyCode )
        {
            taskNo = ltaskNo;
            taskName = ltaskName;
            actual = lactual;
            plan = lplan;
            variance = lvariance;
            order = lorder;
            currencyCode = lcurrencyCode;
        }

        public Integer order;
        public String taskNo;
        public String taskName;
        public Decimal actual;
        public Decimal plan;
        public Decimal variance;
        public String currencyCode;
    }



    global class TaskCostDetails
    {
        public TaskCostDetails()
        {
            error = '';
            nodata = false;

            actualTotal = 0;
            actualOther = 0;

            planTotal = 0;
            planOther = 0;

            varianceTotal = 0;
            varianceOther = 0;

            taskCosts = null;

            currencyCode = '';
        }

        public String error;
        public Boolean nodata;
        
        Decimal actualTotal;
        Decimal actualOther;

        Decimal planTotal;
        Decimal planOther;

        Decimal varianceTotal;
        Decimal varianceOther;

        String currencyCode;
        public List<TaskCost> taskCosts;

    }

}