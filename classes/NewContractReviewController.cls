public with sharing class NewContractReviewController {

  ApexPages.StandardController ctr;
    private Contract_Review__c contractReview;
    public Boolean metroAreaVisibility {get; private set;}

    public NewContractReviewController(ApexPages.StandardController controller)
    {
      
      ctr = controller;
        metroAreaVisibility  = false;
        // Add the agreement to the form request. If an agreement is added then the trigger 
        // for a new contract review request will gather its details from ECO_ContractReviewDTO 
        Id agreementId = ApexPages.currentPage().getParameters().get('AgreementId');
        contractReview = (Contract_Review__c) controller.getRecord();
        if (agreementId != null)
        {
            
            contractReview.Agreement__c = agreementId;
        }
    }
    
    
    public PageReference SetMetroAreaVisibility()
    {
        // && CR_Record.State_Province_Emirate__r.State_Code__c == 'CA'
        List<Country__c> cList = [select id, country_code__c from Country__c where id = :contractReview.Country__c AND country_code__c='US'];
        List<State_Province_Emirate__c> sList = [select id, State_Code__c from State_Province_Emirate__c where id = :contractReview.State_Province_Emirate__c and State_Code__c='CA'];
        
        if(cList.size() > 0 && sList.size() > 0)
        {
            metroAreaVisibility = true;
        } else {
            metroAreaVisibility  = false;
        }
        return null;
    }
    
    public Pagereference Next()
    {
      try
      {
       if(ctr.save() != null) {
         
          //return new PageReference('/' + ctr.getId() + '/e?retURL=%2F' + ctr.getId() );
                return new PageReference('/apex/ContractReview_Edit?id=' + ctr.getId() + '&retURL=%2F' + ctr.getId() + '&sfdc.override=1'  );
                //PageReference edit =  new PageReference( '/apex/ContractReview_Edit?id=a1se0000001iXSc');
                //return edit;
       }
       return null;
      }
      catch(Exception ex)
      {
        return null;   
      }
    }

}