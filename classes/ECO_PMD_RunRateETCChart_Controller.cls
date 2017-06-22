global class ECO_PMD_RunRateETCChart_Controller {

    public ECO_PMD_RunRateETCChart_Controller(){}
 
   
    @RemoteAction
    global static RunRateDetails ProjectSnapshot(String projectNum)
    {
       
        Id projectId = projectNum;
 
        RunRateDetails runRateDetails = new RunRateDetails();

        List<ProjectSnapshot__c> runRateData = [SELECT
                                            RunRateAverageCost__c, 
                                            CostITDApproved__c,
                                            CostETC__c, 
                                            CostITD__c, 
                                            CostForecast__c, 
                                            CostBudget__c,
                                            SnapshotFiscalMonth__c, 
                                            SnapshotDate__c,
                                            SnapshotType__c,
                                            ProjectEndDate__c,
                                            CurrencyIsoCode
                                        FROM
                                            ProjectSnapshot__c
                                        WHERE
                                            Project__c = :projectId AND SnapshotType__c='Auto'
                                        order by SnapshotFiscalMonth__c asc];

        Integer listsize = runRateData.size();

        if (listsize > 0)
        {
            runRateDetails.runRateData = runRateData;
            runRateDetails.AvgCost = ECO_PMD_Helpers.validDecimal(runRateData[listsize-1].RunRateAverageCost__c);
            runRateDetails.CostETC = ECO_PMD_Helpers.validDecimal(runRateData[listsize-1].CostETC__c);
            runRateDetails.CostEAC = ECO_PMD_Helpers.validDecimal(runRateData[listsize-1].CostForecast__c); 
            runRateDetails.CostBudget = ECO_PMD_Helpers.validDecimal(runRateData[listsize-1].CostBudget__c);
            runRateDetails.Var = ECO_PMD_Helpers.validDecimal(runRateData[listsize-1].CostForecast__c) - ECO_PMD_Helpers.validDecimal(runRateData[listsize-1].CostITD__c);
            runRateDetails.ProjectEndDate = runRateData[listsize-1].ProjectEndDate__c;
            runRateDetails.currencyCode = runRateData[listsize-1].CurrencyIsoCode; 
        }                                
        return runRateDetails;
    }

    global class RunRateDetails
    {
        public RunRateDetails()
        {
            error='';
            AvgCost = 0;
            CostETC = 0;
            CostEAC = 0;
            Var=0;
            runRateData = null;
        }

        public String error;
        public Boolean nodata;
        public Decimal AvgCost;
        public Decimal CostETC;
        public Decimal CostEAC;
        public Decimal CostBudget;
        public Decimal Var;
        public Decimal other;
        public String currencyCode;
        public Date ProjectEndDate;
        public List<ProjectSnapshot__c> runRateData;
    }
}