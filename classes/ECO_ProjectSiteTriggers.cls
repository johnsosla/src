public with sharing class ECO_ProjectSiteTriggers {

	public static boolean run = true;

    public static void setChangeManagerIsChangedFlag(List<Project_Site__c> updatedProjectSites, Map<Id, Project_Site__c> oldProjectSitesMap )
    {
        if (!run || ECO_TriggerSettings.isBypassed('PST_setChangeManagerIsChangedFlag') || UserInfo.getUserName().toLowerCase().contains('integration@aecom.com')) 
            return;

        for(Project_Site__c projectSite : updatedProjectSites){
            projectSite.ChangeManagerIsChanged__c = true; 
            if(projectSite.Contribution__c != oldProjectSitesMap.get(projectSite.Id).Contribution__c)
            	projectSite.ChangeManagerContributionIsChanged__c = true; 
        }
    }
	/*public static void CreateClientAccountManagers(list<Project_Site__c> lstProjectSites){
		map<id, set<id>> proj2siteManager = new map<id, set<id>>();

		for(Project_Site__c ps: lstProjectSites){
			if(ps.)

		}

	}*/
}