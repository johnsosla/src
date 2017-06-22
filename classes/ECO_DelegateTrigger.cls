public with sharing class ECO_DelegateTrigger {

	public static Boolean run = true;

	public ECO_DelegateTrigger() {
		
	}

	public static void HandleBeforeInsert(list<Delegate__c> newDelegate){

        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_DelegateTriggerHandleBeforeInsert')) {
            return;
        }

		//populate the Delegator_User__c field from the Delegator__c contact info
		List<Id> contactIds = new List<Id>();
		for(Delegate__c delegate : newDelegate){
			if(delegate.Delegator__c != null){
				contactIds.add(delegate.Delegator__c);
			}
		}

		if(!contactIds.isempty()){
			Map<Id, Contact> contactsMap = new Map<Id, Contact>([Select Id, pse__Salesforce_User__c from Contact where Id In : contactIds]);

			for(Delegate__c delegate : newDelegate){
				delegate.Delegator_User__c = contactsMap.get(delegate.Delegator__c).pse__Salesforce_User__c;
			}		
		}
	}

	public static void ValidateDates(list<Delegate__c> newDelegate){

        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_DelegateTriggerValidateDates')) {
            return;
        }
		
		//Validate in the case that the deleage is not a key member
		
		set<id> sContactIDs = new set<id>();
		set<id> sOrgStringIds = new set<id>();
		list<Delegate__c> lstCheckDelegates = new list<Delegate__c>();
		map<string, list<Delegate__c>> mapNonKeyDelegates = new map<string, list<Delegate__c>>();
		map<string, list<Delegate__c>> mapKeyDelegates = new map<string, list<Delegate__c>>();
		map<id, organizationstring__c> mapOrgString = new map<id, organizationstring__c>();


		for(Delegate__c d: newDelegate){
			sContactIDs.add(d.Delegator__c);
		}

		if(sContactIDs.size() > 0){
			lstCheckDelegates = [select id, 
										Delegate__c, 
										Delegate__r.name,
										Delegator__c, 
										Start_Date__c, 
										End_Date__c, 
										recordtypeid,
										Allowed_Organizations__c,
										Key_Member_Role__c  
								from Delegate__c 
								where Delegator__c IN: sContactIDs];
		}

		if(lstCheckDelegates.size() > 0){
			for(Delegate__c d: lstCheckDelegates){
				if(d.Key_Member_Role__c == null){

					string strKey = d.Delegator__c + '-' + d.recordtypeid;

					if(!mapNonKeyDelegates.containskey(strKey)){
						mapNonKeyDelegates.put(strKey, new list<Delegate__c>());
					}

					mapNonKeyDelegates.get(strKey).add(d);
				} else {

					list<string> lstOrgs = new list<string>();

					if(d.Allowed_Organizations__c!=null){
						lstOrgs = d.Allowed_Organizations__c.split(';');
					}

					for(string orgid: lstOrgs){
						string strKey = d.Delegator__c + '-' + d.Delegate__c + '-' + d.Key_Member_Role__c + '-' + orgid;
						sOrgStringIds.add(orgid);

						if(!mapKeyDelegates.containskey(strKey)){
							mapKeyDelegates.put(strKey, new list<Delegate__c>());
						}

						mapKeyDelegates.get(strKey).add(d);						
					}

				}
			}

			if(sOrgStringIds.size() > 0){
				mapOrgString = new map<id, organizationstring__c>([select id, name from organizationstring__c where id in: sOrgStringIds]);
			}


			for(Delegate__c d: newDelegate){

				if(d.Key_Member_Role__c == null){

					string strKey = d.Delegator__c + '-' + d.recordtypeid;

					if(!mapNonKeyDelegates.containskey(strKey)){
						continue;
					}

					for(Delegate__c dCompare: mapNonKeyDelegates.get(strKey)){
	                    if(dCompare.id != d.id && CompareDates(dCompare, d)){

                    		string strMsg = 'Cannot save delegate due to overlapping start and/or end date with ';

                    		if(dCompare.End_Date__c == null){
                    			d.adderror(strMsg + dCompare.Delegate__r.name + ': ' + dCompare.Start_Date__c + ' - ');
                    		} else {
                        		d.adderror(strMsg + dCompare.Delegate__r.name + ': ' + dCompare.Start_Date__c + ' - ' + dCompare.End_Date__c );
                        	}
	                    }
						
					}

				} else {

					// triple for loop justification: Must compare all the org string dates of existing org string dates of all delegates.

					list<string> lstOrgs = new list<string>();

					if(d.Allowed_Organizations__c!=null){
						lstOrgs = d.Allowed_Organizations__c.split(';');
					}

					for(string orgid: lstOrgs){
						string strKey = d.Delegator__c + '-' + d.Delegate__c + '-' + d.Key_Member_Role__c + '-' + orgid;

						if(!mapKeyDelegates.containskey(strKey)){
							continue;
						}	


						for(Delegate__c dCompare: mapKeyDelegates.get(strKey)){
		                    if(dCompare.id != d.id && CompareDates(dCompare, d)){

	                    		string strMsg = 'Cannot save delegate due to overlapping start and/or end date with ';
	                    		string orgName = '';
	                    		if(mapOrgString.containskey(orgid)){
	                    			orgName = mapOrgString.get(orgid).name;
	                    		}

	                    		if(dCompare.End_Date__c == null){
	                    			d.adderror(strMsg + dCompare.Delegate__r.name + ' - ' + dCompare.Key_Member_Role__c + ' - ' + orgName + ': ' + dCompare.Start_Date__c + ' - ');
	                    		} else {
	                        		d.adderror(strMsg + dCompare.Delegate__r.name + ' - ' + dCompare.Key_Member_Role__c + ' - ' + orgName + ': ' + dCompare.Start_Date__c + ' - ' + dCompare.End_Date__c );
	                        	}
		                    }
							
						}

					}

				}
			}
		}

	}

	public static boolean CompareDates(Delegate__c dCompare, Delegate__c d){
		if(
	        ((d.Start_Date__c >= dCompare.Start_Date__c && (d.Start_Date__c <= dCompare.End_Date__c || dCompare.End_Date__c == null)) ||
	        (d.End_Date__c >= dCompare.Start_Date__c && (d.End_Date__c <= dCompare.End_Date__c || dCompare.End_Date__c == null)))
	        ||
	        ((dCompare.Start_Date__c >= d.Start_Date__c && (dCompare.Start_Date__c <= d.End_Date__c || d.End_Date__c == null)) ||
	        (dCompare.End_Date__c >= d.Start_Date__c && (dCompare.End_Date__c <= d.End_Date__c || d.End_Date__c == null)))                        
        ){
			return true;
        } else {
        	return false;
        }

	}

}