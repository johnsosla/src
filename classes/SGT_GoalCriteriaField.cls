/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_LogicRowController
*              PURPOSE: Decorator class for SGT_Goal_Criteria__mdt custom metadata type
*              CREATED: 01/2017 Ethos Solutions - www.ethos.com
**/
public without sharing class SGT_GoalCriteriaField extends SGT_BaseModel {

	public static Finder find = new Finder();

	public SGT_Goal_Criteria__mdt obj { get { return (SGT_Goal_Criteria__mdt)mObj; } }


	public SGT_GoalCriteriaField(SGT_Goal_Criteria__mdt sObj) {
		super(sObj);
	}


	public class Finder extends SGT_BaseFinder {
		public Finder() {
			super('SGT_Goal_Criteria__mdt');
		}

		public SGT_Goal_Criteria__mdt getById(Id objectId) {
			return (SGT_Goal_Criteria__mdt)Database.query(getSelect() + ' WHERE Id = :objectId');
		}

		public List<SGT_Goal_Criteria__mdt> getAll() {
			return (List<SGT_Goal_Criteria__mdt>)Database.query(getSelect());
		}

		public Map<String, SGT_Goal_Criteria__mdt> getMap() {
			List<SGT_Goal_Criteria__mdt> allCriteria = getAll();
			
			Map<String, SGT_Goal_Criteria__mdt> result = new Map<String, SGT_Goal_Criteria__mdt>();

			for (SGT_Goal_Criteria__mdt row : allCriteria) {
				result.put(row.Opportunity_Field_API__c, row);
			}

			return result;
		}
	}
}