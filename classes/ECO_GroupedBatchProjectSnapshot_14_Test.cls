@istest
private class ECO_GroupedBatchProjectSnapshot_14_Test {
	static testMethod void positiveScheduleBatch_FY2014(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveScheduleBatch('ECO_GroupedBatchProjectSnapshot_FY2014');
	}
	static testMethod void negativeZeroBatchSize_FY2014(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.negativeZeroBatchSize('ECO_GroupedBatchProjectSnapshot_FY2014');
	}
	static testMethod void positiveRunBatch_FY2014(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2014', 'Setup - Snapshot History FY2014', false);
	}
	static testMethod void positiveRunBatch_Block_FY2014(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2014', 'Setup - Snapshot History FY2014', true);
	}
}