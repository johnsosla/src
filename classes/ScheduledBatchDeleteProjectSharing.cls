global class ScheduledBatchDeleteProjectSharing implements Schedulable{

    global void execute(SchedulableContext sc)
    {
        BatchDeleteProjectSharing myBatchObject = new BatchDeleteProjectSharing();
        Database.executeBatch(myBatchObject);
    }        
}