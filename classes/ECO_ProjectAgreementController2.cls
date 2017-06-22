/** ------------------------------------------------------------------------------------------------------
 * @Description
 *
 * @Author      NTT Data - Brent Kendall, Deborah Orth
 * @Date        July 2015
 *-----------------------------------------------------------------------------------------------------*/
global virtual class ECO_ProjectAgreementController2 {

	public ProjectAgreement__c projectAgreement {get; set;}
	String recordTypeId;
	String recordToDelete;
	public String projectId {get; set;}
	public String selectedRecordType {get; set;}
	public pse__Proj__c theProject {get; set;}
	public list<Agreement__c> agreements {get; set;}
	public Boolean hasUpdateAccess {get; set;}
		
	/**
	 * constructor - get the correct agreement record & project id
	 *
	 * @Author  NTT Data - Brent Kendall, Deborah Orth
	 * @Date    July 2015
	 *
	 * @param   controller
	 * @return  
	 **/
	public ECO_ProjectAgreementController2(ApexPages.StandardController controller)
	{
		hasUpdateAccess = false;
		projectAgreement = (ProjectAgreement__c)controller.getRecord();
		if(projectAgreement.Project__c == null){
			projectAgreement.Project__c = ApexPages.currentPage().getParameters().get('ProjectId');
            
		}       
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - Brent Kendall, Deborah Orth
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  Boolean
	 **/
	public Boolean getUserCanEditAgreement()
    {
        if(ECO_Service_Users.isSystemAdminstrator(UserInfo.getProfileId()) || ECO_Service_RecordAccess.getRecordAccess(projectAgreement.Project__c, 'Agreement__c')) {

            return true;
        }
        return false;
    } 

	/**
	 * 
	 *
	 * @Author  NTT Data - Brent Kendall, Deborah Orth
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  PageReference
	 **/
	public PageReference recordTypeSelected()
	{
		pse__Proj__c projectInfo = ECO_Service_Agreement.getProjectFromId(projectAgreement.Project__c);    
		system.debug('DebugMe projectInfo: ' + projectInfo);
        Id accountId = ECO_Service_Agreement.getSiteAccountIdFromProjPrimBillAcct(projectInfo.PrimaryBillingClient__c);
        system.debug('DebugMe accountId ' + accountId);
        Id projectManagerId = ECO_Service_Agreement.getProjectManagerFromProjectTeam(projectInfo.Id);
        system.debug('DebugMe projectManagerId ' + projectManagerId);
        Integer projectAgreementCount = ECO_Service_Agreement.getNextProjectAgreementCount(projectInfo.Id);
        system.debug('DebugMe projectAgreementCount ' + projectAgreementCount);
        RecordType recordType = [select Id, Name, DeveloperName from RecordType where Id = :selectedRecordType];
        	
        system.debug('DebugMe recordType: ' + recordType);
        String projectAgreementNumber;
        	
        if(projectInfo.OracleProjectnumber__c != null && projectInfo.OracleProjectnumber__c != '') 
        	projectAgreementNumber = projectInfo.OracleProjectnumber__c + '-' + String.valueOf(projectAgreementCount);	
        else
        	projectAgreementNumber = null;

		system.debug('DebugMe projectAgreementNumber ' + projectAgreementNumber);
		Agreement__c newAgreement = new Agreement__c(Project__c = projectInfo.Id, 
													Account__c = accountId, 
													RecordTypeId = selectedRecordType, 
													//OUID__c = projectInfo.OUID__c, 
													AgreementNumber__c = projectAgreementNumber,
													ProjectAgreementRecordCount__c = projectAgreementCount,
													AgreementAmountEstimated__c = recordType.DeveloperName == 'Sub' ? 0 : projectInfo.EstimatedContractValue__c,
													ProjectTeamMember__c = projectManagerId,
													FundingCurrencyCode__c = projectInfo.ProjectCurrencyCode__c,
													CurrencyIsoCode = projectInfo.ProjectCurrencyCode__c);													
		insert newAgreement;
		system.debug('DebugMe newAgreement ' + newAgreement);
			
		if(recordType.DeveloperName != 'PrimeMSA'){
			ProjectAgreement__c newProjectAgreement = new ProjectAgreement__c();
			newProjectAgreement.Project__c = projectAgreement.Project__c;
			newProjectAgreement.Agreement__c = newAgreement.Id;
			insert newProjectAgreement;
			system.debug('DebugMe newProjectAgreement: ' + newProjectAgreement);
		}
			
		PageReference newAgreementRef = new PageReference('/' + newAgreement.Id);
		newAgreementRef.getParameters().put('Mode', 'New');
		newAgreementRef.getParameters().put('ProjectId', projectId);
		newAgreementRef.getParameters().put('saveURL', '/' + newAgreement.Id + '?ProjectId='+ projectInfo.Id);
    	newAgreementRef.getParameters().put('retURL', '/apex/ECO_ProjectAgreement?ProjectId=' + projectInfo.Id + '&RecordToDelete='+ newAgreement.Id);
			
		return 	newAgreementRef;				
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - Brent Kendall, Deborah Orth
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  PageReference
	 **/
	public PageReference init()
	{				
		PageReference returnPR;
		
		recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
		recordToDelete = ApexPages.currentPage().getParameters().get('RecordToDelete');
		projectId = projectAgreement.Project__c;

		hasUpdateAccess = getUserCanEditAgreement();
			
		//first time you come to the project agreement, redirect to the recordtype selector page
		if(recordToDelete == null || recordToDelete == '')
		{  
			theProject = [select Name, ProjectSectionHeaderName__c from pse__Proj__c where Id = :projectId limit 1]; 
			// The following line was commented out and replaced per US-06951
			//agreements = [select Id, Name, RecordType.Name, Amount__c, AgreementStatus__c, Account__c, VendorSite__r.AccountName__c, AgreementAmountEstimated__c, TotalApprovedRevenueLimit__c from Agreement__c where Id in (select Agreement__c from ProjectAgreement__c where Project__c = :theProject.Id)];  
			agreements = [select Id, Name, toLabel(RecordType.Name), RecordType.DeveloperName, Amount__c, AgreementStatus__c, Account__c, VendorSite__r.AccountName__c, AgreementAmountEstimated__c, TotalApprovedRevenueLimit__c from Agreement__c where Id in (select Agreement__c from ProjectAgreement__c where Project__c = :theProject.Id)];  
			  
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
	
	/**
	 * 
	 *
	 * @Author  NTT Data - Brent Kendall, Deborah Orth
	 * @Date    July 2015
	 *
	 * @param   
	 * @return  list<RecordType>
	 **/
	public list<RecordType> getAgreementRecordTypes()
	{
		return [select Id, toLabel(Name), DeveloperName from RecordType where sObjectType = 'Agreement__c' and DeveloperName != 'PrimeMSA'];
	}
}