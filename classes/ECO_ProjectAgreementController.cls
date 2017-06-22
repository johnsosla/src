public class ECO_ProjectAgreementController {

	public ProjectAgreement__c projectAgreement {get; set;}
	String recordTypeId;
	String recordToDelete;
	public String projectId {get; set;}
	public String selectedRecordType {get; set;}
	public pse__Proj__c theProject {get; set;}
	public Boolean hasUpdateAccess {get;set;}
	
	
	public ECO_ProjectAgreementController(ApexPages.StandardController controller)
	{
		projectAgreement = (ProjectAgreement__c)controller.getRecord();
		hasUpdateAccess = false;

		if(projectAgreement.Project__c == null){
			projectAgreement.Project__c = ApexPages.currentPage().getParameters().get('project');
		}
	}
	
	public PageReference recordTypeSelected()
	{
		pse__Proj__c projectInfo = ECO_Service_Agreement.getProjectFromId(projectAgreement.Project__c);    
        Id accountId = ECO_Service_Agreement.getSiteAccountIdFromProjPrimBillAcct(projectInfo.PrimaryBillingClient__c);
        Id projectManagerId = ECO_Service_Agreement.getProjectManagerFromProjectTeam(projectInfo.Id);
        Integer projectAgreementCount = ECO_Service_Agreement.getNextProjectAgreementCount(projectInfo.Id);
        RecordType recordType = [select Id, Name, DeveloperName from RecordType where Id = :selectedRecordType];
        	
        String projectAgreementNumber;
        	
        if(projectInfo.OracleProjectnumber__c != null && projectInfo.OracleProjectnumber__c != '') 
        	projectAgreementNumber = projectInfo.OracleProjectnumber__c + '-' + String.valueOf(projectAgreementCount);	
        else
        	projectAgreementNumber = null;
		Agreement__c newAgreement = new Agreement__c(Project__c = projectInfo.Id, 
													Account__c = accountId, 
													RecordTypeId = selectedRecordType, 
													//OUID__c = projectInfo.OUID__c, 
													AgreementNumber__c = projectAgreementNumber,
													ProjectAgreementRecordCount__c = projectAgreementCount,
													AgreementAmountEstimated__c = projectInfo.EstimatedContractValue__c,
													ProjectTeamMember__c = projectManagerId,
													FundingCurrencyCode__c = projectInfo.ProjectCurrencyCode__c,
													CurrencyIsoCode = projectInfo.ProjectCurrencyCode__c);													
		insert newAgreement;
			
		if(recordType.DeveloperName != 'PrimeMSA'){
			ProjectAgreement__c newProjectAgreement = new ProjectAgreement__c();
			newProjectAgreement.Project__c = projectAgreement.Project__c;
			newProjectAgreement.Agreement__c = newAgreement.Id;
			insert newProjectAgreement;
		}
			
		PageReference newAgreementRef = new PageReference('/' + newAgreement.Id);
		newAgreementRef.getParameters().put('Mode', 'New');
		newAgreementRef.getParameters().put('ProjectId', projectId);
		newAgreementRef.getParameters().put('saveURL', '/' + newAgreement.Id + '?ProjectId='+ projectInfo.Id);
    	newAgreementRef.getParameters().put('retURL', '/apex/ECO_ProjectAgreementpage?ProjectId=' + projectInfo.Id + '&RecordToDelete='+ newAgreement.Id);
			
		return 	newAgreementRef;				
	}

	public Boolean getUserCanEditAgreement()
    {
        if(ECO_Service_Users.isSystemAdminstrator(UserInfo.getProfileId()) || ECO_Service_RecordAccess.getRecordAccess(projectAgreement.Project__c, 'Agreement__c')) {

            return true;
        }
        return false;
    } 
	
    public PageReference returnToProject(){
        projectId = ApexPages.currentPage().getParameters().get('project');
        PageReference returnToProject = new PageReference('/' + projectId);
		return returnToProject;
    }
    
	public PageReference init()
	{				
		PageReference returnPR;	

		hasUpdateAccess = getUserCanEditAgreement();

		recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
		recordToDelete = ApexPages.currentPage().getParameters().get('RecordToDelete');
		projectId = projectAgreement.Project__c;
		System.debug('projectId:   '+projectId);
		
		//first time you come to the project agreement, redirect to the recordtype selector page
		if(recordToDelete == null || recordToDelete == '')
		{    
			theProject = [select Name from pse__Proj__c where Id = :projectId limit 1];   
        	return null;			
		}
				
		//if you cancel new agreement from agreement screen, clear the records and go back to project
		if(recordToDelete != null && recordToDelete != '')
		{
			projectId = ApexPages.currentPage().getParameters().get('ProjectId');
            
			Agreement__c agreementToDelete = ECO_Service_Agreement.getAgreementFromId(recordToDelete);
			delete agreementToDelete;
			
			PageReference returnToProject = new PageReference('/' + projectId);
			return returnToProject;
		}
		
		return null;	
	}	
	
	public list<RecordType> getAgreementRecordTypes()
	{
		return [select Id, Name, Description from RecordType where sObjectType = 'Agreement__c' and DeveloperName != 'PrimeMSA'];
	}

}