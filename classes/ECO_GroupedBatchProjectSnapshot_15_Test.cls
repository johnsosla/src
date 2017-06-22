@istest
private class ECO_GroupedBatchProjectSnapshot_15_Test {
	static testMethod void positiveScheduleBatch_FY2015(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveScheduleBatch('ECO_GroupedBatchProjectSnapshot_FY2015');
	}
	static testMethod void negativeZeroBatchSize_FY2015(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.negativeZeroBatchSize('ECO_GroupedBatchProjectSnapshot_FY2015');
	}
	static testMethod void positiveRunBatch_FY2015(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2015', 'Setup - Snapshot History FY2015', false);
	}
	static testMethod void positiveRunBatch_Block_FY2015(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2015', 'Setup - Snapshot History FY2015', true);
	}
}