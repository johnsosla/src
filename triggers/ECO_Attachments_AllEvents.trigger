trigger ECO_Attachments_AllEvents on Attachment (before delete) {
	
	if(trigger.isBefore)
		ECO_AttachmentsTriggerHandler.handleBeforAttachmentDelete(trigger.old);
	

}