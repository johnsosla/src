public with sharing class CFM_SurveyBatchPMReviewController {

	public String surveyProjectId { get; set; }
	public String rejectReason { get; set; }
	public String otherRejectReason { get; set; }

	public CFM_SurveyBatch surveyBatch { get; set; }
	public CFM_SurveyBatchReview surveyBatchReview { get; set; }
	public List<CFM_SurveyBatchProject> surveyBatchProjects { get; set; }

	public CFM_SurveyBatchPMReviewController(ApexPages.StandardController sc) {
		surveyBatchReview = CFM_SurveyBatchReview.find.findById(sc.getId());
        surveyBatch = CFM_SurveyBatch.find.findById(surveyBatchReview.obj.Survey_Batch__c);
        surveyBatchProjects = CFM_SurveyBatchProject.find.findByPm(surveyBatch.getId(), surveyBatchReview.getProjectManagerId());
    }


    public Boolean getIsClosed() {
    	return surveyBatch.isClosed();
    }

    public Boolean getIsCompleted() {
    	return surveyBatchReview.obj.Status__c == 'Completed';
    }

    public PageReference submitAction() {

    	Boolean allUpdated = true;

    	for (CFM_SurveyBatchProject project: surveyBatchProjects) {
    		if (String.isBlank(project.obj.PM_Status__c)) {
    			allUpdated = false;
    		}
    	}

    	if (allUpdated) {
    		surveyBatchReview.obj.Status__c = 'Completed';
    		update surveyBatchReview.obj;
    	}
    	else {
    		CFM_PageUtil.addError(Label.CFM_Confirm_Reject_Projects);
    	}

		List<Task> tasks = [Select Id, Status 
						    from Task 
						    where WhatId =: surveyBatchReview.getId() 
						    	AND OwnerId =: surveyBatchReview.getProjectManagerId()];

		for(Task t : tasks) {
			t.Status = 'Completed';
		}   	
		update tasks;

    	return null;
    }


    public PageReference confirmAction() {
    	String projectId = CFM_PageUtil.getParam('projectId');
    	System.debug('### PARAM Project ID: ' + projectId);

    	for (CFM_SurveyBatchProject project : surveyBatchProjects) {
    		String rowProjectId = (String)project.obj.Id;

			if (projectId == rowProjectId) {	
				if (project.obj.Project__r.CFM_Survey_Contact__c != null) {
					project.obj.PM_Status__c = CFM_SurveyBatchProject.PM_STATUS_CONFIRM;
					project.obj.Status__c = CFM_SurveyBatchProject.STATUS_REVIEWED;
					project.obj.PM_Reject_Reason__c = '';
					project.obj.PM_Reject_Other__c = '';
					project.obj.PM_Submit_Date__c = Datetime.now();
					update project.obj;
				}
				else {
					CFM_PageUtil.addError(project.obj.Project__r.Name + ' ' + Label.CFM_No_Survey_Contact_Error);
					return null;
				}
			}
		}

    	return null;
    }

    public PageReference rejectAction() {
		if (String.isBlank(surveyProjectId)) {
			System.debug('Survey project ID is blank');
			return null;
		}

		for (CFM_SurveyBatchProject project : surveyBatchProjects) {
			if (project.getId() == surveyProjectId) {
				project.obj.PM_Status__c = CFM_SurveyBatchProject.PM_STATUS_REJECT;
				project.obj.Status__c = CFM_SurveyBatchProject.STATUS_REVIEWED;
				project.obj.PM_Reject_Reason__c = rejectReason;
				project.obj.PM_Reject_Other__c = otherRejectReason;
				project.obj.PM_Submit_Date__c = Datetime.now();
				project.save();
			}
		}

    	return null;
    }

    public PageReference editContactAction() {
    	String projectId = CFM_PageUtil.getParam('projectId');

    	for (CFM_SurveyBatchProject project : surveyBatchProjects) {
    		String rowProjectId = (String)project.obj.Id;

			if (projectId == rowProjectId) {
				String projectProfileId = project.obj.Project__c;
				String retUrl = EncodingUtil.urlEncode('/apex/CFM_SurveyBatchPMReview?id=' + surveyBatchReview.getId(), 'UTF-8');
				PageReference pg = new PageReference('/' + projectProfileId + '/e?retURL=' + retUrl);
				pg.setRedirect(true);
				return pg;
			}
		}


		return null;
    }


    public List<SelectOption> getRejectionReasons() {
    	Schema.DescribeFieldResult rejectReason = CFM_Survey_Batch_Project__c.PM_Reject_Reason__c.getDescribe();

		List<Schema.PicklistEntry> rejectReasonList = rejectReason.getPicklistValues();

		List<SelectOption> result = new List<SelectOption>();
		result.add(new SelectOption('', '-- ' + Label.Select + ' --'));
		for (Schema.PicklistEntry entry : rejectReasonList) {
			result.add(new SelectOption(entry.getValue(), entry.getLabel()));
		}

		return result;
    }

}