public with sharing class ECO_ProjectCountryRiskBatchHelper {

	private static Id alertRecordTypeId;

	public ECO_ProjectCountryRiskBatchHelper() {
		alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeDeveloperName);
	}

	public PortalMessage__c createNewAlert (pse__Proj__c proj, Date theDate, String theMessage) {
		PortalMessage__c newPM = new PortalMessage__c();


		newPM.Project_Number__c = proj.EcoSystemReferenceNumber__c;
        newPM.User__c = proj.Project_Manager_User__c;
		newPM.RecordTypeId = alertRecordTypeId;
		newPM.StartDate__c = theDate;
		newPM.EndDate__c = theDate.adddays(1);
		newPM.IsEscalationAlert__c = true;
		newPM.Subject__c = proj.name;
		newPM.LinkToRecord__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+proj.Id;
		newPM.LongDescriptionMaxLength__c = theMessage;
		return newPM;
	}
}