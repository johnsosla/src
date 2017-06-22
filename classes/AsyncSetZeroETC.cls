public class AsyncSetZeroETC implements Queueable {
	
	private static List<String> DEFAULT_RESOURCE_TYPES = new List<String>  {'Labor/Person', 'Subcontractor', 'ODC/FEE', 'Contingeny' };

	public Id budgetHeaderId;
	public List<String> resourceTypes;

	public static Id run(Id budgetHeaderId) {
		return run(budgetHeaderId, null);
	}

	public static Id run(Id budgetHeaderId, String resourceType) {
		AsyncSetZeroETC asyncInstance = new AsyncSetZeroETC(budgetHeaderId, resourceType);
		Id jobId = System.enqueueJob(asyncInstance);

		return jobId;
	}

	public AsyncSetZeroETC(Id budgetHeaderId, String resourceType) {
		if(resourceType == null) this.resourceTypes = DEFAULT_RESOURCE_TYPES;
		else this.resourceTypes = new List<String> { resourceType };

		this.budgetHeaderId = budgetHeaderId;
	}

	public void execute(QueueableContext context) {
        //Do some action here
        System.savePoint oSavePoint = Database.setSavepoint();

        try {
        	for (String resourceType : this.resourceTypes) {
	        	ECO_DTO_BudgetLabourWrapper.future_setAllZeroETC(budgetHeaderId, resourceType);
	        }
        } catch (Exception e) {
        	Database.rollback(oSavePoint);
            system.debug(Logginglevel.ERROR, 'Handled Exception:  ' + e.getMessage());
            system.debug(Logginglevel.ERROR, 'Handled Exception.getLineNumber:  ' + e.getLineNumber());
            system.debug(Logginglevel.ERROR, 'Handled Exception.getStackTraceString:  ' + e.getStackTraceString());
            
            ECO_Service_ErrorLog.logException(e);
            throw e;
        }
	}
}