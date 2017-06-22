public with sharing class ECO_PermissionControlTriggers {
	public static Boolean run = true;

	public static void setProjectOwner(List<pse__Permission_Control__c> permissions) {
		if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('PermCtrl_ProjectOwner')) {
			return;
		}

		Set<Id> projectIds = new Set<Id>();
		Map<Id, Id> permissionMap = new Map<Id, Id>();

		for (pse__Permission_Control__c permission : permissions) {
			if ((permission.AccessReason__c == null) || (permission.AccessReason__c != 'Project Owner'))
				continue;

			projectIds.add(permission.pse__Project__c);
			permissionMap.put(permission.pse__Project__c, permission.id);
		}

		List<pse__Proj__c> toUpdate = [select id, Owner_Permission_Control__c from pse__Proj__c where id in :projectIds];

		for (pse__Proj__c project : toUpdate) {
			project.Owner_Permission_Control__c = permissionMap.get(project.id);
		}

		update toUpdate;
	}
}