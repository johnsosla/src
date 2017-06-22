public class ECO_Service_ContractReview {
	
	private static String PROJECT_MANAGER_ROLE = 'Project Manager';
	private static String PROJECT_Director_ROLE = 'Project Approver';
	private static map<String, Id> oracleProjectNumberProjectIdMap;
	
	public static list<ECO_ContractReviewDTO> getContractReivewDTOs(Id agreementId)
	{	
		list<Id> projectIds = new list<Id>();		
		for(ProjectAgreement__c projectAgreement:[select Id, Project__c, Agreement__c from ProjectAgreement__c where Agreement__c = :agreementId])
		{
			projectIds.add(projectAgreement.Project__c);
		}
		
		Agreement__c agreement = [select Id, AgreementType__c, RecordType.Name
															 , FundingCurrencyCode__c
															 , ScopePackage__c
															 , ScopePackage__r.Scope_Details__c
															 , ScopeOfServices__c
															 , ProfIndemnityLiabilityAmt__c
															 , PublicGeneralLiabilityAmt__c
															 , IntercompanySubconsultant__c
															 , IntercompanySubconsultant__r.Name
															 , VendorName__c
															 , VendorName__r.Name
															 , InvoicingClient__c
															 , InvoicingClient__r.Name
															 , AgreementAmountEstimated__c
															 , VendorSite__c
															 , VendorSite__r.AccountName__c
															 , VendorSite__r.AccountId__c
															 , Account__c
															 , Account__r.Name
															 from Agreement__c where Id = :agreementId];
															 
		list<pse__Proj__c> projects = [select Id, Name, CarryingOutOrganization__r.BusinessLineName__c, USFederalGovernmentProject__c,
										OracleProjectNumber__c
		 								from pse__Proj__c where Id = :projectIds];
		oracleProjectNumberProjectIdMap = new map<String, Id>();
		for(pse__Proj__c project:projects)
		{
			if(project.OracleProjectNumber__c != null && project.OracleProjectNumber__c != '')
				oracleProjectNumberProjectIdMap.put(project.OracleProjectNumber__c, null);
		}
		
		map<Id, list<Id>> projectOpportunityMap = getOpportunitiesForProject(projectIds);
		map<Id, Id> projectManagerMap = getProjectTeamMembersByRole(projectIds, PROJECT_MANAGER_ROLE);
		map<Id, Id> projectDirectorMap = getProjectTeamMembersByRole(projectIds, PROJECT_DIRECTOR_ROLE);
		
		map<String, Id> businessLineIdMap = getBusinessLineNameIdMap();
		populateOracleProjectMap();
						
		list<ECO_ContractReviewDTO> contractReviewDTOs = new list<ECO_ContractReviewDTO>();
		ECO_ContractReviewDTO contractReviewDTO;		
		for(pse__Proj__c project:projects)
		{
			contractReviewDTO = new ECO_ContractReviewDTO();
			if(project.OracleProjectNumber__c != null && project.OracleProjectNumber__c != '')
			{
				contractReviewDTO.ProjectId = oracleProjectNumberProjectIdMap.get(project.OracleProjectNumber__c);
			}
				
			//contractReviewDTO.ProjectId = project.Id; 
			contractReviewDTO.ProjectName = project.Name;	
			contractReviewDTO.OpportunityIds = projectOpportunityMap.get(project.Id);
			
			if(businessLineIdMap.get(project.CarryingOutOrganization__r.BusinessLineName__c) != null)
				contractReviewDTO.BusinessLine = businessLineIdMap.get(project.CarryingOutOrganization__r.BusinessLineName__c);
			else
				contractReviewDTO.BusinessLine = '';
				
			contractReviewDTO.FederealContract = project.USFederalGovernmentProject__c;
			contractReviewDTO.ContractType = agreement.AgreementType__c;

			if(projectManagerMap.containsKey(project.Id))
				contractReviewDTO.ProjectManagerId = projectManagerMap.get(project.Id);
				
			if(projectDirectorMap.containsKey(project.Id))
				contractReviewDTO.ProjectDirectorId = projectDirectorMap.get(project.Id);
				
			contractReviewDTO.AgreementCurrency = agreement.FundingCurrencyCode__c;
			contractReviewDTO.EstimatedFee = agreement.AgreementAmountEstimated__c;
			
			if(agreement.ScopePackage__c != null)
				contractReviewDTO.ScopeOfServices = agreement.ScopePackage__r.Scope_Details__c;
			else
				contractReviewDTO.ScopeOfServices = agreement.ScopeOfServices__c;	
				
			contractReviewDTO.ProfessionalIndemnity = agreement.ProfIndemnityLiabilityAmt__c;
			contractReviewDTO.PublicIndemnity = agreement.PublicGeneralLiabilityAmt__c;
		
			if(agreement.IntercompanySubconsultant__c != null)
			{
				contractReviewDTO.ClientVendorId = agreement.IntercompanySubconsultant__c;
				contractReviewDTO.ClientVendorName = agreement.IntercompanySubconsultant__r.Name;
			}
			else if(agreement.VendorSite__c != null )
			{
				contractReviewDTO.ClientVendorId = agreement.VendorSite__r.AccountId__c;
				contractReviewDTO.ClientVendorName = agreement.VendorSite__r.AccountName__c;
			}
			else
			{
				contractReviewDTO.ClientVendorId = agreement.Account__c;
				contractReviewDTO.ClientVendorName = agreement.Account__r.Name;				
			}
				
			contractReviewDTOs.add(contractReviewDTO);
		}
		
		return contractReviewDTOs;
	}
	
	private static void populateOracleProjectMap()
	{
		for(Project__c project:[select Id, Oracle_Project_Number__c from Project__c where Oracle_Project_Number__c in :oracleProjectNumberProjectIdMap.keyset()])
		{
			oracleProjectNumberProjectIdMap.put(project.Oracle_Project_Number__c, project.Id);
		}
	}

	private static map<String, Id> getBusinessLineNameIdMap()
	{
		map<String, Id> busLineMap = new map<String, Id>();
		for(Business_Line__c businessLine:[select Id, Name from Business_Line__c])
		{
			busLineMap.put(businessLine.Name, businessLine.Id);
		}
		return busLineMap;
	}

	private static map<Id, list<Id>> getOpportunitiesForProject(list<Id> projects)
	{
		map<Id, list<Id>> projOppMap = new map<Id, list<Id>>();
		//prepopulate map so we can return empty list
		for(Id projectId:projects)
		{
			projOppMap.put(projectId, new list<Id>());	
		}
		
		for(Opportunity opp:[select Id, Project__c from Opportunity where Project__c in :projects])
		{
			projOppMap.get(opp.Project__c).add(opp.Id);
		}
		
		return projOppMap;
	}
	
	private static map<Id, Id> getProjectTeamMembersByRole(list<Id> projectIds, String role)
	{
		map<Id, Id> projectRoleMap = new map<Id, Id>(); 
					
		for(ProjectTeamMember__c teamMember: [select Id, Project__c, Contact__r.pse__Salesforce_User__c from ProjectTeamMember__c where Project__c in :projectIds 
												and Active__c = true and ProjectRole__r.Name = :role
												and Contact__r.pse__Salesforce_User__c != null])
		{	
			projectRoleMap.put(teamMember.Project__c, teamMember.Contact__r.pse__Salesforce_User__c);	
		}
		
		return projectRoleMap;
	}
}