public with sharing class ECO_pse_Project_TriggerDispatcher 
{
    public static Set<String> executedMethods = new Set<String>();
    
    public static void Main(List<pse__Proj__c> newList, Map<Id, pse__Proj__c> newMap, List<pse__Proj__c> oldList, Map<Id, pse__Proj__c> oldMap, Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isExecuting)
    {
        Boolean EvaluateHealthyStart_Enabled = ECO_TriggerSettings.getIsTriggerEnabled('EvaluateHealthyStart');
        

        if(isBefore && (isUpdate || isInsert)){

            set<id> sContactIds = new set<id>();
            list<pse__Proj__c> lstProjectsToUpdate = new list<pse__Proj__c>();
            map<id, id> contactToUser = new map<id, id>();


            for(pse__Proj__c p: newList){

                if(isInsert || (isUpdate && p.ProjectApprover__c != oldMap.get(p.id).ProjectApprover__c)){
                    if(p.ProjectApprover__c != null){
                        sContactIds.add(p.ProjectApprover__c);
                        lstProjectsToUpdate.add(p);
                    }
                }

                
                if(isInsert || (isUpdate && p.CaptureManager__c != oldMap.get(p.id).CaptureManager__c)){
                    if(p.CaptureManager__c != null){
                        sContactIds.add(p.CaptureManager__c);
                        lstProjectsToUpdate.add(p);
                    }
                }
                

            }

            if(sContactIds.size() > 0){
                list<contact> lstContact = [select id, pse__Salesforce_User__c from contact where id IN: sContactIds];

                for(contact c: lstContact){
                    if(c.pse__Salesforce_User__c != null){
                        contactToUser.put(c.id, c.pse__Salesforce_User__c);
                    }
                }

                for(pse__Proj__c p: lstProjectsToUpdate){
                    if(contactToUser.containskey(p.ProjectApprover__c)){
                        p.ProjectApproverUser__c = contactToUser.get(p.ProjectApprover__c);
                    }
                    
                    if(contactToUser.containskey(p.CaptureManager__c)){
                        p.CaptureManagerUser__c = contactToUser.get(p.CaptureManager__c);
                    } 
                    
                }
            }
        }

        if(isAfter)
        {
            if(isInsert || isUpdate)
            {
                if(EvaluateHealthyStart_Enabled && !executedMethods.contains('EvaluateHealthyStart') && (!UserInfo.getUserName().toLowerCase().contains('integration@aecom.com')))
                {
                    ECO_pse_Project_Main.EvaluateHealthyStart(newList);
                }
            }
        }
    }
}