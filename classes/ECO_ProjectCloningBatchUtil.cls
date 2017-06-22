global without sharing class ECO_ProjectCloningBatchUtil implements Database.Batchable<Sobject>, Database.Stateful{

    global list<sObject> sObjectList;

    global Map<Id,Id> oldToNewMap;
    
    //global Integer processingId;
    global Id processingId;

    global Map<String, Set<String>> hardcodedFieldMembersForObject;

    global Map<Id, Id> oldToNewMapForNextLevel;

    global Map<Id, Id> mapIdForLookupReferences;

    global Map<String, Id> mapAdditionalFieldsToChange;

    global Id targetProjectId;
    global Id sourceProjectId;

    global boolean IsConverted;

    global ECO_ProjectCloningBatchUtil (Id sourceProjectIdIn, Id targetProjectIdIn, Id processingIdIn, Map<Id,Id> parentSourceToTargetMap, Map<String, Set<String>> hardcodedFieldMembersForObjectIn, Map<Id,Id> mapIdForLookupReferencesIn){
        system.debug('DebugMe:  ECO_ProjectCloningBatchUtil.ctor()');
        sObjectList = new List<SObject>();
        IsConverted = false;

        oldToNewMap = new Map<Id,Id>();
        oldToNewMap = parentSourceToTargetMap;
        sourceProjectId = sourceProjectIdIn;
        targetProjectId = targetProjectIdIn;
        processingId = processingIdIn;
        hardcodedFieldMembersForObject = new Map<String, Set<String>>();
        if(!hardcodedFieldMembersForObjectIn.isEmpty()){
            hardcodedFieldMembersForObject = hardcodedFieldMembersForObjectIn;
        }
        /*
        mapAdditionalFieldsToChange = new Map<String,Id>();
        if(!mapAdditionalFieldsToChangeIn.isEmpty()){
            mapAdditionalFieldsToChange = mapAdditionalFieldsToChangeIn;
        }
        */
        mapIdForLookupReferences = new Map<Id,Id>();
        if(!mapIdForLookupReferencesIn.isEmpty()){
            mapIdForLookupReferences = mapIdForLookupReferencesIn;
        }

        oldToNewMapForNextLevel = new Map<Id,Id>();   
    }


    global Iterable<sObject> start(Database.BatchableContext bc){
        system.debug('DebugMe: start batch:  ' + bc);
        String targetBudgetHeaderId;
        Map<String, BudgetResource__c> targetBudgetResources = new Map<String, BudgetResource__c>();

        //get custom settings for objects that need to be batchprocessed
        List<ECO_Project_Cloning__c> cloneSettings = [SELECT Object_API_Name__c, Processing_Order__c, Fieldset_API_Name__c, Parent_Object_API_Name__c, 
                                                        Additional_SOQL_Where_Filter__c, Parent_Processing_Level__c
                                                        FROM ECO_Project_Cloning__c
                                                        WHERE Id = :processingId AND Active__c = true
                                                        ORDER BY Processing_Order__c ASC];

        if(!cloneSettings.isEmpty()){
            ECO_Project_Cloning__c cpf = cloneSettings.get(0);

            //special handling for tasks - update start and end date to sync with target project
            Integer dayDiff = 0;
            Boolean adjustDates = false;
            if(cpf.Object_API_Name__c.equalsIgnoreCase('pse__Project_Task__c')){
                List<pse__Proj__c> projects = [SELECT Id, pse__Start_Date__c, pse__End_Date__c, isConverted__c
                                                FROM pse__Proj__c 
                                                WHERE Id = :sourceProjectId OR Id = :targetProjectId];

                Date sourceStartDate = null;
                Date targetStartDate = null;

                for(pse__Proj__c proj : projects){
                    if(proj.Id == sourceProjectId){
                        sourceStartDate = proj.pse__Start_Date__c;                        
                    }else{
                        targetStartDate = proj.pse__Start_Date__c;                        
                    }
                }
                if(sourceProjectId != null && targetStartDate != null){
                    dayDiff = sourceStartDate.daysBetween(targetStartDate);
                    adjustDates = true;
                }
                

                for(pse__Proj__c proj : projects){
                    if(proj.id == sourceProjectId && proj.isConverted__c == true){
                        IsConverted = true;
                    }
                }

            }



            /*if(cpf.Object_API_Name__c.equalsIgnoreCase('BudgetTask__c')){
                if(targetBudgetHeaderId == null){
                    targetBudgetHeaderId = [SELECT Id FROM BudgetHeader__c WHERE Project__c = :targetProjectId ORDER BY LastModifiedDate ASC  LIMIT 1].Id;
                }
            }

            if(cpf.Object_API_Name__c.equalsIgnoreCase('BudgetAssignment__c')){
                targetBudgetHeaderId = [SELECT Id FROM BudgetHeader__c WHERE Project__c = :targetProjectId ORDER BY LastModifiedDate ASC  LIMIT 1].Id;
                List<BudgetResource__c> targetResources = [SELECT ClonedSourceId__c, Name FROM BudgetResource__c WHERE BudgetHeader__c = :targetBudgetHeaderId];
                for(BudgetResource__c r : targetResources){
                    targetBudgetResources.put(r.ClonedSourceId__c, r);
                }
            }*/

            /*if(cpf.Object_API_Name__c.equalsIgnoreCase('BudgetTask__c')){
                if(targetBudgetHeaderId == null){
                    list<BudgetHeader__c> lstBH = [SELECT Id, Project__r.pse__Stage__c FROM BudgetHeader__c WHERE CandidateForCloning__c = true AND Project__c = :targetProjectId ORDER BY LastModifiedDate ASC];

                    if(lstBH.size() > 0 && lstBH[0].Project__r.pse__Stage__c == 'Execution' ){
                        targetBudgetHeaderId = lstBH[0].id;
                    } else {
                        targetBudgetHeaderId = lstBH[lstBH.size() - 1].id;
                    }
                }
            }

            if(cpf.Object_API_Name__c.equalsIgnoreCase('BudgetAssignment__c')){
                list<BudgetHeader__c> lstBH = [SELECT Id, Project__r.pse__Stage__c FROM BudgetHeader__c WHERE CandidateForCloning__c = true AND Project__c = :targetProjectId ORDER BY LastModifiedDate ASC];

                if(lstBH.size() > 0 && lstBH[0].Project__r.pse__Stage__c == 'Execution' ){
                    targetBudgetHeaderId = lstBH[0].id;
                } else {
                    targetBudgetHeaderId = lstBH[lstBH.size() - 1].id;
                }

                List<BudgetResource__c> targetResources = [SELECT ClonedSourceId__c, Name FROM BudgetResource__c WHERE BudgetHeader__c = :targetBudgetHeaderId];
                for(BudgetResource__c r : targetResources){
                    targetBudgetResources.put(r.ClonedSourceId__c, r);
                }
            }*/



            //get field set
            system.debug('hardcodedFieldMembersForObject size =' + hardcodedFieldMembersForObject.size());
            Set<String> fieldSetMembers = new Set<String>();
            ECO_ProjectCloningService cs = new ECO_ProjectCloningService();
      
            if(!hardcodedFieldMembersForObject.isEmpty()){  //hardcoded values
                fieldSetMembers = cs.getFieldSetMembersFromMap(hardcodedFieldMembersForObject, cpf.Fieldset_API_Name__c);
            }else{  //field names come from object fieldsets
                fieldSetMembers = cs.getFieldSetMembers(cpf.Fieldset_API_Name__c, cpf.Object_API_Name__c);
            }
            system.debug('fieldSetMembers size=' + fieldSetMembers.size());
            Set<String> lookupFieldsInFieldSet = cs.getLookupFieldsForFieldset(cpf.Object_API_Name__c);

            //build dynamic soql to get objects that need to be cloned
            String soql = '';
            String fields = '';
            Set<String> fieldsToCopyApiNames = new Set<String>();
            if(!fieldsToCopyApiNames.contains('id') && !fieldsToCopyApiNames.contains('Id') && !fieldsToCopyApiNames.contains('ID')){
                fieldsToCopyApiNames.add('Id');
            }
            for(String fieldSetMember : fieldSetMembers){
                if(fieldSetMember.compareTo(cpf.Parent_Object_API_Name__c) != 0){
                    fields += fieldSetMember + ',';   
                    fieldsToCopyApiNames.add(fieldSetMember);                       
                }
                                 
            }
            if(!String.isEmpty(fields)){
                //get rid of last ','
                fields = fields.substring(0, fields.length()-1);
            }

            Set<Id> parentIds = oldToNewMap.keySet();
            /*
            for(Id currId : parentIds){
                system.debug('parentid = ' + currId);
            }
            */

            system.debug('parentIds size = ' + parentIds.size());

            soql = 'SELECT ' + cpf.Parent_Object_API_Name__c + ',' + fields;
            soql += ' FROM ' + cpf.Object_API_Name__c;
            soql += ' WHERE ' + cpf.Parent_Object_API_Name__c + ' IN :parentIds AND ' + cpf.Parent_Object_API_Name__c + ' != NULL';
            
            if(!String.isEmpty(cpf.Additional_SOQL_Where_Filter__c)){
                soql += ' AND ' + String.escapeSingleQuotes(cpf.Additional_SOQL_Where_Filter__c);
            }
            system.debug('dynamic soql = ' + soql);
            List<SObject> sourceObjects = Database.query(soql);
            system.debug('num objects for this level = ' + sourceObjects.size());
            List<SObject> targetObjects = new List<SObject>();

            if(!sourceObjects.isEmpty()){
                
                for(SObject sourceObject : sourceObjects){
                    SObject targetObject = sourceObject.clone(false, true);
                    targetObject.clear();
                    String parentLookupApiName = cpf.Parent_Object_API_Name__c;
                    targetObject.put(parentLookupApiName, oldToNewMap.get((Id)sourceObject.get(parentLookupApiName)));

                    system.debug('adjustDates=' + adjustDates);

                    for(String fieldApiName : fieldsToCopyApiNames){
                        if(fieldApiName.toLowerCase() != 'id'){
                            /*
                            system.debug('fieldApiName = ' + fieldApiName);
                            system.debug('is start date = ' + fieldApiName.equalsIgnoreCase('pse__Start_Date_Time__c'));
                            system.debug('is end date = ' + fieldApiName.equalsIgnoreCase('pse__End_Date_Time__c'));
                            */
                            if(adjustDates && (fieldApiName.equalsIgnoreCase('pse__Start_Date_Time__c') || fieldApiName.equalsIgnoreCase('pse__End_Date_Time__c') ) ){
                                if(sourceObject.get(fieldApiName) != null){
                                    DateTime sourceDate = (DateTime)sourceObject.get(fieldApiName);
                                    DateTime targetDate = sourceDate.addDays(dayDiff);
                                    targetObject.put(fieldApiName, targetDate);
                                }                                
                            }else{
                            
                                targetObject.put(fieldApiName, sourceObject.get(fieldApiName));
                            }                            
                        }                        
                    }
       
                    //update lookup fields if the old id is mapped to a new id
                    for(String lookupApiName : lookupFieldsInFieldSet){                        
                        Id oldRefId = (Id)targetObject.get(lookupApiName);
                        if(mapIdForLookupReferences.containsKey(oldRefId)){
                            Id newRefId = mapIdForLookupReferences.get(oldRefId);
                            targetObject.put(lookupApiName, newRefId);
                        }
                    }                    
                  
                    /*if(cpf.Object_API_Name__c.equalsIgnoreCase('BudgetTask__c')){
                        targetObject.put('BudgetHeader__c', targetBudgetHeaderId);
                    }*/

                    /*
                    after cloning the budget assignment:
                    use the cloned source id to look up the source assignment (sourceBudgetAssignment)
                    which will give us the source resource id
                    then use that to look up the target resource id with the cloned source id
                    */
                   /*if(cpf.Object_API_Name__c.equalsIgnoreCase('BudgetAssignment__c')){
                        Id sourceResourceId = (Id)sourceObject.get('BudgetResource__c');
                        BudgetResource__c targetResource = targetBudgetResources.get(sourceResourceId);
                        if(targetResource != null){
                            targetObject.put('BudgetResource__c', targetResource.Id);
                        }
                        targetObject.put('BudgetVersion__c', targetBudgetHeaderId);
                    }*/


                    targetObject.put('ClonedSourceId__c', sourceObject.Id);
                    targetObjects.add(targetObject);
                    system.debug('DebugMe - targetObject:  ' + targetObject);


                }
            }

            sObjectList = targetObjects;

        }         

       return sObjectList;
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        system.debug('DebugMe:  execute batch');

        if(!IsConverted){
            ECO_TriggerSettings.bypass('PT_BudgetReplicate');
            ECO_TriggerSettings.bypass('PR_replicateNewProjectTask');
        }

        try{
            insert scope;
        } catch( Exception e){
            ECO_Service_ErrorLog.logException(e);
        }


        for(SObject obj : scope){
            oldToNewMapForNextLevel.put((Id)obj.get('ClonedSourceId__c'), (Id)obj.get('Id'));
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        system.debug('DebugMe: finish batch (' + processingId + ')');

        //get next set of objects to clone that are dependent on the objects just inserted
        List<ECO_Project_Cloning__c> cloneSettings = [SELECT Name, Object_API_Name__c, Processing_Order__c, Fieldset_API_Name__c, 
                                                        Parent_Object_API_Name__c, Additional_SOQL_Where_Filter__c, Parent_Processing_Level__c
                                                        FROM ECO_Project_Cloning__c
                                                        WHERE Id = :processingId
                                                        ORDER BY Processing_Order__c ASC];


        if(!cloneSettings.isEmpty()){
             

            ECO_Project_Cloning__c cpf = cloneSettings.get(0);
            //Processing level needs to be defined as processing order - 1.
            Decimal processingLevel = cpf.Processing_Order__c;

            Set<Id> parentIds = oldToNewMapForNextLevel.keySet();
            String soql = 'SELECT ' + cpf.Parent_Object_API_Name__c + ' FROM ' + cpf.Object_API_Name__c + ' WHERE ' + cpf.Parent_Object_API_Name__c + ' IN :parentIds';
            //soql += ' AND ClonedSourceId__c = NULL ';
            if(!String.isEmpty(cpf.Additional_SOQL_Where_Filter__c)){
                soql += ' AND ' + String.escapeSingleQuotes(cpf.Additional_SOQL_Where_Filter__c);
            }
            system.debug('soql for next level = ' + soql.replace(':parentIds', JSON.serialize(parentIds)));

            List<sObject> childrenObjects = Database.query(soql);

            system.debug('num child objects for next level = ' + childrenObjects.size());



            if(!childrenObjects.isEmpty()){

                for(Id key : oldToNewMapForNextLevel.keySet()){
                    mapIdForLookupReferences.put(key, oldToNewMapForNextLevel.get(key));
                }

                //children exist - run batch for nextlevel
                ECO_ProjectCloningBatchUtil batchUtil = new ECO_ProjectCloningBatchUtil(sourceProjectId, targetProjectId, processingId, oldToNewMapForNextLevel, hardcodedFieldMembersForObject, mapIdForLookupReferences);
                Id batchprocessid = Database.executeBatch(batchUtil, 50); 
            }else{
                //process any dependent objects 

                

                
                for(Id key : oldToNewMapForNextLevel.keySet()){
                    mapIdForLookupReferences.put(key, oldToNewMapForNextLevel.get(key));
                }
                

                List<ECO_Project_Cloning__c> nextLevelSettings = [SELECT Id, Object_API_Name__c, Processing_Order__c, Fieldset_API_Name__c, 
                                                        Parent_Object_API_Name__c, Additional_SOQL_Where_Filter__c, Parent_Processing_Level__c
                                                        FROM ECO_Project_Cloning__c
                                                        WHERE Parent_Processing_Level__c = :processingLevel
                                                        ORDER BY Processing_Order__c ASC];

                if(!nextLevelSettings.isEmpty()){
                    cpf = nextLevelSettings.get(0);
                    processingId = cpf.Id;
                    

                    //ECO_ProjectCloningBatchUtil batchUtilChildren = new ECO_ProjectCloningBatchUtil(sourceProjectId, targetProjectId, processingId, oldToNewMapForNextLevel, hardcodedFieldMembersForObject, mapIdForLookupReferences);
                    
                    ECO_ProjectCloningBatchUtil batchUtilChildren = new ECO_ProjectCloningBatchUtil(sourceProjectId, targetProjectId, processingId, mapIdForLookupReferences, hardcodedFieldMembersForObject, mapIdForLookupReferences);
                    

                    Id batchprocessidChildren = Database.executeBatch(batchUtilChildren, 50); 
/*
                    soql = 'SELECT ' + cpf.Parent_Object_API_Name__c + ' FROM ' + cpf.Object_API_Name__c + ' WHERE ' + cpf.Parent_Object_API_Name__c + ' IN :parentIds';
                    soql += ' AND ClonedSourceId__c = NULL ';
                    if(!String.isEmpty(cpf.Additional_SOQL_Where_Filter__c)){
                        soql += ' AND ' + String.escapeSingleQuotes(cpf.Additional_SOQL_Where_Filter__c);
                    }
                    system.debug('soql for children = ' + soql);
                    childrenObjects = Database.query(soql);
                    if(!childrenObjects.isEmpty()){
                        ECO_ProjectCloningService cs = new ECO_ProjectCloningService();
                        cs.newProjectId = targetProjectId;
                        system.debug('targetProjectId = ' + cs.newProjectId);
                        system.debug('sourceProjectId = ' + sourceProjectId);
                        system.debug('processingId = ' + processingId);
                        system.debug('mapIdForLookupReferences size = ' + mapIdForLookupReferences.size());
                        system.debug('calling cloning service');
                       // cs.cloneDependentItemsAfterBatch(sourceProjectId, processingId, mapIdForLookupReferences); 
                    }
                    */
                }    
                      
            }
        }

    }    
}