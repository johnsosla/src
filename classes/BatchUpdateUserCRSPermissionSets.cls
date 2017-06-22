global class BatchUpdateUserCRSPermissionSets implements Database.Batchable<sObject>{

	global Database.querylocator start(Database.BatchableContext BC){
		if (Test.isRunningTest())
		{
			
            return Database.getQueryLocator('Select id , u.Nationality__c From User u where isActive = true order by CreatedDate desc LIMIT 1');
		}
		else
		{
			 return Database.getQueryLocator('Select id , u.Nationality__c From User u  where isActive = true ');
		}            		
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
	   try {
		    List<User> user = new List<User>();
		
		   for(sObject s : scope){
		   		User a = (User)s;
			    a.Nationality__c= '1';
	            user.add(a);
	        }
		
		   update user;
	   } 
	   catch(Exception e){}
	}
	
	global void finish(Database.BatchableContext BC){
	
	}
}