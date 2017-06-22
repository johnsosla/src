public with sharing class ContractReviewGNGDetailsController {


    public Go_No_Go_Conversation__c gngPrivate;

    public Go_No_Go_Conversation__c GNG{
        get{return gngPrivate;}
        private set;
    }

    public ContractReviewGNGDetailsController(ApexPages.StandardController controller)
    {
            
         Contract_Review__c cr = (Contract_Review__c)controller.getRecord();
        
        
         Contract_Review__c cr1 = [select id, Opportunity_GNG__c from Contract_Review__c where id = :cr.id];
        
        
        if (cr1.Opportunity_GNG__c == null)
        {
            gngPrivate = new Go_No_Go_Conversation__c();            
        }   
        else
        {      
             gngPrivate = [SELECT 
                Opportunity_Record__c
                ,Opportunity_Name__c
                ,Opportunity_Lead_Region__c
                ,Primary_Department_from_Opportunity__c
                ,ANZ_Approver__c 
                ,Approver__c
                ,Decision_Date__c
                ,Program_Ceiling__c
                ,Net_Revenue_from_Opp__c
                ,Probabilities_from_Opportunitiy__c
                ,Est_Pursuit_Costs__c
                ,Client_Name__r.Type
                ,AECOM_Work_from_Opp__c
                ,Project_Location__c
                ,Proposal_Due_Date__c
                from Go_No_Go_Conversation__c where id = :cr1.Opportunity_GNG__c];
         }                

        
      }
    

}