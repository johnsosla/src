/***
Author: NTT Centerstance
Purpose: To provide extended controller capabilities for the client finder page
1.0 - Tim C - 02/02/2015 - Created
1.1 - Tim C - 02/02/2015 - Seperated out country risk and city
1.2 - Tim C - 04/11/2015 - Added Filter to eliminate dupes in the search
1.3 - Sameer Ahsan - 07/28/2016 - Added code to update Opportunity when a client is selected as Primary.
***/


/** ---------------------------------------------------------------------------------------
* @Description To provide extended controller capabilities for the client finder page<br/>
* <To provide extended controller capabilities for the client finder page>
*
* @Author NTT Data/AECOM - 
* @Date July 2016 - Added code to update Opportunity when a client is selected as Primary.
*----------------------------------------------------------------------------------------*/
public with sharing virtual class ECO_ClientFinderController{

	public list<Project_Site__c> lstProjectSites {get;set;}
	public list<Site__c> lstSitesSearchResults {get;set;}
	public map<id, Site__c> mapSearchSites {get;set;}
    public map<string, Site__c> mapUniqueSites {get;set;}
	public map<id, Project_Site__c> mapProjectSites {get;set;}
	public map<id, Project_Site__c> mapSitesBilling {get;set;}
    public map<id, Project_Site__c> mapSitesEnd {get;set;}
    public map<id, list<SelectOption>> mapSiteIDtoOptions{get;set;}

	public Site__c oSite {get;set;}

	public pse__Proj__c oProject {get;set;}

    public Opportunity oOpportunity {get;set;}

	public id idSiteID {get;set;}

	public string strSearchResults {get;set;}
	public string strNoRecords {get;set;}

	//public boolean boolShowSiteSearch {get;set;}
	public boolean booDisplaySiteSearchResult {get;set;}
	public boolean booNewProject {get;set;}

    private Project_Site__c oTopTask;
    private Project_Site__c oPrimaryEnd;

    private string sSiteLimit;

    private boolean bSiteMore;

    public boolean bShowMoreButtonSite {get;set;}

    public string showMoreSiteText {get;set;}

    private static string siteLessLIMIT = '50';
    private static string siteMoreLIMIT = '200';
    public integer iSiteRowDelete {get;set;}

    public boolean bSearchOutsideUserOrg {get;set;}

    public siteSearchWrapper oSiteSearch {get;set;}

    public OrganizationString__c userOrg {get;set;}

    public Id oOpportunityId {get;set;}

	/* Custom classes to facilitate this controller */
	public class EcoControllerException extends Exception {}


    public class siteSearchWrapper{
        public string name {get;set;}
        public string city {get;set;}
        public string country {get;set;}
        public string province {get;set;}

        public siteSearchWrapper(){
            name = null;
            city = null;
            country = null;
            province = null;
        }

    }

	/* Constructor */
    public ECO_ClientFinderController(ApexPages.StandardController oStandardController) {

        bSearchOutsideUserOrg = false;
        oSiteSearch = new siteSearchWrapper();

        sSiteLimit = siteLessLIMIT;

        bSiteMore = false;

        bShowMoreButtonSite = false;

        //oOpportunityId = null;

        showMoreSiteText = 'Show More';

        oSite = new Site__c();
        oSite.account__r = new account();
        this.oProject = (pse__Proj__c)oStandardController.getRecord();

        /*
        //Identify the Opportunity linked to this project
        try
        {
            oOpportunity = [select Id from Opportunity where Id = :oProject.pse__Opportunity__c];
        }
        catch( Exception e)
        {
            ECO_Service_ErrorLog.logException(e); 
        }
        */

        mapSitesBilling = new map<id, Project_Site__c>();
        mapSitesEnd = new map<id, Project_Site__c>();


		if(ECO_Utils_String.NullCheck(this.oProject.id) == ''){
			ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'You have reached this page improperly, please access it from the Project screen.');
            ApexPages.addMessage(oPageMessage);
            mapSiteIDtoOptions = new map<id, list<SelectOption>>();
            return;
        } else {
        	UpdateProjectSites();
        }

        SearchUserOrganization();

	}

    public void SearchUserOrganization(){

        list<user> lUser = [SELECT ECO_OrganizationName__c FROM User WHERE ID =:UserInfo.getUserId()];

        list<OrganizationString__c> lUserOrganizations = [SELECT Id, Name, OrganizationName__c, GeographyName__c, Region__c, District__c, Department__c, BusinessLineName__c, LocationName__c, PLManagerContact__c, ProjectOwning__c, FinanceandAccountingManagerContact__c, CFOorDelegateContact__c, OUID__c, CurrencyIsoCode, ProjectApprover__c, ProjectAccountant__c, ProjectAccountant2__c, FinanceLead2__c FROM OrganizationString__c WHERE Name =: lUser[0].ECO_OrganizationName__c and  (InactiveDate__c > TODAY OR InactiveDate__c = null)];

        if(lUserOrganizations.size() > 0){
            userOrg = lUserOrganizations[0];
        } else {
            userOrg = null;
        }
      
    }


    private void showMoreSites(){
        showMoreSiteText = 'Show Less';
        sSiteLimit = siteMoreLIMIT;
        bSiteMore = true;
    }

    private void showLessSites(){
        showMoreSiteText = 'Show More';
        sSiteLimit = siteLessLIMIT;
        bSiteMore = false;
    }


    public void toggleSiteShow(){
        If(bSiteMore){
            showLessSites();
            SearchSites();
        } else {
            showMoreSites();
            SearchSites();
        }
    }

    public PageReference RemoveSite(){

        list<Project_Site__c> lstPSTemp = new list<Project_Site__c>();
        lstPSTemp.addall(lstProjectSites);

        Project_Site__c psDelete = lstProjectSites[iSiteRowDelete];
        lstProjectSites.remove(iSiteRowDelete);

        if(!validate()){
            lstProjectSites = lstPSTemp;
            return null;
        }

        delete psDelete;
 
        return null;
    }

    /*public PageReference stub(){
        return null;
    }*/

	public PageReference SelectSite() {

		if(mapProjectSites.containskey(idSiteID)) {
			return null;
		}

		Site__c SelectedSite = mapSearchSites.get(idSiteID);

        List<SelectOption> contacts = new List<SelectOption>();

        for(contact c:[select id, lastname, firstname, Oracle_ID__c from contact where site__c =: idSiteID]){
            contacts.add(new SelectOption(c.Oracle_ID__c, c.lastname + ', ' + c.firstname));
        }

        mapSiteIDtoOptions.put(idSiteID, contacts);

        string billingid = null;

        if(contacts.size() > 0){
            billingid = contacts[0].getValue();
        }


		Project_Site__c oProjectSite = new Project_Site__c(BillingContactID__c = billingid,  site__c = idSiteID, Project__c = oProject.id, name = SelectedSite.AccountName__c, Contribution__c = 0 );

        lstProjectSites.add(oProjectSite);

        if(lstProjectSites.size() == 1){
            oProjectSite.Contribution__c = 100;
        }

		save();
		//UpdateProjectSites();


		return null;
	}

    public boolean validate(){
        //validate
        decimal contribution = 0;

        System.debug('cp validate begin');

        for(Project_Site__c ps: lstProjectSites){
            System.debug('cp validate ');

            contribution += ps.Contribution__c;

            if(ps.Is_Billing__c && ps.Contribution__c <= 0 && !ps.Project__r.EnableTopTaskCustomerFlag__c){
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'Client ' + ps.Account_Name__c + ' cannot have a contribution <= 0 when it is billing and the project is not a top task customer.'));        
                System.debug('cp validate failed');
                return false; 
            }
        }

        if(contribution != 100){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'Contributions must equal 100%'));        
            return false;        
        }

        return true;
    }


	public void save(){

            System.debug('cp save begin ');

            if(!validate()){
                return;
            }

            System.debug('cp save begin crossed validation ');

			Savepoint oSavePoint = Database.setSavepoint();

            try {
                update oProject;
                upsert lstProjectSites;

                UpdateProjectSites();

                System.debug('cp save begin before opp null check ');

                if (oOpportunity != null)
                {
                    try
                    {
                        update oOpportunity;
                    }
                    catch (Exception e) 
                    {
                        System.debug('cp save begin update opp fail ' + e.getMessage());
                        ECO_Service_ErrorLog.logException(e);
                    } 
                }

            } catch (Exception e) {
                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to update a Project. Please contact your administrator with the following error: ' + e);
                ApexPages.addMessage(oMsg);
                Database.rollback(oSavePoint);
                return;
            }
	}  

    //The save() method gets called on Save or Select, this is only called when the user clicks Save
    public PageReference stubsave(){
        for(Project_Site__c ps: lstProjectSites){
            if(!(ps.Is_Billing__c || ps.Is_End__c))
            {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'Each account must have either Billing Client or End Client checked.'));        
                return null;        
            }
        }

        save();
        return null;
    }


	/* Re-Usable Method for Querying Project Sites */
	public void UpdateProjectSites(){

    	string strSOQL = 'SELECT ';
    	
    	for (Schema.FieldSetMember fsmField: SObjectType.Project_Site__c.FieldSets.pse_ClientFinder_Display_Fieldset.getFields()) {
    		strSOQL += fsmField.getFieldPath() + ', ';
    	}
    	
    	strSOQL += 'BillingContactID__c, ID, SITE__C, Is_Billing__c, Is_Default_Top_Task__c, Is_End__c, Is_Primary_End__c, Site__r.Account__c, Contribution__c, Project__r.EnableTopTaskCustomerFlag__c, Project__r.pse__Stage__c  FROM Project_Site__c WHERE Project__c=\'' + oProject.Id + '\'';

    	lstProjectSites = (list<Project_Site__c>)Database.query(strSOQL);


    	mapProjectSites = new map<id, Project_Site__c>();

    	for(Project_Site__c oProjectSite: lstProjectSites){
    		mapProjectSites.put(oProjectSite.site__c, oProjectSite);
    		if(oProjectSite.Is_End__c){
    			mapSitesEnd.put(oProjectSite.id, oProjectSite);
    		}
    		if(oProjectSite.Is_Billing__c){
    			mapSitesBilling.put(oProjectSite.id, oProjectSite);
    		}
    	}

        mapSiteIDtoOptions = new map<id, list<SelectOption>>();


        set<id> sitesid = new set<id>();

        for(Project_Site__c oProjectSite: lstProjectSites){
            sitesid.add(oProjectSite.SITE__C);
            mapSiteIDtoOptions.put(oProjectSite.Site__c, new List<SelectOption>());
        }
        

        for(contact c:[select id, lastname, firstname, Oracle_ID__c, Site__c from contact where site__c IN: sitesid]){
            if(c.Oracle_ID__c != null){
                mapSiteIDtoOptions.get(c.Site__c).add(new SelectOption(c.Oracle_ID__c, c.lastname + ', ' + c.firstname));
            }
            system.debug('DEBUG****: ' + c.Site__c);
        }


	} 

	/* Utility Method used for recursively obtaining a field from a multiple object relationship */
  	private Object recursiveGet(sObject record, String field) {
		if(field.contains('.')) {
			Integer firstPeriod = field.indexOf('.');
			String nextObjectName = field.subString(0, firstPeriod);
			String remainingfieldName = field.subString(firstPeriod + 1, field.length());
			sObject nextObject = record.getSObject(nextObjectName);
			if(nextObject == null) {
				return null;
			} else {
				return recursiveGet(nextObject, remainingfieldName);
			}
		} else {
			return record.get(field);	
		}
	}


	/* Executes the request to handle dynamics parameters and query Sites */
	public PageReference SearchSites(){


        if((userOrg == null || userOrg.OUID__c == null) && bSearchOutsideUserOrg == false){
            return null;
        }
        
        recordtype rtOO = [select id from recordtype where developername='Oracle_Only'];
        string oracleRTFilter = rtOO.id;

        oSite.Account__r.name = oSiteSearch.name; 
        oSite.City__c = oSiteSearch.city;
        oSite.Country__c = oSiteSearch.country;       
        oSite.State__c = oSiteSearch.province;


        string strSOQL = 'SELECT ';
        string strWhereClause = ' WHERE '; 
        boolean boolAtLeastOne = false;
            
        for (Schema.FieldSetMember fsmField: SObjectType.Site__c.FieldSets.pse_ClientFinder_Search_Result_Fieldset.getFields()) {
            strSOQL += fsmField.getFieldPath() + ', ';
        }
        
        strSOQL += 'ID, Account__c, CustomerSiteUseCode__c FROM Site__c';
        //strSOQL += 'ID, Account__c, OracleCustomerID__c, CustomerSiteUseCode__c FROM Site__c';

        for (Schema.FieldSetMember fsmField: SObjectType.Site__c.FieldSets.pse_ClientFinder_Search_Fieldset.getFields()) {
            
            // Only add parameters to the "WhereClause" string if they contain valid values. 
            // NOTE: only strings are supported by this code.
            if ( recursiveGet(oSite,fsmField.getFieldPath()) != null && recursiveGet(oSite,fsmField.getFieldPath()) != '') {
                strWhereClause += fsmField.getFieldPath() + ' LIKE \'%' + recursiveGet(oSite,fsmField.getFieldPath()) + '%\' AND ';
                boolAtLeastOne = true;
            }
        }       
        
        // Determines if the code found at least one non-null/non-blank search parameter. If so, manipulate the "where string" to strip the last " AND " text
        // and add it to the SOQL statement.
        if (boolAtLeastOne) {
            strWhereClause = strWhereClause.substring(0,strWhereClause.length() - 5);
            strSOQL += strWhereClause;
        }
        
        //strSOQL += ' and  SiteStatus__c = \'A\'';

        if(bSearchOutsideUserOrg){
            if(boolAtLeastOne){
                strSOQL += ' and  SiteStatus__c = \'A\' and Account__r.recordtypeid !=: oracleRTFilter and VendorSiteID__c = null ORDER BY Account__r.name ASC  LIMIT ' + sSiteLimit;
            } else {
                strSOQL += ' WHERE Account__r.recordtypeid !=: oracleRTFilter and  SiteStatus__c = \'A\' and VendorSiteID__c = null  ORDER BY Account__r.name ASC  LIMIT ' + sSiteLimit;
            }
        } else {

            string userOrgID = userOrg.OUID__c;

            if(boolAtLeastOne){
                strSOQL += ' and  SiteStatus__c = \'A\' AND OUID__c =: userOrgID and Account__r.recordtypeid !=: oracleRTFilter and VendorSiteID__c = null  ORDER BY Account__r.name ASC  LIMIT ' + sSiteLimit;
            } else {
                strSOQL += ' WHERE OUID__c =: userOrgID and  SiteStatus__c = \'A\' and Account__r.recordtypeid !=: oracleRTFilter and VendorSiteID__c = null  ORDER BY Account__r.name ASC  LIMIT ' + sSiteLimit;
            }
        }

        //strSOQL += ' and  SiteStatus__c = \'A\'';
        //strSOQL += ' LIMIT ' + sSiteLimit;

        lstSitesSearchResults = (list<Site__c>)Database.query(strSOQL);

        IF(lstSitesSearchResults.size() < integer.valueof(siteLessLIMIT)){
            bShowMoreButtonSite = false;
        } else {
            bShowMoreButtonSite = true;
        }

        
        booDisplaySiteSearchResult = true;



        mapSearchSites = new map<id, Site__c>();
        if(lstSitesSearchResults.size() > 0) {
            for (Site__c oSearchSite: lstSitesSearchResults){
                mapSearchSites.put(oSearchSite.id, oSearchSite);
            }
        }

        return null;         
	}

	public PageReference BillingSelect(){

        for (Project_Site__c oSiteWrapper: lstProjectSites) {
            if(oSiteWrapper.id == idSiteID){
                if (oSiteWrapper.Is_Billing__c) {
                    mapSitesBilling.put(idSiteID, oSiteWrapper);
                } else {
                    mapSitesBilling.remove(idSiteID);
                    oSiteWrapper.Is_Default_Top_Task__c = false;
                    oTopTask = null;
                }
            }
        }

        if(oTopTask == null && mapSitesBilling.size() > 0){
            mapSitesBilling.values()[0].Is_Default_Top_Task__c = true;
            oTopTask = mapSitesBilling.values()[0];
        }

        save();
		//UpdateProjectSites();

        return null;
    }

    public PageReference EndSelect(){
        for (Project_Site__c oSiteWrapper: lstProjectSites) {
            if(oSiteWrapper.id == idSiteID){
                if (oSiteWrapper.Is_End__c) {
                    mapSitesEnd.put(idSiteID, oSiteWrapper);
                } else {
                    mapSitesEnd.remove(idSiteID);
                    oSiteWrapper.Is_Primary_End__c = false;
                    oPrimaryEnd = null;
                }
            }
        }

        if(oPrimaryEnd == null && mapSitesEnd.size() > 0){
            mapSitesEnd.values()[0].Is_Primary_End__c = true;
            oPrimaryEnd = mapSitesEnd.values()[0];
            idSiteID = oPrimaryEnd.id;
            //SearchOpportunities();
        }

        if(mapSitesEnd.size() == 0) {
            strSearchResults = null;
        }

        save();
		//UpdateProjectSites();

        return null;
    }


    /**
     * 
     *
     * @Author  NTT Data/AECOM
     * @Date    NTT Data/AECOM
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference DefaultTopSelect()
    {
        System.debug('cp begin ');
        //Identify the Opportunity linked to this project
        pse__Proj__c p; 
        try
        {
            p = [select pse__Opportunity__c from pse__Proj__c where Id =: this.oProject.id LIMIT 1];
        }
        catch(Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e,'Project information was not able to be retrieved.');
            return null;
        } 

        System.debug('cp before loop ');

        for (Project_Site__c oSiteWrapper: lstProjectSites) {
            System.debug('cp oSiteWrapper.Is_Default_Top_Task__c ' + oSiteWrapper.Is_Default_Top_Task__c);
            if(oSiteWrapper.id == idSiteID){
                oSiteWrapper.Is_Default_Top_Task__c = true;
                oTopTask = oSiteWrapper;
                oProject.DefaultTopTaskCustomer__c = oSiteWrapper.site__r.account__c;

                System.debug('cp oProject.DefaultTopTaskCustomer__c ' + oProject.DefaultTopTaskCustomer__c);

                oProject.PrimaryBillingClient__c = oSiteWrapper.site__c;

                if (p.pse__Opportunity__c != null)
                {
                    oOpportunity = new Opportunity();
                    oOpportunity.Id = p.pse__Opportunity__c;
                    oOpportunity.accountid = oSiteWrapper.site__r.account__c;

                    System.debug('cp oOpportunity.Id ' + oOpportunity.Id);
                    System.debug('cp oOpportunity.accountid ' + oOpportunity.accountid);
                }

            } else {
                oSiteWrapper.Is_Default_Top_Task__c = false;
            }
        }

		save();

        return null;
    }


    public PageReference PrimaryEndSelect(){

        for (Project_Site__c oSiteWrapper: lstProjectSites) {
            if(oSiteWrapper.id == idSiteID){
                oSiteWrapper.Is_Primary_End__c = true;
                oPrimaryEnd = oSiteWrapper;
                oProject.pse__Account__c = oSiteWrapper.site__r.account__c;
                oProject.PrimarySite__c = oSiteWrapper.site__c;

                oProject.PrimaryEndClient__c = oSiteWrapper.site__c;

            } else {
                oSiteWrapper.Is_Primary_End__c = false;
            }
        }

		save();
		//UpdateProjectSites();

        return null;
    }


}