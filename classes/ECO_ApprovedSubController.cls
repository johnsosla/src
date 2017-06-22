public class ECO_ApprovedSubController {
	
	public Approved_Sub__c approvedSub {get; set;}
	public Agreement__c agreement {get; set;}

	public ECO_ApprovedSubController(ApexPages.standardController controller)
	{
		approvedSub = (Approved_Sub__c)controller.getRecord();	
	}
	
	public void init()
	{
		if(Apexpages.currentPage().getParameters().get('Agreement__c') != null)
		{
			approvedSub.Agreement__c = Apexpages.currentPage().getParameters().get('Agreement__c'); 	
			agreement = [select Id, ContractTitle__c, AgreementNumber__c from Agreement__c where Id = :approvedSub.Agreement__c];
		}
		else
			agreement = [select Id, ContractTitle__c, AgreementNumber__c from Agreement__c where Id = :approvedSub.Agreement__c];

	}
	
	public PageReference save()
	{
		if(approvedSub.Id == null)
			insert approvedSub;
		else
			update approvedSub;
		
		PageReference pageRef = new PageReference('/' + approvedSub.Agreement__c);
		return pageRef;
	}
	
}