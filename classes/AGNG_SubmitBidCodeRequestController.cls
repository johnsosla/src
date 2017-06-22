/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM GoNoGo
*              CLASS: AGNG_SubmitBidCodeRequestController
*              PURPOSE: Controller for AGNG_SubmitBidCodeRequest page 
*              CREATED: 01/2017 Ethos Solutions - www.ethos.com
**/
public without sharing class AGNG_SubmitBidCodeRequestController {

	private Go_No_Go_Conversation__c conv;
	public static final String SYS_ADMIN = 'System Administrator';
	public static final String GEO_ADMIN = 'Geography Administrator';
	public static final String BUS_ADMIN = 'Business Administrator';
	public AGNG_SubmitBidCodeRequestController(ApexPages.StandardController std) {
		conv = (Go_No_Go_Conversation__c)std.getRecord();
	}

	public PageReference submitBidCode() {
		//--- We're going to be firing a workflow rule that sets the B&P Charge Code
		//--- and send an email to finance to open a B&P #
		//--- WF - AGNG - Submit Bid Code Request
		User u = [Select Id, Profile.Name from User where Id =: UserInfo.getUserId()];

		if(u.Profile.Name == SYS_ADMIN ||
			u.Profile.Name == GEO_ADMIN ||
			u.Profile.Name == BUS_ADMIN) {
			conv.B_P_Charge_Number__c = null;
			update conv;
		}
		return new PageReference('/' + conv.Id);
	}
}