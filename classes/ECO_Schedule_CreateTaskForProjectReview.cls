global class ECO_Schedule_CreateTaskForProjectReview implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {
      ECO_Batch_CreateTaskForProjectReview oB = new ECO_Batch_CreateTaskForProjectReview();
      Database.executeBatch(oB);
    }
}