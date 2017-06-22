/*************************************************************************
*
* PURPOSE: Trigger to automatically create a Contact record corresponding
* to User record if an email comes from what is considered an AECOM internal user.
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
***************************************************************************/
trigger sshCaseUserToContact on Case (before insert) {
	//Set<String> emailAddresses = new Set<String>();
	//Map<String, Case> casesByEmail = new Map<String, Case>();

	//for (Case thisCase : Trigger.new) {
	//	if(thisCase.SuppliedEmail != null) emailAddresses.add( (thisCase.SuppliedEmail).toLowercase() );

	//	if(thisCase.SuppliedEmail != null && !casesByEmail.keySet().contains( (thisCase.SuppliedEmail).toLowercase() )){
	//		casesByEmail.put( (thisCase.SuppliedEmail).toLowercase(), thisCase);
	//	}
	//}

	//Set<Id> usersWithContact = new Set<Id>();
 //   List<Contact> contactList = new List<Contact>();

 //   //call out to update any Contact records that exist for this list of Users (if the emails don't match)
 //   sshUserContactUtils.updateContactEmails(emailAddresses, usersWithContact, contactList);

 //   sshUserContactUtils.loadUserIdsWithContact(emailAddresses, usersWithContact, contactList);

 //   List<Account> internalUserAccounts = null;

 //   if(ssh_User_Contact_Settings__c.getInstance('Default') != null){
	//	String defaultAccountName = ssh_User_Contact_Settings__c.getInstance('Default').Internal_User_Account__c;
	//	if(defaultAccountName != null)
	//		internalUserAccounts = [select Id, Name from Account where Name = :defaultAccountName];	
	//}

	//if(internalUserAccounts != null && !internalUserAccounts.isEmpty()){

	//    sshUserContactUtils.updateContactUsers(usersWithContact, internalUserAccounts[0].Id);

	//	List<User> userList = [select Id, FirstName, LastName, Department, Title, Email, LanguageLocaleKey, Shared_Services_Is_Executive__c from User where Id NOT in :usersWithContact and (Email in :emailAddresses AND IsActive = true)];

	//	List<Contact> newContacts = new List<Contact>();
	
	//	String rtId = sshUserContactUtils.getRecordTypeIdByName(
	//		ssh_User_Contact_Settings__c.getInstance('Default').Employee_Record_Type__c);

	//	if(!internalUserAccounts.isEmpty()){
	//		for(User user : userList){
	//			newContacts.add(new Contact(
	//				FirstName = user.FirstName,
	//				LastName = user.LastName,
	//				Department = user.Department,
	//				Title = user.Title,
	//				Email = (user.Email).toLowercase(),
	//				SS_Language__c = sshUserContactUtils.getLanguageByLocaleKey(user.LanguageLocaleKey),
	//				Shared_Services_Is_Executive__c = user.Shared_Services_Is_Executive__c,
	//				RecordTypeId = rtId,
	//				User__c = user.Id,
	//				AccountId = internalUserAccounts[0].Id));
	//		}			

	//		insert newContacts;
	//	}

	//	newContacts.addAll(contactList); 			

	//	if(!newContacts.isEmpty()){
	//		for(Contact contact : newContacts){
	//			if(casesByEmail.keySet().contains( (contact.Email).toLowercase() )){
	//				casesByEmail.get( (contact.Email).toLowercase() ).ContactId = contact.Id;
	//			}
	//		}
	//	}

	//}
}