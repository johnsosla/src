public with sharing class ECO_DOA_FormRedirectController {

  public Form__c oForm {get;set;}

  public ECO_DOA_FormRedirectController(ApexPages.StandardController stdController) {
    this.oForm = (Form__c)stdController.getRecord();
    
  }

  public pagereference redirectForm(){
    Integer count = 0;
    //list<RecordType> lstRT = [select id from recordtype where sObjectType='Form__c' and (developername='RFA' OR developername='ORMMemo')];
    list<RecordType> lstRT = [select id from recordtype where sObjectType='Form__c' and developername='RFA' ];
        for(Recordtype rt : lstRT){
            if(oForm.recordtypeid == rt.Id)
                count++;
        }
    /*if(oForm.recordtypeid == lstRT[0].id){
            System.debug('inside if');
      return new pagereference('/apex/ECO_RFA?id=' + oForm.id);
    } else {
            System.debug('inside else');
      return new pagereference('/' + oForm.id + '?nooverride=1');
    }*/
        if(count>0){
            System.debug('inside if');
      return new pagereference('/apex/ECO_RFA?id=' + oForm.id);
    } else {
            System.debug('inside else');
      return new pagereference('/' + oForm.id + '?nooverride=1');
    }
        
  }

  public pagereference redirectFormEdit(){
    Integer count = 0;
    //list<RecordType> lstRT = [select id from recordtype where sObjectType='Form__c' and (developername='RFA' OR developername='ORMMemo')];
    list<RecordType> lstRT = [select id from recordtype where sObjectType='Form__c' and developername='RFA' ];
    for(Recordtype rt : lstRT){
            if(oForm.recordtypeid == rt.Id)
                count++;
        }
    /*if(oForm.recordtypeid == lstRT[0].id){
            System.debug('inside if');
      return new pagereference('/apex/ECO_RFA?id=' + oForm.id);
    } else {
            System.debug('inside else');
      return new pagereference('/' + oForm.id + '/e?retURL=/' + oForm.DOAApprovalRequest__c + '&nooverride=1');
    }*/
        if(count > 0){
            System.debug('inside if');
      return new pagereference('/apex/ECO_RFA?id=' + oForm.id);
    } else {
            System.debug('inside else');
      return new pagereference('/' + oForm.id + '/e?retURL=/' + oForm.DOAApprovalRequest__c + '&nooverride=1');
    }
        
  }

}