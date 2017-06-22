/*************************************************************************
*
* PURPOSE: Trigger on opportunity that creates/updates/deletes GNG records
*
* CLASS: gng_OppToGNGC
* CREATED: 10/15/2014 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
***************************************************************************/
trigger gng_OppToGNGC on Opportunity (after update, before delete) {
	/*
	Opportunity[] newItems = Trigger.New;
	Opportunity[] oldItems = Trigger.Old;
	
	if(Trigger.isUpdate) {

		Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([select Id, Name from RecordType where sObjectType = 'Opportunity']);

		List<Opportunity> needToCreateGNG = new List<Opportunity>();
		List<Opportunity> needToUpdateGNG = new List<Opportunity>();


		if(Trigger.isUpdate) {
			for(Integer i = 0; i<newItems.size(); i++) {
				if(oldItems[i].AECOM_Primary_Dept_Lookup__c == null && newItems[i].AECOM_Primary_Dept_Lookup__c != null) needToCreateGNG.add(newItems[i]);
				else if (oldItems[i].AECOM_Primary_Dept_Lookup__c != null && newItems[i].AECOM_Primary_Dept_Lookup__c != null) needToUpdateGNG.add(newItems[i]);
			}
		}

		//Create GNG records
		if(needToCreateGNG.size() > 0) {
			Map<String, List<Opportunity>> regionOppMap = new Map<String, List<Opportunity>>();

			for(Opportunity o : needToCreateGNG) {
				if(recordTypeMap.keySet().contains(o.RecordTypeId) && String.isNotBlank(o.Geography_Formula__c)) {
					if(!regionOppMap.keySet().contains(o.Geography_Formula__c)) regionOppMap.put(o.Geography_Formula__c, new List<Opportunity>{o});
					else regionOppMap.get(o.Geography_Formula__c).add(o);
				}
			}
			gng_OppToGNGC.createGNGFromOpportunity(regionOppMap);
		}
		//Update GNG records
		else if(needToUpdateGNG.size() > 0) {
			Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
			for(Opportunity o : needToUpdateGNG) {
				if(recordTypeMap.keySet().contains(o.RecordTypeId) && String.isNotBlank(o.Geography_Formula__c)) oppMap.put(o.Id, o);
			}
			gng_OppToGNGC.updateGNGFromOpportunity(oppMap);
		}
	}
	//delete GNG records
	else if(Trigger.isDelete) {
		Set<id> oppIds = new Set<Id>();
		for(Opportunity o : oldItems) oppIds.add(o.Id);

		gng_OppToGNGC.deleteGNGFromOpportunity(oppIds);
	}	
	*/
}