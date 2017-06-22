/** ------------------------------------------------------------------------------------------------------
* @Description The trigger handler for the POLineItem__c object
*
* @Author      NTT Data - ?, Deborah Orth
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_POLineItemTriggers {

	/**
	 * Creates distibution records when a new PO Line Item is added
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   poLineItems - the list of trigger.new entries
	 * @return  
	 **/
	public void createDistributions(List<POLineItem__c> poLineItems){
		List<Distribution__c> distributions = new List<Distribution__c>();
		Set<Id> poHeaderIds = new Set<Id>();
		Set<Id> taskIds = new Set<Id>();

		//get all the PO's and tasks involved
		for( POLineItem__c poLineItem : poLineItems){
			poHeaderIds.add( poLineItem.POHeader__c);
			taskIds.add( poLineItem.ProjectTask__c);
		}

		//get the PO data we need
		Map<Id, POHeader__c> poHeaderDetailMap = new Map<Id, POHeader__c>([SELECT 
																		id, 
																		PO_Date__c 
																	FROM POHeader__c 
																	WHERE Id IN : poHeaderIds]);
		Map<Id, pse__Project_Task__c> taskDetailMap = new Map<Id, pse__Project_Task__c>([SELECT 
																						Id, 
																						pse__Start_Date_Time__c,
																						pse__End_Date_Time__c, 
																						pse__Start_Date__c,
																						pse__End_Date__c 
																					FROM pse__Project_Task__c
																					WHERE Id IN : taskIds]);
	
		for( POLineItem__c poLineItem : poLineItems){
			if(!poLineItem.isArchived__c){
				Distribution__c distribution = new Distribution__c();
				distribution.POLineItem__c = poLineItem.Id;
				//if PO date is in task date range then use it, otherwise use the task start date
				if( poHeaderDetailMap.get(poLineItem.POHeader__c).PO_Date__c < taskDetailMap.get(poLineItem.ProjectTask__c).pse__Start_Date_Time__c.Date()
					|| poHeaderDetailMap.get(poLineItem.POHeader__c).PO_Date__c > taskDetailMap.get(poLineItem.ProjectTask__c).pse__End_Date_Time__c){
					distribution.ExpenditureDate__c = Date.ValueOf(String.valueOf(taskDetailMap.get(poLineItem.ProjectTask__c).pse__Start_Date_Time__c).left(10));
				} else {
					distribution.ExpenditureDate__c = poHeaderDetailMap.get(poLineItem.POHeader__c).PO_Date__c;
				}		
				distributions.add(distribution);
			}
			
		}

		if( !distributions.isEmpty()){
			try {
				insert distributions;
			} catch (Exception e){
				ECO_Service_ErrorLog.logException(e);
			}
		}
	}
}