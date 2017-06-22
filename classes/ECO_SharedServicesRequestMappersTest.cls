/** ------------------------------------------------------------------------------------------------------
* @Description Test for Mapping class for GBS to object graph of Sites and Contacts for create and update
*
* @Author      AECOM, Steve MunLeeuw
* @Date        June 10, 2016
*-----------------------------------------------------------------------------------------------------*/

@IsTest
private class ECO_SharedServicesRequestMappersTest{
	private static List<SharedServicesRequest__c> ssrs = new List<SharedServicesRequest__c>();
	private static ECO_SharedServicesRequestMappers mapper = new ECO_SharedServicesRequestMappers();
	private static Site__c site = new Site__c();
	private static Site__c targetSite = new Site__c();
	private static Contact targetContact = new Contact();

	private static void init(){
		Account a = new Account(Name = 'a');
		insert a;
		targetSite.Account__c = a.Id;
		insert targetSite;


		ssrs.add(new SharedServicesRequest__c(
			OUName__c = 'ou', 
			City__c = 'city',
			ReferenceSite__c = targetSite.Id,
			ReferenceBillingSite__c = targetSite.Id,
			ReferenceRemitSite__c = targetSite.Id,
			Address1StreetPOBox__c = 'a1',
			Address2StreetPOBox__c = 'a2',
			Address3StreetPOBox__c = 'a3',
			Address4StreetPOBox__c = 'a4',
			ZipPostalCode__c = '80521',
			Country__c = 'Australia',
			AddressIsPrimary__c = true,
			BillingStreetPOBox__c = 'b1',
			BillingAddress2StreetPOBox__c = 'b2',
			BillingAddress3StreetPOBox__c = 'b3',
			BillingAddress4StreetPOBox__c = 'b4',
			BillingAddressCity__c = 'bcity',
			BillingZipPostalCode__c = 'bzip',
			BillingAddressCountry__c = 'bcountry',
			BillingAddress1isPrimary__c = false,
			RemitToAddressLine1__c = 'r1',
			RemitToAddressLine2__c = 'r2',
			RemitToCity__c = 'rcity',
			RemitToZipPostalCode__c = 'rzip',
			RemitToCountry__c = 'rcountry',
			RemitIsPrimaryAddress__c = false,
			PrimaryContactLastName__c = 'pLN',
			PrimaryContactFirstName__c = 'pFN',
			PrimaryContactEmail__c = 'pe',
			PrimaryContactPhone__c = 'pp',
			BillingContactLastName__c = 'bLN',
			BillingContactFirstName__c = 'bFN',
			BillingContactEmail_1__c = 'be',
			BillingContactPhone__c = 'bp',
			Contact1LastName__c = 'c1LN',
			Contact1FirstName__c = 'c1FN',
			Contact1EmailAddress__c = 'c1e',
			Contact1Phone__c = 'c1p',
			CustomerContact1Role__c = 'c1r',
			Contact2LastName__c = 'c2LN',
			Contact2FirstName__c = 'c2FN',
			Contact2Email__c = 'c2e',
			Contact2Phone__c = 'c2p',
			CustomerContact2Role__c = 'c2r'
			));
		OrganizationString__c org = new OrganizationString__c(OUName__c = 'ou', OUID__c = 'ouid');
		insert org;
		
		mapper.cacheOUs(ssrs);
	}

	@IsTest
	private static void mapGBStoSite(){
		//arrange
			init();

		//act
			mapper.mapGBStoSite(ssrs[0], site);

		//assert
			system.assertEquals('city', site.City__c, 'Expected City to map');

	}
/*
	@IsTest
	private static void updateSites_Reference(){
		//arrange
			init();

		//act
			mapper.updateSites('ReferenceSite__c', ssrs);

		//assert
			Site__c updatedSite = [SELECT Address1__c, OUID__c FROM Site__c WHERE Id = :targetSite.Id];
			system.assertEquals('a1', updatedSite.Address1__c, 'Expected Address 1 to map');
			system.assertEquals('ouid', updatedSite.OUID__c, 'Expected OrganizationString lookup to find match');
	}

	//@IsTest
	private static void updateSites_Billing(){
		//arrange
			init();

		//act
			mapper.updateSites('ReferenceBillingSite__c', ssrs);

		//assert
			Site__c updatedSite = [SELECT Address1__c, OUID__c FROM Site__c WHERE Id = :targetSite.Id];
			system.assertEquals('b1', updatedSite.Address1__c, 'Expected Address 1 to map');
	}

	//@IsTest
	private static void updateSites_Remit(){
		//arrange
			init();

		//act
			mapper.updateSites('ReferenceRemitSite__c', ssrs);

		//assert
			Site__c updatedSite = [SELECT Address1__c, OUID__c FROM Site__c WHERE Id = :targetSite.Id];
			system.assertEquals('r1', updatedSite.Address1__c, 'Expected Address 1 to map');
	}
*/

	@IsTest
	private static void mapGBStoPrimaryContact(){
		//arrange
			init();

		//act
			mapper.mapGBStoPrimaryContact(ssrs[0], targetContact);

		//assert
			system.assertEquals('pLN', targetContact.LastName, 'Expected LastName 1 to map');
	}

	@IsTest
	private static void mapGBStoBillingContact(){
		//arrange
			init();

		//act
			mapper.mapGBStoBillingContact(ssrs[0], targetContact);

		//assert
			system.assertEquals('bLN', targetContact.LastName, 'Expected LastName 1 to map');
	}

	@IsTest
	private static void mapGBStoContact1(){
		//arrange
			init();

		//act
			mapper.mapGBStoContact1(ssrs[0], targetContact);

		//assert
			system.assertEquals('c1LN', targetContact.LastName, 'Expected LastName 1 to map');
	}


	@IsTest
	private static void mapGBStoContact2(){
		//arrange
			init();

		//act
			mapper.mapGBStoContact2(ssrs[0], targetContact);

		//assert
			system.assertEquals('c2LN', targetContact.LastName, 'Expected LastName 1 to map');
	}
}