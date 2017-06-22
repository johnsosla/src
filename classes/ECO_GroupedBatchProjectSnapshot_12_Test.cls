@istest
private class ECO_GroupedBatchProjectSnapshot_12_Test {
	static testMethod void positiveScheduleBatch_FY2012(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveScheduleBatch('ECO_GroupedBatchProjectSnapshot_FY2012');
	}
	static testMethod void negativeZeroBatchSize_FY2012(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.negativeZeroBatchSize('ECO_GroupedBatchProjectSnapshot_FY2012');
	}
	static testMethod void positiveRunBatch_FY2012(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2012', 'Setup - Snapshot History FY2012', false);
	}
	static testMethod void positiveRunBatch_Block_FY2012(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2012', 'Setup - Snapshot History FY2012', true);
	}
}