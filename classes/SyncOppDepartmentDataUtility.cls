public with sharing class SyncOppDepartmentDataUtility {
	private static Set<ID> processedIds = new Set<ID>();

	public SyncOppDepartmentDataUtility() {
		
	}

	public static void syncOpportunityData(Set<ID> oppIds) {
		List<Opportunity> opps = [SELECT ID
		                         , AECOM_Primary_Dept_Lookup__c
		                         , AECOM_Primary_Department_Percent__c
		                         , Practice_Area_of_Primary_AECOM_Dept__c
		                         , Sub_Practice_Area_of_Primary_AECOM_Dept__c
		                         , AECOM_Department_2__c
		                         , AECOM_Department_2_Practice_Area__c
		                         , AECOM_Department_2_Percent__c
		                         , AECOM_Department_2_Sub_Practice_Area__c
		                         , AECOM_Department_3__c
		                         , AECOM_Department_3_Practice_Area__c
		                         , AECOM_Department_3_Percent__c
		                         , AECOM_Department_3_Sub_Practice_Area__c
		                         , AECOM_Department_4__c
		                         , AECOM_Department_4_Practice_Area__c
		                         , AECOM_Department_4_Percent__c
		                         , AECOM_Department_4_Sub_Practice_Area__c
		                         , AECOM_Department_5__c
		                         , AECOM_Department_5_Practice_Area__c
		                         , AECOM_Department_5_Percent__c
		                         , AECOM_Department_5_Sub_Practice_Area__c
		                         , AECOM_Department_6__c
		                         , AECOM_Department_6_Practice_Area__c
		                         , AECOM_Department_6_Percent__c
		                         , AECOM_Department_6_Sub_Practice_Area__c
		                         , Backup_Processed__c
		                         , (SELECT ID
		                         		   , Primary__c
		                         	       , AECOM_Department__c
		                         	       , split__c
		                         	       , Practice_Area__c
		                         	       , Practice_Area__r.Name
		                         	       , Sub_Practice_Area__c
		                         	       , Sub_Practice_Area__r.Name
		                         	       FROM Opportunity_Departments__r
		                         	       ORDER BY Primary__c DESC, Name)
		                         FROM Opportunity
		                         WHERE ID in :oppIds];

		for(Opportunity opp : opps) {
			if(!processedIds.contains(opp.ID)) {
				//process it
				//backup whats there first
				if(!opp.Backup_Processed__c) {
					opp = backupOppData(opp);
				}
				Integer count = 0;
				for(Opportunity_Department__c dept : opp.Opportunity_Departments__r) {
					//only worried about the first six
					if(count <=5) {
						if(count == 0 && dept.Primary__c) { //just cuz I don't trust this
							opp.AECOM_Primary_Dept_Lookup__c = null;
							opp.AECOM_Primary_Department_Percent__c = null;
							opp.Practice_Area_of_Primary_AECOM_Dept__c = null;
							opp.Sub_Practice_Area_of_Primary_AECOM_Dept__c = null;
							opp.AECOM_Primary_Dept_Lookup__c = dept.AECOM_Department__c;
		                    opp.AECOM_Primary_Department_Percent__c = dept.split__c;
		                    opp.Practice_Area_of_Primary_AECOM_Dept__c = dept.Practice_Area__c;
		                    opp.Sub_Practice_Area_of_Primary_AECOM_Dept__c = dept.Sub_Practice_Area__c;
						} else {
							String label = String.valueOf(count + 1);
							opp.put('AECOM_Department_' + label + '__c', null);
							opp.put('AECOM_Department_' + label + '_Practice_Area__c', null);
							opp.put('AECOM_Department_' + label + '_Percent__c', null);
							opp.put('AECOM_Department_' + label + '_Sub_Practice_Area__c', null);
							opp.put('AECOM_Department_' + label + '__c', dept.AECOM_Department__c);
							opp.put('AECOM_Department_' + label + '_Practice_Area__c', dept.Practice_Area__r.Name);
							opp.put('AECOM_Department_' + label + '_Percent__c', dept.split__c);
							opp.put('AECOM_Department_' + label + '_Sub_Practice_Area__c', dept.Sub_Practice_Area__r.Name);
						}
					}
					count++;
				}
				//add it to the list
				processedIds.add(opp.ID);
				opp.Backup_Processed__c = true;
			}
		}
		Database.update(opps, false);
	}

	private static Opportunity backupOppData(Opportunity opp) {
		opp.Backup_Primary_Dept_Lookup__c = opp.AECOM_Primary_Dept_Lookup__c;
		opp.Backup_Primary_Dept_Percent__c = opp.AECOM_Primary_Department_Percent__c;
		opp.Backup_Primary_Dept_Practice_Area__c = opp.Practice_Area_of_Primary_AECOM_Dept__c;
		opp.Backup_Primary_Dept_Sub_Practice_Area__c = opp.Sub_Practice_Area_of_Primary_AECOM_Dept__c;
		opp.Backup_Department_2__c = opp.AECOM_Department_2__c;
		opp.Backup_Department_2_Practice_Area__c = opp.AECOM_Department_2_Practice_Area__c;
		opp.Backup_Department_2_Percent__c = opp.AECOM_Department_2_Percent__c;
		opp.Backup_Department_2_Sub_Practice_Area__c = opp.AECOM_Department_2_Sub_Practice_Area__c;
		opp.Backup_Department_3__c = opp.AECOM_Department_3__c;
		opp.Backup_Department_3_Practice_Area__c = opp.AECOM_Department_3_Practice_Area__c;
		opp.Backup_Department_3_Percent__c = opp.AECOM_Department_3_Percent__c;
		opp.Backup_Department_3_Sub_Practice_Area__c = opp.AECOM_Department_3_Sub_Practice_Area__c;
		opp.Backup_Department_4__c = opp.AECOM_Department_4__c;
		opp.Backup_Department_4_Practice_Area__c = opp.AECOM_Department_4_Practice_Area__c;
		opp.Backup_Department_4_Percent__c = opp.AECOM_Department_4_Percent__c;
		opp.Backup_Department_4_Sub_Practice_Area__c = opp.AECOM_Department_4_Sub_Practice_Area__c;
		opp.Backup_Department_5__c = opp.AECOM_Department_5__c;
		opp.Backup_Department_5_Practice_Area__c = opp.AECOM_Department_5_Practice_Area__c;
		opp.Backup_Department_5_Percent__c = opp.AECOM_Department_5_Percent__c;
		opp.Backup_Department_5_Sub_Practice_Area__c = opp.AECOM_Department_5_Sub_Practice_Area__c;
		opp.Backup_Department_6__c = opp.AECOM_Department_6__c;
		opp.Backup_Department_6_Practice_Area__c = opp.AECOM_Department_6_Practice_Area__c;
		opp.Backup_Department_6_Percent__c = opp.AECOM_Department_6_Percent__c;
		opp.Backup_Department_6_Sub_Practice_Area__c = opp.AECOM_Department_6_Sub_Practice_Area__c;
		return opp;
	}
}