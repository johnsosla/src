public without sharing class PMC_CertificationTrainingResult extends PMC_BaseModel {

	public static Finder find = new Finder();

	public Pm_Certification_Training_Results__c obj { get { return (Pm_Certification_Training_Results__c)mObj; } }


	public PMC_CertificationTrainingResult() {
		super(new Pm_Certification_Training_Results__c());
	}

	public PMC_CertificationTrainingResult(Pm_Certification_Training_Results__c sObj) {
		super(sObj);
	}

	public static List<PMC_CertificationTrainingResult> decorate(List<Pm_Certification_Training_Results__c> sList) {
		List<PMC_CertificationTrainingResult> result = new List<PMC_CertificationTrainingResult>();
		for (Pm_Certification_Training_Results__c row : sList) result.add(new PMC_CertificationTrainingResult(row));
		return result;
	}

	public Boolean matches(PMC_REST_CompletionTracking.TrainingResult apiResult) {
		return apiResult.curriculumId == obj.Curriculum_Id__c && apiResult.itemId == obj.Item_ID__c;
				//(
				// (apiResult.completionDate == null && obj.Completion_Date__c == null) // Both completion dates are null
				// ||
				// (apiResult.completionDate != null && obj.Completion_Date__c == null) // Filling in the completion date
				// ||
				// (apiResult.completionDate != null && obj.Completion_Date__c != null && apiResult.completionDate == obj.Completion_Date__c)
				//); // Completion date is a match
	}

	public Boolean completionDateIsUpdateOrLater(PMC_REST_CompletionTracking.TrainingResult apiResult) {
		// If existing record has no completion date, or the incoming has a completion date and is later than the one we have
		return obj.Completion_Date__c == null || (apiResult.completionDate != null && apiResult.completionDate >= obj.Completion_Date__c);
	}

	public void updateFromApiResult(PMC_REST_CompletionTracking.TrainingResult apiResult) {
		obj.Completion_Date__c = apiResult.completionDate;
		obj.Curriculum_Id__c = apiResult.curriculumId;
		obj.Grade__c = apiResult.grade;
		obj.Item_Id__c = apiResult.itemId;
		obj.Item_Title__c = apiResult.itemTitle;
		obj.Item_Type__c = apiResult.itemType;
		obj.TrackingId__c = apiResult.trackingId;
	}

	public class Finder extends PMC_BaseFinder {
		public Finder() {
			super('Pm_Certification_Training_Results__c');
		}

		public List<PMC_CertificationTrainingResult> findByCertRequest(Id certificationRequestId) {
			List<Pm_Certification_Training_Results__c> result = Database.query(getSelect() + ' where PM_Candidate_Application__c = :certificationRequestId');
			return decorate(result);
		}

		public List<PMC_CertificationTrainingResult> findByCertRequests(Set<Id> certificationRequestIds) {
			List<Pm_Certification_Training_Results__c> result = Database.query(getSelect() + ' where PM_Candidate_Application__c in :certificationRequestIds');

			return decorate(result);
		}

		public Map<String, List<PMC_CertificationTrainingResult>> findMapByCertRequests(Set<Id> certificationRequestIds) {
			Map<String, List<PMC_CertificationTrainingResult>> resultMap = new Map<String, List<PMC_CertificationTrainingResult>>();

			List<PMC_CertificationTrainingResult> queryResults = findByCertRequests(certificationRequestIds);

			for (PMC_CertificationTrainingResult row : queryResults) {
				if (!resultMap.containsKey(row.obj.PM_Candidate_Application__c)) {
					resultMap.put(row.obj.PM_Candidate_Application__c, new List<PMC_CertificationTrainingResult>());
				}

				resultMap.get(row.obj.PM_Candidate_Application__c).add(row);
			}

			return resultMap;
		}
	}
}