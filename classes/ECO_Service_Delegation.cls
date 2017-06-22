/** ------------------------------------------------------------------------------------------------------
* @Description Facilitates all delegation related functions such as escalation and bypass evaluation
*
* @Author      NTT Data - Tim Chiang
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
global without sharing class ECO_Service_Delegation {
    public static Boolean run = true;

    public static string CMProcessNameClose {
        get { 
            ECOApprovalAPINames__c CS = ECOApprovalAPINames__c.getOrgDefaults();
            return CS.CMProcessNameClose__c;
        }
        set;
    }
    public static string CMProcessNameHold {
        get { 
            ECOApprovalAPINames__c CS = ECOApprovalAPINames__c.getOrgDefaults();
            return CS.CMProcessNameHold__c;
        }
        set;
    }
    
    static map<id, contact> contactMap;
    public static list<ECO_DelegationCheck__c> lstCheck {get;set;}
    public static map<string, ECO_DelegationCheck__c> mapCheck {get;set;}


    public static ECO_Delegate_Approval_Process_Settings__c settings {get;set;}
    public static list<AECOM_Delegation__c> delegateSettings  {get;set;}
    public static list<string> processNames  {get;set;}
    public static map<string, AECOM_Delegation__c> mapDS  {get;set;}
    public static map<string, AECOM_Delegation__c> mapDSGeneral  {get;set;}
    public static map<string, set<string>> objectNameToFields {get;set;}


    /*public static void escalate(id sObjectID){

        List<SObject> sObjectsToUpdate = new List<SObject>();
        SObject o1 = sObjectID.getSObjectType().newSObject(sObjectID);
        o1.put('FlagForEscalate__c', true);
        sObjectsToUpdate.add(o1);

        try {
            update sObjectsToUpdate;
        } catch( Exception e){
            ECO_Service_ErrorLog.logException(e);
        }

        
    }*/

    /**
     * Extracts and setup base information used for escalation batch
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    public static void initialize(){

        if(settings == null){

            settings = ECO_Delegate_Approval_Process_Settings__c.getOrgDefaults();
            delegateSettings = [select id, Escalation__c, Field_API_Name__c, Object_Name__c, Process__c, ProcessAPIName__c, Role__c, ProcessStepAPI__c, FirstStepEscalation__c, FirstStepEscalationLock__c from AECOM_Delegation__c];

            processNames = new list<string>();
            mapDS = new map<string, AECOM_Delegation__c>();
            mapDSGeneral = new map<string, AECOM_Delegation__c>();
            objectNameToFields = new map<string, set<string>>();

            for(AECOM_Delegation__c d: delegateSettings){
                if(d.ProcessAPIName__c != null){
                    processNames.add(d.ProcessAPIName__c);
                    mapDS.put(d.ProcessAPIName__c + '-' + d.ProcessStepAPI__c, d);
                    mapDSGeneral.put(d.ProcessAPIName__c, d);
                }


                if(!objectNameToFields.containskey(d.Object_Name__c)){
                    objectNameToFields.put(d.Object_Name__c, new set<string>());
                }

                objectNameToFields.get(d.Object_Name__c).add(d.Field_API_Name__c);

                if(d.FirstStepEscalation__c != null){
                    objectNameToFields.get(d.Object_Name__c).add(d.FirstStepEscalation__c);
                    if(d.FirstStepEscalationLock__c != null){
                        objectNameToFields.get(d.Object_Name__c).add(d.FirstStepEscalationLock__c);
                    }
                }
            }        



        }
    }

    /**
     * Forms base query for batch escalation
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    public static string formQuery(){

        initialize();

        string query;

        query = 'Select CompletedDate, ProcessDefinitionId, ProcessDefinition.DeveloperName, CreatedById, CreatedDate, ElapsedTimeInDays, ElapsedTimeInHours, Id, LastActorId, Status, TargetObjectId,';
        query += '(SELECT Id, ActorId, OriginalActorId, StepStatus, CreatedDate, StepNodeId FROM Steps ORDER BY CreatedDate DESC), '; 
        query += '(SELECT Id, StepStatus, ActorId, OriginalActorId, ProcessNodeId, ProcessInstanceId, CreatedDate FROM StepsAndWorkitems where StepStatus=\'Pending\' or StepStatus=\'Reassigned\' ORDER BY CreatedDate DESC), ';
        query += '(SELECT ActorId,CreatedDate,OriginalActorId,ProcessInstanceId,Id, ElapsedTimeInDays FROM Workitems) ';
        query += 'from ProcessInstance where Status = \'Pending\' ';

        for(integer i=0; i <= processNames.size() -1; i++){
            if(i == 0){
                query += 'AND (';
            } else {
                query += ' OR ';
            }

            query += 'ProcessDefinition.DeveloperName = \'' + processNames[i] + '\' ';

            if(i == processNames.size() -1){
                query += ')';
            }
        }        

        return query;
    }


    /**
     * Generic method to retrieve required Sobject info from various Sobject types
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    public static void constructObjectData(string objectName, set<id> objectIDs, list<id> lstProjectIds, map<id, id> mapObjectToProject,  map<id, Sobject> mapObjects){
        string strSOQL = 'select id, delegateProject__c, FlagForEscalate__c ';

        if(objectNameToFields.containskey(objectName)){
            for(string field: objectNameToFields.get(objectName)){

                //add the contact from the custom settings
                strSOQL = strSOQL + ', ' +  field;

                // add the contact's SFDC user from the custom settings
                //string userField = field.removeEnd('__c') + '__r.pse__Salesforce_User__c';
                //strSOQL = strSOQL + ', ' +  userField;
            }
        }

        strSOQL = strSOQL + ' FROM ' + objectName + ' where id IN: objectIDs';

        list<sobject> lstObjects = Database.query(strSOQL);

        for(sobject so: lstObjects){
            lstProjectIds.add((id)so.get('delegateProject__c'));
            mapObjectToProject.put((id)so.get('id'), (id)so.get('delegateProject__c'));
            mapObjects.put((id)so.get('id'), so);
        }        
    }

    /**
     * Creates a workitem request for recall
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    public static void createRecallItem(id workitemid, map<id, Approval.ProcessWorkItemRequest> mapProcessWorkItemReq){
        Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
        pwr.setAction('Removed');
        pwr.setWorkItemId(workitemid);
        pwr.SetComments('The workflow has timed out. Please resubmit this project for approval.');

        mapProcessWorkItemReq.put(workItemid, pwr);        
    }


    /**
     * Handles the execute portion of the batch escalation
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    public static void handleEscalationExecute(List<ProcessInstance> processInstances, boolean skipDateCheck){

        ECO_ProjectTriggers.run = false;
        ECO_QuestionnaireSet_TriggerDispatcher.run = false;
        ECO_Service_PurchaseOrders.run = false;
        //ECO_ChangeManagerTriggerHandler.masterRun = false;
        ECO_ChangeManagerTriggerHandler.run = false;
        ECO_ChangeManagerTriggerHandler.handleRejection = true;
        ECO_ProjectReviewTrigger.run = false;
        ECO_BudgetHeaderTriggers.run = false;

        initialize();
        
        Id alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeDeveloperName);

        map<id, AECOM_Delegation__c> mapProcessToField = new map<id, AECOM_Delegation__c>();
        map<id, AECOM_Delegation__c> mapProcessToFieldGeneral = new map<id, AECOM_Delegation__c>();


        
        map<id, Approval.ProcessWorkItemRequest> mapProcessWorkItemReq = new map<id, Approval.ProcessWorkItemRequest>();
        map<id, Delegation__c> mapDelegationsToInsert = new map<id, Delegation__c>();
        map<id, PortalMessage__c> mapPortalMsgToInsert = new map<id, PortalMessage__c>();
        map<id, id> mapProcessToObject = new map<id, id>();
        map<id, id> mapObjectToProject = new map<id, id>();
        map<id, pse__Proj__c> mapProcessToProject = new map<id, pse__Proj__c>();
        map<id, ProcessInstance> mapWorkItemToProcess = new map<id, ProcessInstance>();
        set<id> setProDefIds = new set<id>();
        map<id, ProcessNode> mapPDIDtoPN = new map<id, ProcessNode>();
        map<id, pse__Proj__Share> mapIDtoPS = new map<id, pse__Proj__Share>();

        map<id, Sobject> mapSObjectToUpdate = new map<id, Sobject>();


        if(processInstances.size() > 0){
            List<Id> originalApproverIds = new List<Id>();
            List<ProcessInstance> processForEscalation = new List<ProcessInstance>();
            set<id> objectIDs = new set<id>();
            List<ProcessInstanceWorkitem> lstWorkItems = new List<ProcessInstanceWorkitem>();


            for(ProcessInstance processInstance : processInstances){
                setProDefIds.add(processInstance.ProcessDefinitionId);
            }

            for(ProcessNode pn:[SELECT Id,Name,DeveloperName, ProcessDefinitionId FROM ProcessNode WHERE ProcessDefinitionId IN:setProDefIds]){
                mapPDIDtoPN.put(pn.id, pn);
            }


            for(ProcessInstance PI : processInstances){
                objectIDs.add(PI.TargetObjectId);
            }


            map<id, id> userToContact = new map<id, id>();
            map<id, Sobject> mapObjects = new map<id, Sobject>();

            list<id> lstProjectIds = new list<id>();

            constructObjectData('ChangeManager__c', objectIDs, lstProjectIds, mapObjectToProject, mapObjects);
            constructObjectData('POHeader__c', objectIDs, lstProjectIds, mapObjectToProject, mapObjects);
            constructObjectData('pse__Proj__c', objectIDs, lstProjectIds, mapObjectToProject, mapObjects);
            constructObjectData('QuestionnaireSet__c', objectIDs, lstProjectIds, mapObjectToProject, mapObjects);
            constructObjectData('ProjectReview__c', objectIDs, lstProjectIds, mapObjectToProject, mapObjects);


            for(ProcessInstance PI : processInstances){

                

                string search = null;

                if(mapPDIDtoPN.containskey((id)PI.StepsAndWorkitems[0].ProcessNodeId) && mapPDIDtoPN.get((id)PI.StepsAndWorkitems[0].ProcessNodeId) !=null){
                    search = PI.ProcessDefinition.DeveloperName + '-' + mapPDIDtoPN.get((id)PI.StepsAndWorkitems[0].ProcessNodeId).DeveloperName;
                } else {
                    search = PI.ProcessDefinition.DeveloperName + '-';
                }

                //system.debug('DEBUG@@@ ID: ' + PI.TargetObjectId + ' process ' + search);

                if(mapDS.containskey(search)){

                    //system.debug('DEBUG@@@ FOUND');
                    AECOM_Delegation__c delPI = mapDS.get(search);

                    if(delPI.FirstStepEscalation__c != null &&
                        delPI.FirstStepEscalationLock__c != null &&
                        mapObjects.containskey((id)PI.TargetObjectId) &&
                        hasSObjectField(delPI.FirstStepEscalationLock__c, mapObjects.get((id)PI.TargetObjectId)) &&
                        (boolean)mapObjects.get((id)PI.TargetObjectId).get(delPI.FirstStepEscalationLock__c) == true){

                        //system.debug('DEBUG@@@ CONTINUE');
                        continue;
                    }
                }




                if(skipDateCheck ||  
                    ECO_Service_Delegation.GetElapsedTime(PI.StepsAndWorkitems[0].CreatedDate, datetime.now()) >= settings.Number_of_Days_Allowed_In_Process__c || 
                    (mapObjects.containskey((id)PI.TargetObjectId) &&  (boolean)mapObjects.get((id)PI.TargetObjectId).get('FlagForEscalate__c') == true)
                    ){


                    if(mapObjects.containskey((id)PI.TargetObjectId) &&  (boolean)mapObjects.get((id)PI.TargetObjectId).get('FlagForEscalate__c') == true){
                        mapObjects.get((id)PI.TargetObjectId).put('FlagForEscalate__c' ,false);

                        mapSObjectToUpdate.put((id)mapObjects.get((id)PI.TargetObjectId).get('id'), mapObjects.get((id)PI.TargetObjectId));
                    } else {

                    }

                    for(ProcessInstanceWorkitem workItem : PI.Workitems){

                            processForEscalation.add(PI);

                            string searchKey = null;
                            string searchKeyGeneral = null;

                            searchKeyGeneral = PI.ProcessDefinition.DeveloperName;

                            if(mapPDIDtoPN.containskey((id)PI.StepsAndWorkitems[0].ProcessNodeId) && mapPDIDtoPN.get((id)PI.StepsAndWorkitems[0].ProcessNodeId) !=null){
                                searchKey = PI.ProcessDefinition.DeveloperName + '-' + mapPDIDtoPN.get((id)PI.StepsAndWorkitems[0].ProcessNodeId).DeveloperName;
                            } else {
                                searchKey = PI.ProcessDefinition.DeveloperName + '-';
                            }

                            //system.debug(searchKey + '---' + searchKeyGeneral);
                            if(mapDS.containsKey(searchKey) || mapDSGeneral.containsKey(searchKeyGeneral)){

                                //system.debug('found');

                                mapProcessToObject.put(workItem.id, PI.TargetObjectId);
                                
                                originalApproverIds.add(workItem.ActorId);
                                lstWorkItems.add(workItem);
                                mapWorkItemToProcess.put(workItem.id, PI);
                                
                                if(mapDS.containsKey(searchKey)){
                                    mapProcessToField.put(workItem.id, mapDS.get(searchKey));
                                } else {
                                    mapProcessToFieldGeneral.put(workItem.id, mapDSGeneral.get(searchKeyGeneral));
                                }
                            }
                    }
                }

            }

            if(processForEscalation.size() > 0){


                map<id, pse__Proj__c> mapProj = new map<id, pse__Proj__c>([select id 
                                                                                ,name
                                                                                ,EcoSystemReferenceNumber__c
                                                                                ,PnLManager__c
                                                                                ,FinanceLead__c
                                                                                ,PnLManager__r.pse__Salesforce_User__c
                                                                                ,FinanceLead__r.pse__Salesforce_User__c
                                                                                ,pse__Project_Manager__r.pse__Salesforce_User__c
                                                                                ,CarryingOutOrganization__c 
                                                                            from pse__Proj__c where id IN: lstProjectIds]);

                for(id i: mapProcessToObject.keyset()){

                    id objID = mapProcessToObject.get(i);

                    if(mapObjectToProject.containsKey(objID) && mapProj.containsKey(mapObjectToProject.get(objID))){

                        pse__Proj__c tempProj = mapProj.get(mapObjectToProject.get(objID));

                        mapProcessToProject.put(i, tempProj);

                        if(tempProj.PnLManager__c != null && tempProj.PnLManager__r.pse__Salesforce_User__c !=null){
                            userToContact.put((id)tempProj.PnLManager__r.pse__Salesforce_User__c, (id)tempProj.PnLManager__c);
                        }

                        if(tempProj.FinanceLead__c != null && tempProj.FinanceLead__r.pse__Salesforce_User__c !=null){
                            userToContact.put((id)tempProj.FinanceLead__r.pse__Salesforce_User__c, (id)tempProj.FinanceLead__c);
                        }

                    }
                }

                //find the alternate delegates for the original actors in the approval process
                Map<Id, Delegate__c> delegatorId2Delegate = new Map<Id, Delegate__c>();
                Map<Id, contact> contactIDToContact = new Map<Id, contact>();
                List<Delegate__c> delegates = [Select Id, Delegate__c, Delegate__r.pse__Salesforce_User__c, Delegator__c, 
                                                     Delegator__r.pse__Salesforce_User__c , CurrencyIsoCode, RecordType.DeveloperName
                                                from Delegate__c 
                                                where RecordType.DeveloperName = 'Alternate' and Delegator__r.pse__Salesforce_User__c IN : originalApproverIds and 
                                                    (Start_Date__c != null and Start_Date__c <=: datetime.now().dateGMT()) and (End_Date__c = null or End_Date__c >=: datetime.now().dateGMT())];


                for(Delegate__c delegate : delegates){
                    delegatorId2Delegate.put(delegate.Delegator__r.pse__Salesforce_User__c, delegate);
                    userToContact.put(delegate.Delegator__r.pse__Salesforce_User__c, delegate.Delegate__c);
                }  

                //if an alternate does not exist, we will have to use the user's supervisor to default an alternate. Must use the users to query the contacts to get the supervisor user ids. 
                List<contact> lstContact = [select id, pse__Salesforce_User__c, ReportsTo.pse__Salesforce_User__c, ReportsToid from contact where pse__Salesforce_User__c IN: originalApproverIds];

                for(contact c : lstContact){
                    userToContact.put(c.ReportsTo.pse__Salesforce_User__c, c.ReportsToid);
                    userToContact.put(c.pse__Salesforce_User__c, c.id);

                    contactIDToContact.put(c.pse__Salesforce_User__c, c);

                }
                  





                list<ProcessInstanceWorkitem> workItemsToUpdate = new list<ProcessInstanceWorkitem>();

                // check to see IF the user is an PnL OR FA of the project
                for(ProcessInstanceWorkitem workItem : lstWorkItems){

                    id oldactor = workItem.actorid;

                    string strRouteLogic = '';

                    if(mapProcessToProject.containsKey(workItem.id)){


                        pse__Proj__c mappedProj = mapProcessToProject.get(workItem.id);


                        boolean esclateToAlt = false;

                        if(mapProcessToField.containsKey(workItem.id)){
                            AECOM_Delegation__c delSetting = mapProcessToField.get(workItem.id);


                            if(mapProcessToProject.containsKey(workItem.id)){

                                pse__Proj__c processProj = mapProcessToProject.get(workItem.id);
                                id objectID = mapWorkItemToProcess.get(workItem.id).TargetObjectId;
                                sobject targetO = mapObjects.get(objectID);

                                string userField = null;
                                string objectFieldUser = null;
                                string firstEscalationUserField = null;
                                string firstEscalationobjectFieldUser = null;

                                if(hasSObjectField(delSetting.Field_API_Name__c, targetO)){
                                    //userField = delSetting.Field_API_Name__c.removeEnd('__c') + '__r.pse__Salesforce_User__c';
                                    objectFieldUser = (id)targetO.get(delSetting.Field_API_Name__c);
                                }

                                if(delSetting.FirstStepEscalation__c != null && hasSObjectField(delSetting.FirstStepEscalation__c, targetO)){
                                    //firstEscalationUserField = delSetting.FirstStepEscalation__c.removeEnd('__c') + '__r.pse__Salesforce_User__c';
                                    firstEscalationobjectFieldUser = (id)targetO.get(delSetting.FirstStepEscalation__c);
                                }


                                if(delSetting.FirstStepEscalation__c != null && workItem.actorid == objectFieldUser){

                                    strRouteLogic = ' First Escalation Step: ' + delSetting.Field_API_Name__c + ' --> ' + delSetting.FirstStepEscalation__c;
                                    workItem.ActorId = firstEscalationobjectFieldUser;
                                    workItemsToUpdate.add(workItem);

                                } else if(delSetting.Escalation__c == 'PNL' && processProj.PnLManager__c != null && processProj.PnLManager__r.pse__Salesforce_User__c != null){


                                    boolean foundPNL = false;


                                    for(processinstancehistory pih: mapWorkItemToProcess.get(workItem.id).StepsAndWorkitems){
                                        
                                        //system.debug('CHECK HISTORY : ' + pih);
                                        //system.debug('LATEST HISTORY : ' + mapWorkItemToProcess.get(workItem.id).StepsAndWorkitems[0]);

                                        //check to see if this is the current step
                                        if(pih.ProcessNodeId == mapWorkItemToProcess.get(workItem.id).StepsAndWorkitems[0].ProcessNodeId){

                                            //system.debug('SAME STEP');

                                            if(pih.ActorId == processProj.PnLManager__r.pse__Salesforce_User__c || pih.OriginalActorId == processProj.PnLManager__r.pse__Salesforce_User__c){
                                                //system.debug('FOUND');
                                                foundPNL = true;
                                            }
                                        }
                                    }

                                    if(!foundPNL){
                                        strRouteLogic = ' Escalating to P&L Manager as one has not been found for this approval step.';
                                        workItem.ActorId = processProj.PnLManager__r.pse__Salesforce_User__c;
                                        workItemsToUpdate.add(workItem);
                                    } else {
                                        
                                        if(workItem.ActorId == processProj.PnLManager__r.pse__Salesforce_User__c){
                                            strRouteLogic = ' The P&L has been found as last actor - Escalate to Alt -- ';
                                            esclateToAlt = true;
                                        } else {
                                            strRouteLogic = ' The P&L has been found as a previous actor - Do Not Escalate to Alt -- ';
                                            createRecallItem(workItem.id, mapProcessWorkItemReq);
                                        }
                                    }

                                } else if (delSetting.Escalation__c == 'FA' && processProj.FinanceLead__c != null && processProj.FinanceLead__r.pse__Salesforce_User__c != null) {

                                    boolean foundFA = false;

                                    for(processinstancehistory pih: mapWorkItemToProcess.get(workItem.id).StepsAndWorkitems){
                                        
                                        //check to see if this is the current step
                                        if(pih.ProcessNodeId == mapWorkItemToProcess.get(workItem.id).StepsAndWorkitems[0].ProcessNodeId){
                                            if(pih.ActorId == processProj.FinanceLead__r.pse__Salesforce_User__c || pih.OriginalActorId == processProj.FinanceLead__r.pse__Salesforce_User__c){
                                                foundFA = true;
                                            }
                                        }
                                    }

                                    if(!foundFA){
                                        strRouteLogic = ' Escalating to FA as one has not been found for this approval step.';
                                        workItem.ActorId = processProj.FinanceLead__r.pse__Salesforce_User__c;
                                        workItemsToUpdate.add(workItem);
                                    } else {

                                        if(workItem.ActorId == processProj.FinanceLead__r.pse__Salesforce_User__c){
                                            strRouteLogic = ' The FA has been found as last actor - Escalate to Alt -- ';
                                            esclateToAlt = true;
                                        } else {
                                            strRouteLogic = ' The FA has been found as a previous actor - Do Not Escalate to Alt -- ';
                                            createRecallItem(workItem.id, mapProcessWorkItemReq);
                                        }
                                    }
                                } else {

                                }
                                
                            }
                        }

                        boolean logDelegation = true;

                        if(esclateToAlt){

                            if(delegatorId2Delegate.containsKey(workItem.ActorId) && delegatorId2Delegate.get(workItem.ActorId).Delegate__r.pse__Salesforce_User__c != null ){

                                strRouteLogic += ' Escalating to Alternate';
                                workItem.ActorId = delegatorId2Delegate.get(workItem.ActorId).Delegate__r.pse__Salesforce_User__c;
                                workItemsToUpdate.add(workItem);

                            } else {

                                if(contactIDToContact.containskey(workItem.ActorId) 
                                    && contactIDToContact.get(workItem.ActorId).ReportsToid !=null 
                                    && contactIDToContact.get(workItem.ActorId).ReportsTo.pse__Salesforce_User__c !=null){

                                    strRouteLogic += ' Escalating to Manager (Default Alternate)';
                                    workItem.ActorId = contactIDToContact.get(workItem.ActorId).ReportsTo.pse__Salesforce_User__c;
                                    workItemsToUpdate.add(workItem);                                    
                                } else {
                                    strRouteLogic += ' An Escalation path has not been found';
                                    logDelegation = false;
                                }

                            }                            
                        }

                        if(logDelegation){

                            id delegateContact = null;
                            if(userToContact.containskey(workItem.ActorId)){
                                delegateContact = userToContact.get(workItem.ActorId);
                            }

                            id oldContact = null;
                            if(userToContact.containskey(oldactor)){
                                oldContact = userToContact.get(oldactor);
                            }


                            id delegateRecord = null;
                            if(delegatorId2Delegate.containsKey(workItem.ActorId)){
                                delegateRecord = delegatorId2Delegate.get(workItem.ActorId).id;
                            }

                            string processName = null;
                            if(mapProcessToField.containsKey(workItem.id)){
                                processName = mapProcessToField.get(workItem.id).Process__c;
                            } else {
                                processName = mapProcessToFieldGeneral.get(workItem.id).Process__c;
                            }

                            string delReason = null;
                            if(mapSObjectToUpdate.containskey(mapProcessToObject.get(workItem.id))){
                                delReason = 'Manual Escalation';
                            } else {
                                delReason = 'Automatic Escalation';
                            }

                            if(strRouteLogic != null){
                                delReason = delReason + strRouteLogic;
                            }


                            Delegation__c oDelegation = new Delegation__c(DelegateUser__c = workItem.ActorId
                                                                        , OldDelegate__c = oldactor
                                                                        , OldDelegateContact__c = oldContact
                                                                        , Delegate_Swapped__c = delegateContact
                                                                        , Record__c = mapWorkItemToProcess.get(workItem.id).TargetObjectId
                                                                        , Process__c = processName
                                                                        , Object_Name__c = mapWorkItemToProcess.get(workItem.id).TargetObjectId.getSObjectType().getDescribe().getLabel()
                                                                        , Delegation_Reason__c = delReason
                                                                        , Delegate__c = delegateRecord
                                                                        , Project__c = mappedProj.id
                                                                        , Field_Name__c = null
                                                                        , Delegation_Process__c = 'N/A'
                                                                        );

                            mapDelegationsToInsert.put(mapWorkItemToProcess.get(workItem.id).TargetObjectId, oDelegation);

                            string strDescription = '';
                            if(strRouteLogic.contains('Do Not Escalate to Alt')){
                                strDescription = 'The workflow for ' + processName + ' on ' + mappedProj.Name  + ' has timed out. Please resubmit this project for approval.';
                            }else{
                                strDescription = 'The workflow for ' + processName + ' on ' + mappedProj.Name  + ' has been escalated.';
                            } 

                            PortalMessage__c oPortalMessage = new PortalMessage__c(RecordTypeId = alertRecordTypeId
                                            , User__c = mappedProj.pse__Project_Manager__r.pse__Salesforce_User__c 
                                            , StartDate__c = Date.today()
                                            , EndDate__c = Date.today().addDays(7)
                                            , LongDescriptionMaxLength__c = strDescription
                                            , Subject__c = mappedProj.name
                                            , LinkToRecord__c = '/' + mappedProj.Id
                                            , Project_Number__c = mappedProj.EcoSystemReferenceNumber__c
                                            );

                            mapPortalMsgToInsert.put(mapWorkItemToProcess.get(workItem.id).TargetObjectId, oPortalMessage);




                            

                            //system.debug('IN SHARE CREATE');
                            pse__Proj__Share ps = new pse__Proj__Share();
                            ps.AccessLevel = 'Edit';
                            ps.ParentId = mappedProj.id;
                            ps.UserOrGroupId =  workItem.ActorId;  
                            ps.RowCause = Schema.pse__Proj__Share.RowCause.Delegation__c;                    
                            mapIDtoPS.put(workItem.id, ps);          
                            //system.debug(ps);     

                        }
                    }

                }



                if(workItemsToUpdate.size() > 0){

                    //system.debug(workItemsToUpdate);

                    Database.SaveResult[] srList = Database.update(workItemsToUpdate, false);
                    ECO_Service_ErrorLog.logException( workItemsToUpdate, srList, 'ECO_Service_Delegation.handleEscalationExecute - Update WorkItems');

                    //update workItemsToUpdate;
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            //system.debug('Successfully updated workitem ID: ' + sr.getId());
                        } else {

                            if(mapProcessToObject.containskey((id)sr.getId())){
                                mapSObjectToUpdate.remove(mapProcessToObject.get((id)sr.getId()));
                                mapDelegationsToInsert.remove(mapProcessToObject.get((id)sr.getId()));
                                mapIDtoPS.remove((id)sr.getId());
                            }

                            for(Database.Error err : sr.getErrors()) {
                                //system.debug('The following error has occurred.');          
                                //system.debug(err.getStatusCode() + ': ' + err.getMessage());
                                //system.debug('Workitem fields that affected this error: ' + err.getFields());

                            }
                        }
                    }


                }

                if(mapSObjectToUpdate.values().size() > 0){

                    ECO_ProjectTriggers.run = false;
                    ECO_QuestionnaireSet_TriggerDispatcher.run = false;
                    ECO_Service_PurchaseOrders.run = false;
                    ECO_ChangeManagerTriggerHandler.run = false;
                    ECO_ProjectReviewTrigger.run = false;

                    list<sobject> lstToUpdate = mapSObjectToUpdate.values();

                    Database.SaveResult[] srList = Database.update(lstToUpdate, false);
                    ECO_Service_ErrorLog.logException( lstToUpdate, srList, 'ECO_Service_Delegation.handleEscalationExecute - Update Sobject Flag Reset');

                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            //system.debug('Successfully updated sobject ID: ' + sr.getId());
                        } else {

                            //system.debug('Error trying to reset escalation flag for sobject ID: ' + sr.getId());

                            for(Database.Error err : sr.getErrors()) {
                                //system.debug('The following error has occurred.');          
                                //system.debug(err.getStatusCode() + ': ' + err.getMessage());
                                //system.debug('SObject fields that affected this error: ' + err.getFields());

                            }
                        }
                    }

                }

                if(mapIDtoPS.values().size() > 0){

                    list<pse__Proj__Share> listPS = mapIDtoPS.values();

                    Database.SaveResult[] srList = Database.insert(listPS, false);
                    ECO_Service_ErrorLog.logException( listPS, srList, 'ECO_Service_Delegation.handleEscalationExecute - Insert Sobject Project Share');

                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {

                        } else {

                            for(Database.Error err : sr.getErrors()) {
                                //system.debug('The following error has occurred.');          
                                //system.debug(err.getStatusCode() + ': ' + err.getMessage());
                                //system.debug('Project Share fields that affected this error: ' + err.getFields());

                            }
                        }
                    }



                    //insert mapDelegationsToInsert.values();
                }


                if(mapDelegationsToInsert.values().size() > 0){

                    list<delegation__c> listDel = mapDelegationsToInsert.values();
                    Database.SaveResult[] srList = Database.insert(listDel, false);
                    ECO_Service_ErrorLog.logException( listDel, srList, 'ECO_Service_Delegation.handleEscalationExecute - Insert Delegation Audit Log');

                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {

                        } else {

                            for(Database.Error err : sr.getErrors()) {
                                //system.debug('The following error has occurred.');          
                                //system.debug(err.getStatusCode() + ': ' + err.getMessage());
                                //system.debug('Delegation fields that affected this error: ' + err.getFields());

                            }
                        }
                    }



                    //insert mapDelegationsToInsert.values();
                }

                if(mapProcessWorkItemReq.values().size() > 0){

                    list<approval.ProcessWorkItemRequest> lstPWR = mapProcessWorkItemReq.values();
                    Approval.ProcessResult[] lstPR = Approval.process(lstPWR, false);

                    ECO_Service_ErrorLog.logException( lstPWR, lstPR, 'ECO_Service_Delegation.handleEscalationExecute - Recall Workitems');

                    for (Approval.ProcessResult sr : lstPR) {
                        if (sr.isSuccess()) {

                        } else {

                            for(Database.Error err : sr.getErrors()) {
                                //system.debug('The following error has occurred.');          
                                //system.debug(err.getStatusCode() + ': ' + err.getMessage());
                                //system.debug('Delegation fields that affected this error: ' + err.getFields());

                            }
                        }
                    }

                }

                //GET DELEGATE APPROVAL PROCESS SETTING
                ECO_Delegate_Approval_Process_Settings__c CS = ECO_Delegate_Approval_Process_Settings__c.getOrgDefaults();
                
                if(cs.Send_Portal_Messages__c){
                    if(mapPortalMsgToInsert.values().size() > 0){

                        list<PortalMessage__c> listPM = mapPortalMsgToInsert.values();
                        Database.SaveResult[] srList = Database.insert(listPM, false);
                        ECO_Service_ErrorLog.logException( listPM, srList, 'ECO_Service_Delegation.handleEscalationExecute - Insert Portal Messages Audit Log');

                        for (Database.SaveResult sr : srList) {
                            if (sr.isSuccess()) {

                            } else {

                                for(Database.Error err : sr.getErrors()) {
                                    //system.debug('The following error has occurred.');          
                                    //system.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    //system.debug('Portal fields that affected this error: ' + err.getFields());

                                }
                            }
                        }



                        //insert mapDelegationsToInsert.values();
                    }
                }

            }
        }        
    }



    /**
     * Determines if a field exists on a generic SObject
     * NOTE: the hasSObjectField method requires an ALL LOWERCAP name to be passed in. Odd quirk, but it appears to be case sensative
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    public static boolean hasSObjectField(String fieldName, SObject so){
        return so.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName.tolowercase());
    }


    /**
     * Get the list of checks that needs to be performed on each object type
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    public static void obtainCheckList(){
        if(lstCheck == null){
            lstCheck = [select id, Check__c, ProcessAPIName__c, ObjectAPIName__c from ECO_DelegationCheck__c];

            mapCheck = new map<string, ECO_DelegationCheck__c>();

            for(ECO_DelegationCheck__c d: lstCheck){
                if(d.ProcessAPIName__c != null){
                    mapCheck.put(d.Check__c + '-' + d.ObjectAPIName__c +'-'+d.ProcessAPIName__c, d);
                } else {
                    mapCheck.put(d.Check__c + '-' + d.ObjectAPIName__c +'-', d);
                }

            }
        }

    }

    /**
     * Get the amount of time in days between 2 date times
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    public static integer GetElapsedTime(datetime startTime, datetime endTime)
    {
        if(startTime == null || endTime == null)
            return 0;


        Long dt1Long = startTime.getTime();
        Long dt2Long = endTime.getTime();
        
        double milliseconds = dt2Long - dt1Long;
        double seconds = milliseconds / 1000;
        double minutes = seconds / 60;
        double hours = minutes / 60;
        double days = hours / 24;
        integer roundeddays = integer.valueof(days);

        //system.debug('@@@ DEBUG - START DATE: ' + startTime + ' -- END DATE: ' + endTime + ' ---- HOURS: ' + hours + '  DAYS: ' +  days + '  RETURN: ' +  roundeddays );

        //return startTime.date().daysbetween(endTime.date());
        return roundeddays;
    }


    /**
     * Insert delegation audit records
     * Note: due to the potential recursive nature of triggers, the delegation service needs to keep track of 
     * layered execution of the service (due to the service's static nature). This means that delegation records are stored in a 
     * "stack" like fashion.
     *   
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    public static void insertDelegations(list<SObject> lstTargets){

        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_Service_Delegation')) {
            return;
        }


        list<list<Delegation__c>> delLst = ECO_Service_Delegation_Helper.lstofDelegationstoInsert[ECO_Service_Delegation_Helper.lstofDelegationstoInsert.size() -1];


        integer index = 0;

        list<ProjectTeamMember__c> lstPTM = new list<ProjectTeamMember__c>();
        set<id> setProjID = new set<id>();
        set<id> setUserID = new set<id>();

        List<pse__Proj__Share> projectShare = new List<pse__Proj__Share>();


        for(SObject s : lstTargets){

            for(Delegation__c d: delLst[index]){

                d.Record__c = s.id;
                setProjID.add(d.Project__c);

                if(d.olddelegate__c != null){
                    setUserID.add(d.olddelegate__c);
                }
            }

            index++;
        }

        list<contact> lstOldContacts;

        if(setUserID.size() > 0){
            lstOldContacts = [select id, pse__Salesforce_User__c from contact where pse__Salesforce_User__c in: setUserID ];


            if(lstOldContacts.size() >0){
                map<id, id> UserIDToContact = new map<id, id>();

                for(contact c: lstOldContacts){
                    UserIDToContact.put(c.pse__Salesforce_User__c, c.id);
                }

                index = 0;

                for(SObject s : lstTargets){
                    for(Delegation__c d: delLst[index]){

                        if(d.olddelegate__c != null && UserIDToContact.containsKey(d.olddelegate__c)){
                            d.OldDelegateContact__c = UserIDToContact.get(d.olddelegate__c);
                        }
                    }

                    index++;
                }
            }
        }

        /*if(delLst.size() > 0){
            //lstPTM = [select id, Project__c, Contact__c, Contact__r.pse__Salesforce_User__c, ProjectRole__c from ProjectTeamMember__c where Project__c IN: setProjID ];
        }


        map<string, id> ProjectContactToRole = new map<string, id>();

        if(lstPTM.size() > 0){
            for(ProjectTeamMember__c ptm: lstPTM){
                ProjectContactToRole.put((id)ptm.Project__c + '-' + (id)ptm.Contact__r.pse__Salesforce_User__c, ptm.ProjectRole__c);
            }
        }*/

        for(Delegation__c d: ECO_Service_Delegation_Helper.lstDelegationToRecord){
           /* if(ProjectContactToRole.containskey((id)d.Project__c + '-' + (id)d.DelegateUser__c)){
                d.ProjectRole__c = ProjectContactToRole.get((id)d.Project__c + '-' + (id)d.DelegateUser__c);
            }*/

            //system.debug('REASON****' + d.Delegation_Reason__c);

            if(d.NeedsShareRule__c){

                //system.debug('IN SHARE CREATE');
                pse__Proj__Share ps = new pse__Proj__Share();
                ps.AccessLevel = 'Edit';
                ps.ParentId = d.Project__c;
                ps.UserOrGroupId =  d.DelegateUser__c;  
                ps.RowCause = Schema.pse__Proj__Share.RowCause.Delegation__c;                    
                projectShare.add(ps);          
                //system.debug(ps);      
            }

        }

        if(ECO_Service_Delegation_Helper.lstDelegationToRecord.size() > 0){

            try {
                insert ECO_Service_Delegation_Helper.lstDelegationToRecord;
            } catch( Exception e){
                ECO_Service_ErrorLog.logException(e);
            }

            
        }

        ECO_Service_Delegation_Helper.lstofDelegationstoInsert.remove(ECO_Service_Delegation_Helper.lstofDelegationstoInsert.size() -1);

        if(projectShare.size() > 0){
            upsert projectShare;
        }
    }

    /**
     * Retrieve a map of related projects
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    private static map<id, pse__Proj__c> getProjectMap(list<SObject> lstTargets){

        map<id, pse__Proj__c> mapProj;



            set<string> sProjectIds = new set<string>();

            for(SObject s : lstTargets){
                sProjectIds.add((string)s.get('delegateProject__c'));
            }

            mapProj = new map<id, pse__Proj__c>([select id
                                                        ,PnLManager__c
                                                        ,FinanceLead__c
                                                        ,CurrentApprovedRevenueBudget__c
                                                        ,clAECOMProjectReviewCategory__c
                                                        ,CurrencyISOCode
                                                        ,EstimatedContractValue__c
                                                        ,TotalMargin__c
                                                        ,NetServicesRevenue__c
                                                        ,Project_Revenue_Budget__c  
                                                        ,TotalApprovedSubmittedNetMargin__c
                                                        ,TotalApprovedSubmittedATR__c
                                                        ,NetMarginOfNSR__c
                                                        ,TotalForecastApprovedNM__c
                                                        ,TotalForecastApprovedSubmittedNM__c
                                                        ,DifferenceInForecastNM__c
                                                        ,ApprovedSubmittedNetMarginOfNSR__c
                                                        ,TotalForecastSubmittedNSR__c
                                                        ,TotalForecastNSR__c
                                                        ,ChangeInForecastNM__c
                                                        ,CarryingOutOrganization__c
                                                        ,OUID__c
                                                from pse__Proj__c where id in: sProjectIds]);


        return mapProj;

    }

    /**
     * Retrieve a map of related contacts
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    private static map<id, contact> getContactMap(map<id, pse__Proj__c> mapProj){
        
        set<id> sid = new set<id>();

        for(pse__Proj__c p: mapProj.values()){
            if(p.PnLManager__c != null){
                sid.add(p.PnLManager__c);
            }

            if(p.FinanceLead__c != null){
                sid.add(p.FinanceLead__c);
            }            
        }

        map<id, contact> mapContact = new map<id, contact>([select id, pse__Salesforce_User__c from contact where id IN: sid]);


        return mapContact;
    }

    /**
     * Retrieve object label from generic SObject
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    private static string getObjectLabel(Sobject oTarget){
        if(oTarget != null){
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            Schema.SObjectType sobjType = gd.get(getObjectName(oTarget)); 
            return sobjType.getDescribe().getLabel();
        } else {
            return null;
        }       
    }

    /**
     * Retrieve object name from generic SObject
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    private static string getObjectName(Sobject oTarget){
        if(oTarget != null){

            return oTarget.getSObjectType().getDescribe().getName();
        } else {
            return null;
        }
    }

    /**
     * Get delegation custom settings
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    private static list<AECOM_Delegation__c> getCustomSettings(Sobject oTarget){
        string objectTypeName = getObjectName(oTarget);

        list<AECOM_Delegation__c> lstAD = [select id,
                                                Object_Name__c,
                                                Field_API_Name__c, 
                                                Process__c, 
                                                Role__c, 
                                                Escalation__c, 
                                                ProcessAPIName__c, 
                                                FirstStepEscalation__c, 
                                                FirstStepEscalationLock__c, 
                                                PreventDelegateswhenlocked__c 
                                            from AECOM_Delegation__c 
                                            where Object_Name__c=: objectTypeName 
                                                and ForAutoEscalationOnly__c != true];

        return lstAD;
    }

    /**
     * Get related delegates
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    private static map<string, list<Delegate__c>> getDelegates(list<SObject> lstTargets, map<id, pse__Proj__c> projectMap){

        set<id> setUsers = new set<id>();
        set<id> delegators = new set<id>();
        set<string> OUIDs = new set<string>();

        list<AECOM_Delegation__c> lstAD = getCustomSettings(lstTargets[0]);
        id rtKM;
        id rtDe;

        list<RecordType> lstRT = [Select Id, DeveloperName From RecordType where sobjecttype = 'Delegate__c'];

        for(RecordType rt: lstRT){
            if(rt.DeveloperName == 'Key_Roles'){
                rtKM = rt.id;
            } else if (rt.DeveloperName == 'Default'){
                rtDe = rt.id;
            }
        }

        // Get users
        for(SObject s: lstTargets){
            if( s.get('delegateProject__c') != null ){
                
                string ouid = projectMap.get((id)s.get('delegateProject__c')).OUID__c;
                ECODelegationOrgPreference__c Edop = ECODelegationOrgPreference__c.getvalues(ouid);

                if(Edop != null && Edop.UseDefaultDelegation__c){
                    OUIDs.add(ouid);

                } else {

                    // SPOT TO RESPECT FLAG
                    for(AECOM_Delegation__c ad: lstAD){
                        if(s.get(ad.Field_API_Name__c) != null){
                            setUsers.add((id)s.get(ad.Field_API_Name__c));


                            delegators.add(contactMap.get(projectMap.get((id)s.get('delegateProject__c')).PnLManager__c).pse__Salesforce_User__c);

                            if(contactMap.get(projectMap.get((id)s.get('delegateProject__c')).FinanceLead__c) != null){
                                delegators.add(contactMap.get(projectMap.get((id)s.get('delegateProject__c')).FinanceLead__c).pse__Salesforce_User__c);
                            }
                            
                        }
                    }
                }
            }
        }  



        list<Delegate__c> lstDelegates = [select id
                                                , Delegate__c, Delegate__r.pse__Salesforce_User__c
                                                , Delegator__c, Delegator__r.pse__Salesforce_User__c 
                                                , Agreement_Amount_estimated__c
                                                , Project_Revenue_Budget__c
                                                , Project_Net_Margin_Value__c
                                                , Project_Net_Margin_age_of_NSR__c
                                                , age_Change_in_Forecast_Net_Margin__c
                                                , Value_change_in_Forecast_Net_Margin__c
                                                , Agreement_Amount_estimated_Bypass__c
                                                , Agreement_Amount_estimated_Bypass_lt__c 
                                                , Agreement_Amount_estimated_lt__c
                                                , Project_Revenue_Budget_Bypass__c
                                                , Project_Revenue_Budget_Bypass_lt__c
                                                , Project_Revenue_Budget_lt__c
                                                , Project_Net_Margin_Value_Bypass__c
                                                , Project_Net_Margin_Value_lt__c
                                                , Project_Net_Margin_Value_Bypass_lt__c
                                                , Project_Net_Margin_age_of_NSR_lt__c
                                                , Project_Net_Margin_of_NSR_Bypass_lt__c
                                                , age_Change_in_Forecast_Net_Margin_lt__c
                                                , age_Change_in_Forecast_Net_Margin_Bypass__c
                                                , age_Change_in_Forecast_Net_Margin_Byp_lt__c
                                                , Value_change_in_Forecast_Net_Margin_lt__c
                                                , Value_change_Forecast_Nt_Margn_Byps_lt__c
                                                , Value_change_in_Forecast_Net_Margin_Byps__c
                                                , Project_Review_Category_C_0__c
                                                , Project_Review_Category_C_1__c
                                                , Project_Review_Category_C_2__c
                                                , Project_Review_Category_C_3__c
                                                , Project_Review_Category_C_4__c
                                                , Backlog_Value_Bypass__c
                                                , Backlog_Value__c
                                                , Backlog_Value_lt__c
                                                , Backlog_Value_Bypass_lt__c
                                                ,Project_Review_Category_C_0_Bypass__c
                                                ,Project_Review_Category_C_1_Bypass__c
                                                ,Project_Review_Category_C_2_Bypass__c
                                                ,Project_Review_Category_C_3_Bypass__c
                                                ,Project_Review_Category_C_4_Bypass__c
                                                ,Project_Net_Margin_age_of_NSR_Bypass__c
                                                ,Allowed_Organizations__c
                                                ,Start_Date__c
                                                ,End_Date__c
                                                ,Key_Member_Role__c
                                                ,CurrencyIsoCode
                                                ,OUID__c


                                            from Delegate__c 
                                            where ((Delegate__r.pse__Salesforce_User__c IN: setUsers 
                                                and Delegator__r.pse__Salesforce_User__c IN: delegators 
                                                and RecordTypeid =: rtKM
                                                and Approval_Status__c = 'Approved')
                                                or OUID__c IN: OUIDs)
                                                and Start_Date__c <=: datetime.now().dateGMT() 
                                                and (End_Date__c = null or End_Date__c >=: datetime.now().dateGMT())
                                                
                                                ];

        //system.debug('DEBUG****: DELEGATE SEARCH: ' + lstDelegates);

        map<string, list<Delegate__c>> mapProjectMapToDelegate = new map<string, list<Delegate__c>>();

        for(Delegate__c d:lstDelegates){
            string skey ='';

            if(d.OUID__c != null){
                skey += d.OUID__c; 
            } else {
                skey += (id)d.Delegator__c; 
                skey += (id)d.Delegate__r.pse__Salesforce_User__c;                
            }

            skey += (string)d.Key_Member_Role__c;

            //system.debug('DEBUG****: DELEGATE KEY CREATED: ' + skey);

            if(!mapProjectMapToDelegate.containskey(skey)){
                mapProjectMapToDelegate.put( skey, new list<Delegate__c>());
            }

            mapProjectMapToDelegate.get(skey).add(d);
            //mapProjectMapToDelegate.put( skey, d);
        }

        return mapProjectMapToDelegate;
    }
    


    /**
     * Custom method to add comma's for message string manipulation 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    private static string addcomma(string slimit){
        if(slimit.length() > 0){
            return ', ';
        }

        return '';
    }


    /**
     * Custom method to create a zero/false based delegate that will trigge limits
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    public static Delegate__c createZeroDelegate(){
        Delegate__c d = new Delegate__c();

        d.CurrencyIsoCode = 'USD';
        d.age_Change_in_Forecast_Net_Margin_lt__c = 0;
        d.age_Change_in_Forecast_Net_Margin__c = 0;
        d.Agreement_Amount_estimated_lt__c = 0;
        d.Agreement_Amount_estimated__c = 0;
        d.Backlog_Value_lt__c = 0;
        d.Backlog_Value__c = 0;
        d.Project_Net_Margin_age_of_NSR_lt__c = 0;
        d.Project_Net_Margin_age_of_NSR__c = 0;
        d.Project_Net_Margin_Value_lt__c = 0;
        d.Project_Net_Margin_Value__c = 0;
        d.Project_Revenue_Budget_lt__c = 0;
        d.Project_Revenue_Budget__c = 0;
        d.Value_change_in_Forecast_Net_Margin_lt__c = 0;
        d.Value_change_in_Forecast_Net_Margin__c = 0;


        d.Project_Review_Category_C_0__c = false;
        d.Project_Review_Category_C_1__c = false;
        d.Project_Review_Category_C_2__c = false;
        d.Project_Review_Category_C_3__c = false;
        d.Project_Review_Category_C_4__c = false;

        d.age_Change_in_Forecast_Net_Margin_Byp_lt__c = false;
        d.age_Change_in_Forecast_Net_Margin_Bypass__c = false;
        d.Agreement_Amount_estimated_Bypass_lt__c = false;
        d.Agreement_Amount_estimated_Bypass__c = false;
        d.Project_Net_Margin_of_NSR_Bypass_lt__c = false;
        d.Project_Net_Margin_age_of_NSR_Bypass__c = false;
        d.Project_Net_Margin_Value_Bypass_lt__c = false;
        d.Project_Net_Margin_Value_Bypass__c = false;
        d.Project_Revenue_Budget_Bypass_lt__c = false;
        d.Project_Revenue_Budget_Bypass__c = false;
        d.Value_change_Forecast_Nt_Margn_Byps_lt__c = false;
        d.Value_change_in_Forecast_Net_Margin_Byps__c = false;
        d.Backlog_Value_Bypass_lt__c = false;
        d.Backlog_Value_Bypass__c = false;
        d.Project_Review_Category_C_0_Bypass__c = false;
        d.Project_Review_Category_C_1_Bypass__c = false;
        d.Project_Review_Category_C_2_Bypass__c = false;
        d.Project_Review_Category_C_4_Bypass__c = false;
        d.Project_Review_Category_C_3_Bypass__c = false;


        return d;
    }


    /**
     * Determines if a process has violated a delegation limit that will require escalation
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    private static list<change> checkLimits(list<change> lstChanges){

        //system.debug('DELEGATION SERVICE: Starting Limit Checks');

        map<id, decimal> mProjToAgreementAmount;
        map<id, decimal> mProjToITD;


        list<change> lstCheckableChanges = new  list<change>();
        list<change> lstNeedsEscalaction = new list<change>();
        list<change> listOriginalBeforeEscalation = new list<change>();

        set<id> setProjIds = new set<id>();

        map<id, string> projToCurr = new map<id, string>();


        for(change c: lstChanges){
            if(c.userDelegate != null){
                setProjIds.add(c.relProj.id);
                lstCheckableChanges.add(c);
                projToCurr.put((id)c.relProj.id, c.relProj.CurrencyISOCode);
            } else {

            }
        }

        obtainCheckList();

        // if no related projects are found, then get out of here
        if(setProjIds.size() == 0){

            //system.debug('DELEGATION SERVICE: Cannot find related project to the records being inserted. Terminating Limit Check - Potentially due to no delegate found');

            return new list<change>();
        }        


        string objectName = getObjectName(lstChanges[0].oSObject);

        boolean bHasProcess = false;
        if(hasSObjectField('process__c', lstChanges[0].oSObject)){
            bHasProcess = true;
        }


        // Get agreement data ******************************************************

        mProjToAgreementAmount = new  map<id, decimal>();

        /*AggregateResult[] groupedResults = [SELECT Project__c
                                                    ,SUM(Agreement__r.AgreementAmountEstimated__c)amount 
                                                FROM ProjectAgreement__c 
                                                WHERE Project__c IN:setProjIds AND 
                                                    (Agreement__r.RecordType.DeveloperName = 'Prime' OR Agreement__r.RecordType.DeveloperName = 'PrimeTaskOrder') 
                                                GROUP BY Project__c];


        for (AggregateResult ar : groupedResults)  {
            mProjToAgreementAmount.put((id)ar.get('Project__c'),  (decimal)ar.get('amount'));
        }*/


        list<ProjectAgreement__c> lstAgreements = [select id, Project__c, Agreement__r.AgreementAmountEstimated__c, Agreement__r.CurrencyISOCode from ProjectAgreement__c where Project__c IN:setProjIds AND 
                                                    (Agreement__r.RecordType.DeveloperName = 'Prime' OR Agreement__r.RecordType.DeveloperName = 'PrimeTaskOrder') ];


        for (ProjectAgreement__c pa : lstAgreements)  {
            if(mProjToAgreementAmount.containsKey((id)pa.Project__c)){
                decimal amount = 0;
                if(pa.Agreement__r.AgreementAmountEstimated__c != null){
                    amount = mProjToAgreementAmount.get((id)pa.Project__c) + ECO_Service_ExchangeRate.getPlannedExchangeRate(pa.Agreement__r.CurrencyISOCode, projToCurr.get((id)pa.Project__c))*pa.Agreement__r.AgreementAmountEstimated__c;
                }
                mProjToAgreementAmount.put((id)pa.Project__c, amount);
            } else {
                decimal amount = 0;
                if(pa.Agreement__r.AgreementAmountEstimated__c != null){
                    amount = ECO_Service_ExchangeRate.getPlannedExchangeRate(pa.Agreement__r.CurrencyISOCode, projToCurr.get((id)pa.Project__c))*pa.Agreement__r.AgreementAmountEstimated__c;
                }
                mProjToAgreementAmount.put((id)pa.Project__c, amount);
            }
        }



        //*********************************************************

        mProjToITD = new  map<id, decimal>();

        // Get Backlog Value******************************************************
        /*AggregateResult[] groupedResultsITD = [select ProjectNumber__c  , sum(Amount__c) totalRevenue from Revenue__c where ProjectNumber__c in :setProjIds and GLDate__c <= TODAY GROUP BY ProjectNumber__c];

        for (AggregateResult ar : groupedResultsITD)  {
            mProjToITD.put((id)ar.get('ProjectNumber__c'), (decimal)ar.get('totalRevenue'));
        }*/

        //*********************************************************

        list<Revenue__c> lstRevenue = [select id, ProjectNumber__c, Amount__c, GLDate__c, CurrencyISOCode from Revenue__c where ProjectNumber__c in :setProjIds and GLDate__c <= TODAY];

        for (Revenue__c r : lstRevenue)  {

            //system.debug('DELEGATION SERVICE: EXCHANGE RATE - ' + r.CurrencyISOCode + ' TO ' + projToCurr.get((id)r.ProjectNumber__c) + ' ON ' + r.GLDate__c + ' -- ' + ECO_Service_ExchangeRate.getPlannedExchangeRate(r.CurrencyISOCode, projToCurr.get((id)r.ProjectNumber__c)));

            if(mProjToITD.containsKey((id)r.ProjectNumber__c)){
                decimal amount = mProjToITD.get((id)r.ProjectNumber__c) + ECO_Service_ExchangeRate.getPlannedExchangeRate(r.CurrencyISOCode, projToCurr.get((id)r.ProjectNumber__c))*r.Amount__c;
                mProjToITD.put((id)r.ProjectNumber__c, amount);
            } else {
                decimal amount = ECO_Service_ExchangeRate.getPlannedExchangeRate(r.CurrencyISOCode, projToCurr.get((id)r.ProjectNumber__c))*r.Amount__c;
                mProjToITD.put((id)r.ProjectNumber__c, amount);
            }
        }        



        for(change c: lstCheckableChanges){

            //system.debug('DELEGATION SERVICE: Checking Delegation limits of - ' + c.userDelegate.id + ' against project - ' + c.relProj.id);

            string sProcessName = '';

            if(bHasProcess){
                if((string)c.oSObject.get('process__c') != null){
                    sProcessName = (string)c.oSObject.get('process__c');
                }
            }
            

            //**** CONVERSION TO PROJECT CURRENCY

            //decimal xRate = ECO_Service_ExchangeRate.getPlannedExchangeRate('NZD', c.relProj.CurrencyISOCode);
            decimal xRate = ECO_Service_ExchangeRate.getPlannedExchangeRate(c.userDelegate.CurrencyIsoCode, c.relProj.CurrencyISOCode);
            string xChangemsg = ECO_Service_ExchangeRate.getPlannedExchangeRateStringForMessage(c.userDelegate.CurrencyIsoCode, c.relProj.CurrencyISOCode);

            string DelegateISO = c.userDelegate.CurrencyIsoCode;
            string ProjectISO = c.relProj.CurrencyIsoCode;



            decimal convertedDecimalBudget = c.relProj.Project_Revenue_Budget__c;
            decimal convertedDecimalBudgetPreExecution = c.relProj.EstimatedContractValue__c;
            decimal convertedAgreementAmountEstimated = c.userDelegate.Agreement_Amount_estimated__c*xRate;
            decimal convertedAgreementAmountEstimatedLT = c.userDelegate.Agreement_Amount_estimated_lt__c*xRate;
            decimal convertedUserDelegateProjectRevenueBudget = c.userDelegate.Project_Revenue_Budget__c*xRate;
            decimal convertedUserDelegateProjectRevenueBudgetLT = c.userDelegate.Project_Revenue_Budget_lt__c*xRate;
            decimal convertedUserDelegateProjectNetMarginValue = c.userDelegate.Project_Net_Margin_Value__c*xRate;
            decimal convertedUserDelegateProjectNetMarginValueLT = c.userDelegate.Project_Net_Margin_Value_lt__c*xRate;
            decimal convertedUserDelegateForecastNM = c.userDelegate.Value_change_in_Forecast_Net_Margin__c*xRate;
            decimal convertedUserDelegateForecastNMLT = c.userDelegate.Value_change_in_Forecast_Net_Margin_lt__c*xRate;
            decimal TotalApprovedSubmittedNetMargin = c.relProj.TotalApprovedSubmittedNetMargin__c;
            decimal TotalApprovedSubmittedATR = c.relProj.TotalApprovedSubmittedATR__c;
            decimal ApprovedSubmittedNetMarginOfNSR = c.relProj.ApprovedSubmittedNetMarginOfNSR__c;
            decimal NetMarginOfNSR = c.relProj.NetMarginOfNSR__c;
            decimal TotalForecastApprovedNM = c.relProj.TotalForecastApprovedNM__c;
            decimal TotalForecastApprovedSubmittedNM = c.relProj.TotalForecastApprovedSubmittedNM__c;
            decimal DifferenceInForecastNM = c.relProj.DifferenceInForecastNM__c;
            decimal TotalMargin = c.relProj.TotalMargin__c;
            decimal convertedUserBV = c.userDelegate.Backlog_Value__c*xRate;
            decimal convertedUserBVLT = c.userDelegate.Backlog_Value_lt__c*xRate;
            decimal TotalForecastSubmittedNSR = c.relProj.TotalForecastSubmittedNSR__c;
            decimal TotalForecastNSR = c.relProj.TotalForecastNSR__c;
            decimal ChangeInForecastNM = c.relProj.ChangeInForecastNM__c;


            decimal agreementAmount = null;
            if(mProjToAgreementAmount.containskey(c.relProj.id)){
                //agreementAmount = ECO_Service_ExchangeRate.convertFromOrgCurrency(c.relProj.CurrencyISOCode, mProjToAgreementAmount.get(c.relProj.id), date.today());
                agreementAmount = mProjToAgreementAmount.get(c.relProj.id);
            }


            //**** ACTUAL CHECK


            if(mapCheck.containskey('Agreement Amount' + '-'  + objectName + '-' + sProcessName) ){

                //system.debug('DELEGATION SERVICE: AGREEMENT CHECK***************');

                // check Agreement Amount

                if(agreementAmount == null){
                    //system.debug('DELEGATION SERVICE: No Agreement Amounts Found***************');
                } else {

                    //system.debug('DELEGATION SERVICE: Agreement Amount ' + agreementAmount.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedAgreementAmountEstimated.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Agreement_Amount_estimated__c + ' ' + DelegateISO + ')' );

                    if(agreementAmount != null && 
                        agreementAmount > convertedAgreementAmountEstimated){
                        
                        //system.debug('DELEGATION SERVICE: BREACHED');
                        string reason = 'Agreement Amount: ' + agreementAmount.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedAgreementAmountEstimated.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Agreement_Amount_estimated__c + ' ' + DelegateISO + ')';

                        if(c.userDelegate.Agreement_Amount_estimated_Bypass__c){

                            //system.debug('DELEGATION SERVICE: Agreement Check Bypass > set to TRUE');

                            c.limitChangeReason +=  addcomma(c.limitChangeReason) + reason;
                            //c.limitChangeReason +=  addcomma(c.limitChangeReason) + 'Agreement Amount: ' + agreementAmount + ' > than limit ' + convertedAgreementAmountEstimated + '(Original agree: ' + mProjToAgreementAmount.get(c.relProj.id) + ' Original Limit: ' + c.userDelegate.Agreement_Amount_estimated__c + ' Rate: ' +  xRate  + ')';
                        } else {

                            //system.debug('DELEGATION SERVICE: Agreement Check Bypass > set to FALSE');

                            c.limitBypassReason  +=  addcomma(c.limitBypassReason) + reason;
                            c.limitViolationWithNoBypass = true;
                        }
                    } else {
                        //system.debug('DELEGATION SERVICE: PASS');
                    }


                    //system.debug('DELEGATION SERVICE: Agreement Amount ' + agreementAmount.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedAgreementAmountEstimatedLT.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Agreement_Amount_estimated_lt__c + ' ' + DelegateISO + ')');

                    // check Agreement Amount
                    if(agreementAmount != null && 
                        agreementAmount < convertedAgreementAmountEstimatedLT){
                        
                        //system.debug('DELEGATION SERVICE: BREACHED');

                        string reason = 'Agreement Amount: ' + agreementAmount.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedAgreementAmountEstimatedLT.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Agreement_Amount_estimated_lt__c + ' ' + DelegateISO + ')';

                        if(c.userDelegate.Agreement_Amount_estimated_Bypass_lt__c){

                            //system.debug('DELEGATION SERVICE: Agreement Check Bypass < set to TRUE');

                            c.limitChangeReason +=  addcomma(c.limitChangeReason) + reason;
                            //c.limitChangeReason +=  addcomma(c.limitChangeReason) + 'Agreement Amount: ' + agreementAmount + ' > than limit ' + convertedAgreementAmountEstimated + '(Original agree: ' + mProjToAgreementAmount.get(c.relProj.id) + ' Original Limit: ' + c.userDelegate.Agreement_Amount_estimated__c + ' Rate: ' +  xRate  + ')';
                        } else {

                            //system.debug('DELEGATION SERVICE: Agreement Check Bypass < set to FALSE');

                            c.limitBypassReason  +=  addcomma(c.limitBypassReason) + reason;
                            c.limitViolationWithNoBypass = true;
                        }
                    } else {
                        //system.debug('DELEGATION SERVICE: PASS');
                    }
                }

            }

            if(mapCheck.containskey('Project Revenue Budget' + '-'  + objectName + '-' + sProcessName) ){

                //system.debug('DELEGATION SERVICE: PROJECT REVENUE CHECK***************');

                //system.debug('DELEGATION SERVICE: Project Revenue Budget: ' + convertedDecimalBudget.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedUserDelegateProjectRevenueBudget.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Revenue_Budget__c + ' ' + DelegateISO + ')');

                // check Revenue Budget >
                if( convertedDecimalBudget > convertedUserDelegateProjectRevenueBudget){

                    //system.debug('DELEGATION SERVICE: BREACHED');

                    string reason = 'Project Revenue Budget: ' + convertedDecimalBudget.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedUserDelegateProjectRevenueBudget.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Revenue_Budget__c + ' ' + DelegateISO + ')';

                    if(c.userDelegate.Project_Revenue_Budget_Bypass__c ){   

                        //system.debug('DELEGATION SERVICE: Project Revenue Budget Bypass > set to TRUE');  
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Revenue Budget Bypass > set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason)  + reason;
                        c.limitViolationWithNoBypass = true;
                    }
                } else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }


                //system.debug('DELEGATION SERVICE: Project Revenue Budget: ' + convertedDecimalBudget.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedUserDelegateProjectRevenueBudgetLT.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Revenue_Budget_lt__c + ' ' + DelegateISO + ')');

                // check Revenue Budget <
                if( convertedDecimalBudget < convertedUserDelegateProjectRevenueBudgetLT){
                    
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Revenue Budget: ' + convertedDecimalBudget.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedUserDelegateProjectRevenueBudgetLT.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Revenue_Budget_lt__c + ' ' + DelegateISO + ')';

                    if(c.userDelegate.Project_Revenue_Budget_Bypass_lt__c){    
                        //system.debug('DELEGATION SERVICE: Project Revenue Budget Bypass < set to TRUE');   
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Revenue Budget Bypass < set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }
                } else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }
            }

            if(mapCheck.containskey('Project Revenue Budget Pre-Execution' + '-'  + objectName + '-' + sProcessName) ){

                //system.debug('DELEGATION SERVICE: PROJECT REVENUE CHECK PRE-EXECUTION***************');


                //system.debug('DEBUG@@@ ' + convertedDecimalBudgetPreExecution.setscale(2));
                //system.debug('DEBUG@@@ ' + convertedUserDelegateProjectRevenueBudget.setscale(2));
                //system.debug('DEBUG@@@ ' + c.userDelegate.Project_Revenue_Budget__c);
                //system.debug('DELEGATION SERVICE: Project Revenue Budget Pre-Execution: ' + convertedDecimalBudgetPreExecution.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedUserDelegateProjectRevenueBudget.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Revenue_Budget__c + ' ' + DelegateISO + ')');

                // check Revenue Budget >
                if( convertedDecimalBudgetPreExecution > convertedUserDelegateProjectRevenueBudget){

                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Revenue Budget Pre-Execution: ' + convertedDecimalBudgetPreExecution.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedUserDelegateProjectRevenueBudget.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Revenue_Budget__c + ' ' + DelegateISO + ')';

                    if(c.userDelegate.Project_Revenue_Budget_Bypass__c ){   

                        //system.debug('DELEGATION SERVICE: Project Revenue Budget Pre-Execution: Bypass > set to TRUE');  
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Revenue Budget Pre-Execution: Bypass > set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason)  + reason;
                        c.limitViolationWithNoBypass = true;
                    }
                } else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }

                //system.debug('DELEGATION SERVICE: Project Revenue Budget Pre-Execution: ' + convertedDecimalBudgetPreExecution.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedUserDelegateProjectRevenueBudgetLT.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Revenue_Budget_lt__c + ' ' + DelegateISO + ')');

                // check Revenue Budget <
                if( convertedDecimalBudgetPreExecution < convertedUserDelegateProjectRevenueBudgetLT){
                    
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Revenue Budget Pre-Execution: ' + convertedDecimalBudgetPreExecution.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedUserDelegateProjectRevenueBudgetLT.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Revenue_Budget_lt__c + ' ' + DelegateISO + ')';

                    if(c.userDelegate.Project_Revenue_Budget_Bypass_lt__c){    
                        //system.debug('DELEGATION SERVICE: Project Revenue Budget Pre-Execution: Bypass < set to TRUE');   
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Revenue Budget Pre-Execution: Bypass < set to FALSE');  
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }
                } else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }
            }



            if(mapCheck.containskey('Project Net Margin' + '-'  + objectName + '-' + sProcessName) ){

                //system.debug('DELEGATION SERVICE: PROJECT NET MARGIN CHECK***************');

                //system.debug('DELEGATION SERVICE: Project Net Margin: ' + TotalApprovedSubmittedNetMargin.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedUserDelegateProjectNetMarginValue.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Net_Margin_Value__c + ' ' + DelegateISO + ')');

                // check net margin limit >
                // NM has been aggregated and should be in the default org currency
                if(TotalApprovedSubmittedNetMargin > convertedUserDelegateProjectNetMarginValue){
                    
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Net Margin: ' + TotalApprovedSubmittedNetMargin.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedUserDelegateProjectNetMarginValue.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Net_Margin_Value__c + ' ' + DelegateISO + ')';

                    if(c.userDelegate.Project_Net_Margin_Value_Bypass__c){
                        //system.debug('DELEGATION SERVICE: Project Net Margin: Bypass > set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Net Margin: Bypass > set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }             
                } else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }          

                // check net margin limit <
                // NM has been aggregated and should be in the default org currency
                //system.debug('DELEGATION SERVICE: Project Net Margin: ' + TotalApprovedSubmittedNetMargin.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedUserDelegateProjectNetMarginValueLT.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Net_Margin_Value_lt__c + ' ' + DelegateISO + ')');

                if(TotalApprovedSubmittedNetMargin < convertedUserDelegateProjectNetMarginValueLT){
                    
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Net Margin: ' + TotalApprovedSubmittedNetMargin.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedUserDelegateProjectNetMarginValueLT.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Net_Margin_Value_lt__c + ' ' + DelegateISO + ')';

                    if(c.userDelegate.Project_Net_Margin_Value_Bypass_lt__c){

                        //system.debug('DELEGATION SERVICE: Project Net Margin: Bypass < set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Net Margin: Bypass < set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }  
                } else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }
            }

            if(mapCheck.containskey('Project Net Margin Pre-Execution' + '-'  + objectName + '-' + sProcessName) ){

                //system.debug('DELEGATION SERVICE: PROJECT NET MARGIN CHECK PRE-EXECUTION***************');

                // check net margin limit >
                // NM has been aggregated and should be in the default org currency

                //system.debug('DELEGATION SERVICE: Project Net Margin Pre-Execution: ' + TotalMargin.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedUserDelegateProjectNetMarginValue.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Net_Margin_Value__c + ' ' + DelegateISO + ')');

                if(TotalMargin > convertedUserDelegateProjectNetMarginValue){
                    
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Net Margin Pre-Execution: ' + TotalMargin.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedUserDelegateProjectNetMarginValue.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Net_Margin_Value__c + ' ' + DelegateISO + ')';

                    if(c.userDelegate.Project_Net_Margin_Value_Bypass__c){
                        //system.debug('DELEGATION SERVICE: Project Net Margin Pre-Execution: Bypass > set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Net Margin Pre-Execution: Bypass > set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }             
                } else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }          

                // check net margin limit <
                // NM has been aggregated and should be in the default org currency

                //system.debug('DELEGATION SERVICE: Project Net Margin Pre-Execution: ' + TotalMargin.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedUserDelegateProjectNetMarginValueLT + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Net_Margin_Value_lt__c + ' ' + DelegateISO + ')');

                if(TotalMargin < convertedUserDelegateProjectNetMarginValueLT){
                    
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Net Margin Pre-Execution: ' + TotalMargin.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedUserDelegateProjectNetMarginValueLT + ' ' + ProjectISO + ' (' + c.userDelegate.Project_Net_Margin_Value_lt__c + ' ' + DelegateISO + ')';

                    if(c.userDelegate.Project_Net_Margin_Value_Bypass_lt__c){
                        //system.debug('DELEGATION SERVICE: Project Net Margin Pre-Execution: Bypass < set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Net Margin Pre-Execution: Bypass < set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }  
                }  else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }  
            }



            if(mapCheck.containskey('Project Net Margin NSR' + '-'  + objectName + '-' + sProcessName) ){

                //system.debug('DELEGATION SERVICE: PROJECT NET MARGIN NSR CHECK***************');

                //system.debug('DELEGATION SERVICE: Project Net Margin NSR %: ' + ApprovedSubmittedNetMarginOfNSR.setscale(2) + ' > than limit ' + c.userDelegate.Project_Net_Margin_age_of_NSR__c);

                // check net margin NSR % >
                if(ApprovedSubmittedNetMarginOfNSR > c.userDelegate.Project_Net_Margin_age_of_NSR__c){
                    
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Net Margin NSR %: ' + ApprovedSubmittedNetMarginOfNSR.setscale(2) + ' > than limit ' + c.userDelegate.Project_Net_Margin_age_of_NSR__c;

                    if(c.userDelegate.Project_Net_Margin_age_of_NSR_Bypass__c){
                        //system.debug('DELEGATION SERVICE: Project Net Margin NSR % Bypass > set to TRUE');

                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Net Margin NSR % Bypass > set to FALSE');

                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }  
                }  else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }           


                //system.debug('DELEGATION SERVICE: Project Net Margin NSR %: ' + ApprovedSubmittedNetMarginOfNSR.setscale(2) + ' < than limit ' + c.userDelegate.Project_Net_Margin_age_of_NSR_lt__c);
                // check net margin NSR % <
                if(ApprovedSubmittedNetMarginOfNSR < c.userDelegate.Project_Net_Margin_age_of_NSR_lt__c){
                    
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Net Margin NSR %: ' + ApprovedSubmittedNetMarginOfNSR.setscale(2) + ' < than limit ' + c.userDelegate.Project_Net_Margin_age_of_NSR_lt__c;

                    if(c.userDelegate.Project_Net_Margin_of_NSR_Bypass_lt__c){
                        //system.debug('DELEGATION SERVICE: Project Net Margin NSR % Bypass < set to TRUE');

                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Net Margin NSR % Bypass < set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }  
                }  else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }       
            }    


            if(mapCheck.containskey('Project Net Margin NSR Pre-Execution' + '-'  + objectName + '-' + sProcessName) ){

                //system.debug('DELEGATION SERVICE: PROJECT NET MARGIN NSR CHECK PRE-EXECUTION***************');

                //system.debug('DELEGATION SERVICE: Project Net Margin NSR % Pre-Execution: ' + NetMarginOfNSR.setscale(2) + ' > than limit ' + c.userDelegate.Project_Net_Margin_age_of_NSR__c);

                // check net margin NSR % >
                if(NetMarginOfNSR > c.userDelegate.Project_Net_Margin_age_of_NSR__c){
                    
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Net Margin NSR % Pre-Execution: ' + NetMarginOfNSR.setscale(2) + ' > than limit ' + c.userDelegate.Project_Net_Margin_age_of_NSR__c;

                    if(c.userDelegate.Project_Net_Margin_age_of_NSR_Bypass__c){

                        //system.debug('DELEGATION SERVICE: Project Net Margin NSR % Bypass Pre-Execution > set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {

                        //system.debug('DELEGATION SERVICE: Project Net Margin NSR % Bypass Pre-Execution > set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }  
                }  else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }           

                //system.debug('DELEGATION SERVICE: Project Net Margin NSR %: Pre-Execution: ' + NetMarginOfNSR.setscale(2) + ' < than limit ' + c.userDelegate.Project_Net_Margin_age_of_NSR_lt__c);
                // check net margin NSR % <
                if(NetMarginOfNSR < c.userDelegate.Project_Net_Margin_age_of_NSR_lt__c){
                    
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Net Margin NSR %: Pre-Execution: ' + NetMarginOfNSR.setscale(2) + ' < than limit ' + c.userDelegate.Project_Net_Margin_age_of_NSR_lt__c;

                    if(c.userDelegate.Project_Net_Margin_of_NSR_Bypass_lt__c){

                        //system.debug('DELEGATION SERVICE: Project Net Margin NSR % Bypass Pre-Execution < set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {

                        //system.debug('DELEGATION SERVICE: Project Net Margin NSR % Bypass Pre-Execution < set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }  
                }  else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }     
            }




            if(mapCheck.containskey('% Change in Forecast Net Margin' + '-'  + objectName + '-' + sProcessName) ){

                //system.debug('DELEGATION SERVICE: % CHANGE FORECAST NET MARGIN CHECK***************');

                //system.debug('DELEGATION SERVICE: Project % Change in Forecast Net Margin: ' + changeInForecastNM.setscale(2) + ' > than limit ' + c.userDelegate.age_Change_in_Forecast_Net_Margin__c.setscale(2));

                // check % change in Forecast Net Margin >
                if(changeInForecastNM > c.userDelegate.age_Change_in_Forecast_Net_Margin__c){
                    
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project % Change in Forecast Net Margin: ' + changeInForecastNM.setscale(2) + ' > than limit ' + c.userDelegate.age_Change_in_Forecast_Net_Margin__c.setscale(2);

                    if(c.userDelegate.age_Change_in_Forecast_Net_Margin_Bypass__c){

                        //system.debug('DELEGATION SERVICE: Project % Change in Forecast Net Margin Bypass > set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason; 
                    } else {

                        //system.debug('DELEGATION SERVICE: Project % Change in Forecast Net Margin Bypass > set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason; 
                        c.limitViolationWithNoBypass = true;
                    }            
                }  else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }   


                //system.debug('DELEGATION SERVICE: Project % Change in Forecast Net Margin: ' + changeInForecastNM.setscale(2) + ' < than limit ' + c.userDelegate.age_Change_in_Forecast_Net_Margin_lt__c);

                // check % change in Forecast Net Margin <
                if(changeInForecastNM < c.userDelegate.age_Change_in_Forecast_Net_Margin_lt__c){
                    
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project % Change in Forecast Net Margin: ' + changeInForecastNM.setscale(2) + ' < than limit ' + c.userDelegate.age_Change_in_Forecast_Net_Margin_lt__c;

                    if(c.userDelegate.age_Change_in_Forecast_Net_Margin_Byp_lt__c){

                        //system.debug('DELEGATION SERVICE: Project % Change in Forecast Net Margin Bypass < set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project % Change in Forecast Net Margin Bypass < set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    } 
                }  else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }    
            }


            if(mapCheck.containskey('Value Change in Forecast Net Margin' + '-'  + objectName + '-' + sProcessName) ){

                //system.debug('DELEGATION SERVICE: PROJECT FORECAST NET MARGIN CHECK***************');

                //system.debug('DELEGATION SERVICE: Project Value Change in Forecast Net Margin: ' + DifferenceInForecastNM.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedUserDelegateForecastNM.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Value_change_in_Forecast_Net_Margin__c + ' ' + DelegateISO + ')');

                // check value change in Forecast Net Margin >=
                if(DifferenceInForecastNM > convertedUserDelegateForecastNM){

                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Value Change in Forecast Net Margin: ' + DifferenceInForecastNM.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedUserDelegateForecastNM.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Value_change_in_Forecast_Net_Margin__c + ' ' + DelegateISO + ')';

                    if(c.userDelegate.Value_change_in_Forecast_Net_Margin_Byps__c){

                        //system.debug('DELEGATION SERVICE: Project Value Change in Forecast Net Margin Bypass > set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {

                        //system.debug('DELEGATION SERVICE: Project Value Change in Forecast Net Margin Bypass > set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    } 
                } else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }       

                // check value change in Forecast Net Margin <=

                //system.debug('Project Value Change in Forecast Net Margin: ' + DifferenceInForecastNM.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedUserDelegateForecastNMLT.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Value_change_in_Forecast_Net_Margin_lt__c + ' ' + DelegateISO + ')');
                if(DifferenceInForecastNM < convertedUserDelegateForecastNMLT){

                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Project Value Change in Forecast Net Margin: ' + DifferenceInForecastNM.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedUserDelegateForecastNMLT.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Value_change_in_Forecast_Net_Margin_lt__c + ' ' + DelegateISO + ')';
                    
                    if(c.userDelegate.Value_change_Forecast_Nt_Margn_Byps_lt__c){

                        //system.debug('DELEGATION SERVICE: Project Value Change in Forecast Net Margin Bypass < set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Value Change in Forecast Net Margin Bypass < set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    } 
                } else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }         
            }
        

            // Check Backlog Value
            ////system.debug('STRING CHECK:' + 'Backlog' + '-'  + objectName + '-' + sProcessName);
            if(mapCheck.containskey('Backlog' + '-'  + objectName + '-' + sProcessName) ){

                //system.debug('DELEGATION SERVICE: PROJECT BACKLOG CHECK***************');
                



                decimal ITD = 0;
                if(mProjToITD.containskey(c.relProj.id)){
                    ITD = mProjToITD.get(c.relProj.id);
                }

                decimal backlog = c.relProj.Project_Revenue_Budget__c - ITD;
                //backlog = ECO_Service_ExchangeRate.convertFromOrgCurrency(c.relProj.CurrencyISOCode, backlog, date.today());

                //system.debug('DELEGATION SERVICE: Backlog Amount: ' + backlog.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedUserBV.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Backlog_Value__c + ' ' + DelegateISO + ')');
                if(backlog > convertedUserBV){
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Backlog Amount: ' + backlog.setscale(2) + ' ' + ProjectISO + ' > than limit ' + convertedUserBV.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Backlog_Value__c + ' ' + DelegateISO + ')';

                    if(c.userDelegate.Backlog_Value_Bypass__c){

                        //system.debug('DELEGATION SERVICE: Project Backlog Bypass > set to TRUE');
                        c.limitChangeReason  += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Backlog Bypass > set to FALSE');
                        c.limitBypassReason  += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }
                } else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }


                //system.debug('DELEGATION SERVICE: Backlog Amount: ' + backlog.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedUserBVLT.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Backlog_Value_lt__c + ' ' + DelegateISO + ')');
                if(backlog < convertedUserBVLT){
                    //system.debug('DELEGATION SERVICE: BREACHED');
                    string reason = 'Backlog Amount: ' + backlog.setscale(2) + ' ' + ProjectISO + ' < than limit ' + convertedUserBVLT.setscale(2) + ' ' + ProjectISO + ' (' + c.userDelegate.Backlog_Value_lt__c + ' ' + DelegateISO + ')';

                    if(c.userDelegate.Backlog_Value_Bypass_lt__c){
                        //system.debug('DELEGATION SERVICE: Project Backlog Bypass < set to TRUE');
                        c.limitChangeReason  += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Backlog Bypass < set to FALSE');
                        c.limitBypassReason  += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }
                } else {
                    //system.debug('DELEGATION SERVICE: PASS');
                }


            }

            ////system.debug('STRING CHECK:' + 'Review Category' + '-'  + objectName + '-' + sProcessName);
            if(mapCheck.containskey('Review Category' + '-'  + objectName + '-' + sProcessName) ){

                //system.debug('DELEGATION SERVICE: PROJECT REVIEW CATEGORY CHECK***************');

                //system.debug('DELEGATION SERVICE: Project Review Category: ' + c.relProj.clAECOMProjectReviewCategory__c);

                // Check Project Review Category
                if(c.relProj.clAECOMProjectReviewCategory__c == 'C-0' && !c.userDelegate.Project_Review_Category_C_0__c){

                    string reason = 'Review Category C-0 is not allowed for delegate ';

                    //system.debug('DELEGATION SERVICE: ' + reason);

                    if(c.userDelegate.Project_Review_Category_C_0_Bypass__c){
                        //system.debug('DELEGATION SERVICE: Project Review C-0 bypass set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Review C-0 bypass set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }

                } else if (c.relProj.clAECOMProjectReviewCategory__c == 'C-1'  && !c.userDelegate.Project_Review_Category_C_1__c){
                    
                    string reason = 'Review Category C-1 is not allowed for delegate ';

                    //system.debug('DELEGATION SERVICE: ' + reason);

                    if(c.userDelegate.Project_Review_Category_C_1_Bypass__c){
                        //system.debug('DELEGATION SERVICE: Project Review C-1 bypass set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Review C-1 bypass set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }

                } else if (c.relProj.clAECOMProjectReviewCategory__c == 'C-2'  && !c.userDelegate.Project_Review_Category_C_2__c){
                    
                    string reason = 'Review Category C-2 is not allowed for delegate ';

                    //system.debug('DELEGATION SERVICE: ' + reason);

                    if(c.userDelegate.Project_Review_Category_C_2_Bypass__c){
                        //system.debug('DELEGATION SERVICE: Project Review C-2 bypass set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Review C-2 bypass set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }

                } else if (c.relProj.clAECOMProjectReviewCategory__c == 'C-3'  && !c.userDelegate.Project_Review_Category_C_3__c){
                    
                    string reason = 'Review Category C-3 is not allowed for delegate ';

                    //system.debug('DELEGATION SERVICE: ' + reason);

                    if(c.userDelegate.Project_Review_Category_C_3_Bypass__c){
                        //system.debug('DELEGATION SERVICE: Project Review C-3 bypass set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Review C-3 bypass set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }

                } else if (c.relProj.clAECOMProjectReviewCategory__c == 'C-4'  && !c.userDelegate.Project_Review_Category_C_4__c){

                    string reason = 'Review Category C-4 is not allowed for delegate ';
                    
                    //system.debug('DELEGATION SERVICE: ' + reason);                    

                    if(c.userDelegate.Project_Review_Category_C_4_Bypass__c){
                        //system.debug('DELEGATION SERVICE: Project Review C-4 bypass set to TRUE');
                        c.limitChangeReason += addcomma(c.limitChangeReason) + reason;
                    } else {
                        //system.debug('DELEGATION SERVICE: Project Review C-4 bypass set to FALSE');
                        c.limitBypassReason += addcomma(c.limitBypassReason) + reason;
                        c.limitViolationWithNoBypass = true;
                    }
                } else {

                    //system.debug('DELEGATION SERVICE: PASS');
                }
            }

            //system.debug('DELEGATION SERVICE: ENDING LIMIT CHECK');
            if(c.limitChangeReason.length() > 0 || c.limitViolationWithNoBypass == true){

                if(c.limitChangeReason.length() == 0 && c.limitViolationWithNoBypass){
                    change original = c.cloneChange();
                    original.limitBypassReason = '';
                    original.limitChangeReason = '';
                    original.limitViolationWithNoBypass = false;

                    listOriginalBeforeEscalation.add(original);
                }


                //system.debug('DELEGATION SERVICE: BREACH OF LIMIT(S) DETECTED');
                lstNeedsEscalaction.add(c);
            }

            if(c.limitChangeReason != '' && c.limitChangeReason !=null){
                c.limitChangeReason += addcomma(c.limitChangeReason) + ' :::: ' + xChangemsg;  
            }
            
            if(c.limitBypassReason != '' && c.limitBypassReason !=null){
                c.limitBypassReason += addcomma(c.limitBypassReason) + ' :::: ' + xChangemsg;  
            }

        }

        if(listOriginalBeforeEscalation.size() > 0){
            lstChanges.addAll(listOriginalBeforeEscalation);
        }

        return lstNeedsEscalaction;
    }


    /**
     * Evaluates delegations for the appropriate escalation
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    private static void evalulateEscalation(list<change> lstChanges, list<Delegation__c> lstDelegationToRecord1, string objectLabel){
         

        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('Delegation_evalulateEscalation')) {
            return;
        }

        //system.debug('DELEGATION SERVICE: Starting Escalation');

        list<change> lstChangeViolateLimit = checkLimits(lstChanges);

        if(lstChangeViolateLimit.size() > 0){


            boolean isProj = false;
            if(getObjectName(lstChangeViolateLimit[0].oSObject)== 'pse__Proj__c'){
                isProj = true;
            }


            // replace the changes with the corresponding override
             for(change c: lstChangeViolateLimit){
                //system.debug('DELEGATION SERVICE: ESCALATING :' + c.oSObject + ' - ' + c.fieldNameChange);


                id oldID = (id)c.oSObject.get(c.oAD.Field_API_Name__c);

                string delegateProcess;
                if(c.userDelegate.id == null){
                    delegateProcess = 'No Delegate Found';
                } else if (c.userDelegate.OUID__c == null){
                    delegateProcess = 'Delegate';
                } else if (c.userDelegate.OUID__c != null){
                    delegateProcess = 'Default Delegate';
                }

                if(c.relProj.PnLManager__c != null && c.oAD.Escalation__c == 'PNL'){
                    //system.debug('DELEGATION SERVICE: ESCALATING TO PNL');

                    string reason = '';
                    
                    // handle the case a limit has been exceeded with a bypass
                    if(c.limitChangeReason.length() > 0){
                        c.oSObject.put(c.oAD.Field_API_Name__c, contactMap.get(c.relProj.PnLManager__c).pse__Salesforce_User__c );

                        /*if(isProj){
                            c.oSObject.put('ProjectApprover__c', c.relProj.PnLManager__c);

                        }*/

                        c.userChange = contactMap.get(c.relProj.PnLManager__c).pse__Salesforce_User__c;
                        //system.debug('DELEGATION SERVICE: New User - ' + c.userChange);

                        reason = 'Limit Escalation: ' + c.limitChangeReason;

                    // handle the case a limit has been exceeded without a bypass
                    } else {
                        if(hasSObjectField('escalationapprover__c', c.oSObject) ){
                            c.oSObject.put('EscalationApprover__c', contactMap.get(c.relProj.PnLManager__c).pse__Salesforce_User__c );   
                            c.fieldNameChange = 'EscalationApprover__c';
                            c.userChange = contactMap.get(c.relProj.PnLManager__c).pse__Salesforce_User__c;
                            reason = 'Non-Bypass Escalation: ' + c.limitBypassReason;    

                            //system.debug('DELEGATION SERVICE: Non-Bypass Escalation New User - ' + contactMap.get(c.relProj.PnLManager__c).pse__Salesforce_User__c); 
                        } else {

                            //system.debug('DELEGATION SERVICE: Tried to populate Non-Bypass Escalation New User - ' + contactMap.get(c.relProj.PnLManager__c).pse__Salesforce_User__c + ' but escalation bypass field does not exist'); 
                            continue;
                        }             
                    }



                    Delegation__c oDelegation = new Delegation__c(DelegateUser__c = contactMap.get(c.relProj.PnLManager__c).pse__Salesforce_User__c
                                                                , Delegate_Swapped__c = contactMap.get(c.relProj.PnLManager__c).id
                                                                , Record__c = (id)c.oSObject.get('id')
                                                                , Process__c = c.oAD.Process__c
                                                                , Object_Name__c = objectLabel
                                                                , Delegation_Reason__c = reason
                                                                , Delegate__c = c.userDelegate.id
                                                                , Project__c = (id)c.oSObject.get('delegateProject__c')
                                                                , Field_Name__c = c.fieldNameChange
                                                                , OldDelegate__c = oldID
                                                                , Project_Role__c = 'Project Approver'
                                                                , Delegation_Process__c = delegateProcess
                                                                );

                    lstDelegationToRecord1.add(oDelegation);

                    list<list<Delegation__c>> delLst = ECO_Service_Delegation_Helper.lstofDelegationstoInsert[ECO_Service_Delegation_Helper.lstofDelegationstoInsert.size() -1];
                    delLst[c.sobjectIndex].add(oDelegation);
                } else if (c.relProj.FinanceLead__c != null && c.oAD.Escalation__c == 'FA'){

                    //system.debug('DELEGATION SERVICE: ESCALATING TO FA');

                    string reason = '';


                    // handle the case a limit has been exceeded with a bypass
                    if(c.limitChangeReason.length() > 0){
                        c.oSObject.put(c.oAD.Field_API_Name__c, contactMap.get(c.relProj.FinanceLead__c).pse__Salesforce_User__c );
                        c.userChange = contactMap.get(c.relProj.FinanceLead__c).pse__Salesforce_User__c;

                        /*if(isProj){
                            c.oSObject.put('ProjectApprover__c', c.relProj.FAManager__c);

                        }*/

                        reason = 'Limit Escalation: ' + c.limitChangeReason;

                        //system.debug('DELEGATION SERVICE: New User - ' + c.userChange);


                    } else {
                        if(hasSObjectField('escalationaccountant__c', c.oSObject) ){
                            c.oSObject.put('EscalationAccountant__c', contactMap.get(c.relProj.FinanceLead__c).pse__Salesforce_User__c );
                            c.fieldNameChange = 'EscalationAccountant__c';
                            c.userChange = contactMap.get(c.relProj.FinanceLead__c).pse__Salesforce_User__c;
                            reason = 'Non-Bypass Escalation: ' + c.limitBypassReason;   

                            //system.debug('DELEGATION SERVICE: Non-Bypass Escalation New User - ' + contactMap.get(c.relProj.FinanceLead__c).pse__Salesforce_User__c); 
                        } else {

                            //system.debug('DELEGATION SERVICE: Tried to populate Non-Bypass Escalation New User - ' + contactMap.get(c.relProj.PnLManager__c).pse__Salesforce_User__c + ' but escalation bypass field does not exist'); 
                            continue;
                        }
                    }



                    Delegation__c oDelegation = new Delegation__c(DelegateUser__c = contactMap.get(c.relProj.FinanceLead__c).pse__Salesforce_User__c
                                                                , Delegate_Swapped__c = contactMap.get(c.relProj.FinanceLead__c).id
                                                                , Record__c = (id)c.oSObject.get('id')
                                                                , Process__c = c.oAD.Process__c
                                                                , Object_Name__c = objectLabel
                                                                , Delegation_Reason__c = reason
                                                                , Delegate__c = c.userDelegate.id
                                                                , Project__c = (id)c.oSObject.get('delegateProject__c')
                                                                , Field_Name__c = c.fieldNameChange
                                                                , OldDelegate__c = oldID
                                                                , Project_Role__c = 'Financial Lead'
                                                                , Delegation_Process__c = delegateProcess
                                                                );

                    lstDelegationToRecord1.add(oDelegation);
                    list<list<Delegation__c>> delLst = ECO_Service_Delegation_Helper.lstofDelegationstoInsert[ECO_Service_Delegation_Helper.lstofDelegationstoInsert.size() -1];
                    delLst[c.sobjectIndex].add(oDelegation);                    
                } else {
                    //system.debug('DELEGATION SERVICE: CANNOT DETERMINE WHO TO ESCALATE TO');
                }
             }

        } else {
             //system.debug('DELEGATION SERVICE: No Limit Violations Detected');
        }

        //system.debug('DELEGATION SERVICE: ESCALATION COMPLETE');
    }     

    /**
     * generic function to handle vacation or admin delegate replacements
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    public static list<Delegation__c> delegateReplace(list<change> lstChanges, map<id, Delegate__c> mapDelegates, string sReason){

        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_Service_Delegation_delegateReplace')) {
            return new list<Delegation__c>();
        }

        string objectLabel = getObjectLabel(lstChanges[0].oSObject);

        list<Delegation__c> lstDelegationToRecord1 = new list<Delegation__c>();

        for(change c: lstChanges){
            if(mapDelegates.containskey((id)c.userChange)){

                //system.debug('DELEGATION SERVICE: FOUND DELEGATE FOR ' + (id)c.userChange + ' - Delegate ID ' + mapDelegates.get((id)c.userChange).id);

                id oldUser = null;
                id changeUser = null;
                string headerReason = '';

                if(c.limitViolationWithNoBypass){
                    oldUser = (id)c.oSObject.get(c.fieldNameChange);
                    changeUser = mapDelegates.get((id)c.userChange).Delegate__r.pse__Salesforce_User__c;
                    c.oSObject.put(c.fieldNameChange, changeUser);
                    headerReason = 'Bypass Field: ';
                } else {
                    oldUser = (id)c.oSObject.get(c.oAD.Field_API_Name__c);
                    changeUser = mapDelegates.get((id)c.userChange).Delegate__r.pse__Salesforce_User__c;
                    c.oSObject.put(c.oAD.Field_API_Name__c, changeUser);
                }


                //system.debug('DELEGATION SERVICE: ON OBJECT ' + objectLabel + ' ID ' + (id)c.oSObject.get('id') + 'FOR PROJECT ' + (id)c.oSObject.get('delegateProject__c'));
                //system.debug('DELEGATION SERVICE: REPLACING ' + oldUser + ' with ' + changeUser + ' on field ' + c.fieldNameChange);

                string reason = headerReason + sReason;

                Delegation__c oDelegation = new Delegation__c(DelegateUser__c = changeUser
                                                            , Delegate_Swapped__c = mapDelegates.get((id)c.userChange).Delegate__c
                                                            , Record__c = (id)c.oSObject.get('id')
                                                            , Process__c = c.oAD.Process__c
                                                            , Object_Name__c = objectLabel
                                                            , Delegation_Reason__c = reason
                                                            , Delegate__c = mapDelegates.get((id)c.userChange).id
                                                            , Project__c = (id)c.oSObject.get('delegateProject__c')
                                                            , Field_Name__c = c.fieldNameChange
                                                            , OldDelegate__c = oldUser
                                                            , NeedsShareRule__c = true
                                                            , Delegation_Process__c = 'N/A'
                                                            );

                lstDelegationToRecord1.add(oDelegation);
                list<list<Delegation__c>> delLst = ECO_Service_Delegation_Helper.lstofDelegationstoInsert[ECO_Service_Delegation_Helper.lstofDelegationstoInsert.size() -1];
                delLst[c.sobjectIndex].add(oDelegation);
            } else {

            }
        }

        return lstDelegationToRecord1;
    }   

    /**
     * The main service call to kickoff escalation process
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
    public static void evaluateDelegation(list<SObject> lstTargets, map<id, SObject> oldMap){

        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_Service_Delegation')) {
            return;
        }

        //system.debug('DELEGATION SERVICE: STARTING EVALUATION OF DELEGATION');

        list<SObject> lstChanged = new list<SObject>();
        list<SObject> lstForVacation = new list<SObject>();
        list<SObject> lstForOverride = new list<SObject>();
        list<change> lstChanges = new list<change>();
        set<id> setUsers = new set<id>();
        map<id,Delegate__c> mapAdminDelegates = new map<id,Delegate__c>();
        map<id,Delegate__c> mapVacaDelegates = new map<id,Delegate__c>();

        id rtVacation = ECO_Utils_Meta.getRecordTypeId(Delegate__c.sObjectType, 'Vacation');
        id rtOverride = ECO_Utils_Meta.getRecordTypeId(Delegate__c.sObjectType, 'Administrator_Override');

        list<AECOM_Delegation__c> lstAD = getCustomSettings(lstTargets[0]);


        string objectLabel = getObjectLabel(lstTargets[0]);
        //system.debug('DELEGATION SERVICE: Handling Sobject Type ' + objectLabel);


        map<id, pse__Proj__c> projectMap = getProjectMap(lstTargets);
        contactMap =  getContactMap(projectMap);
        map<string, list<Delegate__c>> delegateMap = getDelegates(lstTargets, projectMap);

        integer index = 0;
        
        ECO_Service_Delegation_Helper.lstDelegationToRecord = new list<Delegation__c>();
        //ECO_Service_Delegation_Helper.lstofDelegationstoInsert = new list<list<Delegation__c>>();  

        if(ECO_Service_Delegation_Helper.lstofDelegationstoInsert == null){
            ECO_Service_Delegation_Helper.lstofDelegationstoInsert = new list<list<list<Delegation__c>>>();  
        }

        list<list<Delegation__c>> delLst = new list<list<Delegation__c>>();
        ECO_Service_Delegation_Helper.lstofDelegationstoInsert.add(delLst);

        ECO_Service_Delegation_Helper.test = true;      

        // Detect all the changes bassed on the custom settings criteria
        for(SObject s: lstTargets){

            delLst.add(new list<Delegation__c>());


            for(AECOM_Delegation__c ad: lstAD){

                //**** NOTE: the hasSObjectField method requires an ALL LOWERCAP name to be passed in. Odd quirk, but it appears to be case sensative
                if(!hasSObjectField('process__c', s) || (hasSObjectField('process__c', s) && (s.get('Process__c') == null || s.get('Process__c') == ad.ProcessAPIName__c))){
                //if(s.get('Process111__c') == null){

                    if(ad.FirstStepEscalation__c != null && ad.FirstStepEscalationLock__c != null && ad.PreventDelegateswhenlocked__c == true){
                        continue;
                    }


                    if(s.get(ad.Field_API_Name__c) != null && (oldMap==null || (s.get(ad.Field_API_Name__c) !=  oldMap.get((id)s.get('id')).get(ad.Field_API_Name__c)))){

                        //system.debug('DELEGATION SERVICE: New Value Detected : ' + ad.Field_API_Name__c + ' Value: ' + s.get(ad.Field_API_Name__c));
                        if(oldMap!=null){
                            //system.debug('DELEGATION SERVICE: Old Value : ' + ad.Field_API_Name__c + ' Value: ' + oldMap.get((id)s.get('id')).get(ad.Field_API_Name__c));
                        }


                        //setUsers.add((id)s.get(ad.Field_API_Name__c));  

                        string reason = 'User Changed';
                        id lastUser = null;

                        if(oldMap==null){
                            reason = 'Record Created/Submitted';
                        } else {
                            lastUser = (id)oldMap.get((id)s.get('id')).get(ad.Field_API_Name__c);
                        }

                        string searchKey = '';

                        pse__Proj__c keyProj = projectMap.get((id)s.get('delegateProject__c'));

                        string ouid = keyProj.OUID__c;

                        //system.debug('@@@ DEBUG OUID - ' + ouid);
                        ECODelegationOrgPreference__c Edop = ECODelegationOrgPreference__c.getvalues(ouid);


                        if(Edop != null && Edop.UseDefaultDelegation__c){
                            if(ad.Escalation__c == 'FA'){
                                searchKey = keyProj.OUID__c;
                                searchKey += 'Project Accountant';

                            } else {
                                searchKey = keyProj.OUID__c;
                                searchKey += 'Project Approver';
                            }
                        } else {
                            if(ad.Escalation__c == 'FA'){
                                searchKey = (id)keyProj.FinanceLead__c ;
                                searchKey += (id)s.get(ad.Field_API_Name__c);
                                searchKey += 'Project Accountant';

                            } else {
                                searchKey = (id)keyProj.PnLManager__c;
                                searchKey += (id)s.get(ad.Field_API_Name__c);
                                searchKey += 'Project Approver';
                            }                            
                        }


                        //system.debug('DEBUG****: DELEGATE KEY LOOKING: ' + searchKey);


                        Delegate__c dDelegate = null;
                        Delegate__c dZeroDelegate = createZeroDelegate();

                        if(delegateMap.containskey(searchKey)){
                            //dDelegate = delegateMap.get(searchKey);

                            //system.debug('DEBUG****: DELEGATE KEY FOUND: ' + searchKey);
                            for(Delegate__c del: delegateMap.get(searchKey)){


                                if(del.OUID__c != null){
                                    dDelegate = del;
                                } else {
                                    if(del.Allowed_Organizations__c != null && del.Allowed_Organizations__c.indexof(projectMap.get((id)s.get('delegateProject__c')).CarryingOutOrganization__c) != -1){

                                        //system.debug('DELEGATION SERVICE: User Delegate Found For ' + (string)s.get(ad.Field_API_Name__c) + ' : ' +  del.id + ' - ' + del.Start_Date__c + ' - ' + del.End_Date__c);
                                        dDelegate = del;
                                    }
                                }

                            }

                        }

                        if(dDelegate == null){
                            //system.debug('DELEGATION SERVICE: User Delegate NOT Found For ' + (string)s.get(ad.Field_API_Name__c));
                            dDelegate = dZeroDelegate;
                        }

                        pse__Proj__c proj = null;
                        if(projectMap.containskey((id)s.get('delegateProject__c'))){
                            proj = projectMap.get((id)s.get('delegateProject__c'));
                        }

                        lstChanges.add(new change(s, ad, dDelegate, proj, index));

                        id iDelegate = null;
                        id icontact = null;
                        if(dDelegate != null){
                            iDelegate = dDelegate.id;
                            icontact = dDelegate.Delegate__c;
                        }

                        Delegation__c oDelegation = new Delegation__c(DelegateUser__c = (id)s.get(ad.Field_API_Name__c)
                                                                    , Delegate_Swapped__c = icontact
                                                                    , Record__c = (id)s.get('id')
                                                                    , Process__c = ad.Process__c
                                                                    , Object_Name__c = objectLabel
                                                                    , Delegation_Reason__c = reason
                                                                    , Delegate__c = iDelegate
                                                                    , Project__c = (id)s.get('delegateProject__c')
                                                                    , Field_Name__c = ad.Field_API_Name__c
                                                                    , OldDelegate__c = lastUser
                                                                    , Project_Role__c = ad.Role__c
                                                                    , Delegation_Process__c = 'N/A'
                                                                    );


                        ECO_Service_Delegation_Helper.lstDelegationToRecord.add(oDelegation);

                        delLst[index].add(oDelegation);
                    }
                }
            }

            index++;
        }   

        // Evaluate escalation

        //if(!(getObjectName(lstTargets[0]) == 'pse__Proj__c' && oldMap==null)){

            evalulateEscalation(lstChanges, ECO_Service_Delegation_Helper.lstDelegationToRecord, objectLabel);
        //}

        for(change c:lstChanges){
            setUsers.add((id)c.userChange);
        }


        // get all the override and vacation delegates based on the users found
        list<Delegate__c> lstDelegates = [select id, Delegate__c, Delegate__r.pse__Salesforce_User__c, Delegator__r.pse__Salesforce_User__c, RecordTypeId, CurrencyIsoCode 
                                            from Delegate__c where Delegator__r.pse__Salesforce_User__c IN: setUsers 
                                                                AND (recordtypeid=:rtVacation or recordtypeid=:rtOverride) 
                                                                AND Start_Date__c <=: datetime.now().dateGMT()
                                                                AND (End_Date__c >=: datetime.now().dateGMT() OR End_Date__c =null)];
        for(Delegate__c d: lstDelegates){
            if(d.recordtypeid == rtVacation){
                mapVacaDelegates.put(d.Delegator__r.pse__Salesforce_User__c , d);
            } else if (d.recordtypeid == rtOverride) {
                mapAdminDelegates.put(d.Delegator__r.pse__Salesforce_User__c , d);
            }
        }
        
        if (lstChanges.size() > 0) {

            //system.debug('DELEGATION SERVICE: STARTING VACATION OVERRIDE');
            ECO_Service_Delegation_Helper.lstDelegationToRecord.addall(delegateReplace(lstChanges, mapVacaDelegates, 'Vacation Delegation'));
            //system.debug('DELEGATION SERVICE: ENDING VACATION OVERRIDE');
            //system.debug('DELEGATION SERVICE: STARTING ADMIN OVERRIDE');
            ECO_Service_Delegation_Helper.lstDelegationToRecord.addall(delegateReplace(lstChanges, mapAdminDelegates, 'Administrative Override Delegation'));
            //system.debug('DELEGATION SERVICE: ENDING ADMIN OVERRIDE');
        }
        
        //insert lstDelegationToRecord;
        //system.debug('DELEGATION SERVICE: ENDING EVALUATION OF DELEGATION');
    }    

    /** ------------------------------------------------------------------------------------------------------
    * @Description Helps with organizing and tracking critical information on changes to SObjects
    *
    * @Author      NTT Data - Tim Chiang
    * @Date        2016
    *-----------------------------------------------------------------------------------------------------*/
    public class change{
        public SObject oSObject {get;set;}
        public AECOM_Delegation__c oAD {get;set;}
        public string userChange {get;set;}
        public Delegate__c userDelegate {get;set;}
        public pse__Proj__c relProj {get;set;}
        public string limitChangeReason {get;set;}
        public string limitBypassReason {get;set;}
        public BudgetHeader__c oBudget {get;set;}
        public integer sobjectIndex {get;set;}
        public boolean limitViolationWithNoBypass {get;set;}
        public string fieldNameChange {get;set;}

        public change(){

        }

        /**
         * Alternate constructor
         *
         * @Author  NTT Data - Tim Chiang
         * @Date    2016
         *
         **/
        public change(SObject oSObject, AECOM_Delegation__c oAD, Delegate__c userDelegate, pse__Proj__c relProj, integer index){
            this.oSObject = oSObject;
            this.oAD = oAD;
            this.userDelegate = userDelegate;
            this.relProj = relProj;

            this.userChange = (id)this.oSObject.get(oAD.Field_API_Name__c);
            this.limitChangeReason = '';
            this.limitBypassReason = '';
            this.oBudget = null;
            this.sobjectIndex = index;
            this.limitViolationWithNoBypass = false;
            this.fieldNameChange = oAD.Field_API_Name__c;
        }

        /**
         * Custom method to handle the cloning of a change
         *
         * @Author  NTT Data - Tim Chiang
         * @Date    2016
         *
         **/
        public change cloneChange(){
            change returnChange = new change();
            returnChange.oSObject = this.oSObject;
            returnChange.oAD = this.oAD;
            returnChange.userChange = this.userChange;
            returnChange.userDelegate = this.userDelegate;
            returnChange.relProj = this.relProj;
            returnChange.limitChangeReason = this.limitChangeReason;
            returnChange.limitBypassReason = this.limitBypassReason;
            returnChange.oBudget = this.oBudget;
            returnChange.sobjectIndex = this.sobjectIndex;
            returnChange.limitViolationWithNoBypass = this.limitViolationWithNoBypass;
            returnChange.fieldNameChange = this.fieldNameChange;

            return returnChange;
        }
    }


}