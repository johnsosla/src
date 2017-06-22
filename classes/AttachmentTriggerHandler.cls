// Trigger Handler for Attachments
// Richard Cook 2016
// AECOM

public class AttachmentTriggerHandler {
    public static void OnBeforeInsert(List<Attachment> newValues)
    {
    }
    public static  void OnAfterInsert(Map<Id,Attachment> newMap)
    {
        ContractReviewHelper.SendNotification(newMap);
    }
    public static  void OnBeforeUpdate(Map<Id,Attachment> newMap, Map<Id,Attachment> oldMap)
    {
    }
    public static void OnAfterUpdate(Map<Id,Attachment> newMap, Map<Id,Attachment> oldMap)
    {
        ContractReviewHelper.SendNotification(newMap);
    }
    public static void OnBeforeDelete(Map<Id,Attachment> oldMap)
    {
    }
    public static void OnAfterDelete(Map<Id,Attachment> oldMap)
    {
    }
    public static void OnAfterUndelete(Map<Id,Attachment> oldMap)
    {
    }
}