global class BatchUpdateOpportunityNameSearchable implements Database.Batchable<sObject>{

	global Database.querylocator start(Database.BatchableContext BC){
		if (Test.isRunningTest())
		{
            return Database.getQueryLocator('select Opportunity_Name__c, Opportunity_Name_Searchable__c ' +
            		' from Go_No_Go_Conversation__c  where Opportunity_Name_Searchable__c = \'\'  LIMIT 1');
		}
		else
		{
			return Database.getQueryLocator('select Opportunity_Name__c, Opportunity_Name_Searchable__c ' +
            		' from Go_No_Go_Conversation__c  where Opportunity_Name_Searchable__c = \'\'  ');
		}            		
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
	   try {
		    List<Go_No_Go_Conversation__c> gng = new List<Go_No_Go_Conversation__c>();
		
		   for(sObject s : scope){
		   		Go_No_Go_Conversation__c a = (Go_No_Go_Conversation__c)s;
		        if(a.Opportunity_Name__c != a.Opportunity_Name_Searchable__c){
		            a.Opportunity_Name_Searchable__c= a.Opportunity_Name__c;
		            gng.add(a);
	            }
	        }
		
		   update gng;
	   } 
	   catch(Exception e){}
	}
	
	global void finish(Database.BatchableContext BC){
	
	}
}