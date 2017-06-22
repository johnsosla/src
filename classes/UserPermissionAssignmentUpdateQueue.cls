public class UserPermissionAssignmentUpdateQueue implements Queueable {

	private List<PermissionSetAssignment> permissionSetAssignmentToRemove;
	private List<PermissionSetAssignment> permissionSetAssignmentToUpdate;

	public UserPermissionAssignmentUpdateQueue(List<PermissionSetAssignment> toRemove, List<PermissionSetAssignment> toUpdate){

		permissionSetAssignmentToRemove = toRemove;
		permissionSetAssignmentToUpdate = toUpdate;
	}

    public void execute(QueueableContext context) {
    	List<Database.SaveResult> results;

    	try{
	        database.delete (permissionSetAssignmentToRemove, false);
    	}
    	catch (Exception e){
    		ECO_Service_ErrorLog.logException(e);
    	}

    	try{
			results = database.insert (permissionSetAssignmentToUpdate, false);
    	}
    	catch(Exception e){
    		ECO_Service_ErrorLog.logException(e);
    	}
    	for(Database.SaveResult result : results){
	    	if(!result.isSuccess()){
	    		ECO_Service_ErrorLog.logException(permissionSetAssignmentToUpdate, results, 'UserPermissionAssignmentUpdateQueue.execute');
	    		break;
	    	}
    	}
    }
}