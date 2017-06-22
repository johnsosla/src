/*************************************************************************
*
* PURPOSE: Trigger to automatically update the status to In Review for cases pulled from queue
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
***************************************************************************/
trigger sshCaseStatusUpdate on Case (before update) {

	Map<Id, Case> oldCaseMap = Trigger.oldMap;
	Map<Id, Case> newCaseMap = Trigger.newMap;
	List<Group> queues = [select Id from Group where Type = 'Queue'];
	Set<Id> queueIds = new Set<Id>();
	if(!queues.isEmpty()){
		for(Group queue : queues) queueIds.add(queue.Id);
	}
	for(Id caseId : newCaseMap.keySet()){
		if(oldCaseMap.containsKey(caseId)){
			Boolean belongedToQueue = queueIds.contains(oldCaseMap.get(caseId).OwnerId) ? true : false;
			if(oldCaseMap.get(caseId).get('Status') == 'Pending' && oldCaseMap.get(caseId).OwnerId != null && belongedToQueue){
				if(oldCaseMap.get(caseId).OwnerId != newCaseMap.get(caseId).OwnerId){
					newCaseMap.get(caseId).Status = 'In Review';
				}
			}
		}
	}

}