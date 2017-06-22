public without sharing class PMC_DDPAssignment extends PMC_BaseModel  {

	public PMC_DDP_Assignment__c obj { get { return (PMC_DDP_Assignment__c)mObj; } }

	public PMC_DDPAssignment(PMC_DDP_Assignment__c sobj) {
		super(sobj);
	}

	public static List<PMC_DDPAssignment> decorate(List<PMC_DDP_Assignment__c> sList) {
		List<PMC_DDPAssignment> result = new List<PMC_DDPAssignment>();
		for (PMC_DDP_Assignment__c row : sList) result.add(new PMC_DDPAssignment(row));
		return result;
	}

	public static void assignDdpForCertifications(List<PMCertReq__c> requests, Map<Id, User> candidates) {
		Set<String> ddpNames = new Set<String>();
		Set<String> signatureImageNames = new Set<String>();

		for (PMCertReq__c req : requests) {
			User u = candidates.get(req.Candidate__c);

			PMC_DDP_Assignment__c assignment = getDdpAssignmentForRequest(req, u);

			if (assignment == null) {
				PMC_LogUtil.insertWarning('PMC_DDPAssignment', 'DDP Assignment not found for PMCertReq__c: ' + req.Id, true);
				continue;
			}

			ddpNames.add(assignment.DDP_Name__c);
			ddpNames.add(assignment.Letter_DDP_Name__c);
			if (!String.isBlank(assignment.Signature_1_Name__c)) signatureImageNames.add(assignment.Signature_1_Name__c);
			if (!String.isBlank(assignment.Signature_2_Name__c)) signatureImageNames.add(assignment.Signature_2_Name__c);
		}


		String whereClause = '';
		for (String ddpName : ddpNames) {
			if (whereClause.length() > 0) whereClause += ' OR ';
			whereClause += ' Name like \'' + ddpName + '%\' ';
		}

		List<LOOP__DDP__c> ddps = Database.query('Select Id, Name, (Select Id, Name from LOOP__Custom_Integration_Options__r) from LOOP__DDP__c where ' + whereClause);
		List<Document> signatureImages = [Select Id, Name, DeveloperName from Document where DeveloperName in :signatureImageNames];

		Map<String, LOOP__DDP__c> ddpMap = new Map<String, LOOP__DDP__c>();
		Map<String, Document> signatureMap = new Map<String, Document>();

		for (LOOP__DDP__c row : ddps) ddpMap.put(row.Name, row);
		for (Document row : signatureImages) signatureMap.put(row.DeveloperName, row);

		for (PMCertReq__c req : requests) {
			User u = candidates.get(req.Candidate__c);

			PMC_DDP_Assignment__c assignment = getDdpAssignmentForRequest(req, u);
			if (assignment == null) continue; // Already warned above

			LOOP__DDP__c certificate = ddpMap.get(assignment.DDP_Name__c);
			if (ddpMap.containsKey(assignment.DDP_Name__c + ' ' + u.LanguageLocaleKey)) {
				certificate = ddpMap.get(assignment.DDP_Name__c + ' ' + u.LanguageLocaleKey);				
			}

			LOOP__DDP__c letter = ddpMap.get(assignment.Letter_DDP_Name__c);
			if (ddpMap.containsKey(assignment.Letter_DDP_Name__c + ' ' + u.LanguageLocaleKey)) {
				letter = ddpMap.get(assignment.Letter_DDP_Name__c + ' ' + u.LanguageLocaleKey);
			}

			String sig1 = null;
			String sig2 = null;
			if (!String.isBlank(assignment.Signature_1_Name__c)) sig1 = signatureMap.get(assignment.Signature_1_Name__c).Id + '.jpg';
			if (!String.isBlank(assignment.Signature_2_Name__c)) sig2 = signatureMap.get(assignment.Signature_2_Name__c).Id + '.jpg';

			req.Certificate_DDP_Id__c = certificate.Id;
			req.Letter_DDP_Id__c = letter.Id;

			req.Certificate_Delivery_Id__c = certificate.LOOP__Custom_Integration_Options__r.get(0).Id;
			req.Letter_Delivery_Id__c = letter.LOOP__Custom_Integration_Options__r.get(0).Id;

			req.Signature_1_Id__c = sig1;
			req.Signature_2_Id__c = sig2;


			if (req.Letter_Generation_Status__c == PMC_CertificationRequest.GEN_STATUS_PENDING) {
				req.Letter_Generation_Status__c = PMC_CertificationRequest.GEN_STATUS_GENERATING;
			}
			if (req.Certificate_Generation_Status__c == PMC_CertificationRequest.GEN_STATUS_PENDING) {
				req.Certificate_Generation_Status__c = PMC_CertificationRequest.GEN_STATUS_GENERATING;
			}

		}

		PMC_LogUtil.flush();
	}

	public static PMC_DDP_Assignment__c getDdpAssignmentForRequest(PMCertReq__c req, User u) {
		List<PMC_DDPAssignment> assignments = decorate(PMC_DDP_Assignment__c.getAll().values());

		PMC_DDP_Assignment__c result = null;

		PMC_DDPAssignment superGeoMatch = null;
		PMC_DDPAssignment regionMatch = null;
		PMC_DDPAssignment countryMatch = null;

		// Match on the most specific geography combination that we can find.
		for (PMC_DDPAssignment assignment : assignments) {
			List<String> superGeos =  assignment.obj.Super_Geo__c == null ? new List<String>() : assignment.obj.Super_Geo__c.split(',');
			List<String> regions = assignment.obj.Geo__c == null ? new List<String>() : assignment.obj.Geo__c.split(',');
			List<String> countries = assignment.obj.Country__c == null ? new List<String>() : assignment.obj.Country__c.split(',');

			if (countries.size() > 0) {
				for (String country : countries) {
					if (PMC_StringUtils.equalsIgnoreCase(country,u.Country)) {
						countryMatch = assignment;
					}
				}
			}
			if (countryMatch == null && regions.size() > 0 && countries.size() == 0) {
				for (String region : regions) {
					if (PMC_StringUtils.equalsIgnoreCase(region, u.Geography__c)) {
						regionMatch = assignment;
					}
				}
			}
			if (countryMatch == null && regionMatch == null && superGeos.size() > 0 && countries.size() == 0 && regions.size() == 0) {
				for (String superGeo : superGeos) {
					if (PMC_StringUtils.equalsIgnoreCase(superGeo, u.Supergeography__c)) {
						superGeoMatch = assignment;
					}
				}
			}
		}


		if (superGeoMatch != null) {
			result = superGeoMatch.obj;
		}
		if (regionMatch != null) {
			result = regionMatch.obj;
		}
		if (countryMatch != null) {
			result = countryMatch.obj;
		}

		return result;
	}
}