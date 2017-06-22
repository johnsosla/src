global class INC_IncentiveDTWAdminSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		INC_FindDTWAdminForNewIncentiveProjects batch = new INC_FindDTWAdminForNewIncentiveProjects();
		database.executebatch(batch);
	}
}