public with sharing class ECO_VendorSubTriggerHandler {
	
	public static void handleBeforeInsert(list<VendorSub__c> newSubs)
	{
		for(VendorSub__c sub:newSubs)
		{
			sub.Name = sub.VendorName__c;
		}
	}

}