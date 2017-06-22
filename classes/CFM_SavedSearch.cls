public with sharing class CFM_SavedSearch extends CFM_BaseModel {
	public static Finder find = new Finder('CFM_Survey_Project_Saved_Search__c');

	public CFM_Survey_Project_Saved_Search__c obj { get { return (CFM_Survey_Project_Saved_Search__c)mObj; } }

	public List<CFM_LogicRow> logicRowList { get; set; }
	public Boolean enableFilterLogic { get; set; }
	public String filterLogic { get; set; }


	// To be used when constructing from an existing saved search in the database
	public CFM_SavedSearch(CFM_Survey_Project_Saved_Search__c sObj) {
		super(sObj);
		this.logicRowList = (List<CFM_LogicRow>)JSON.deserialize(sObj.LogicRow_JSON__c, List<CFM_LogicRow>.class);
		this.enableFilterLogic = sObj.Enable_Filter_Logic__c;
		this.filterLogic = sObj.Filter_Logic__c;
	}	

	// To be used when constructing a new saved search or updating an existing
	public CFM_SavedSearch(CFM_Survey_Project_Saved_Search__c sObj, List<CFM_LogicRow> logicRowList, Boolean enableFilterLogic, String filterLogic) {
		super(sObj);
		updateLogic(logicRowList, enableFilterLogic, filterLogic);
	}

	public void updateLogic(List<CFM_LogicRow> logicRowList, Boolean enableFilterLogic, String filterLogic) {
		this.logicRowList = logicRowList;
		this.enableFilterLogic = enableFilterLogic;
		this.filterLogic = filterLogic;
	}

	public override void save() {
		obj.LogicRow_JSON__c = JSON.serialize(logicRowList);
		obj.Enable_Filter_Logic__c = enableFilterLogic;
		obj.Filter_Logic__c = filterLogic;

		upsert obj;
	}

	public static List<CFM_SavedSearch> decorate(List<CFM_Survey_Project_Saved_Search__c> sList) {
		List<CFM_SavedSearch> result = new List<CFM_SavedSearch>();

		for (CFM_Survey_Project_Saved_Search__c row : sList) {
			result.add(new CFM_SavedSearch(row));
		}

		return result;
	}


	public class Finder extends CFM_BaseFinder {
		public Finder(String sObjectName) {
			super(sObjectName);
		}

		public List<CFM_SavedSearch> findAll() {
			List<CFM_Survey_Project_Saved_Search__c> results = Database.query(getSelect() + ' WHERE Is_Default_Inclusion_Criteria__c = false');
			return CFM_SavedSearch.decorate(results);
		}

		public List<CFM_SavedSearch> findByName(String name) {
			List<CFM_Survey_Project_Saved_Search__c> results = Database.query(getSelect() + ' WHERE Name = :name');
			return CFM_SavedSearch.decorate(results);
		}

		public CFM_SavedSearch findDefaultInclusionCriteria() {
			List<CFM_Survey_Project_Saved_Search__c> results = Database.query(getSelect() + ' WHERE Is_Default_Inclusion_Criteria__c = true');
			
			if (results.size() > 0) {
				return new CFM_SavedSearch(results.get(0));
			}

			return null;
		}
	}
}