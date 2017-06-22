/*******************************************************************
  Name        :   ContractReview
  Requester   :   CRS Requirments
  Author      :   AECOM - Luke Farbotko
  Version     :   1.0 
  Purpose     :   used by in process builder to assign a contract to a  
  				  prefered person or legal queue
  Date        :   12 Feb, 2015 

********************************************************************/
public with sharing class ContractReview {
	@InvocableMethod(label='ContractReviewAssignment')
	public static void Assign(List<ContractReviewVariable> vars) {
   	 	
			
   	 	for(ContractReviewVariable v : vars) {
   	 		
    		
        	Contract_Review__c cr = [select Id, OwnerId, Legal_Team__c , Preferred_Contract_Reviewer__c, Federal_Contract__c  from Contract_Review__c where id = :v.crId]; 
        	
        	
        	
        	if(cr.Federal_Contract__c == true){
        		Group queueFederalUS = [select Id from Group where Name = 'Legal Federal US' and Type = 'Queue'];
        		cr.OwnerId  = queueFederalUS.Id;
        	}
        	else{
        		//if (cr.Preferred_Contract_Reviewer__c <> null){
        			//cr.OwnerId = cr.Preferred_Contract_Reviewer__c;
        		
	        	//}
	        	//else {
	        		Group queue = [select Id from Group where Name = :v.queueName and Type = 'Queue'];
	        		cr.OwnerId  = queue.Id;
	        		
	        	//}
        	}
        
        	cr.Legal_Team__c = v.queueName;
        	Update cr;
        	
   	 	}
   	 
		return ;
	}
}