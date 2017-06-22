public without sharing class ECO_UserTriggers {
	
	public static Boolean run = true;
	
	private static System.LoggingLevel debugLevel = LoggingLevel.INFO;
	
	public static void setDefaultInformation (List<User> insertedUsers) {
		if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('User_setDefaultInfo')) {
			return;
		}
		
		Set<String> orgStringNames = new Set<String>();
		
		for (User u : insertedUsers) {
			orgStringNames.add(u.ECO_OrganizationName__c);
		}
		
		orgStringNames.add(ECO_DefaultOrgString__c.getInstance().OrganizationStringName__c);
		
		Map<String, OrganizationString__c> orgStringMap = new Map<String, OrganizationString__c>();
		for (OrganizationString__c os : [SELECT Id 
												, OrganizationName__c
												, BusinessLineName__c
												, GeographyName__c
												, Region__c
												, OUID__c
												, OrgId__c
										FROM OrganizationString__c
										WHERE OrganizationName__c IN :orgStringNames]) {
			orgStringMap.put(os.OrganizationName__c, os);
		}
		
		for (User u : insertedUsers) {
			if (ECO_Utils_String.NullCheck(u.ECO_OrganizationName__c) == '') {
				u.ECO_OrganizationName__c = ECO_DefaultOrgString__c.getInstance().OrganizationStringName__c;
			}
			OrganizationString__c thisOrgString = orgStringMap.get(u.ECO_OrganizationName__c);
			
			// if no match, do not overwrite
			if (thisOrgString == null) {
				continue;
			}
			
			u.ECO_Region__c =  thisOrgString.Region__c;
			u.ECO_Geography__c =  thisOrgString.GeographyName__c;
			u.ECO_BusinessLine__c =  thisOrgString.BusinessLineName__c;
			u.ECO_OUID__c = thisOrgString.OUID__c;
			u.ECO_OrgId__c = thisOrgString.OrgId__c;
		}
	}
}