/*************************************************************************
*
* PURPOSE: Util class containing methods used by User and Contact related
* triggers
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
* Steve MunLeeuw Oct 2016  Matching on TrackingId or Contact.User__c
***************************************************************************/
global class sshUserContactUtils {

    public static final String UNKNOWN = 'UNKNOWN';
    public static final String AECOM_EMAIL_DOMAIN = '@aecom.com';
    public static final String ALTERNATE_EMAIL_DOMAIN = '@urs.com';
    public static final String WHEN_TO_MAP_INSERT = 'Insert';
    public static final String WHEN_TO_MAP_UPDATE = 'Update';
    public static final String WHEN_TO_MAP_BOTH = 'Both';

    public static Map<String, OrganizationString__c> newContactOrgStrings = new Map<String, OrganizationString__c>();

    public static Map<String, Id> recordTypeNameToId;

    /**
    * @Description This method will update the "copy" Contact records for the associated User records changes. Since this is called from a trigger
    *                 on a setup object (User) the method must be a future method.
    * @param userIdList - Set list of user Id's that were changed.
    */
    public static void updateContactUsers(Set<ID> userIdList) {
        if (System.isFuture() || System.isBatch() || System.isScheduled()) {
            doUpdateContactUsers(userIdList, null);
        } else {
            doUpdateContactUsersFuture(userIdList, null);
        }
    }

    /**
    * @Description This method will update the "copy" Contact records for the associated User records changes. Since this is called from a trigger
    *                 on a setup object (User) the method must be a future method.
    * @param userIdList - Set list of user Id's that were changed.
    * @param userIdList - Set list of user Id's that were changed.
    */
    public static void updateContactUsers(Set<ID> userIdList, Id internalUserAcctId) {
        if (System.isFuture() || System.isBatch() || System.isScheduled()) {
            doUpdateContactUsers(userIdList, internalUserAcctId);
        } else {
            doUpdateContactUsersFuture(userIdList, internalUserAcctId);
        }
    }

    private static string SetToString (Set<Id> userList)
    {
        Integer i = 0;
        string returnString = '';            
        for(Id user : userList)
        {
            if( i > 0)
            {
                returnString += ',\'' + user + '\'';
            } else {
                returnString += '\'' + user + '\'';
            }
            i += 1;
        }
        return returnString;


    }

    //for executing the User -> Contact update if we are already in the future context
    private static void doUpdateContactUsers(Set<Id> userIdList, Id internalUserAcctId) {
        System.debug('USER LIST 2-------' + internalUserAcctId);
        if(userIdList.size() == 0)
            return;

        Map<String, User> userEmailMap = new Map<String, User>();
        Map<String, User> userTrackingIdMap = new Map<String, User>();
        Set<String> userEcoOrgNames = new Set<String>();
        Map<String, OrganizationString__c> orgStrings = new Map<String, OrganizationString__c>();
        MetaDataTypeMappings mdt = new MetaDataTypeMappings();
        Set<Id> managerIdSet = new Set<Id>();

        for (User user : Database.query('Select ' + String.join(new List<String>(mdt.UserFieldStrings), ',')
                                        + ' from User '
                                        + 'where ID IN: userIdList')) {
            userEmailMap.put(user.Id, User);
            if(user.TrackingID__c != null){
                userTrackingIdMap.put(user.TrackingID__c, user);
            }
            managerIdSet.add(user.ManagerId);                                            
            if (String.isNotBlank(user.ECO_OrganizationName__c)) {
                userEcoOrgNames.add(user.ECO_OrganizationName__c);
            }
        }

        // We could just set the user's ECO_OrganizationName__c to Contact's Organization String
        // but this doesn't take into account that the string might not be an actual record
        // if it doesn't exist we'll set it to null
        for (OrganizationString__c orgString : [Select Id, OrganizationName__c from OrganizationString__c where OrganizationName__c IN: userEcoOrgNames]) {
            orgStrings.put(orgString.OrganizationName__c, orgString);
        }
        

        Map<Id,User> managerContacts = new Map<Id,User>([select id, (select id from Contacts__r) from User where id in :managerIdSet ]);

        List<Contact> contactsToUpdate = new List<Contact>();
        Set<String> userIdsRelationship = userEmailMap.keySet();
        Set<String> userIdsTracking = userTrackingIdMap.keySet();
        String soqlGetContacts = 'SELECT '
            + 'RecordTypeId, RecordType.DeveloperName, ' 
            + String.join(new List<String>(mdt.ContactFieldStrings), ',')
            + ' FROM Contact WHERE User__c IN :userIdsRelationship OR TrackingID__c IN :userIdsTracking';
        List<Contact> contactList = Database.query(soqlGetContacts);

        System.debug('Contact List======>'+contactList);
        Set<Id> userIds = new Set<Id>();
        List<Contact> newContacts = new List<Contact>();
        sshCustomSettings.CaseTriggerSettings settings = sshCustomSettings.getCaseTriggerSettings();
        Id employeeRT = getRecordTypeIdByName(RT_NAME_EMPLOYEE);

        if (!contactList.isEmpty()) {
            for (Contact contact : contactList) {
                if ((userEmailMap.keySet().contains(contact.User__c) && contact.RecordTypeId == employeeRT)
                    || (userTrackingIdMap.keySet().contains(contact.TrackingID__c))
                    ) {
                    
                    Boolean isUpdate = false;
                    User updateUser = userEmailMap.get(contact.User__c);
                    if(updateUser == null){
                        updateUser = userTrackingIdMap.get(contact.TrackingID__c);
                        contact.User__c = updateUser.Id;
                        isUpdate = true;
                    }
                    userIds.add(updateUser.Id);
                    updateUser.Manager =  managerContacts.get(updateUser.ManagerId);
                    
                    Id orgId = orgStrings.get(updateUser.ECO_OrganizationName__c) != null
                               ? orgStrings.get(updateUser.ECO_OrganizationName__c).Id
                               : null;
                    Boolean isUpdateContact = updateContact(contact, updateUser, mdt);
                    if(isUpdateContact){ isUpdate = true; }
                    if(contact.OrganizationString__c != orgId){
                        contact.OrganizationString__c = orgId;
                        isUpdate = true;
                    }
                    if(contact.RecordType.DeveloperName == 'HR_Pre_Hire'){
                        contact.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PSA_Resource' LIMIT 1].Id;
                        isUpdate = true;
                    }

                    //-- 6.16.15 AECSSH-448
                    //contact.SS_Language__c = getLanguageByLocaleKey(updateUser.LanguageLocaleKey);
                    if (contact.AccountId != internalUserAcctId && internalUserAcctId != null) {
                        contact.AccountId = internalUserAcctId;
                        isUpdate = true;
                    }
                    if(updateUser.IsActive && contact.Status__c != 'Employee - Active'
                        || !updateUser.IsActive && contact.Status__c != 'Employee - Inactive'){
                        contact.Status__c = updateUser.IsActive ? 'Employee - Active' : 'Employee - Inactive';
                        isUpdate = true;
                    }
                    if(isUpdate){
                        contactsToUpdate.add(contact);
                    }
                }
            }
            // Duke Ames 8/2016
            // Changed update to Database.SaveResult() due to all records in batch being rolled back when the batch had any failure
            // Also changed below (insert) and in createNewContactsForInsertedUsers method
            System.debug('Contacts to Update=====>'+ contactsToUpdate);
            if(!contactsToUpdate.isEmpty()){
                Database.SaveResult[] result = Database.update(contactsToUpdate, false);
                for(Database.SaveResult sr : result){
                    if(!sr.isSuccess()){
                        ECO_Service_ErrorLog.logException(contactsToUpdate, result, 'sshUserContactUtils.doUpdateContactUsers', 'User to Contact Trigger Contact Update');
                        break;
                    }
                }
            }
        }

        for (User user : Database.query('Select ' + String.join(new List<String>(mdt.UserFieldStrings), ',')
                                        + ' from User '
                                        + 'where ID IN: userIdList')) {
                                            
            user.Manager =  managerContacts.get(user.ManagerId);                                            
            userEmailMap.put(user.Id, User);
        }
        for(Id userId : userEmailMap.keySet()) {
            if(!userIds.contains(userId)) {
                newContacts.add(buildNewContact(userEmailMap, settings, userId));
            }
        }
        if(!newContacts.isEmpty()) {
            // Duke Ames 8/2016
            // Changed insert to Database.SaveResult() due to all records in batch being rolled back when the batch had any failure
            // Also changed in createNewContactsForInsertedUsers method
            Database.SaveResult[] result = Database.insert(newContacts, false);
            for(Database.SaveResult sr : result){
                if(!sr.isSuccess()){
                    ECO_Service_ErrorLog.logException(newContacts, result, 'sshUserContactUtils.doUpdateContactUsers', 'User to Contact Trigger Contact Insert');
                    break;
                }
            }
        }
    }

//for executing the User -> Contact update if not already in future context
    @future
    private static void doUpdateContactUsersFuture(Set<Id> userIdList, Id internalUserAcctId) {
    System.debug('User list- ------' + userIdList);
        doUpdateContactUsers(userIdList, internalUserAcctId);

    }

    // get set of user ids that already have an associated contact record
    public static void loadUserIdsWithContact(Set<String> emailAddresses, Set<Id> userIdsWithContact, List<Contact> contactList) {
        List<User> userList = [select Id, Email from User where Email in :emailAddresses AND IsActive = true];
        List<Contact> currentContactList = [select Id, Email from Contact where Email in :emailAddresses];

        Map<String, Id> userEmails = new Map<String, Id>();

        if (!userList.isEmpty() && !currentContactList.isEmpty()) {

            for (User user : userList) {
                userEmails.put( (user.Email).toLowerCase(), user.Id);
            }

            for (Contact contact : currentContactList) {
                if (userEmails.containsKey(contact.Email.toLowerCase()) ) {
                    userIdsWithContact.add(userEmails.get(contact.Email.toLowerCase()));
                    contact.User__c = userEmails.get(contact.Email.toLowerCase());
                    contactList.add(contact);
                }
            }

            upsert contactList;
        }
    }

    public static Id getRecordTypeIdByName(String name) {
        if (recordTypeNameToId == null) {
            recordTypeNameToId = new Map<String, Id>();
        }
        Id rtId = null;
        if (String.isNotBlank(name)) {
            if (!recordTypeNameToId.containsKey(name)) {
                RecordType rT = [select Id from RecordType where DeveloperName = :name OR Name = :name LIMIT 1];
                recordTypeNameToId.put(name, rT.Id);
            }
            rtId = recordTypeNameToId.get(name);
        }

        return rtId;
    }

    //pass in a list of emails and return a list of emails that do have a contact
    public static Set<String> getEmailsWithContact(Set<String> emails) {
        List<Contact> contacts = [select Email from Contact where Email in :emails];
        Set<String> emailsWithContact = new Set<String>();
        if (!contacts.isEmpty()) {
            for (Contact contact : contacts) {
                if (emails.contains( (contact.Email).toLowerCase() )) {
                    emailsWithContact.add( (contact.Email).toLowerCase() );
                }
            }
        }

        return emailsWithContact;
    }

    //get set of internal user email addresses based on list of email addresses
    //this is used to see which addresses in the email to case list are internal vs vendor
    public static Set<String> getUserEmailsByEmail(Set<String> emails) {
        List<User> users = [select Email from User where Email in :emails AND IsActive = true];
        Set<String> userEmails = new Set<String>();
        for (User user : users) {
            userEmails.add( (user.Email).toLowerCase() );
        }

        return userEmails;
    }

    public static String getLanguageByLocaleKey(String localeKey) {
        Map<String, String> keyMapping = new Map<String, String> {
            'en_US' => 'English',
            'fr' => 'French'
        };
        String language = 'English';
        if (keyMapping.keySet().contains(localeKey)) {
            language = keyMapping.get(localeKey);
        }

        return language;
    }

    //accept list of User records that have existing Contact records
    //then check to make sure that the emails match. Update if not.
    public static void updateContactEmails(Set<String> emails, Set<Id> usersWithContact, List<Contact> contactList) {
        List<User> users = [select Id, Email from User where Email in :emails AND IsActive = true];
        List<Contact> contacts = [select User__c, Email from Contact where User__c in :users];
        Map<Id, Contact> contactRefs = new Map<Id, Contact>();
        if (!contacts.isEmpty()) {
            for (Contact ct : contacts) {
                contactRefs.put(ct.User__c, ct);
            }
            for (User user : users) {
                if (contactRefs.keySet().contains(user.Id)) {
                    usersWithContact.add(user.Id);
                    if ( (user.Email).toLowerCase() != (contactRefs.get(user.Id).Email).toLowerCase() ) {
                        Contact tempCt = contactRefs.get(user.Id);
                        tempCt.Email = (user.Email).toLowerCase();
                        contactList.add(tempCt);
                    }
                }
            }
            if (!contactList.isEmpty()) {
                update contactList;
            }
        }
    }

    // Note that the key can be either an email or an Id depending on method that is calling it
    // UTC_UserToContact.trigger uses Id as the key
    // sshCaseToContact.trigger uses email as the key
    public static Contact buildNewContact(Map<String, User> userMap, sshCustomSettings.CaseTriggerSettings settings, String key) {
        Id orgId = newContactOrgStrings.get(userMap.get(key).ECO_OrganizationName__c) != null
                   ? newContactOrgStrings.get(userMap.get(key).ECO_OrganizationName__c).Id
                   : null;
        Contact newContact = new Contact();
        User u = userMap.get(key);
        MetaDataTypeMappings mdt = new MetaDataTypeMappings();

        updateContact(newContact, u, mdt);
        newContact.OrganizationString__c = orgId;
        newContact.RecordTypeId = settings.internalUserContactRecordTypeId;
        newContact.AccountId = settings.internalUserAccount.Id;
        newContact.Status__c = 'Employee - Active';
        if(u.ManagerId != null)
        {
            List<Contact> managerContacts = u.Manager.Contacts__r;
            if(managerContacts.size() > 0)
            {
                newContact.ReportsToId = managerContacts[0].Id;
            }
        }
        
        return newContact;
    }

    public static Boolean updateContact(Contact cont, User u, MetaDataTypeMappings mdt) {
        Boolean isUpdate = false;
        for(UTC_User_to_Contact_Mapping__mdt mapping : mdt.Mappings) {
            List<String> mapFields = mapping.User_API__c.split(',');
            if(mapFields.size() > 1) {
                List<String> values = new List<String>();
                for(String mapField : mapFields) {
                    if(String.isNotBlank((String)u.get(mapField))) {
                        values.add((String)u.get(mapField));
                    }
                }
                if(!values.isEmpty()) {
                    String target = String.join(values, ' || ');
                    if(cont.get(mapping.Contact_API__c) != target){
                        cont.put(mapping.Contact_API__c, target);
                        isUpdate = true;
                    }
                }
            } else {
                if(cont.get(mapping.Contact_API__c) != u.get(mapping.User_API__c)){
                    cont.put(mapping.Contact_API__c, u.get(mapping.User_API__c));
                    isUpdate = true;
                }
            }
        }
        if(!cont.pse__Is_Resource__c){
            cont.pse__Is_Resource__c = true;
            isUpdate = true;
        }
        cont.OracleContactId__c = String.isNotBlank(u.TrackingID__c)
                                  ? 'EMPLOYEE-' + u.TrackingID__c
                                  : '';
                                  
        if(u.ManagerId != null && u.Manager != null)
        {
            List<Contact> managerContacts = u.Manager.Contacts__r;
            if(managerContacts.size() > 0)
            {
                 if(cont.ReportsToId != managerContacts[0].Id){
                       cont.ReportsToId = managerContacts[0].Id;
                       isUpdate = true;
                }
            }
        }
        return isUpdate;
    }

    @future
    public static void createNewContactsForInsertedUsers(Set<Id> userIds) {
        if(userIds.size() == 0)
            return;
        MetaDataTypeMappings mdt = new MetaDataTypeMappings();

        List<Contact> newContacts = new List<Contact>();
        Map<String, User> userMap = new Map<String, User>();
        Set<Id> managerIdSet = new Set<Id>();
        Set<String> userTrackingIdSet = new Set<String>();
        sshCustomSettings.CaseTriggerSettings settings = sshCustomSettings.getCaseTriggerSettings();

        // Get list of all applicable organization string records from users
        Set<String> userEcoOrgNames = new Set<String>();
        Map<String, OrganizationString__c> orgStrings = new Map<String, OrganizationString__c>();

        String Userquery = 'Select ' + String.join(new List<String>(mdt.UserFieldStrings), ',');
               Userquery += ' from User ';
               Userquery += ' where ID IN: userIds';
              System.debug(Userquery);
         
          List<User> userList = Database.query(Userquery);
        System.debug(userList);
        for (User user : userList ) {
            managerIdSet.add(user.ManagerId);
            if(user.TrackingID__c != null){
                userTrackingIdSet.add(user.TrackingID__c);
            }
        }
        Map<Id,User> managerContacts = new Map<Id,User>([select id, (select id from Contacts__r) from User where id in :managerIdSet ]);

        String soqlGetContacts = 'SELECT '
            + 'RecordTypeId, RecordType.DeveloperName, ' 
            + String.join(new List<String>(mdt.ContactFieldStrings), ',')
            + ' FROM Contact WHERE TrackingID__c IN :userTrackingIdSet';
        List<Contact> contactsWithTrackingIds = Database.query(soqlGetContacts);

        Set<String> trackingIdsWithContacts = new Set<String>();
        for(Contact contact : contactsWithTrackingIds){
            if(contact.TrackingID__c != null){
                trackingIdsWithContacts.add(contact.TrackingID__c);
            }
        }

        List<Contact> contactsToUpdate = new List<Contact>();            
        for (User user : userList ) {
            user.Manager =  managerContacts.get(user.ManagerId);
            if(trackingIdsWithContacts.contains(user.TrackingID__c)){
                for(Contact contact : contactsWithTrackingIds){
                    if(contact.TrackingID__c == user.TrackingID__c){
                        updateContact(contact, user, mdt);
                        contact.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PSA_Resource' LIMIT 1].Id;
                        contactsToUpdate.add(contact);
                    }
                }
            }
            else{
                userMap.put(user.Id, user);
            }
            if (String.isNotBlank(user.ECO_OrganizationName__c)) {
                userEcoOrgNames.add(user.ECO_OrganizationName__c);
            }
        }
        if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }

        // We could just set the user's ECO_OrganizationName__c to Contact's Organization String
        // but this doesn't take into account that the string might not be an actual record
        // if it doesn't exist we'll set it to null
        for (OrganizationString__c orgString : [Select Id, OrganizationName__c from OrganizationString__c where OrganizationName__c         IN: userEcoOrgNames]) {
            orgStrings.put(orgString.OrganizationName__c, orgString);
        }

        newContactOrgStrings.putAll(orgStrings);
        for (String key : userMap.keySet()) {
            newContacts.add(buildNewContact(userMap, settings, key));
        }

        if(!newContacts.isEmpty()) {
            //insert newContacts;

            // Duke Ames 8/2016
            // Changed insert to Database.SaveResult() due to all records in batch being rolled back when the batch had any failure
            // Also changed in doUpdateContactUsers method
            
            Database.SaveResult[] result = Database.insert(newContacts, false);
            for(Database.SaveResult sr : result){
                if(!sr.isSuccess()){
                    ECO_Service_ErrorLog.logException(newContacts, result, 'sshUserContactUtils.createNewContactsForInsertedUsers', 'User to Contact Trigger Contact Insert');
                    break;
                }
            }
        }
    }

    //method for parsing a SuppliedName into Contact from Case
    public static Contact parseContact(String nameString) {
        String [] nameParts;
        String spaceNormalizedNameString;
        String firstName;
        String lastName;

        if (String.isNotBlank(nameString)) {

            spaceNormalizedNameString = nameString.normalizeSpace();
            Boolean hasCommas = false;
            //contains commas, split on that first
            if (nameString.contains(',')) {
                hasCommas = true;
                nameParts = spaceNormalizedNameString.split(','); //do the split into array
            } else if (spaceNormalizedNameString.containsWhitespace()) {
                nameParts = spaceNormalizedNameString.split(' '); //split on space
            }

            if (nameParts == null) {
                if (String.isNotBlank(spaceNormalizedNameString)) {
                    firstName = spaceNormalizedNameString;
                } else {
                    firstName = UNKNOWN;
                }
                lastName = UNKNOWN; //put unknown since we don't know last name
            } else if (nameParts.size() == 1) { //probably just a first name or first (space) last
                firstName = nameParts[0];
                lastName = UNKNOWN; //put unknown since we don't know last name
            } else if (nameParts.size() == 2) {

                lastName = hasCommas ? nameParts[0] : nameParts[1];
                firstName = hasCommas ? nameParts[1] : nameParts[0];

            } else if (nameParts.size() > 2) {
                if (hasCommas) { //last name is 0th, append additional positions together for FirstName
                    lastName = nameParts[0];
                    String tmpStr;
                    for (String namePart : nameParts) {
                        if (namePart != lastName) {
                            if (tmpStr == null) {
                                tmpStr = namePart;
                            } else {
                                tmpStr += (' ' + namePart);
                            }
                        }
                    }
                    firstName = tmpStr;
                } else { //first name is 0th, append additional positions together for LastName
                    firstName = nameParts[0] + ' ' + nameParts[1]; //>3 means they probably have a middle name/initial listed
                    String tmpStr;
                    for (String namePart : nameParts) {
                        if (!firstName.contains(namePart)) {
                            if (tmpStr == null) {
                                tmpStr = namePart;
                            } else {
                                tmpStr += (' ' + namePart);
                            }
                        }
                    }
                    lastName = tmpStr;
                }
            }

        }

        Contact tempContact = new Contact();
        tempContact.FirstName = String.isNotBlank(firstName) ? firstName : UNKNOWN;
        tempContact.LastName = String.isNotBlank(lastName) ? lastName : UNKNOWN;
        tempContact.Case_Web_Name__c = String.isBlank(spaceNormalizedNameString) ? null : spaceNormalizedNameString;

        if (tempContact.FirstName != null) {
            tempContact.FirstName = tempContact.FirstName.abbreviate(40);
        }

        if (tempContact.LastName != null) {
            tempContact.LastName = tempContact.LastName.abbreviate(80);
        }

        if (tempContact.Case_Web_Name__c != null) {
            tempContact.Case_Web_Name__c = tempContact.Case_Web_Name__c.abbreviate(255);
        }

        return tempContact;
    }

    public static final String RT_NAME_EMPLOYEE = !Test.isRunningTest() ? ssh_User_Contact_Settings__c.getInstance('Default').Employee_Record_Type__c : 'PSA Resource';
    public static final String RT_NAME_VENDOR = !Test.isRunningTest() ? ssh_User_Contact_Settings__c.getInstance('Default').External_Vendor_Record_Type__c : 'AP Vendor';

    /** ---------------------------------------------------------------------------------------
    * @Description Retrieving configuration data from the Custom Metadata Type: UTC User to Contact Mapping<br/>
    * The above code contained the same queries and looping structure over and over so I created this class.
    * You'll likely notice there's still repetitive code above.
    *
    * @Author AECOM - Steve MunLeeuw
    * @Date Oct 2016
    *----------------------------------------------------------------------------------------*/
   private class MetaDataTypeMappings {
        public List<UTC_User_to_Contact_Mapping__mdt> Mappings {get; set;} 
        public Set<String> UserFieldStrings {get; set;}
        public Set<String> ContactFieldStrings {get; set;}


        private MetaDataTypeMappings(){
            //I may need to split this out into the various types, but based on a prior meeting it appears we don't need the ability to update conditionally
            //this appears to be a case of implementing requirements that are not necessary. all mappings should be marked as Both
            Mappings = [SELECT 
                            User_API__c, 
                            Contact_API__c, 
                            When_To_Map__c 
                        FROM UTC_User_to_Contact_Mapping__mdt 
                        WHERE When_To_Map__c =: WHEN_TO_MAP_UPDATE 
                            OR When_To_Map__c =: WHEN_TO_MAP_BOTH
                            OR When_To_Map__c =: WHEN_TO_MAP_INSERT];

            UserFieldStrings = new Set<String>{'ECO_OrganizationName__c','TrackingID__c', 'ManagerId', 'Manager.Id'};
            ContactFieldStrings = new Set<String>{'pse__Is_Resource__c', 'OrganizationString__c', 'AccountId', 'Status__c'};

            for(UTC_User_to_Contact_Mapping__mdt mapping : mappings) {
                // This is for the case that more than one field on User maps to a single field
                // on Contact
                List<String> mapFields = mapping.User_API__c.split(',');
                UserFieldStrings.addAll(mapFields);
                List<String> contactMapFields = mapping.Contact_API__c.split(',');
                ContactFieldStrings.addAll(contactMapFields);
            }
        }
    }
}