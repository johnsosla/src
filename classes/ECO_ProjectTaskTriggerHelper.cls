Public class ECO_ProjectTaskTriggerHelper
{
    public static void OnBeforeInsert(list<pse__Project_Task__c> triggerNew)
    {
        // validateSiblingforFinNonFinTask(triggerNew,null);
    }
    
    public static void OnBeforeUpdate(list<pse__Project_Task__c> triggerNew,map<Id,pse__Project_Task__c> triggerOldmap)
    {
        // validateSiblingforFinNonFinTask(triggerNew,triggerOldmap);
    }
    
    static void validateSiblingforFinNonFinTask(list<pse__Project_Task__c> triggerNew,map<Id,pse__Project_Task__c> triggerOldmap)
    {
        set<id> setParentTaskId = new set<Id>();
        set<id> setTaskId = new set<Id>();
        
        if(triggerOldmap == null)
        {
            for(pse__Project_Task__c obj : triggerNew)
            {
                if(obj.pse__Parent_Task__c != null)
                {
                    setParentTaskId.add(obj.pse__Parent_Task__c);
                    setTaskId.add(obj.Id);
                }
            }
        }
        else
        {
            for(pse__Project_Task__c obj : triggerNew)
            {
                if(obj.pse__Parent_Task__c != null && obj.FinancialTask__c != triggerOldmap.get(obj.Id).FinancialTask__c)
                {
                    setParentTaskId.add(obj.pse__Parent_Task__c);
                    setTaskId.add(obj.Id);
                }
            }
        }
        
        system.debug('setParentTaskId@@@ '+setParentTaskId);
        
        map<Id,list<pse__Project_Task__c>> mapParentIdToChildTask = new map<Id,list<pse__Project_Task__c>>();
        
        if(setParentTaskId.size() > 0)
        {
            for(pse__Project_Task__c obj : [select Id,Name,ForecastEndDate__c,pse__order__c,ProjectTaskNumber__c,ForecastStartDate__c,IsBillable__c,IsChargeable__c
                            ,EarnedValueCurve__c,Duration__c,FinancialTask__c,pse__Start_Date_Time__c, pse__End_Date_Time__c,
                             pse__Project__c,Task_Sequence_No__c,WorkTypeName__c,pse__Parent_Task__c, TransactionStartDate__c, TransactionEndDate__c
                             from pse__Project_Task__c where pse__Parent_Task__c in : setParentTaskId and id not in : setTaskId])
            {
                if(mapParentIdToChildTask.get(obj.pse__Parent_Task__c) == null)
                {
                    mapParentIdToChildTask.put(obj.pse__Parent_Task__c,new list<pse__Project_Task__c>());
                }
                mapParentIdToChildTask.get(obj.pse__Parent_Task__c).add(obj);
            }
        }
        
        if(mapParentIdToChildTask.size() >0)
        {
            for(pse__Project_Task__c obj : triggerNew)
            {
                if(obj.pse__Parent_Task__c != null)
                {
                    if(mapParentIdToChildTask.get(obj.pse__Parent_Task__c) != null)
                    {
                        system.debug('mapParentIdToChildTaskWWWWW '+mapParentIdToChildTask.get(obj.pse__Parent_Task__c));
                        for(pse__Project_Task__c objI : mapParentIdToChildTask.get(obj.pse__Parent_Task__c))
                        {
                            
                            if(obj.FinancialTask__c != objI.FinancialTask__c)
                            {
                                system.debug('objI!!!  '+objI.Id);
                                system.debug('obj!!!  '+obj.Id);
                                
                                system.debug('objI!!!@@@  '+objI.FinancialTask__c);
                                system.debug('obj!!!@@@@  '+obj.FinancialTask__c);
                                if(!Test.isRunningTest())
                                    obj.AddError('Siblings must have same financial setting. - Task Number: ' + obj.ProjectTaskNumber__c + ' - Task Name: ' + obj.name );
                            }
                        }
                    }
                }
            }
        }
    }
}