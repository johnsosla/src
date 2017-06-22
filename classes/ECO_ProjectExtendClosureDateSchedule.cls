global class ECO_ProjectExtendClosureDateSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		ECO_ProjectExtendClosureDateBatch b = new ECO_ProjectExtendClosureDateBatch();
		database.executeBatch(b);
	}
}