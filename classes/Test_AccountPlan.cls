@isTest
private class Test_AccountPlan {

    	@isTest
        static void testAccountPlan() {
           	Account acc = new Account(Name='Test Account Plan');
            insert acc;
            SFDC_Acct_Plan__c accPlan = new SFDC_Acct_Plan__c(Account__c = acc.ID);
            accPlan.Planning_Year__c = 'FY2014';
            accPlan.Plan_Status__c = 'Draft';
            insert accPlan;
            
            Goals_Results__c fin = new Goals_Results__c(Click_to_return__c = accPlan.ID);
            fin.Geography__c = 'Global';
            fin.Bookings_Target__c = 100;
            fin.Net_Revenue_Goal__c = 200;
            fin.Gross_Revenue_Goal__c = 300;
            fin.GM_Target__c = 10;
            insert fin;
            
            Qtr_Review__c qtrReview = new Qtr_Review__c(AcctPlan__c = accPlan.ID);
            qtrReview.Review_Period__c = 'FY14 - Q1';
            qtrReview.Review_Date__c = System.today();
            insert qtrReview;
            
            ApexPages.StandardController ctl = new ApexPages.StandardController(qtrReview);
            QuarterlyReviewExtension ext = new QuarterlyReviewExtension(ctl);
            List<Quarterly_Financials__c> financials = ext.quarterFinancials;
            System.assertEquals(1, financials.size());
            Quarterly_Financials__c qtrFin = financials[0];
            qtrFin.YTD_Bookings__c = 10;
            qtrFin.YTD_Gross_Revenue__c = 30;
            qtrFin.YTD_Net_Revenue__c = 20;
            qtrFin.YTD_GM__c = 2;
            
            PageReference ref = ext.saveFinancials();
            System.assertEquals('/' + qtrReview.ID , ref.getUrl());
            
            ctl = new ApexPages.StandardController(qtrReview);
            ext = new QuarterlyReviewExtension(ctl);
            financials = ext.quarterFinancials;
            System.assertEquals(1, financials.size());
			
            qtrFin = financials[0];
            ApexPages.StandardController ctl2 = new ApexPages.StandardController(qtrFin);
            QuarterlyFinancialExtension ext2 = new QuarterlyFinancialExtension(ctl2);
            ext2.redir();
            
            
        }
}