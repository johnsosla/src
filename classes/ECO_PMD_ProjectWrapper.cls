public with sharing class ECO_PMD_ProjectWrapper {
    
	public pse__Proj__c project { get; set; }
    public Id projectId { get; set; }
    public string chartJSONEV {get;set;}
    public string chartJSONCPISPI {get;set;}
    
    public ECO_PMD_ProjectWrapper() {}
    public ECO_PMD_ProjectWrapper(pse__Proj__c theProject) {
        project = theProject;
        
        projectId = project.Id; //oStandardController.getId();
        // project = [select Name, pse__Start_Date__c, pse__End_Date__c from pse__Proj__c where Id = :projectId];
        chartJSONEV = createEarnedValueGoogleChartJSON();
        chartJSONCPISPI = createCpiAndSpiGoogleChartJSON();
    }
 
  public class ECO_EarnedvalueReportControllerException extends Exception {
  }

  public String getChartJSONEV() {
    return chartJSONEV;
  }

  public String getChartJSONCPISPI() {
      return chartJSONCPISPI;
  }

  private String createEarnedValueGoogleChartJSON(){  
  
    list<WeeklyRollupEntry__c> lWeeklyRollupEntries = new list<WeeklyRollupEntry__c>([SELECT id
                                                                                             , PeriodStartDate__c
                                                                                             , AppliedApprovedCost__c
                                                                                             , ProjectFunctionalBurdenedCost__c
                                                                                             , EarnedValue__c
                                                                                   FROM WeeklyRollupEntry__c 
                                                                                   WHERE Project__c = :projectId]);

    List<EarnedValueHeader__c> listOfEVRs = [SELECT Id 
                                                  , SnapshotDate__c
                                                  , (SELECT id
                                                              , TrendEAC1__c
                                                          , TrendEAC2__c
                                                     FROM Earned_Value_Tasks__r
                                                    )
                                             FROM EarnedValueHeader__c
                                             WHERE Project__c = :projectId
                                             AND SnapshotDate__c != null
                                             ORDER BY SnapshotDate__c DESC];
    Decimal dTrendEAC1 = 0;
    Decimal dTrendEAC2 = 0;

    if (!listOfEVRs.isEmpty()) {
            EarnedValueHeader__c existingReport = listOfEVRs.get(0);

            for(EarnedValueTask__c oEarnedValueTask : existingReport.Earned_Value_Tasks__r){
                    dTrendEAC1 += ECO_Utils_String.NullCheck(oEarnedValueTask.TrendEAC1__c);
                    dTrendEAC2 += ECO_Utils_String.NullCheck(oEarnedValueTask.TrendEAC2__c);
            }
    }

    String sTrendEAC1 = String.valueOf(dTrendEAC1);
    String sTrendEAC2 = String.valueOf(dTrendEAC2);

    list<list<String>> lResults = new list<list<String>>();

    for(WeeklyRollupEntry__c oWeeklyRollupEntry : lWeeklyRollupEntries){
            list<String> lResultLine = new list<String>();

            lResultLine.add(String.valueOf(oWeeklyRollupEntry.PeriodStartDate__c));
            lResultLine.add(String.valueOf(ECO_Utils_String.NullCheck(oWeeklyRollupEntry.AppliedApprovedCost__c)));
            lResultLine.add(String.valueOf(ECO_Utils_String.NullCheck(oWeeklyRollupEntry.ProjectFunctionalBurdenedCost__c)));
            lResultLine.add(String.valueOf(ECO_Utils_String.NullCheck(oWeeklyRollupEntry.EarnedValue__c)));
            lResultLine.add(sTrendEAC1);
            lResultLine.add(sTrendEAC2);

            lResults.add(lResultLine);
    }

    return JSON.serialize(lResults);
 
  }

  private String createCpiAndSpiGoogleChartJSON(){    
    
      list<WeeklyRollupEntry__c> lWeeklyRollupEntries = new list<WeeklyRollupEntry__c>([SELECT id
                                                                                                   , PeriodStartDate__c
                                                                                                   , SPI__c
                                                                                                   , CPI__c
                                                                                         FROM WeeklyRollupEntry__c 
                                                                                         WHERE Project__c = :projectId]);

      list<list<String>> lResults = new list<list<String>>();

      for(WeeklyRollupEntry__c oWeeklyRollupEntry : lWeeklyRollupEntries){
              list<String> lResultLine = new list<String>();

              lResultLine.add(String.valueOf(oWeeklyRollupEntry.PeriodStartDate__c));
              lResultLine.add(String.valueOf(ECO_Utils_String.NullCheck(oWeeklyRollupEntry.CPI__c)));
              lResultLine.add(String.valueOf(ECO_Utils_String.NullCheck(oWeeklyRollupEntry.SPI__c)));

              lResults.add(lResultLine);
      }

      return JSON.serialize(lResults);
 
  }
  

}