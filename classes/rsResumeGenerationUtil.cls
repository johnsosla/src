global class rsResumeGenerationUtil {


    //TODO - this should be made to take a Set<Id> instead of a List<String>
    //so we don't have to do an idiotic datatype conversion
    public static String generateResumeJson(List<String> userIds){

        //If we don't have anything selected just pass back an empty json array
        if(userIds == null || userIds.isEmpty()) return '{"users":[]}';

        Set<Id> userIdSet = new Set<Id>();
        for(String userId : userIds) userIdSet.add(userId);

        Set<String> userFields = new Set<String>{'Resume_Output_Name__c','Resume_Output_Title__c','FirstName','LastName','Name','Office__c','Bio__c',
                                                 'Title','Years_Of_Experience__c','Years_With_AECOM_Num__c',
                                                 'Years_with_Other_Firms__c','Business_Card_Title__c'};

        Map<Id, User> users = rsProfile.find.byUserIdSetMinFields(userIdSet,userFields);

        //Performance improvement so we're only looping over users
        //actual list of profile parts instead of all profile parts
        //for every user...
        Map<Id,List<rs_Profile_Part__c>> profilePartsMap = rsProfilePart.find.byUsersAsMap(userIdSet);

        //TODO - factor out somewhere else.. like rsProject or whatever
        Map<Id,List<PR_Team_Employee__c>> userProjectMap = new Map<Id,List<PR_Team_Employee__c>> ();
        for(PR_Team_Employee__c p : [select Id,Date_Involvement_Ended__c,Project_Name__c,
                                                     Date_Involvement_Started__c,Client__c,Description__c,EmployeeUser__c,
                                                     Location_City__c,Location_Country__c,Location_State_Prov_Emirate__c,
                                                     Non_AECOM_Project__c,Project_Group__c,Project_Role__c
                                                     from PR_Team_Employee__c where EmployeeUser__c in: userIdSet AND Status__c = :rsPRTeamEmployee.S_APPROVED
                                                     AND Output_On_Resume__c = true
                                                     and Next_Project_Part__r.Status__c != :rsPRTeamEmployee.S_APPROVED
                                                     order by Non_AECOM_Project__c asc, Group_Sequence__c asc, Project_Sequence__c asc]) {

            if(userProjectMap.containsKey(p.EmployeeUser__c)) {
                userProjectMap.get(p.EmployeeUser__c).add(p);
            }
            else {
                userProjectMap.put(p.EmployeeUser__c,new List<PR_Team_Employee__c>{p});
            }
        }
        //End TODO


        Map<Id,Schema.RecordTypeInfo> rtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosById();

        Map<String, List<Map<String, Object>>> partsMap = new Map<String, List<Map<String, Object>>>();
        partsMap.put('users', new List<Map<String, Object>>());

        //Loop through all users and add them in..
        for(Id userId : userIds){

            Map<String, Object> tempMap = new Map<String, Object>();
            User thisUser = users.get(userId);

            for(String userField : userFields){
                tempMap.put(userField, thisUser.get(userField));
            }

            for(rs_Profile_Part__c part : profilePartsMap.get(userId)){
                String thisRtName = getRtNameByFieldName(rtInfo.get(part.RecordTypeId).getName());
                //If the first profile part hasn't been added for at type
                //create a new list for it and add it
                if(!tempMap.keySet().contains(thisRtName)){
                    tempMap.put(thisRtName, new List<rs_Profile_Part__c>{part});
                }
                //Else, get the existing one and add it.
                else {
                    ((List<rs_Profile_Part__c>)tempMap.get(thisRtName)).add(part);
                }
            }

            //TODO - probably will have to break out into 3 different project types
            if(userProjectMap.containsKey(userId) && userProjectMap.get(userId).size() > 0) {
                tempMap.put('projectexperience',userProjectMap.get(userId));
            }
            partsMap.get('users').add(tempMap);
        }
        return JSON.serialize(partsMap);
    }

    public static String getRtNameByFieldName(String rtFieldName){
        String retVal = rtFieldName;
        Map<String, String> nameMap = new Map<String, String>{
            'Education' => 'educations',
            'Registration' => 'licenses',
            'Languages' => 'languages',
            'Translations' => 'translations',
            'Certification' => 'certifications',
            'Work History' => 'employments',
            'Award' => 'Award',
            'Skill Index' => 'Skill Index',
            'Training' => 'trainings',
            'Professional Affiliation' => 'memberships',
            'Publication' => 'publications',
            'Award' => 'awards',
            'New Project' => 'projectexperience',
            'Non-AECOM Project' => 'projectexperience',
            'Existing Project' => 'projectexperience'
        };

        if(nameMap.keySet().contains(rtFieldName)){
            retVal = nameMap.get(rtFieldName);
        }
        return retVal;
    }
}