global with sharing class ECO_PMD_PL_Controller {

    public ECO_PMD_PL_Controller(){}

    
    @RemoteAction
    global static ProjectSnapshot_MashUp ProjectSnapshot(String projectNum)
    {
        Id projectId = projectNum;

        ProjectSnapshot_MashUp snapshot_mashup = new ProjectSnapshot_MashUp();
        
        try
        {
            // GET THE LATEST TWO SNAPSHOTS FOR THE PROJECT
            List<ProjectSnapshot__c>  snapshots = [SELECT id, SnapshotDate__c 
                    , GrossRevenueMonthToDate__c, GrossRevenueYearToDate__c, GrossRevenueITD__c, GrossRevenueETC__c, GrossRevenueForecast__c, GrossRevenueBudgetOriginal__c, GrossRevenueBudget__c, GrossRevenueForecastPrevME__c, GrossRevenueForecastDelta__c, GrossRevenueDraft__c
                    , CostsODCEXPSMonthtoDate__c, CostsODCEXPSYearToDate__c, CostsODCEXPSITD__c, CostsODCEXPSETC__c, CostsODCEXPSForecast__c , CostsODCEXPSBudgetOriginal__c, CostsODCEXPSBudget__c, CostsODCEXPSForecastPrevME__c, CostsODCEXPSForecastDelta__c, CostsODCEXPSDraft__c
                    , CostsODCSUBSMonthtoDate__c, CostsODCSUBSYearToDate__c, CostsODCSUBSITD__c, CostsODCSUBSETC__c, CostsODCSUBSForecast__c , CostsODCSUBSBudgetOriginal__c, CostsODCSUBSBudget__c, CostsODCSUBSForecastPrevME__c, CostsODCSUBSForecastDelta__c, CostsODCSUBSDraft__c
                    , ContingencyForecast__c, ContingencyBudgetOriginal__c, ContingencyBudget__c, ContingencyForecastPrevME__c, ContingencyForecastDelta__c, ContingencyDraft__c
                    , NetServiceMonthtoDate__c, NetServiceYearToDate__c, NetServiceITD__c, NetServiceETC__c, NetServiceForecast__c , NetServiceBudgetOriginal__c, NetServiceBudget__c, NetServiceForecastPrevME__c, NetServiceForecastDelta__c, NetServiceDraft__c
                    , LaborMonthToDate__c, LaborYearToDate__c, LaborITD__c, LaborETC__c, LaborForecast__c, LaborBudgetOriginal__c, LaborBudget__c, LaborForecastPrevME__c, LaborForecastDelta__c, LaborDraft__c
                    , FringeMonthToDate__c, FringeYearToDate__c, FringeITD__c, FringeETC__c, FringeForecast__c, FringeBudgetOriginal__c, FringeBudget__c, FringeForecastPrevME__c, FringeForecastDelta__c, FringeDraft__c
                    , GrossMarginMonthToDate__c, GrossMarginYearToDate__c, GrossMarginITD__c, GrossMarginETC__c, GrossMarginForecast__c, GrossMarginBudgetOriginal__c, GrossMarginBudget__c, GrossMarginForecastPrevME__c, GrossMarginForecastDelta__c, GrossMarginDraft__c
                    , OverheadMonthToDate__c, OverheadYearToDate__c, OverheadITD__c, OverheadETC__c, OverheadForecast__c, OverheadBudgetOriginal__c, OverheadBudget__c, OverheadForecastPrevME__c, OverheadForecastDelta__c, OverheadDraft__c
                    , NetMarginMonthToDate__c, NetMarginYearToDate__c, NetMarginITD__c, NetMarginETC__c, NetMarginForecast__c, NetMarginBudgetOriginal__c, NetMarginBudget__c, NetMarginForecastPrevME__c, NetMarginForecastDelta__c, NetMarginDraft__c
                    , GMNSRMonthToDate__c, GMNSRYearToDate__c, GMNSRITD__c, GMNSRETC__c, GMNSRForecast__c, GMNSRBudgetOriginal__c, GMNSRBudget__c, GMNSRForecastPrevME__c, GMNSRForecastDelta__c, GMNSRDraft__c
                    , NMGRMonthToDate__c, NMGRYearToDate__c, NMGRITD__c, NMGRETC__c, NMGRForecast__c, NMGRBudgetOriginal__c, NMGRBudget__c, NMGRForecastPrevME__c, NMGRForecastDelta__c, NMGRDraft__c
                    , NMNSRMonthToDate__c, NMNSRYearToDate__c, NMNSRITD__c, NMNSRETC__c, NMNSRForecast__c, NMNSRBudgetOriginal__c, NMNSRBudget__c, NMNSRForecastPrevME__c, NMNSRForecastDelta__c, NMNSRDraft__c
                    , HoursMonthToDate__c, HoursYearToDate__c, HoursITD__c, HoursETC__c, HoursForecast__c, HoursBudgetOriginal__c, HoursBudget__c, HoursForecastPrevME__c, HoursForecastDelta__c, HoursDraft__c
                    , AvgLaborHourMonthToDate__c, AvgLaborHourYearToDate__c, AvgLaborHourITD__c, AvgLaborHourETC__c, AvgLaborHourForecast__c, AvgLaborHourBudgetOriginal__c, AvgLaborHourBudget__c, AvgLaborHourForecastPrevME__c, AvgLaborHourForecastDelta__c, AvgLaborHourDraft__c
                    , SCMMonthToDate__c, SCMYearToDate__c, SCMITD__c, SCMETC__c, SCMForecast__c, SCMBudgetOriginal__c, SCMBudget__c, SCMForecastPrevME__c, SCMForecastDelta__c, SCMDraft__c
                    , LostMarginMonthToDate__c, LostMarginYearToDate__c, LostMarginITD__c, LostMarginETC__c, LostMarginForecast__c, LostMarginDraft__c
                    , OriginalBudgetAsOfDate__c, CurrentBudgetAsOfDate__c, ProjectEndDatePrevME__c, ProjectEndDate__c, CurrencyIsoCode 
                    , CostMonthToDate__c, CostYearToDate__c, CostITD__c, CostETC__c, CostForecast__c, CostOrigBudget__c, CostBudget__c, CostDraft__c
                    , CostForecastPrevME__c, CostForecastDelta__c, CostMonthToDateApproved__c, CostYearToDateApproved__c, CostITDApproved__c
                    , LaborMultiplierMonthToDate__c, LaborMultiplierYearToDate__c, LaborMultiplierITD__c, LaborMultiplierETC__c, LaborMultiplierForecast__c, LaborMultiplierBudgetOriginal__c, LaborMultiplierBudget__c, LaborMultiplierForecastPrevME__c, LaborMultiplierForecastDelta__c, LaborMultiplierUnapproved__c, LaborMultiplierDraft__c  

                FROM ProjectSnapshot__c
                WHERE Project__c = :projectId 
                AND SnapshotDate__c != null AND SnapshotType__c='Auto'
                ORDER BY SnapshotDate__c DESC
                LIMIT 1];

            // There is only one month of snapshots
            if (snapshots.size()==1)
            {
                snapshot_mashup.current =  snapshots[0];
            } else {
                snapshot_mashup.nodata = true;
            }

            //snapshot_mashup.first = firstsnapshots;
        }
        catch (Exception ex){

            snapshot_mashup.error = ex.getMessage() + ' ' + ex.getLineNumber();
            snapshot_mashup.nodata = true;
        }

        return snapshot_mashup;
    }



    global class ProjectSnapshot_MashUp
    {
        public ProjectSnapshot_MashUp()
        {
            current = null;
            //first = null;
            //previous = null;
            nodata = false;
        }

        public String error;
        public Boolean nodata;
        public ProjectSnapshot__c current;
        //public ProjectSnapshot__c first;
        //public ProjectSnapshot__c previous;

    }
}