public without sharing class ECO_Service_Applications {
	
	private static System.LoggingLevel debugLevel = LoggingLevel.INFO;
	
	private static Map<Id, Configuration__c> applicationToConfigMap = new Map<Id, Configuration__c>();
	
	private static Boolean requiresUpsert = false;
	
	public static void upsertApplicationsForUser() {
		if (requiresUpsert) {
			system.debug('Upserting!!!');
			upsert applicationToConfigMap.values();
		}
	}
	
	/*  Luke Farbotko AECOM 23 Nov 2015
		Builds the required quiry string for returning a users applications in eco portal
		The default apps boolean is used to switch between wheather we want the users 
		selected apps or the apps that AECOM want for all users as default.
	*/
	public static String builderApplicationsForUserQuery(User theUser, String searchTerm, Boolean defultsApps) {
		String queryString = 'SELECT Id';
		queryString			+= ' , Name';
		queryString			+= ' , RecordTypeId';
		queryString			+= ' , BusinessLinesAvailableTo__c';
		queryString			+= ' , DefaultSortOrder__c';
		queryString			+= ' , GeographiesAvailableTo__c';
		queryString			+= ' , RegionsAvailableTo__c';
		queryString			+= ' , IsActive__c';
		queryString			+= ' , IsHidden__c';
		queryString			+= ' , ConfigurationTemplate__r.IsRemovable__c';
		queryString			+= ' , IsRemovable__c';
		queryString			+= ' , IsTemplateActive__c';
		queryString			+= ' , User__c';
		queryString			+= ' , IsDefault__c';
		queryString			+= ' , UserSortOrder__c';
		queryString			+= ' , Application__c';
		queryString			+= ' , Application__r.ApplicationName__c';
		queryString			+= ' , Application__r.ApplicationURL__c';
		queryString			+= ' , Application__r.ImageName__c';
		queryString			+= ' , Application__r.NetworkRequirement__c';
		queryString			+= ' , Application__r.MobileEnabled__c';
		queryString			+= ' , RecordType.Name';
		queryString			+= ' , RecordType.DeveloperName';
		queryString			+= ' , ConfigurationTemplate__c';

		queryString			+= ' FROM Configuration__c';
		// This block is for user records
		queryString			+= ' WHERE ';

		if (defultsApps == false){
			queryString		+= '(User__c = \''+theUser.Id+'\'';
			queryString			+= ' AND ConfigurationTemplate__r.IsActive__c = true';
			//queryString			+= ' AND IsHidden__c = false';
			//queryString			+= ' AND ConfigurationTemplate__r.GeographiesAvailableTo__c INCLUDES (\'' + theUser.ECO_Geography__c + '\',\'All\')';
			//queryString			+= ' AND ConfigurationTemplate__r.BusinessLinesAvailableTo__c INCLUDES (\'' + theUser.ECO_BusinessLine__c + '\',\'All\')';
			//queryString			+= ' AND ConfigurationTemplate__r.RegionsAvailableTo__c INCLUDES (\'' + theUser.ECO_Region__c + '\',\'All\')';
			if (ECO_Utils_String.NullCheck(searchTerm) != '') {
				queryString			+= ' AND (Application__r.Category__c LIKE \'%' + searchTerm + '%\'';
				queryString			+= ' OR Application__r.ApplicationName__c LIKE \'%' + searchTerm + '%\')';
			}
			queryString			+= ' AND RecordType.DeveloperName = \'Application\')';

		}
		else{
			queryString			+= ' (User__c = null';
			queryString			+= ' AND IsActive__c = true';
			queryString			+= ' AND IsDefault__c = true';
			//queryString			+= ' AND GeographiesAvailableTo__c INCLUDES (\'' + theUser.ECO_Geography__c + '\',\'All\')';
			//queryString			+= ' AND BusinessLinesAvailableTo__c INCLUDES (\'' + theUser.ECO_BusinessLine__c + '\',\'All\')';
			//queryString			+= ' AND RegionsAvailableTo__c INCLUDES (\'' + theUser.ECO_Region__c + '\',\'All\')';
			if (ECO_Utils_String.NullCheck(searchTerm) != '') {
				queryString			+= ' AND (Application__r.Category__c LIKE \'%' + searchTerm + '%\'';
				queryString			+= ' OR Application__r.ApplicationName__c LIKE \'%' + searchTerm + '%\')';
			}
			queryString			+= ' AND RecordType.DeveloperName = \'ApplicationTemplate\')';
		}

		
		// this block is for template records
		
		
		//queryString			+= ' ORDER BY User__c DESC';
		//queryString			+= ' ORDER BY UserSortOrder__c ASC';
		//queryString			+= ' , UserSortOrder__c ASC';
		//queryString			+= ' , Application__c ASC';
		//queryString			+= ' , DefaultSortOrder__c ASC';
		
		system.debug(debugLevel, 'Built this query:  '+queryString);
		return queryString;
	}

	public static Map<Id, Configuration__c> getUpdateApplicationsForUser (User theUser, String searchTerm) {
		
		// Map<Id, Configuration__c> applicationToConfigMap = new Map<Id, Configuration__c>();
		/*
		String queryString = 'SELECT Id';
		queryString			+= ' , Name';
		queryString			+= ' , RecordTypeId';
		queryString			+= ' , BusinessLinesAvailableTo__c';
		queryString			+= ' , DefaultSortOrder__c';
		queryString			+= ' , GeographiesAvailableTo__c';
		queryString			+= ' , RegionsAvailableTo__c';
		queryString			+= ' , IsActive__c';
		queryString			+= ' , IsHidden__c';
		queryString			+= ' , ConfigurationTemplate__r.IsRemovable__c';
		queryString			+= ' , IsRemovable__c';
		queryString			+= ' , IsTemplateActive__c';
		queryString			+= ' , User__c';
		queryString			+= ' , IsDefault__c';
		queryString			+= ' , UserSortOrder__c';
		queryString			+= ' , Application__c';
		queryString			+= ' , Application__r.ApplicationName__c';
		queryString			+= ' , Application__r.ApplicationURL__c';
		queryString			+= ' , Application__r.ImageName__c';
		queryString			+= ' , Application__r.NetworkRequirement__c';
		queryString			+= ' , Application__r.MobileEnabled__c';
		queryString			+= ' , RecordType.Name';
		queryString			+= ' , ConfigurationTemplate__c';

		queryString			+= ' FROM Configuration__c';
		// This block is for user records
		queryString			+= ' WHERE (User__c = \''+theUser.Id+'\'';
		queryString			+= ' AND ConfigurationTemplate__r.IsActive__c = true';
		//queryString			+= ' AND IsHidden__c = false';
		//queryString			+= ' AND ConfigurationTemplate__r.GeographiesAvailableTo__c INCLUDES (\'' + theUser.ECO_Geography__c + '\',\'All\')';
		//queryString			+= ' AND ConfigurationTemplate__r.BusinessLinesAvailableTo__c INCLUDES (\'' + theUser.ECO_BusinessLine__c + '\',\'All\')';
		//queryString			+= ' AND ConfigurationTemplate__r.RegionsAvailableTo__c INCLUDES (\'' + theUser.ECO_Region__c + '\',\'All\')';
		if (ECO_Utils_String.NullCheck(searchTerm) != '') {
			queryString			+= ' AND (Application__r.Category__c LIKE \'%' + searchTerm + '%\'';
			queryString			+= ' OR Application__r.ApplicationName__c LIKE \'%' + searchTerm + '%\')';
		}
		queryString			+= ' AND RecordType.Name = \'Application\')';
		// this block is for template records
		queryString			+= ' OR (User__c = null';
		queryString			+= ' AND IsActive__c = true';
		queryString			+= ' AND IsDefault__c = true';
		//queryString			+= ' AND GeographiesAvailableTo__c INCLUDES (\'' + theUser.ECO_Geography__c + '\',\'All\')';
		//queryString			+= ' AND BusinessLinesAvailableTo__c INCLUDES (\'' + theUser.ECO_BusinessLine__c + '\',\'All\')';
		//queryString			+= ' AND RegionsAvailableTo__c INCLUDES (\'' + theUser.ECO_Region__c + '\',\'All\')';
		if (ECO_Utils_String.NullCheck(searchTerm) != '') {
			queryString			+= ' AND (Application__r.Category__c LIKE \'%' + searchTerm + '%\'';
			queryString			+= ' OR Application__r.ApplicationName__c LIKE \'%' + searchTerm + '%\')';
		}
		queryString			+= ' AND RecordType.Name = \'Application Template\')';
		
		//queryString			+= ' ORDER BY User__c DESC';
		queryString			+= ' ORDER BY UserSortOrder__c ASC';
		//queryString			+= ' , UserSortOrder__c ASC';
		//queryString			+= ' , Application__c ASC';
		queryString			+= ' , DefaultSortOrder__c ASC';
		
		system.debug(debugLevel, 'Built this query:  '+queryString);
		
		// Boolean requiresUpsert = false;
		
		// This has to happen in two loops because ordering by a blank user just doesn't work.. the nulls show up first.
		
		List<Configuration__c> configs = Database.query(queryString);
		*/

		// Luke Farbotko AECOM  23-Oct-2015 - next 5 lines have been added to replace the above commented block.
		// It breats the previous query into and post joins to gain SOQL performace by removing the 'OR'condition
		List<Configuration__c> configsDefaults = Database.query(builderApplicationsForUserQuery(theUser, searchTerm,true));
		List<Configuration__c> configsUsers = Database.query(builderApplicationsForUserQuery(theUser, searchTerm,false));

		List<Configuration__c> configs = new List<Configuration__c>();

		configs.addAll(configsDefaults);
		configs.addAll(configsUsers);

		// First loop populates the user records only
		for (Configuration__c configItem : configs) {
			if (configItem.RecordType.DeveloperName == 'ApplicationTemplate') {
				// This is a template, skip it
				continue;
			}
			
			applicationToConfigMap.put(configItem.Application__c, configItem);
		}
		
		// Second loop adds DEFAULT apps that user doesn't have configs for
		for (Configuration__c configItem : configs) {
			if (configItem.RecordType.DeveloperName == 'Application') {
				// This is a NOT template, skip it
				continue;
			}
			
			if (applicationToConfigMap.keySet().contains(configItem.Application__c)) {
				// User already has this one, keep going.
				continue;
			}
			
			system.debug('Found app user doesn\'t have:  '+configItem);
			
			Configuration__c newConfigItem = configItem.clone();
			newConfigItem.UserSortOrder__c = configItem.DefaultSortOrder__c;
			newConfigItem.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Configuration__c.sObjectType, 'Application');
			newConfigItem.ConfigurationTemplate__c = configItem.Id;
			newConfigItem.ConfigurationTemplate__r = configItem;
			newConfigItem.IsHidden__c = false;
			newConfigItem.User__c = theUser.Id;
			
			applicationToConfigMap.put(configItem.Application__c, newConfigItem);
			
			requiresUpsert = true;
		}
		
		/*
		if (requiresUpsert) {
			system.debug('Upserting!!!');
			upsert applicationToConfigMap.values();
		}
		*/
		
		for (Configuration__c c : applicationToConfigMap.values()) {
			system.debug('Evalling Config Item.User__c:  '+c.User__c);
			system.debug('Evalling Config Item.Id:  '+c.Id);
			system.debug('Evalling Config Item.UserSortOrder__c:  '+c.UserSortOrder__c);
		}
		
		return applicationToConfigMap;
		
	}

	public static Map<Id, Configuration__c> getAvailableApplicationsForUser (User theUser, string name, map<String, String> searchMap) {
		
		// Map<Id, Configuration__c> applicationToConfigMap = new Map<Id, Configuration__c>();
		
		String queryString = 'SELECT Id';
		queryString			+= ' , Name';
		queryString			+= ' , RecordTypeId';
		queryString			+= ' , BusinessLinesAvailableTo__c';
		queryString			+= ' , DefaultSortOrder__c';
		queryString			+= ' , GeographiesAvailableTo__c';
		queryString			+= ' , RegionsAvailableTo__c';
		queryString			+= ' , IsActive__c';
		queryString			+= ' , IsHidden__c';
		queryString			+= ' , ConfigurationTemplate__r.IsRemovable__c';
		queryString			+= ' , IsRemovable__c';
		queryString			+= ' , IsTemplateActive__c';
		queryString			+= ' , User__c';
		queryString			+= ' , IsDefault__c';
		queryString			+= ' , UserSortOrder__c';
		queryString			+= ' , Application__c';
		queryString			+= ' , Application__r.ApplicationName__c';
		queryString			+= ' , Application__r.ApplicationURL__c';
		queryString			+= ' , Application__r.ImageName__c';
		queryString			+= ' , Application__r.NetworkRequirement__c';
		queryString			+= ' , Application__r.MobileEnabled__c';
		queryString			+= ' , RecordType.Name';
		queryString			+= ' , RecordType.DeveloperName';
		queryString			+= ' , ConfigurationTemplate__c';

		queryString			+= ' FROM Configuration__c';

		// this block is for template records
		queryString			+= ' WHERE (IsActive__c = true';
		queryString			+= ' AND IsRemovable__c = true';
		queryString			+= ' AND RecordType.DeveloperName = \'ApplicationTemplate\')';
		
		string likeArray = '';


		if (ECO_Utils_String.NullCheck(name) != ''){
			list<string> nameArray = String.escapeSingleQuotes(name).split(' ');
			
			for(string s:nameArray){
				likeArray += 'Application__r.ApplicationName__c LIKE \'%' + s + '%\' OR ';
			}

			likeArray = likeArray.removeEnd('OR ');

			queryString			+= ' AND ( ' +  likeArray + ' ) ';

			system.debug(likeArray);
		}

		if (searchMap != null) {
			for(string searchterm : searchMap.keySet()){
				system.debug('Term: ' + searchterm);
				if(ECO_Utils_String.NullCheck(searchMap.get(searchterm)) != '')
					queryString	+= ' AND ' + String.escapeSingleQuotes(searchterm) + ' INCLUDES (\'' + String.escapeSingleQuotes(searchMap.get(searchterm)) + '\')';
			}
		}

		queryString			+= ' ORDER BY User__c DESC';
		queryString			+= ' , Application__c ASC';
		queryString			+= ' , UserSortOrder__c ASC';
		queryString			+= ' , DefaultSortOrder__c ASC';
		
		system.debug(debugLevel, 'Built this query:  '+queryString);
		
		List<Configuration__c> configs = Database.query(queryString);
		
		for (Configuration__c configItem : configs) {
			applicationToConfigMap.put(configItem.Application__c, configItem);
		}

		return applicationToConfigMap;
	}
	
	public static List<Configuration__c> getSortedList (User theUser) {
		return getSortedList(theUser, null);
	}
	
	public static List<Configuration__c> getSortedList (User theUser, String searchTerm) {
		List<SortableConfiguration> sortedList = new List<SortableConfiguration>();
		
		for (Configuration__c config : getUpdateApplicationsForUser(theUser, searchTerm).values()) {
			sortedList.add(new SortableConfiguration(config));
		}
		
		List<Configuration__c> sortedConfigItems = new List<Configuration__c>();
		
		sortedList.sort();
		
		for (SortableConfiguration sc : sortedList) {
			sortedConfigItems.add(sc.theConfigItem);
			system.debug('Adding Sorted Config:  '+sc.theConfigItem.UserSortOrder__c);
			system.debug('Adding Sorted Config App Name:  '+sc.theConfigItem.Application__r.ApplicationName__c);
		}
		
		return sortedConfigItems;
	}

	public static List<Configuration__c> getAvailableSortedList (User theUser) {
		return getAvailableSortedList(theUser, null, null);
	}

	public static List<Configuration__c> getAvailableSortedList (User theUser, string name, map<String, String> searchMap) {
		List<SortableConfiguration> sortedList = new List<SortableConfiguration>();
		
		for (Configuration__c config : getAvailableApplicationsForUser(theUser, name, searchMap).values()) {
			sortedList.add(new SortableConfiguration(config));
		}
		
		List<Configuration__c> sortedConfigItems = new List<Configuration__c>();
		
		sortedList.sort();
		
		for (SortableConfiguration sc : sortedList) {
			sortedConfigItems.add(sc.theConfigItem);
			system.debug('Adding Sorted Config:  '+sc.theConfigItem.UserSortOrder__c);
			system.debug('Adding Sorted Config App Name:  '+sc.theConfigItem.Application__r.ApplicationName__c);
		}
		
		return sortedConfigItems;
	}

	public class SortableConfiguration implements comparable {
		public Integer compareTo(Object compareTo) {
			SortableConfiguration compareToConfig = (SortableConfiguration)compareTo;
			
		    if (theConfigItem.UserSortOrder__c == compareToConfig.theConfigItem.UserSortOrder__c) {
				return 0;
		    }
			if (theConfigItem.UserSortOrder__c > compareToConfig.theConfigItem.UserSortOrder__c) {
				return 1;
			}
	        return -1;  
		}
		
		public Configuration__c theConfigItem;
		
		public SortableConfiguration (Configuration__c incomingConfigItem) {
			theConfigItem = incomingConfigItem;
		}
	}
	
}