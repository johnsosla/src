@isTest (seeAllData=false)

public class EndClientSector_Triggers_Test {
    
	static testMethod void UpdateEndClientSector() {            
        Account a = new Account();
        a.Name = 'Test Account';
        a.Client_Group__c = 'Municipal';
        a.Client_Subgroup__c = 'Utility/Regulatory Agency - Water';
        insert a;
        
        Account account = [select id, name, client_group__c, client_subgroup__c from account limit 1];
        List<Id> accountIds = new List<Id>();
        accountIds.add(account.Id);
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name='Test Opp';
        opportunity.AccountId=account.Id;
        opportunity.Stagename = '1 Lead';
        opportunity.probability = 100;
        opportunity.TO_Procurement_Method__c = 'Competitive Task Orders';
        opportunity.Capture_Manager_User__c = UserInfo.getUserId();
        opportunity.closeDate = Date.today();
        opportunity.Estimated_work_start_date__c = Date.today();
        opportunity.ValidateGo__c = false;
        insert opportunity;
        
        Opportunity o = [select End_Client_Sector__c from Opportunity where Id=:opportunity.Id];
        
        a.Client_Subgroup__c = 'Utility/Regulatory Agency - Water';
        update a;
        
        test.startTest();
        
        EndClientSector_Triggers.setEndClientSector(accountIds);
        System.assertEquals('Public Sector', o.End_Client_Sector__c);
        
        test.stopTest();
    }
}