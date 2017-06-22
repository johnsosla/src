/*
  Name        :   AttachmentHandler
  Requester   :   CRS Requirments
  Author      :   AECOM - Richard Cook
  Version     :   1.0 
  Purpose	  :   Create a trigger handler to handle user note events

 */
Trigger NoteTrigger on Note (after insert,after update )
{
    if (Trigger.isAfter && Trigger.isInsert)
	{
		NoteHandler.OnAfterInsert(Trigger.newMap);
	}    
    else if (Trigger.isAfter && Trigger.isUpdate)
	{
		NoteHandler.OnAfterUpdate(Trigger.newMap, Trigger.oldMap);
	}        
    
}