@isTest
private class ECO_BudgetHeaderSummaryControllerTest {
    @testSetup static void initData() {
        ECO_Utils_Testing.createTestDataForBudgets();
    }

    static pse__Proj__c initEmptyProject() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_BudgetHeaderTriggers.run = false;

        Integer numOfWeeks = 1, numOfProjectTasks = 5;
        ECO_Utils_Testing.ProjectWrapper myProjWrapper = ECO_Utils_Testing.createProjectWithTasks('A', numOfProjectTasks, numOfWeeks);
        pse__Proj__c proj = myProjWrapper.project;
        proj.DateLastCompletedBudgetQuestionnaire__c = Date.today();

        
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_BudgetHeaderTriggers.run = false;
        
        update proj;

        return proj;
    }

    static pse__Proj__c initProject() {
        
        List<BudgetHeader__c> objBhs = [select id, Name, Project__c, TotalCost__c from BudgetHeader__c limit 1];
        system.debug('objBhs: ' + objBhs);

        BudgetHeader__c objBh = objBhs[0];

        PageReference pageRef = Page.ECO_BudgetHeaderSummary;
        Test.setCurrentPage(pageRef);
        // ApexPages.currentPage().getParameters().put('qp', 'yyyy');

       // ApexPages.StandardController con = new ApexPages.StandardController(objBh);
        // ECO_BudgetLabourEACController ext = new ECO_BudgetLabourEACController(con);  
        
        pse__Proj__c proj = [Select Id, Name From pse__Proj__c where id = :objBh.Project__c];
        return proj;
    }

    static testMethod void testEmptyProject() {
        
        User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
        insert testUser;

        System.runAs(testUser) {

            pse__Proj__c proj = initEmptyProject();
            Test.startTest();
            ECO_ProjectTriggers.run = false;
            ECO_ProjectTaskTriggers.run = false;
            ECO_BudgetHeaderTriggers.run = false;
            system.debug('--Disabled Triggers');
            ECO_BudgetHeaderSummaryController emptyCon = new ECO_BudgetHeaderSummaryController(new ApexPages.StandardController(proj));
            system.debug('--Begin emptyCon.onLoad() ');
            emptyCon.onLoad();
            Test.stopTest();    
        }
        
    }

    static testMethod void testBudgetHeaderSummaryController() {
        /*
        Account account = AccountTestData.createAccounts(1)[0];
        insert account;
        
        pse__Proj__c project = PSEProjectTestData.createProjects(New List<Account>{account}, 1)[0];
        insert project;
        
        List<pse__Project_Task__c> projectTasks = PSEProjectTaskTestData.createProjectTasks(New List<pse__Proj__c>{project}, 5);
        insert projectTasks;
        
        List<BudgetHeader__c> budgetHeaders = BudgetHeaderTestData.createBudgetHeaders(new List<pse__Proj__c>{project}, 4);
        budgetHeaders[1].Status__c = ECO_DTO_BudgetHeader.STATUS_FORECAST;
        budgetHeaders[2].Status__c = ECO_DTO_BudgetHeader.STATUS_WORKATRISK;
        insert budgetHeaders;
        */
        

        User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
		insert testUser;
        
        System.runAs(testUser) {
            Test.startTest();
            ECO_ProjectTaskTriggers.run = false;
            ECO_BudgetHeaderSummaryController controller = new ECO_BudgetHeaderSummaryController(new ApexPages.StandardController(initProject()));
            
            controller.onLoad();
            controller.goToQuestionnaire();

            String testStr = controller.selectedBudgetHeader;
            testStr = controller.selectedAction;
            Decimal BudgetTotalRawLabour = controller.budgetWrapper.getBudgetTotalRawLabour;
            Decimal ForecastTotalRawLabour = controller.budgetWrapper.getForecastTotalRawLabour;
            Decimal WorkAtRiskTotalRawLabour = controller.budgetWrapper.getWorkAtRiskTotalRawLabour;
            Decimal BudgetTotalFBLR = controller.budgetWrapper.getBudgetTotalFBLR;
            Decimal ForecastTotalFBLR = controller.budgetWrapper.getForecastTotalFBLR;
            Decimal WorkAtRiskTotalFBLR = controller.budgetWrapper.getWorkAtRiskTotalFBLR;
            Decimal BudgetTotalFringe = controller.budgetWrapper.getBudgetTotalFringe;
            Decimal ForecastTotalFringe = controller.budgetWrapper.getForecastTotalFringe;
            Decimal WorkAtRiskTotalFringe = controller.budgetWrapper.getWorkAtRiskTotalFringe;
            Decimal BudgetTotalOverhead = controller.budgetWrapper.getBudgetTotalOverhead;
            Decimal ForecastTotalOverhead = controller.budgetWrapper.getForecastTotalOverhead;
            Decimal WorkAtRiskTotalOverhead = controller.budgetWrapper.getWorkAtRiskTotalOverhead;
            Decimal BudgetTotalSubAmount = controller.budgetWrapper.getBudgetTotalSubAmount;
            Decimal ForecastTotalSubAmount = controller.budgetWrapper.getForecastTotalSubAmount;
            Decimal WorkAtRiskTotalSubAmount = controller.budgetWrapper.getWorkAtRiskTotalSubAmount;
            Decimal BudgetTotalFeeAmount = controller.budgetWrapper.getBudgetTotalFeeAmount;
            Decimal ForecastTotalFeeAmount = controller.budgetWrapper.getForecastTotalFeeAmount;
            Decimal WorkAtRiskTotalFeeAmount = controller.budgetWrapper.getWorkAtRiskTotalFeeAmount;
            Decimal BudgetTotalCost = controller.budgetWrapper.getBudgetTotalCost;
            Decimal ForecastTotalCost = controller.budgetWrapper.getForecastTotalCost;
            Decimal WorkAtRiskTotalCost = controller.budgetWrapper.getWorkAtRiskTotalCost;
            Decimal BudgetTotalRevenue = controller.budgetWrapper.getBudgetTotalRevenue;
            Decimal ForecastTotalRevenue = controller.budgetWrapper.getForecastTotalRevenue;
            Decimal WorkAtRiskTotalRevenue = controller.budgetWrapper.getWorkAtRiskTotalRevenue;
            Decimal BudgetTotalNetServiceRevenue = controller.budgetWrapper.getBudgetTotalNetServiceRevenue;
            Decimal ForecastTotalNetServiceRevenue = controller.budgetWrapper.getForecastTotalNetServiceRevenue;
            Decimal WorkAtRiskTotalNetServiceRevenue = controller.budgetWrapper.getWorkAtRiskTotalNetServiceRevenue;
            Decimal BudgetTotalGrossMargin = controller.budgetWrapper.getBudgetTotalGrossMargin;
            Decimal ForecastTotalGrossMargin = controller.budgetWrapper.getForecastTotalGrossMargin;
            Decimal WorkAtRiskTotalGrossMargin = controller.budgetWrapper.getWorkAtRiskTotalGrossMargin;
            Decimal BudgetTotalNetMargin = controller.budgetWrapper.getBudgetTotalNetMargin;
            Decimal ForecastTotalNetMargin = controller.budgetWrapper.getForecastTotalNetMargin;
            Decimal WorkAtRiskTotalNetMargin = controller.budgetWrapper.getWorkAtRiskTotalNetMargin;
            Decimal BudgetTotalGMNSR = controller.budgetWrapper.getBudgetTotalGMNSR;
            Decimal ForecastTotalGMNSR = controller.budgetWrapper.getForecastTotalGMNSR;
            Decimal WorkAtRiskTotalGMNSR = controller.budgetWrapper.getWorkAtRiskTotalGMNSR;
            Decimal BudgetTotalNMNSR = controller.budgetWrapper.getBudgetTotalNMNSR;
            Decimal ForecastTotalNMNSR = controller.budgetWrapper.getForecastTotalNMNSR;
            Decimal WorkAtRiskTotalNMNSR = controller.budgetWrapper.getWorkAtRiskTotalNMNSR;
            
            Id bhId = controller.budgetWrapper.dtoBudgetHeaders[0].oBudgetHeader.Id;
            String budgetName = controller.budgetWrapper.dtoBudgetHeaders[0].budgetName;
            DateTime createdDate = controller.budgetWrapper.dtoBudgetHeaders[0].CreatedDate;
            String Status = controller.budgetWrapper.dtoBudgetHeaders[0].status;
            Decimal dTotalCost = controller.budgetWrapper.dtoBudgetHeaders[0].dTotalCost;
            Decimal dTotalRevenue = controller.budgetWrapper.dtoBudgetHeaders[0].dTotalRevenue;
            Decimal dTotalApprovedCost = controller.budgetWrapper.dtoBudgetHeaders[0].dTotalApprovedCost;
            Decimal dTotalApprovedRevenue = controller.budgetWrapper.dtoBudgetHeaders[0].dTotalApprovedRevenue;
            Decimal dTotalForecastCost = controller.budgetWrapper.dtoBudgetHeaders[0].dTotalForecastCost;
            Decimal dTotalForecastRevenue = controller.budgetWrapper.dtoBudgetHeaders[0].dTotalForecastRevenue;
            Decimal dTotalWorkAtRiskCost = controller.budgetWrapper.dtoBudgetHeaders[0].dTotalWorkAtRiskCost;
			Decimal dTotalWorkAtRiskRevenue = controller.budgetWrapper.dtoBudgetHeaders[0].dTotalWorkAtRiskRevenue;

            String strSelectedAction = controller.budgetWrapper.dtoBudgetHeaders[0].strSelectedAction;

            Decimal testVal = controller.budgetWrapper.dtoBudgetHeaders[0].directPersonnelExpenses;
            testVal = controller.budgetWrapper.dtoBudgetHeaders[0].salaryCostMultiplier;
            testVal = controller.budgetWrapper.dtoBudgetHeaders[0].averageLabourRatePerHour;
            String approvalStatus = controller.budgetWrapper.dtoBudgetHeaders[0].approvalStatus;

            controller.onArchiveLoad();
            
            for (ECO_DTO_BudgetHeader budgetHeader : controller.budgetWrapper.dtoBudgetHeaders) {
                List<SelectOption> lstActions = budgetHeader.lstActions;
            }

            Apexpages.currentPage().getParameters().put('budgetHeaderId', bhId);

            
            try {
                Apexpages.currentPage().getParameters().put('actionSelected', 'SubmitInternalChange');
                controller.onAction();
            } catch (Exception ex) {
                System.debug('--ERR SubmitInternalChange: ' + ex.getMessage());
            }

            try {
                Apexpages.currentPage().getParameters().put('actionSelected', 'SubmitExternalChange');
                controller.onAction();
            } catch (Exception ex) {
                System.debug('--ERR SubmitExternalChange: ' + ex.getMessage());
            }

            try {
                Apexpages.currentPage().getParameters().put('actionSelected', 'ViewInternalChange');
                controller.onAction();
            } catch (Exception ex) {
                System.debug('--ERR ViewInternalChange: ' + ex.getMessage());
            }

            try {
                Apexpages.currentPage().getParameters().put('actionSelected', 'ViewExternalChange');
                controller.onAction();
            } catch (Exception ex) {
                System.debug('--ERR ViewExternalChange: ' + ex.getMessage());
            }

            try {
                Apexpages.currentPage().getParameters().put('actionSelected', 'ArchiveBudget');
                controller.onAction();
            } catch (Exception ex) {
                System.debug('--ERR ArchiveBudget: ' + ex.getMessage());
            }

            try {
                Apexpages.currentPage().getParameters().put('actionSelected', 'UnArchiveBudget');
                controller.onAction();
            } catch (Exception ex) {
                System.debug('--ERR UnArchiveBudget: ' + ex.getMessage());
            }
            Test.stopTest();
        }
    }
}