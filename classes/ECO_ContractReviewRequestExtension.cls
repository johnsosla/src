public with sharing class ECO_ContractReviewRequestExtension {
	public Contract_Review__c contractReview {get; set;}
    public DOAApprovalRequest__c doaApprovalRequest {get;set;}
    
    public List<Contract_Review__c> lstContractReview {get; set;}
    public List<Agreement__c> lstAgreement {get;set;}
    public List<aTableRow> tableRows { get; set; }
    
    public Id projectId {get;set;}
    public Id doaID {get;set;}
    public Integer count {get;set;}
    
    public ECO_ContractReviewRequestExtension(ApexPages.StandardController standardcontroller) {
        doaApprovalRequest = (DOAApprovalRequest__c)standardController.getRecord();
        doaID = doaApprovalRequest.Id;
        System.debug('doaApprovalRequest.Id:    '+doaApprovalRequest.Id); 
        doaApprovalRequest = [Select Id, Project__c From DOAApprovalRequest__c Where Id = :doaID];
        projectId = doaApprovalRequest.Project__c;
        contractReview = new Contract_Review__c();
        tableRows =  new List<aTableRow>();
        loadContractReview();
        

    }
    
    public class aTableRow {
        public Id sContractId {get;set;}
        public String sContractReviewName {get;set;}
        public String sAgreement {get;set;}
        public String sAgreementStatus {get;set;}
        public String sAgreementType {get; set;}
        public Agreement__c objAgreement {get;set;}
        public Contract_Review__c objContractReview {get;set;}
        
        public aTableRow(Contract_Review__c oContractReview, Agreement__c oAgreement){
            objAgreement = new Agreement__c();
            objContractReview = new Contract_Review__c();
            
            objContractReview = oContractReview;
            objAgreement = oAgreement;
            
            /*sContractId = contractId;
            sContractReviewName = contractName;
            sAgreement = contractAgreement;
            sAgreementStatus = agreementStatus;
            sAgreementType = agreementType;*/
            
        }
	}
    
    public void loadContractReview(){
        count = 0;
        lstAgreement = new List<Agreement__c>([Select Id, Name, AgreementType__c, AgreementStatus__c From Agreement__c where Project__c = :projectId]);
        lstContractReview =  new List<Contract_Review__c>([Select Id, Agreement__c, Name From Contract_Review__c Where Agreement__c IN :lstAgreement]);
        System.debug('lstContractReview   size:  '+lstContractReview.size());
        System.debug('lstAgreement size:   '+lstAgreement.size());
        //tableRows.add(new aTableRow(oContractReview.Id));
        for(Agreement__c oAgreement : lstAgreement){
            for(Contract_Review__c oContractReview : lstContractReview){
                if(oContractReview.Agreement__c == oAgreement.Id){
                    tableRows.add(new aTableRow(oContractReview, oAgreement));
                    count++;
                    System.debug('Inside for '+count+'   time');
                }
                
            }
        }
        System.debug('tableRows.size:    '+tableRows.size());
        
    }
    
    
}