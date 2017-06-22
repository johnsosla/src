public without sharing class CFM_UserManagement {

    private static final String AECOM_ACCOUNT_NAME = 'AECOM';
	// Parameters:
	// List<Id> userIds -- List of user IDs to get/generate contacts for
	// Returns:
	// A Map<Id,Id> of User IDs to Contact IDs
	// API Usage: 3 SOQL, 1 DML
	public static Map<Id, Id> getContactIdsForUsers(List<Id> userIds) {
		Map<Id, Id> userToContactIds = new Map<Id, Id>();

		List<Contact> contactsWithUsers = [Select Id, FirstName, LastName, SS_Language__c, Email, User__c from Contact where User__c in :userIds and RecordType.Name = 'PSA Resource'];
		Map<Id, Contact> contactsWithoutLanguage = new Map<Id, Contact>();

		List<Id> usersWithoutContacts = new List<Id>();

		for (Id userId : userIds) {
			for (Contact c : contactsWithUsers) {
				if (c.User__c == userId) {

					if (String.isBlank(c.SS_Language__c)) {
						contactsWithoutLanguage.put(c.Id, c);
					}

					userToContactIds.put(userId, c.Id);
				}
			}

			if (!userToContactIds.containsKey(userId)) {
				usersWithoutContacts.add(userId);
			}
		}

		if (contactsWithoutLanguage.size() > 0) {
			List<Id> usersWithoutLanguage = new List<Id>();
			for (Contact c : contactsWithoutLanguage.values()) usersWithoutLanguage.add(c.User__c);

			Map<Id, User> users = new Map<Id, User>([Select Id, LanguageLocaleKey, FirstName, LastName, Email, Department, Title, Phone, MobilePhone from User where Id in :usersWithoutLanguage]);

			for (Contact c : contactsWithoutLanguage.values()) {
				User u = users.get(c.User__c);
				c.SS_Language__c = u.LanguageLocaleKey;
			}

			update contactsWithoutLanguage.values();
		}


		if (usersWithoutContacts.size() > 0) {
			Id aecomEmployeeRtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('PSA Resource').getRecordTypeId();
			Id aecomAccountRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('AECOM Internal Account').getRecordTypeId();

			Account aecomAccount = [Select Id from Account where RecordTypeID = :aecomAccountRtId AND Name =: AECOM_ACCOUNT_NAME];

			List<Contact> newContacts = new List<Contact>();

			List<User> users = [Select Id, LanguageLocaleKey, FirstName, LastName, Email, Department, Title, Phone, MobilePhone from User where Id in :usersWithoutContacts];

			for (User u : users) {
				Contact c = new Contact(
					FirstName=u.FirstName,
					LastName=u.LastName,
					Email = u.Email,
					Department=u.Department,
					Title=u.Title,
					Phone=u.Phone,
					MobilePhone=u.MobilePhone,
					User__c=u.Id,
					RecordTypeID = aecomEmployeeRtId,
					AccountId = aecomAccount.Id,
					SS_Language__c = u.LanguageLocaleKey);

				newContacts.add(c);
			}


			insert newContacts;

			for (Contact c : newContacts) {
				userToContactIds.put(c.User__c, c.Id);
			}
		}


		return userToContactIds;
	}
}