@istest
private class ECO_GroupedBatchProjectSnapshot_17_Test {
	static testMethod void positiveScheduleBatch_FY2017(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveScheduleBatch('ECO_GroupedBatchProjectSnapshot_FY2017');
	}
	static testMethod void negativeZeroBatchSize_FY2017(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.negativeZeroBatchSize('ECO_GroupedBatchProjectSnapshot_FY2017');
	}
	static testMethod void positiveRunBatch_FY2017(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2017', 'Setup - Snapshot History FY2017', false);
	}
	static testMethod void positiveRunBatch_Block_FY2017(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2017', 'Setup - Snapshot History FY2017', true);
	}
}