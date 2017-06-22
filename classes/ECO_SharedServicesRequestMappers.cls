/** ------------------------------------------------------------------------------------------------------
* @Description Mapping class for GBS to object graph of Sites and Contacts for create and update
*
* @Author      AECOM, Steve MunLeeuw
* @Date        June 10, 2016
*-----------------------------------------------------------------------------------------------------*/

public class ECO_SharedServicesRequestMappers{
	private Map<String, OrganizationString__c> orgStrings;
	private Map<String, Id> mapCountry;

	public void cacheOUs(List<SharedServicesRequest__c> ssrs){
		Set<String> ouNames = new Set<String>();
		for(SharedServicesRequest__c ssr : ssrs){
			ouNames.add(ssr.OUName__c);
		}
		orgStrings = new Map<String, OrganizationString__c>();
		List<OrganizationString__c> lorgStrings = [SELECT OUName__c, OUID__c FROM OrganizationString__c WHERE OUName__c IN :ouNames];
		for(OrganizationString__c orgString : lorgStrings){
			orgStrings.put(orgString.OUName__c, orgString);
		}

		//Also need countries
		List<Country__c> lstCountry = [SELECT Id, Name FROM Country__c];
		mapCountry = new Map<String, Id>();

		for(Country__c c: lstCountry){
			mapCountry.put(c.name, c.id);
		}
	}


	/**
	 * 
	 *
	 * @Author  AECOM - Steve MunLeeuw
	 * @Date    Oct 2016
	 *
	 * @param   fk the foreign key for the entity on the GBS object
	 * @param   ssrs, the collection of GBS request objects that the trigger is handling
	 * @Description If the user has clicked Submit Request, the sites have potentially been created
	 * If they have, we'll update them, if an earlier edit didn't populate the fields, but this edit does, we'll create the site
	 * If the uwer previously has created a site, but now doesn't want it, they will need to navigate to that site and delete it, shouldn't happen
	 * This code only executes if the Submit Request has been created and the GBS.Account__r.OracleCustomerNumber has not been populated
	 * once the Oracle Cutomer Number is populated that means this request is in a sync relationship with Oracle and can not be modified.
	 * Salesforce creates the entities (Account, Site, Contaxt), but Oracle is the system of record.
	 **/
	public void updateSites(String fk, List<SharedServicesRequest__c> ssrs){
		List<Id> filter = new List<Id>();

		List<Site__c> sitesToUpdate = new List<Site__c>();
		List<Site__c> sitesToInsert = new List<Site__c>();

		for(SharedServicesRequest__c ssr : ssrs){
			if(fk == 'ReferenceSite__c' && ssr.ReferenceSite__c != null){
				filter.add(ssr.ReferenceSite__c);
			}
			else if(fk == 'ReferenceBillingSite__c' && ssr.ReferenceBillingSite__c != null){
				filter.add(ssr.ReferenceBillingSite__c);
				System.debug('DebugMe: creating billing site: ' + fk + ' - ' + ssr.ReferenceBillingSite__c);

			}
			else if(fk == 'ReferenceRemitSite__c' && ssr.ReferenceRemitSite__c != null){
				filter.add(ssr.ReferenceRemitSite__c);
			}
		}

		List<Site__c> sites = [SELECT
								Id,
								Address1__c,
								Address2__c,
								Address3__c,
								Address4__c,
								City__c,
								State__c,
								PostalCode__c,
								Country__c,
								PrimaryFlag__c,
								SiteStatus__c,
								OUName__c
							 FROM Site__c WHERE Id IN :filter LIMIT 1];

		for(SharedServicesRequest__c ssr : ssrs){
			if(fk == 'ReferenceSite__c'){
				if(sites.isEmpty()){
					Site__c site = new Site__c();
					if(mapGBStoSite(ssr, site)){
						sitesToInsert.add(site);
					}
				}
				else{
					if(mapGBStoSite(ssr, sites[0])){
						sitesToUpdate.add(sites[0]);
					}
				}
			}
			else if(fk == 'ReferenceBillingSite__c'){
				if(sites.isEmpty()){
					Site__c site = new Site__c();
					if(mapGBStoBillingSite(ssr, site)){
						sitesToInsert.add(site);
					}
				}
				else{
					if(mapGBStoBillingSite(ssr, sites[0])){
						sitesToUpdate.add(sites[0]);
					}
				}
			}
			else if(fk == 'ReferenceRemitSite__c'){
				if(sites.isEmpty()){
					Site__c site = new Site__c();
						mapGBStoRemitSite(ssr, site);
						sitesToInsert.add(site);
				}
				else{
					if(mapGBStoRemitSite(ssr, sites[0])){
						sitesToUpdate.add(sites[0]);
					}
				}
			}

			if(!sitesToInsert.isEmpty()){
				try {
					insert sitesToInsert;
					if(fk == 'ReferenceSite__c'){ ssr.ReferenceSite__c = sitesToInsert[0].Id; }
					if(fk == 'ReferenceBillingSite__c'){ 
						ssr.ReferenceBillingSite__c = sitesToInsert[0].Id; 
					}
					if(fk == 'ReferenceRemitSite__c'){ 
						ssr.ReferenceRemitSite__c = sitesToInsert[0].Id; }

				}
				catch (Exception e){
					ECO_Service_ErrorLog.logException(e);
				}
			}
		}

		if(!sitesToUpdate.isEmpty()){
			try {
				update sitesToUpdate;
			}
			catch (Exception e){
				ECO_Service_ErrorLog.logException(e);
			}
		}

	}



	/**
	 * 
	 *
	 * @Author  AECOM - Steve MunLeeuw
	 * @Date    Oct 2016
	 *
	 * @param   fk the foreign key for the entity on the GBS object
	 * @param   ssrs, the collection of GBS request objects that the trigger is handling
	 * @Description see updateSites method above, same pattern and rules apply
	 **/
	public void updateContacts(String fk, List<SharedServicesRequest__c> ssrs){
		Id filter;
		String cRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Oracle Contact').getRecordTypeId();

		List<Contact> contactsToUpdate = new List<Contact>();
		List<Contact> contactsToInsert = new List<Contact>();

		for(SharedServicesRequest__c ssr : ssrs){
			if(fk == 'Contact1Lookup__c'){
				filter = ssr.Contact1Lookup__c;
			}
			else if(fk == 'Contact2Lookup__c'){
				filter = ssr.Contact2Lookup__c;
			}
			else if(fk == 'PrimaryContactLookup__c'){
				filter = ssr.PrimaryContactLookup__c;
			}
			else if(fk == 'BillingContactLookup__c'){
				filter = ssr.BillingContactLookup__c;
			}

			List<Contact> contacts = [SELECT
										Id,
										FirstName,
										LastName,
										Email,
										Phone,
										RoleType__c
									  FROM Contact WHERE Id = :filter LIMIT 1];

				if(fk == 'Contact1Lookup__c'){
					if(contacts.isEmpty()){
						Contact contact = new Contact(RecordTypeId = cRecordTypeId, AccountId = ssr.Account__c);
						if(mapGBStoContact1(ssr, contact)){
							contactsToInsert.add(contact);
						}
					}
					else{
						if(mapGBStoContact1(ssr, contacts[0])){
							contactsToUpdate.add(contacts[0]);
						}
					}
				}
				else if(fk == 'Contact2Lookup__c'){
					if(contacts.isEmpty()){
						Contact contact = new Contact(RecordTypeId = cRecordTypeId);
						if(mapGBStoContact2(ssr, contact)){
							contactsToInsert.add(contact);
						}
					}
					else{
						if(mapGBStoContact2(ssr, contacts[0])){
							contactsToUpdate.add(contacts[0]);
						}
					}
				}
				else if(fk == 'PrimaryContactLookup__c'){
					if(contacts.isEmpty()){
						Contact contact = new Contact(RecordTypeId = cRecordTypeId);
						if(mapGBSToPrimaryContact(ssr, contact)){
							contactsToInsert.add(contact);
						}
					}
					else{
						if(mapGBSToPrimaryContact(ssr, contacts[0])){
							contactsToUpdate.add(contacts[0]);
						}
					}
				}
				else if(fk == 'BillingContactLookup__c'){
					if(contacts.isEmpty()){
						Contact contact = new Contact(RecordTypeId = cRecordTypeId, RoleType__c = 'Billing');
						if(mapGBSToPrimaryContact(ssr, contact)){
							contactsToInsert.add(contact);
						}
					}
					else{
						if(mapGBStoBillingContact(ssr, contacts[0])){
							contactsToUpdate.add(contacts[0]);
						}
					}
				}

			if(!contactsToUpdate.isEmpty()){
				try {
					update contactsToUpdate;
				}
				catch (Exception e){
					ECO_Service_ErrorLog.logException(e);
				}
			}
			if(!contactsToInsert.isEmpty()){
				try {
					insert contactsToInsert;
					if(fk == 'Contact1Lookup__c'){
						ssr.Contact1Lookup__c = contactsToInsert[0].Id;
					}
					else if(fk == 'Contact2Lookup__c'){
						ssr.Contact2Lookup__c = contactsToInsert[0].Id;
					}
					else if(fk == 'PrimaryContactLookup__c'){
						ssr.PrimaryContactLookup__c = contactsToInsert[0].Id;
					}
					else if(fk == 'BillingContactLookup__c'){
						ssr.BillingContactLookup__c = contactsToInsert[0].Id;
					}
				}
				catch (Exception e){
					ECO_Service_ErrorLog.logException(e);
				}
			}
		}
	}


	/**
	 * 
	 *
	 * @Author  AECOM - Steve MunLeeuw
	 * @Date    June 2016
	 *
	 * @param   source, target, list of api field names <Target, Source>
	 * @return  True if the target is updated
	 **/
	public Boolean MapSourceToTarget(SObject source, SObject target, Map<String, String> apiFieldNames){
		Boolean isUpdate = false;

		for(String sourceField : apiFieldNames.keySet()){
			String targetField = apiFieldNames.get(sourceField);
			if(apiFieldNames.get(sourceField) != target.get(apiFieldNames.get(sourceField))){
				//system.debug('TraceMe MapSourceToTarget: ' + target.getsObjectType().getDescribe().Name + '.' + apiFieldNames.get(sourceField) + '(' + target.get(sourceField) + ') => ' + source.getsObjectType().getDescribe().Name + '.' + sourceField + '(' + source.get(sourceField) + ')');
				target.put(targetField, source.get(sourceField));
				isUpdate = true;
			}
		}


		return isUpdate;
	}

	public Boolean mapGBStoSite(SharedServicesRequest__c gbs, Site__c site){
		Boolean isUpdate = false;

		//validate that the site is populated
		if(gbs.City__c == null){ return isUpdate; }

		Map<String, String> fieldsToMap = new Map<String, String>();

		fieldsToMap.put('Address1StreetPOBox__c', 'Address1__c');
		fieldsToMap.put('Address2StreetPOBox__c', 'Address2__c');
		fieldsToMap.put('Address3StreetPOBox__c', 'Address3__c');
		fieldsToMap.put('Address4StreetPOBox__c', 'Address4__c');
		fieldsToMap.put('City__c', 'City__c');
		fieldsToMap.put('StateProvinceEmirateName__c', 'State__c');
		fieldsToMap.put('ZipPostalCode__c', 'PostalCode__c');
		fieldsToMap.put('Country__c', 'Country__c');
		fieldsToMap.put('AddressIsPrimary__c', 'PrimaryFlag__c');

		isUpdate = MapSourceToTarget(gbs, site, fieldsToMap);

		if(site.OUName__c != gbs.OUName__c){
			site.OUName__c = gbs.OUName__c;

		
			OrganizationString__c orgString = orgStrings.get(gbs.OUName__c);
			if(orgString != null){
				site.OUID__c = orgString.OUID__c;
			}
			isUpdate = true;
		}

		return isUpdate;		
	}

	public Boolean mapGBStoBillingSite(SharedServicesRequest__c gbs, Site__c site){
		Boolean isUpdate = false;

		//validate that the site is populated
		if(gbs.BillingAddressCity__c == null){ return isUpdate; }

		Map<String, String> fieldsToMap = new Map<String, String>();

		fieldsToMap.put('BillingStreetPOBox__c', 'Address1__c');
		fieldsToMap.put('BillingAddress2StreetPOBox__c', 'Address2__c');
		fieldsToMap.put('BillingAddress3StreetPOBox__c', 'Address3__c');
		fieldsToMap.put('BillingAddress4StreetPOBox__c', 'Address4__c');
		fieldsToMap.put('BillingAddressCity__c', 'City__c');
		fieldsToMap.put('BillingStateProvinceEmirateName__c', 'State__c');
		fieldsToMap.put('BillingZipPostalCode__c', 'PostalCode__c');
		fieldsToMap.put('BillingAddressCountry__c', 'Country__c');
		fieldsToMap.put('BillingAddress1isPrimary__c', 'PrimaryFlag__c');
		//Associate Account
		site.Account__c = gbs.Account__c;

		isUpdate = MapSourceToTarget(gbs, site, fieldsToMap);
		
		return isUpdate;		
	}

	public Boolean mapGBStoRemitSite(SharedServicesRequest__c gbs, Site__c site){
		Boolean isUpdate = false;

		//validate that the site is populated
		if(gbs.RemitToCity__c == null){ return isUpdate; }

		Map<String, String> fieldsToMap = new Map<String, String>();

		fieldsToMap.put('RemitToAddressLine1__c', 'Address1__c');
		fieldsToMap.put('RemitToAddressLine2__c', 'Address2__c');
		fieldsToMap.put('RemitToStateProvinceEmirateName__c', 'State__c');
		fieldsToMap.put('RemitToCity__c', 'City__c');
		fieldsToMap.put('RemitToZipPostalCode__c', 'PostalCode__c');
		fieldsToMap.put('RemitToCountry__c', 'Country__c');
		fieldsToMap.put('RemitIsPrimaryAddress__c', 'PrimaryFlag__c');
		//Associate Account
		site.Account__c = gbs.Account__c;

		isUpdate = MapSourceToTarget(gbs, site, fieldsToMap);

		return isUpdate;		
	}

	public Boolean mapGBStoPrimaryContact(SharedServicesRequest__c gbs, Contact contact){
		Boolean isUpdate = false;

		Map<String, String> fieldsToMap = new Map<String, String>();

		fieldsToMap.put('PrimaryContactLastName__c', 'LastName');
		fieldsToMap.put('PrimaryContactFirstName__c', 'FirstName');
		fieldsToMap.put('PrimaryContactEmail__c', 'Email');
		fieldsToMap.put('PrimaryContactPhone__c', 'Phone');

		isUpdate = MapSourceToTarget(gbs, contact, fieldsToMap);

		return isUpdate;		
	}

	public Boolean mapGBStoBillingContact(SharedServicesRequest__c gbs, Contact contact){
		Boolean isUpdate = false;


		Map<String, String> fieldsToMap = new Map<String, String>();

		fieldsToMap.put('BillingContactLastName__c', 'LastName');
		fieldsToMap.put('BillingContactFirstName__c', 'FirstName');
		fieldsToMap.put('BillingContactEmail_1__c', 'Email');
		fieldsToMap.put('BillingContactPhone__c', 'Phone');

		isUpdate = MapSourceToTarget(gbs, contact, fieldsToMap);

		return isUpdate;		
	}

	public Boolean mapGBStoContact1(SharedServicesRequest__c gbs, Contact contact){
		Boolean isUpdate = false;

		Map<String, String> fieldsToMap = new Map<String, String>();

		fieldsToMap.put('Contact1LastName__c', 'LastName');
		fieldsToMap.put('Contact1FirstName__c', 'FirstName');
		fieldsToMap.put('Contact1EmailAddress__c', 'Email');
		fieldsToMap.put('Contact1Phone__c', 'Phone');
		fieldsToMap.put('CustomerContact1Role__c', 'RoleType__c');

		isUpdate = MapSourceToTarget(gbs, contact, fieldsToMap);

		return isUpdate;
	}

	public Boolean mapGBStoContact2(SharedServicesRequest__c gbs, Contact contact){
		Boolean isUpdate = false;

		Map<String, String> fieldsToMap = new Map<String, String>();
		fieldsToMap.put('Contact2LastName__c', 'LastName');
		fieldsToMap.put('Contact2FirstName__c', 'FirstName');
		fieldsToMap.put('Contact2Email__c', 'Email');
		fieldsToMap.put('Contact2Phone__c', 'Phone');
		fieldsToMap.put('CustomerContact2Role__c', 'RoleType__c');

		isUpdate = MapSourceToTarget(gbs, contact, fieldsToMap);

		return isUpdate;
	}

	public Boolean mapGBStoCustomerAccount(SharedServicesRequest__c gbs, Account account){
		Boolean isUpdate = false;

		Map<String, String> fieldsToMap = new Map<String, String>();
		fieldsToMap.put('AccountNameChinese__c', 'Account_Name_in_Local_Language__c');
		fieldsToMap.put('DBNumberDUNS__c', 'DBNumberDUNS__c');
		fieldsToMap.put('DesktopCheckAsia__c', 'DesktopCheckAsia__c');
		fieldsToMap.put('CustomerName__c', 'Name');
		fieldsToMap.put('ParentAccount__c', 'ParentID');
		fieldsToMap.put('ClientGroup__c', 'Client_Group__c');
		fieldsToMap.put('ClientSubgroup__c', 'Client_Subgroup__c');
		fieldsToMap.put('Reach__c', 'Reach__c');
		fieldsToMap.put('SicCode__c', 'Sic');
		fieldsToMap.put('SicDescription__c', 'SicDesc');
		fieldsToMap.put('MKDenialStatus__c', 'MK_Denial__c');
		fieldsToMap.put('IntercompanyCustomer__c', 'CustomerType__c');

		isUpdate = MapSourceToTarget(gbs, account, fieldsToMap);
		if(mapGBStoAccountAddress(gbs, account)){ isUpdate = true; }

		return isUpdate;
	}

	public Boolean mapGBStoVendorAccount(SharedServicesRequest__c gbs, Account account){
		Boolean isUpdate = false;

		Map<String, String> fieldsToMap = new Map<String, String>();
		fieldsToMap.put('AccountNameChinese__c', 'Account_Name_in_Local_Language__c');
		fieldsToMap.put('DBNumberDUNS__c', 'DBNumberDUNS__c');
		fieldsToMap.put('DesktopCheckAsia__c', 'DesktopCheckAsia__c');
		fieldsToMap.put('CustomerName__c', 'Name');
		fieldsToMap.put('VendorType__c', 'VendorType__c');
		fieldsToMap.put('SicCode__c', 'Sic');
		fieldsToMap.put('SicDescription__c', 'SicDesc');
		fieldsToMap.put('SocioMinorityOwned__c', 'Is_MinorityOwned__c');
		fieldsToMap.put('SocioNonProfit__c', 'NonProfit__c');
		fieldsToMap.put('SocioSmallBusinessSB__c', 'Is_SmallBusiness__c');
		fieldsToMap.put('SocioLargeBusiness__c', 'LargeBusiness__c');
		fieldsToMap.put('SocioVeteranOwnedVO__c', 'Is_VeteranOwned__c');
		fieldsToMap.put('SocioWomenOwnedWO__c', 'Is_WomanOwned__c');
		fieldsToMap.put('SocioServiceDisabledVeteranOwnedSDVO__c', 'Is_DisabledVetOwned__c');
		fieldsToMap.put('Socio8aCertifiedFirms8a__c', 'Eight_A_Certified__c');
		fieldsToMap.put('SocioAbilityOne__c', 'AbilityOne__c');
		fieldsToMap.put('SocioAlaskaNativeCorpandTriballyOwned__c', 'AK_Native_Tribally_Owned__c');
		fieldsToMap.put('EcoEconomicallyDisadvantagedWomanOwned__c', 'ECO_Disadvn_WomanOwned_SB__c');
		fieldsToMap.put('SocioHistoricallyBlackCollegesandUniv__c', 'Hist_BLK_Minority_Inst__c');
		fieldsToMap.put('SocioSmallDisadvantagedBusinessSDB__c', 'SmallDisadvnBusiness__c');
		fieldsToMap.put('MKDenialStatus__c', 'MK_Denial__c');
		fieldsToMap.put('SocioHUBZone__c', 'HubZone__c');

		isUpdate = MapSourceToTarget(gbs, account, fieldsToMap);
		if(mapGBStoAccountAddress(gbs, account)){ isUpdate = true; }

		return isUpdate;
	}

	public Boolean mapGBStoSubAccount(SharedServicesRequest__c gbs, Account account){
		Boolean isUpdate = false;

		Map<String, String> fieldsToMap = new Map<String, String>();
		fieldsToMap.put('DBNumberDUNS__c', 'DBNumberDUNS__c');
		fieldsToMap.put('DesktopCheckAsia__c', 'DesktopCheckAsia__c');
		fieldsToMap.put('CustomerName__c', 'Name');
		fieldsToMap.put('ParentAccount__c', 'ParentID');
		fieldsToMap.put('VendorType__c', 'VendorType__c');
		fieldsToMap.put('SicCode__c', 'Sic');
		fieldsToMap.put('SicDescription__c', 'SicDesc');
		fieldsToMap.put('SocioMinorityOwned__c', 'Is_MinorityOwned__c');
		fieldsToMap.put('SocioNonProfit__c', 'NonProfit__c');
		fieldsToMap.put('SocioSmallBusinessSB__c', 'Is_SmallBusiness__c');
		fieldsToMap.put('SocioLargeBusiness__c', 'LargeBusiness__c');
		fieldsToMap.put('SocioVeteranOwnedVO__c', 'Is_VeteranOwned__c');
		fieldsToMap.put('SocioWomenOwnedWO__c', 'Is_WomanOwned__c');
		fieldsToMap.put('SocioServiceDisabledVeteranOwnedSDVO__c', 'Is_DisabledVetOwned__c');
		fieldsToMap.put('Socio8aCertifiedFirms8a__c', 'Eight_A_Certified__c');
		fieldsToMap.put('SocioAbilityOne__c', 'AbilityOne__c');
		fieldsToMap.put('SocioAlaskaNativeCorpandTriballyOwned__c', 'AK_Native_Tribally_Owned__c');
		fieldsToMap.put('EcoEconomicallyDisadvantagedWomanOwned__c', 'ECO_Disadvn_WomanOwned_SB__c');
		fieldsToMap.put('SocioHistoricallyBlackCollegesandUniv__c', 'Hist_BLK_Minority_Inst__c');
		fieldsToMap.put('SocioSmallDisadvantagedBusinessSDB__c', 'SmallDisadvnBusiness__c');
		fieldsToMap.put('MKDenialStatus__c', 'MK_Denial__c');
		fieldsToMap.put('SocioHUBZone__c', 'HubZone__c');

		isUpdate = MapSourceToTarget(gbs, account, fieldsToMap);
		if(mapGBStoAccountAddress(gbs, account)){ isUpdate = true; }

		return isUpdate;
	}

	public Boolean mapGBStoAccountAddress(SharedServicesRequest__c gbs, Account account){
		Boolean isUpdate = false;

		Map<String, String> fieldsToMap = new Map<String, String>();

		if(gbs.AddressIsPrimary__c){
			fieldsToMap.put('OfficePhone__c', 'Phone');
			fieldsToMap.put('City__c', 'City__c');
			fieldsToMap.put('StateProvinceEmirate__c', 'State_Province_Emerate__c');
			fieldsToMap.put('ZipPostalCode__c', 'Zip__c');
			isUpdate = MapSourceToTarget(gbs, account, fieldsToMap);

			String newStreet = gbs.Address1StreetPOBox__c;
			if(gbs.Address2StreetPOBox__c != null){ newStreet += ', ' + gbs.Address2StreetPOBox__c; }
			if(gbs.Address3StreetPOBox__c != null){ newStreet += ', ' + gbs.Address3StreetPOBox__c; }
			if(gbs.Address4StreetPOBox__c != null){ newStreet += ', ' + gbs.Address4StreetPOBox__c; }

			if(account.Street__c != newStreet){
				account.Street__c = newStreet;
				isUpdate = true;
			}

			if(mapCountry.containskey(gbs.Country__c)){
				if(account.CountryLookup__c != mapCountry.get(gbs.Country__c)){
					account.CountryLookup__c = mapCountry.get(gbs.Country__c);
					isUpdate = true;
				}
			}
		}
		else if (gbs.BillingAddress1isPrimary__c) {
			fieldsToMap.put('BillingOfficePhone__c', 'Phone');
			fieldsToMap.put('BillingAddressCity__c', 'City__c');
			fieldsToMap.put('BillingStateProvinceEmirate__c', 'State_Province_Emerate__c');
			fieldsToMap.put('BillingZipPostalCode__c', 'Zip__c');
			isUpdate = MapSourceToTarget(gbs, account, fieldsToMap);

			String newStreet = gbs.BillingStreetPOBox__c;
			if(gbs.BillingAddress2StreetPOBox__c != null){ newStreet += ', ' + gbs.BillingAddress2StreetPOBox__c; }
			if(gbs.BillingAddress3StreetPOBox__c != null){ newStreet += ', ' + gbs.BillingAddress3StreetPOBox__c; }
			if(gbs.BillingAddress4StreetPOBox__c != null){ newStreet += ', ' + gbs.BillingAddress4StreetPOBox__c; }

			if(account.Street__c != newStreet){
				account.Street__c = newStreet;
				isUpdate = true;
			}

			if(mapCountry.containskey(gbs.BillingAddressCountry__c)){
				if(account.CountryLookup__c != mapCountry.get(gbs.BillingAddressCountry__c)){
					account.CountryLookup__c = mapCountry.get(gbs.BillingAddressCountry__c);
					isUpdate = true;
				}
			}
		}
		else if (gbs.RemitIsPrimaryAddress__c) {
			fieldsToMap.put('RemitToAddressLine2__c', 'Phone');
			fieldsToMap.put('RemitToCity__c', 'City__c');
			fieldsToMap.put('RemitToStateProvinceEmirate__c', 'State_Province_Emerate__c');
			fieldsToMap.put('RemitToZipPostalCode__c', 'Zip__c');
			isUpdate = MapSourceToTarget(gbs, account, fieldsToMap);

			String newStreet = gbs.RemitToAddressLine1__c;
			if(gbs.RemitToAddressLine2__c != null){ newStreet += ', ' + gbs.RemitToAddressLine2__c; }

			if(account.Street__c != newStreet){
				account.Street__c = newStreet;
				isUpdate = true;
			}

			if(mapCountry.containskey(gbs.RemitToCountry__c)){
				if(account.CountryLookup__c != mapCountry.get(gbs.RemitToCountry__c)){
					account.CountryLookup__c = mapCountry.get(gbs.RemitToCountry__c);
					isUpdate = true;
				}
			}
		}

		return isUpdate;
	}
}