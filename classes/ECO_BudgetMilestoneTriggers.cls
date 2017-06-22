public with sharing class ECO_BudgetMilestoneTriggers {
	
	public static void RollupMilestones(List<BudgetMilestone__c> tNew, List<BudgetMilestone__c> tOld){
		map<string, Decimal> mRevenue = new map<string, Decimal>();

		if(tNew != null){
			for(BudgetMilestone__c oBudgetMilestone : tNew){
				Date dExDatePlusOffset = oBudgetMilestone.ExDate__c.addDays(oBudgetMilestone.PaymentTermsOffset__c.intValue());
				string sSnapshotKey = ECO_Service_Snapshots.DateToSnapshotKey(dExDatePlusOffset, oBudgetMilestone.Project__c);

				if(oBudgetMilestone.Amount__c != null){
					Decimal dRevenue = ECO_Utils_String.NullCheck(mRevenue.get(sSnapshotKey)) + oBudgetMilestone.Amount__c;

					mRevenue.put(sSnapshotKey, dRevenue);
				}
			}
		}

		if(tOld != null){
			for(BudgetMilestone__c oBudgetMilestone : tNew){
				Date dExDatePlusOffset = oBudgetMilestone.ExDate__c.addDays(oBudgetMilestone.PaymentTermsOffset__c.intValue());
				string sSnapshotKey = ECO_Service_Snapshots.DateToSnapshotKey(dExDatePlusOffset, oBudgetMilestone.Project__c);

				if(oBudgetMilestone.Amount__c != null){
					if(oBudgetMilestone.Amount__c != ECO_Utils_String.NullCheck(mRevenue.get(sSnapshotKey))){
						Decimal dRevenue = ECO_Utils_String.NullCheck(mRevenue.get(sSnapshotKey)) + oBudgetMilestone.Amount__c;

						mRevenue.put(sSnapshotKey, dRevenue);
					}
				}
			}
		}

		system.debug('## ' + mRevenue);

		set<string> lSnapshotKeys = new set<string>();

		for(string s : mRevenue.keySet()){
			lSnapshotKeys.add(s);
		}

		system.debug('## ' + lSnapshotKeys);

		list<WeeklyRollupEntry__c> lWeeklyRollupEntries = new list<WeeklyRollupEntry__c>([SELECT Id
																								   , CompositeKey__c
																								   , Revenue__c
																							  FROM WeeklyRollupEntry__c 
																							  WHERE CompositeKey__c in :lSnapshotKeys]);

		list<WeeklyRollupEntry__c> lWeeklyRollupEntriesToUpdate = new list<WeeklyRollupEntry__c>();

		for(WeeklyRollupEntry__c oWeeklyRollupEntry : lWeeklyRollupEntries){
			string sSnapshotKey = oWeeklyRollupEntry.CompositeKey__c;
			boolean bRecordToAdd = false;

			if(mRevenue.containsKey(sSnapshotKey)){
				oWeeklyRollupEntry.Revenue__c = ECO_Utils_String.NullCheck(oWeeklyRollupEntry.Revenue__c) + mRevenue.get(sSnapshotKey);

				bRecordToAdd = true;
			}

			if(bRecordToAdd)
				lWeeklyRollupEntriesToUpdate.add(oWeeklyRollupEntry);
		}

		if (!lWeeklyRollupEntriesToUpdate.isEmpty()) {
			update lWeeklyRollupEntriesToUpdate;
		}
	}
}