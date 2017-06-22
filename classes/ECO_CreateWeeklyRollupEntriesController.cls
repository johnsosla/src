public with sharing class ECO_CreateWeeklyRollupEntriesController {
	public ApexPages.StandardController stdController {get; set;}

	public ECO_CreateWeeklyRollupEntriesController(ApexPages.StandardController stdController) {
		this.stdController = stdController;
	}

	public void recalculate() {
		recalculateFuture(stdController.getId());
	}

	public static void recalculateFuture(Id projectId) {
		Set<Id> projectIds = new Set<Id>();
		projectIds.add(projectId);

		ECO_Service_WeeklyRollupEntry.recalculate(projectIds);
	}
}