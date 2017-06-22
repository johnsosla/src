/* Omar */
public without sharing class ECO_Service_Users {
    private class ECO_Service_UsersException extends Exception {}
    
    private static User userCache;
    
    public static User getUserInfoById (Id userId, Boolean refreshFromDatabase) {
        if (userCache == null || refreshFromDatabase == true) {
            userCache = [SELECT Id 
                                , Name
                                , ECO_Geography__c
                                , ECO_BusinessLine__c
                                , ECO_Region__c
                                , Geography__c
                                , Business_Line__c
                                , Region__c
                                , Certified_PM__c
                        FROM User 
                        WHERE Id = :userId];
                        
            userCache.ECO_Geography__c = (ECO_Utils_String.NullCheck(userCache.ECO_Geography__c) != '') ? userCache.ECO_Geography__c : userCache.Geography__c;
            userCache.ECO_BusinessLine__c = (ECO_Utils_String.NullCheck(userCache.ECO_BusinessLine__c) != '') ? userCache.ECO_BusinessLine__c : userCache.Business_Line__c;
            userCache.ECO_Region__c = (ECO_Utils_String.NullCheck(userCache.ECO_Region__c) != '') ? userCache.ECO_Region__c : userCache.Region__c;
        }
        
        return userCache;
    }

    public static Boolean isSystemAdminstrator(Id profileId) {

        List<Profile> listProfile = [Select Name from Profile where Id = :profileId Limit 1]; 
            
        if(listProfile.isEmpty()) {
            return false;
        }
            
        if( listProfile[0].Name == 'System Administrator' || listProfile[0].Name == 'Administrateur système'){
            return true;          
        }

        return false;
    }
    
    public static User getUserInfoById (Id userId) {
        return getUserInfoById(userId, false);
    }
    
    public static List<ProcessInstanceWorkitem> getApprovalsForUser (Id userId) {
        return [SELECT Id
                        , ActorId
                        , ElapsedTimeInDays
                        , ElapsedTimeInHours
                        , ElapsedTimeInMinutes
                        , OriginalActorId
                        , ProcessInstanceId
                        , ProcessInstance.Status
                        , ProcessInstance.TargetObjectId
                        , ProcessInstance.TargetObject.Name
                FROM ProcessInstanceWorkitem
                WHERE ActorId = :userId];
    }
    
    public static List<Task> getOpenTasksForUser (Id userId) {
        return [SELECT Id 
                        , AccountId
                        , ActivityDate
                        , CallDisposition
                        , CallDurationInSeconds
                        , CallObject
                        , CallType
                        , Description
                        , IsHighPriority
                        , Status
                        , Subject
                        , Type
                        , What.Name
                        , Priority 
                FROM Task 
                WHERE IsClosed = false
                    AND OwnerId = :userId];
    }

}