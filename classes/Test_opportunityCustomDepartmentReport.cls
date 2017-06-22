/******************************************************************************************************************************
Created By :    
Date       :    28 Sep 2010
Reason     :    Contains unit test methods for the Controller Class "opportunityCustomDepartmentReport"
*******************************************************************************************************************************/
@isTest
private class Test_opportunityCustomDepartmentReport {
    
    @isTest
    private static void unitTest1() {
        // Generate Test Data
        createTestData();
        
        // Run Report
        opportunityCustomDepartmentReport controller = new opportunityCustomDepartmentReport(null);
         
        // Getter method call : getContentType
        controller.getContentType();
        
        // set variables need to Run Report
        controller.forFrom.CloseDate = Date.newInstance(2010, 9, 02);
        controller.forTo.CloseDate = Date.newInstance(2010, 9, 26);
        controller.forFrom.Primary_Business_Line__c = 'PDD';
        controller.forFrom.Market_Segment__c = 'Architecture';
        controller.selectedStage = new List<String>{'1 Lead','5 SNB/Win/Award'};
        //controller.forFrom.Amount = 1000;
        //controller.forTo.Amount = 1000000;
        // "Run Report" button action
        controller.ClickedOnRunreport();
        
        //System.debug('____________' + controller.forExportURL);
        PageReference pg = new PageReference(controller.forExportURL);
        Test.setCurrentPage(pg);
        //System.debug('SOQL : ' + Apexpages.currentPage().getParameters().get('soql'));
        //System.debug('export : ' + Apexpages.currentPage().getParameters().get('export'));
        controller = new opportunityCustomDepartmentReport(null);
        controller.Cancel();
        // Getter method call : getContentType
        controller.getContentType();
        // Static method call 
        // Getter method: getStagePicklistValues
        opportunityCustomDepartmentReport.getStagePicklistValues();
        
        insertOpportunities();
        
        String oppQry = 'Select Contract_duration_in_Months__c,Name,AccountId,Account.Name,RecordType.Name,StageName,'+
        'Opportunity_ID__c,Ceiling_Amount_Total__c ,CloseDate, AECOM_Role__c,'+
        'Go_Probability__c, Probability, Subs_Other_Revenue__c, Task_Order_Number__c, Primary_Business_Line__c,'+ 
        'Market_Segment__c, Practice_Area__c, Multiple_Geographies__c, Bid_Proposal_Charge__c, B_P_Budget__c,'+
        'B_P_Actual_to_date__c, BL_Distribution__c, Book_date__c, Client_Solicitation_ID_number__c,'+ 
        'Competitive_Bid_or_Sole_source__c, Construction_cost__c, Contract_Type__c, Date_lost_cancelled_no_go__c,'+ 
        'Date_RFP_expected__c, Date_RFP_received__c, Date_RFQ_expected__c, Date_RFQ_received__c, Project_City__c,'+ 
        'Project_State_Province__c, ProjectCountry__c, Submittal_Date_Proposal__c, Go_No_Go_Request_submitted_date__c,'+
        'Hub_Approval_required__c, Internal_proposal_ID_number__c, Market_Sector_Priority__c,'+ 
        'MPRC_Approval_required__c, Project_Delivery_Method__c, Proposal_Location__c,'+ 
        'Reason_Won_or_Lost__c, Report_comments__c, Strategic_Pursuit__c, Transportation_Initiatives__c,'+ 
        'PDD_D_P_E_Primary_Global_Practice_Line__c, PDD_D_P_E_Secondary_Global_Practice_Line__c,'+ 
        'PDD_General_Market_Sector__c, PDD_Practice_Line__c, PDD_Services__c, Services__c, Stimulus_Funding__c,'+ 
        'Id,Amount ,(Select AECOM_Department__r.Name, split__c,Primary__c From Opportunity_Departments__r),'+
        '(Select Employee__r.Name,role__c FROM AECOM_Team1__r) FROM Opportunity Where Id != null  limit 5';
        
        controller.runreport(oppQry);
    }
    
    private static void createTestData() {
        // AECOM Employee
        AECOM_Employee__c aecomEmp = new AECOM_Employee__c(First_Name__c='test', Last_Name__c='emp', Employee_ID__c='1234$321');
        insert aecomEmp;
         Map<String,ID> recordTypesMap = new Map<String,ID>();
        for(RecordType r:[select id,Name from RecordType where sObjectType='Opportunity' and isActive=true]){
            recordTypesMap.put(r.Name,r.Id);
            system.debug('###' + r.Name);
        }
        // Opprotunity
        List<Opportunity> listOpp = new List<Opportunity>();
        Opportunity opp = new Opportunity(Name='test opp', 
                                          StageName='1 Lead', 
                                          CloseDate=Date.newInstance(2010, 9, 25), 
                                          RecordTypeId = recordTypesMap.get('Project - APAC'),
                                          Amount = 10000,Legacy_OpportunityID__c='1002',  Estimated_work_start_date__c = Date.today(),
                                          ProjectCountry__c = 'Test', Enterprise_Service__c = 'None', TO_Procurement_Method__c = 'Test',
                                          Capture_Manager__c = aecomEmp.Id,
                                          CS_Gross_Margin_Percent__c = 15);
        
        listOpp.add(opp);
        
        // Opprotunity
        Opportunity opp2 = new Opportunity(Name='test opp 2', 
                                          StageName='1 Lead', 
                                          CloseDate=Date.newInstance(2010, 9, 20), 
                                          
                                          RecordTypeId = recordTypesMap.get('Project - APAC'), Estimated_work_start_date__c = Date.today(),
                                          ProjectCountry__c = 'Test', Enterprise_Service__c = 'None', TO_Procurement_Method__c = 'Test',
                                          Amount = 10000,Legacy_OpportunityID__c='1003',
                                          CS_Gross_Margin_Percent__c = 15);
        
        listOpp.add(opp2);
        
        // Opprotunity
        Opportunity opp3 = new Opportunity(Name='test opp 3', 
                                          StageName='1 Lead', 
                                          CloseDate=Date.newInstance(2010, 9, 15), 
                                          
                                          RecordTypeId = recordTypesMap.get('Project - Americas'), Estimated_work_start_date__c = Date.today(),
                                          ProjectCountry__c = 'Test', Enterprise_Service__c = 'None', TO_Procurement_Method__c = 'Test',
                                          Amount = 10000,Legacy_OpportunityID__c='1001',
                                          CS_Gross_Margin_Percent__c = 15);
        
        listOpp.add(opp3);
        
        insert listOpp;
        
        // Account
        Account act = new Account(Name='test Account', Account_Manager__c = aecomEmp.Id,Legacy_AccountID__c='123#ed');
        insert act;
        
        // AECOM Department
        List<AECOM_Primary_Department__c> listAECOMDeppt = new List<AECOM_Primary_Department__c>();
        AECOM_Primary_Department__c aecomDept = new AECOM_Primary_Department__c(Name='Test Dept', 
                                                                                Geography__c='North America',
                                                                                Lead_District__c = 'Central Midwest',
                                                                                Lead_Region__c = 'CA');
        
        listAECOMDeppt.add(aecomDept);
        
        aecomDept = new AECOM_Primary_Department__c(Name='Test Dept', 
                                                    Geography__c='North America',
                                                    Lead_District__c = 'Central Midwest',
                                                    Lead_Region__c = 'CA');
        
        listAECOMDeppt.add(aecomDept);
        
        insert listAECOMDeppt;
        
        // Opportunity Department
        List<Opportunity_Department__c> listOppDept = new List<Opportunity_Department__c>();
        Opportunity_Department__c oppDept = new Opportunity_Department__c(AECOM_Department__c = listAECOMDeppt[0].Id,
                                                                          Opportunity__c = opp.Id,
                                                                          Primary__c = true,
                                                                          Split__c = 10);
        
        listOppDept.add(oppDept);
        
        oppDept = new Opportunity_Department__c(AECOM_Department__c = listAECOMDeppt[0].Id,
                                                Opportunity__c = opp.Id,
                                                Primary__c = false,
                                                Split__c = 20);
        
        listOppDept.add(oppDept);
        
        oppDept = new Opportunity_Department__c(AECOM_Department__c = listAECOMDeppt[0].Id,
                                                Opportunity__c = opp.Id,
                                                Primary__c = false,
                                                Split__c = 40);
        
        listOppDept.add(oppDept);
        
        oppDept = new Opportunity_Department__c(AECOM_Department__c = listAECOMDeppt[1].Id,
                                                Opportunity__c = opp.Id,
                                                Primary__c = false,
                                                Split__c = 60);
        
        listOppDept.add(oppDept);
        
        oppDept = new Opportunity_Department__c(AECOM_Department__c = listAECOMDeppt[1].Id,
                                                Opportunity__c = opp.Id,
                                                Primary__c = false,
                                                Split__c = 50);
        
        listOppDept.add(oppDept);
        
        oppDept = new Opportunity_Department__c(AECOM_Department__c = listAECOMDeppt[1].Id,
                                                Opportunity__c = opp.Id,
                                                Primary__c = false,
                                                Split__c = 10);
        
        listOppDept.add(oppDept);
        
        insert listOppDept;
        
        
        // AECOM Team
        List<AECOM_team__c> listAECOMTeam = new List<AECOM_team__c>();
        AECOM_team__c aecomTeam = new AECOM_team__c(Opportunity__c=opp.Id, Employee__c=aecomEmp.Id, Role__c='Principal in Charge');
        listAECOMTeam.add(aecomTeam);
        
        aecomTeam = new AECOM_team__c(Opportunity__c=opp2.Id, Employee__c=aecomEmp.Id, Role__c='Business Lead');
        listAECOMTeam.add(aecomTeam);
        
        aecomTeam = new AECOM_team__c(Opportunity__c=opp3.Id, Employee__c=aecomEmp.Id, Role__c='BD Lead');
        listAECOMTeam.add(aecomTeam);
        
        //insert listAECOMTeam;
    }
    
    
     public static void insertOpportunities() {
        Map<String,Id> recordTypes = new Map<String,Id>();
        List<Opportunity> opportunities = new List<Opportunity>(); 
        for(RecordType  recType :[Select Name, Id From RecordType where SobjectType ='Opportunity']){
            recordTypes.put(recType.Name,recType.Id);
        }
        
		AECOM_Primary_Department__c primaryDept = new AECOM_Primary_Department__c(Lead_Region__c = 'test Lead Region');
        primaryDept.Status__c = 'Active';
		insert primaryDept;      
         
       // Account
        Account acc=new Account();
        acc.Name='Test Account';
        acc.Type__c='Client';
        acc.Client_Group__c='Industrial/Commercial';
        acc.Client_Subgroup__c='Small - population under 500K';
        acc.Legacy_AccountID__c='12212' + System.now();
        acc.City__c='testCity';
        insert acc;
        
        // Master Contract
        Opportunity masterContract=new Opportunity();
        masterContract.AccountId=acc.id;
        masterContract.Name='Test';
        masterContract.Primary_Business_Line__c='Water';
        masterContract.AECOM_Primary_Dept_Lookup__c=primaryDept.Id;
        masterContract.CloseDate=Date.today();
        masterContract.StageName='1 Lead';

        //masterContract.RecordTypeId=[select ID from RecordType where Name='Program'].Id;
        masterContract.RecordTypeId=recordTypes.get('Program - APAC');
        
        masterContract.Legacy_OpportunityID__c='test' + System.now();
        masterContract.Project_State_Province__c = 'This is text DEscription';
        masterContract.Estimated_work_start_date__c = Date.today();
        masterContract.Enterprise_Service__c = 'None';
        masterContract.TO_Procurement_Method__c = 'Test';

        // added to pass validation rule
        masterContract.CS_Gross_Margin_Percent__c = 15;

        opportunities.add(masterContract);      
                
        // Second Master Contract
        Opportunity masterContract2=new Opportunity();
        masterContract2.AccountId=acc.id;
        masterContract2.Name='Test';
        masterContract2.Primary_Business_Line__c='Water';
        masterContract2.AECOM_Primary_Dept_Lookup__c=primaryDept.Id;
        masterContract2.CloseDate=Date.today();
        masterContract2.StageName='1 Lead';
        masterContract2.RecordTypeId=recordTypes.get('Program - Americas');
        masterContract2.Legacy_OpportunityID__c='test1' + System.now();
        masterContract2.Estimated_work_start_date__c = Date.today();
        masterContract2.Enterprise_Service__c = 'None';
        masterContract2.TO_Procurement_Method__c = 'Test';

        // added to pass validation rule
        masterContract2.CS_Gross_Margin_Percent__c = 15;

        opportunities.add(masterContract2);
        
        insert opportunities;
     }
    
}