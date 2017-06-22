public with sharing class CFM_SurveyBatchController {

    public CFM_Survey_Batch__c surveyBatch {get; set;}
    
    public CFM_SurveyBatchController(ApexPages.StandardController stdController) {
        surveyBatch = (CFM_Survey_Batch__c)CFM_SurveyBatch.find.byId(stdController.getId());
    }
    
    // Mark the survey as closed, setting close date
    public PageReference closeAction() {
        if (surveyBatch.Status__c == CFM_SurveyBatch.STATUS_PENDING_REVIEW) {  
            surveyBatch.Survey_Close_Date__c = DateTime.now().date();
            surveyBatch.Status__c = CFM_SurveyBatch.STATUS_PENDING_SUBMIT;
            update surveyBatch;


            List<CFM_SurveyBatchProject> batchProjects = CFM_SurveyBatchProject.find.findConfirmedProjects(surveyBatch.Id);

            for (CFM_SurveyBatchProject row : batchProjects) {
                row.obj.Status__c = CFM_SurveyBatchProject.STATUS_PENDING_QSUBMIT;
            }

            CFM_BaseModel.save(batchProjects);

            // Auto-Complete tasks that have not been reviewed by PMs
            Set<Id> taskParentIds = new Set<Id>();
            for(CFM_SurveyBatchReview review : CFM_SurveyBatchReview.find.findBySurveyBatchId(surveyBatch.Id)) {
                taskParentIds.add(review.getId());
            }
            List<Task> reviewTasks = [Select Id, Status from Task where WhatId IN: taskParentIds and Status != 'Completed'];
            for(Task t : reviewTasks) {
                t.Status = 'Completed';
            }
            update reviewTasks;
        }

        return new PageReference('/' + surveyBatch.Id);
    }

    public PageReference generateCSVPreviewAction() {
        if (surveyBatch.Status__c == CFM_SurveyBatch.STATUS_PENDING_SUBMIT) {
            List<CFM_SurveyBatchProject> batchProjects = CFM_SurveyBatchProject.find.findProjectsPendingSubmit(surveyBatch.Id);
            batchProjects = CFM_SurveyBatchProject.removeDuplicatesAndDoNotSurvey(batchProjects);

            if (batchProjects.size() > 0) {
                CFM_SurveyBatchProjectCSVGenerator generator = new CFM_SurveyBatchProjectCSVGenerator(batchProjects);
                CFM_CSVGenerator.CFM_CSVResult result = generator.generateCSV(true);

                return new PageReference('/servlet/servlet.FileDownload?file=' + result.CsvAttachId);
            }
            else {
                CFM_PageUtil.addError('No projects found to include in the CSV');
                return null;
            }
        }
        else {
            CFM_PageUtil.addError('Preview can only be generated when batch has been closed');
        }

        return null;
    }
    
    // Mark the survey to be picked up by Qualtrics
    public PageReference submitAction() {
        if (surveyBatch.Status__c == CFM_SurveyBatch.STATUS_PENDING_SUBMIT) {
            surveyBatch.Status__c = CFM_SurveyBatch.STATUS_SENT;
            surveyBatch.Survey_Sent_Date__c = DateTime.now().date();
            update surveyBatch; 

            List<CFM_SurveyBatchProject> batchProjects = CFM_SurveyBatchProject.find.findProjectsPendingSubmit(surveyBatch.Id);
            batchProjects = CFM_SurveyBatchProject.removeDuplicatesAndDoNotSurvey(batchProjects);
            for (CFM_SurveyBatchProject row : batchProjects) {
                row.obj.Status__c = CFM_SurveyBatchProject.STATUS_SENT;
                row.obj.Qualtrics_Status__c = 'Ready For Transmission';
            }

            CFM_BaseModel.save(batchProjects);

            CFM_SurveyBatchProjectCSVGenerator generator = new CFM_SurveyBatchProjectCSVGenerator(batchProjects);
            CFM_CSVGenerator.CFM_CSVResult result = generator.generateCSV(false);
            CFM_DebugUtils.log('result', result);

            CFM_LastSurveyDateUpdater.updateLastSurveyDates(batchProjects);
            
            //---Async for both callout time limitations and for heap limits (building the body of the request was erroring out on the heap)
            CFM_QualtricsAsyncIntegrationHandler handler = new CFM_QualtricsAsyncIntegrationHandler(new CFM_SurveyBatch(surveyBatch), result.CsvContents);
            Id queuedCalloutJobId = System.enqueueJob(handler);
        }

        return new PageReference('/' + surveyBatch.Id);
    }

    // Notify the PMs to review the projects
    public PageReference notifyPmAction() {
        if (surveyBatch.Status__c != CFM_SurveyBatch.STATUS_NEW && surveyBatch.Status__c != CFM_SurveyBatch.STATUS_PENDING_REVIEW) {
            // Cannot submit for review unless in new or pending review status.
            // It might be in pending review status if the survey admin adds additional projects to the batch after sending out previous ones for review
            return new PageReference('/' + surveyBatch.Id);
        }


        surveyBatch.Status__c = CFM_SurveyBatch.STATUS_PENDING_REVIEW;
        update surveyBatch;

        List<CFM_Survey_Project_Review__c> existingReviews = [Select Id, Status__c, Project_Manager__c from CFM_Survey_Project_Review__c where Survey_Batch__c = :surveyBatch.Id];
        Map<Id, CFM_Survey_Project_Review__c> projectManagerToReview = new  Map<Id, CFM_Survey_Project_Review__c>();

        for (CFM_Survey_Project_Review__c review : existingReviews) {
            projectManagerToReview.put(review.Project_Manager__c, review);
        }

        List<CFM_Survey_Project_Review__c> reviews = new List<CFM_Survey_Project_Review__c>();

        List<CFM_Survey_Batch_Project__c> surveyProjects = CFM_SurveyBatchProject.find.findSurveyProjectsForNotification(SurveyBatch.Id);


        // Group the projects by project manager, so we will only send one notification to the PM
        Map<Id, List<CFM_Survey_Batch_Project__c>> projectManagerToSurveyProjects = new Map<Id, List<CFM_Survey_Batch_Project__c>>();

        for (CFM_Survey_Batch_Project__c row : surveyProjects) {
            Id projectManagerId = row.Project__r.Oracle_Project_Manager_lookup__c;
            System.debug('Project manager ID: ' + projectManagerId);
            if (!String.isBlank(projectManagerId)) {
                if (!projectManagerToSurveyProjects.containsKey(projectManagerId)) {
                    projectManagerToSurveyProjects.put(projectManagerId, new List<CFM_Survey_Batch_Project__c>());
                }

                projectManagerToSurveyProjects.get(projectManagerId).add(row);
            }
        }

        // For each project manager, create the Survey Review header object and mark the survey project status
        for (Id projectManagerId : projectManagerToSurveyProjects.keySet()) {
            if (!projectManagerToReview.containsKey(projectManagerId)) {
                CFM_Survey_Project_Review__c review = new CFM_Survey_Project_Review__c();
                review.Survey_Batch__c = surveyBatch.Id;
                review.Status__c = 'Pending Send';
                review.Project_Manager__c = projectManagerId;
                reviews.add(review);
            }
        }

        insert reviews;

        CFM_NotifyPM_Batch b = new CFM_NotifyPM_Batch(surveyBatch.Id);

        Database.executeBatch(b, 200);
    
        return new PageReference('/' + surveyBatch.Id);
    }
}