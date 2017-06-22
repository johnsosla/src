public class ECO_ChangeManagerRecordTypeController {
	
	public pse__Proj__c project 						{get; set;}
	public ChangeManager__c executionApproval 			{get; set;}
	public ChangeManager__c preContractExecutionApproval {get; set;}
    public Boolean allowPreContractApproval {get; set;}

    /**
     * standard controller
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
	public ECO_ChangeManagerRecordTypeController(ApexPages.StandardController standarController) {
		project = (pse__Proj__c)standarController.getRecord();	
	}

    /**
     * initialize controller, determines if an existing change manager execution approval entry exists for the project
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
	public PageReference init()
	{
		Id executionApprovalRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'ExecutionApproval');
		Id preContractExecutionApprovalRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'ExecutionApprovalPreContract');

        allowPreContractApproval = true;
        ECOPreContractOrgPreference__c orgPreference = ECOPreContractOrgPreference__c.getvalues(project.OUID__c);
        if(orgPreference == null || !orgPreference.EnablePreContractFunctionality__c){
            allowPreContractApproval = false;
            List<ChangeManager__c> executionApprovalChangeManagers = [select Id, Name, ApprovalStatus__c from ChangeManager__c where RecordTypeId = :executionApprovalRecordTypeId and Project__c = :project.Id];
            if(!executionApprovalChangeManagers.isEmpty()) {
                return new PageReference('/' + executionApprovalChangeManagers[0].Id);
            }
            else {
                ChangeManager__c approvalForExecutionChangeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = executionApprovalRecordTypeId, Process__c = 'EcoCMProjectExecution2');
                
                try {
                    insert approvalForExecutionChangeManager;
                }
                catch(Exception e) {
                    ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                    return null;
                }
                return new PageReference('/' + approvalForExecutionChangeManager.Id);
            }
            
        }


		List<ChangeManager__c> executionApprovalChangeManagers = [select Id, Name, ApprovalStatus__c from ChangeManager__c where RecordTypeId = :executionApprovalRecordTypeId and Project__c = :project.Id];
		if(!executionApprovalChangeManagers.isEmpty()) {
			executionApproval = executionApprovalChangeManagers[0];	
		}

		List<ChangeManager__c> preContractExecutionApprovalChangeManagers = [select Id, Name, ApprovalStatus__c from ChangeManager__c where RecordTypeId = :preContractExecutionApprovalRecordTypeId and Project__c = :project.Id];
		if(!preContractExecutionApprovalChangeManagers.isEmpty()) {
			preContractExecutionApproval = preContractExecutionApprovalChangeManagers[0];
		}

       	return null;
	}

    /**
     * Return to project changes
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
	public PageReference redirectToProjectChanges()
	{
		return new PageReference('/apex/ECO_ProjectChangeManager?id=' + project.Id);
	}

    /**
     * Return to project
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
	public PageReference returnToProject()
	{
		return new PageReference('/' + project.Id);
	}

    /**
     * Creates change manager entry based on what record type was selected
     *
     * @Author  NTT Data - Brent Kendall
     * @Date    2016
     *
     * @return   PageReference     
     **/
    public PageReference createNewExecutionApprovalChangeManager()
    {
        String selectedRecordType = ApexPages.currentPage().getParameters().get('RecordType');

        Id recordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, selectedRecordType);

       	ChangeManager__c approvalForExecutionChangeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = recordTypeId, Process__c = 'EcoCMProjectExecution2');


        try{
		  insert approvalForExecutionChangeManager;
        }
        catch(Exception e) {
            ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
        }
                  
        return new PageReference('/' + approvalForExecutionChangeManager.Id);
    
    }

}