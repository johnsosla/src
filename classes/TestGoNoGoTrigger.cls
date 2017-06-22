@isTest
private class TestGoNoGoTrigger {
    private static Account createAccount() {
        Account acc = new Account(Name='Test Account');
        insert acc;
        return acc;
    }
    
    private static Opportunity createOpportunity(Account act, AECOM_Primary_Department__c dept) {
        // AECOM Employee
        AECOM_Employee__c aecomEmp = new AECOM_Employee__c(First_Name__c='test', Last_Name__c='emp', Employee_ID__c='1234$321');
        insert aecomEmp;
        Map<String,ID> recordTypesMap = new Map<String,ID>();
        for(RecordType r:[select id,Name from RecordType where sObjectType='Opportunity' and isActive=true]){
            recordTypesMap.put(r.Name,r.Id);
            system.debug('###' + r.Name);
        }
        
        Opportunity opp = new Opportunity(Name='test opp', 
                                          StageName='1 Lead', 
                                          CloseDate=Date.newInstance(2010, 9, 25), 
                                          RecordTypeId = recordTypesMap.get('Project - APAC'),
                                          Amount = 10000, 
                                          Legacy_OpportunityID__c='1002', 
                                          ProjectCountry__c='United States',
                                          AECOM_Primary_Dept_Lookup__c=dept.Id,
                                          Estimated_work_start_date__c = Date.today().addDays(90),
                                          TO_Procurement_Method__c = 'Competitive Task Orders',
                                          Enterprise_Service__c = 'Engineering',
                                          CS_Gross_Margin_Percent__c = 15
                                          );
        insert opp;
        return opp;
    }
    
    private static Go_No_Go_Conversation__c createGNG(Opportunity opp) {
        Go_No_Go_Conversation__c gng = new Go_No_Go_Conversation__c(Opportunity__c=opp.ID);
        gng.Participants__c = 'Test participant 1';
        gng.AECOM_Work_primary__c = 'Aviation';
        insert gng;
        return gng;
    }
    
    private static List<ExecuteTrigger__c> createCustomSettings() {
        List<ExecuteTrigger__c> settings = new List<ExecuteTrigger__c>();
        ExecuteTrigger__c noActTrigger = new ExecuteTrigger__c(Name='taskRelatedtoAccountmanager', NotRunTrigger__c=true);
        ExecuteTrigger__c noOppTrigger = new ExecuteTrigger__c(Name='OpportunityBeforeInsertBeforeUpdate', NotRunTrigger__c=true);
        insert settings;
        return settings;
    }
    
    private static AECOM_Primary_Department__c createAECOMDept(String name, String region) {
        AECOM_Primary_Department__c aeDept = new AECOM_Primary_Department__c();
        if(name != null) {
            aeDept.Name = name;    
        } else {
            aeDept.Name = 'Test Dept Name';
        }

        if(region != null) {
            aeDept.Lead_Region__c = region;    
        } else {
            aeDept.Lead_Region__c = 'Test Region';    
        }
        
        
        insert aeDept;
        return aeDept;
    }

    @isTest (SeeAllData=true) private static void test_gng_trigger_sets_charge_number_on_opp() {
        List<ExecuteTrigger__c> sets = createCustomSettings();
        Account acc = createAccount();
        AECOM_Primary_Department__c prim = createAECOMDept(null, null);
        Opportunity opp = createOpportunity(acc, prim);
        Go_No_Go_Conversation__c g = createGNG(opp);
        g.B_P_Charge_Number__c = 'Test Number';
        upsert g;
       
        Opportunity updatedOpp = [SELECT ID, Name, Bid_Proposal_Charge__c FROM Opportunity WHERE ID = :opp.ID];
        System.assertEquals('Test Number', updatedOpp.Bid_Proposal_Charge__c);
    }
}