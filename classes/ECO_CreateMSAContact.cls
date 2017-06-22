public class ECO_CreateMSAContact {
	
	public ManagementTeam__c managementTeam {get; set;}
	public ManagementTeam__c clientMember {get; set;}
	public ManagementTeam__c vendorMember {get; set;}
	public boolean creatingNewContact {get; set;}
	public Contact contact {get; set;}
	public Agreement__c agreement {get; set;}
	
	public ECO_CreateMSAContact(ApexPages.standardController sc)
	{
		managementTeam = (ManagementTeam__c)sc.getRecord();
//		managementTeam.Agreement__c = 'a4Ye00000009lshEAA';
	}

	public void init()
	{
		agreement = [select Id, AgreementNumber__c, ContractTitle__c from Agreement__c where Id = :managementTeam.Agreement__c limit 1];
		clientMember = new ManagementTeam__c();
		vendorMember = new ManagementTeam__c();
	}

	public void createNewContact()
	{
		agreement = [select Id, Account__c, ContractTitle__c, AgreementNumber__c from Agreement__c where Id = :managementTeam.Agreement__c limit 1];

		creatingNewContact = true;
		contact = new Contact(AccountId = agreement.Account__c);
		
		//return null;
	}
	
	public PageReference save()
	{
		update managementTeam;
		
		PageReference pageRef = new PageReference('/apex/ECO_AgreementView');
		pageRef.getParameters().put('Id', managementTeam.Agreement__c);
		return pageRef;
	}
	
	public PageReference saveNewContact()
	{
		creatingNewContact = false;
		
		insert contact;
		managementTeam.TeamMember__c = contact.Id;
		
		return null;
	}
	
	public PageReference cancelNewContact()
	{
		creatingNewContact = false;
		
		return null;
	}	

}