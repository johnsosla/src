/** ---------------------------------------------------------------------------------------
 * @Description <Project Setup wizard><br/>
 * <Tabbed guidandance for selecting client(s), split, opportunity and finally creating the project.>
 *
 * @Author NTT Data/AECOM - 
 * @Date May 2016 - Adding show more to Opportunity selection tab
 *----------------------------------------------------------------------------------------*/
public without sharing class ECO_ProjectSetupController {

    public list<Project_Site__c> lstProjectSites { get; set; }
    public list<SiteWrapper> lstSites { get; set; }
    public list<SelectOption> loOpportunities { get; set; }
    public list<Site__c> lstSitesSearchResults { get; set; }
    public list<pse__Proj__c> listSimilarProjects { get; set; }
    public list<opportunity> lstSearchOpportunities { get; set; }

    public list<OrganizationString__c> lOrganizations { get; set; }
    public list<OrganizationString__c> lUserOrganizations { get; set; }
    public list<OrganizationWrapper> lSelectedOrganizations { get; set; }
    public list<SelectOption> loGeographies { get; set; }
    public list<SelectOption> loRegions { get; set; }
    public list<SelectOption> loDistricts { get; set; }
    public list<SelectOption> loBusinessLines { get; set; }
    public list<SelectOption> loDepartments { get; set; }
    public list<SelectOption> loLocations { get; set; }

    public list<SelectOption> loProjOwnings { get; set; }
    public list<oppClone> lstOppClone { get; set; }

    public map<id, SiteWrapper> mapSites { get; set; }
    public map<id, SiteWrapper> mapSitesBilling { get; set; }
    public map<id, SiteWrapper> mapSitesEnd { get; set; }
    public map<id, Site__c> mapSearchSites { get; set; }
    public map<string, Site__c> mapUniqueSites { get; set; }
    public map<id, opportunity> mapOpportunitySearch { get; set; }
    public map<id, OrganizationWrapper> mapOrganizationIdToProjectOrganization { get; set; }
    public map<id, OrganizationString__c> mapOrganizationString { get; set; }

    public pse__Proj__c oProject { get; set; }
    public Site__c oSite { get; set; }
    public siteSearchWrapper oSiteSearch { get; set; }
    public ProjectOrganization__c oProjectOrganization { get; set; }
    public OrganizationString__c oPrimaryOrganization { get; set; }

    public id idSiteID { get; set; }
    public integer iSiteRowDelete { get; set; }
    public id sSelectedOpportunityId { get; set; }
    public string strSearchResults { get; set; }
    public string sOrganizationName { get; set; }
    public string sGeographyName { get; set; }
    public string sRegion { get; set; }
    public string sDistrict { get; set; }
    public string sBusinessLine { get; set; }
    public string sDepartment { get; set; }

    public string oDepartment { get; set; }
    public string oDepartmentOrgName { get; set; }

    public string sLocation { get; set; }
    public string sProjOwning { get; set; }
    public string sSelectedOrganizationId { get; set; }
    public string tabState { get; set; }

    public OrganizationString__c userOrg { get; set; }

    public boolean boolShowSiteSearch { get; set; }
    public boolean booDisplaySiteSearchResult { get; set; }
    public boolean booDisplayOpportunitySearch { get; set; }
    public boolean booShowProjectInput { get; set; }
    public boolean boolNameAttempted { get; set; }
    public boolean bSearchInProgress { get; set; }
    public boolean bProjectFilled { get; set; }
    public boolean bOppSelected { get; set; }
    public boolean bSearchOutsideUserOrg { get; set; }
    public boolean bOpportunityProgramSelected { get; set; }
    public boolean bLinkedToProject { get; set; }

    public string oppName { get; set; }
    public string oppProjectCountryName { get; set; }
    public List<SelectOption> projCountryOptions { get; set; }

    public Integer intNumIsBilling;
    public Integer intNumIsEnd;

    private SiteWrapper oTopTask;
    public SiteWrapper oPrimaryEnd { get; set; }
    public SiteWrapper oPrimaryEnd1 { get; set; }

    private string lastSaveAttemptName;

    private String sSiteLimit;
    private Integer iOrgLimit;
    private Integer iOppLimit;

    private boolean bSiteMore;
    private boolean bOrgMore;
    private boolean bOppMore;

    public boolean bShowMoreButtonSite { get; set; }
    public boolean bShowMoreButtonOrg { get; set; }
    public boolean bShowMoreButtonOpp { get; set; }

    public String showMoreSiteText { get; set; }
    public String showMoreOrgText { get; set; }
    public String showMoreOppText { get; set; }

    private static string siteLessLIMIT = '50';
    private static string siteMoreLIMIT = '200';

    private static integer orgLessLIMIT = 20;
    private static integer orgMoreLIMIT = 200;

    private static integer oppLessLIMIT = 50;
    private static integer oppMoreLIMIT = 300;

    public boolean tab2enabled { get; set; }

    public map<id, recordtype> mapOppRecType { get; set; }
    public List<SelectOption> opportunityRecType { get; set; }
    public string idSelectedOppRecType { get; set; }
    public string sSelectedOppRecType { get; set; }

    public string siteSearchResultMsg { get; set; }

    //3818
    public boolean lSelectedOrganizationsPrimaryNotFound { get; set; }
    public string lSelectedOrganizationsPrimaryNotFoundWarning { get; set; }
    public string lSelectedOrganizationsPrimaryNotFoundList { get; set; }

    public Boolean createNewOppDisabled { get; set; }

    public Boolean searchResults { get; set; }





    public void changeRegion()
    {
        if (idSelectedOppRecType != null)
        {
            createNewOppDisabled = false;
        }
        else
        {
            createNewOppDisabled = true;
        }
    }

    /* Custom classes to facilitate this controller */
    public class EcoControllerException extends Exception { }

    /* Custom Class used to add more options for the sites object */
    public class SiteWrapper {
        public Site__c oSite { get; set; }
        public String strType { get; set; }
        public string billingContact { get; set; }
        public integer contributions { get; set; }

        public boolean booIsBilling { get; set; }
        public boolean booIsDefaultTopTask { get; set; }
        public boolean booIsEnd { get; set; }
        public boolean booIsPrimaryEnd { get; set; }
        public map<string, string> oidmap { get; set; }

        public list<SelectOption> contacts { get; set; }

        public SiteWrapper(Site__c oTargetSite) {
            String oracleId;
            this.oSite = oTargetSite;
            booIsBilling = false;
            booIsDefaultTopTask = false;
            booIsEnd = false;
            booIsPrimaryEnd = false;

            contacts = new List<SelectOption> ();

            oidmap = new map<string, string> ();

            for (contact c :[select id, lastname, firstname, Oracle_ID__c from contact where site__c = :oTargetSite.id]) {
                oracleId = c.Oracle_ID__c != null ? c.Oracle_ID__c : 'NotInOracle';
                contacts.add(new SelectOption(oracleId, c.lastname + ', ' + c.firstname));
                oidmap.put(oracleId, c.id);
            }

            contributions = 0;

        }
    }

    /* Custom Class used to add more options for the organization object */
    public class OrganizationWrapper {
        public OrganizationString__c oOrganization { get; set; }
        public ProjectOrganization__c oProjectOrganization { get; set; }
        public String strType { get; set; }
        public integer ContributionPercent { get; set; }


        public OrganizationWrapper(OrganizationString__c oTargetOrganization) {
            this.oOrganization = oTargetOrganization;
            oProjectOrganization = new ProjectOrganization__c();
        }
    }

    public class oppClone {
        public string id { get; set; }
        public string acctName { get; set; }
        public string oppName { get; set; }
        public string oppNumber { get; set; }
        public string stage { get; set; }
        public string type { get; set; }
        public string value { get; set; }
        public string capManager { get; set; }
        public string organization { get; set; }
        public string createdDate { get; set; }
        public string AECOMrole { get; set; }
        public string PrimaryDepartment { get; set; }
        public string BusinessUnit { get; set; }
        public string Geography { get; set; }
        public string LeadRegion { get; set; }
        public string LeadDistrict { get; set; }
        public string SubPracticeArea { get; set; }
        public string GrossAECOMrevenue { get; set; }
        public string SubOtherRevenue { get; set; }
        public string NetRevenue { get; set; }
        public string CreatedByName { get; set; }
    }


    private void showMoreSites() {
        showMoreSiteText = 'Show Less';
        sSiteLimit = siteMoreLIMIT;
        bSiteMore = true;
    }

    private void showLessSites() {
        showMoreSiteText = 'Show More';
        sSiteLimit = siteLessLIMIT;
        bSiteMore = false;
    }

    private void showMoreOrg() {
        showMoreOrgText = 'Show Less';
        iOrgLimit = orgMoreLIMIT;
        bOrgMore = true;
    }

    private void showLessOrg() {
        showMoreOrgText = 'Show More';
        iOrgLimit = orgLessLIMIT;
        bOrgMore = false;
    }

    private void showMoreOpp() {
        showMoreOppText = 'Show Less';
        iOppLimit = oppMoreLIMIT;
        bOppMore = true;
    }

    private void showLessOpp() {
        showMoreOppText = 'Show More';
        iOppLimit = oppLessLIMIT;
        bOppMore = false;
    }

    public void toggleSiteShow() {
        If (bSiteMore) {
            showLessSites();
            SearchSites();
        } else {
            showMoreSites();
            SearchSites();
        }
    }

    public void toggleOrgShow() {
        If (bOrgMore) {
            showLessOrg();
            SearchOrganizations();
        } else {
            showMoreOrg();
            SearchOrganizations();
        }
    }

    public void toggleOppShow() {
        If (bOppMore) {
            showLessOpp();
            SearchOpportunities();
        } else {
            showMoreOpp();
            SearchOpportunities();
        }
    }

    public class siteSearchWrapper {
        public string name { get; set; }
        public string city { get; set; }
        public string country { get; set; }
        public string province { get; set; }

        public siteSearchWrapper() {
            name = null;
            city = null;
            country = null;
            province = null;
        }

    }

    /* Constructor */
    public ECO_ProjectSetupController(ApexPages.StandardController oStandardController) {
        oSite = new Site__c();
        oSite.account__r = new account();
        oSiteSearch = new siteSearchWrapper();

        //3818
        lSelectedOrganizationsPrimaryNotFound = determinePrimaryWarning();
        lSelectedOrganizationsPrimaryNotFoundWarning = 'Warning:  One or more of the selected Organizations could not be added to the Opportunity record.  Contact your licensed CRM administrator to add the Organizations to the Opportunity record.<br/><br/>The following organization(s) did not transfer:';
        lSelectedOrganizationsPrimaryNotFoundList = '';

        oProjectOrganization = new ProjectOrganization__c();

        this.oProject = (pse__Proj__c) oStandardController.getRecord();


        oTopTask = null;
        oPrimaryEnd = null;

        ResetValues();

        //lSelectedOrganizations = oProject.ProjectOrganizations__r;

        sOrganizationName = '';
        sGeographyName = '';
        sRegion = '';
        sDistrict = '';
        sBusinessLine = '';
        sDepartment = '';

        oDepartment = '';

        sLocation = '';
        sProjOwning = '';

        sSelectedOrganizationId = '';
        bSearchInProgress = false;
        bSearchOutsideUserOrg = false;
        tab2enabled = false;
        //isValid();
        //SearchOrganizations();

        lSelectedOrganizations = new list<OrganizationWrapper> ();
        lUserOrganizations = new list<OrganizationString__c> ();
        mapOrganizationString = new map<id, OrganizationString__c> ();
        mapOrganizationIdToProjectOrganization = new map<id, OrganizationWrapper> ();
        lstSites = new list<SiteWrapper> ();
        loOpportunities = new list<SelectOption> ();
        mapSites = new map<id, SiteWrapper> ();
        mapSitesBilling = new map<id, SiteWrapper> ();
        mapSitesEnd = new map<id, SiteWrapper> ();
        mapSearchSites = new map<id, Site__c> ();
        lstOppClone = new list<oppClone> ();
        tabState = 'name1';
        bProjectFilled = false;
        bOppSelected = false;
        bOpportunityProgramSelected = false;

        sSiteLimit = siteLessLIMIT;
        iOrgLimit = orgLessLIMIT;
        iOppLimit = oppLessLIMIT;

        bSiteMore = false;
        bOrgMore = false;
        bOppMore = false;

        bShowMoreButtonSite = false;
        bShowMoreButtonOrg = false;
        bShowMoreButtonOpp = false;

        showMoreSiteText = 'Show More';
        showMoreOrgText = 'Show More';
        showMoreOppText = 'Show More';

        oppName = null;

        mapOppRecType = new map<id, recordtype> ();
        opportunityRecType = new List<SelectOption> ();
        sSelectedOppRecType = '';

        opportunityRecType.add(new SelectOption('', 'None'));
        for (recordtype r :[select id, name from recordtype where SobjectType = 'Opportunity']) {
            opportunityRecType.add(new SelectOption(r.id, r.name));
            mapOppRecType.put(r.id, r);
        }

        idSelectedOppRecType = null;

        populateOppProjectCountryList();
        oppProjectCountryName = null;

        createNewOppDisabled = true;

        bLinkedToProject = false;

        SearchOrganizations();
        SearchUserOrganization();
    }

    public void SearchUserOrganization() {
        list<user> lUser = [SELECT ECO_OrganizationName__c FROM User WHERE ID = :UserInfo.getUserId()];

        lUserOrganizations = [SELECT Id, Name, OrganizationName__c, GeographyName__c, Region__c, 
                                     District__c, Department__c, BusinessLineName__c, LocationName__c, 
                                     GoNoGoApprover__c, PLManagerContact__c, ProjectOwning__c, 
                                     FinanceandAccountingManagerContact__c, CFOorDelegateContact__c, OUID__c, 
                                     CurrencyIsoCode, ProjectApprover__c, ProjectAccountant__c, ProjectAccountant2__c, 
                                     FinanceLead2__c, ProjectBiller__c 
                                FROM OrganizationString__c 
                                WHERE Name = :lUser[0].ECO_OrganizationName__c and(InactiveDate__c > TODAY OR InactiveDate__c = null)];

        if (lUserOrganizations.size() > 0) {
            userOrg = lUserOrganizations[0];
        } else {
            userOrg = null;
        }

        for (OrganizationString__c SearchOrganiation : lUserOrganizations) {
            mapOrganizationString.put(SearchOrganiation.id, SearchOrganiation);
        }
    }


    /* Executes the request to handle dynamics parameters and query Sites */
    public PageReference SearchSites() {

        ResetValues();

        if ((userOrg == null || userOrg.OUID__c == null) && bSearchOutsideUserOrg == false) {
            return null;
        }

        oSite.Account__r.name = oSiteSearch.name;
        oSite.City__c = oSiteSearch.city;
        oSite.Country__c = oSiteSearch.country;
        oSite.State__c = oSiteSearch.province;

        recordtype rtOO = [select id from recordtype where developername = 'Oracle_Only'];
        string oracleRTFilter = rtOO.id;
        string strSOQL = 'SELECT ';
        string strSOQLCount = 'SELECT ';
        string strWhereClause = ' WHERE ';
        boolean boolAtLeastOne = false;

        for (Schema.FieldSetMember fsmField : SObjectType.Site__c.FieldSets.pse_ClientFinder_Search_Result_Fieldset.getFields()) {
            strSOQL += fsmField.getFieldPath() + ', ';
        }

        strSOQL += 'ID, Account__c, CustomerSiteUseCode__c, OUID__c, name, Account__r.Account_Manager__r.Employee_ID__c, Account__r.Client_Account_Manager_CAM__r.ContactId FROM Site__c';
        strSOQLCount += 'COUNT() FROM Site__c';
        //strSOQL += 'ID, Account__c, CustomerAccountSiteID__c, OracleCustomerID__c, CustomerSiteUseCode__c, OUID__c, name, Account__r.Account_Manager__r.Employee_ID__c FROM Site__c';

        for (Schema.FieldSetMember fsmField : SObjectType.Site__c.FieldSets.pse_ClientFinder_Search_Fieldset.getFields()) {

            // Only add parameters to the "WhereClause" string if they contain valid values. 
            // NOTE: only strings are supported by this code.
            if (recursiveGet(oSite, fsmField.getFieldPath()) != null && recursiveGet(oSite, fsmField.getFieldPath()) != '') {
                strWhereClause += fsmField.getFieldPath() + ' LIKE \'%' + recursiveGet(oSite, fsmField.getFieldPath()) + '%\' AND ';
                boolAtLeastOne = true;
            }
        }

        // Determines if the code found at least one non-null/non-blank search parameter. If so, manipulate the "where string" to strip the last " AND " text
        // and add it to the SOQL statement.
        if (boolAtLeastOne) {
            strWhereClause = strWhereClause.substring(0, strWhereClause.length() - 5);
            strSOQL += strWhereClause;
            strSOQLCount += strWhereClause;
        }

        //strWhereClause += ' and  SiteStatus__c = \'A\'';
        //strSOQL += ' and  SiteStatus__c = \'A\'';
        //strSOQLCount += ' and  SiteStatus__c = \'A\'';

        if (bSearchOutsideUserOrg) {
            if (boolAtLeastOne) {
                strSOQL += ' and  SiteStatus__c = \'A\' and Account__r.recordtypeid !=: oracleRTFilter and VendorSiteID__c = null ORDER BY Account__r.name ASC  LIMIT ' + sSiteLimit;
                strSOQLCount += 'and  SiteStatus__c = \'A\' and Account__r.recordtypeid !=: oracleRTFilter and VendorSiteID__c = null LIMIT 10000';
            } else {
                strSOQL += ' WHERE Account__r.recordtypeid !=: oracleRTFilter and  SiteStatus__c = \'A\' and VendorSiteID__c = null  ORDER BY Account__r.name ASC  LIMIT ' + sSiteLimit;
                strSOQLCount += ' WHERE Account__r.recordtypeid !=: oracleRTFilter and  SiteStatus__c = \'A\' and VendorSiteID__c = null  LIMIT 10000';
            }
        } else {

            string userOrgID = userOrg.OUID__c;

            if (boolAtLeastOne) {
                strSOQL += ' and  SiteStatus__c = \'A\' AND OUID__c =: userOrgID and Account__r.recordtypeid !=: oracleRTFilter and VendorSiteID__c = null  ORDER BY Account__r.name ASC  LIMIT ' + sSiteLimit;
                strSOQLCount += 'and  SiteStatus__c = \'A\' AND OUID__c =: userOrgID and Account__r.recordtypeid !=: oracleRTFilter and VendorSiteID__c = null  LIMIT 10000';
            } else {
                strSOQL += ' WHERE OUID__c =: userOrgID and  SiteStatus__c = \'A\' and Account__r.recordtypeid !=: oracleRTFilter and VendorSiteID__c = null  ORDER BY Account__r.name ASC  LIMIT ' + sSiteLimit;
                strSOQLCount += ' WHERE OUID__c =: userOrgID and  SiteStatus__c = \'A\' and Account__r.recordtypeid !=: oracleRTFilter and VendorSiteID__c = null  LIMIT 10000';
            }
        }



        lstSitesSearchResults = (list<Site__c>) Database.query(strSOQL);

        Integer lstSitesSearchResultsCount = Database.countQuery(strSOQLCount);

        IF (lstSitesSearchResults.size() < integer.valueof(siteLessLIMIT)) {
            bShowMoreButtonSite = false;
        } else {
            bShowMoreButtonSite = true;
        }

        IF (lstSitesSearchResultsCount > integer.valueof(siteMoreLIMIT) && sSiteLimit == siteMoreLIMIT)
        {
            siteSearchResultMsg = 'There are more than ' + siteMoreLIMIT + ' entries which match your search criteria. However, results displayed here are limited to ' + siteMoreLIMIT + ' for any single search. Please input additional information into the search parameters to refine the search results.';
        }
        else
        {
            siteSearchResultMsg = '';
        }
        //else
        //{
        //siteSearchResultMsg = 'Number of entries returned are ' + lstSitesSearchResultsCount;   
        //}

        booDisplaySiteSearchResult = true;

        /*if(lstSitesSearchResults.size() > 0) {
         
          map<string, Site__c> mapUniqueSites = new map<string, Site__c>();
          mapSearchSites = new map<id, Site__c>();
          list<Site__c> nullSearchSites = new list<site__c>();

          for (Site__c oSearchSite: lstSitesSearchResults){
          if(oSearchSite.OracleCustomerID__c == null || oSearchSite.CustomerAccountSiteID__c == null ){
          mapSearchSites.put(oSearchSite.id, oSearchSite);
          nullSearchSites.add(oSearchSite);
          } else {
          if(mapUniqueSites.containskey(oSearchSite.OracleCustomerID__c + '-' + oSearchSite.CustomerAccountSiteID__c)){
          if(oSearchSite.CustomerSiteUseCode__c == 'BILL_TO') {
          mapSearchSites.put(oSearchSite.id, oSearchSite);
          mapUniqueSites.put(oSearchSite.OracleCustomerID__c + '-' + oSearchSite.CustomerAccountSiteID__c, oSearchSite);
          }
          } else {
          mapSearchSites.put(oSearchSite.id, oSearchSite);
          mapUniqueSites.put(oSearchSite.OracleCustomerID__c + '-' + oSearchSite.CustomerAccountSiteID__c, oSearchSite);
          }
          }
          }

          lstSitesSearchResults = mapUniqueSites.values();

          if(nullSearchSites.size() >0){
          lstSitesSearchResults.addall(nullSearchSites);
          }


          }*/


        /*if(lstSitesSearchResults.size() > 0){
         
          mapSearchSites = new map<id, Site__c>();

          for (Site__c oSearchSite: lstSitesSearchResults){
          mapSearchSites.put(oSearchSite.id, oSearchSite);
          }
          }*/

        mapSearchSites = new map<id, Site__c> ();
        if (lstSitesSearchResults.size() > 0) {
            for (Site__c oSearchSite : lstSitesSearchResults) {
                mapSearchSites.put(oSearchSite.id, oSearchSite);
            }
        }


        //strSearchResults = string.valueof(lstSitesSearchResults.size()) + ' Record(s) Found';

        //lstSites = new list<SiteWrapper>();
        //mapSites = new map<id, SiteWrapper>();
        lstSearchOpportunities = new list<Opportunity> ();






        return null;
    }



    public PageReference RemoveSite() {
        lstSites.remove(iSiteRowDelete);
        return null;
    }


    public PageReference SelectSite() {

        if (!mapSites.containskey(idSiteID)) {
            SiteWrapper oSite = new SiteWrapper(mapSearchSites.get(idSiteID));
            mapSites.put(idSiteID, oSite);
            lstSites.add(oSite);
        }

        if (lstSites.size() == 1) {
            lstSites[0].booIsPrimaryEnd = true;
            lstSites[0].booIsBilling = true;
            lstSites[0].booIsEnd = true;
            lstSites[0].booIsDefaultTopTask = true;
            lstSites[0].contributions = 100;

            oPrimaryEnd = lstSites[0];
            oPrimaryEnd1 = lstSites[0];
            oTopTask = lstSites[0];

            mapSitesEnd.put(idSiteID, lstSites[0]);
            mapSitesBilling.put(idSiteID, lstSites[0]);

            //SearchOpportunities();

        }

        SearchOpportunities();
        tabState = 'name1';
        return null;
    }


    public PageReference BillingSelect() {
        for (SiteWrapper oSiteWrapper : lstSites) {
            if (oSiteWrapper.oSite.id == idSiteID) {
                if (oSiteWrapper.booIsBilling) {
                    mapSitesBilling.put(idSiteID, oSiteWrapper);
                } else {
                    mapSitesBilling.remove(idSiteID);
                    oSiteWrapper.booIsDefaultTopTask = false;
                    oTopTask = null;
                }
            }
        }

        if (oTopTask == null && mapSitesBilling.size() > 0) {
            mapSitesBilling.values() [0].booIsDefaultTopTask = true;
            oTopTask = mapSitesBilling.values() [0];
        }

        return null;
    }

    public PageReference EndSelect() {
        for (SiteWrapper oSiteWrapper : lstSites) {
            if (oSiteWrapper.oSite.id == idSiteID) {
                if (oSiteWrapper.booIsEnd) {
                    mapSitesEnd.put(idSiteID, oSiteWrapper);
                } else {
                    mapSitesEnd.remove(idSiteID);
                    oSiteWrapper.booIsPrimaryEnd = false;
                    oPrimaryEnd = null;
                }
            }
        }

        if (oPrimaryEnd == null && mapSitesEnd.size() > 0) {
            mapSitesEnd.values() [0].booIsPrimaryEnd = true;
            oPrimaryEnd = mapSitesEnd.values() [0];
            oPrimaryEnd1 = mapSitesEnd.values() [0];
            idSiteID = oPrimaryEnd.oSite.id;
            //SearchOpportunities();
        }

        if (mapSitesEnd.size() == 0) {
            lstSearchOpportunities = null;
            strSearchResults = null;
            booDisplayOpportunitySearch = false;
        }

        return null;
    }


    public PageReference DefaultTopSelect() {

        for (SiteWrapper oSiteWrapper : lstSites) {
            if (oSiteWrapper.oSite.id == idSiteID) {
                oSiteWrapper.booIsDefaultTopTask = true;
                oTopTask = oSiteWrapper;
            } else {
                oSiteWrapper.booIsDefaultTopTask = false;
            }
        }

        return null;
    }


    public PageReference PrimaryEndSelect() {

        for (SiteWrapper oSiteWrapper : lstSites) {
            if (oSiteWrapper.oSite.id == idSiteID) {
                oSiteWrapper.booIsPrimaryEnd = true;
                oPrimaryEnd = oSiteWrapper;
                oPrimaryEnd1 = oSiteWrapper;
            } else {
                oSiteWrapper.booIsPrimaryEnd = false;
            }
        }

        //SearchOpportunities();

        return null;
    }

    public PageReference SelectOpportunityForMasterContract() {
        return null;
    }

    public PageReference SelectOpportunity() {

        booShowProjectInput = true;
        oProject.pse__Opportunity__c = sSelectedOpportunityId;
        oProject.name = mapOpportunitySearch.get(sSelectedOpportunityId).name;
        oProject.clAECOMServiceType__c = mapOpportunitySearch.get(sSelectedOpportunityId).Enterprise_Service__c;
        oProject.EstimatedContractValue__c = mapOpportunitySearch.get(sSelectedOpportunityId).Amount;
        
        //US-06402
        oProject.EstimatedStartDate__c = mapOpportunitySearch.get(sSelectedOpportunityId).Estimated_work_start_date__c;        
        
        oppName = mapOpportunitySearch.get(sSelectedOpportunityId).name;
        String recType = mapOpportunitySearch.get(sSelectedOpportunityId).RecordTypeText__c;
        
        if (recType == 'Program - Americas' || recType == 'Program - APAC' || recType == 'Program - CS' || recType == 'Program EMEA&I' || recType == 'Program - MS')
        {
            bOpportunityProgramSelected = true;
        }
        
        /*
          //Add the logic for Capture Manager assignment from the captmanageruser to proj's capturemanagercontact, as well as proj's capmanageruser
          set<id> sContactIds = new set<id>();
          list<pse__Proj__c> lstProjectsToUpdate = new list<pse__Proj__c>();
          map<id, id> contactToUser = new map<id, id>();

          if(oProject.CaptureManagerUser__c != mapOpportunitySearch.get(sSelectedOpportunityId).Capture_Manager_User__c)
          {
          if(mapOpportunitySearch.get(sSelectedOpportunityId).Capture_Manager_User__c != null)
          {
          sContactIds.add(mapOpportunitySearch.get(sSelectedOpportunityId).Capture_Manager_User__c);
          oProject.CaptureManagerUser__c = mapOpportunitySearch.get(sSelectedOpportunityId).Capture_Manager_User__c;
          lstProjectsToUpdate.add(oProject);
          }
          }
          System.debug('(SA catch) oProject.CaptureManagerUser__c : ' + oProject.CaptureManagerUser__c);

          if(sContactIds.size() > 0){
          //list<contact> lstContact = [select id, pse__Salesforce_User__c from contact where id IN: sContactIds];
          list<contact> lstContact = [select id, pse__Salesforce_User__c from contact where pse__Salesforce_User__c IN: sContactIds];

          for(contact c: lstContact){
          if(c.pse__Salesforce_User__c != null){
          contactToUser.put(c.pse__Salesforce_User__c, c.id);
          }
          System.debug('(SA catch) c.id : ' + c.id);
          }

          for(pse__Proj__c p: lstProjectsToUpdate){ 
                         
          if(contactToUser.containskey(mapOpportunitySearch.get(sSelectedOpportunityId).Capture_Manager_User__c)){
          p.CaptureManager__c = contactToUser.get(p.CaptureManagerUser__c);
          } 
          System.debug('(SA catch) p.CaptureManager__c : ' + p.CaptureManager__c);
          }
          } 
         */

        //CHECK IF OPP IS ASSOCIATED TO A PROJECT AND DISPLAY A WARNING MESSAGE - TOM SMALARA
        Integer count = (Integer) [SELECT count(Id) cnt from pse__Proj__c where pse__Opportunity__c = :sSelectedOpportunityId] [0].get('cnt');

        if (count > 0) {
            bLinkedToProject = true;
            tabState = 'name2';
        } else {
            bLinkedToProject = false;
            tabState = 'name3';
        }
        setPrimary();
        setSecondary();
        lastSaveAttemptName = null;
        boolNameAttempted = false;
        bOppSelected = true;
        return null;
    }

    /** 
     * @Description Sets the Primary Organization based on the selected Department - ONLY FIRED FROM STEP 2 WHEN AN EXISTING OPP IS SELECTED
     *
     * @Author  AECOM - Tom Smalara - tom.smalara@aecom.com
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    private void setPrimary() {
        //sDepartment = mapOpportunitySearch.get(sSelectedOpportunityId).Primary_Department_read_only__c;
        oDepartment = mapOpportunitySearch.get(sSelectedOpportunityId).Primary_Department_read_only__c;

        List<AECOM_Primary_Department__c> oDepartmentOrgNameList = [SELECT Org_String__c From AECOM_Primary_Department__c Where Name = :oDepartment LIMIT 1];

        if (oDepartmentOrgNameList.size() > 0)
        {
            oDepartmentOrgName = oDepartmentOrgNameList[0].Org_String__c;
            sSelectedOrganizationId = getOrganizationId();
        }

        Decimal PrimarySplit = 0;
        List<Opportunity_Department__c> oOppDeptList = [SELECT AECOM_Department__c, split__c, Name FROM Opportunity_Department__c Where Opportunity__c = :sSelectedOpportunityId and Primary__c = :true LIMIT 1];
        if (oOppDeptList.size() > 0)
        {
            PrimarySplit = oOppDeptList[0].split__c;
        }

        //sSelectedOrganizationId = getOrganizationId();
        if (String.isNotBlank(sSelectedOrganizationId)) {
            OrganizationWrapper oNewProjectOrganization = new OrganizationWrapper(mapOrganizationString.get(sSelectedOrganizationId));

            if (!mapOrganizationIdToProjectOrganization.containskey(sSelectedOrganizationId)) {
                if (lSelectedOrganizations.size() == 0) {
                    oNewProjectOrganization.strtype = 'Primary';
                    //oNewProjectOrganization.oProjectOrganization.ContributionPercent__c = 100;
                    oNewProjectOrganization.oProjectOrganization.ContributionPercent__c = PrimarySplit;
                } else {
                    oNewProjectOrganization.strtype = 'Supporting';
                    oNewProjectOrganization.oProjectOrganization.ContributionPercent__c = 0;
                }

                lSelectedOrganizations.add(oNewProjectOrganization);
                mapOrganizationIdToProjectOrganization.put(sSelectedOrganizationId, oNewProjectOrganization);

                for (string sString : mapOrganizationIdToProjectOrganization.keySet()) {
                    OrganizationWrapper oOrganization = mapOrganizationIdToProjectOrganization.get(sString);

                    if (oOrganization.strType == 'Primary') {
                        oProject.CarryingOutOrganization__c = sString;
                        oProject.CurrencyIsoCode = oOrganization.oOrganization.CurrencyIsoCode;
                        oProject.ProjectCurrencyCode__c = oOrganization.oOrganization.CurrencyIsoCode;
                        oProject.ProjectFunctionalCurrencyCode__c = oOrganization.oOrganization.CurrencyIsoCode;
                        oPrimaryOrganization = oOrganization.oOrganization;
                        //System.debug('oPrimaryOrganization::::' + oPrimaryOrganization);
                    }
                }
            }
        }


    }

    //4947
    /** 
     * @Description Sets the Secondary Organizations based on the selected Department - ONLY FIRED FROM STEP 2 WHEN AN EXISTING OPP IS SELECTED
     *
     * @Author  AECOM - Sameer Ahsan - sameer.ahsan@aecom.com
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    private void setSecondary()
    {
        List<Opportunity_Department__c> oOppDeptList = [SELECT AECOM_Department__c, split__c, Name FROM Opportunity_Department__c Where Opportunity__c = :sSelectedOpportunityId and Primary__c != true];

        if (oOppDeptList.size() > 0)
        {
            for (Opportunity_Department__c od : oOppDeptList)
            {
                List<AECOM_Primary_Department__c> oDepartmentOrgNameList = [SELECT Org_String__c From AECOM_Primary_Department__c Where Id = :od.AECOM_Department__c LIMIT 1];

                if (oDepartmentOrgNameList.size() > 0)
                {
                    for (AECOM_Primary_Department__c pd : oDepartmentOrgNameList)
                    {
                        oDepartmentOrgName = pd.Org_String__c;
                        sSelectedOrganizationId = getOrganizationId();
                    }

                    if (String.isNotBlank(sSelectedOrganizationId))
                    {
                        OrganizationWrapper oNewProjectOrganization = new OrganizationWrapper(mapOrganizationString.get(sSelectedOrganizationId));

                        if (!mapOrganizationIdToProjectOrganization.containskey(sSelectedOrganizationId))
                        {
                            oNewProjectOrganization.strtype = 'Supporting';
                            oNewProjectOrganization.oProjectOrganization.ContributionPercent__c = od.split__c;
                        }

                        lSelectedOrganizations.add(oNewProjectOrganization);
                        mapOrganizationIdToProjectOrganization.put(sSelectedOrganizationId, oNewProjectOrganization);

                        for (string sString : mapOrganizationIdToProjectOrganization.keySet())
                        {
                            OrganizationWrapper oOrganization = mapOrganizationIdToProjectOrganization.get(sString);

                            if (oOrganization.strType == 'Primary') {
                                oProject.CarryingOutOrganization__c = sString;
                                oProject.CurrencyIsoCode = oOrganization.oOrganization.CurrencyIsoCode;
                                oProject.ProjectCurrencyCode__c = oOrganization.oOrganization.CurrencyIsoCode;
                                oProject.ProjectFunctionalCurrencyCode__c = oOrganization.oOrganization.CurrencyIsoCode;
                                oPrimaryOrganization = oOrganization.oOrganization;
                            }
                        }
                    }
                }
            }
        }
    }

    /** 
     * @Description Get the OrganizationId based on the Department Name
     *
     * @Author  AECOM - Tom Smalara - tom.smalara@aecom.com
     * @Date    2016
     *
     * @param   
     * @return  orgId
     **/
    private String getOrganizationId() {
        string sQuery = 'SELECT Id, Name, OrganizationName__c, CurrencyIsoCode, GeographyName__c, Region__c, District__c, Department__c, BusinessLineName__c, LocationName__c, GoNoGoApprover__c, PLManagerContact__c, Project_Owning_Text__c, ProjectOwning__c, FinanceandAccountingManagerContact__c, CFOorDelegateContact__c, OUID__c, ProjectApprover__c, ProjectAccountant__c, ProjectAccountant2__c, FinanceLead2__c, ProjectBiller__c FROM OrganizationString__c WHERE ';
        //sQuery += 'Department__c like \'' + oDepartment + '%\' and ';
        //sQuery += 'Department__c = \'' + oDepartment + '\' and ';
        sQuery += 'OrganizationName__c like \'' + oDepartmentOrgName + '%\' and ';

        sQuery += '(InactiveDate__c > TODAY OR InactiveDate__c = null) ORDER BY OrganizationName__c, GeographyName__c, Region__c, BusinessLineName__c, Department__c, LocationName__c';

        try {
            list<OrganizationString__c> lOrganizationsQueried = Database.query(sQuery);
            lOrganizations = new list<OrganizationString__c> ();
            String orgId;
            for (OrganizationString__c SearchOrganization : lOrganizationsQueried) {
                if (lOrganizations.size() < iOrgLimit) {
                    mapOrganizationString.put(SearchOrganization.id, SearchOrganization);
                    lOrganizations.add(SearchOrganization);
                    orgId = SearchOrganization.id;
                }
            }
            return orgId;
        } catch(Exception e) {
            ECO_Service_ErrorLog.logException(e);
        }
        return null;
    }

    public PageReference SkipOpportunity() {

        //system.debug('SkipOpportunity::::selectedOppRecType::::' + sSelectedOppRecType);

        if (idSelectedOppRecType == '' || idSelectedOppRecType == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select recordtype for automatic opportunity creation.'));
            system.debug('SkipOpportunityn - idSelectedOppRecType');
            tabState = 'name2';
            return null;
        }

        sSelectedOppRecType = mapOppRecType.get(idSelectedOppRecType).name;

        //system.debug('SkipOpportunity1');

        oProject.clAECOMServiceType__c = null;
        booShowProjectInput = false;
        oProject.pse__Opportunity__c = null;
        oProject.name = null;
        oppName = null;
        tabState = 'name3';
        bOppSelected = true;
        //oProject.CaptureManager__c = null;
        //oProject.CaptureManagerUser__c = null;

        //system.debug('SkipOpportunity2');

        return null;
    }


    public PageReference Step2() {

        if (canContinue()) {
            tab2enabled = true;
            tabState = 'name2';
            return null;
        } else {
            return null;
        }


    }


    /** Method defined for saving the project form. Cannot use the standard controller because the clear method is defined in the extension **/
    public PageReference CreateProject() {

        ECO_Service_DirtyScope.run = false;
         
        if (isValid()) {

            ECO_Service_RecordAccess.ignoreRestOfSecurity = true;

            if (lastSaveAttemptName != oProject.name) {
                boolNameAttempted = false;
            }


            if (!boolNameAttempted) {

                // Perform Validation
                string projName = '%' + oProject.name + '%';
                //list<pse__Proj__c> listSearchProjects = [select id, name from pse__Proj__c where name LIKE : projName LIMIT 50];

                string strSOQL = 'SELECT ';

                for (Schema.FieldSetMember fsmField : SObjectType.pse__Proj__c.FieldSets.pse_ProjectFieldsforCustomProjectSetup.getFields()) {
                    strSOQL += fsmField.getFieldPath() + ', ';
                }

                strSOQL += 'ID FROM pse__Proj__c where name LIKE : projName LIMIT 50';

                listSimilarProjects = (list<pse__Proj__c>) Database.query(strSOQL);



                if (listSimilarProjects.size() > 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Attention: A duplicate project might already exist! Please confirm that you do want to create this project.'));
                    boolNameAttempted = true;
                    lastSaveAttemptName = oProject.name;
                    return null;
                }

            }

            list<pse__Proj__c> lstExactMatch = [select id from pse__Proj__c where name = :oProject.name];

            if (lstExactMatch.size() > 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Attention: The project name you specified already exists! please update the project name.'));
                return null;
            }


            Savepoint oSavePoint = Database.setSavepoint();


            try {
                id oppID = null;

                if (oProject.pse__Opportunity__c == null) {
                    oProject.pse__Opportunity__c = CreateOpportunity();
                }


                //UPDATES FROM EXISTING OPPORTUNITY
                else
                {
                    Opportunity ExistingOpp = null;

                    try
                    {
                        ExistingOpp = [select Id, AECOM_Role__c, Capture_Manager_User__c, Go_Probability__c, Probability_Stage__c, Date_RFP_expected__c, Submittal_Date_Proposal__c, Initial_Estimated_Award_Date__c, Estimated_work_start_date__c, CloseDate from Opportunity where Id = :oProject.pse__Opportunity__c];
                    }
                    catch(Exception e)
                    {
                        ECO_Service_ErrorLog.logException(e);
                    }

                    if (ExistingOpp != null)
                    {
                        if (oProject.AECOMrole__c != ExistingOpp.AECOM_Role__c)
                        {
                            oProject.AECOMrole__c = ExistingOpp.AECOM_Role__c;
                        }
                        if (ExistingOpp.Capture_Manager_User__c != null)
                        {
                            if (oProject.CaptureManagerUser__c != ExistingOpp.Capture_Manager_User__c)
                            {
                                //System.debug('p.CaptureManagerUser__c');
                                oProject.CaptureManagerUser__c = ExistingOpp.Capture_Manager_User__c;

                                list<contact> lstContact = new list<contact> ();

                                try
                                {
                                    lstContact = [select id, name, pse__Salesforce_User__c from contact where pse__Salesforce_User__c = :oProject.CaptureManagerUser__c];
                                }
                                catch(Exception e)
                                {
                                    ECO_Service_ErrorLog.logException(e);
                                }

                                for (contact c : lstContact)
                                {
                                    if (c.id != null)
                                    {
                                        oProject.CaptureManager__c = c.id;
                                    }
                                }
                            }
                        }
                        if (oProject.GoProbability__c != ExistingOpp.Go_Probability__c)
                        {
                            oProject.GoProbability__c = ExistingOpp.Go_Probability__c;
                        }
                        if (oProject.GetProbability__c != ExistingOpp.Probability_Stage__c)
                        {
                            oProject.GetProbability__c = ExistingOpp.Probability_Stage__c;
                        }
                        //US-06402
                        if (oProject.RFPIssueDate__c != ExistingOpp.Date_RFP_expected__c)
                        {
                            oProject.RFPIssueDate__c = ExistingOpp.Date_RFP_expected__c;
                        }                        
                        if (oProject.ProposalSubmittedDate__c != ExistingOpp.Submittal_Date_Proposal__c)
                        {
                            oProject.ProposalSubmittedDate__c = ExistingOpp.Submittal_Date_Proposal__c;
                        }
                        //if (oProject.EstAwardDate__c != ExistingOpp.Initial_Estimated_Award_Date__c)
                        if (oProject.EstAwardDate__c != ExistingOpp.CloseDate)
                        {
                            //oProject.EstAwardDate__c = ExistingOpp.Initial_Estimated_Award_Date__c;
                            oProject.EstAwardDate__c = ExistingOpp.CloseDate;
                        }
                        /*
                        if (oProject.EstimatedStartDate__c != ExistingOpp.Estimated_work_start_date__c)
                        {
                            oProject.EstimatedStartDate__c = ExistingOpp.Estimated_work_start_date__c;
                        }
                        */
                            
                        //new logic for sync department info
                        //jtenorio
                        //US-05505
                        //system.debug('about to enter update');
                        UpdateOpportunity(ExistingOpp);

                    }
                }

            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Error has occurred while attempting to create an Opportunity. Please contact your administrator with the following error: ' + e));
                Database.rollback(oSavePoint);
                if (sSelectedOpportunityId == null)
                oProject.pse__Opportunity__c = null;
                return null;
            }

            System.debug('****');
            
            oProject.pse__Account__c = oPrimaryEnd.osite.account__c;
            oProject.DefaultTopTaskCustomer__c = oTopTask.osite.account__c;
            oProject.PrimarySite__c = oPrimaryEnd.osite.id;

            oProject.PrimaryBillingClient__c = oTopTask.osite.id;
            oProject.PrimaryEndClient__c = oPrimaryEnd.osite.id;
            oProject.Client_Account_Manager__c = oPrimaryEnd.oSite.Account__r.Client_Account_Manager_CAM__c;

            //4593
            oProject.ValidateGo__c = false;

            list<recordtype> lrt = [Select ID, Name From RecordType Where sObjectType = 'pse__Proj__c' and developername = 'CustomerProjectUnapproved'];

            oProject.recordtypeid = lrt[0].id;
            System.debug('****2');

            ECO_Service_RecordAccess.PCCCreate = true;
            System.debug('****');
            try {
                System.debug('test:before Project insert');
                insert oProject;
                System.debug('test:after Project insert');

            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Error has occurred while attempting to create a Project. Please contact your administrator with the following error: ' + e));
                Database.rollback(oSavePoint);
                if (sSelectedOpportunityId == null)
                oProject.pse__Opportunity__c = null;
                return null;
            }

            ECO_ProjectTriggers.run = false;

            try {
                CreateProjectOrganizations();

            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Error has occurred while attempting to creating project organizations. Please contact your administrator with the following error: ' + e));
                Database.rollback(oSavePoint);
                if (sSelectedOpportunityId == null)
                oProject.pse__Opportunity__c = null;
                return null;
            }


            try {
                CreateProjectSites();

            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Error has occurred while attempting to creating project sites. Please contact your administrator with the following error: ' + e));
                Database.rollback(oSavePoint);
                if (sSelectedOpportunityId == null)
                oProject.pse__Opportunity__c = null;
                return null;
            }



            try {
                update oProject;

            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Error has occurred while attempting to update Project. Please contact your administrator with the following error: ' + e));
                Database.rollback(oSavePoint);
                if (sSelectedOpportunityId == null)
                oProject.pse__Opportunity__c = null;
                return null;
            }

            ECO_Service_RecordAccess.PCCCreate = false;
            ECO_ProjectTriggers.run = true;

            // redirect the user to the project detail page if successful
            PageReference pageRef = new PageReference('/' + oProject.id + '/e?retURL=/' + oProject.id);
            return pageRef;
        } else {
            return null;
        }
    }

    public PageReference SearchOrganizations() {
        set<string> lGeographies = new set<string> ();
        set<string> lRegions = new set<string> ();
        set<string> lDistricts = new set<string> ();
        set<string> lBusinessLines = new set<string> ();
        set<string> lDepartments = new set<string> ();
        set<string> lLocations = new set<string> ();
        set<string> lProjOwning = new set<string> ();

        bSearchInProgress = false;

        string sQuery = 'SELECT Id, Name, OrganizationName__c, CurrencyIsoCode, GeographyName__c, Region__c, District__c, Department__c, BusinessLineName__c, LocationName__c, GoNoGoApprover__c, PLManagerContact__c, Project_Owning_Text__c, ProjectOwning__c, FinanceandAccountingManagerContact__c, CFOorDelegateContact__c, OUID__c, ProjectApprover__c, ProjectAccountant__c, ProjectAccountant2__c, FinanceLead2__c, ProjectBiller__c FROM OrganizationString__c WHERE ';

        if (ECO_Utils_String.NullCheck(sOrganizationName) != '') {
            sQuery += 'OrganizationName__c LIKE \'%' + sOrganizationName + '%\' and ';
            bSearchInProgress = true;
        }

        if (ECO_Utils_String.NullCheck(sGeographyName) != '') {
            sQuery += 'GeographyName__c = \'' + sGeographyName + '\' and ';
            bSearchInProgress = true;
        }

        if (ECO_Utils_String.NullCheck(sRegion) != '') {
            sQuery += 'Region__c = \'' + sRegion + '\' and ';
            bSearchInProgress = true;
        }

        if (ECO_Utils_String.NullCheck(sDistrict) != '') {
            sQuery += 'District__c = \'' + sDistrict + '\' and ';
            bSearchInProgress = true;
        }

        if (ECO_Utils_String.NullCheck(sBusinessLine) != '') {
            sQuery += 'BusinessLineName__c = \'' + sBusinessLine + '\' and ';
            bSearchInProgress = true;
        }

        if (ECO_Utils_String.NullCheck(sDepartment) != '') {
            sQuery += 'Department__c = \'' + sDepartment + '\' and ';
            bSearchInProgress = true;
        }

        if (ECO_Utils_String.NullCheck(sLocation) != '') {
            sQuery += 'LocationName__c = \'' + sLocation + '\' and ';
            bSearchInProgress = true;
        }

        if (ECO_Utils_String.NullCheck(sProjOwning) != '') {
            sQuery += 'Project_Owning_Text__c = \'' + sProjOwning + '\' and ';
            bSearchInProgress = true;
        }
        sQuery += 'ProjectOwning__c=true and (InactiveDate__c > TODAY OR InactiveDate__c = null) ORDER BY OrganizationName__c, GeographyName__c, Region__c, BusinessLineName__c, Department__c, LocationName__c';

        list<OrganizationString__c> lOrganizationsQueried = Database.query(sQuery);

        loGeographies = new list<SelectOption> ();
        loRegions = new list<SelectOption> ();
        loDistricts = new list<SelectOption> ();
        loBusinessLines = new list<SelectOption> ();
        loDepartments = new list<SelectOption> ();
        loLocations = new list<SelectOption> ();
        loProjOwnings = new list<SelectOption> ();

        for (OrganizationString__c oOrganizationString : lOrganizationsQueried) {
            if (lGeographies.size() < 1000)
            lGeographies.add(oOrganizationString.GeographyName__c);
            if (lRegions.size() < 1000)
            lRegions.add(oOrganizationString.Region__c);
            if (lDistricts.size() < 1000)
            lDistricts.add(oOrganizationString.District__c);
            if (lBusinessLines.size() < 1000)
            lBusinessLines.add(oOrganizationString.BusinessLineName__c);
            if (lDepartments.size() < 1000)
            lDepartments.add(oOrganizationString.Department__c);
            if (lLocations.size() < 1000)
            if (oOrganizationString.LocationName__c != null) {
                lLocations.add(oOrganizationString.LocationName__c);
            }
            if (lProjOwning.size() < 1000)
            if (oOrganizationString.Project_Owning_Text__c != null) {
                lProjOwning.add(oOrganizationString.Project_Owning_Text__c);
            }
        }

        list<string> olGeographies = new list<string> (lGeographies);
        list<string> olRegions = new list<string> (lRegions);
        list<string> olDistricts = new list<string> (lDistricts);
        list<string> olBusinessLines = new list<string> (lBusinessLines);
        list<string> olDepartments = new list<string> (lDepartments);
        list<string> olLocations = new list<string> (lLocations);
        list<string> olProjOwnings = new list<string> (lProjOwning);


        olGeographies.sort();
        olRegions.sort();
        olDistricts.sort();
        olBusinessLines.sort();
        olDepartments.sort();
        olLocations.sort();
        olProjOwnings.sort();

        for (string sString : olGeographies) {
            loGeographies.add(new SelectOption(sString, sString));
        }

        for (string sString : olRegions) {
            loRegions.add(new SelectOption(sString, sString));
        }

        for (string sString : olDistricts) {
            loDistricts.add(new SelectOption(sString, sString));
        }

        for (string sString : olBusinessLines) {
            loBusinessLines.add(new SelectOption(sString, sString));
        }

        for (string sString : olDepartments) {
            loDepartments.add(new SelectOption(sString, sString));
        }

        for (string sString : olLocations) {
            loLocations.add(new SelectOption(sString, sString));
        }

        for (string sString : olProjOwnings) {
            loProjOwnings.add(new SelectOption(sString, sString));
        }

        if (bSearchInProgress) {

            lOrganizations = new list<OrganizationString__c> ();

            for (OrganizationString__c SearchOrganiation : lOrganizationsQueried) {


                if (lOrganizations.size() < iOrgLimit) {
                    mapOrganizationString.put(SearchOrganiation.id, SearchOrganiation);
                    lOrganizations.add(SearchOrganiation);
                }

                if (lOrganizations.size() < orgLessLIMIT) {
                    bShowMoreButtonOrg = false;
                } else {
                    bShowMoreButtonOrg = true;
                }

            }



        }

        return null;
    }

    public PageReference Reset() {
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



    public boolean canContinue()
    {
        boolean bIsValid = true;
        boolean noEmptyCB = true;
        Decimal dSiteTotal = 0;

        for (SiteWrapper oSiteWrapper : lstSites)
        {
            Decimal dPercentage = ECO_Utils_String.NullCheck(oSiteWrapper.contributions);
            dSiteTotal += dPercentage;

            if (oSiteWrapper.booIsBilling && oSiteWrapper.billingContact == null) {
                noEmptyCB = false;
            }
        }

        if (!noEmptyCB)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must select a contact for each billing client.'));
            bIsValid = false;
        }

        if (dSiteTotal != 100)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Contribution % for the Selected Sites does not total 100%.'));
            bIsValid = false;
        }

        return bIsValid;
    }

    public boolean isValid()
    {
        boolean bIsValid = true;
        boolean noEmptyCB = true;
        Decimal dTotal = 0;
        Decimal dSiteTotal = 0;

        for (SiteWrapper oSiteWrapper : lstSites)
        {
            Decimal dPercentage = ECO_Utils_String.NullCheck(oSiteWrapper.contributions);
            dSiteTotal += dPercentage;

            if (oSiteWrapper.booIsBilling && oSiteWrapper.billingContact == null) {
                noEmptyCB = false;
            }
        }

        for (OrganizationWrapper po : lSelectedOrganizations)
        {
            Decimal dPercentage = ECO_Utils_String.NullCheck(po.oProjectOrganization.ContributionPercent__c);
            dTotal += dPercentage;
        }

        if (!noEmptyCB)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'All selected sites must have a billing contact'));
            bIsValid = false;
        }

        if (dSiteTotal != 100)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Contribution % for the Selected Sites does not total 100%.'));
            bIsValid = false;
        }

        if (dTotal != 100)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Contribution % for the Selected Organizations does not total 100%.'));
            bIsValid = false;
        }

        if (oPrimaryOrganization == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Primary Organization has not been selected.'));
            bIsValid = false;
        }

        return bIsValid;

    }

    public PageReference ProjectDetailNext() {
        if ((oppName == null || oppName == '') && (oppProjectCountryName == null || oppProjectCountryName == ''))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Project Country required.'));
            
        }
        if(!ApexPages.hasMessages()){
            bProjectFilled = true;
            tabState = 'name4';
        }
        return null;
    }

    /*public PageReference SaveRecords(){
      if(isValid())
      {
      try{
      update lSelectedOrganizations;
      }catch(EcoControllerException oException){
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
      }
     
      //Update Project to reflect changes
      oProject = ECO_Service_Projects.getProjectById(oProject.Id);
      lSelectedOrganizations = oProject.ProjectOrganizations__r;
      }
      return null;
      }*/

    public PageReference RemoveEntry() {
        list<OrganizationWrapper> lNewSelectedOrganizations = new list<OrganizationWrapper> ();

        for (OrganizationWrapper oSelectedProjectOrganization : lSelectedOrganizations) {
            if (oSelectedProjectOrganization.oOrganization.id != sSelectedOrganizationId) {
                lNewSelectedOrganizations.add(oSelectedProjectOrganization);
            }
            else
            {
                oProjectOrganization = new ProjectOrganization__c();
                //System.debug('oProjectOrganization::::' + oProjectOrganization);
            }

            lSelectedOrganizations = lNewSelectedOrganizations;
            mapOrganizationIdToProjectOrganization.remove(sSelectedOrganizationId);
        }

        //3818
        lSelectedOrganizationsPrimaryNotFound = determinePrimaryWarning();

        return null;
    }



    public PageReference SelectPrimary() {
        for (OrganizationWrapper oSelectedProjectOrganization : lSelectedOrganizations) {
            oSelectedProjectOrganization.strType = 'Supporting';
        }

        if (mapOrganizationIdToProjectOrganization.containskey(sSelectedOrganizationId)) {
            mapOrganizationIdToProjectOrganization.get(sSelectedOrganizationId).strType = 'Primary';
        } else {
            OrganizationWrapper oNewProjectOrganization = new OrganizationWrapper(mapOrganizationString.get(sSelectedOrganizationId));
            oNewProjectOrganization.strtype = 'Primary';

            if (lSelectedOrganizations.size() == 0) {
                oNewProjectOrganization.oProjectOrganization.ContributionPercent__c = 100;
            } else {
                oNewProjectOrganization.oProjectOrganization.ContributionPercent__c = 0;
            }

            lSelectedOrganizations.add(oNewProjectOrganization);
            mapOrganizationIdToProjectOrganization.put(sSelectedOrganizationId, oNewProjectOrganization);
        }

        for (string sString : mapOrganizationIdToProjectOrganization.keySet()) {
            OrganizationWrapper oOrganization = mapOrganizationIdToProjectOrganization.get(sString);

            if (oOrganization.strType == 'Primary') {
                oProject.CarryingOutOrganization__c = sString;
                oProject.CurrencyIsoCode = oOrganization.oOrganization.CurrencyIsoCode;
                oProject.ProjectCurrencyCode__c = oOrganization.oOrganization.CurrencyIsoCode;
                oProject.ProjectFunctionalCurrencyCode__c = oOrganization.oOrganization.CurrencyIsoCode;
                //oProject.PrimaryOrganization__c = sString;
                oPrimaryOrganization = oOrganization.oOrganization;
            }
        }

        //3818
        lSelectedOrganizationsPrimaryNotFound = determinePrimaryWarning();

        return null;
    }

    public PageReference SelectSecondary() {

        if (mapOrganizationIdToProjectOrganization.containskey(sSelectedOrganizationId)) {
            mapOrganizationIdToProjectOrganization.get(sSelectedOrganizationId).strType = 'Supporting';
        } else {
            OrganizationWrapper oNewProjectOrganization = new OrganizationWrapper(mapOrganizationString.get(sSelectedOrganizationId));
            oNewProjectOrganization.strtype = 'Supporting';

            if (lSelectedOrganizations.size() == 0) {
                oNewProjectOrganization.oProjectOrganization.ContributionPercent__c = 100;
            } else {
                oNewProjectOrganization.oProjectOrganization.ContributionPercent__c = 0;
            }

            lSelectedOrganizations.add(oNewProjectOrganization);
            mapOrganizationIdToProjectOrganization.put(sSelectedOrganizationId, oNewProjectOrganization);
        }

        oProject.CarryingOutOrganization__c = null;
        //oProject.PrimaryOrganization__c = null;
        oPrimaryOrganization = null;

        for (string sString : mapOrganizationIdToProjectOrganization.keySet()) {

            OrganizationWrapper oOrganization = mapOrganizationIdToProjectOrganization.get(sString);

            if (oOrganization.strType == 'Primary') {
                oProject.CarryingOutOrganization__c = sString;
                oProject.CurrencyIsoCode = oOrganization.oOrganization.CurrencyIsoCode;
                oProject.ProjectCurrencyCode__c = oOrganization.oOrganization.CurrencyIsoCode;
                oProject.ProjectFunctionalCurrencyCode__c = oOrganization.oOrganization.CurrencyIsoCode;
                //oProject.PrimaryOrganization__c = sString;
                oPrimaryOrganization = oOrganization.oOrganization;
            }
        }

        //3818
        lSelectedOrganizationsPrimaryNotFound = determinePrimaryWarning();

        return null;
    }

    //3818
    public boolean determinePrimaryWarning()
    {
        boolean lSelectedFoundPrimary = false;
        lSelectedOrganizationsPrimaryNotFoundList = '';

        if (lSelectedOrganizations != null)
        {

            map<string, AECOM_Primary_Department__c> mapAPD = new map<string, AECOM_Primary_Department__c> ();
            set<string> sOrgNames = new set<string> ();

            for (OrganizationWrapper po : lSelectedOrganizations)
            {
                sOrgNames.add(po.oOrganization.OrganizationName__c);
            }

            list<AECOM_Primary_Department__c> lstAPD = new list<AECOM_Primary_Department__c> ();

            try {
                lstAPD = [SELECT ID, Org_String__c FROM AECOM_Primary_Department__c WHERE Org_String__c IN :sOrgNames];
            } catch(Exception e) {
                ECO_Service_ErrorLog.formatPageError(e, 'Error while searching for AECOM Primary Department during determinePrimaryWarning: ' + e.getMessage());
            }

            for (AECOM_Primary_Department__c APD : lstAPD) {
                mapAPD.put(APD.Org_String__c, APD);
            }


            for (OrganizationWrapper po : lSelectedOrganizations)
            {
                //AECOM_Primary_Department__c[] primaryDeptartments = [SELECT ID FROM AECOM_Primary_Department__c  WHERE Org_String__c = :po.oOrganization.OrganizationName__c LIMIT 1];

                //if (primaryDeptartments.size() == 0)
                if (!mapAPD.containskey(po.oOrganization.OrganizationName__c))
                {
                    lSelectedFoundPrimary = true;
                    lSelectedOrganizationsPrimaryNotFoundList = lSelectedOrganizationsPrimaryNotFoundList + po.oOrganization.OrganizationName__c + '<br/>';
                }
            }
        }

        return lSelectedFoundPrimary;
    }


    private void ResetValues() {
        this.lstSearchOpportunities = new list<opportunity> ();
        lstProjectSites = new list<Project_Site__c> ();
        //lstSites = new list<SiteWrapper>();
        //mapSites = new map<id, SiteWrapper>();
        //mapSitesBilling = new map<id, SiteWrapper>();
        //mapSitesEnd = new map<id, SiteWrapper>();
        //mapSearchSites = new map<id, Site__c>();

        boolShowSiteSearch = false;
        booDisplaySiteSearchResult = false;
        booDisplayOpportunitySearch = false;
        booShowProjectInput = false;
        //oProject = new pse__Proj__c();
    }

    /**
     * Used for creating the Project Site junction objects AFTER the project has been saved.
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    private void CreateProjectSites() {
        list<Project_Site__c> lstProjectSitesToInsert = new list<Project_Site__c> ();

        for (SiteWrapper oSiteWrapper : lstSites) {
            lstProjectSitesToInsert.add(new Project_Site__c(Contribution__c = oSiteWrapper.contributions, BillingContactID__c = oSiteWrapper.billingContact, BillingContact__c = oSiteWrapper.oidmap.get(oSiteWrapper.billingContact), Project__c = oProject.Id, name = oSiteWrapper.oSite.AccountName__c.left(70), Site__c = oSiteWrapper.oSite.id, Is_Billing__c = oSiteWrapper.booIsBilling, Is_Default_Top_Task__c = oSiteWrapper.booIsDefaultTopTask, Is_End__c = oSiteWrapper.booIsEnd, Is_Primary_End__c = oSiteWrapper.booIsPrimaryEnd));
        }

        try{
            insert lstProjectSitesToInsert;
        }
        catch(Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e, label.ErrorCreatingProjectSites);
        }

    }

    /* Used for creating the Project Organization junction objects AFTER the project has been saved.  */
    private void CreateProjectOrganizations() {
        list<ProjectOrganization__c> lstProjectOrganizationsToInsert = new list<ProjectOrganization__c> ();
        list<ProjectTeamMember__c> listProjectTeamMemberToInsert = new list<ProjectTeamMember__c> ();

        map<string, ProjectRole__c> mapProjectRole = new map<string, ProjectRole__c> ();
        List<ProjectRole__c> lProjectRoles = new List<ProjectRole__c> ([Select Id, Name, Type__c From ProjectRole__c Where Active__c = true]);

        for (ProjectRole__c pr : lProjectRoles) {
            mapProjectRole.put(pr.Name, pr);
        }


        /*list<contact> lstSearchContact = [select id, pse__Salesforce_User__c from contact where pse__Salesforce_User__c  =: UserInfo.getUserId()];
          if(mapProjectRole.containskey('Project Manager') && lstSearchContact.size() > 0){
          id auth2IDa = mapProjectRole.get('Project Manager').id;
          id contactIDa = lstSearchContact[0].id;

          listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactIDa, ProjectRole__c = auth2IDa, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
          oProject.pse__Project_Manager__c = contactIDa;
         
          } else {
          ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Unable to populate Project Manager based on current user. ');
          ApexPages.addMessage(oMsg);
          }       */
        //Priya
        if (mapProjectRole.containskey('Project Owner')) {
            id auth2ID = mapProjectRole.get('Project Owner').id;
            id contactID;
            //System.debug('oProject.OwnerId:::' + UserInfo.getUserId());
            Contact oContact = [Select Id, pse__Salesforce_User__c from contact where pse__Salesforce_User__c<> NULL AND pse__Salesforce_User__c = :UserInfo.getUserId()];
            if (oContact != null) {
                System.debug('oContact:::' + oContact.Id);
                contactID = oContact.Id;
            }

            listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));

        }
        //System.debug('mapProjectRole:::' + mapProjectRole.values());
        for (OrganizationWrapper oOrganizationWrapper : lSelectedOrganizations) {
            lstProjectOrganizationsToInsert.add(new ProjectOrganization__c(Project__c = oProject.Id, OrganizationString__c = oOrganizationWrapper.oOrganization.id, Type__c = oOrganizationWrapper.strType, ContributionPercent__c = oOrganizationWrapper.oProjectOrganization.ContributionPercent__c));


            if ((oOrganizationWrapper.oOrganization.PLManagerContact__c != null ||
                 oOrganizationWrapper.oOrganization.FinanceandAccountingManagerContact__c != null ||
                 oOrganizationWrapper.oOrganization.CFOorDelegateContact__c != null ||
                 oOrganizationWrapper.oOrganization.ProjectApprover__c != null ||
                 oOrganizationWrapper.oOrganization.ProjectAccountant__c != null ||
                 oOrganizationWrapper.oOrganization.ProjectAccountant2__c != null ||
                 oOrganizationWrapper.oOrganization.FinanceLead2__c != null ||
                 oOrganizationWrapper.oOrganization.GoNoGoApprover__c != null ||
                 oOrganizationWrapper.oOrganization.ProjectBiller__c != null 

            )
                && oOrganizationWrapper.strType == 'Primary') {

                /*list<contact> lstSearchContact = [select id, User__c from contact where (User__c =: oOrganizationWrapper.oOrganization.PLManagerContact__c or User__c =: oOrganizationWrapper.oOrganization.FinanceandAccountingManagerContact__c) and User__c !=null];
                 
                  map<id, contact> mapContact = new map<id, contact>();
                  for(contact c:lstSearchContact){
                  mapContact.put(c.User__c, c);
                  }*/



                if (mapProjectRole.containskey('Project Approver 2') && oOrganizationWrapper.oOrganization.PLManagerContact__c != null) {
                    id auth2ID = mapProjectRole.get('Project Approver 2').id;
                    id contactID = oOrganizationWrapper.oOrganization.PLManagerContact__c;

                    listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));

                    oProject.PnLManager__c = contactID;

                    /*} else {
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Unable to populate Project Approver 2 based on PL Owner on Primary Org: ' + oOrganizationWrapper.oOrganization.name));*/
                }

                if (mapProjectRole.containskey('Finance Lead') && oOrganizationWrapper.oOrganization.FinanceandAccountingManagerContact__c != null) {
                    id auth2ID = mapProjectRole.get('Finance Lead').id;
                    id contactID = oOrganizationWrapper.oOrganization.FinanceandAccountingManagerContact__c;

                    listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));

                    oProject.FinanceLead__c = contactID;

                    /*} else {
                      ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Unable to populate Finance Lead based on Finance and Accounting Manager on Primary Org: ' + oOrganizationWrapper.oOrganization.name);
                      ApexPages.addMessage(oMsg);*/
                }

                if (mapProjectRole.containskey('CFO or Delegate') && oOrganizationWrapper.oOrganization.CFOorDelegateContact__c != null) {
                    id auth2ID = mapProjectRole.get('CFO or Delegate').id;
                    id contactID = oOrganizationWrapper.oOrganization.CFOorDelegateContact__c;

                    listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
                    /* } else {
                      ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Unable to populate CFO or Delegate based on CFO or Delegate on Primary Org: ' + oOrganizationWrapper.oOrganization.name);
                      ApexPages.addMessage(oMsg);*/
                }

                if (mapProjectRole.containskey('Project Approver') && oOrganizationWrapper.oOrganization.ProjectApprover__c != null) {
                    id auth2ID = mapProjectRole.get('Project Approver').id;
                    id contactID = oOrganizationWrapper.oOrganization.ProjectApprover__c;

                    listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));

                    oProject.ProjectApprover__c = contactID;
                    /* } else {
                      ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Unable to populate Project Approver based on Project Approver on Primary Org: ' + oOrganizationWrapper.oOrganization.name);
                      ApexPages.addMessage(oMsg);*/
                }

                if (mapProjectRole.containskey('Project Accountant') && oOrganizationWrapper.oOrganization.ProjectAccountant__c != null) {
                    id auth2ID = mapProjectRole.get('Project Accountant').id;
                    id contactID = oOrganizationWrapper.oOrganization.ProjectAccountant__c;

                    listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
                    /*} else {
                      ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Unable to populate Project Accountant based on Project Accountant on Primary Org: ' + oOrganizationWrapper.oOrganization.name);
                      ApexPages.addMessage(oMsg);*/
                }

                if (mapProjectRole.containskey('Project Accountant 2') && oOrganizationWrapper.oOrganization.ProjectAccountant2__c != null) {
                    id auth2ID = mapProjectRole.get('Project Accountant 2').id;
                    id contactID = oOrganizationWrapper.oOrganization.ProjectAccountant2__c;

                    listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
                    /*} else {
                      ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Unable to populate Project Accountant 2 based on Project Accountant 2 on Primary Org: ' + oOrganizationWrapper.oOrganization.name);
                      ApexPages.addMessage(oMsg);*/
                }

                if (mapProjectRole.containskey('Finance Lead 2') && oOrganizationWrapper.oOrganization.FinanceLead2__c != null) {
                    id auth2ID = mapProjectRole.get('Finance Lead 2').id;
                    id contactID = oOrganizationWrapper.oOrganization.FinanceLead2__c;

                    listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
                    /*} else {
                      ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Unable to populate Finance Lead 2 based on Finance Lead 2 on Primary Org: ' + oOrganizationWrapper.oOrganization.name);
                      ApexPages.addMessage(oMsg);*/
                }

                if (mapProjectRole.containskey('Go/No Go Approver') && oOrganizationWrapper.oOrganization.GoNoGoApprover__c != null) {
                    id auth2ID = mapProjectRole.get('Go/No Go Approver').id;
                    id contactID = oOrganizationWrapper.oOrganization.GoNoGoApprover__c;

                    listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
                    oProject.GoNoGoApprover__c = contactID;
                }
                if (mapProjectRole.containskey('Project Biller') && oOrganizationWrapper.oOrganization.ProjectBiller__c != null) {
                    id auth2ID = mapProjectRole.get('Project Biller').id;
                    id contactID = oOrganizationWrapper.oOrganization.ProjectBiller__c;

                    listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = contactID, ProjectRole__c = auth2ID, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
                }

            }

        }

        // Create a client account manager from Project's Account

        if (mapProjectRole.containskey('Client Account Manager')) {
            id iCAMid = mapProjectRole.get('Client Account Manager').id;
            if (oPrimaryEnd.oSite.Account__r.Client_Account_Manager_CAM__c != null) {
                Contact[] con = [SELECT Id FROM Contact WHERE pse__Salesforce_User__c<> NULL AND pse__Salesforce_User__c = :oPrimaryEnd.oSite.Account__r.Client_Account_Manager_CAM__c];
                if (con.size() > 0) {
                    listProjectTeamMemberToInsert.add(new ProjectTeamMember__c(Contact__c = con[0].Id, ProjectRole__c = iCAMid, Project__c = oProject.Id, StartDate__c = oProject.EstimatedStartDate__c));
                }
            }
        }

        insert lstProjectOrganizationsToInsert;

        if (listProjectTeamMemberToInsert.size() > 0) {
            insert listProjectTeamMemberToInsert;
        }

    }

    /**
     * @description Update opportunity departments coming from project
     * @param opp 
     */
    private void UpdateOpportunity(Opportunity opp) {
        //local variablles
        map<string, AECOM_Primary_Department__c> mapAPD = new map<string, AECOM_Primary_Department__c> ();
        set<string> sOrgNames = new set<string> ();
        Opportunity_Department__c oOpportunityDepartmentToInsert;

//system.debug('obtaining organizations');
        //Obtain current organizations
        for (OrganizationWrapper po : lSelectedOrganizations)
        {
            sOrgNames.add(po.oOrganization.OrganizationName__c);
        }

        list<AECOM_Primary_Department__c> lstAPD = new list<AECOM_Primary_Department__c> ();

//system.debug('about search primary departments');
        try {
            lstAPD = [SELECT ID, Org_String__c FROM AECOM_Primary_Department__c WHERE Org_String__c IN :sOrgNames];
        } catch(Exception e) {
            ECO_Service_ErrorLog.formatPageError(e, 'Error while searching for AECOM Primary Department during UpdateOpportunity: ' + e.getMessage());
        }

        for (AECOM_Primary_Department__c APD : lstAPD) {
            mapAPD.put(APD.Org_String__c, APD);
        }


//system.debug('about to set opportunity primary');
        //set primary department for opportunity
        for (OrganizationWrapper oOrganizationWrapper : lSelectedOrganizations) {
            if (oOrganizationWrapper.strType == 'Primary') {

                if (mapAPD.containskey(oOrganizationWrapper.oOrganization.OrganizationName__c)) {
                    /*
                      Setting the AECOM_Primary_Dept_Lookup__c is required to create the Go/NoGo Conversation record
                      which is a requirement in US-02492
                     */


                    opp.AECOM_Primary_Dept_Lookup__c = mapAPD.get(oOrganizationWrapper.oOrganization.OrganizationName__c).Id;
                    opp.AECOM_Primary_Department_Percent__c = oOrganizationWrapper.oProjectOrganization.ContributionPercent__c;

                }
                /*else {
                opp.AECOM_Primary_Department_Percent__c = oOrganizationWrapper.oProjectOrganization.ContributionPercent__c;
                opp.AECOM_Primary_Dept_Lookup__c = '';
                }*/

            }
        }

        //US-3638
        opp.ValidateGo__c = false;

        //US-4409
        opp.CurrencyIsoCode = oProject.CurrencyIsoCode;

//system.debug('about to update opp');

ECO_ProjectTriggers.run =  false;
            
        
        //Now proceed with the Opportunity update
        update opp;  

//system.debug('about to delete secondaries');
        //delete current departments and then upsert secondary departments



        Opportunity_Department__c[] lstOppDToDelete = [Select Business_Line__c, id, AECOM_Department__c, Primary__c, split__c, Practice_Area__c, Sub_Practice_Area__c from Opportunity_Department__c where Opportunity__c = :opp.Id LIMIT 1000];


        //check if there are departments to delete

        if (lstOppDToDelete.size() > 0) {
            delete lstOppDToDelete;
        }

        //upsert current departments
        list<Opportunity_Department__c> lstOppDToInsert = new list<Opportunity_Department__c> ();
        
        
        
        //ADD Primary
        //Use Wellington / Tauranga / Christchurch 2594 for matching Org_String__c
        for (OrganizationWrapper oOrganizationWrapper : lSelectedOrganizations) {
            Opportunity_Department__c oOpportunityDepartmentToInsert0 = new Opportunity_Department__c();
            if (oOrganizationWrapper.strType == 'Primary') {
                //AECOM_Primary_Department__c[] supportingDepartments = [SELECT ID FROM AECOM_Primary_Department__c  WHERE Org_String__c = :oOrganizationWrapper.oOrganization.OrganizationName__c LIMIT 1];

                if (mapAPD.containskey(oOrganizationWrapper.oOrganization.OrganizationName__c)) {
                    //if(supportingDepartments.size() > 0){

                    oOpportunityDepartmentToInsert0.Primary__c = true;
                    //oOpportunityDepartmentToInsert.AECOM_Department__c = supportingDepartments[0].Id;    
                    oOpportunityDepartmentToInsert0.AECOM_Department__c = mapAPD.get(oOrganizationWrapper.oOrganization.OrganizationName__c).Id;
                }
                /*else {
                
                oOpportunityDepartmentToInsert.Primary__c = false;
                oOpportunityDepartmentToInsert.AECOM_Department__c = '';
                
                }*/

                if (oOpportunityDepartmentToInsert0 != null) {
                    oOpportunityDepartmentToInsert0.split__c = oOrganizationWrapper.oProjectOrganization.ContributionPercent__c;
                    oOpportunityDepartmentToInsert0.Opportunity__c = opp.id;
                    lstOppDToInsert.add(oOpportunityDepartmentToInsert0);
                }
            }

        }        
        
        



        //Use Wellington / Tauranga / Christchurch 2594 for matching Org_String__c
        for (OrganizationWrapper oOrganizationWrapper : lSelectedOrganizations) {
            oOpportunityDepartmentToInsert = new Opportunity_Department__c();
            if (oOrganizationWrapper.strType == 'Supporting') {
                //AECOM_Primary_Department__c[] supportingDepartments = [SELECT ID FROM AECOM_Primary_Department__c  WHERE Org_String__c = :oOrganizationWrapper.oOrganization.OrganizationName__c LIMIT 1];

                if (mapAPD.containskey(oOrganizationWrapper.oOrganization.OrganizationName__c)) {
                    //if(supportingDepartments.size() > 0){

                    oOpportunityDepartmentToInsert.Primary__c = false;
                    //oOpportunityDepartmentToInsert.AECOM_Department__c = supportingDepartments[0].Id;    
                    oOpportunityDepartmentToInsert.AECOM_Department__c = mapAPD.get(oOrganizationWrapper.oOrganization.OrganizationName__c).Id;
                }
                /*else {
                
                oOpportunityDepartmentToInsert.Primary__c = false;
                oOpportunityDepartmentToInsert.AECOM_Department__c = '';
                
                }*/

                if (oOpportunityDepartmentToInsert != null) {
                    oOpportunityDepartmentToInsert.split__c = oOrganizationWrapper.oProjectOrganization.ContributionPercent__c;
                    oOpportunityDepartmentToInsert.Opportunity__c = opp.id;
                    lstOppDToInsert.add(oOpportunityDepartmentToInsert);
                }
            }

        }

        if (lstOppDToInsert.size() > 0) {
            try {
                insert lstOppDToInsert;
            } catch(Exception e) {
                ECO_Service_ErrorLog.formatPageError(e, 'Error while inserting opportunities departments for UpdateOpportunity: ' + e.getMessage());
            }
        }
        
        //system.debug('finish updating');
        

        //question for Sameer, update the opp departmets at object level???

        /*
        List<Opportunity_Department__c> lst = new List<Opportunity_Department__c> ();
        integer PrimaryCount = 0;
        Double SplitCount = 0;

        opp.AECOM_Department_2__c = null;
        opp.AECOM_Department_2_Percent__c = 0;

        opp.AECOM_Department_2_Practice_Area__c = null;
        opp.AECOM_Department_2_Sub_Practice_Area__c = null;

        opp.AECOM_Department_3__c = null;
        opp.AECOM_Department_3_Percent__c = 0;

        opp.AECOM_Department_3_Practice_Area__c = null;
        opp.AECOM_Department_3_Sub_Practice_Area__c = null;

        opp.AECOM_Department_4__c = null;
        opp.AECOM_Department_4_Percent__c = 0;

        opp.AECOM_Department_4_Practice_Area__c = null;
        opp.AECOM_Department_4_Sub_Practice_Area__c = null;

        opp.AECOM_Department_5__c = null;
        opp.AECOM_Department_5_Percent__c = 0;
        opp.AECOM_Department_5_Practice_Area__c = null;
        opp.AECOM_Department_5_Sub_Practice_Area__c = null;

        opp.AECOM_Department_6__c = null;
        opp.AECOM_Department_6_Percent__c = 0;
        opp.AECOM_Department_6_Practice_Area__c = null;
        opp.AECOM_Department_6_Sub_Practice_Area__c = null;

        integer RegularDeptCount = 2;
        for (Opportunity_Department__c od : lstOppDToInsert) {

            if (od.AECOM_Department__c != null) {
                string currentKey = od.AECOM_Department__c;
                if (od.Practice_Area__c != null) {
                    currentKey = currentKey + od.Practice_Area__c;
                }
                if (od.Sub_Practice_Area__c != null) {
                    currentKey = currentKey + od.Sub_Practice_Area__c;
                }


                if (!od.Primary__c) {
                    if (RegularDeptCount == 2) {
                        opp.AECOM_Department_2__c = od.AECOM_Department__c;
                        opp.AECOM_Department_2_Percent__c = od.Split__c;
                        if (od.Practice_Area__c != null) {
                            opp.AECOM_Department_2_Practice_Area__c = od.Practice_Area__c;
                        }
                        if (od.Sub_Practice_Area__c != null) {
                            opp.AECOM_Department_2_Sub_Practice_Area__c = od.Sub_Practice_Area__c;
                        }
                    }
                    if (RegularDeptCount == 3) {
                        opp.AECOM_Department_3__c = od.AECOM_Department__c;
                        opp.AECOM_Department_3_Percent__c = od.Split__c;
                        if (od.Practice_Area__c != null) {
                            opp.AECOM_Department_3_Practice_Area__c = od.Practice_Area__c;
                        }
                        if (od.Sub_Practice_Area__c != null) {
                            opp.AECOM_Department_3_Sub_Practice_Area__c = od.Sub_Practice_Area__c;
                        }
                    }
                    if (RegularDeptCount == 4) {
                        opp.AECOM_Department_4__c = od.AECOM_Department__c;
                        opp.AECOM_Department_4_Percent__c = od.Split__c;
                        if (od.Practice_Area__c != null) {
                            opp.AECOM_Department_4_Practice_Area__c = od.Practice_Area__c;
                        }
                        if (od.Sub_Practice_Area__c != null) {
                            opp.AECOM_Department_4_Sub_Practice_Area__c = od.Sub_Practice_Area__c;
                        }
                    }
                    if (RegularDeptCount == 5) {
                        opp.AECOM_Department_5__c = od.AECOM_Department__c;
                        opp.AECOM_Department_5_Percent__c = od.Split__c;
                        if (od.Practice_Area__c != null) {
                            opp.AECOM_Department_5_Practice_Area__c = od.Practice_Area__c;
                        }
                        if (od.Sub_Practice_Area__c != null) {
                            opp.AECOM_Department_5_Sub_Practice_Area__c = od.Sub_Practice_Area__c;
                        }
                    }
                    if (RegularDeptCount == 6) {
                        opp.AECOM_Department_6__c = od.AECOM_Department__c;
                        opp.AECOM_Department_6_Percent__c = od.Split__c;
                        if (od.Practice_Area__c != null) {
                            opp.AECOM_Department_6_Practice_Area__c = od.Practice_Area__c;
                        }
                        if (od.Sub_Practice_Area__c != null) {
                            opp.AECOM_Department_6_Sub_Practice_Area__c = od.Sub_Practice_Area__c;
                        }
                    }
                    RegularDeptCount++;
                }
            }
        }

        update opp;
        */



    }
    
    private id CreateOpportunity() {


        opportunity oOpportunityToInsert = new opportunity();
        Opportunity_Department__c oOpportunityDepartmentToInsert;
        oOpportunityToInsert.name = oProject.name;
        oOpportunityToInsert.Description = oProject.ProjectDescription__c;

        //US-2492 : commented out as part of the request recieved in 2492 31 March 2016 testing.
        //oOpportunityToInsert.Enterprise_Service__c = oProject.clAECOMServiceType__c;

        oOpportunityToInsert.closeDate = oProject.EstimatedStartDate__c;
        oOpportunityToInsert.Stagename = '1 Lead';
        oOpportunityToInsert.Previous_StageName__c = '1 Lead';
        oOpportunityToInsert.probability = 100;
        oOpportunityToInsert.accountid = oPrimaryEnd.osite.Account__c;
        oOpportunityToInsert.TO_Procurement_Method__c = 'Competitive Task Orders';
        oOpportunityToInsert.Master_Contract_lookup__c = sSelectedOpportunityId;
        oOpportunityToInsert.Capture_Manager_User__c = UserInfo.getUserId();
        //oOpportunityToInsert.Capture_Manager_User__c = oProject.CaptureManagerUser__c;

        oOpportunityToInsert.recordtypeid = idSelectedOppRecType;
        oOpportunityToInsert.ProjectCountry__c = oppProjectCountryName;

        oOpportunityToInsert.Estimated_work_start_date__c = oProject.EstimatedStartDate__c;
        //system.debug('closeDate - Estimated_work_start_date__c: ' + oOpportunityToInsert.closeDate + ' - ' + oOpportunityToInsert.Estimated_work_start_date__c);


        map<string, AECOM_Primary_Department__c> mapAPD = new map<string, AECOM_Primary_Department__c> ();
        set<string> sOrgNames = new set<string> ();

        for (OrganizationWrapper po : lSelectedOrganizations)
        {
            sOrgNames.add(po.oOrganization.OrganizationName__c);
        }

        list<AECOM_Primary_Department__c> lstAPD = new list<AECOM_Primary_Department__c> ();

        try {
            lstAPD = [SELECT ID, Org_String__c FROM AECOM_Primary_Department__c WHERE Org_String__c IN :sOrgNames];
        } catch(Exception e) {
            ECO_Service_ErrorLog.formatPageError(e, 'Error while searching for AECOM Primary Department during CreateOpportunity: ' + e.getMessage());
        }

        for (AECOM_Primary_Department__c APD : lstAPD) {
            mapAPD.put(APD.Org_String__c, APD);
        }

        for (OrganizationWrapper oOrganizationWrapper : lSelectedOrganizations) {
            if (oOrganizationWrapper.strType == 'Primary') {
                //AECOM_Primary_Department__c[] primaryDeptartments = [SELECT ID FROM AECOM_Primary_Department__c  WHERE Org_String__c = :oOrganizationWrapper.oOrganization.OrganizationName__c LIMIT 1];
                //if(primaryDeptartments.size() > 0){
                if (mapAPD.containskey(oOrganizationWrapper.oOrganization.OrganizationName__c)) {
                    /*
                      Setting the AECOM_Primary_Dept_Lookup__c is required to create the Go/NoGo Conversation record
                      which is a requirement in US-02492
                     */

                    //oOpportunityToInsert.AECOM_Primary_Dept_Lookup__c = primaryDeptartments[0].Id;

                    oOpportunityToInsert.AECOM_Primary_Dept_Lookup__c = mapAPD.get(oOrganizationWrapper.oOrganization.OrganizationName__c).Id;
                    oOpportunityToInsert.AECOM_Primary_Department_Percent__c = oOrganizationWrapper.oProjectOrganization.ContributionPercent__c;
                    //System.debug('********SA********** - Setting the AECOM_Primary_Dept_Lookup__c: ' + oOpportunityToInsert.AECOM_Primary_Dept_Lookup__c);
                    //System.debug('********SA********** - Setting the AECOM_Primary_Department_Percent__c: ' + oOpportunityToInsert.AECOM_Primary_Department_Percent__c);
                    //oOpportunityToInsert.Practice_Area_of_Primary_AECOM_Dept__c = oProject.clAECOMWork__c;
                }

            }
        }

        //US-3638
        oOpportunityToInsert.ValidateGo__c = false;

        //US-4409
        oOpportunityToInsert.CurrencyIsoCode = oProject.CurrencyIsoCode;

        insert oOpportunityToInsert;


        list<Opportunity_Department__c> lstOppDToInsert = new list<Opportunity_Department__c> ();

        //Use Wellington / Tauranga / Christchurch 2594 for matching Org_String__c
        for (OrganizationWrapper oOrganizationWrapper : lSelectedOrganizations) {
            oOpportunityDepartmentToInsert = new Opportunity_Department__c();
            if (oOrganizationWrapper.strType == 'Supporting') {
                //AECOM_Primary_Department__c[] supportingDepartments = [SELECT ID FROM AECOM_Primary_Department__c  WHERE Org_String__c = :oOrganizationWrapper.oOrganization.OrganizationName__c LIMIT 1];

                if (mapAPD.containskey(oOrganizationWrapper.oOrganization.OrganizationName__c)) {
                    //if(supportingDepartments.size() > 0){

                    oOpportunityDepartmentToInsert.Primary__c = false;
                    //oOpportunityDepartmentToInsert.AECOM_Department__c = supportingDepartments[0].Id;    
                    oOpportunityDepartmentToInsert.AECOM_Department__c = mapAPD.get(oOrganizationWrapper.oOrganization.OrganizationName__c).Id;
                }

                if (oOpportunityDepartmentToInsert != null) {
                    oOpportunityDepartmentToInsert.split__c = oOrganizationWrapper.oProjectOrganization.ContributionPercent__c;
                    oOpportunityDepartmentToInsert.Opportunity__c = oOpportunityToInsert.id;
                    lstOppDToInsert.add(oOpportunityDepartmentToInsert);
                }
            }

        }

        if (lstOppDToInsert.size() > 0) {
            try {
                insert lstOppDToInsert;
            } catch(Exception e) {
                ECO_Service_ErrorLog.formatPageError(e, 'Error while inserting opportunities departments for CreateOpportunity: ' + e.getMessage());
            }
        }

        return oOpportunityToInsert.id;
    }

    /** ---------------------------------------------------------------------------------------
     * @Description <Selection of Opportunities><br/>
     * <ePM users do not have a SF license that gives them read privileges to the Opportunity data.
     * Because of this we cannot use the standard paging mechanism and instead must rely on the Show More
     * technique.  The following will fail for ePM users>:
     * setConOpportunities = new ApexPages.StandardsetController(Database.getQueryLocator(strSOQL));
     * lstSearchOpportunities = (list<Opportunity>)setConOpportunities.getRecords(); 
     *
     * @Author NTT Data/AECOM - 
     * @Date May 2016 - Adding show more to Opportunity selection tab
     *----------------------------------------------------------------------------------------*/
    private void SearchOpportunities() {
        list<Site__c> listSearchSites = new list<Site__c> ();
        set<id> setSitesToSearch = new set<id> ();
        set<id> setAccountsToSearch = new set<id> ();

        for (sitewrapper oSiteWrapper : lstSites) {
            setSitesToSearch.add(oSiteWrapper.oSite.id);
        }


        if (setSitesToSearch.size() > 0) {
            listSearchSites = [SELECT ID, Account__c FROM SITE__C WHERE ID IN :setSitesToSearch];
        }

        for (site__c oSite : listSearchSites) {
            setAccountsToSearch.add(oSite.Account__c);
        }

        if (listSearchSites.size() > 0) {
            string strSOQL = 'SELECT ';
            boolean boolAtLeastOne = false;

            for (Schema.FieldSetMember fsmField : SObjectType.opportunity.FieldSets.pse_OpportunityFieldsForSearchResult.getFields()) {
                strSOQL += fsmField.getFieldPath() + ', ';
            }

            strSOQL += 'ID, Name, createdby.name, recordtype.name, AcctName__c, Enterprise_Service__c, Net_Revenue_TO_Project__c, AECOM_Primary_Dept_Lookup__c, Primary_Department_read_only__c, type, StageName, Opportunity_ID__c, AECOM_Role__c, Business_Line_of_Primary_AECOM_Dept__c, Geography_Formula__c, Lead_Region_Formula__c, Lead_District_Formula__c, Sub_Practice_Area_of_Primary_AECOM_Dept__c, Sub_Practice_Area_of_Primary_AECOM_Dept__r.name, Subs_Other_Revenue__c, AECOM_Fee__c, Amount, RecordTypeText__c, Estimated_work_start_date__c ';
            strSOQL += 'FROM OPPORTUNITY WHERE Accountid IN: setAccountsToSearch ';
            strSOQL += 'AND (NOT StageName Like \'6%\') AND (NOT StageName Like \'9%\') ORDER BY StageName ASC, name ASC LIMIT ' + iOppLimit;

            //US-07208
            /*
            strSOQL += 'ID, Name, createdby.name, recordtype.name, AcctName__c, Enterprise_Service__c, Net_Revenue_TO_Project__c, AECOM_Primary_Dept_Lookup__c, Primary_Department_read_only__c, type, StageName, Opportunity_ID__c, AECOM_Role__c, Business_Line_of_Primary_AECOM_Dept__c, Geography_Formula__c, Lead_Region_Formula__c, Lead_District_Formula__c, Sub_Practice_Area_of_Primary_AECOM_Dept__c, Sub_Practice_Area_of_Primary_AECOM_Dept__r.name, Subs_Other_Revenue__c, AECOM_Fee__c, Amount, RecordTypeText__c, Estimated_work_start_date__c ';
            strSOQL += 'FROM OPPORTUNITY WHERE Accountid IN: setAccountsToSearch ';
            strSOQL += 'AND (NOT StageName Like \'6%\') AND (NOT StageName Like \'9%\') ';
            strSOQL += 'AND (StageName <> \'5A Program in Negotiation\') AND (StageName <> \'5B Program Signed and Active\') '; 
            strSOQL += 'AND (StageName <> \'7 Canceled by Client\') AND (StageName <> \'8 No-Go\')  ';
            strSOQL += 'ORDER BY StageName ASC, name ASC LIMIT ' + iOppLimit;
            */
            
            lstSearchOpportunities = (list<opportunity>) Database.query(strSOQL);
            getOppClone();

            if (lstSearchOpportunities.isEmpty()) {
                searchResults = true;
            } else {
                searchResults = false;
            }

            if (lstSearchOpportunities.size() < oppLessLIMIT) {
                bShowMoreButtonOpp = false;
            } else {
                bShowMoreButtonOpp = true;
            }
            booDisplayOpportunitySearch = true;
        }
    }


    ///////////////////////////


    private void getOppClone() {
        strSearchResults = string.valueof(lstSearchOpportunities.size()) + ' Record(s) Found';

        mapOpportunitySearch = new map<id, opportunity> ();
        lstOppClone = new list<oppClone> ();
        list<SelectOption> loTempOpp = new list<SelectOption> ();

        List<String> args = new String[] { '0', 'number', '###,###,##0' };

        for (opportunity oOpportunity : lstSearchOpportunities) {
            mapOpportunitySearch.put(oOpportunity.id, oOpportunity);

            oppClone oClone = new oppClone();
            oClone.id = oOpportunity.id;
            oClone.acctName = oOpportunity.AcctName__c;
            oClone.oppName = oOpportunity.name;
            oClone.capManager = oOpportunity.CaptureManager__c;
            oClone.createdDate = oOpportunity.createdDate.format();
            oClone.organization = oOpportunity.Primary_Department_read_only__c;
            oClone.oppNumber = oOpportunity.Opportunity_ID__c;
            oClone.stage = oOpportunity.StageName;
            oClone.type = oOpportunity.recordtype.name;
            oClone.AECOMrole = oOpportunity.AECOM_Role__c;
            oClone.PrimaryDepartment = oOpportunity.Primary_Department_read_only__c;
            oClone.BusinessUnit = oOpportunity.Business_Line_of_Primary_AECOM_Dept__c;
            oClone.Geography = oOpportunity.Geography_Formula__c;
            oClone.LeadRegion = oOpportunity.Lead_Region_Formula__c;
            oClone.LeadDistrict = oOpportunity.Lead_District_Formula__c;
            oClone.CreatedByName = oOpportunity.createdby.name;

            if (oOpportunity.Sub_Practice_Area_of_Primary_AECOM_Dept__c != null) {
                oClone.SubPracticeArea = oOpportunity.Sub_Practice_Area_of_Primary_AECOM_Dept__r.name;
            }

            if (oOpportunity.AECOM_Fee__c != null) {
                oClone.GrossAECOMrevenue = String.format(oOpportunity.AECOM_Fee__c.format(), args);
            }

            if (oOpportunity.Subs_Other_Revenue__c != null) {
                oClone.SubOtherRevenue = String.format(oOpportunity.Subs_Other_Revenue__c.format(), args);
            }
            if (oOpportunity.Net_Revenue_TO_Project__c != null) {
                oClone.NetRevenue = String.format(oOpportunity.Net_Revenue_TO_Project__c.format(), args);
            }

            if (oOpportunity.AECOM_Fee__c != null) {
                oClone.Value = String.format(oOpportunity.AECOM_Fee__c.format(), args);
            }

            //Add records with type Program to select list
            if (oOpportunity.recordtype.name.indexOf('Program') >= 0) {
                loTempOpp.add(new SelectOption(oOpportunity.id, oOpportunity.name));
            }
            lstOppClone.add(oClone);
        }
        //sort list of program opps        
        loTempOpp = ECO_SortOptionList.SortOptionList(loTempOpp);
        loOpportunities.add(new SelectOption('', '-- select a related opportunity --'));
        loOpportunities.addAll(loTempOpp);
    }


    ///////////////////////////


    /* Utility Method used for recursively obtaining a field from a multiple object relationship */
    private Object recursiveGet(sObject record, String field) {
        if (field.contains('.')) {
            Integer firstPeriod = field.indexOf('.');
            String nextObjectName = field.subString(0, firstPeriod);
            String remainingfieldName = field.subString(firstPeriod + 1, field.length());
            sObject nextObject = record.getSObject(nextObjectName);
            if (nextObject == null) {
                return null;
            } else {
                return recursiveGet(nextObject, remainingfieldName);
            }
        } else {
            return record.get(field);
        }
    }


    private void populateOppProjectCountryList() {
        Schema.DescribeFieldResult fieldResult = Opportunity.ProjectCountry__c.getDescribe();

        projCountryOptions = new list<SelectOption> ();

        projCountryOptions.add(new SelectOption('', '-- select a country --'));

        for (Schema.Picklistentry picklistEntry : fieldResult.getPicklistValues())
        {
            projCountryOptions.add(new SelectOption(pickListEntry.getValue(), pickListEntry.getLabel()));
        }
    }
}