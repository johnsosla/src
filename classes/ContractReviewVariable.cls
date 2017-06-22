/*******************************************************************
  Name        :   ContractReviewVariable
  Requester   :   CRS Requirments
  Author      :   AECOM - Luke Farbotko
  Version     :   1.0 
  Purpose     :   Variable using in process builder APEX  invocable method
  				  ContractReview.Assign(List<ContractReviewVariable> vars) 
  Date        :   12 Feb, 2015 

********************************************************************/
global class ContractReviewVariable {


	@InvocableVariable(required=true)
	public ID crId;
	
	@InvocableVariable(required=true)
	public string queueName;
	
}