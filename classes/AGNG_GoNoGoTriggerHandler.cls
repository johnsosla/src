/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM GoNoGo
*              CLASS: AGNG_GoNoGoTriggerHandler
*              PURPOSE: Trigger handler for AGNG_GoNoGoTrigger 
*              CREATED: 01/2017 Ethos Solutions - www.ethos.com
**/
public class AGNG_GoNoGoTriggerHandler {

	public static final String BID_CODE_WARNING_RT = 'Bid Code Warning';
	public static final String BID_CODE_REQUEST_RT = 'Bid Code Request';
	private static final String DCS_AME_OP_GROUP = 'DCS AME';
	private static final String DCS_AME_OP_GROUP_ALT = 'Americas';
	private static final String LATIN_AME_REGION = 'Latin America';
	private static Map<String, Schema.RecordTypeInfo> mRtInfo = Go_No_Go_Conversation__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    public static map<Id,Opportunity> oppMap = new map<Id, Opportunity>();
	
	public static void handleBeforeInsert(List<Go_No_Go_Conversation__c> newList) {
		setGNGRecordTypes(newList);
	}

	public static void handleBeforeUpdate(Map<Id, Go_No_Go_Conversation__c> newMap, Map<Id, Go_No_Go_Conversation__c> oldMap) {
		setGNGRecordTypes(newMap.values());
	}


	private static void setGNGRecordTypes(List<Go_No_Go_Conversation__c> newList) {
		Set<Id> oppIds = new Set<Id>();
		for(Go_No_Go_Conversation__c conv : newList) {
			oppIds.add(conv.Opportunity__c);
		}
		// Opportunity__r.AECOM_Primary_Dept_Lookup__c
		/*Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([Select Id, AECOM_Primary_Dept_Lookup__r.Lead_District__c,
																	AECOM_Primary_Dept_Lookup__r.Operating_Group__c 
																from Opportunity
																where Id IN: oppIds]);*/
		if (!oppMap.keySet().containsAll(oppIds)) {	
			oppMap = new Map<Id, Opportunity>([Select Id, AECOM_Primary_Dept_Lookup__r.Lead_District__c,
																	AECOM_Primary_Dept_Lookup__r.Operating_Group__c 
																from Opportunity
																where Id IN: oppIds]);			
		}															

		for(Go_No_Go_Conversation__c conv : newList) {
			if(!conv.epmrmassessment__c && 
				oppMap.get(conv.Opportunity__c).AECOM_Primary_Dept_Lookup__r.Lead_District__c != LATIN_AME_REGION &&
				(oppMap.get(conv.Opportunity__c).AECOM_Primary_Dept_Lookup__r.Operating_Group__c == DCS_AME_OP_GROUP
					|| oppMap.get(conv.Opportunity__c).AECOM_Primary_Dept_Lookup__r.Operating_Group__c == DCS_AME_OP_GROUP_ALT)) { 
				conv.RecordTypeId = mRtInfo.get(BID_CODE_WARNING_RT).getRecordTypeId();
			} else if(conv.epmrmassessment__c && 
				oppMap.get(conv.Opportunity__c).AECOM_Primary_Dept_Lookup__r.Lead_District__c != LATIN_AME_REGION &&
				(oppMap.get(conv.Opportunity__c).AECOM_Primary_Dept_Lookup__r.Operating_Group__c == DCS_AME_OP_GROUP
					|| oppMap.get(conv.Opportunity__c).AECOM_Primary_Dept_Lookup__r.Operating_Group__c == DCS_AME_OP_GROUP_ALT)) { 
				conv.RecordTypeId = mRtInfo.get(BID_CODE_REQUEST_RT).getRecordTypeId();
                        if((conv.Program_Ceiling__c >= 100000 || conv.Pursuit_Cost_Total__c >= 50000 || conv.Project_TO_Contract_Rev__c >= 100000) && conv.B_P_Charge_Number__c == null) {
                            conv.Open_a_discrete_B_P_Number__c = 'Yes';
                        }
			}
		}
	}
}