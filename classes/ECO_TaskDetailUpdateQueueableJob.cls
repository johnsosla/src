public class ECO_TaskDetailUpdateQueueableJob implements Queueable {
	List<ECO_TaskDetailController.RemoteTaskWrapper> remoteTasks;

	public ECO_TaskDetailUpdateQueueableJob(List<ECO_TaskDetailController.RemoteTaskWrapper> remoteTasks) {
		this.remoteTasks = remoteTasks;
	}

	public void execute(QueueableContext context) {
		Id jobId = context.getJobId();
        List<ECO_TaskDetailController.ErrorRow> errorRows = ECO_TaskDetailController.updateTasksAsync(remoteTasks);

        String returnValue = JSON.serialize(errorRows);

        // Insert record with return value
        AsyncResponse__c response = new AsyncResponse__c(JobId__c = jobId, ReturnValue__c = returnValue);

        insert response; 
	}
}