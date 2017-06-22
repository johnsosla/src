/** ---------------------------------------------------------------------------------------
* @Description Evaluate the Health of a Project in terms of its Key Performance Indicators (KPIs)
*
* @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
* @Date October 2016
*----------------------------------------------------------------------------------------*/
public class ECO_HealthCheckEvaluator 
{
    public List<Response> kpiResponses {get; set;}
    ECO_KPICalculation kpiCalc {get; set;}
    
    /** ---------------------------------------------------------------------------------------
    * @Description Evaluate a Project's Health, as called from User Interface (UI); 
    *    it should result in a new ProjectSnapshot creation, with KPI responses
    *    NOTE: IF(item.Evaluation_Result__c, $Resource.RedCircle, $Resource.greenStar)
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param projectIds - the project Ids to get the project HealthCheck Calculations for
    * @return Map<Id, List<Response>> - a Map of a List of Response objects with HealthCheck evaluation attributes
    *----------------------------------------------------------------------------------------*/
    public Map<Id, List<Response>> EvaluateProjects(List<Id> projectIds)
    {
        System.debug(logginglevel.FINE,'<<< BEGIN EvaluateProjects(projectIds) >>>');
        Map<Id, List<Response>> projectToResponsesMap = new Map<Id, List<Response>>();
        Map<Id, ProjectSnapshot__c> projectToSnapshotMap = new Map<Id, ProjectSnapshot__c>();
        try {
            kpiCalc = new ECO_KPICalculation();
            projectToSnapshotMap = kpiCalc.getProjectSnapshotsForHealthCalculations(projectIds);
            projectToResponsesMap = EvaluateProjectsHealth(projectIds, kpiCalc.projectToSnapshotMap);
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        System.debug(logginglevel.FINE,'>>> END EvaluateProjects(projectIds) <<<');
        return projectToResponsesMap;
    }

    /** ---------------------------------------------------------------------------------------
    * @Description Evaluate a Project's Health, as called from the Service_ProjectSnapshots class
    *   which will save the data in Snapshot KPI objects
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *
    * @param projectIds - the project Ids to get the project HealthCheck Calculations for
    * @param Map<Id, ProjectSnapshot__c> - the Map of Project Id to Project Snapshot data being evaluated
    * @return Map<Id, List<Response>> - a Map of a List of Response objects with HealthCheck evaluation attributes
    *----------------------------------------------------------------------------------------*/
    public Map<Id, List<Response>> EvaluateProjectsHealth(List<Id> projectIds, 
        Map<Id, ProjectSnapshot__c> projectToSnapshotMap)
    {
        Map<Id, List<Response>> projectToResponsesMap = new Map<Id, List<Response>>();
        System.debug(logginglevel.FINE,'<<< BEGIN EvaluateProjectsHealth(snapshots) >>>');

        //Pull Custom Setting
        try {
            Date asOfDate = Date.today();
            
            if (kpiCalc == null) {
                kpiCalc = new ECO_KPICalculation();
            }

            kpiCalc.agedARMap = kpiCalc.calcAgedAR(projectIds, Date.today());
            //System.debug('___agedARMap size='+kpiCalc.agedARMap.size());

            kpiCalc.daysSinceLastEACUpdateMap = 
                kpiCalc.calcDaysSinceLastEACUpdate(projectIds, Date.today());
            //System.debug('___kpiCalc.daysSinceLastEACUpdateMap size='+kpiCalc.daysSinceLastEACUpdateMap.size());

            for (Id projectId : projectIds) {
                kpiResponses = new List<Response>();
                pse__Proj__c project = ECO_Service_Projects.getProjectById(projectId);
                kpiCalc.snapshot = projectToSnapshotMap.get(projectId);
                //System.debug('___EvaluateProjectHealth kpiCalc.snapshot='+kpiCalc.snapshot);

                Response resp;
                ECO_KPIs__c kpi;
                String thresholdA = '';
                String thresholdB = '';

                try {
                    //Calculate Aged AR
                    Decimal agedAR = 0;
                    if (kpiCalc.agedARMap.size() > 0) {
                        Decimal initAgedAR = kpiCalc.agedARMap.get(projectId);
                        if (initAgedAR != null) {
                            agedAR = kpiCalc.agedARMap.get(projectId).setScale(1);
                        }
                    }
                    //System.debug('___projectId='+projectId+', agedAR='+agedAR);
                    //Pull Threshold (Default)
                    kpi = ECO_KPIs__c.getInstance('Aged AR');
                    thresholdA = kpi.ThresholdA__c;
                    //Create Response
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    resp.evalResult = (agedAR > Decimal.valueOf(thresholdA));
                    resp.valueString = String.valueOf(agedAR);
                    resp.message = agedAR + ' days';
                    System.debug('___ resp='+resp);
                    //Add Response to kpiResponses
                    kpiResponses.add(resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }

                /*NOTE: HIDDEN for now from the ProjectPerformanceReviews page:
                try {
                    // Average Labor Rate:
                    Decimal avgLaborRate = kpiCalc.calcAverageLaborRate().setScale(1);
                    System.debug('___avgLaborRate Variance='+avgLaborRate);
                    kpi = ECO_KPIs__c.getInstance('Average Labor Rate Variance to Budget');
                    thresholdA = kpi.ThresholdA__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    
                    resp.evalResult = (avgLaborRate > Decimal.valueOf(thresholdA));
                    resp.valueString = String.valueOf(avgLaborRate);
                    resp.message = avgLaborRate + ' %';
                    kpiResponses.add(resp);
                    System.debug('___ resp 2='+resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }*/
                
                try {
                    // Earned Value (CPI):
                    Decimal cpi = 0;
                    if (kpiCalc.calcCPI() > 0) {
                        cpi = kpiCalc.calcCPI().setScale(2);
                    }
                    //System.debug('___cpi='+cpi);
                    kpi = ECO_KPIs__c.getInstance('Earned Value (CPI)');
                    //System.debug('___kpi='+kpi);
                    thresholdA = kpi.ThresholdA__c;
                    thresholdB = kpi.ThresholdB__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = 
                        kpi.ThresholdText__c.replace('[Threshold A]', thresholdA).replace('[Threshold B]', thresholdB);
                    resp.evalResult = !(cpi > Decimal.valueOf(thresholdA) && cpi < Decimal.valueOf(thresholdB));
                    resp.valueString = String.valueOf(cpi);
                    resp.message = cpi + ' CPI';
                    kpiResponses.add(resp);
                    //System.debug('___ resp3='+resp);
                }
                catch(Exception e){
                    System.debug('Exception='+e.getStackTraceString());
                    ECO_Service_ErrorLog.logException(e);
                }
                
                try {
                    // Earned Value (SPI):
                    Decimal spi = 0;
                    if (kpiCalc.calcSPI() > 0) {
                        spi = kpiCalc.calcSPI().setScale(2);
                    }
                    //System.debug('___spi='+spi);
                    kpi = ECO_KPIs__c.getInstance('Earned Value (SPI)');
                    //System.debug('___kpi='+kpi);
                    thresholdA = kpi.ThresholdA__c;
                    thresholdB = kpi.ThresholdB__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = 
                        kpi.ThresholdText__c.replace('[Threshold A]', thresholdA).replace('[Threshold B]', thresholdB);
                    resp.evalResult = !(spi > Decimal.valueOf(thresholdA) && spi < Decimal.valueOf(thresholdB));
                    resp.valueString = String.valueOf(spi);
                    resp.message = spi + ' SPI';
                    kpiResponses.add(resp);
                    //System.debug('___ resp4='+resp);
                }
                catch(Exception e){
                    System.debug('Exception='+e.getStackTraceString());
                    ECO_Service_ErrorLog.logException(e);
                }
                
                try {           
                    // EAC - Last Update
                    Decimal eacLastUpdateDays = 0;
                    if (kpiCalc.daysSinceLastEACUpdateMap.size() > 0) {
                        eacLastUpdateDays = kpiCalc.daysSinceLastEACUpdateMap.get(projectId).setScale(1);
                    }
                    //System.debug('___eacLastUpdateDays='+eacLastUpdateDays);
                    kpi = ECO_KPIs__c.getInstance('EAC – Last Update');
                    thresholdA = kpi.ThresholdA__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    resp.evalResult = (eacLastUpdateDays > Decimal.valueOf(thresholdA));
                    resp.valueString = String.valueOf(eacLastUpdateDays);
                    resp.message = (eacLastUpdateDays == -1 ? 'N/A' : eacLastUpdateDays + ' days');
                    kpiResponses.add(resp);
                    //System.debug('___ resp5='+resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
                
                /*NOTE: HIDDEN for now from the ProjectPerformanceReviews page:
                try {            
                    // EAC - RunRateETC
                    Decimal runRateETC = 
                        kpiCalc.calcRunRateETC(project.RevisedEndDate__c, asOfDate).setScale(1);
                    System.debug('___runRateETC variance='+runRateETC);
                    kpi = ECO_KPIs__c.getInstance('EAC – Run Rate ETC');
                    thresholdA = kpi.ThresholdA__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    resp.evalResult = (runRateETC > Decimal.valueOf(thresholdA));
                    resp.valueString = String.valueOf(runRateETC);
                    resp.message = runRateETC + ' % of EAC';
                    kpiResponses.add(resp);
                    System.debug('___ resp6='+resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }*/

                try {
                    // EAC - Negative ETC
                    Boolean negativeETC = kpiCalc.isNegativeETC();
                    //System.debug('___negativeETC='+negativeETC);
                    kpi = ECO_KPIs__c.getInstance('EAC – Negative ETC');
                    thresholdA = kpi.ThresholdA__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    resp.evalResult = (negativeETC == Boolean.valueOf(thresholdA));
                    resp.valueString = String.valueOf(negativeETC);
                    Decimal costETC = kpiCalc.calcCostETC();
                    resp.message = project.ProjectFunctionalCurrencyCode__c + ' ' + costETC;
                    kpiResponses.add(resp);
                    //System.debug('___ resp7='+resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
                
                try {
                    // Net Margin
                    Decimal netMargin = kpiCalc.calcNetMarginMTD().setScale(1);
                    //System.debug('___netMargin='+netMargin);
                    kpi = ECO_KPIs__c.getInstance('Margin (MTD Net)');
                    thresholdA = kpi.ThresholdA__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    resp.evalResult = (netMargin < Decimal.valueOf(thresholdA));
                    resp.valueString = String.valueOf(netMargin);
                    resp.message = project.ProjectFunctionalCurrencyCode__c + ' ' + netMargin;
                    kpiResponses.add(resp);
                    //System.debug('___ resp8='+resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
                
                try { 
                    // Gross Margin
                    Decimal grossMargin = kpiCalc.calcGrossMarginMTD().setScale(1);
                    //System.debug('___grossMargin='+grossMargin);
                    kpi = ECO_KPIs__c.getInstance('Margin (MTD Gross)');
                    thresholdA = kpi.ThresholdA__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    resp.evalResult = (grossMargin < Decimal.valueOf(thresholdA));
                    resp.valueString = String.valueOf(grossMargin);
                    resp.message = project.ProjectFunctionalCurrencyCode__c + ' ' + grossMargin;
                    kpiResponses.add(resp);
                    //System.debug('___ resp9='+resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
                
                try {   
                    // Gained/Lost Margin
                    Decimal lostMarginPct = kpiCalc.calcLostAsPctOfApprovedMargin().setScale(1);
                    //System.debug('___lostMarginPct='+lostMarginPct);
                    kpi = ECO_KPIs__c.getInstance('Gained/Lost Margin');
                    thresholdA = kpi.ThresholdA__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    resp.evalResult = (lostMarginPct > Decimal.valueOf(thresholdA));
                    resp.valueString = String.valueOf(lostMarginPct);
                    resp.message = lostMarginPct + ' % Lost Net Margin ITD';
                    kpiResponses.add(resp);
                    //System.debug('___ resp10='+resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
                
                try {
                    // PM certified
                    Boolean pmNotCertified = kpiCalc.isPMNotCertified(project);
                    //System.debug('___pmNotCertified='+pmNotCertified);
                    kpi = ECO_KPIs__c.getInstance('Project Manager');
                    thresholdA = kpi.ThresholdA__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    resp.evalResult = (pmNotCertified == Boolean.valueOf(thresholdA));
                    resp.valueString = String.valueOf(pmNotCertified);
                    resp.message = (resp.evalResult ? 'PM is Not certified' : 'PM is Certified');
                    kpiResponses.add(resp);
                    //System.debug('___ resp11='+resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
                
                try {
                    // ITD Revenue > Contract Value
                    Decimal revenueExceedingContractValue = 
                        kpiCalc.calcRevenueExceedingContractValue(project).setScale(1);
                    //System.debug('___revenueExceedingContractValue='+revenueExceedingContractValue);
                    kpi = ECO_KPIs__c.getInstance('ITD Revenue > Contract Value');
                    thresholdA = kpi.ThresholdA__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    resp.evalResult = (revenueExceedingContractValue > Decimal.valueOf(thresholdA));
                    resp.valueString = String.valueOf(revenueExceedingContractValue);
                    resp.message = project.ProjectFunctionalCurrencyCode__c + ' ' + revenueExceedingContractValue;
                    kpiResponses.add(resp);
                    //System.debug('___ resp12='+resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
                
                try {
                    // Scheduled End Date
                    Boolean isScheduledEndDateInPast = 
                        kpiCalc.isScheduledEndDateInThePast(project, asOfDate);
                    kpi = ECO_KPIs__c.getInstance('Scheduled End Date');
                    thresholdA = kpi.ThresholdA__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    resp.evalResult = (isScheduledEndDateInPast == Boolean.valueOf(thresholdA));
                    resp.valueString = String.valueOf(isScheduledEndDateInPast);
                    if (project.pse__End_Date__c != null) {
                        resp.message = project.pse__End_Date__c.format();
                    }
                    kpiResponses.add(resp);
                    //System.debug('___ resp13='+resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
                
                try {
                    // Forecast End Date
                    Boolean isForecastEndDateInPast = 
                        kpiCalc.isForecastEndDateInThePast(project, asOfDate);
                    kpi = ECO_KPIs__c.getInstance('Forecast End Date');
                    thresholdA = kpi.ThresholdA__c;
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    resp.evalResult = (isForecastEndDateInPast == Boolean.valueOf(thresholdA));
                    resp.valueString = String.valueOf(isForecastEndDateInPast);
                    //NOTE: Substitute pse__End_Date__c if RevisedEndDate__c is null:
                    Date endDate = (project.RevisedEndDate__c == null ? project.pse__End_Date__c : project.RevisedEndDate__c);
                    if (endDate != null) {
                        resp.message = endDate.format();
                    }
                    kpiResponses.add(resp);
                    //System.debug('___ resp14='+resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
                
                try {
                    // Aged Unbilled
                    Map<String, Decimal> unbilledMap = kpiCalc.calcAgedUnbilled();
                    kpi = ECO_KPIs__c.getInstance('Aged Unbilled');
                    thresholdA = kpi.ThresholdA__c;
                    Decimal threshold = Decimal.valueOf(thresholdA);
                    resp = new Response();
                    resp.triggerName = kpi.Name;
                    resp.regionOverride = false;
                    resp.thresholdDescription = kpi.ThresholdText__c.replace('[Threshold A]', thresholdA);
                    //System.debug('___unbilledMap='+unbilledMap);
                    Decimal unbilledValue = 0;
                    if (threshold > 0 && threshold < 30) {
                        unbilledValue = unbilledMap.get('0to30');
                    }
                    else if (threshold >= 30 && threshold < 60) {
                        unbilledValue = unbilledMap.get('UnbilledTotal') - unbilledMap.get('0to30');
                    }
                    else if (threshold >= 60 && threshold < 90) {
                        unbilledValue = unbilledMap.get('UnbilledTotal') - unbilledMap.get('31to60') - unbilledMap.get('0to30');
                    }
                    else if (threshold >= 90 && threshold < 180) {
                        unbilledValue = unbilledMap.get('UnbilledTotal') - unbilledMap.get('61to90') - unbilledMap.get('31to60') - unbilledMap.get('0to30');
                    }
                    else if (threshold >= 180) {
                        unbilledValue = unbilledMap.get('181plus');
                    }

                    unbilledValue = unbilledValue.setScale(2);
                    resp.evalResult = (unbilledValue > 0);
                    resp.valueString = String.valueOf(unbilledValue);
                    resp.message = project.ProjectFunctionalCurrencyCode__c + ' ' + unbilledValue + ' unbilled';
                    kpiResponses.add(resp);
                    //System.debug('___ resp15='+resp);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
                projectToResponsesMap.put(projectId, kpiResponses);
            }
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        System.debug(logginglevel.FINE,'>>> END EvaluateProjectHealth(projectId, snapshot) <<<');
        return projectToResponsesMap;
    }

    /** ---------------------------------------------------------------------------------------
    * @Description Inner Class object which contains data as a result of the HealthCheck evaluation
    *
    * @Author Arman.Shah@nttdata.com, Jake.White@aecom.com
    * @Date August 2016
    *----------------------------------------------------------------------------------------*/
    public class Response
    {
        public String triggerName {get; set;}
        public String thresholdDescription {get; set;}
        public Boolean evalResult {get; set;}
        public String message {get; set;}
        public Boolean regionOverride {get; set;}
        public String valueString {get; set;}
    }
}