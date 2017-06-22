/** ------------------------------------------------------------------------------------------------------
* @Description Controller supporting the ECO_PMD_NavigationBar_ng 
* and other components that display information about a specific projcet
*
* @Author      NTT Data ??, AECOM Luke Farbotko, Jake White
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_PMD_ProjectDetails_Controller {
    
    public pse__Proj__c project { get; set; }
 	public Boolean initialized { get; set; }    
    public String uLocale { get; set; }
    public String id_Report_CostDetailRawCost { get; set;}

    public string currentProjectId  {
    	get;
        set {

            currentProjectId = value;
        	System.debug('lfxxxx' + value);
            initializeProject(currentProjectId);
        }
     }
     /**/

    public String StartDate {get; set;}
    public String EndDate {get; set;}
    public String ForecastStartDate {get; set;}
    public String ForecastEndDate {get; set;}

    /**
     * 
     *
     * @Author  NTT Data ??, AECOM Luke Farbotko, Jake White
     * @Date    2015
     *
     * @param   projectId - Salesforce object ID of the pse__Proj__c object
     * @return  
     **/
    public void initializeProject(string projectId)
    {
        //GET USERS LOCALE FOR DATES
        uLocale = UserInfo.getLocale();
        try{
            ReportDetails__c setting = ReportDetails__c.getInstance('Cost Details - Raw Data');
            id_Report_CostDetailRawCost = setting.Report_Id__c;
        } catch (Exception e){
            id_Report_CostDetailRawCost = '';
            system.debug(e);
        }
    	System.debug('lfxxxxINIT' + projectId);
    	project = [select id, 
					name, 
					OracleProjectnumber__c, 
					clAECOMProjectReviewCategory__c, 
                    clAECOMWork__c,
					ContractTypes__c,
					ProjectApprover__r.Name, 
					DefaultTopTaskCustomer__r.Name, 
					PrimaryEndClient__r.Name, 
					BusinessLineOwningOrg__c,
					EndMarketSector__c, 
					pse__Region__r.pse__Region_Name_Chain__c,
					pse__Project_Manager__r.Name,
                    PrimaryBillingClientNameOnly__c,
                    ProjectFunctionalCurrencyCode__c,
                    pse__Start_Date__c,
                    pse__End_Date__c,
                    RevisedStartDate__c,
                    RevisedEndDate__c
				from pse__Proj__c
				where id = :projectId]; 

        StartDate = '';
        if(this.project.pse__Start_Date__c != null)
        {
            StartDate = this.project.pse__Start_Date__c.format();
        }
        EndDate = '';
        if(this.project.pse__End_Date__c != null)
        {
            EndDate = this.project.pse__End_Date__c.format();
        }
        ForecastStartDate = '';
        if(this.project.RevisedStartDate__c != null)
        {
            ForecastStartDate = this.project.RevisedStartDate__c.format();
        }
        ForecastEndDate = '';
        if(this.project.RevisedEndDate__c != null)
        {
            ForecastEndDate = this.project.RevisedEndDate__c.format();
        }    

    }

    public ECO_PMD_ProjectDetails_Controller(){}
    
    public ECO_PMD_ProjectDetails_Controller(ApexPages.StandardController stdController) {
        this.project = (pse__Proj__c)stdController.getRecord();     
    }

}