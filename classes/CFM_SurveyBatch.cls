public with sharing class CFM_SurveyBatch extends CFM_BaseModel {

	public static final String STATUS_NEW = 'New';
	public static final String STATUS_PENDING_REVIEW = 'Pending PM review';
	public static final String STATUS_CLOSED = 'Closed but not sent';
	public static final String STATUS_PENDING_SUBMIT = 'Pending Qualtrics submittal';
	public static final String STATUS_SENT = 'Sent to Qualtrics';

	public static Finder find = new Finder();


	public CFM_Survey_Batch__c obj { get 
		{ 
			return (CFM_Survey_Batch__c)mObj; 
		} 
	}

	public CFM_SurveyBatch() {
		this(new CFM_Survey_Batch__c());
	}

	public CFM_SurveyBatch(CFM_Survey_Batch__c sObj) {
		super(sObj);
	}

	public Date getTargetSurveyDate() {
		return obj.Target_Survey_Date__c;
	}

	public String getFormattedTargetSurveyDate() {
		return Datetime.newInstance(obj.Target_Survey_Date__c.year(), obj.Target_Survey_Date__c.month(), obj.Target_Survey_Date__c.day()).format();
	}

	public static List<CFM_SurveyBatch> decorate(List<CFM_Survey_Batch__c> sList) {
		List<CFM_SurveyBatch> result = new List<CFM_SurveyBatch>();
		for (CFM_Survey_Batch__c row : sList) result.add(new CFM_SurveyBatch(row));
		return result;
	}


	public Boolean isClosed() {
		return (obj.Status__c != STATUS_NEW && obj.Status__c != STATUS_PENDING_REVIEW) || 
				(obj.Survey_Close_Date__c != null && obj.Survey_Close_Date__c < Date.today());
	}

	public class Finder extends CFM_BaseFinder {
		public Finder() {
			super('CFM_Survey_Batch__c');
		}

		public CFM_SurveyBatch findById(Id surveyBatchId) {
			CFM_Survey_Batch__c result = (CFM_Survey_Batch__c)byId(surveyBatchId);
			return new CFM_SurveyBatch(result);
		}

		public List<CFM_Survey_Batch__c> findByIds(Set<Id> surveyBatchIds) {
			return (List<CFM_Survey_Batch__c>)Database.query(getSelect() + ' where Id IN: surveyBatchIds');
		}

	}
}