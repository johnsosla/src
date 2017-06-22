public class NoteHandler {
    public static  void OnAfterInsert(Map<Id,Note> newMap)
    {
        ContractReviewHelper.SendNotification(newMap);
    }
    public static void OnAfterUpdate(Map<Id,Note> newMap, Map<Id,Note> oldMap)
    {
        ContractReviewHelper.SendNotification(newMap);
    }
    

}