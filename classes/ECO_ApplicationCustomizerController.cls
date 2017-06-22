public with sharing class ECO_ApplicationCustomizerController extends ECO_PageControllerBase {
	
	public List<Configuration__c> selectedApplications				{ get; set; }
	public List<Configuration__c> applicationsAvailable				{ get; set; }
	public Map<Id, Configuration__c> selectedApplicationMap			{ get; set; }
	public Map<Id, Configuration__c> allAvailableApplicationsMap	{ get; set; }
	public Id selectedConfigId										{ get; set; }
	public String serializedOrder									{ get; set; }
	public User theUser												{ get; set; }
	public String searchTerm										{ get; set; }
	public Boolean inSearchResultsMode								{ get; set; }
	public List<Configuration__c> allDefaultAppConfigs				{ get; set; }
	public Map<Id, Configuration__c> selectedAndAvailableAppMap		{ get; set; }
	public String photoUrl											{ get; set; }
	
	private class ApplicationCustomizerException extends Exception {}

	public List<SelectOption> geographies									{ get{
			List<SelectOption> optionlist = new List<SelectOption>();

			optionlist.add(new SelectOption('', Label.ECOAppCusSelectGeography));
			optionlist.addAll(ECO_Utils_Meta.getPickListValues(new Configuration__c(), 'GeographiesAvailableTo__c'));

			return optionlist;
		} private set; }

	public List<SelectOption> categories										{ get{
			List<SelectOption> optionlist = new List<SelectOption>();

			optionlist.add(new SelectOption('', Label.ECOAppCusSelectCategory));
			optionlist.addAll(ECO_Utils_Meta.getPickListValues(new Application__c(), 'Category__c'));

			return optionlist;
		} private set; }

	public List<SelectOption> businesslines								{ get{
			List<SelectOption> optionlist = new List<SelectOption>();

			optionlist.add(new SelectOption('', Label.ECOAppCusSelecBusinessLine));
			optionlist.addAll(ECO_Utils_Meta.getPickListValues(new Configuration__c(), 'BusinessLinesAvailableTo__c'));

			return optionlist;
		} private set; }

	public Map<string, string> searchMap							{ get; set; }

	public string selectedGeography									{ get; set; }
	public string selectedBusinessLine								{ get; set; }
	
	public string selectedCategory									{ get; set; }
	
	private Date fromDate;
	private class ECO_ReportFinderControllerException extends Exception {}
	private System.LoggingLevel debugLevel = LoggingLevel.INFO;
	private String retURL;
	
	public ECO_ApplicationCustomizerController () {
		
		Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');
		
		if (!Test.isRunningTest()) {
			photoUrl = ConnectApi.ChatterUsers.getPhoto(null, UserInfo.getUserId()).smallPhotoUrl;
		}
		
		searchTerm = '';
		searchMap = null;

		this.theUser = ECO_Service_Users.getUserInfoById(UserInfo.getUserId());
		
		try {
			this.retURL = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('retURL'), 'UTF-8');
		} catch (Exception e) {
			this.retURL = '/apex/ECO_Portal';
		}

		selectedGeography = '';
		selectedBusinessLine = '';
		selectedCategory = '';

		inSearchResultsMode = false;
	}
	
	public PageReference onLoad () {
		
		this.selectedApplicationMap = new Map<Id, Configuration__c>();
		this.allAvailableApplicationsMap = new Map<Id, Configuration__c>();
		this.allDefaultAppConfigs = new List<Configuration__c>();
		this.selectedAndAvailableAppMap = new Map<Id, Configuration__c>();
		
		populateSelectedApps();  // This method performs DML, cannot go in constructor
		populateAvailableApps();
		
		// We just want to do this once during construction so we have a clean map of all their apps, unaffected by search filtering
		selectedAndAvailableAppMap.putAll(selectedApplicationMap);
		selectedAndAvailableAppMap.putAll(allAvailableApplicationsMap);
		/*
		Map<Id, Configuration__c> availableApplicationsMap = new Map<Id, Configuration__c>();
		
		for (Configuration__c c : selectedApplications) {
			system.debug('Apps C:  '+c.IsHidden__c);
			
			if (!c.IsHidden__c) {
				selectedApplicationMap.put(c.Application__c, c);
			}
				
			allAvailableApplicationsMap.put(c.Application__c, c);
			
			if (c.IsDefault__c) {
				allDefaultAppConfigs.add(c);
			}
		}
		
		selectedApplications = selectedApplicationMap.values();

		for (Configuration__c c : applicationsAvailable) {
			
			system.debug('AvailableApps C:  '+c.IsHidden__c);
			
			allAvailableApplicationsMap.put(c.Application__c, c);

			if(!selectedApplicationMap.containsKey(c.Application__c)){
				availableApplicationsMap.put(c.Application__c, c);
			}
			
			if (c.IsDefault__c) {
				allDefaultAppConfigs.add(c);
			}
		}

		allAvailableApplicationsMap.putAll(selectedApplicationMap);

		applicationsAvailable = availableApplicationsMap.values();
		
		system.debug(debugLevel, 'selectedApplicationMap.keySet():  '+selectedApplicationMap.keySet());
		*/
		return null;
	}
	
	public void populateSelectedApps () {
		this.selectedApplications = ECO_Service_Applications.getSortedList(theUser);
		
		this.selectedApplicationMap = new Map<Id, Configuration__c>();
		
		for (Configuration__c c : selectedApplications) {
			if (!c.IsHidden__c) {
				selectedApplicationMap.put(c.Application__c, c);
			}
			if (c.IsDefault__c) {
				allDefaultAppConfigs.add(c);
			}
		}
		
		this.selectedApplications = selectedApplicationMap.values();
	}

	public void populateAvailableApps () {
		this.applicationsAvailable = ECO_Service_Applications.getAvailableSortedList(theUser, searchTerm, searchMap);
		
		system.debug('this.applicationsAvailable:  '+this.applicationsAvailable);
		
		this.allAvailableApplicationsMap = new Map<Id, Configuration__c>();

		//Map<Id, Configuration__c> availableApplicationsMap = new Map<Id, Configuration__c>();
		
		/*
		for (Configuration__c c : selectedApplications) {
			if (!c.IsHidden__c) {
				selectedApplicationMap.put(c.Application__c, c);
			}
		}
		
		selectedApplications = selectedApplicationMap.values();

		*/
		for (Configuration__c c : applicationsAvailable) {
			//allAvailableApplicationsMap.put(c.Application__c, c);
			
			if (c.IsDefault__c) {
				allDefaultAppConfigs.add(c);
			}
			
			if(!selectedApplicationMap.containsKey(c.Application__c)){
				//availableApplicationsMap.put(c.Application__c, c);
				allAvailableApplicationsMap.put(c.Application__c, c);
			}
			
		}

		//allAvailableApplicationsMap.putAll(selectedApplicationMap);

		applicationsAvailable = allAvailableApplicationsMap.values();
	}
	
	public PageReference applySearchFilter () {
		system.debug('searchTerm:  '+searchTerm);

		searchMap = new Map<string, string>();

		if (ECO_Utils_String.NullCheck(selectedGeography) != '') {
			searchMap.put('GeographiesAvailableTo__c', selectedGeography);
		} if (ECO_Utils_String.NullCheck(selectedBusinessLine) != '') {
			searchMap.put('BusinessLinesAvailableTo__c', selectedBusinessLine);
		} if (ECO_Utils_String.NullCheck(selectedCategory) != '') {
			searchMap.put('Application__r.Category__c', selectedCategory);
		}

		populateAvailableApps();
		
		system.debug('searchTerm:  '+searchTerm);
		system.debug('searchMap:  '+searchMap);
		
		if (ECO_Utils_String.NullCheck(searchTerm) != '' || !searchMap.isEmpty()) {
			inSearchResultsMode = true;
		} else {
			inSearchResultsMode = false;
		}
		
		system.debug('inSearchResultsMode:  '+inSearchResultsMode);
		
		return null;
	}
	
	public PageReference clearSearchTerm () {
		searchTerm = '';

		selectedGeography = '';
		selectedBusinessLine = '';
		selectedCategory = '';

		searchMap = null;

		populateAvailableApps();

		inSearchResultsMode = false;
		
		return null;
	}
	/*
	public PageReference hideApplication () {
		system.debug(debugLevel, 'PageParams:  '+ApexPages.currentPage().getParameters());
		
		selectedConfigId = ApexPages.currentPage().getParameters().get('selectedConfigId');
		
		system.debug(debugLevel, 'selectedApplicationMap:  '+selectedApplicationMap);
		
		selectedApplicationMap.get(selectedConfigId).IsHidden__c = true;
		return null;
	}
	
	public PageReference showApplication () {
		selectedConfigId = ApexPages.currentPage().getParameters().get('selectedConfigId');
		
		selectedApplicationMap.get(selectedConfigId).IsHidden__c = false;
		return null;
	}
	*/

	public PageReference returnToPage () {
		return new PageReference(retURL);
	}

	public PageReference savePositions () {
		System.savePoint sp = Database.setSavePoint();
		
		system.debug(debugLevel, 'serializedOrder:  '+serializedOrder);
		
		Map<Id, Configuration__c> configItemsToInsert = new Map<Id, Configuration__c>();
		Integer newSortOrder = 1;
		string applicationRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Configuration__c.sObjectType, 'Application');
		
		try {
			for (String s : serializedOrder.split('&')) {
				system.debug(debugLevel, 'String:  '+s);
				
				system.debug('selectedAndAvailableAppMap.keySet():  '+selectedAndAvailableAppMap.keySet());
				system.debug('selectedAndAvailableAppMap.keySet().contains(key):  '+selectedAndAvailableAppMap.keySet().contains(s.replace('id=', '')));
				
				Configuration__c configFromPage = selectedAndAvailableAppMap.get(s.replace('id=', ''));

				if (configFromPage == null) {
					throw new ApplicationCustomizerException('Issues Saving with this record:  '+s);
				}
				
				system.debug('configFromPage:  '+configFromPage);
				
				Configuration__c newConfigItem = configFromPage.clone(false, false, false, false);
				
				newConfigItem.UserSortOrder__c = newSortOrder;

				if(ECO_Utils_String.NullCheck(newConfigItem.ConfigurationTemplate__c) == ''){
					newConfigItem.ConfigurationTemplate__c = selectedAndAvailableAppMap.get(s.replace('id=', '')).Id;
					newConfigItem.User__c = UserInfo.getUserId();
					newConfigItem.RecordTypeId = applicationRecordTypeId;
				}
				
				newConfigItem.IsHidden__c = false; // Now this serialized list only conains nonhidden stuff, so let's hardcode it.
				newConfigItem.IsActive__c = true;

				system.debug('Config Item: ' + newConfigItem);
				
				system.debug('newConfigItem.UserSortOrder__c:  '+newConfigItem.UserSortOrder__c);
				
				newSortOrder++;
				
				system.debug(debugLevel, 'newConfigItem.Application__r.ApplicationName__c:  '+newConfigItem.Application__r.ApplicationName__c);
				system.debug(debugLevel, 'newConfigItem.UserSortOrder__c:  '+newConfigItem.UserSortOrder__c);
				
				configItemsToInsert.put(newConfigItem.Application__c, newConfigItem);
			}
		} catch (Exception e) {
			ApexPages.addMessages(e);
			return null;
		}
		
		// This loop creates a hidden entry for everything they haven't selected, so apps don't reappear.
		for (Configuration__c c : allDefaultAppConfigs) {
			if (!configItemsToInsert.keySet().contains(c.Application__c)) {
					Configuration__c newHiddenConfig = c.clone(false, false, false, false);
					newHiddenConfig.RecordTypeId = applicationRecordTypeId;
					newHiddenConfig.IsHidden__c = true;
					newHiddenConfig.User__c = UserInfo.getUserId();
					
					system.debug('Found one not configured:  '+newHiddenConfig);
					
					configItemsToInsert.put(newHiddenConfig.Application__c, newHiddenConfig);
			}
		}
		
		try {
			delete [SELECT Id 
					FROM Configuration__c 
					WHERE RecordType.Name = :ECO_Constants.Configuration_ApplicationRecordTypeName
						AND User__c = :theUser.Id];
			
			system.debug(debugLevel, 'configItemsToInsert:  ' + configItemsToInsert);
			
			insert configItemsToInsert.values();

			return returnToPage();
			
		} catch (Exception e) {
			system.debug('Handling Exception:  '+e.getMessage());
			Database.rollBack(sp);
			ApexPages.addMessages(e);
		}

		return null;
	}
}