trigger INC_User_AllEvents on User (after update) {

	set<string> sUserIDs = new set<string>();

	if(trigger.isUpdate && trigger.isAfter){
		for(user u: trigger.new){
			if(u.isactive == false && u.isactive != trigger.oldMap.get(u.id).isactive){
				sUserIDs.add(u.id);
			}
		}

		if(sUserIDs.size() >0){
			INC_UserAllEventsTrigger.UpdateEnrollAppsInactiveUser(sUserIDs);
		}

	}
}