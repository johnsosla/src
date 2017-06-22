/*************************************************************************
*
* PURPOSE: Trigger to automatically create a Contact record corresponding
* to an External Vendor
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
***************************************************************************/
trigger sshCaseVendorToContact on Case (before insert) {

	//Set<String> emailAddresses = new Set<String>();
	//Map<String, Case> casesByEmail = new Map<String, Case>();

	//for (Case thisCase : Trigger.new) {
	//	if(thisCase.SuppliedEmail != null) emailAddresses.add( (thisCase.SuppliedEmail).toLowerCase() );

	//	if(thisCase.SuppliedEmail != null && !casesByEmail.keySet().contains( (thisCase.SuppliedEmail).toLowerCase() )){
	//		casesByEmail.put( (thisCase.SuppliedEmail).toLowerCase(), thisCase);
	//	}
	//}

	//Set<String> userEmailAddresses = sshUserContactUtils.getUserEmailsByEmail(emailAddresses);
	//Set<String> existingContactAddresses = sshUserContactUtils.getEmailsWithContact(emailAddresses);

	//List<Contact> newContacts = new List<Contact>();
	//String defaultAccountName = null;

	//if(ssh_User_Contact_Settings__c.getInstance('Default') != null){
	//	defaultAccountName = ssh_User_Contact_Settings__c.getInstance('Default').External_Vendor_Uncategorized_Account__c;
	//}

	//if(defaultAccountName != null){

	//	List<Account> externalVendorAccounts = [select Id, Name from Account where Name = :defaultAccountName];

	//	String rtId = sshUserContactUtils.getRecordTypeIdByName(
	//			ssh_User_Contact_Settings__c.getInstance('Default').External_Vendor_Record_Type__c);

	//	for(String email : emailAddresses){
	//		Boolean hasEmail = casesByEmail.keySet().contains(email.toLowerCase());
	//		if(hasEmail && !userEmailAddresses.contains(email.toLowerCase()) && !existingContactAddresses.contains(email.toLowerCase())){
	//			Contact tempContact = sshUserContactUtils.parseContact(casesByEmail.get(email).SuppliedName); //call out to static parser

	//			if(tempContact != null){
	//				tempContact.Email = email;
	//				tempContact.RecordTypeId = rtId;
	//				tempContact.AccountId = externalVendorAccounts[0] != null ? externalVendorAccounts[0].Id : null;

	//				newContacts.add(tempContact);
	//			}

	//		}
	//	}

	//	insert newContacts;

	//	for(Contact contact : newContacts){
	//		if(casesByEmail.keySet().contains(contact.Email)){
	//			casesByEmail.get(contact.Email).ContactId = contact.Id;
	//		}
	//	}
	//}

}