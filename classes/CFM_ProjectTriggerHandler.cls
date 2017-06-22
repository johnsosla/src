/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM NPS Surveys (ANPS)
*              CLASS: CFM_ProjectTriggerHandler
*              PURPOSE: Trigger handler for CFM_ProjectProfileTrigger
*              CREATED: 07/2016 Ethos Solutions - www.ethos.com
**/
public class CFM_ProjectTriggerHandler {

	public static final String NOTIFY_INITIAL = 'Initial';
	public static final String NOTIFY_RESEND = 'Resend';
    
    public static void handleBeforeInsert(List<Project__c> projects) {
		for (Project__c project : projects) {
			if (String.isBlank(project.Project_Description__c)) {
				if (String.isNotBlank(project.Oracle_Project_Number__c)) {
					project.Project_Description__c = project.Oracle_Project_Number__c;
				}
				else if (String.isNotBlank(project.Name)) {
					project.Project_Description__c = project.Name;
				}
				else {
					project.Project_Description__c = 'No Oracle Project Number or Project Label found.';
				}
			}
		} 
	}
    
    public static void handleBeforeUpdate(Map<Id, Project__c> newMap, Map<Id, Project__c> oldMap) {
		handleUpdatedPmsOnProjects(newMap, oldMap);
	}
    
    private static void handleUpdatedPmsOnProjects(Map<Id, Project__c> newMap, Map<Id, Project__c> oldMap) {
		try {
			System.debug(LoggingLevel.ERROR, 'In handleBeforeUpdate()');

			Set<Id> updatedProjects = new Set<Id>();
			Set<Id> allPmIds = new Set<Id>();

			for (Id projectId : newMap.keySet()) {
				if (newMap.get(projectId).Oracle_Project_Manager_lookup__c != null 
					&& oldMap.get(projectId).Oracle_Project_Manager_lookup__c != null
					&& newMap.get(projectId).Oracle_Project_Manager_lookup__c != oldMap.get(projectId).Oracle_Project_Manager_lookup__c) {
					updatedProjects.add(projectId);

					allPmIds.add(newMap.get(projectId).Oracle_Project_Manager_lookup__c);
					allPmIds.add(oldMap.get(projectId).Oracle_Project_Manager_lookup__c);
				}
			}

			if (updatedProjects.size() > 0) {
				System.debug(LoggingLevel.ERROR, 'UpdatedProjects.size() > 0');

				// All batch projects, whether 
				List<CFM_Survey_Batch_Project__c> allBatchProjects = [Select Id, Project__c, Survey_Batch__c, Project__r.Oracle_Project_Manager_lookup__c 
										from CFM_Survey_Batch_Project__c where 
										(
											Project__c in :updatedProjects
											or Project__r.Oracle_Project_Manager_lookup__c in :allPmIds
										)
										and
										(Status__c =: CFM_SurveyBatch.STATUS_NEW OR Survey_Batch__r.Status__c =: CFM_SurveyBatch.STATUS_PENDING_REVIEW)];

				Map<Id, Map<Id, List<CFM_Survey_Batch_Project__c>>> batchToPmProjectList = getBatchToPmProjectList(allBatchProjects);

				List<CFM_Survey_Batch_Project__c> updatedBatchProjects = new List<CFM_Survey_Batch_Project__c>();
				for (CFM_Survey_Batch_Project__c row : allBatchProjects) {
					if (updatedProjects.contains(row.Project__c)) {
						updatedBatchProjects.add(row);
					}
				}

				Set<Id> surveyBatchIds = new Set<Id>();
				for (CFM_Survey_Batch_Project__c row : updatedBatchProjects) surveyBatchIds.add(row.Survey_Batch__c);


				List<CFM_Survey_Project_Review__c> projectReviews = [Select Id, Status__c, Project_Manager__c, Survey_Batch__c
													  from CFM_Survey_Project_Review__c 
													  where Project_Manager__c in :allPmIds
													  and Survey_Batch__c in :surveyBatchIds];
 
 				Map<String, CFM_Survey_Project_Review__c> batchPmToReviews = new Map<String, CFM_Survey_Project_Review__c>();
 				for (CFM_Survey_Project_Review__c row : projectReviews) {
 					batchPmToReviews.put(row.Survey_Batch__c + '|' + row.Project_Manager__c, row);
 				}

 				checkForUpdatedPmsAndReassignReviews(newMap, updatedProjects, updatedBatchProjects, batchToPmProjectList, batchPmToReviews);
			}
			
		}
		catch (Exception e) {
			String error = 'Error while updating related Scheduled Survey\'s Project_180__c field: ' + e.getMessage() + ' -- ' + e.getStackTraceString();
			CFM_Integration_Log__c log = new CFM_Integration_Log__c(Result__c=error);
            insert log;
			System.debug(LoggingLevel.ERROR, error);
		}
	}
    
    private static void checkForUpdatedPmsAndReassignReviews(Map<Id, Project__c> newMap, 
														Set<Id> updatedProjects, 
														List<CFM_Survey_Batch_Project__c> updatedBatchProjects, 
														Map<Id, Map<Id, List<CFM_Survey_Batch_Project__c>>> batchToPmProjectList,
														Map<String, CFM_Survey_Project_Review__c> batchPmToReviews) 
	{
		Set<Id> notifySurveyBatchIds = new Set<Id>();
		List<CFM_Survey_Project_Review__c> updatedReviews = new List<CFM_Survey_Project_Review__c>();

		for (CFM_Survey_Batch_Project__c batchProject : updatedBatchProjects) {
			System.debug(LoggingLevel.ERROR, 'Checking batch Project: ' + batchProject.Id);

			Id projectId = batchProject.Project__c;
			Id surveyBatchId = batchProject.Survey_Batch__c;
			Id pmId = batchProject.Project__r.Oracle_Project_Manager_lookup__c;

			if (newMap.containsKey(projectId) && batchToPmProjectList.containsKey(surveyBatchId) && batchToPmProjectList.get(batchProject.Survey_Batch__c).containsKey(pmId)) {

				Id newPmId = newMap.get(projectId).Oracle_Project_Manager_lookup__c;

				List<CFM_Survey_Batch_Project__c> pmBatchProjects = batchToPmProjectList.get(surveyBatchId).get(pmId);

				Boolean pmHasOtherProjects = false;

				if (pmBatchProjects.size() > 1) {
					for (CFM_Survey_Batch_Project__c otherBatchProject : pmBatchProjects) {
						if (!updatedProjects.contains(otherBatchProject.Project__c)) {
							pmHasOtherProjects = true;
						}
					}
				}

				if (pmHasOtherProjects) {
					//---Case 2: PM has been reassigned, but has other projects in the batch which have not been reassigned	
					
					String key = surveyBatchId + '|' + newPmId;

					if (!batchPmToReviews.containsKey(key)) {
						System.debug(LoggingLevel.ERROR, 'Case 2a: The pm does not have a project review for this batch. We should create a new one');
						// Case 2a: The pm does not have a project review for this batch. We should create a new one
						CFM_Survey_Project_Review__c  newReview = new CFM_Survey_Project_Review__c(
							Survey_Batch__c = surveyBatchId,
							Status__c = 'Pending Send',
							Project_Manager__c = newPmId
						);

						updatedReviews.add(newReview);
						notifySurveyBatchIds.add(surveyBatchId);
					}
					else {
						System.debug(LoggingLevel.ERROR, 'Case 2b: the new PM already has a project review for this batch');
						// Case 2b: the new PM already has a project review for this batch
						// Nothing to do.
					}
				}
				else {
					System.debug(LoggingLevel.ERROR, 'Re-assigning review to new PM');

					String key = surveyBatchId + '|' + pmId;
					// PM Only has one project in this batch, and it has been re-assigned. We can just change the PM on the old survey review object.
					if (batchPmToReviews.containsKey(key)) {
						
						CFM_Survey_Project_Review__c review = batchPmToReviews.get(key);
						review.Project_Manager__c = newPmId;
						updatedReviews.add(review);
						notifySurveyBatchIds.add(surveyBatchId);
					}
				}
			}
		}

		if (updatedReviews.size() > 0) {
			upsert updatedReviews;

			CFM_NotifyPM_Job handler = new CFM_NotifyPM_Job(notifySurveyBatchIds, updatedReviews);
			Id queuedJobId = System.enqueueJob(handler);
		}
	}
    
    private static Map<Id, Map<Id, List<CFM_Survey_Batch_Project__c>>> getBatchToPmProjectList(List<CFM_Survey_Batch_Project__c> batchProjects) {
		Map<Id, Map<Id, List<CFM_Survey_Batch_Project__c>>> batchToPmProjectList = new Map<Id, Map<Id, List<CFM_Survey_Batch_Project__c>>>();

		for (CFM_Survey_Batch_Project__c row : batchProjects) {
			Id pmId = row.Project__r.Oracle_Project_Manager_lookup__c;
			Id batchId = row.Survey_Batch__c;

			if (!batchToPmProjectList.containsKey(batchId)) {
				batchToPmProjectList.put(batchId, new Map<Id, List<CFM_Survey_Batch_Project__c>>());
			}

			Map<Id, List<CFM_Survey_Batch_Project__c>> pmToProjectList = batchToPmProjectList.get(batchId);

			if (!pmToProjectList.containsKey(pmId)) {
				pmToProjectList.put(pmId, new List<CFM_Survey_Batch_Project__c>());
			}

			pmToProjectList.get(pmId).add(row);
		}

		return batchToPmProjectList;
	}

	public static void handleAfterUpdate(Map<Id, Project__c> newMap, Map<Id, Project__c> oldMap) {


	}
}