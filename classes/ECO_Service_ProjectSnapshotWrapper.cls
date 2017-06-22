public with sharing class ECO_Service_ProjectSnapshotWrapper {
	
	public ECO_Service_ProjectSnapshotWrapper() {
		
	}
	
	/*@InvocableMethod(label='ProjectSnapshot' Description='Test')
	public static void executeBatch(List<String> pId) {
		Id projId = Id.valueOf(pId[0]);
		List<pse__Proj__c> projList = [SELECT Id FROM pse__Proj__c WHERE Id = : projId];
		ECO_Service_ProjectSnapshotBatch.execute2(projList);
	}*/
	
	/*
	@InvocableMethod(label='ProjectSnapshot' Description='Test')
	public static void batchRun(List<String> pId) {
		List<Id> pIdList = new List<Id>();
		for (String pIdStr : pId) {
			pIdList.add(Id.valueOf(pIdStr));
		}
		
		ECO_Service_ProjectSnapshotBatch psBatch = new ECO_Service_ProjectSnapshotBatch();
		psBatch.projectIdList = pIdList;
		database.executeBatch(psBatch, 1);
	}
	*/
}