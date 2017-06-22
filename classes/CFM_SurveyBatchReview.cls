public class CFM_SurveyBatchReview extends CFM_BaseModel {
	public static Finder find = new Finder('CFM_Survey_Project_Review__c');

	public CFM_Survey_Project_Review__c obj { get { return (CFM_Survey_Project_Review__c)mObj; } }

 	public CFM_SurveyBatchReview(CFM_Survey_Project_Review__c review) {
		super(review);
	}

	public Id getProjectManagerId() {
		return obj.Project_Manager__c;
	}
	
	public class Finder extends CFM_BaseFinder {
		public Finder(String sObjectName) {
			super(sObjectName);
		}

		public CFM_SurveyBatchReview findById(Id projectReviewId) {
			CFM_Survey_Project_Review__c review = (CFM_Survey_Project_Review__c)byId(projectReviewId);
			return new CFM_SurveyBatchReview(review);
		}

		public List<CFM_SurveyBatchReview> findBySurveyBatchId(Id surveyBatchId) {
			List<CFM_SurveyBatchReview> reviews = new List<CFM_SurveyBatchReview>();
			for(CFM_Survey_Project_Review__c review : (List<CFM_Survey_Project_Review__c>)getSelectWhere('Survey_Batch__c', surveyBatchId)) {
				reviews.add(new CFM_SurveyBatchReview(review));
			}
			return reviews;
		}
	}
}