global class CFM_NotifyPM_Job implements Queueable  {

	Set<Id> batchIds;
	String notifyType;
	List<CFM_Survey_Project_Review__c> surveyProjectReviews;

	global CFM_NotifyPM_Job(Set<Id> batchIds, List<CFM_Survey_Project_Review__c> surveyProjectReviews) {
        this.surveyProjectReviews = surveyProjectReviews;
        this.batchIds = batchIds;
        this.notifyType = CFM_ProjectTriggerHandler.NOTIFY_RESEND;
    }

    public void execute(QueueableContext context) {
    	Map<Id, CFM_Survey_Batch__c> surveyBatches = new Map<Id, CFM_Survey_Batch__c>(CFM_SurveyBatch.find.findByIds(batchIds));
        CFM_NotifyPM_Batch.notifyPms(this.notifyType, new List<Id>(batchIds), surveyBatches, surveyProjectReviews);
    }
}