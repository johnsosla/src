/*************************************************************************
* COMPONENT: Shared Services Helpdesk
* Trigger: sshCaseToContact
* PURPOSE: Trigger used to insert a new case and update Contact information
* CREATED: 07/10/15 Ethos Solutions - www.ethos.com
* AUTHOR: Joe DePetro
***************************************************************************/
trigger sshCaseToContact on Case (before insert) {
    //-- get Custom Settings needed for this Case trigger
    sshCustomSettings.CaseTriggerSettings settings = sshCustomSettings.getCaseTriggerSettings();

    if (settings != null && settings.validationOk()) {
        Map<String, Case> casesByEmail = new Map<String, Case>();
        Map<String, Case> casesByAlternateEmail = new Map<String, Case>();
        Set<String> userEcoOrgNames = new Set<String>();
        Map<String, OrganizationString__c> orgStrings = new Map<String, OrganizationString__c>();

        Set<String> userFieldStrings = new Set<String>{'ECO_OrganizationName__c','ssh_AECOM_Email__c','TrackingID__c'};

        for(UTC_User_to_Contact_Mapping__mdt mapping : [Select User_API__c, Contact_API__c, When_To_Map__c
                                                        from UTC_User_to_Contact_Mapping__mdt
                                                        where When_To_Map__c =: sshUserContactUtils.WHEN_TO_MAP_INSERT
                                                            OR When_To_Map__c =: sshUserContactUtils.WHEN_TO_MAP_BOTH]) {
            // This is for the case that more than one field on User maps to a single field
            // on Contact
            List<String> mapFields = mapping.User_API__c.split(',');
            userFieldStrings.addAll(mapFields);
        }

        //-- build a map of the Cases coming in: <Email, Case>
        for (Case thisCase : Trigger.new) {
            if (thisCase.SuppliedEmail != null) {
                casesByEmail.put( (thisCase.SuppliedEmail).toLowerCase(), thisCase);
                casesByAlternateEmail.put( (thisCase.SuppliedEmail).toLowerCase().replace(sshUserContactUtils.AECOM_EMAIL_DOMAIN, sshUserContactUtils.ALTERNATE_EMAIL_DOMAIN), thisCase);
            }
        }

        //-- get current Users for incoming Cases. The users can match on the email or the secondary email field (ssh_AECOM_Email__c)
        Map<String, User> userMap = new Map<String, User>();
        Set<String> emails = casesByEmail.keySet();
        for (User usr : Database.query('Select ' + String.join(new List<String>(userFieldStrings), ',')
                                        + ' from User '
                                        + ' where IsActive = true AND ((Email IN :emails) OR (ssh_AECOM_Email__c IN :emails)) LIMIT 99999')) {
            if (String.isNotBlank(usr.ssh_AECOM_Email__c)) {
                userMap.put(usr.ssh_AECOM_Email__c.toLowerCase(), usr);
            }
            if (String.isNotBlank(usr.ECO_OrganizationName__c)) {
                userEcoOrgNames.add(usr.ECO_OrganizationName__c);
            }

            userMap.put(usr.Email.toLowerCase(), usr);
        }

        //-- build list of user ids
        List<String> foundUserIds = new List<String>();
        for (User userObj : userMap.values()) {
            foundUserIds.add(userObj.Id);
        }

        Map<String, Contact> currentContactMap = new Map<String, Contact>();

        //-- add any Contacts that might be found from links to users. The user list we have now includes users from both emails addresses. This will
        //-- catch Contacts that do not match the secondary email address.
        for (Contact con : [select Id, User__c, Email from Contact where User__c in :foundUserIds]) {
            if (String.isNotBlank(con.Email)) {
                currentContactMap.put(con.Email.toLowerCase(), con);
            }
        }

        //-- get current contacts for incoming Cases. This will catch any contact records that are not linked to users, but match email addresses with an incoming case
        for (Contact con : [select Id, User__c, Email from Contact where Email in :casesByEmail.keySet()]) {
            if (String.isNotBlank(con.Email)) {
                currentContactMap.put(con.Email.toLowerCase(), con);
            }
        }

        //-- SPECIAL ALTERNATE MAPPING
        //-- Since users may have a Case email with "@aecom.com" and the user record can have "@urs.com" we will need a alternate list to check.
        Map<String, User> altUserMap = new Map<String, User>();
        Set<String> altEmails = casesByAlternateEmail.keySet();
        for (User usr : Database.query('Select ' + String.join(new List<String>(userFieldStrings), ',')
                                        + ' from User '
                                        + ' where IsActive = true AND Email in :altEmails')) {
            altUserMap.put(usr.Email.toLowerCase(), usr);
            if (String.isNotBlank(usr.ECO_OrganizationName__c)) {
                userEcoOrgNames.add(usr.ECO_OrganizationName__c);
            }
        }

        List<Contact> contactUpdateList = new List<Contact>();
        Map<String, Contact> mappedEmailUpdateList = new Map<String, Contact>();

        for (OrganizationString__c orgString : [Select Id, OrganizationName__c from OrganizationString__c where OrganizationName__c IN: userEcoOrgNames]) {
            orgStrings.put(orgString.OrganizationName__c, orgString);
        }

        sshUserContactUtils.newContactOrgStrings.putAll(orgStrings);

        //-- cycle thru incoming Cases and setup Contact insert and update lists.
        for (String caseEmail : casesByEmail.keySet()) {
            Contact contactRec;

            //-- Contact record exists - add link to Case right here and this one is done
            if (currentContactMap.containsKey(caseEmail)) {
                casesByEmail.get(caseEmail).ContactId = currentContactMap.get(caseEmail).Id;
            }
            //-- current contact is not found, lets look at the User linked Contacts.
            else if (userMap.containsKey(caseEmail)) {
                if (currentContactMap.containsKey(userMap.get(caseEmail).Email)) {
                    casesByEmail.get(caseEmail).ContactId = currentContactMap.get(userMap.get(caseEmail).Email).Id;
                } else {
                    contactUpdateList.add(sshUserContactUtils.buildNewContact(userMap, settings, userMap.get(caseEmail).Email));
                }
            } else { //- Contact or User does not exist - build new Contact & add to list for insertion. We will have to set the link later
                //-- SPECIAL ALTERNATIVE MAPPING
                String alternateEmail = caseEmail.replace(sshUserContactUtils.AECOM_EMAIL_DOMAIN, sshUserContactUtils.ALTERNATE_EMAIL_DOMAIN);
                if (altUserMap.containsKey(alternateEmail)) { //-- the user exists with an alternate email, we just need a contact record
                    contactRec = sshUserContactUtils.buildNewContact(altUserMap, settings, alternateEmail);
                } else { //-- no user - must be a vendor, create new contact record from Case name
                    contactRec = sshUserContactUtils.parseContact(casesByEmail.get(caseEmail).SuppliedName); //call out to static parser

                    if (contactRec != null) {
                        contactRec.Email = caseEmail;
                        //-- If the new Case email contains '@aecom.com' we will consider the author an employee user even though a record has not been found.
                        contactRec.RecordTypeId = (caseEmail.endsWithIgnoreCase(sshUserContactUtils.AECOM_EMAIL_DOMAIN)) ? settings.internalUserContactRecordTypeId : settings.vendorContactRecordTypeId;
                        contactRec.AccountId = (caseEmail.endsWithIgnoreCase(sshUserContactUtils.AECOM_EMAIL_DOMAIN)) ? settings.internalUserAccount.Id : settings.externalVendorAccount.Id;
                    }
                }

                contactUpdateList.add(contactRec);
            }
        }

        upsert contactUpdateList;

        //-- The Case records associated with these new Contact records could not get their Contact link set because the Contact did not exist.
        //-- Now that they do we will set those links.
        for (Contact c : contactUpdateList) {
            if (casesByEmail.containsKey(c.Email)) {
                casesByEmail.get(c.Email).ContactId = c.Id;
            } else if (userMap.containsKey(c.Email)) {
                casesByEmail.get(userMap.get(c.Email).ssh_AECOM_Email__c).ContactId = c.Id;
            } else {
                String alternateEmail = altUserMap.get(c.Email).Email.replace(sshUserContactUtils.ALTERNATE_EMAIL_DOMAIN, sshUserContactUtils.AECOM_EMAIL_DOMAIN);
                casesByEmail.get(alternateEmail).ContactId = c.Id;
            }
        }

        //To auto populate the region picklist value from the contact
        HRS_CaseHandler.autoPopulateRegionEntitlementOnCase( Trigger.New );

        //To auto populate the four select picklist value if an Org is definded
        HRS_CaseHandler.autoPopulateSelectionValueOnCase( Trigger.New, null );

        //To auto populate the HR system Key based on 3 fields
        HRS_CaseHandler.autoPopulateHRSysCodeOnCase( Trigger.New, null );

        //HRS_CaseHandler.autoEbandCaseSubmit( Trigger.New, null );     
        HRS_CaseHandler.autoPopulateContactInfoOnCase( Trigger.New );
        
    }

}