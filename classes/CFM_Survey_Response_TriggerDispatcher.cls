public with sharing class CFM_Survey_Response_TriggerDispatcher 
{
    public static Set<String> executedMethods = new Set<String>();
    
    public static void Main(List<CFM_Survey_Response__c> newList, Map<Id, CFM_Survey_Response__c> newMap, List<CFM_Survey_Response__c> oldList, Map<Id, CFM_Survey_Response__c> oldMap, Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isExecuting)
    {

        if(isBefore && isInsert)
        {
    		CFM_Survey_Response_TriggerHandler.checkForMergedAccountsAndFix(newList);
            CFM_Survey_Response_TriggerHandler.updateSurveyResponseWithRelatedFFProject(newList);
        }

        
        if(isAfter && isInsert)
        {
            CFM_Survey_Response_TriggerHandler.emailInitialNotifications(newList);
            try {
                CFM_SurveyCase.handleSurveyResponseInsert(newList, newMap); 
            }
            catch (Exception e) {
                System.debug('Caught error while inserting survey response: ' + e);
            }
        }
    }
}