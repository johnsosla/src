public with sharing class ECO_DOA_ApprovalRequestRecordCtrl {
  public String DOARecordType {get;set;}
    public List <RecordType> lstRecordtypes {get;set;}
    public String selectedRecordType {get; set;}
    public DOAApprovalRequest__c newDOA {get;set;}
    public ECO_DOA_ApprovalRequestRecordCtrl(ApexPages.StandardController controller) {
    newDOA = new DOAApprovalRequest__c();
        lstRecordtypes = new List <RecordType>();
        lstRecordtypes = [Select Id, Name, DeveloperName, Description 
                          From RecordType 
                          WHERE SobjectType = 'DOAApprovalRequest__c'
                           AND DeveloperName IN ('DOACreate', 'NonProject', 'NonEcosystemCreate')];
    }
    
  /*public List<selectOption> getDOARecType(){
        List<selectOption> lstDOARecordType = new List<selectOption>();
        
        for(RecordType rt : lstRecordtypes){
            lstDOARecordType.add(new SelectOption(rt.Name, rt.Name));
        }
         
        return lstDOARecordType;
  }*/
    
    public list<RecordType> getDoaApprovalRecordTypes()
  {
    lstRecordtypes = [Select Id, Name, DeveloperName, Description 
                          From RecordType 
                          WHERE SobjectType = 'DOAApprovalRequest__c'
                           AND DeveloperName IN ('DOACreate', 'NonProject', 'NonEcosystemCreate')];
        return lstRecordtypes;
  }
    
    public PageReference redirect(){
        PageReference pgRef;
        //RecordType recordType = [select Id, DeveloperName, Name from RecordType where DeveloperName = 'NonEcosystemCreate'];
        
        try{
            /*newDOA.RecordTypeId = recordType.Id;
            System.debug('newDOA.RecordTypeId:   '+newDOA.RecordTypeId);
            Insert newDOA;*/
            pgRef = new pagereference('/apex/ECO_DOA_ApprovalRequestCreation?questionOne=No');
            return pgRef;
        }catch (Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to add a DOA Approval Request. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
    }
    public PageReference recordTypeSelected()
  {
        PageReference pgRef;
        RecordType recordType = [select Id, DeveloperName, Name from RecordType where Id = :selectedRecordType];
        try{
            if(recordType.DeveloperName == 'NonEcosystemCreate'){
            //pgRef = new pagereference('/apex/ECO_DOA_ApprovalRequest');
            newDOA.RecordTypeId = recordType.Id;
            Insert newDOA;
          pgRef = new pagereference('/apex/ECO_DOA_ApprovalRequestCreation');
            }
            else{
                newDOA.RecordTypeId = recordType.Id;
                Insert newDOA;
                pgRef = new pagereference('/'+newDOA.Id+'/e?retURL=%2F'+newDOA.Id);
            }    
            return pgRef;
        }catch (Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to add a DOA Trigger. Please contact your administrator with the following error: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
        
   }
}