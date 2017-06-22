public class ECOM_TasksComponentController {
    @AuraEnabled
    public static List<Task> getTasks() {
        Id currentUser = UserInfo.getUserId();
        return [Select Id, Subject, Type, Status, Priority
                From Task
                Where IsClosed = false
                and IsDeleted = false
                and IsArchived = false
                and OwnerId = :currentUser
               	Order By ActivityDate ASC];
    }


    @AuraEnabled
    public static Id getStandardTaskRtId() {
        return [Select Id from RecordType where DeveloperName = 'Standard_Tasks'].Id;
    }

}