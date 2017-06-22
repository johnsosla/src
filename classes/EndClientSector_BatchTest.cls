@isTest
public class EndClientSector_BatchTest {
    
    static testMethod void UpdateEndClientSector() {            
        Account a = new Account();
        a.Name = 'US Airforce';
        a.Client_Group__c = 'National Government';
        a.Client_Subgroup__c = 'Other Agency';
        insert a;
        
        Account a1 = new Account();
        a1.Name = 'TEST Account';
        a1.Client_Group__c = 'National Government';
        a1.Client_Subgroup__c = 'Defense - Other';
        insert a1;
        
        
        List<Opportunity> opportunities = new List<Opportunity>();
		
        Opportunity opportunity = new Opportunity();
        	opportunity.Name='Test Opp0';
        	opportunity.AccountId=a.Id;
        	opportunity.Stagename = '1 Lead';
        	opportunity.probability = 100;
        	opportunity.TO_Procurement_Method__c = 'Competitive Task Orders';
        	opportunity.Capture_Manager_User__c = UserInfo.getUserId();
        	opportunity.closeDate = Date.today();
        	opportunity.Estimated_work_start_date__c = Date.today();
        	opportunity.ValidateGo__c = false;
        	opportunities.add(opportunity);  
        
        Integer i = 1;
       
		while (i < 9) { 
            opportunity = new Opportunity();
        	opportunity.Name='Test Opp' + string.valueOf(i);
        	opportunity.AccountId=a1.Id;
        	opportunity.Stagename = '1 Lead';
        	opportunity.probability = 100;
        	opportunity.TO_Procurement_Method__c = 'Competitive Task Orders';
        	opportunity.Capture_Manager_User__c = UserInfo.getUserId();
        	opportunity.closeDate = Date.today();
        	opportunity.Estimated_work_start_date__c = Date.today();
        	opportunity.ValidateGo__c = false;
        	opportunities.add(opportunity);      
        	i++;	
		}
        
        insert opportunities;
        
        opportunities = [select End_Client_Sector__c from Opportunity];      
        
        test.startTest();
        
        System.assertEquals('Other US Fed. Civilian Accts', opportunities[0].End_Client_Sector__c);
        
        
        EndClientSector_Batch b = new EndClientSector_Batch();
        b.BatchSize=null;                
        Database.executeBatch(b);
        
        
        test.stopTest();
    }

}