global with sharing class ECO_PMD_Commitment_Controller {

    private final pse__Proj__c oProject ;

    public string locale { get {return UserInfo.getLocale().replace('_', '-');} }
    
    //public ECO_PMD_ProjectWrapper wrapper { get; set; }
    
    public ECO_PMD_Commitment_Controller (ApexPages.StandardController oStandardController) {
          this.oProject = (pse__Proj__c)oStandardController.getRecord();
          //this.wrapper = new ECO_PMD_ProjectWrapper(this.oProject);
    }

        @RemoteAction
    global static List<Commitment> ProjectScheduleTasks(String projectNum)
    {
        Id projectId = projectNum;
        List<POcommitment__c>  commitments;
        try
        {
           //note  POLineAmount__c, POAmountBilled__c added just too have some $ values, these are not official 
            commitments = [SELECT id, name
            , ProjectTaskNumber__r.ProjectTaskNumber__c
            , ProjectTaskNumber__r.Name
            , POHeader__r.VendorSite__r.name
            , POHeader__r.VendorName__c
            , SupplierNumber__c
            , SupplierName__c
            , POLine__c
            , PONumber__c
            , ExpenditureType__c
            , CurrencyIsoCode
            , POCurrency__c
            , POExchangeRate__c
            , FunctionalCurrency__c
            , POLineAmount__c
            , POAmountBilled__c 
            FROM POcommitment__c
            WHERE ProjectNumber__c = :projectId
            ORDER BY PONumber__c ASC, POLine__c ASC];
        }
        catch (Exception ex){
            // HMMM
        }

        system.debug(commitments);

        List<Commitment> result = new List<Commitment>();
        for(POcommitment__c poc : commitments) {
          Commitment item = new Commitment();
          item.ProjectTaskNumber = poc.ProjectTaskNumber__r.ProjectTaskNumber__c;
          item.ProjectTaskName = poc.ProjectTaskNumber__r.Name;
          item.VendorSite = poc.POHeader__r.VendorSite__r.name;
          item.VendorName = poc.POHeader__r.VendorName__c;
          item.SupplierNumber = poc.SupplierNumber__c;
          item.SupplierName = poc.SupplierName__c;
          item.POLine = poc.POLine__c;
          item.PONumber = poc.PONumber__c;
          item.ExpenditureType = poc.ExpenditureType__c;
          item.CurrencyIsoCode = poc.CurrencyIsoCode;
          item.POCurrency = poc.POCurrency__c;
          item.FunctionalCurrency = poc.FunctionalCurrency__c;
          item.POExchangeRate = poc.POExchangeRate__c;
          item.POLineAmount = poc.POLineAmount__c;
          item.POAmountBilled = poc.POAmountBilled__c;
          result.add(item);
        }
        return result;
    }

    global class Commitment {
        public string ProjectTaskNumber {get; set;}
        public string ProjectTaskName {get;set;}
        public string VendorSite {get;set;}
        public string VendorName {get;set;}
        public string SupplierNumber {get;set;}
        public string SupplierName {get;set;}
        public string POLine {get; set;}
        public string PONumber {get; set;}
        public string ExpenditureType {get; set;}
        public string CurrencyIsoCode {get; set;}
        public string POCurrency {get;set;}
        public string FunctionalCurrency {get; set;}
        public decimal POExchangeRate {get; set;}
        public decimal POLineAmount {get; set;}
        public decimal POAmountBilled {get; set;}
    }
}