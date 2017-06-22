public class ECO_ProjectChangeManagerController {
        
        public pse__Proj__c project {get; set;}
        private list<String> changeManagerSubmittedIds;
        private String mode;
        
        public ECO_ProjectChangeManagerController(ApexPages.standardController controller)
        {
           		mode = '';
           		mode = Apexpages.currentPage().getParameters().get('mode');
           		
                project = (pse__Proj__c)controller.getRecord();
                changeManagerSubmittedIds = ECO_Service_ChangeManager.getChangeManagerSubmittedIds(project.Id);
        }
        
        public PageReference init()
        {
           	if(mode == 'ExecutionApproval')
           	{
           		Id approvalForExecutionChangeManager = approvalForExecution();	
           		return new PageReference('/' + approvalForExecutionChangeManager);  
           	}          
           	return null;        	
        }
                
        public boolean getIsChangedTasks()
        {
                return ECO_Service_ChangeManager.isChangedTasks(project.Id, changeManagerSubmittedIds);         
        }
        
        public boolean getIsChangedKeyMembers()
        {
                return ECO_Service_ChangeManager.isChangedKeyMembers(project.Id, changeManagerSubmittedIds);
        }
        
        public boolean getIsChangedCustomers()
        {
                return ECO_Service_ChangeManager.isChangedCustomers(project.Id, changeManagerSubmittedIds);
        }

        public boolean getIsChangedClassifications()
        {
                return ECO_Service_ChangeManager.isChangedClassifications(project.Id);
        }

        public boolean getIsChangedSHE()
        {
                return ECO_Service_ChangeManager.isChangedSafetyHealthEnv(project.Id);
        }
        
        public boolean getIsChangedAgreements()
        {
                return ECO_Service_ChangeManager.isChangedAgreements(project.Id, changeManagerSubmittedIds);
        }

        public boolean getIsChangedFunding()
        {
                return ECO_Service_ChangeManager.isChangedFunding(project.Id, changeManagerSubmittedIds);
        }       

        public boolean getIsChangedDocManage()
        {
                return ECO_Service_ChangeManager.isChangedDocumentManagement(project.Id);
        }               
        
        public boolean getIsChangedStakeComm()
        {
                return ECO_Service_ChangeManager.isChangedStakeholders(project.Id, changeManagerSubmittedIds);
        }       
        
        public boolean getIsChangedResources()
        {
                return ECO_Service_ChangeManager.isChangedResources(project.Id, changeManagerSubmittedIds);
        }       
        
        public boolean getIsChangedDeliverables()
        {
                return ECO_Service_ChangeManager.isChangedDeliverables(project.Id, changeManagerSubmittedIds);
        }       
        
        public boolean getIsChangedScope()
        {
                return ECO_Service_ChangeManager.isChangedScope(project.Id, changeManagerSubmittedIds);
        }       
        
        public boolean getIsChangedResilience()
        {
                return ECO_Service_ChangeManager.isChangedResilence(project.Id);
        }       

        public boolean getIsChangedRisk()
        {
                return ECO_Service_ChangeManager.isChangedRisk(project.Id, changeManagerSubmittedIds);
        }   
        
        public Id approvalForExecution()
    	{
    		Id executionApprovalRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'ExecutionApproval');
            Id executionApprovalPreContractRecordTypeId = ECO_Utils_Meta.getRecordTypeId(ChangeManager__c.sObjectType, 'ExecutionApprovalPreContract');
    		
    		list<ChangeManager__c> approvalForExecutionChangeManagers = [select Id from ChangeManager__c 
                                                                        where (RecordTypeId = :executionApprovalRecordTypeId 
                                                                                  or RecordTypeId = :executionApprovalPreContractRecordTypeId)
                                                                        and Project__c = :project.Id order by Id desc];
    		
    		if(approvalForExecutionChangeManagers.isEmpty())
    		{
    			//ChangeManager__c approvalForExecutionChangeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = executionApprovalRecordTypeId, Process__c = 'EcoCMProjectExecutionBypass');
                ChangeManager__c approvalForExecutionChangeManager;
                if(mode == 'ExecutionApproval') {
                    approvalForExecutionChangeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = executionApprovalRecordTypeId, Process__c = 'EcoCMProjectExecution2');
                }
                else {
                    approvalForExecutionChangeManager = new ChangeManager__c(Project__c = project.Id, RecordTypeId = executionApprovalPreContractRecordTypeId, Process__c = 'EcoCMProjectExecution2');   
                }
    			insert approvalForExecutionChangeManager;
    		
    			return approvalForExecutionChangeManager.Id;
    		}
    		return approvalForExecutionChangeManagers[0].Id;
    	}    

}