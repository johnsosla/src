@istest
public with sharing class TestProjectOpportunityExtension {
    public static Opportunity opp;

    
    
    
    @isTest (seeAllData=false)
    static void testProjectOpportunityExtension() {
        createTestData();
        
        ApexPages.Standardcontroller ctl = new ApexPages.Standardcontroller(opp);
        ProjectOpportunityExtension ext = new ProjectOpportunityExtension(ctl);
        ext.saveProject();
    }
    
    
    private static void setup()
    {
            Opp_Project_Field_Map__c xx = new Opp_Project_Field_Map__c();
            xx.Name = 'AECOM_Job_number__c';
            xx.Project_Field_Name__c = 'Project_Name__c';
            xx.Default_Value__c = '12345';
            insert xx;
        
            Opp_Project_Field_Map__c xxy = new Opp_Project_Field_Map__c();
            xxy.Name = 'Description';
            xxy.Project_Field_Name__c = 'Project_Description__c';
            xxy.Default_Value__c = '12345';
            insert xxy;     
            
            Opp_Project_Field_Map__c acc = new Opp_Project_Field_Map__c();
            acc.Name = 'AccountId';
            acc.Project_Field_Name__c = 'Owner__c';
            acc.Default_Value__c = '000000000000000000';
            insert acc;                
            
            Opp_Project_Field_Map__c xxx = new Opp_Project_Field_Map__c();
            xxx.Name = 'Name';
            xxx.Project_Field_Name__c = 'Name';
            xxx.Default_Value__c = 'Project Name';
            insert xxx; 
        
            Opp_Project_Field_Map__c abc = new Opp_Project_Field_Map__c();
            abc.Name = 'Project_City__c';
            abc.Project_Field_Name__c = 'Project_City__c';
            abc.Default_Value__c = 'Project city';
            insert abc; 

            Opp_Project_Field_Map__c abc2 = new Opp_Project_Field_Map__c();
            abc2.Name = 'ProjectCountry__c';
            abc2.Project_Field_Name__c = 'Project_Country__c';
            abc2.Default_Value__c = 'Project country';
            insert abc2;            
            
            ValidState__c state = new ValidState__c();
            state.State__c = null;
            state.Country__c = 'Australia';
            insert state;
    }    
    
    private static void createTestData() {
        setup();
		Map<String,Id> recordTypes = new Map<String,Id>();
        List<Opportunity> opportunities = new List<Opportunity>(); 
        for(RecordType  recType :[Select Name, Id From RecordType where SobjectType ='Opportunity']){
            recordTypes.put(recType.Name,recType.Id);
        }
        
		AECOM_Primary_Department__c primaryDept = new AECOM_Primary_Department__c(Lead_Region__c = 'test Lead Region');
        primaryDept.Status__c = 'Active';
		insert primaryDept;        
        
/*        Id aecomId;
        for(AECOM_Primary_Department__c aecom :[select id from AECOM_Primary_Department__c WHERE Status__c = 'Active'  limit 1]){
            aecomId = aecom.id;
        } */
        
       // Account
        Account acc1=new Account();
        acc1.Name='Test Account1';
        acc1.Type__c='Client';
        acc1.Client_Group__c='Industrial/Commercial';
        acc1.Client_Subgroup__c='Small - population under 500K';
        acc1.Legacy_AccountID__c='1221234';
        acc1.City__c='testCity';
        insert acc1;
        
        // Master Contract
        opp=new Opportunity();
        opp.AccountId=acc1.id;
        opp.Name='Test';
        opp.Primary_Business_Line__c='Water';
        opp.AECOM_Primary_Dept_Lookup__c=primaryDept.Id;
        opp.CloseDate=Date.today();
        opp.StageName='6 Test';
        opp.RecordTypeId=recordTypes.get('Program - APAC');
        
        opp.Legacy_OpportunityID__c='test' + System.now();
        opp.Project_State_Province__c = 'This is text DEscription';   
        opp.CM_Type__c='Test';     
        opp.Contract_Est_Months__c = 5;
        opp.WinDate__c = system.today();
        opp.Project_State_Province__c='WI';
        opp.AECOM_Job_Number__c='01010101';
        opp.Services__c = 'Test 1';
        opp.Energy_Service_Type__c = 'Test 2';
        opp.Reason_Won_or_Lost__c = 'Test';
        opp.Enterprise_Service__c = 'None';
        opp.AECOM_Job_number__c = '123';
        opp.Reason_Won_or_Lost__c = 'Technical Team';
        opp.Date_Canceled__c = date.today();
        opp.Date_lost_cancelled_no_go__c = date.today();
        insert opp;
        
        // Account
        Account part=new Account();
        part.Name='Test Account1';
        part.Type__c='Subcontractor';
        part.Client_Group__c='Industrial/Commercial';
        part.Client_Subgroup__c='Small - population under 500K';
        part.Legacy_AccountID__c='01101101';
        part.City__c='testCity';
        insert part;
        
        Partner op = new Partner();
        op.OpportunityId = opp.id;
        op.AccountToId=part.ID;
        op.Role = 'Alliance Partner';
        insert op;
        
            // Account
        Account prime=new Account();
        prime.Name='Test Account1';
        prime.Type__c='Subcontractor';
        prime.Client_Group__c='Industrial/Commercial';
        prime.Client_Subgroup__c='Small - population under 500K';
        prime.Legacy_AccountID__c='011011301';
        prime.City__c='testCity';
        insert prime;
        
        Partner op2 = new Partner();
        op2.OpportunityId = opp.id;
        op2.AccountToId=prime.ID;
        op2.Role = 'Prime';
        insert op2;
       
    }
    
    
     
}