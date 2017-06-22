global class ECO_ProjectClosureRecommendationSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		ECO_ProjectClosureRecommendationBatch b = new ECO_ProjectClosureRecommendationBatch();
		database.executeBatch(b);
	}
}