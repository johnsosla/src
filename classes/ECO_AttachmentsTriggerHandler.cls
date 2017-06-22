public with sharing class ECO_AttachmentsTriggerHandler {
	
	public static void handleBeforAttachmentDelete(list<Attachment> attachments)
	{
		map<Id, Attachment> whatIdAttachmentMap = new map<Id, Attachment>();
		for(Attachment attachment:attachments)	
		{
			whatIdAttachmentMap.put(attachment.ParentId, attachment);		
		}
		
		list<BudgetHeader__c> budgetHeaders = [select Id from BudgetHeader__c where Id in :whatIdAttachmentMap.keyset()];
		list<Agreement__c> agreements = [select Id, ProgramPlanAttachment__c, GuidanceAttachment__c, BusinessDevelopmentAttachment__c, MeetingMinutesAttachment__c
		                                   from Agreement__c where Id in :whatIdAttachmentMap.keyset()];
		
		Attachment attachmentForErrorMessage;
		for(BudgetHeader__c budgetHeader:budgetHeaders){
			attachmentForErrorMessage = whatIdAttachmentMap.get(budgetHeader.Id);	
			attachmentForErrorMessage.addError('Users are not allowed to delete Budget Attachments');	
		}
		
		for(Agreement__c agreement:agreements)
		{
			//GuidanceAttachment__c, ProgramPlanAttachment__c, BusinessDevelopmentAttachment__c, MeetingMinutesAttachment__c
			attachmentForErrorMessage = whatIdAttachmentMap.get(agreement.Id);
			String guidanceAttanchments = '';
			String businessDevelopmentAttachments = '';
			String meetingMinuteAttachments = '';
			String programPlanAttachments = '';

			if(agreement.GuidanceAttachment__c != null)
				guidanceAttanchments = agreement.GuidanceAttachment__c;

			if(agreement.BusinessDevelopmentAttachment__c != null)
				businessDevelopmentAttachments = agreement.BusinessDevelopmentAttachment__c; 

			if(agreement.MeetingMinutesAttachment__c != null)
				meetingMinuteAttachments = agreement.MeetingMinutesAttachment__c; 

			if(agreement.ProgramPlanAttachment__c != null)
				programPlanAttachments = agreement.ProgramPlanAttachment__c;

			if(!guidanceAttanchments.contains(attachmentForErrorMessage.Id) && !businessDevelopmentAttachments.contains(attachmentForErrorMessage.Id) && !meetingMinuteAttachments.contains(attachmentForErrorMessage.Id) && !programPlanAttachments.contains(attachmentForErrorMessage.Id))
				attachmentForErrorMessage.addError('Users are not allowed to delete Agreement Attachments');	
		}				
	}
}