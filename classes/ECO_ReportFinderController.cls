public with sharing class ECO_ReportFinderController extends ECO_PageControllerBase {
	
	public String searchReportName								{ get; set; }
	public Map<Id, ConfigItemWrapper> configItemsOnPage			{ get; set; }
	public Map<Id, Configuration__c> selectedConfigItems		{ get; set; }
	public Id selectedReportId									{ get; set; }
	public User theUser											{ get; set; }
	public List<Configuration__c> configItemsFromReportQuery	{ get; set; }
	public String orderedReports								{ get; set; }
	public List<Configuration__c> orderedUserConfigItems		{ get; set; }
	public String photoUrl										{ get; set; }
	
	private Date fromDate;
	private class ECO_ReportFinderControllerException extends Exception {}
	private System.LoggingLevel debugLevel = LoggingLevel.INFO;
	private String retURL;
	
	public ECO_ReportFinderController () {
		
		Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');
		
		if (!Test.isRunningTest()) {
			photoUrl = ConnectApi.ChatterUsers.getPhoto(null, UserInfo.getUserId()).smallPhotoUrl;
		}
		
		this.configItemsOnPage = new Map<Id, ConfigItemWrapper>();
		this.selectedConfigItems = new Map<Id, Configuration__c>();
		this.theUser = ECO_Service_Users.getUserInfoById(UserInfo.getUserId());
		this.theUser.Date_of_Birth__c = Date.today().addYears(-1);
		this.orderedUserConfigItems = new List<Configuration__c>();
		
		// prepopulate already selected reports
		for (Configuration__c existingConfigItem : ECO_Service_Reports.getReportsForUser(this.theUser.Id)) {
			system.debug('Getting Config Item From Db:  '+existingConfigItem.UserSortOrder__c);
			selectedConfigItems.put(existingConfigItem.ReportId__c, existingConfigItem.clone());
			orderedUserConfigItems.add(existingConfigItem.clone());
		}
		
		this.searchReportName = '';
		try {
			this.retURL = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('retURL'), 'UTF-8');
		} catch (Exception e) {
			this.retURL = '/apex/ECO_Portal';
		}
		
		// perform the first search
		doSearch();
	}
	
	public PageReference doSearch () {
		if (searchReportName != '' && searchReportName.length() < 3) {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Search term must contain at least 3 characters.'));
			return null;
		}
		
		// This only performs the search, then terms are changed or if they want to reset
		configItemsFromReportQuery = new List<Configuration__c>();
		for (Report r : Database.query(buildQueryString())) {
			Configuration__c config = new Configuration__c();
			config.ReportId__c = r.Id;
			config.ReportName__c = r.Name;
			config.User__c = theUser.Id;
			config.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Configuration__c.sObjectType, 'Report');
			configItemsFromReportQuery.add(config);
		}
		
		populateCurrentRecords();
		
		return null;
	}
	
	public PageReference clearSearchTerms () {
		this.theUser.Date_of_Birth__c = null;
		this.searchReportName = '';
		
		doSearch();
		
		return null;
	}
	
	public PageReference selectItem () {
		ECO_PortalSettings settings = new ECO_PortalSettings();
		
		if (selectedConfigItems.size() >= settings.maxReports) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You may not select more than ' + settings.maxReports + ' reports.'));
			return null;
		}
		
		system.debug(debugLevel, 'selectedReportId:  '+selectedReportId);
		system.debug(debugLevel, 'configItemsOnPage:  '+this.configItemsOnPage);
		
		if (selectedReportId == null) {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'No report found with Id:  '+selectedReportId));
			return null;
		}
		
		Configuration__c selectedItem = this.configItemsOnPage.get(selectedReportId).theConfigItem.clone();
		selectedItem.User__c = theUser.Id;
		
		selectedConfigItems.put(selectedReportId, selectedItem);
		orderedUserConfigItems.add(selectedItem);
		
		system.debug(debugLevel, 'selectedConfigItems:  '+this.selectedConfigItems);
		
		markSelectedRecords();
		
		return null;
	}
	
	public PageReference removeItem () {
		selectedConfigItems.remove(selectedReportId);
		Integer i = 0;
		for (Configuration__c c : orderedUserConfigItems) {
			if (c.ReportId__c == selectedReportId) {
				orderedUserConfigItems.remove(i);
				break;
			}
			i++;
		}
		markSelectedRecords();
		return null;
	}

	public PageReference cancel () {
		return new PageReference(retURL);
	}
	
	public PageReference save () {
		System.savePoint sp = Database.setSavePoint();
		
		try {
			system.debug(debugLevel, 'About to Delete!');
			delete [SELECT Id 
					FROM Configuration__c 
					WHERE RecordType.Name = :ECO_Constants.Configuration_ApplicationReportRecordTypeName 
						AND User__c = :theUser.Id];
			
			// new way
			List<Configuration__c> orderedConfigItemsToInsert = new List<Configuration__c>();
			Integer i = 1;
			for (String reportId : orderedReports.split('&')) {
				String reportIdCleaned = reportId.replaceAll('id=', '');
				system.debug('Cleaned Id:  '+reportIdCleaned); 
				
				if (ECO_Utils_String.NullCheck(reportIdCleaned) == '') {
					continue;
				}
				
				Configuration__c configItem = selectedConfigItems.get(reportIdCleaned);
				configItem.UserSortOrder__c = i;
				i++;
				
				orderedConfigItemsToInsert.add(configItem);
			}
			
			if (!orderedConfigItemsToInsert.isEmpty()) {
				insert orderedConfigItemsToInsert;
			}
			
			return new PageReference(retURL);
		} catch (Exception e) {
			system.debug('Handled Exception:  '+e.getMessage());
			Database.rollBack(sp);
			ApexPages.addMessages(e);
			return null;
		}
	}
	
	public String buildQueryString () {
		fromDate = theUser.Date_of_Birth__c;  // Again, just using the user to provide the date field
		
		system.debug('searchReportName:  '+searchReportName);
		
		String queryString	= 'SELECT Id';
		queryString			+= ' , Name';
		queryString			+= ' , Description';
		queryString			+= ' , Format';
		queryString			+= ' FROM Report';
		queryString			+= ' WHERE Id != null'; // Why get fancy over whether I need a where clause... 
		if (fromDate != null) {
			queryString			+= ' AND CreatedDate >= :fromDate'; 
		}
		if (searchReportName != '') {
			queryString			+= ' AND Name LIKE \'%'+searchReportName+'%\'';
		}
		queryString			+= ' ORDER BY Name ASC';
		queryString			+= ' LIMIT 100';
		
		return queryString;
	}
	
	private void populateCurrentRecords () {
		
		this.configItemsOnPage = new Map<Id, ConfigItemWrapper>();
		
		for (Configuration__c ci : configItemsFromReportQuery) {
			ConfigItemWrapper ciw = new ConfigItemWrapper(ci);
			
			system.debug('ciw.theConfigItem.ReportId__c:  '+ciw.theConfigItem.ReportId__c);
			
			this.configItemsOnPage.put(ciw.theConfigItem.ReportId__c, ciw);
		}
		
		markSelectedRecords();
	}
	
	private void markSelectedRecords () {
		for (ConfigItemWrapper ciw : this.configItemsOnPage.values()) {
			if (selectedConfigItems.keySet().contains(ciw.theConfigItem.ReportId__c)) {
				ciw.selected = true;
			} else {
				ciw.selected = false;
			}
		}
		
		system.debug(' this.configItemsOnPage:  '+ this.configItemsOnPage.keySet());
		system.debug(' this.selectedConfigItems.keySet():  '+ this.selectedConfigItems.keySet());
	}
	
	public class ConfigItemWrapper {
		public Boolean selected {get;set;}
		public Configuration__c theConfigItem {get;set;}
		
		public ConfigItemWrapper (Configuration__c ci) {
			this.theConfigItem = ci;
			this.selected = false;
		}
	}
	
}