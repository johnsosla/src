@istest
private class ECO_GroupedBatchProjectSnapshot_16_Test {
	static testMethod void positiveScheduleBatch_FY2016(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveScheduleBatch('ECO_GroupedBatchProjectSnapshot_FY2016');
	}
	static testMethod void negativeZeroBatchSize_FY2016(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.negativeZeroBatchSize('ECO_GroupedBatchProjectSnapshot_FY2016');
	}
	static testMethod void positiveRunBatch_FY2016(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2016', 'Setup - Snapshot History FY2016', false);
	}
	static testMethod void positiveRunBatch_Block_FY2016(){
		ECO_GroupedBatchProjectSnapshot_FYs_Test.positiveRunBatch('ECO_GroupedBatchProjectSnapshot_FY2016', 'Setup - Snapshot History FY2016', true);
	}
}