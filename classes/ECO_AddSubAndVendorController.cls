public with sharing class ECO_AddSubAndVendorController {
    
    public String budgetHeaderId {get; set;}
    public String refresh {get; set;}
    public IBudgetSave parentController {get; set;}

	public BudgetHeader__c budgetHeader {get; set;}
	public pse__Proj__c theProject {get; set;}
    
    public Site__c oSite {get;set;}
    public id idSiteID {get;set;}
    
    public list<ECO_DTO_VendorSite> lstVendorSites {get;set;}
    
    public list<Site__c> lstSitesSearchResults {get;set;}
    
    public String searchAcctName {get; set;}
	public String searchCityTown {get; set;}
	public String searchStateProvinceEmirate {get; set;}
	public String searchCountry {get; set;}
    
    public String ready {
		get {
			init();
			return ready;
		}
		set;
	}
    
    public ECO_AddSubAndVendorController() { 
	}
    
    public void init() {
		budgetHeader = [select id, Project__c from BudgetHeader__c where id = :budgetHeaderId];

		if (budgetHeader.id == null)
			return;

		theProject = [select id, DefaultBillRate__c, DefaultUpliftLabor__c, DefaultUpliftSubs__c from pse__Proj__c where id = :budgetHeader.Project__c];
        
        oSite = new Site__c();
        oSite.account__r = new Account();
		
		populateSubVendor();
	}
    
    public void populateSubVendor() {
        lstVendorSites = new List<ECO_DTO_VendorSite>();
        
        string strSOQL = 'SELECT ';
    	
    	for (Schema.FieldSetMember fsmField: SObjectType.VendorSite__c.FieldSets.VendorFinder_Display_Fieldset.getFields()) {
    		strSOQL += fsmField.getFieldPath() + ', ';
    	}
    	
    	strSOQL += 'ID, SITE__c, Site__r.VendorSiteID__c, Site__r.City__c, Site__r.State__c, Site__r.Country__c, Site__r.Account__c, Site__r.AccountName__c, name FROM VendorSite__c WHERE Project__c=\'' + budgetHeader.Project__c + '\'';

    	List<VendorSite__c> vendorList = (list<VendorSite__c>)Database.query(strSOQL);
        for(VendorSite__c vendorSite : vendorLIst) {
        	lstVendorSites.add(new ECO_DTO_VendorSite(vendorSite));	    
        }
    }
    
    public PageReference addGenericResource() {
        BudgetResource__c genericBr = createBudgetResource(null);

        parentController.save();
        insert genericBr;

        return close();
    }

    public PageReference addExistingResource() {
		List<BudgetResource__c> budgetResourcestoInsert = new List<BudgetResource__c>();

		for (ECO_DTO_VendorSite vendorSite : lstVendorSites) {
			if (!vendorSite.selected)
				continue;
			budgetResourcestoInsert.add(createBudgetResource(vendorSite.vendorSite));
		}
        parentController.save();
		insert budgetResourcestoInsert;

		PageReference pr = new PageReference('/apex/' + refresh + '?id=' + budgetHeader.id);
		pr.setRedirect(true);

		return parentController.hardRefresh();
	}
    
    public PageReference close() {
        PageReference pr = new PageReference('/apex/' + refresh + '?id=' + budgetHeader.id);
		pr.setRedirect(true);

		return parentController.hardRefresh();
    }
    
    public PageReference SearchSites() {
        Set<Id> lstSiteIds = new Set<Id>();
        for(ECO_DTO_VendorSite eco_vendorSite : lstVendorSites) {
            lstSiteIds.add(eco_vendorSite.vendorSite.Site__c);  
        }
        system.debug('lstSiteIds = ' + lstSiteIds);

        string strSOQL = 'SELECT ';
        
        boolean boolAtLeastOne = false;
            
        for (Schema.FieldSetMember fsmField: SObjectType.Site__c.FieldSets.pse_ClientFinder_Search_Result_Fieldset.getFields()) {
            strSOQL += fsmField.getFieldPath() + ', ';
        }
        
        strSOQL += 'ID, Account__c FROM Site__c WHERE SiteStatus__c=\'A\' AND VendorSiteID__c != null ';
        
        if ((searchAcctName != null) && (!searchAcctName.trim().equals(''))) {
			strSOQL += ' and Account__r.Name like \'%' + searchAcctName.trim() + '%\'';
		}

		if ((searchCityTown != null) && (!searchCityTown.trim().equals(''))) {
			strSOQL += ' and City__c like \'%' + searchCityTown.trim() + '%\'';
		}

		if ((searchStateProvinceEmirate != null) && (!searchStateProvinceEmirate.trim().equals(''))) {
			strSOQL += ' and State__c like \'%' + searchStateProvinceEmirate.trim() + '%\'';
		}

		if ((searchCountry != null) && (!searchCountry.trim().equals(''))) {
			strSOQL += ' and Country__c like \'%' + searchCountry.trim() + '%\'';
		}
        
        strSOQL += ' AND Id NOT IN :lstSiteIds LIMIT 50';

        System.debug('SubsVendors search query: ' + strSOQL);

        lstSitesSearchResults = (list<Site__c>)Database.query(strSOQL);

        return null;        
    }
    
    public PageReference SelectSiteAsSub() {
    	VendorSite__c oVS = createVendorSite('Sub');
        
    	insert oVS;
        
    	populateSubVendor();
        parentController.save();
        insert createBudgetResource(oVS);
        
        PageReference pr = new PageReference('/apex/' + refresh + '?id=' + budgetHeader.id);
		pr.setRedirect(true);

		return parentController.hardRefresh();
    }

    public PageReference SelectSiteAsVendor() {
        VendorSite__c oVS = createVendorSite('Vendor');
    	insert oVS;
        
    	populateSubVendor();
        parentController.save();
        insert createBudgetResource(oVS);
        
        PageReference pr = new PageReference('/apex/' + refresh + '?id=' + budgetHeader.id);
		pr.setRedirect(true);

		return parentController.hardRefresh();
    }
    
    private VendorSite__c createVendorSite(String Type) {
        VendorSite__c vendorSite = new VendorSite__c();
    	vendorSite.Project__c = theProject.Id;
    	vendorSite.Site__c = idSiteID;
    	vendorSite.Type__c = Type;
        
        return vendorSite;
    }
    
    private BudgetResource__c createBudgetResource(VendorSite__c vendorSite) {
        BudgetResource__c budgetResource = new BudgetResource__c();
        budgetResource.BudgetHeader__c = budgetHeader.id;
        budgetResource.OverrideRatesOnLines__c = true;
        budgetResource.ResourceType__c = 'Subcontractor';
        budgetResource.OverrideBillRate__c = theProject.DefaultBillRate__c;
        budgetResource.OverrideUplift__c = theProject.DefaultUpliftSubs__c;
        budgetResource.JobName__c = null;
        budgetResource.VendorSite__c = vendorSite == null ? null : vendorSite.id;
        
        return budgetResource;
    }
}