/*************************************************************************
*
* PURPOSE: Data access object for ProcessInstance
*
* CLASS: gng_OppToGNGC
* CREATED: 12/15/2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/

public class gng_ApprovalProcessDao extends gng_BaseDao{

	private static final gng_ApprovalProcessDao apDao = new gng_ApprovalProcessDao();
	
	private gng_ApprovalProcessDao() {
		super('ProcessInstance');
	}

	public static gng_ApprovalProcessDao getInstance() {
		return apDao;
	}

	public void submitApprovalProcess(Id objId,String comment) {
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setComments(comment);
		req.setObjectId(objId);
		Approval.ProcessResult result = Approval.process(req);
	}

	public void approveWorkItem(Id objId, String comment) {
		processWorkItem(objId, comment, 'Approve');
	}

	public void rejectWorkItem(Id objId, String comment) {
		processWorkItem(objId, comment, 'Reject');
	}

	public Boolean recallWorkItem(Id objId, String comment) {
		return processWorkItem(objId, comment, 'Removed');
	}

	public Boolean isUnderApproval(Id objectId) {
		List<ProcessInstanceWorkitem> wiList 
	    = [Select Id, ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId 
	       From ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = :objectId];

        return wiList.size() != 0;
	}

	private Boolean processWorkItem(Id objId, String comment, String action) {
		addFields(new Set<String>{'(Select Id,ActorId,ProcessInstanceId from WorkItems)'});
		String whereStr = 'TargetObjectId = ' + quote(objId);
		String orderStr = 'CREATEDDATE DESC';
		List<ProcessInstance> procList = (List<ProcessInstance>)getsObjects(whereStr,orderStr);
			if(procList.size() > 0 && procList[0].WorkItems.size() > 0) {
				Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
		        req.setComments(comment);
		        req.setAction(action); //This is the action that is approve in your case, you can set it to Reject also
		        req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
		        req.setWorkitemId(procList[0].WorkItems[0].Id);
		        Approval.ProcessResult result =  Approval.process(req);
		        return true;
		    }
		    else return false;
	}
}