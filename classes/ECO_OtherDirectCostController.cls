public class ECO_OtherDirectCostController {
	
	public OtherDirectCost__c otherDirectCost {get; set;}
	public Agreement__c agreement {get; set;}
	
	public ECO_OtherDirectCostController(ApexPages.StandardController standardController)
	{
		otherDirectCost = (OtherDirectCost__c)standardController.getRecord();
	}

	public void init()
	{
		if(Apexpages.currentPage().getParameters().get('Agreement__c') != null)
		{
			otherDirectCost.Agreement__c = Apexpages.currentPage().getParameters().get('Agreement__c'); 
			agreement = [select Id, AgreementNumber__c, ContractTitle__c from Agreement__c where Id = :otherDirectCost.Agreement__c];		
		}
		else
			agreement = [select Id, AgreementNumber__c, ContractTitle__c from Agreement__c where Id = :otherDirectCost.Agreement__c];
	}
	
	public PageReference save()
	{
		if(otherDirectCost.Id == null)
			insert otherDirectCost;
		else
			update otherDirectCost;
		
		PageReference pageRef = new PageReference('/' + otherDirectCost.Agreement__c);
		return pageRef;
	}	
}