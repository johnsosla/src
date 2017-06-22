public class QuarterlyFinancialExtension{
    public Quarterly_Financials__c qtrFin {get;set;}
    String retUrl = ApexPages.currentPage().getParameters().get('retURL');
    /**
	*
	*/
    public QuarterlyFinancialExtension (ApexPages.StandardController ctl) {
        this.qtrFin = (Quarterly_Financials__c)ctl.getRecord();   
    }
    
    public PageReference redir() {
        PageReference ref = Page.QuarterReviewEdit;
        ref.getParameters().put('id',qtrFin.Quarterly_Review__c);
        ref.getParameters().put('retURL',retURL);
        ref.setRedirect(true);
        return ref;
    }
}