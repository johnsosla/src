global class ECO_TaskSyncSchedulable implements Schedulable{

	global void execute(SchedulableContext sc) {
		ECO_Service_ProjectSync.initiateTaskSyncLaterProcessing();
   }
}