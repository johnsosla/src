global class ECO_ProjectClosureSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		ECO_ProjectCountryAlertBatch b = new ECO_ProjectCountryAlertBatch();
		database.executeBatch(b);
	}
}