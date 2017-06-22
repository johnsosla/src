/* Change Log
Date        Developer           Work Item           Changes Made
----        ---------           ---------           ------------
2/6/15      Gautam Shah         WI-000191           Created "isValid" method, lines 148-163; calls to this methods on lines 50, 166;
4/3/15      Brad Furdyk                             Added updating CarryingOutOrganization__c when primary org gets set to support imported projects which don't use PrimaryOrganization__c
*/
public class ECO_OrganizationFinderController {
    public pse__Proj__c oProject {get; set;}

    public string sOrganizationName {get; set;}
    public string sGeographyName {get; set;}
    public string sRegion {get; set;}
    public string sDistrict {get; set;}
    public string sBusinessLine {get; set;}
    public string sDepartment {get; set;}
    public string sLocation {get; set;}
    public string sProjOwning {get; set;}

    public list<SelectOption> loGeographies {get; set;}
    public list<SelectOption> loRegions {get; set;}
    public list<SelectOption> loDistricts {get; set;}
    public list<SelectOption> loBusinessLines {get; set;}
    public list<SelectOption> loDepartments {get; set;}
    public list<SelectOption> loLocations {get; set;}
    public list<SelectOption> loProjOwnings {get; set;}
    public list<OrganizationString__c> lUserOrganizations {get; set;}

    public list<OrganizationString__c> lOrganizations {get; set;}
    public list<ProjectOrganization__c> lSelectedOrganizations {get; set;}

    public OrganizationString__c userOrg {get;set;}

    public string sSelectedOrganizationId {get; set;}

    public boolean bSearchInProgress {get; set;}
    
    public boolean bUpdateContributionDisabled {get; set;}

    private integer iOrgLimit;

    private boolean bOrgMore;

    public site__c primarySite {get;set;}

    public boolean bShowMoreButtonOrg {get;set;}
    public string showMoreOrgText {get;set;}
    private static integer orgLessLIMIT = 20;
    private static integer orgMoreLIMIT = 200;


    public class EcoControllerException extends Exception {}

    public ECO_OrganizationFinderController(ApexPages.StandardController oStandardController) {
        ProjectOrganization__c oProjectOrganization = (ProjectOrganization__c)oStandardController.getRecord();

        string passedProjectID = ApexPages.currentPage().getParameters().get('passedProjectID');


        if(ECO_Utils_String.NullCheck(oProjectOrganization.Project__c) == '' && passedProjectID==null){
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'You have reached this page improperly, please access it from the Project screen.');
            ApexPages.addMessage(oPageMessage);

            return;
        } else if (ECO_Utils_String.NullCheck(oProjectOrganization.Project__c) == '' && passedProjectID!=null){
            oProjectOrganization.Project__c = passedProjectID;
        }

        oProject = ECO_Service_Projects.getProjectById(oProjectOrganization.Project__c);
        lSelectedOrganizations = oProject.ProjectOrganizations__r;

        sOrganizationName = '';
        sGeographyName = '';
        sRegion = '';
        sDistrict = '';
        sBusinessLine = '';
        sDepartment = '';
        sLocation = '';
        sProjOwning = '';

        iOrgLimit = orgLessLIMIT;
        bOrgMore = false;
        bShowMoreButtonOrg = false;
        showMoreOrgText = 'Show More';

        sSelectedOrganizationId = '';
        bSearchInProgress = false;   
        bUpdateContributionDisabled = false;     
        isValid(false);

        lUserOrganizations = new list<OrganizationString__c>();

        primarySite = [select id, OUID__c from site__c where id =: oProject.PrimarySite__c];

        SearchOrganizations();
        SearchUserOrganization();
    }
    
    public PageReference cancel()
    {
        return new PageReference('/' + oProject.Id);
    }

    public void SearchUserOrganization(){

        list<user> lUser = [SELECT ECO_OrganizationName__c FROM User WHERE ID =:UserInfo.getUserId()];

        lUserOrganizations = [SELECT Id, Name, OrganizationName__c, GeographyName__c, Region__c, District__c, Department__c, BusinessLineName__c, LocationName__c, PLManagerContact__c, ProjectOwning__c, FinanceandAccountingManagerContact__c, CFOorDelegateContact__c, OUID__c, CurrencyIsoCode FROM OrganizationString__c WHERE Name =: lUser[0].ECO_OrganizationName__c and ProjectOwning__c=true and (InactiveDate__c > TODAY OR InactiveDate__c = null)];

        if(lUserOrganizations.size() > 0){
            userOrg = lUserOrganizations[0];
        } else {
            userOrg = null;
        }
      
    }

    private void showMoreOrg(){
        showMoreOrgText = 'Show Less';
        iOrgLimit = orgMoreLIMIT;
        bOrgMore = true;
    }

    private void showLessOrg(){
        showMoreOrgText = 'Show More';
        iOrgLimit = orgLessLIMIT;
        bOrgMore = false;
    }


    public void toggleOrgShow(){
        If(bOrgMore){
            showLessOrg();
            SearchOrganizations();
        } else {
            showMoreOrg();
            SearchOrganizations();
        }
    }
    
    public PageReference SearchOrganizations(){
        set<string> lGeographies = new set<string>();
        set<string> lRegions = new set<string>();
        set<string> lDistricts = new set<string>();
        set<string> lBusinessLines = new set<string>();
        set<string> lDepartments = new set<string>();
        set<string> lLocations = new set<string>();
        set<string> lProjOwning = new set<string>();

        bSearchInProgress = false;

        string sQuery = 'SELECT Id, CurrencyIsoCode, Name, OrganizationName__c, GeographyName__c, Region__c, District__c, Department__c, BusinessLineName__c, Project_Owning_Text__c, ProjectOwning__c, LocationName__c FROM OrganizationString__c WHERE ';
        
        if(ECO_Utils_String.NullCheck(sOrganizationName) != ''){
            sQuery += 'Name LIKE \'%' + sOrganizationName + '%\' and ';
            bSearchInProgress = true;
        }

        if(ECO_Utils_String.NullCheck(sGeographyName) != ''){
            sQuery += 'GeographyName__c = \'' + sGeographyName + '\' and ';
            bSearchInProgress = true;
        }
        
        if(ECO_Utils_String.NullCheck(sRegion) != ''){
            sQuery += 'Region__c = \'' + sRegion + '\' and ';
            bSearchInProgress = true;
        }
        
        if(ECO_Utils_String.NullCheck(sDistrict) != ''){
            sQuery += 'District__c = \'' + sDistrict + '\' and ';
            bSearchInProgress = true;
        }

        if(ECO_Utils_String.NullCheck(sBusinessLine) != ''){
            sQuery += 'BusinessLineName__c = \'' + sBusinessLine + '\' and ';
            bSearchInProgress = true;
        }
        
        if(ECO_Utils_String.NullCheck(sDepartment) != ''){
            sQuery += 'Department__c = \'' + sDepartment + '\' and ';
            bSearchInProgress = true;
        }

        if(ECO_Utils_String.NullCheck(sLocation) != ''){
            sQuery += 'LocationName__c = \'' + sLocation + '\' and ';
            bSearchInProgress = true;
        }

        sQuery += '(InactiveDate__c > TODAY OR InactiveDate__c = null)  and ProjectOwning__c=true ORDER BY OrganizationName__c, GeographyName__c, Region__c, BusinessLineName__c, Department__c, LocationName__c';
        
        system.debug(sQuery);

        list<OrganizationString__c> lOrganizationsQueried = Database.query(sQuery);

        loGeographies = new list<SelectOption>();
        loRegions = new list<SelectOption>();
        loDistricts = new list<SelectOption>();
        loBusinessLines = new list<SelectOption>();
        loDepartments = new list<SelectOption>();
        loLocations  = new list<SelectOption>();
        loProjOwnings  = new list<SelectOption>();

        for(OrganizationString__c oOrganizationString : lOrganizationsQueried){
            if(lGeographies.size() < 1000)
                lGeographies.add(oOrganizationString.GeographyName__c);
            if(lRegions.size() < 1000)
                lRegions.add(oOrganizationString.Region__c);
            if(lDistricts.size() < 1000)
                lDistricts.add(oOrganizationString.District__c);
            if(lBusinessLines.size() < 1000)
                lBusinessLines.add(oOrganizationString.BusinessLineName__c);
            if(lDepartments.size() < 1000)
                lDepartments.add(oOrganizationString.Department__c);
            if(lLocations.size() < 1000)
                if(oOrganizationString.LocationName__c != null){
                    lLocations.add(oOrganizationString.LocationName__c);
                }
            if(lProjOwning.size() < 1000)
                if(oOrganizationString.Project_Owning_Text__c != null){
                    lProjOwning.add(oOrganizationString.Project_Owning_Text__c);
                }
        }

        list<string> olGeographies = new list<string>(lGeographies);
        list<string> olRegions = new list<string>(lRegions);
        list<string> olDistricts = new list<string>(lDistricts);
        list<string> olBusinessLines = new list<string>(lBusinessLines);
        list<string> olDepartments = new list<string>(lDepartments);
        list<string> olLocations = new list<string>(lLocations);
        list<string> olProjOwnings = new list<string>(lProjOwning);


        olGeographies.sort();
        olRegions.sort();
        olDistricts.sort();
        olBusinessLines.sort();
        olDepartments.sort();
        olLocations.sort();
        olProjOwnings.sort();

        for(string sString : olGeographies){
            loGeographies.add(new SelectOption(sString, sString));
        }

        for(string sString : olRegions){
            loRegions.add(new SelectOption(sString, sString));
        }

        for(string sString : olDistricts){
            loDistricts.add(new SelectOption(sString, sString));
        }

        for(string sString : olBusinessLines){
            loBusinessLines.add(new SelectOption(sString, sString));
        }

        for(string sString : olDepartments){
            loDepartments.add(new SelectOption(sString, sString));
        }

        for(string sString : olLocations){
            loLocations.add(new SelectOption(sString, sString));
        }

        for(string sString : olProjOwnings){
            loProjOwnings.add(new SelectOption(sString, sString));
        }
        
        if(bSearchInProgress){

            lOrganizations = new list<OrganizationString__c>();

            for(OrganizationString__c SearchOrganiation: lOrganizationsQueried){
                if(lOrganizations.size() < iOrgLimit){
                    lOrganizations.add(SearchOrganiation);
                }
                
                if(lOrganizations.size() < orgLessLIMIT){
                    bShowMoreButtonOrg = false;
                } else {
                    bShowMoreButtonOrg = true;
                }
            }

        }

        return null;
    }


    public PageReference Reset(){
        sOrganizationName = '';
        sGeographyName = '';
        sRegion = '';
        sDistrict = '';
        sLocation = '';
        sBusinessLine = '';
        sDepartment = '';

        SearchOrganizations();

        return null;
    }

    public boolean isValid(boolean allowDML)
    {
        boolean bIsValid = true;
        Decimal dTotal = 0;
        
        if(lSelectedOrganizations.size() == 0)
            bUpdateContributionDisabled = true;
        else
            bUpdateContributionDisabled = false;
        
        if(lSelectedOrganizations.size() == 1 && allowDML)
        {
            if(lSelectedOrganizations[0].ContributionPercent__c != 100)
            {
                lSelectedOrganizations[0].ContributionPercent__c = 100;
                SaveRecords();
            }
        }
       
        for(ProjectOrganization__c po : lSelectedOrganizations)
        {
            Decimal dPercentage = ECO_Utils_String.NullCheck(po.ContributionPercent__c);
            dTotal += dPercentage;
        }
        if(lSelectedOrganizations.size() > 0 && dTotal != 100)
        {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'The Contribution % for the Selected Organizations does not total 100%.');
            ApexPages.addMessage(oPageMessage);
            bIsValid = false;
        }
        
        return bIsValid;
    }

    public PageReference SaveRecords(){

        Integer OppUpdatePrjUpdate = 0;

        if(isValid(false))
        {
            try{
                update lSelectedOrganizations;
                OppUpdatePrjUpdate = 1;
            }catch(EcoControllerException oException){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
            }

            /******OPPORTUNITY UPDATES******/
            if (OppUpdatePrjUpdate == 1)
            {
                //System.debug('inside update or insert Flag');
                //PREPARING THE AECOM_Primary_Department__c MAP.
                //Prepare and populate the set of orgstring ids

                Set<Id> appdIdsSet =  new Set<Id>();

                Set<Id> setOrgStringIds = new Set<Id>();
                for (ProjectOrganization__c orgString : lSelectedOrganizations)
                {
                    setOrgStringIds.add(orgString.OrganizationString__c);
                    //System.debug('orgString.OrganizationString__c: ' + orgString.OrganizationString__c);
                }
                //Prepare and populate the list of orgstrings
                List<OrganizationString__c> lstOrgStrings = new list<OrganizationString__c>();
                try
                {
                    lstOrgStrings = [select Id, OrganizationName__c from OrganizationString__c where Id IN :setOrgStringIds];
                }
                catch( Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
                //Populate the set of org string names
                Set<string> sOrgNames = new set<string>();
                for(OrganizationString__c os : lstOrgStrings)
                {
                    sOrgNames.add(os.OrganizationName__c);
                    //System.debug('os.OrganizationName__c: ' + os.OrganizationName__c);
                }                      

                list<AECOM_Primary_Department__c> lstAPD = new list<AECOM_Primary_Department__c>();
                try{
                    lstAPD = [SELECT ID, Org_String__c FROM AECOM_Primary_Department__c  WHERE Org_String__c IN:sOrgNames];
                } catch( Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, 'Error while searching for AECOM Primary Department during CreateOpportunity: ' + e.getMessage());
                }
                Map<string, AECOM_Primary_Department__c> mapAPD = new map<string, AECOM_Primary_Department__c>();  
                for(AECOM_Primary_Department__c APD:lstAPD){
                    mapAPD.put(APD.Org_String__c, APD);
                    //System.debug('APD.Org_String__c: ' + APD.Org_String__c);
                    appdIdsSet.add(APD.Id);
                }                

                //PREPARING THE Org String Map
                List<ProjectOrganization__c> lProjectOrganizations = new List<ProjectOrganization__c>();
                try
                {
                    lProjectOrganizations = [SELECT Id, OrganizationString__c FROM ProjectOrganization__c 
                                             WHERE Project__c = :oProject.Id and 
                                             OrganizationString__c IN :setOrgStringIds];
                }
                catch( Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
                Map<Id, string> mapOrgStrings = new Map<Id, string>();
                
                List<OrganizationString__c> listorgstrs = new List<OrganizationString__c>();
                try
                {
                    listorgstrs = [SELECT Id, OrganizationName__c FROM OrganizationString__c WHERE Id  IN : setOrgStringIds];
                }
                catch(Exception e)
                {
                    ECO_Service_ErrorLog.logException(e);   
                }
                for (OrganizationString__c os : listorgstrs)
                {
                    mapOrgStrings.put(os.Id, os.OrganizationName__c);   
                }                      


                Opportunity oOpp = null;
                try
                {
                    oOpp = [select id, Name, AECOM_Primary_Dept_Lookup__c, AECOM_Primary_Department_Percent__c, StageName from Opportunity where id=: oProject.pse__Opportunity__c];
                    //System.debug('oOpp.Name ' + oOpp.Name);
                }
                catch( Exception e)
                {
                    ECO_Service_ErrorLog.logException(e);
                }                

                list<Opportunity_Department__c> lstOppDToUpdate = new list<Opportunity_Department__c>();

                Opportunity_Department__c oOpportunityDepartmentToInsert = new Opportunity_Department__c();

                //This will prepare a map that is going to be searched after the for, so we can identity the id of the record for remval.
                list<Opportunity_Department__c> oddeptsList = new list<Opportunity_Department__c>();
                try
                {
                    oddeptsList = [Select Id, AECOM_Department__c, Opportunity__c From Opportunity_Department__c Where AECOM_Department__c IN :appdIdsSet and Opportunity__c = :oOpp.id];
                }
                catch(Exception e)
                {
                    ECO_Service_ErrorLog.logException(e);
                }             

                Map<Id, Opportunity_Department__c> oddepts =  new Map<Id, Opportunity_Department__c>();

                for (Opportunity_Department__c oddept: oddeptsList )
                {
                    oddepts.put(oddept.AECOM_Department__c, oddept);
                }
                

                for(ProjectOrganization__c oProjectOrganization : lSelectedOrganizations)
                {
                    //System.debug('inside supporting ' + oOpp.Name);
                    //Do the SOQL to get the organization name.
                    OrganizationString__c orgSelect = null;
                    try
                    {
                        orgSelect = [Select Id, OrganizationName__c From OrganizationString__c Where Id =: oProjectOrganization.OrganizationString__c LIMIT 1];
                    }
                    catch(Exception e)
                    {
                        ECO_Service_ErrorLog.logException(e);
                    }                  
                    String orgNameSelect = orgSelect.OrganizationName__c;

                    //System.debug('orgNameSelect : ' + orgNameSelect);

                    //At this point, we want to do a check to see if the AECOM Primary Object contains this org.
                    
                    list<AECOM_Primary_Department__c> primarySelectList = 
                    //AECOM_Primary_Department__c primarySelect = 
                        [Select Id, Org_String__c From AECOM_Primary_Department__c 
                         Where Org_String__c = :orgNameSelect Limit 1];

                    //if (primarySelect != null)
                    if (primarySelectList.size() > 0)
                    {
                        //System.debug('primarySelect.Id : ' + primarySelect.Id);

                        if (mapAPD.containsKey(mapOrgStrings.get((Id)oProjectOrganization.OrganizationString__c)))
                        {
                            oOpportunityDepartmentToInsert = oddepts.get(mapAPD.get(mapOrgStrings.get((Id)oProjectOrganization.OrganizationString__c)).Id);
                            //oOpportunityDepartmentToInsert.split__c = oProjectOrganization.ContributionPercent__c;

                            if(oOpportunityDepartmentToInsert != null){
                                lstOppDToUpdate.add(oOpportunityDepartmentToInsert);
                            

                                oOpportunityDepartmentToInsert.split__c = oProjectOrganization.ContributionPercent__c;
                                //oOpportunityDepartmentToInsert.AECOM_Department__c = supportingDepartments[0].Id;    
                                oOpportunityDepartmentToInsert.AECOM_Department__c = primarySelectList[0].Id;  
                                //lstOppDToInsert.Add(oOpportunityDepartmentToInsert);                
                            }
                        }             
                    }                 
                }

                if (lstOppDToUpdate.size()>0)          
                {
                    try
                    {
                        update lstOppDToUpdate;
                        //System.debug('Passed update');
                    }
                    catch( Exception e)
                    {
                        ECO_Service_ErrorLog.logException(e);
                        //System.debug('Exception: ' + e.getMessage());
                    }
                }
            }

            OppUpdatePrjUpdate = 0;
    
            //Update Project to reflect changes
            oProject = ECO_Service_Projects.getProjectById(oProject.Id);
            lSelectedOrganizations = oProject.ProjectOrganizations__r;
        }
        return null;
    }

    public PageReference RemoveEntry()
    {
        //Check if entry already exists
        list<ProjectOrganization__c> lProjectOrganizationsToRemove = new list<ProjectOrganization__c>([SELECT Id, Type__c, OrganizationString__c 
                                                            FROM ProjectOrganization__c
                                                            WHERE Project__c = :oProject.Id and OrganizationString__c = :sSelectedOrganizationId]);

        Integer OppUpdateProceed = 0;

        Set<Id> appdIdsSet =  new Set<Id>();
        //System.debug('inside update or insert Flag');
        //PREPARING THE AECOM_Primary_Department__c MAP.
        //Prepare and populate the set of orgstring ids
        Set<Id> setOrgStringIds = new Set<Id>();
        for (ProjectOrganization__c orgString : lSelectedOrganizations)
        {
            setOrgStringIds.add(orgString.OrganizationString__c);
            //System.debug('orgString.OrganizationString__c: ' + orgString.OrganizationString__c);
        }
        //Prepare and populate the list of orgstrings
        List<OrganizationString__c> lstOrgStrings = new list<OrganizationString__c>();
        try
        {
            lstOrgStrings = [select Id, OrganizationName__c from OrganizationString__c where Id IN :setOrgStringIds];
        }
        catch( Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        //Populate the set of org string names
        Set<string> sOrgNames = new set<string>();
        for(OrganizationString__c os : lstOrgStrings)
        {
            sOrgNames.add(os.OrganizationName__c);
            //System.debug('os.OrganizationName__c: ' + os.OrganizationName__c);
        }                      

        list<AECOM_Primary_Department__c> lstAPD = new list<AECOM_Primary_Department__c>();
        try
        {
            lstAPD = [SELECT ID, Org_String__c FROM AECOM_Primary_Department__c  WHERE Org_String__c IN:sOrgNames];
        } 
        catch( Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e, 'Error while searching for AECOM Primary Department during CreateOpportunity: ' + e.getMessage());
        }

        Map<string, AECOM_Primary_Department__c> mapAPD = new map<string, AECOM_Primary_Department__c>();  
        for(AECOM_Primary_Department__c APD:lstAPD)
        {
            mapAPD.put(APD.Org_String__c, APD);
            //System.debug('APD.Org_String__c: ' + APD.Org_String__c);
            appdIdsSet.add(APD.Id);
        }

        //PREPARING THE Org String Map
        List<ProjectOrganization__c> lProjectOrganizations = new List<ProjectOrganization__c>();
        try
        {
            lProjectOrganizations = [SELECT Id, OrganizationString__c FROM ProjectOrganization__c 
                                     WHERE Project__c = :oProject.Id and 
                                     OrganizationString__c IN :setOrgStringIds];
        }
        catch( Exception e)
        {
            ECO_Service_ErrorLog.logException(e);
        }
        Map<Id, string> mapOrgStrings = new Map<Id, string>();
        
        List<OrganizationString__c> listorgstrs = new List<OrganizationString__c>();
        try
        {
            listorgstrs = [SELECT Id, OrganizationName__c FROM OrganizationString__c WHERE Id  IN : setOrgStringIds];
        }
        catch(Exception e)
        {
            ECO_Service_ErrorLog.logException(e);   
        }
        for (OrganizationString__c os : listorgstrs)
        {
            mapOrgStrings.put(os.Id, os.OrganizationName__c);   
        }        


        //REMOVE FROM PROJECTS
        try
        {
            delete lProjectOrganizationsToRemove;
            OppUpdateProceed = 1;
        }catch(EcoControllerException oException)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
        }

        
        /******OPPORTUNITY UPDATES******/
        if (OppUpdateProceed == 1)
        {
            Opportunity oOpp = null;

            try
            {
                oOpp = [Select id, Name, AECOM_Primary_Dept_Lookup__c, AECOM_Primary_Department_Percent__c, StageName From Opportunity where id=: oProject.pse__Opportunity__c];
                //System.debug('oOpp.Name ' + oOpp.Name);
            }
            catch( Exception e)
            {
                ECO_Service_ErrorLog.logException(e);
            }            

            list<Opportunity_Department__c> lstOppDToDelete = new list<Opportunity_Department__c>();

            Opportunity_Department__c oOpportunityDepartmentToDelete = new Opportunity_Department__c();

            Set<Id> aecomDeptId = new Set<Id>();    //AECOM Dept Ids

            //This will prepare a map that is going to be searched after the for, so we can identity the id of the record for remval.
            list<Opportunity_Department__c> oddeptsList = new list<Opportunity_Department__c>();

            try
            {
                oddeptsList = [Select Id, AECOM_Department__c, Opportunity__c From Opportunity_Department__c Where AECOM_Department__c IN :appdIdsSet and Opportunity__c = :oOpp.id];
            }
            catch( Exception e)
            {
                ECO_Service_ErrorLog.logException(e);
            }            

            Map<Id, Opportunity_Department__c> oddepts =  new Map<Id, Opportunity_Department__c>();

            for (Opportunity_Department__c oddept: oddeptsList )
            {
                oddepts.put(oddept.AECOM_Department__c, oddept);
            }


            for(ProjectOrganization__c oProjectOrganization : lProjectOrganizationsToRemove)
            {
                //System.debug('inside for');

                if(oProjectOrganization.Type__c == 'Supporting')
                {
                    //System.debug('(Id)oProjectOrganization.OrganizationString__c : ' + (Id)oProjectOrganization.OrganizationString__c);                        
                    //System.debug('mapOrgStrings.get((Id)oProjectOrganization.OrganizationString__c) : ' + mapOrgStrings.get((Id)oProjectOrganization.OrganizationString__c));

                    if(mapAPD.containskey(mapOrgStrings.get((Id)oProjectOrganization.OrganizationString__c)))
                    {
                        //System.debug('mapAPD.get(mapOrgStrings.get(oProjectOrganization.OrganizationString__c)).Id : ' + mapAPD.get(mapOrgStrings.get(oProjectOrganization.OrganizationString__c)).Id);
                        //System.debug('oOpp.id : ' + oOpp.id);

                        //oOpportunityDepartmentToDelete.Opportunity__c = oOpp.id;
                        //oOpportunityDepartmentToDelete.AECOM_Department__c = mapAPD.get(mapOrgStrings.get((Id)oProjectOrganization.OrganizationString__c)).Id;
                        if (mapAPD.containsKey(mapOrgStrings.get((Id)oProjectOrganization.OrganizationString__c)))
                        {
                            oOpportunityDepartmentToDelete = oddepts.get(mapAPD.get(mapOrgStrings.get((Id)oProjectOrganization.OrganizationString__c)).Id);
                            lstOppDToDelete.add(oOpportunityDepartmentToDelete);
                        }

                        OppUpdateProceed = 1;
                    }
                }
            }
            
            if(lstOppDToDelete.size() > 0)       
            {
                try
                {
                    delete lstOppDToDelete;
                    //System.debug('Passed update');
                }
                catch( Exception e)
                {
                    ECO_Service_ErrorLog.logException(e);
                    //System.debug('Exception: ' + e.getMessage());
                }
            }           

            OppUpdateProceed = 0;
        }

        //Update Project to reflect changes
        oProject = ECO_Service_Projects.getProjectById(oProject.Id);
        lSelectedOrganizations = oProject.ProjectOrganizations__r;

        isValid(true);
        
        return null;
    }

    public PageReference SelectPrimary(){
        Savepoint oSavePoint = Database.setSavepoint();

        //System.debug('inside SelectPrimary');

        //Check if entry already exists
        list<ProjectOrganization__c> lProjectOrganizationsToMakeSecondary = new list<ProjectOrganization__c>([SELECT Id
                                                            FROM ProjectOrganization__c
                                                            WHERE Project__c = :oProject.Id and OrganizationString__c != :sSelectedOrganizationId and Type__c = 'Primary']);

        if(lProjectOrganizationsToMakeSecondary.size() > 0){
            for(ProjectOrganization__c oProjectOrganization : lProjectOrganizationsToMakeSecondary){
                oProjectOrganization.Type__c = 'Supporting';
            }

            try{
                update lProjectOrganizationsToMakeSecondary;
            }catch(EcoControllerException oException){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                Database.rollback(oSavePoint);

                return null;
            }

            ECO_Service_RecordAccess.ignoreRestOfSecurity=true;
        }

        //Check if entry already exists
        list<ProjectOrganization__c> lProjectOrganizationsToMakePrimary = new list<ProjectOrganization__c>();
        try
        {
            lProjectOrganizationsToMakePrimary = [SELECT Id, Type__c, OrganizationString__c , ContributionPercent__c FROM ProjectOrganization__c
                                                  WHERE Project__c = :oProject.Id and OrganizationString__c = :sSelectedOrganizationId];
        }
        catch( Exception e)
        {
            ECO_Service_ErrorLog.logException(e);
        }

        ProjectOrganization__c oProjectOrganizationToInsert = new ProjectOrganization__c(Project__c = oProject.Id, OrganizationString__c = sSelectedOrganizationId, Type__c = 'Primary');

        Integer OppUpdatePrjUpdate = 0;
        Integer OppUpdatePrjInsert = 0;
        Integer OppUpdateProceed = 0;

        //System.debug('sSelectedOrganizationId ' + sSelectedOrganizationId);

        if(lProjectOrganizationsToMakePrimary.size() > 0)
        {
            //System.debug('lProjectOrganizationsToMakePrimary.size() ' + lProjectOrganizationsToMakePrimary.size());

            for(ProjectOrganization__c oProjectOrganization : lProjectOrganizationsToMakePrimary){
                oProjectOrganization.Type__c = 'Primary';
            }

            try{
                update lProjectOrganizationsToMakePrimary;
                OppUpdatePrjUpdate = 1;
                System.debug('OppUpdatePrjUpdate ' + OppUpdatePrjUpdate);
            }catch(EcoControllerException oException){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                Database.rollback(oSavePoint);

                return null;
            }
        }
        else
        {
            try{
                insert oProjectOrganizationToInsert;
                OppUpdatePrjInsert = 1;
                System.debug('OppUpdatePrjInsert ' + OppUpdatePrjInsert);
            }catch(EcoControllerException oException){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                Database.rollback(oSavePoint);

                return null;
            }
        }

        ECO_Service_RecordAccess.ignoreRestOfSecurity=true;
        ECO_Service_DirtyScope.Run = false;

        /******OPPORTUNITY UPDATES******/
        if (OppUpdatePrjUpdate == 1 || OppUpdatePrjInsert == 1)
        {
            System.debug('inside update or insert Flag');
            //PREPARING THE AECOM_Primary_Department__c MAP.
            //Prepare and populate the set of orgstring ids
            Set<Id> setOrgStringIds = new Set<Id>();
            for (ProjectOrganization__c orgString : lSelectedOrganizations)
            {
                setOrgStringIds.add(orgString.OrganizationString__c);
                //System.debug('orgString.OrganizationString__c: ' + orgString.OrganizationString__c);
            }
            //Prepare and populate the list of orgstrings
            List<OrganizationString__c> lstOrgStrings = new list<OrganizationString__c>();
            try
            {
                lstOrgStrings = [select Id, OrganizationName__c from OrganizationString__c where Id IN :setOrgStringIds];
            }
            catch( Exception e){
                ECO_Service_ErrorLog.logException(e);
            }
            //Populate the set of org string names
            Set<string> sOrgNames = new set<string>();
            for(OrganizationString__c os : lstOrgStrings)
            {
                sOrgNames.add(os.OrganizationName__c);
                //System.debug('os.OrganizationName__c: ' + os.OrganizationName__c);
            }                      

            list<AECOM_Primary_Department__c> lstAPD = new list<AECOM_Primary_Department__c>();
            try{
                lstAPD = [SELECT ID, Org_String__c FROM AECOM_Primary_Department__c  WHERE Org_String__c IN:sOrgNames];
            } catch( Exception e){
                ECO_Service_ErrorLog.formatPageError(e, 'Error while searching for AECOM Primary Department during CreateOpportunity: ' + e.getMessage());
            }
            Map<string, AECOM_Primary_Department__c> mapAPD = new map<string, AECOM_Primary_Department__c>();  
            for(AECOM_Primary_Department__c APD:lstAPD){
                mapAPD.put(APD.Org_String__c, APD);
                //System.debug('APD.Org_String__c: ' + APD.Org_String__c);
            }                

            //PREPARING THE Org String Map
            List<ProjectOrganization__c> lProjectOrganizations = new List<ProjectOrganization__c>();
            try
            {
                lProjectOrganizations = [SELECT Id, OrganizationString__c FROM ProjectOrganization__c 
                                         WHERE Project__c = :oProject.Id and 
                                         OrganizationString__c IN :setOrgStringIds];
            }
            catch( Exception e){
                ECO_Service_ErrorLog.logException(e);
            }
            Map<Id, string> mapOrgStrings = new Map<Id, string>();
            
            List<OrganizationString__c> listorgstrs = new List<OrganizationString__c>();
            try
            {
                listorgstrs = [SELECT Id, OrganizationName__c FROM OrganizationString__c WHERE Id  IN : setOrgStringIds];
            }
            catch(Exception e)
            {
                ECO_Service_ErrorLog.logException(e);   
            }
            for (OrganizationString__c os : listorgstrs)
            {
                mapOrgStrings.put(os.Id, os.OrganizationName__c);   
            }



            Opportunity oOpp = null;
            try
            {
                oOpp = [select id, AECOM_Primary_Dept_Lookup__c, AECOM_Primary_Department_Percent__c, StageName from Opportunity where id=: oProject.pse__Opportunity__c];
            }
            catch( Exception e){
                ECO_Service_ErrorLog.logException(e);
            }

            if (OppUpdatePrjUpdate == 1)
            {
                for(ProjectOrganization__c oProjectOrganization : lProjectOrganizationsToMakePrimary)
                {
                    //System.debug('inside for');
                    //System.debug('OppUpdatePrjUpdate ' + OppUpdatePrjUpdate);

                    if(oProjectOrganization.Type__c == 'Primary')
                    {
                        //System.debug('(Id)oProjectOrganization.OrganizationString__c : ' + (Id)oProjectOrganization.OrganizationString__c);                        
                        //System.debug('mapOrgStrings.get((Id)oProjectOrganization.OrganizationString__c) : ' + mapOrgStrings.get((Id)oProjectOrganization.OrganizationString__c));

                        if(mapAPD.containskey(mapOrgStrings.get((Id)oProjectOrganization.OrganizationString__c)))
                        {
                            System.debug('mapAPD.get(mapOrgStrings.get(oProjectOrganization.OrganizationString__c)).Id : ' + mapAPD.get(mapOrgStrings.get(oProjectOrganization.OrganizationString__c)).Id);
                            System.debug('oProjectOrganization.ContributionPercent__c : ' + oProjectOrganization.ContributionPercent__c);

                            oOpp.AECOM_Primary_Dept_Lookup__c = mapAPD.get(mapOrgStrings.get((Id)oProjectOrganization.OrganizationString__c)).Id;
                            oOpp.AECOM_Primary_Department_Percent__c = oProjectOrganization.ContributionPercent__c;
                            OppUpdateProceed = 1;
                        }
                    }
                }
            }
            else if (OppUpdatePrjInsert == 1)
            { 
                //System.debug('inside for');
                System.debug('OppUpdatePrjInsert ' + OppUpdatePrjInsert);

                if(oProjectOrganizationToInsert.Type__c == 'Primary')
                {
                    //Do the SOQL to get the organization name.
                    OrganizationString__c orgSelect = null;
                    try
                    {
                        orgSelect = [Select Id, OrganizationName__c From OrganizationString__c Where Id =: oProjectOrganizationToInsert.OrganizationString__c];
                    }
                    catch( Exception e)
                    {
                        ECO_Service_ErrorLog.logException(e);
                    }                    

                    String orgNameSelect = orgSelect.OrganizationName__c;

                    System.debug('orgNameSelect : ' + orgNameSelect);

                    //At this point, we want to do a check to see if the AECOM Primary Object contains this org.

                    list<AECOM_Primary_Department__c> listPrimarySelect = new list<AECOM_Primary_Department__c>();
                    listPrimarySelect = [Select Id, Org_String__c From AECOM_Primary_Department__c Where Org_String__c = :orgNameSelect Limit 1];

                    if (!listPrimarySelect.isEmpty())
                    {
                        oOpp.AECOM_Primary_Dept_Lookup__c = listPrimarySelect[0].Id;
                        oOpp.AECOM_Primary_Department_Percent__c = oProjectOrganizationToInsert.ContributionPercent__c;
                        OppUpdateProceed = 1;
                    }

                }            
            }

            OppUpdatePrjUpdate = 0;
            OppUpdatePrjInsert = 0;  

            if (OppUpdateProceed == 1)          
            {
                try
                {
                    ECO_ProjectTriggers.run = false;
                    update oOpp;
                    ECO_ProjectTriggers.run = true;
                    //System.debug('Passed update');
                }
                catch( Exception e)
                {
                    ECO_Service_ErrorLog.logException(e);
                    //System.debug('Exception: ' + e.getMessage());
                }
            }

            OppUpdateProceed = 0;
        }

        OrganizationString__c targetOrg = [select id, CurrencyIsoCode from OrganizationString__c where id=:sSelectedOrganizationId];

        //Update project to reflect
        pse__Proj__c oProjectToUpdate = new pse__Proj__c(Id = oProject.Id, CarryingOutOrganization__c = sSelectedOrganizationId, CurrencyIsoCode=targetOrg.CurrencyIsoCode, ProjectFunctionalCurrencyCode__c=targetOrg.CurrencyIsoCode);



        //****UPDATE PROJECT ORG AND KEY MEMBERS - Tom Smalara 24-FEB-2016

        oProjectToUpdate.CarryingOutOrganization__c = sSelectedOrganizationId;

        map<string, ProjectRole__c> mapProjectRole = new map<string, ProjectRole__c>();
        List<ProjectRole__c> lProjectRoles = new List<ProjectRole__c>([Select Id, Name, Type__c From ProjectRole__c Where Active__c = true]);

        for(ProjectRole__c pr: lProjectRoles){
            mapProjectRole.put(pr.Name, pr);
        }

        set<id> roleset = new set<id>();
        roleset.add(mapProjectRole.get('Project Approver').id);
        roleset.add(mapProjectRole.get('Project Approver 2').id);
        roleset.add(mapProjectRole.get('Finance Lead').id);
        roleset.add(mapProjectRole.get('CFO or Delegate').id);
        roleset.add(mapProjectRole.get('Project Accountant').id);
        roleset.add(mapProjectRole.get('Project Accountant 2').id);
        roleset.add(mapProjectRole.get('Finance Lead 2').id);
        roleset.add(mapProjectRole.get('Go/No Go Approver').id);

        //Delete current members
        id pmID = mapProjectRole.get('Project Manager').id;
        //list<ProjectTeamMember__c> lProjectTeamMembers = [select Contact__c from ProjectTeamMember__c where Project__c = :oProject.Id and ProjectRole__c <> :pmID];
        list<ProjectTeamMember__c> lProjectTeamMembers = [select Contact__c from ProjectTeamMember__c where Project__c = :oProject.Id and ProjectRole__c IN :roleset];

        set<id> sPTMids = new set<id>();
        for(ProjectTeamMember__c ptm:  lProjectTeamMembers){
            sPTMids.add(ptm.id);
        }

        if(sPTMids.size() > 0){
            list<InductedProjectTeamMembers__c> lstIPTM = [select id from InductedProjectTeamMembers__c where ProjectTeamMember__c IN: sPTMids];

            if(lstIPTM.size() > 0){
                try{
                    ECO_ProjectTriggers.run = false;
                    delete lstIPTM;
                    ECO_ProjectTriggers.run = true;
                } catch( Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, 'An error has occurred while attempting to delete project team members. Please contact your administrator.');
                }
            }
                
        }

        System.debug('lProjectTeamMembers to delete::::' + lProjectTeamMembers);
        delete lProjectTeamMembers;

        //Insert Key Members from primary 
        OrganizationString__c orgToUpdate = [SELECT Id, Name, OrganizationName__c, CurrencyIsoCode, GeographyName__c, 
                                                    Region__c, District__c, Department__c, BusinessLineName__c, 
                                                    LocationName__c, PLManagerContact__c, Project_Owning_Text__c, 
                                                    ProjectOwning__c, FinanceandAccountingManagerContact__c, 
                                                    CFOorDelegateContact__c, OUID__c, ProjectApprover__c, 
                                                    ProjectAccountant__c, ProjectAccountant2__c, 
                                                    FinanceLead2__c, GoNoGoApprover__c 
                                               FROM OrganizationString__c 
                                              Where id=:sSelectedOrganizationId];
        list<ProjectTeamMember__c> listProjectTeamMemberToInsert = new list<ProjectTeamMember__c>();
        
        if(mapProjectRole.containskey('Project Approver') && orgToUpdate.ProjectApprover__c != null){
            id auth2ID = mapProjectRole.get('Project Approver').id;
            id contactID = orgToUpdate.ProjectApprover__c;

            listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));

            oProjectToUpdate.ProjectApprover__c = contactID;
        } else {
            oProjectToUpdate.ProjectApprover__c = null;
        } 

        if(mapProjectRole.containskey('Project Approver 2') && orgToUpdate.PLManagerContact__c != null){
            id auth2ID = mapProjectRole.get('Project Approver 2').id;
            id contactID = orgToUpdate.PLManagerContact__c;

            listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));

            oProjectToUpdate.PnLManager__c = contactID;
            //System.debug('oProject.PnLManager__c::::' + contactID);
        }  else {
            oProjectToUpdate.PnLManager__c = null;
        } 
        
        if(mapProjectRole.containskey('Finance Lead') && orgToUpdate.FinanceandAccountingManagerContact__c != null){
            id auth2ID = mapProjectRole.get('Finance Lead').id;
            id contactID = orgToUpdate.FinanceandAccountingManagerContact__c;

            listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
            oProjectToUpdate.FinanceLead__c = contactID;
        } else {
            oProjectToUpdate.FinanceLead__c = null;
        } 

        if(mapProjectRole.containskey('CFO or Delegate') && orgToUpdate.CFOorDelegateContact__c != null){
            id auth2ID = mapProjectRole.get('CFO or Delegate').id;
            id contactID = orgToUpdate.CFOorDelegateContact__c;

            listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
        }

        if(mapProjectRole.containskey('Project Accountant') && orgToUpdate.ProjectAccountant__c != null){
            id auth2ID = mapProjectRole.get('Project Accountant').id;
            id contactID = orgToUpdate.ProjectAccountant__c;

            listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
        }

        if(mapProjectRole.containskey('Project Accountant 2') && orgToUpdate.ProjectAccountant2__c != null){
            id auth2ID = mapProjectRole.get('Project Accountant 2').id;
            id contactID = orgToUpdate.ProjectAccountant2__c;

            listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
        }

        if(mapProjectRole.containskey('Finance Lead 2') && orgToUpdate.FinanceLead2__c != null){
            id auth2ID = mapProjectRole.get('Finance Lead 2').id;
            id contactID = orgToUpdate.FinanceLead2__c;

            listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
        }  

        if(mapProjectRole.containskey('Go/No Go Approver') && orgToUpdate.GoNoGoApprover__c != null){
            id auth2ID = mapProjectRole.get('Go/No Go Approver').id;
            id contactID = orgToUpdate.GoNoGoApprover__c;

            listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
            oProjectToUpdate.GoNoGoApprover__c = contactID;
        } else{
            oProjectToUpdate.GoNoGoApprover__c = null;
        }

        if(listProjectTeamMemberToInsert.size() > 0){
            ECO_ProjectTriggers.run = false;
            insert listProjectTeamMemberToInsert;
            ECO_ProjectTriggers.run = true;
        }
        
        //update oProject;     

        try{
            update oProjectToUpdate;
        }catch(EcoControllerException oException){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
            Database.rollback(oSavePoint);

            return null;
        }


        //***END UPDATE KEY MEMBER

        //Update Project to reflect changes
        oProject = ECO_Service_Projects.getProjectById(oProject.Id);
        lSelectedOrganizations = oProject.ProjectOrganizations__r;

        isValid(true);
        return null;
    }

    public PageReference SelectSecondary(){

        if(oProject.CarryingOutOrganization__c == sSelectedOrganizationId && oProject.OracleSyncStatus__c=='S' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot set Primary Org as Secondary'));
            return null;
        }


        Savepoint oSavePoint = Database.setSavepoint();

        Integer OppUpdateProceed = 0;

        //Check if entry already exists
        list<ProjectOrganization__c> lProjectOrganizationsToMakeSecondary = new list<ProjectOrganization__c>([SELECT Id
                                                            FROM ProjectOrganization__c
                                                            WHERE Project__c = :oProject.Id and OrganizationString__c = :sSelectedOrganizationId]);

        ProjectOrganization__c oProjectOrganizationToInsert = new ProjectOrganization__c(Project__c = oProject.Id, OrganizationString__c = sSelectedOrganizationId, Type__c = 'Supporting');

        if(lProjectOrganizationsToMakeSecondary.size() > 0){
            for(ProjectOrganization__c oProjectOrganization : lProjectOrganizationsToMakeSecondary){
                oProjectOrganization.Type__c = 'Supporting';
            }

            try{
                update lProjectOrganizationsToMakeSecondary;
                OppUpdateProceed = 1;
            }catch(EcoControllerException oException){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                Database.rollback(oSavePoint);

                return null;
            }
        }else{
            //ProjectOrganization__c oProjectOrganizationToInsert = new ProjectOrganization__c(Project__c = oProject.Id, OrganizationString__c = sSelectedOrganizationId, Type__c = 'Supporting');

            try{
                insert oProjectOrganizationToInsert;
                OppUpdateProceed = 1;
            }catch(EcoControllerException oException){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                Database.rollback(oSavePoint);

                return null;
            }
        }

        //Update project to reflect if organization is currently primary
        if(oProject.CarryingOutOrganization__c == sSelectedOrganizationId){
            //pse__Proj__c oProjectToUpdate = new pse__Proj__c(Id = oProject.Id, PrimaryOrganization__c = null);
            pse__Proj__c oProjectToUpdate = new pse__Proj__c(Id = oProject.Id, CarryingOutOrganization__c = null);

            try{
                update oProjectToUpdate;
            }catch(EcoControllerException oException){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                Database.rollback(oSavePoint);

                return null;
            }
        }


        /******OPPORTUNITY UPDATES******/
        if (OppUpdateProceed == 1)
        {
            System.debug('inside ' + 'oppUpdateProceed');
            //PREPARING THE AECOM_Primary_Department__c MAP.
            //Prepare and populate the set of orgstring ids
            Set<Id> setOrgStringIds = new Set<Id>();
            for (ProjectOrganization__c orgString : lSelectedOrganizations)
            {
                setOrgStringIds.add(orgString.OrganizationString__c);
                //System.debug('orgString.OrganizationString__c: ' + orgString.OrganizationString__c);
            }
            //Prepare and populate the list of orgstrings
            List<OrganizationString__c> lstOrgStrings = new list<OrganizationString__c>();
            try
            {
                lstOrgStrings = [select Id, OrganizationName__c from OrganizationString__c where Id IN :setOrgStringIds];
            }
            catch( Exception e){
                ECO_Service_ErrorLog.logException(e);
            }
            //Populate the set of org string names
            Set<string> sOrgNames = new set<string>();
            for(OrganizationString__c os : lstOrgStrings)
            {
                sOrgNames.add(os.OrganizationName__c);
                //System.debug('os.OrganizationName__c: ' + os.OrganizationName__c);
            }                      

            list<AECOM_Primary_Department__c> lstAPD = new list<AECOM_Primary_Department__c>();
            try
            {
                lstAPD = [SELECT ID, Org_String__c FROM AECOM_Primary_Department__c  WHERE Org_String__c IN:sOrgNames];
            } catch( Exception e)
            {
                ECO_Service_ErrorLog.formatPageError(e, 'Error while searching for AECOM Primary Department during CreateOpportunity: ' + e.getMessage());
            }
            Map<string, AECOM_Primary_Department__c> mapAPD = new map<string, AECOM_Primary_Department__c>();  
            for(AECOM_Primary_Department__c APD:lstAPD){
                mapAPD.put(APD.Org_String__c, APD);
                //System.debug('APD.Org_String__c: ' + APD.Org_String__c);
            }                

            //PREPARING THE Org String Map
            List<ProjectOrganization__c> lProjectOrganizations = new List<ProjectOrganization__c>();
            try
            {
                lProjectOrganizations = [SELECT Id, OrganizationString__c FROM ProjectOrganization__c 
                                         WHERE Project__c = :oProject.Id and 
                                         OrganizationString__c IN :setOrgStringIds];
            }
            catch( Exception e){
                ECO_Service_ErrorLog.logException(e);
            }
            Map<Id, string> mapOrgStrings = new Map<Id, string>();
            for (ProjectOrganization__c p : lProjectOrganizations)
            {
                OrganizationString__c orgstr = [SELECT Id, OrganizationName__c FROM OrganizationString__c WHERE Id =: p.OrganizationString__c];
                mapOrgStrings.put((Id)p.OrganizationString__c, orgstr.OrganizationName__c);
            }

            Opportunity oOpp = null;
            try
            {
                oOpp = [select id, Name, AECOM_Primary_Dept_Lookup__c, AECOM_Primary_Department_Percent__c, StageName from Opportunity where id=: oProject.pse__Opportunity__c];
            }
            catch( Exception e)
            {
                ECO_Service_ErrorLog.logException(e);
            }            
            //System.debug('oOpp.Name ' + oOpp.Name);

            list<Opportunity_Department__c> lstOppDToInsert = new list<Opportunity_Department__c>();

            Opportunity_Department__c oOpportunityDepartmentToInsert = new Opportunity_Department__c();

            if(oProjectOrganizationToInsert.Type__c == 'Supporting')
            {
                System.debug('inside supporting ' + oOpp.Name);
                //Do the SOQL to get the organization name.
                OrganizationString__c orgSelect = null;
                try
                {
                    orgSelect = [Select Id, OrganizationName__c From OrganizationString__c Where Id =: oProjectOrganizationToInsert.OrganizationString__c];
                }
                catch(Exception e)
                {
                    ECO_Service_ErrorLog.logException(e);
                }
                String orgNameSelect = orgSelect.OrganizationName__c;
                //System.debug('orgNameSelect : ' + orgNameSelect);
                //At this point, we want to do a check to see if the AECOM Primary Object contains this org.

                list<AECOM_Primary_Department__c> primarySelectList = 
                //AECOM_Primary_Department__c primarySelect = 
                    [Select Id, Org_String__c From AECOM_Primary_Department__c 
                     Where Org_String__c = :orgNameSelect Limit 1];
                    
                //if (primarySelect != null)
                if (primarySelectList.size() > 0)
                {
                    //System.debug('primarySelect.Id : ' + primarySelect.Id);
                    oOpportunityDepartmentToInsert.Primary__c = false;
                    //oOpportunityDepartmentToInsert.AECOM_Department__c = supportingDepartments[0].Id;    

                    oOpportunityDepartmentToInsert.AECOM_Department__c = primarySelectList[0].Id;      
                    //oOpportunityDepartmentToInsert.AECOM_Department__c = primarySelect.Id;                     
                }

                if (oOpportunityDepartmentToInsert != null){
                    //System.debug('oProjectOrganizationToInsert.ContributionPercent__c : ' + oProjectOrganizationToInsert.ContributionPercent__c);
                    //System.debug('oOpp.id : ' + oOpp.id);

                    oOpportunityDepartmentToInsert.split__c = oProjectOrganizationToInsert.ContributionPercent__c;
                    oOpportunityDepartmentToInsert.Opportunity__c = oOpp.id;//oOpportunityToInsert.id;

                    //Check to make sure if it doesnt already exist in Opp Departments.
                    Integer DuplicateCheck = 0;
                    try
                    {
                        DuplicateCheck = [Select Count() From Opportunity_Department__c 
                                            Where Opportunity__c = :oOpp.id And AECOM_Department__c = :oOpportunityDepartmentToInsert.AECOM_Department__c];
                    }
                    catch (Exception e)
                    {
                        ECO_Service_ErrorLog.logException(e);
                    }

                    if (DuplicateCheck == 0)
                    {
                        lstOppDToInsert.add(oOpportunityDepartmentToInsert);
                    }
                } 
            } 

            if(lstOppDToInsert.size() > 0)
            {
                try
                {
                    insert lstOppDToInsert;
                    //System.debug('Passed opp department insert ');
                } 
                catch( Exception e)
                {
                    ECO_Service_ErrorLog.formatPageError(e, 'Error while inserting opportunities departments for CreateOpportunity: ' + e.getMessage());
                    //System.debug('e.getMessage() ' + e.getMessage());
                }            
            }            

            OppUpdateProceed = 0;
        }

        //Update Project to reflect changes
        oProject = ECO_Service_Projects.getProjectById(oProject.Id);
        lSelectedOrganizations = oProject.ProjectOrganizations__r;

        isValid(true);
        return null;
    }
}