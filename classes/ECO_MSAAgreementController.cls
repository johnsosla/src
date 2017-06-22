public class ECO_MSAAgreementController {
	
	public Agreement__c agreement {get; set;}
	public String mode {get; set;}
	public String clientId {get; set;}
	public String contractType {get; set;}
	
	public ECO_MSAAgreementController()
	{
		clientId = ApexPages.currentPage().getParameters().get('clientId'); 
        contractType = ApexPages.currentPage().getParameters().get('contractType');		
	}
	
	public PageReference init()
	{
		RecordType recordType = [select Id, DeveloperName from RecordType where DeveloperName = 'PrimeMSA'];
		Agreement__c agreement = new Agreement__c(Account__c = clientId, RecordTypeId = recordType.Id, AgreementsMSA__c = clientId);
		insert agreement;
		
		PageReference ref = new PageReference('/apex/ECO_AgreementView');
		ref.getParameters().put('Id', agreement.Id);
		ref.getParameters().put('Mode', 'Edit');
		return ref;
		
		
	}

	

}