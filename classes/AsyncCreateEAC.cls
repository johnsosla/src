public class AsyncCreateEAC implements Queueable {
	public String eacType;
	public Id projectId;
	public Id budgetHeaderId {get; set;}

	public AsyncCreateEAC(String eacType, Id projectId) {
		this.eacType = eacType;
		this.projectId = projectId;
	}

	public void execute(QueueableContext context) {
        System.savePoint oSavePoint = Database.setSavepoint();

        try {
            if (eacType == 'createGenericEAC')  budgetHeaderId = ECO_BudgetEACService.createGenericECO(projectId);
            if (eacType == 'createEAC')  budgetHeaderId = ECO_BudgetEACService.createInitECO(projectId);            
            
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