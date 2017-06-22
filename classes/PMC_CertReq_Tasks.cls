public class PMC_CertReq_Tasks {
	public static void handleAfterUpdate(Map<Id, PMCertReq__c> oldMap, Map<Id, PMCertReq__c> newMap) {
		List<Task> taskProcessList = new List<Task>();

		Set<Id> userIds = new Set<Id>();

		for (PMCertReq__c newRow : newMap.values()) {
			if (newRow.PLMgr__c != null) userIds.add(newRow.PLMgr__c);
			if (newRow.Sponsor__c != null) userIds.add(newRow.Sponsor__c);
			if (newRow.Interviewer__c != null) userIds.add(newRow.Interviewer__c);
		}

		List<Task> oldTasks = [Select Id, WhatId, Status from Task where WhatId IN :newMap.keySet() and Status != 'Completed'];
        Map<Id, Task> oldTaskMap = new Map<Id, Task>();
        for (Task t : oldTasks) oldTaskMap.put(t.WhatId, t); 

        List<PMC_Task_Subject_Description__c> taskSubjects = PMC_Task_Subject_Description__c.getAll().values();
        Map<String, PMC_Task_Subject_Description__c> subjectsByLanguage = new Map<String, PMC_Task_Subject_Description__c>();
        for (PMC_Task_Subject_Description__c subject : taskSubjects) subjectsByLanguage.put(subject.Language_Code__c, subject);

		Map<Id, User> users = new Map<Id, User>([Select Id, Name, LanguageLocaleKey from User where Id in :userIds]);

		for (PMCertReq__c newRow : newMap.values()) {
			PMCertReq__c oldRow = oldMap.get(newRow.Id);

			Boolean closeOldTask = false;
 			
 			if (newStatus(oldRow, newRow, PMC_CertificationRequest.STATUS_SPONSOR_END_REQUESTED) && newRow.Sponsor__c != null) {
 				PMC_Task_Subject_Description__c subject = getTaskSubject(subjectsByLanguage, users.get(newRow.Sponsor__c));
 				taskProcessList.add(createTask(newRow.Sponsor__c, newRow.Id, subject.Task_Subject__c, subject.Sponsor_Endorsement_Description__c));
 			}
 			if (oldStatus(oldRow, newRow, PMC_CertificationRequest.STATUS_SPONSOR_END_REQUESTED)) {
 				closeOldTask = true;
 			}
 			if (newStatus(oldRow, newRow, PMC_CertificationRequest.STATUS_TRAINING_APP_REQUESTED) && newRow.PLMgr__c != null) {
 				PMC_Task_Subject_Description__c subject = getTaskSubject(subjectsByLanguage, users.get(newRow.PLMgr__c));
 				taskProcessList.add(createTask(newRow.PLMgr__c, newRow.Id, subject.Task_Subject__c, subject.Training_Approval_Description__c));
 			}
 			if (oldStatus(oldRow, newRow, PMC_CertificationRequest.STATUS_TRAINING_APP_REQUESTED)) {
 				closeOldTask = true;
 			}
 			if (newStatus(oldRow, newRow, PMC_CertificationRequest.STATUS_SCHEDULE_INTERVIEW) && newRow.Interviewer__c != null) {
 				PMC_Task_Subject_Description__c subject = getTaskSubject(subjectsByLanguage, users.get(newRow.Interviewer__c));
 				taskProcessList.add(createTask(newRow.Interviewer__c, newRow.Id, subject.Task_Subject__c, subject.Interviewer_Endorsement_Description__c));
 			}
 			if (oldStatus(oldRow, newRow, PMC_CertificationRequest.STATUS_SCHEDULE_INTERVIEW)) {
 				closeOldTask = true;
 			}
 			if (newStatus(oldRow, newRow, PMC_CertificationRequest.STATUS_AWAITING_APPROVAL) && newRow.PLMgr__c != null) {
 				PMC_Task_Subject_Description__c subject = getTaskSubject(subjectsByLanguage, users.get(newRow.PLMgr__c));
 				taskProcessList.add(createTask(newRow.PLMgr__c, newRow.Id, subject.Task_Subject__c, subject.Final_Approval_Task_Description__c));
 			}
 			if (oldStatus(oldRow, newRow, PMC_CertificationRequest.STATUS_AWAITING_APPROVAL)) {
 				closeOldTask = true;
 			}


 			if (closeOldTask && oldTaskMap.containsKey(newRow.Id)) {
 				Task t = oldTaskMap.get(newRow.Id);
 				t.Status = 'Completed';
 				taskProcessList.add(t);
 			}
		}


		if (taskProcessList.size() > 0) {
			upsert taskProcessList;
		}
	}

	private static PMC_Task_Subject_Description__c getTaskSubject(Map<String, PMC_Task_Subject_Description__c> subjectsByLanguage, User user) {
		if (subjectsByLanguage.containsKey(user.LanguageLocaleKey)) {
			return subjectsByLanguage.get(user.LanguageLocaleKey);
		}
		else if (subjectsByLanguage.containsKey('en_US')) { // Default to English
			return subjectsByLanguage.get('en_US');
		}

		throw new NoTaskDescriptionSetupException();
	}

	private static Task createTask(Id assignee, Id whatId, String subject, String description) {
		Id taskRtId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('ECO Tasks').getRecordTypeId();

		Task newTask = new Task();
        newTask.Subject = subject;
        newTask.Description = description;
        newTask.Status = 'Not Started';
        newTask.Priority = 'Normal';
        newTask.Type = 'Other';
        newTask.OwnerId = assignee;
        newTask.RecordTypeId = taskRtId;
        newTask.WhatId = whatId; 
        return newTask;
	}

	private static Boolean newStatus(PMCertReq__c oldRow, PMCertReq__c newRow, String statusVal) {
		// Status was changed from something else, to the new value
		return (oldRow.CertificationRequestStatus__c != statusVal && newRow.CertificationRequestStatus__c == statusVal);
	}

	private static Boolean oldStatus(PMCertReq__c oldRow, PMCertReq__c newRow, String statusVal) {
		// Status was changed from the value, to something else
		return (oldRow.CertificationRequestStatus__c == statusVal && newRow.CertificationRequestStatus__c != statusVal);
	}

	private class NoTaskDescriptionSetupException extends Exception { 
	}
}