public without sharing class ECO_PortalSettings {
	public Integer maxReports;
	
	public ECO_PortalSettings () {
		ECO_PortalSettings__c settings = ECO_PortalSettings__c.getInstance();
		
		if (settings == null 
			|| settings.MaximumNumberOfReports__c == null) {
				maxReports = 8;
		} else {
			maxReports = Integer.valueOf(settings.MaximumNumberOfReports__c);
		}
		
	}
}