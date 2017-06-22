public class PMC_CertificateGeneration_Job implements Schedulable, Database.Batchable<sObject>, Database.Stateful {

	private Boolean isAssignment = false;
	private Boolean isEmail = false;

	public PMC_CertificateGeneration_Job() {
		
	}

	public PMC_CertificateGeneration_Job(Boolean isAssignment, Boolean isEmail) {
		this.isAssignment = isAssignment;
		this.isEmail = isEmail;
	}


	public void execute(SchedulableContext sc) {
		PMC_LogUtil.insertDebug('PMC_CertificateGeneration_Job', 'PMC_CertificateGeneration_Job Job Started', false);
		PMC_CertificateGeneration_Job assignmentBatch = new PMC_CertificateGeneration_Job(true, false);
		Database.executeBatch(assignmentBatch, 100);

		PMC_CertificateGeneration_Job emailBatch = new PMC_CertificateGeneration_Job(false, true);
		Database.executeBatch(emailBatch, 5);
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		
		if (isAssignment) {
			PMC_LogUtil.insertDebug('PMC_CertificateGeneration_Job', 'PMC_CertificateGeneration_Job assignment batch Started', false);

			return Database.getQueryLocator([Select
				Id,
				Letter_Generation_Status__c,
				Certificate_Generation_Status__c,
				Candidate__c
				from PMCertReq__c
				where 
				(Letter_Generation_Status__c = :PMC_CertificationRequest.GEN_STATUS_PENDING or Certificate_Generation_Status__c = :PMC_CertificationRequest.GEN_STATUS_PENDING)
			]);
		}
		else if (isEmail) {
			PMC_LogUtil.insertDebug('PMC_CertificateGeneration_Job', 'PMC_CertificateGeneration_Job email batch Started', false);

			return Database.getQueryLocator([Select
				Id,
				Letter_Generation_Status__c,
				Certificate_Generation_Status__c,
				Candidate__c
				from PMCertReq__c
				where 
				(Letter_Generation_Status__c = :PMC_CertificationRequest.GEN_STATUS_COMPLETE and Certificate_Generation_Status__c = :PMC_CertificationRequest.GEN_STATUS_COMPLETE)
			]);
		}

		// Invalid state
		return null;
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		try {
			List<PMCertReq__c> certReqs = (List<PMCertReq__c>)scope; 

			List<Id> candidateIds = new List<Id>();
			for (PMCertReq__c row : certReqs) candidateIds.add(row.Candidate__c);

			if (isAssignment) {
				assignDdpsForCertifications(certReqs, candidateIds);
			}
			else if (isEmail) {
				sendEmailsForCertifications(certReqs, candidateIds);
			}
		}
		catch (Exception e) {
			String mode = isEmail ? 'email' : 'assignment';
			PMC_LogUtil.insertError('PMC_CertificateGeneration_Job', 'Error while executing ' + mode + ': ' + e.getMessage() + ' -- ' + e.getStackTraceString());
		}
	}

	private static void assignDdpsForCertifications(List<PMCertReq__c> certReqs, List<Id> candidateIds) {
		PMC_LogUtil.insertDebug('PMC_CertificateGeneration_Job', 'PMC_CertificateGeneration_Job Assignment Executed Batch: ' + certReqs.size(), false);
				
		Map<Id, User> candidates = new Map<Id, User>([Select Id, LanguageLocaleKey, Supergeography__c, Geography__c, Country from User where Id in :candidateIds]);

		PMC_DDPAssignment.assignDdpForCertifications(certReqs, candidates);

		update certReqs;
	}
 
	private static void sendEmailsForCertifications(List<PMCertReq__c> certReqs, List<Id> candidateIds) {
		PMC_Settings__c settings = PMC_Settings__c.getOrgDefaults();

		PMC_LogUtil.insertDebug('PMC_CertificateGeneration_Job', 'PMC_CertificateGeneration_Job Email Executed Batch: ' + certReqs.size(), false);

		Map<Id, Id> usersToContacts = CFM_UserManagement.getContactIdsForUsers(candidateIds);

		// Get the email template
		EmailTemplate template = [Select Id from EmailTemplate where DeveloperName = 'PM_Cert_notify_Candidate_final_App_HTML'];

		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

		for (PMCertReq__c row : certReqs) {
			// We are running a batch size of 5 so it's ok that this is not bulkified. We need to query the attachments individually to avoid heap size limits

			// Query attachments for this record
			List<Attachment> attachList = [Select Id, Name, Body from Attachment where ParentId = :row.Id and (Name = :settings.Letter_File_Name__c or Name = :settings.Certificate_File_Name__c)];

			if (attachList.size() >= 2) {
				// De-duplicate in case the file has been generated twice
				Map<String, Attachment> attachMap = new Map<String, Attachment>();
				for (Attachment a : attachList) attachMap.put(a.Name, a);

				// Only send if we have both the letter and the certificate

				// Send the email, with the attachments
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTemplateId(template.Id);
                message.setSaveAsActivity(false);
                message.setTargetObjectId(usersToContacts.get(row.Candidate__c));
                message.setWhatId(row.Id);

                if (!String.isBlank(settings.Org_Wide_Email_Address_ID__c)) {
                	message.setOrgWideEmailAddressId(settings.Org_Wide_Email_Address_ID__c);
                }

               	List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
               	for (Attachment a : attachMap.values()) {
               		Messaging.EmailFileAttachment emailAttach = new Messaging.EmailFileAttachment();
               		emailAttach.setFileName(a.Name);
               		emailAttach.setBody(a.Body);
               		fileAttachments.add(emailAttach);
               	}

               	message.setFileAttachments(fileAttachments);

                messages.add(message);

                row.Letter_Generation_Status__c = PMC_CertificationRequest.GEN_STATUS_SENT;
                row.Certificate_Generation_Status__c = PMC_CertificationRequest.GEN_STATUS_SENT;
			}

			
		}

		Messaging.sendEmail(messages);

		List<Database.SaveResult> results = Database.update(certReqs, false);
		for (Database.SaveResult result : results) {
			if (!result.isSuccess()) {
				PMC_LogUtil.insertError('PMC_CertificateGeneration_Job', 'Error while sending requests: ' + JSON.serialize(result.getErrors()));
			}
		}
	}

	public void finish(Database.BatchableContext BC) {
		if (isEmail) {
			PMC_LogUtil.insertDebug('PMC_CertificateGeneration_Job', 'PMC_CertificateGeneration_Job Email Finished', false);
		}
		else {
			PMC_LogUtil.insertDebug('PMC_CertificateGeneration_Job', 'PMC_CertificateGeneration_Job Assignment Finished', false);	
		}
		
	}
}