trigger CFM_SurveyBatchReviewReminder on CFM_Survey_Batch__c (after update) {
	for (CFM_Survey_Batch__c batch : Trigger.new) {
		if (batch.Send_PM_Review_Reminders__c && !Trigger.oldMap.get(batch.Id).Send_PM_Review_Reminders__c) {
			// Flag has flipped from unchecked to checked
			CFM_PMReviewReminderBatch b = new CFM_PMReviewReminderBatch(batch);
			Database.executeBatch(b, 200);
		}
		if (batch.Send_Reminders__c && !Trigger.oldMap.get(batch.Id).Send_Reminders__c) {
			// Send reminders to Qualtrics
			CFM_QualtricsAsyncIntegrationHandler reminderHandler = new CFM_QualtricsAsyncIntegrationHandler(new CFM_SurveyBatch(batch), true);
			Id queuedCalloutJobId = System.enqueueJob(reminderHandler);
		}
	}
}