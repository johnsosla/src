public class ECO_ContractReviewDTO {
	
	public 	list<Id> 	OpportunityIds 			{get; set;}
	public 	String 		BusinessLine   			{get; set;}
	public 	Id       	ClientVendorId 			{get; set;}
	public  String 		ClientVendorName        {get; set;}
	public 	String 		ContractType			{get; set;}
	public 	Id			ProjectManagerId		{get; set;}		
	public 	Id			ProjectDirectorId		{get; set;}
	public 	String		AgreementCurrency		{get; set;}
	public 	Decimal		EstimatedFee			{get; set;}
	public 	Id			ProjectId				{get; set;}
	public	String		ProjectName				{get; set;}
	public 	String		ScopeOfServices			{get; set;}
	public 	Decimal		ProfessionalIndemnity	{get; set;}
	public 	Decimal		PublicIndemnity			{get; set;}
	public	Boolean 	FederealContract 		{get; set;}
	
}