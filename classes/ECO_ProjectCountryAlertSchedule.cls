global class ECO_ProjectCountryAlertSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		ECO_ProjectCountryAlertBatch b = new ECO_ProjectCountryAlertBatch();
		database.executeBatch(b);
	}
}