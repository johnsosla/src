/*
  Name        :   AttachmentHandler
  Requester   :   CRS Requirments
  Author      :   AECOM - Richard Cook
  Version     :   1.0 
  Purpose    :   Create a trigger handler to handle user attachment upload events

 */
Trigger AttachmentHandler on Attachment ( before insert, after insert, before update, after update,
before delete, after delete, after undelete )
{
    if (Trigger.isAfter && Trigger.isInsert)
  {
    AttachmentTriggerHandler.OnAfterInsert(Trigger.newMap);
  }    
  /* Currently no use for other events
   * 
   * #region unUsed
   * else if(Trigger.isBefore && Trigger.isInsert)
  {
    AttachmentTriggerHandler.OnBeforeInsert(Trigger.new);
  } else if (Trigger.isBefore && Trigger.isUpdate)
  {
    AttachmentTriggerHandler.OnBeforeUpdate(Trigger.newMap, Trigger.oldMap);
  } else if (Trigger.isAfter && Trigger.isUpdate) 
  {
    AttachmentTriggerHandler.OnAfterUpdate(Trigger.newMap, Trigger.oldMap);
  } else if (Trigger.isBefore && Trigger.isDelete) 
  {
    AttachmentTriggerHandler.OnBeforeDelete(Trigger.oldMap);
  } else if (Trigger.isAfter && Trigger.isDelete) 
  {
    AttachmentTriggerHandler.OnAfterDelete(Trigger.oldMap);
  } else if (Trigger.isAfter && Trigger.isUndelete)
  {
    AttachmentTriggerHandler.OnAfterUndelete(Trigger.oldMap);
  }
  */
  
}