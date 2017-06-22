global with sharing class ECO_PMD_AccountsReceivable_Controller {

    public string locale { get {return UserInfo.getLocale().replace('_', '-');} }

    private final pse__Proj__c project;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ECO_PMD_AccountsReceivable_Controller(ApexPages.StandardController stdController) {
        //stdController.addFields(new List<string>{'OracleProjectNumber__c', 'Name'});
        this.project = (pse__Proj__c)stdController.getRecord();
    }

    @RemoteAction @ReadOnly
    public static List<Billing> GetBillingData(String projectId) {
        List<Billing__c> billingData = [select id, name
            , RAInvoiceNumber__c
            , DraftInvoiceNumber__c
            , InvoiceComments__c
            , Billing_InvoiceImageFileURL__c
            , CustomerNumber__c
            , CustomerName__c
            , InvoiceDate__c
            , BillThroughDate__c
            , InvoiceCurrency__c
            , CurrencyIsoCode
            , TaxAmountNumber__c
            , InvoiceAmountNumber__c
            , RetentionAmountNumber__c
            , BalanceDueNumber__c
            , AccountedTaxAmount__c
            , ProjectFunctionalInvoiceAmount__c
            , AccountedBalanceDue__c
            , ProjectFunctionalRetentionAmount__c
            , PreTaxInvoiceAmountNumber__c
            , ProjectFunctionalPreTaxInvoiceAmoun__c
            , AR0to30__c
            , AR31to60__c
            , AR61to90__c
            , AR91to180__c
            , AR181Plus__c

            from Billing__c
            where ProjectNumber__c = :projectId
            order by RAInvoiceNumber__c DESC];

        List<Billing> billings = new List<Billing>();
        for(Billing__c item : billingData) {
            Billing billing = new Billing();

            billing.DraftInvoiceNumber = item.DraftInvoiceNumber__c;
            billing.ARInvoiceNumber = item.RAInvoiceNumber__c;
            billing.InvoiceComments = item.InvoiceComments__c;
            billing.InvoiceImageLink = item.Billing_InvoiceImageFileURL__c;
            billing.InvoiceDate = item.InvoiceDate__c;
            billing.BillThroughDate = item.BillThroughDate__c;

            billing.CustomerNumber = item.CustomerNumber__c;
            billing.CustomerName = item.CustomerName__c;

            billing.InvoiceCurrency = item.InvoiceCurrency__c;
            billing.IC_PreTaxInvoiceAmount = item.PreTaxInvoiceAmountNumber__c;
            billing.IC_TaxAmount = item.TaxAmountNumber__c;
            billing.IC_InvoiceAmount = item.InvoiceAmountNumber__c;
            billing.IC_RetentionAmount = item.RetentionAmountNumber__c;
            billing.IC_BalanceDue = item.BalanceDueNumber__c;
            
            billing.FunctionalCurrency = item.CurrencyIsoCode;
            billing.ProjectFunctionalPreTaxInvoiceAmount = item.ProjectFunctionalPreTaxInvoiceAmoun__c;
            billing.AccountedTaxAmount = item.AccountedTaxAmount__c;
            billing.ProjectFunctionalInvoiceAmount = item.ProjectFunctionalInvoiceAmount__c;
            billing.ProjectFunctionalRetentionAmount = item.ProjectFunctionalRetentionAmount__c;
            billing.AccountedBalanceDue = item.AccountedBalanceDue__c;

            billing.AR0to30 = item.AR0to30__c;
            billing.AR31to60 = item.AR31to60__c;
            billing.AR61to90 = item.AR61to90__c;
            billing.AR91to180 = item.AR91to180__c;
            billing.AR181Plus = item.AR181Plus__c;

            billings.add(billing);
        }

        return billings;
    }

    global class Billing {
        
        public string DraftInvoiceNumber {get; set;}
        public string ARInvoiceNumber {get;set;}
        public string InvoiceComments {get;set;}
        public string InvoiceImageLink {get;set;}
        public date InvoiceDate {get; set;}
        public date BillThroughDate {get; set;}
       
        public string CustomerNumber {get; set;}
        public string CustomerName {get; set;}

        public string InvoiceCurrency {get;set;}
        public decimal IC_PreTaxInvoiceAmount {get; set;}
        public decimal IC_TaxAmount {get; set;}
        public decimal IC_InvoiceAmount {get; set;}
        public decimal IC_RetentionAmount {get; set;}
        public decimal IC_BalanceDue {get; set;}
       
        public string FunctionalCurrency {get; set;}
        public decimal ProjectFunctionalPreTaxInvoiceAmount {get; set;}
        public decimal AccountedTaxAmount {get; set;}
        public decimal ProjectFunctionalInvoiceAmount {get; set;}
        public decimal ProjectFunctionalRetentionAmount {get; set;}
        public decimal AccountedBalanceDue {get; set;}

        public decimal AR0to30 {get; set;}
        public decimal AR31to60 {get; set;}
        public decimal AR61to90 {get; set;}
        public decimal AR91to180 {get; set;}
        public decimal AR181Plus {get; set;}

       }
}