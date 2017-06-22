@isTest
public class ECO_Batch_CreateTaskForProjReviewTest {
	
	static testMethod void testBatchCreateTaskForProjReviewTest() {

		ECO_Batch_CreateTaskForProjectReview batch = new ECO_Batch_CreateTaskForProjectReview();
		Id batchId = Database.executeBatch(batch);
		
	}

	/*static testMethod void testBatchCreateTaskForProjReviewProjectManagerDefined() {

		ECO_Batch_CreateTaskForProjectReview batch = new ECO_Batch_CreateTaskForProjectReview('');
		Id batchId = Database.executeBatch(batch);
		
	}*/

}