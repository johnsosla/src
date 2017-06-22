public class ECO_MSATeamingPartnerController {
	
	public MSATeamingPartner__c msaTeamingPartner {get; set;}
	public Agreement__c agreement {get; set;}
	
	public ECO_MSATeamingPartnerController(ApexPages.StandardController standardController)
	{
		msaTeamingPartner = (MSATeamingPartner__c)standardController.getRecord();
	}

	public void init()
	{
		if(Apexpages.currentPage().getParameters().get('Agreement__c') != null)
		{
			msaTeamingPartner.Agreement__c = Apexpages.currentPage().getParameters().get('Agreement__c'); 
			agreement = [select Id, AgreementNumber__c, ContractTitle__c from Agreement__c where Id = :msaTeamingPartner.Agreement__c];		
		}
		else
		{
			agreement = [select Id, AgreementNumber__c, ContractTitle__c from Agreement__c where Id = :msaTeamingPartner.Agreement__c];		
		}
	}
	
	public PageReference save()
	{
		if(msaTeamingPartner.Id == null)
			insert msaTeamingPartner;
		else
			update msaTeamingPartner;
		
		PageReference pageRef = new PageReference('/' + msaTeamingPartner.Agreement__c);
		return pageRef;
	}	
}