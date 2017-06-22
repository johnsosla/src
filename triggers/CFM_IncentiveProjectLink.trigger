/*************************************************************************
*
* PURPOSE: Link the project profile record to the incentive project record, 
*          based on project number. If this trigger needs to be disabled,
*          see the CFM Survey Settings custom setting for the checkbox
*          to disable this trigger
*
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington (npilkington@ethos.com)
***************************************************************************/
trigger CFM_IncentiveProjectLink on IncentiveProject__c (after insert, after update) {
	if (!CFM_Survey_Settings__c.getOrgDefaults().Disable_Incentive_Project_Link__c) {
		try {
			CFM_IncentiveProjectLink.linkFromIncentiveProject(Trigger.newMap);
		}
		catch (Exception e) {
			System.debug('Error while linking Incentive Project to Project Profile: ' + e.getMessage() + ' -- ' + e.getStackTraceString());
		}

	}
}