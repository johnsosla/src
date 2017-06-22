@istest
private class ECO_GroupedBatchProjectSnapshot_13_Test {
	static testMethod void positiveScheduleBatch_FY2013(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveScheduleBatch('ECO_GroupedBatchProjectSnapshot_FY2013');
	}
	static testMethod void negativeZeroBatchSize_FY2013(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.negativeZeroBatchSize('ECO_GroupedBatchProjectSnapshot_FY2013');
	}
	static testMethod void positiveRunBatch_FY2013(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2013', 'Setup - Snapshot History FY2013', false);
	}
	static testMethod void positiveRunBatch_Block_FY2013(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2013', 'Setup - Snapshot History FY2013', true);
	}
}