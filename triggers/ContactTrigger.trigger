trigger ContactTrigger on Contact (before insert, after insert, before update) {

	if ( trigger.isAfter && trigger.isInsert ){

		HRS_ContactHandler.assignEntitlementContact( Trigger.New );

	}
    
    //Check if there are any duplicate contacts.
    //This code has been added to address the duplicate contact issue.
	//if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
	//	HRS_ContactHandler.checkForDuplicateContacts(Trigger.New);
	//}    
}