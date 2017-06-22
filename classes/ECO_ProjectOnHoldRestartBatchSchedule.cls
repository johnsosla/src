global class ECO_ProjectOnHoldRestartBatchSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		ECO_ProjectOnHoldRestartBatch b = new ECO_ProjectOnHoldRestartBatch();
		database.executeBatch(b);
	}
}