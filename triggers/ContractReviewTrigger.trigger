/*******************************************************************
  Name        :   ContractReviewTrigger
  Requester   :   CRS Requirments
  Author      :   AECOM - Luke Farbotko
  Version     :   1.0 
  Purpose     :   1. Update the CR opp with the GNGs opp so that there is a direct 
            referance.
            2. Ensure that teh creater, PM and PD have access to the 
            record via manual sharing as we have private sharing 
            on the object 
  Date        :   12 Feb, 2015 
  Modifications
  Steve MunLeeuw Jan 25, 2016 - Description Nature of Works to rich text field.
  Richard Cook April 4 2016 - Added new section to handle timestamps

********************************************************************/
trigger ContractReviewTrigger on Contract_Review__c (before insert, before update, after update, after insert) {

     


     Map<Id, Go_No_Go_Conversation__c> gngMap = new Map<Id, Go_No_Go_Conversation__c>();                   
     List<Id> listIds = new List<Id>();

     //get list of gngs
  for (Contract_Review__c cr: Trigger.new){          
      
      if(cr.Opportunity_GNG__c != null){
        listIds.add(cr.Opportunity_GNG__c);
        }
     
   }
      
    gngMap = new Map<Id, Go_No_Go_Conversation__c>([SELECT id, Opportunity__c
                          , Opportunity__r.Name
                          , Opportunity__r.AccountId
                          , Opportunity__r.Account.Name
                          , Opportunity__r.Account.CountryLookup__c
                          , Opportunity__r.Project__c
                          , Opportunity__r.Description
                          , Opportunity__r.Amount
                          , Opportunity__r.AECOM_Primary_Dept_Lookup__r.Business_Line_Lookup__c
                          , Opportunity__r.CurrencyIsoCode 
                          , Opportunity__r.Capture_Manager_User__c
                          , Project_Director__c
                          FROM Go_No_Go_Conversation__c  
                         where Id IN :listIds   ]);
       
                
     for(Contract_Review__c cr: Trigger.new){
        

        if(Trigger.isBefore && Trigger.isUpdate)
        {

            // set date fields
            Contract_Review__c oldValue = Trigger.oldMap.get(cr.Id);
            if(ContractReviewHelper.OwnerChange(cr, oldValue))
            {
                cr.Time_Owner_changed__c = System.now();
            }
            ContractReviewHelper.SetStatusChangeFields(cr, oldValue);
        }               
       
       if (Trigger.isBefore) {
       
         Go_No_Go_Conversation__c gng = gngMap.get(cr.Opportunity_GNG__c);
           

           if(Trigger.isInsert && cr.Agreement__c != null)
           {
             list<ECO_ContractReviewDTO > contractReviewDTOs = ECO_Service_ContractReview.getContractReivewDTOs(cr.Agreement__c);

             system.debug('xxlfxx' + contractReviewDTOs);

             if (contractReviewDTOs.size()> 0)
             {
               system.debug('xxlfxx' + contractReviewDTOs[0]);
               if (contractReviewDTOs[0].OpportunityIds.size()> 0)
               {
                 cr.Opportunity__c = contractReviewDTOs[0].OpportunityIds[0];
               }
               try{cr.Business_Line__c = contractReviewDTOs[0].BusinessLine;}catch(Exception ex){}
               
               cr.Client_Vendor__c = contractReviewDTOs[0].ClientVendorId;             
               cr.Project__c = contractReviewDTOs[0].ProjectId;
               cr.Description_Nature_of_Works_1__c = contractReviewDTOs[0].ScopeOfServices;
               cr.Estimated_Fee__c = contractReviewDTOs[0].EstimatedFee;
               cr.CurrencyIsoCode = contractReviewDTOs[0].AgreementCurrency;
               cr.Request_Name__c = contractReviewDTOs[0].ProjectName;
               cr.Project_Director__c = contractReviewDTOs[0].ProjectDirectorId;
               cr.Project_Manager__c = contractReviewDTOs[0].ProjectManagerId;
               cr.Contract_Type__c = contractReviewDTOs[0].ContractType;
               cr.PI_Insurance_Amount__c = contractReviewDTOs[0].ProfessionalIndemnity;
               cr.PL_Insurance_Amount__c = contractReviewDTOs[0].PublicIndemnity;
               cr.Federal_Contract__c = contractReviewDTOs[0].FederealContract;
               cr.Client_vendor_as_named_on_the_contract__c = contractReviewDTOs[0].ClientVendorName;
             }
             
           }
           else if(Trigger.isInsert && gng != null)
           {
             cr.Client_Vendor__c =  gng.Opportunity__r.AccountId;
             cr.Client_vendor_as_named_on_the_contract__c =  gng.Opportunity__r.Account.Name;
             cr.Country_of_incorporation_of_the_client_v__c = gng.Opportunity__r.Account.CountryLookup__c;
             cr.Business_Line__c = gng.Opportunity__r.AECOM_Primary_Dept_Lookup__r.Business_Line_Lookup__c;
             cr.Project__c = gng.Opportunity__r.Project__c;
             cr.Description_Nature_of_Works_1__c = gng.Opportunity__r.Description;
             cr.Estimated_Fee__c = gng.Opportunity__r.Amount;
             cr.CurrencyIsoCode = gng.Opportunity__r.CurrencyIsoCode;
             cr.Request_Name__c = gng.Opportunity__r.Name;
             cr.Project_Director__c = gng.Project_Director__c;
             cr.Project_Manager__c = gng.Opportunity__r.Capture_Manager_User__c;
           }
          
           if(gng != null){
             cr.Opportunity__c = gng.Opportunity__c;
           }
           else{
             cr.Opportunity__c = null;
           }
       }
         if (Trigger.isAfter) {
           ContractReviewSharing.manualShareRead(cr.Id, cr.CreatedById, 'Edit');
           ContractReviewSharing.manualShareRead(cr.Id, cr.Project_Manager__c, 'Edit');
           ContractReviewSharing.manualShareRead(cr.Id, cr.Project_Director__c, 'Edit');
           ContractReviewSharing.manualShareRead(cr.Id, cr.Other_project_member__c, 'Edit');
           ContractReviewSharing.manualShareRead(cr.Id, cr.Second_Legal_User__c, 'Edit');
         }
         
     }
     

}