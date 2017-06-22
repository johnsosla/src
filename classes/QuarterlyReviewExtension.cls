public class QuarterlyReviewExtension{
    public Qtr_Review__c qtrReview {get;set;}
    private ID planId;
    String retUrl = ApexPages.currentPage().getParameters().get('retURL');
    
    /**
    *
    */
    public QuarterlyReviewExtension (ApexPages.StandardController ctl) {
        this.qtrReview = (Qtr_Review__c)ctl.getRecord();   
        planId = qtrReview.AcctPlan__c;
    }
    
    /**
    *
    */
    private List<Goals_Results__c> financialTargets {
        get {
            if (financialTargets == null) {
                financialTargets = [SELECT ID
                                    , Geography__c 
                                    , GM_Target__c
                                    , Bookings_Target__c
                                    , Gross_Revenue_Goal__c
                                    , Net_Revenue_Goal__c
                                    , (SELECT ID FROM Quarterly_Financials__r WHERE Quarterly_Review__c = :qtrReview.ID)
                                    FROM Goals_Results__c 
                                    WHERE Click_to_return__c = :planId]; //Click_to_return__c is the Account plan               
            }
            return financialTargets;
        }
        set;
    }
    
    /**
    *
    */
    public List<Quarterly_Financials__c> quarterFinancials {
        get {
            if (quarterFinancials == null) {
                quarterFinancials = new List<Quarterly_Financials__c>();
                
                Map<ID, Quarterly_Financials__c> qFinMap = new Map<ID, Quarterly_Financials__c>([SELECT ID
                                                                                                     , Financial_Target__c
                                                                                                     , Quarterly_Review__c
                                                                                                     , Geography__c
                                                                                                     , YTD_Bookings__c 
                                                                                                     , YTD_GM__c
                                                                                                     , YTD_Gross_Revenue__c
                                                                                                     , YTD_Net_Revenue__c
                                                                                                     FROM Quarterly_Financials__c 
                                                                                                     WHERE Quarterly_Review__c = :qtrReview.ID]);
                for (Goals_Results__c finTarget : financialTargets) {
                   if (!finTarget.Quarterly_Financials__r.isEmpty()) {
                       Quarterly_Financials__c matched = qFinMap.get(finTarget.Quarterly_Financials__r[0].ID);
                       if (matched != null) {
                           matched.Financial_Target__r = finTarget;
                           quarterFinancials.add(matched);
                       }
                   } else {
                       Quarterly_Financials__c newQtr = new Quarterly_Financials__c(Geography__c = finTarget.Geography__c);
                       newQtr.Quarterly_Review__c = qtrReview.ID;
                       newQtr.Financial_Target__c = finTarget.ID;
                       newQtr.Financial_Target__r = finTarget;
                       quarterFinancials.add(newQtr);
                   }
                }
                
            }
            return quarterFinancials;
        }
        set;
    }
    
    /**
    *
    */
    public PageReference saveFinancials() {
        try {
            upsert qtrReview;
            
            upsert quarterFinancials;
        } catch (Exception e) {
            return null;
        }
        
        String nextPage = retURL != null ? retURL : '/' + qtrReview.ID;
        PageReference ref = new PageReference(nextPage);
        ref.setRedirect(true);
        return ref;
    }
    
    
}