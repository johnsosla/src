global class INC_AGGRCalculationScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		Database.executebatch(new INC_AGGRCalculationBatch(), 100);
	}
}