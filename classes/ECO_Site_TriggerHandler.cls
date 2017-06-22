/** ------------------------------------------------------------------------------------------------------
* @Description The trigger handler for the Site__c object
*
* @Author      NTT Data - Priya Parepalli, Deborah Orth
* @Date        March 2016
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_Site_TriggerHandler {
	
	/**
	 * Deals with updates and finds records that need to have th OUName updated
	 *
	 * @Author  NTT Data - Priya Parepalli, Deborah Orth
	 * @Date    March 2016
	 *
	 * @param   tOld - list of records before trigger fired
	 * @param   tNewMap - map of records after trigger fired
	 * @return  
	 **/
	public static void updateOUName(List<Site__c> tOld, Map<Id, Site__c> tNewMap){
		Set<String> ouIds = new Set<String>();
		Map<String, String> siteIdNameMap = new Map<String, String>();

		//did the Id field change?
		for( Site__c s : tOld){
			if( s.OUId__c != tNewMap.get(s.Id).OUId__c){

				//if they removed the OUId then remove the name too
				if( String.isBlank(tNewMap.get(s.Id).OUId__c)){
					tNewMap.get(s.Id).OUName__c = null;

				} else {
					ouIds.add( tNewMap.get(s.Id).OUId__c);
				}
			}
		}

		//did we find any to process?
		if( !ouIds.isEmpty()){
			//get the data we need to update the trigger records
			for( OrganizationString__c os : [SELECT OUName__c, OUId__c 
											FROM OrganizationString__c 
											WHERE OUId__c IN : ouIds
											ORDER BY CreatedDate]){
				//make sure we don't get duplicates
				if( !siteIdNameMap.containsKey( os.OUId__c)){
					siteIdNameMap.put( os.OUId__c, os.OUName__c);
				}
			}

			//if we find the OUId in the map, then updated the record in the trigger
			for( Id sId : tNewMap.keySet()){
				if( siteIdNameMap.containsKey(tNewMap.get(sId).OUId__c)){
					tNewMap.get(sId).OUName__c = siteIdNameMap.get(tNewMap.get(sId).OUId__c);
				}
			}
		}
	}

	/**
	 * Find the correct OUName for each record and updated before data is persisted in DB
	 *
	 * @Author  NTT Data - Priya Parepalli, Deborah Orth
	 * @Date    May 2016
	 *
	 * @param   tNew - list of records after trigger fired
	 * @return  
	 **/
	public static void insertOUName(List<Site__c> tNew){
		Set<String> ouIds = new Set<String>();
		Map<String, String> siteIdNameMap = new Map<String, String>();

		//make a list of non-blank OUIds
		for( Site__c s : tNew){
			if( !String.isBlank(s.OUId__c)){
				ouIds.add(s.OUId__c);
			}
		}

		//did we find any to process?
		if( !ouIds.isEmpty()){
			//get the data we need to update the trigger records
			for( OrganizationString__c os : [SELECT OUName__c, OUId__c 
											FROM OrganizationString__c 
											WHERE OUId__c IN : ouIds
											ORDER BY CreatedDate]){
				//make sure we don't get duplicates
				if( !siteIdNameMap.containsKey( os.OUId__c)){
					siteIdNameMap.put( os.OUId__c, os.OUName__c);
				}
			}

			//if we find the OUId in the map, then updated the record in the trigger
			for( Site__c s : tNew){
				if( siteIdNameMap.containsKey(s.OUId__c)){
					s.OUName__c = siteIdNameMap.get(s.OUId__c);
				}
			}
		}
	}	

}