/*************************************************************************
*
* PURPOSE: Creating/Modifying Go/No-Go records based on Opportunity
*
* CLASS: gng_OppToGNGC
* CREATED: 10/15/2014 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
*
* Updates: 
*    - 20-Apr-2015, Luke Farbotko
*      Fix issue in the mapping introduced by the critical update 'Predictable 
*        Iteration Order for Apex Unordered Collections'
*    - 16-Jul-2015, Tom Smalara
*      Add India to 'View Only'  
*    - 27-Oct-2015, Ram Kalagara
*      Fixed issue: Task/Notification should only be assigned/sent for stages 2,3,5,6
*      Added additional GNG fields to update Contingent_Liabilities_Notes__c, Forecast_Amount_gross__c, 
*      Gross_Margin__c, Forecast_Margin__c, Project_Scope_Summary__c, Project_Location__c.
*    - 29-Oct-2015, Ram Kalagara
*      Show error message when one of the Opportunity fields in ANZFiledMap are updated and GNG status is 'Submitted for Approval - Pending'
*      Added method to get updated field labels
*    - 02-Nov-2015, Ram Kalagara
*      Added exception to bypass Opportunity update error for three super users
*    - 23-Nov-2015, Ram Kalagara
*      Commented out code to update GNG Fields Contingent_Liabilities_Notes__c, Forecast_Amount_gross__c, 
*      Gross_Margin__c, Forecast_Margin__c, Project_Scope_Summary__c, Project_Location__c.
*    - 01-Mar-2015, Sameer Ahsan
*      Set the epmrmassessment__c checkbox to true if go/nogo completes approval phase.  
*    - 8-Jun-06 Fix broken tests. Remove NZ GNG auto creation for epm rollout
*    - 20-Jul-2016, Steve MunLeeuw
*      Issue I-1568: EMIA GNG PD notifications not working
*      factored out createStage2TaskForPM to support creating task for PM when Opp Stage and Go/No-Go decision out of sync
***************************************************************************/
public with sharing class gng_OppToGNGC {
    //Field map for Opp field => GNG field
    private static final Map<String, List<String>> ANZFieldMap = new Map<String, List<String>>{
        'CurrencyIsoCode' =>  new List<String>{'CurrencyIsoCode'},
        'Go_Probability__c' => new List<String>{'Market_Position_Q11__c'},
        'Probability_Stage__c' => new List<String>{'Market_Position_Q12__c'},
        'Construction_cost__c' => new List<String>{'Capital_Value__c'},
        'Project_DirectorUser__c' => new List<String>{'Project_Director__c', 'Bid_Director__c'},
        'Project_Director_EMEA__c' => new List<String>{'Project_Director__c'},
        'Capture_Manager_User__c' => new List<String>{'Bid_Manager__c', 'Project_Manager__c'},
        'Date_RFP_expected__c' => new List<String>{'RFT_Issue_Date__c'},
        'Estimated_work_start_date__c' => new List<String>{'Project_Start_Date__c'},
        //Removed mapping per AEGNG-133
        //'CloseDate' => 'Proposal_Due_Date__c',
        'Work_end_date_del__c' => new List<String>{'Project_Duration__c'},
        'Net_Revenue_To_Project__c' => new List<String>{'Staff_Time_FBLR_Fee__c'},
        'Business_Line_of_Primary_AECOM_Dept__c' => new List<String>{'Business_Line__c'},
        'Net_Revenue_Program__c' => new List<String>{'Net_Revenue_Program__c'},
        'Net_Revenue_TO_Project__c' => new List<String>{'Net_Revenue_TO_Project__c'},
        'B_P_Budget__c' => new List<String>{'Bid_Proposal_Budget__c'},
        'Account_Manager__c' => new List<String>{'Account_Manager__c'}
        //'Contingent_Liabilities_Notes__c' => new List<String>{'Contingent_Liabilities_Notes_New__c'},
        //'Forecast_Net_amount__c' => new List<String>{'Forecast_Amount_gross_New__c'},
        //'Gross_Margin__c' => new List<String>{'Gross_Margin_New__c'},
        //'Forecast_Margin__c' => new List<String>{'Forecast_Margin_New__c'},
        //'Description' => new List<String>{'Project_Scope_Summary__c'},
        //'Project_Location__c' => new List<String>{'Project_Location_New__c'}
    };

    private static final Set<String> VIEW_ONLY_RECORDTYPES_OPP = new Set<String> {
        'Project_CS',
        'Program_CS',
        'Task_Order_CS',
        'Project_MS',
        'Program_MS',
        'Task_Order_MS'
    };

    private static final Set<String> EMEA_I_REGIONS = new Set<String> {
        'Africa',
        'Middle East',
        'India',
        'Europe'
    };

    private static final Set<String> VIEW_ONLY_REGIONS = new Set<String> {
       //'Asia',            //change made in production, reconciling code Steve MunLeeuw 6/23/2016
       'Greater China',
       'Southeast Asia'            
    };

    private static final Set<String> ANZ_REGIONS = new Set<String> {
        'ANZ'
    };

    private static final Set<String> AMERICA_REGIONS = new Set<String> {
        'North America'
    };

    public static Set<String> updatedFields = new Set<String>();

    public static String updatedFieldLabels;

    public static Set<Id> hasRanOpp = new Set<Id>();

    //Creating new Go/No-Go records from opportunites
    public static void createGNGFromOpportunity(Map<String, List<Opportunity>> oppMap) {
        Map<String, Opportunity> oppMapFlat = new Map<String, Opportunity>();
        List<RecordType> recordTypes = [select Id, Name, DeveloperName from RecordType where sObjectType = 'Go_No_Go_Conversation__c' or sObjectType = 'Opportunity'];
        Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
        List<Go_No_Go_Conversation__c> gng = new List<Go_No_Go_Conversation__c>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Id> gngIdsToPD = new Map<Id,Id>();

        for(List<Opportunity> oppList : oppMap.values()) {
            oppMapFlat.putAll(oppList);
            for(Opportunity o : oppList) {
                oppIds.add(o.Id);
            }
        }

        for(RecordType r : recordTypes) {
            recordTypeMap.put(r.Name, r);
            recordTypeMap.put(r.Id, r);
            recordTypeMap.put(r.DeveloperName, r);
        }

        System.debug('debugMe oppMap.keySet(): ' + oppMap.keySet());
        for(String region : oppMap.keySet()) {
            System.debug('region:  ' + region);
            for(Opportunity o : oppMap.get(region)) {
                System.debug('Opportunity:  ' + o.Name);
                Boolean isViewOnlyRecordType = VIEW_ONLY_RECORDTYPES_OPP.contains(recordTypeMap.get(o.RecordTypeId).DeveloperName);
                System.debug('hasRanOpp.contains(o.Id):  ' + hasRanOpp.contains(o.Id));
                if(hasRanOpp.contains(o.Id)) continue;
                Go_No_Go_Conversation__c newGNG = new Go_No_Go_Conversation__c();
                if(VIEW_ONLY_REGIONS.contains(region) || isViewOnlyRecordType) newGNG.RecordTypeId = recordTypeMap.get('View_Only').Id;
                else if(EMEA_I_REGIONS.contains(region)){
                    if(region != 'Middle East'){
                        newGNG.RecordTypeId = recordTypeMap.get('Europe_GNG').Id;
                    }
                    else{
                        continue;
                    }
                }
                else if(ANZ_REGIONS.contains(region)) {
                    //I-1827  Disable ANZ Why Go
                    // Steve MunLeeuw Nov. 2016
                    //if(o.Lead_Region_Formula__c == 'ANZ NZ') {
                        continue;
                    //}
                    //newGNG.RecordTypeId = recordTypeMap.get('ANZ_GNG').Id;
                }
                else if(AMERICA_REGIONS.contains(region)) newGNG.RecordTypeId = recordTypeMap.get('Americas_GNG').Id;
                newGNG.Opportunity__c = o.Id;
                newGNG.Client_Name__c = o.AccountId;
                newGNG.Subs_Fee__c = o.Subs_Other_Revenue__c;
                newGNG.Subs_Cost__c = o.Subs_Other_Revenue__c;
                newGNG.Project_Scope_Summary__c = o.Description;                
                setFields(newGNG, o);
                hasRanOpp.add(o.Id);
                gng.add(newGNG); 
            }
        }

        try
        {
            if(gng.size() > 0){
                system.debug( '***SA-gng_OppToGNGC.createGNGFromOpportunity - PreInsert ');            
                insert gng;
                system.debug( '***SA-gng_OppToGNGC.createGNGFromOpportunity - PostInsert ');
            }
        }
        catch (Exception e)
        {
            system.debug( '***SA-gng_OppToGNGC.createGNGFromOpportunity - DMLException ' + e.getMessage());
        }



        for(Go_No_Go_Conversation__c g : gng){
            if(!gngIdsToPD.containsKey(g.Id) 
                && !oppMapFlat.get(g.Opportunity__c).StageName.startsWith('1') 
                && !oppMapFlat.get(g.Opportunity__c).StageName.startsWith('4') 
                && !oppMapFlat.get(g.Opportunity__c).StageName.startsWith('8') 
                && !oppMapFlat.get(g.Opportunity__c).StageName.startsWith('7') 
                && !oppMapFlat.get(g.Opportunity__c).StageName.startsWith('9') 
                && g.RecordTypeId == recordTypeMap.get('Europe_GNG').Id  //On update we can query the record type developer name 
                && g.Decision__c != 'Go' 
                && g.Decision__c != 'No-Go'
                )
                {
                    gngIdsToPD.put(g.Id,g.Project_Director__c);
                } 
        }

        if(gngIdsToPD.size() > 0){
            createStage2TaskForPM(gngIdsToPD);
        }
    }

    //update existing Go/No-Go records
    public static void updateGNGFromOpportunity(Map<String, Opportunity> oppMap) {

        Set<String> ids = oppMap.keySet();
        String query = buildQueryString('Go_No_Go_Conversation__c')+ ', RecordType.Name' + ' ,RecordType.DeveloperName from Go_No_Go_Conversation__c where Opportunity__c in: ids';
        Map<Id,Id> gngIdsToPD = new Map<Id,Id>();
        List<Go_No_Go_Conversation__c> gngsToUpdate = new List<Go_No_Go_Conversation__c>();
        Set<Id> lockedGNGs = new Set<Id>();
        gng_ApprovalProcessDao appDao = gng_ApprovalProcessDao.getInstance();

        Map<Id,Task> existingUserTask = new Map<Id,Task>();

        for(Go_No_Go_Conversation__c g : (List<Go_No_Go_Conversation__c>)Database.query(query)) {
            system.debug( '***SA-gng_OppToGNGC.updateGNGFromOpportunity - g.Approval_Status__c ' + g.Approval_Status__c);            
            
            if(compareFields(g, oppMap.get(g.Opportunity__c))) {
                if(g.Approval_Status__c != 'Submitted for Approval - Pending') {
                    //3150 - add r&M Submission
                    //system.debug( '***SA-gng_OppToGNGC.updateGNGFromOpportunity - g.epmrmassessment__c1 ');
                    //system.debug( '***SA-gng_OppToGNGC.updateGNGFromOpportunity - g.Approval_Status__c1 ' + g.Approval_Status__c);
                    //if(!g.epmrmassessment__c && (g.Approval_Status__c == 'Approved' || g.Approval_Status__c == 'Rejected' || g.Approval_Status__c == 'Not Submitted'))
                    //    g.epmrmassessment__c = true;
                    gngsToUpdate.add(setFields(g, oppMap.get(g.Opportunity__c)));
                }
                else {
                    // Prevent normal users from updating when GNG is in Submitted for Approval - Pending status
                    User user = [select id, Profile.Name, CommunityNickname from User where id = :Userinfo.getUserId()];
                    if(String.valueOf(user.CommunityNickname) != 'SystemNA' && String.valueOf(user.CommunityNickname) != 'APIC' && String.valueOf(user.Profile.Name) != 'API Access'){
                        oppMap.get(g.Opportunity__c).addError('You cannot update ' + getUpdatedFieldLabels() + ' until Go/No Go Conversation is Approved/Rejected.');
                    } else {
                        //3150 - add r&M Submission
                        //system.debug( '***SA-gng_OppToGNGC.updateGNGFromOpportunity - g.epmrmassessment__c2 ');
                        //system.debug( '***SA-gng_OppToGNGC.updateGNGFromOpportunity - g.Approval_Status__c2 ' + g.Approval_Status__c);
                        //if(!g.epmrmassessment__c && (g.Approval_Status__c == 'Approved' || g.Approval_Status__c == 'Rejected' || g.Approval_Status__c == 'Not Submitted'))
                        //    g.epmrmassessment__c = true;
                        gngsToUpdate.add(setFields(g, oppMap.get(g.Opportunity__c)));
                    }
                    //if(appDao.recallWorkItem(g.Id, 'Recalling to Update')) lockedGNGs.add(g.Id);
                    //gngsToUpdate.add(setFields(g, oppMap.get(g.Opportunity__c)));
                }   
            }
            if(!gngIdsToPD.containsKey(g.Id) && !oppMap.get(g.Opportunity__c).StageName.startsWith('1') && !oppMap.get(g.Opportunity__c).StageName.startsWith('4') && !oppMap.get(g.Opportunity__c).StageName.startsWith('8') && !oppMap.get(g.Opportunity__c).StageName.startsWith('7') && !oppMap.get(g.Opportunity__c).StageName.startsWith('9') && g.RecordType.DeveloperName == 'Europe_GNG' && g.Decision__c != 'Go' && g.Decision__c != 'No-Go') gngIdsToPD.put(g.Id,g.Project_Director__c);


        }
        update gngsToUpdate;

        createStage2TaskForPM(gngIdsToPD);
    }


    /** ------------------------------------------------------------------------------------------------------
    * @Description When the opportunity stage lacks the supporting go no-go decision and the region is Europe, a task is created for the PM
    *
    * @Author      Ethos -> AECOM, Steve MunLeeuw
    * @Date        July 20, 2016
    * This logic was in method @see gng_OppToGNGC.updateGNGFromOpportunity, factored out to this method
    * and included call from @see gng_OppToGNGC.createGNGFromOpportunity
    *-----------------------------------------------------------------------------------------------------*/
    private static void createStage2TaskForPM(Map<Id,Id> gngIdsToPD){
        Map<Id,Task> existingUserTask = new Map<Id,Task>();
        List<Task> tasks = new List<Task>();


        for(Task t : [Select OwnerId,WhatId,Subject from Task where OwnerId IN: gngIdsToPD.values() AND WhatId IN: gngIdsToPD.keySet() AND Subject =: 'Opportunity has reached Stage 2 and Go/No Go record has not been approved or rejected.']) {
            existingUserTask.put(t.WhatId,t);
        }
        for(Id gngId : gngIdsToPD.keySet()) {
            Task existTask = existingUserTask.get(gngId);
            if(String.isNotBlank(gngIdsToPD.get(gngId)) // Checks if Opp has a PD
                && (existTask == null ||  //Checks if there exists a Task already for OPP
                    (existTask != null && existTask.OwnerId != gngIdsToPD.get(gngId)) // Checks if existing task matches Project director
                )){
                tasks.add(createGNGTask(gngIdsToPD.get(gngId),gngId));
            }
        }
        Database.DMLOptions notifyOption = new Database.DMLOptions();
        notifyOption.EmailHeader.triggerUserEmail = true;

        Database.insert(tasks, notifyOption);
    }

    //delete existing Go/No-Go records
    public static void deleteGNGFromOpportunity(Set<Id> oppIds) {
        delete [select Id,Name from Go_No_Go_Conversation__c where Opportunity__c in: oppIds];
    }

    //set ANZ fields (TODO: update to encompass all regions)
    private static Go_No_Go_Conversation__c setFields(Go_No_Go_Conversation__c g, Opportunity o) {
          for(String oppField : ANZFieldMap.keySet()) {
                 if(oppField == 'Project_DirectorUser__c' || oppField == 'Project_Director_EMEA__c')
                 {
                   Boolean isEMEA = (o.Geography_Formula__c == 'Europe' || o.Geography_Formula__c == 'Middle East' || o.Geography_Formula__c == 'Africa' || o.Geography_Formula__c == 'India'); // is India required in here too?
                   if(oppField == 'Project_DirectorUser__c' && isEMEA)
                     continue;
                   if(oppField == 'Project_Director_EMEA__c' && !isEMEA)
                     continue;
                 }
                 for(String gngField : ANZFieldMap.get(oppField)) {
                    //if (gngField == 'Project_Location_New__c') {
                    //    g.put(gngField, getProjectLocation(o));
                    //} else {
                        //System.debug('debugMe:  update gng from opp - from: ' + gngField + ' - ' + o.get(oppField));
                        g.put(gngField, o.get(oppField));
                    //}                    
                 }
          }
          return g;
    } 

    // Concatenate city, state, and country into ProjectLocation__c
    private static String getProjectLocation(Opportunity o) {
        String city = o.get('Project_City__c') == null ? '' : o.get('Project_City__c') + ', '; 
        String states = '';
        if (o.get('Project_State_Province__c') != null)
        {
            states = String.valueOf(o.get('Project_State_Province__c'));
            states = states.replace(';', ', ') + ', ';
        }
        return city + states + o.get('ProjectCountry__c');
    }

    //compares the fields between GNG and Opp to see if we need to update the GNG record
    private static Boolean compareFields(Go_No_Go_Conversation__c g, Opportunity o) {
        Boolean isUpdate = false;

         for(String oppField : ANZFieldMap.keySet()) {
             if(oppField == 'Project_DirectorUser__c' || oppField == 'Project_Director_EMEA__c'){
                   Boolean isEMEA = (o.Geography_Formula__c == 'Europe' || o.Geography_Formula__c == 'Middle East' || o.Geography_Formula__c == 'Africa' || o.Geography_Formula__c == 'India'); // is India required in here too?
                   if(oppField == 'Project_DirectorUser__c' && isEMEA)
                     continue;
                   if(oppField == 'Project_Director_EMEA__c' && !isEMEA)
                     continue;
             }
            for(String gngField : ANZFieldMap.get(oppField)) {
                if(g.get(gngField) != o.get(oppField))  
                {
                    String gngFieldValue, oppFieldValue;
                    if (gngField == 'Account_Manager__c') { // Added '' to compare null vs blank. Datatypes are diff for gngField and oppField
                        gngFieldValue = g.get(gngField) == null ? '' : String.valueOf(g.get(gngField));
                        oppFieldValue = o.get(oppField) == null ? '' : String.valueOf(o.get(oppField));
                        if (gngFieldValue.trim() != oppFieldValue.trim()) {
                            isUpdate = true;  
                            //System.debug('debugMe:  gng vs. opp - ' + gngFieldValue.trim() + ' - ' + oppFieldValue.trim());
                            updatedFields.add(oppField);                              
                        }
                    } else {
                        isUpdate = true;                    
                        //System.debug('debugMe:  update opp field - ' + oppField);
                        updatedFields.add(oppField);                              
                    }
                }
            }
        }
        return isUpdate;
    }

    // Get labels for the updated fields
    private static String getUpdatedFieldLabels()
    {
        String labels;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('Opportunity');
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        for (String fieldName: fieldMap.keySet()) 
        {
            for (String oppField : updatedFields)
            {
                if (fieldName == oppField)
                {
                    labels = (labels == null ? '' : labels + ', ') + fieldMap.get(fieldName).getDescribe().getLabel();//It provides to get the object fields label.
                }
            }
        }     
        return labels;     
    }

    //build query string
    private static String buildQueryString(String objectName){
        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        DescribeSObjectResult objDef = objToken.getDescribe();
        String fieldList = String.join(new List<String>(objDef.fields.getMap().keySet()), ',').toLowerCase();

        return 'select ' + fieldList;
    }

    private static Task createGNGTask(Id ownerId, Id gngId) {
        Task newTask = new Task();
        newTask.Subject = 'Opportunity has reached Stage 2 and Go/No Go record has not been approved or rejected.';
        newTask.Status = 'Not Started';
        newTask.Priority = 'Normal';
        newTask.Type = 'Other';
        newTask.ActivityDate = Date.today();
        newTask.OwnerId = ownerId;
        newTask.WhatId = gngId;
        return newTask;
    }
}