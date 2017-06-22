@isTest(seeAllData=false)
private class ECO_Schedule_CreateTaskForProjRvwTest {
	static testMethod void testExecute() {
        Test.startTest();
        ECO_Batch_CreateTaskForProjectReview batch = new ECO_Batch_CreateTaskForProjectReview();
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, batch);
        Test.stopTest();
    }
}