public class ECO_AgreementTriggerHandler {

	public static boolean run = true;
	
	public static list<pse__Proj__c> handleProjectUpdate(list<id> ids, map<Id, pse__Proj__c> projectMap, Agreement__c agreement){

		list<pse__Proj__c> updatedProjects = new list<pse__Proj__c>();

		for(Id projectId:ids){

			pse__Proj__c updatedProject = projectMap.get(projectId);
			if(agreement.segAdherence__c == 'Yes'){

				if(updatedProject.isSegmented__c == true && updatedProject.clAECOMSegmentationReason__c == 'Segmentable'){
					continue;
				}

				updatedProject.isSegmented__c = true;
				//updatedProject.SegmentationStatus__c = 'Segmented';
				updatedProject.clAECOMSegmentationReason__c = 'Segmentable';


			} else if(agreement.segOptionDoesNotQualify__c == 'Yes') {
				if(updatedProject.isSegmented__c == true && updatedProject.clAECOMSegmentationReason__c == 'Management Purposes'){
					continue;
				}		

				updatedProject.isSegmented__c = true;
				//updatedProject.SegmentationStatus__c = 'Segmented for Mangement Purposes';
				updatedProject.clAECOMSegmentationReason__c = 'Management Purposes';

			} else {
				if(updatedProject.isSegmented__c == false && updatedProject.clAECOMSegmentationReason__c == 'Not Segmented'){
					continue;
				}		

				updatedProject.isSegmented__c = false;
				//updatedProject.SegmentationStatus__c = 'Not Segmented';
				updatedProject.clAECOMSegmentationReason__c = 'Not Segmented';

			}
			updatedProjects.add(updatedProject);											
		}

		return updatedProjects;

	}


	public static void handleSegmentationApproval(map<Id, Agreement__c> oldAgreementMap, map<Id, Agreement__c> newAgreementMap)
	{
		if (!ECO_TriggerSettings.getIsTriggerEnabled('AGREEMENT_segmentationApproval') || !run) {
			return;
		}
		
		map<Id, Agreement__c> msaAgreements = new map<Id, Agreement__c>();
		map<Id, Agreement__c> nonMSAAgreements = new map<Id, Agreement__c>();
		list<pse__Proj__c> updatedProjects =  new list<pse__Proj__c>();
		
		for(Agreement__c agreement:newAgreementMap.values())
		{
			if(oldAgreementMap.get(agreement.Id).SegApprovalStatus__c != 'Approved' && agreement.SegApprovalStatus__c == 'Approved')
			{
				if(agreement.IsMSA__c)
					msaAgreements.put(agreement.Id, agreement);	
				else
					nonMSAAgreements.put(agreement.Id, agreement);
			}
		}

		map<Id, list<Id>> agreementProjectIdMap = new map<Id, list<Id>>();
		set<Id> projectIds = new set<Id>();		


		if(msaAgreements.values().size() > 0)
		{
			map<Id, list<Agreement__c>> msaTaskOrderMap = new map<Id, list<Agreement__c>>();
			list<Agreement__c> taskOrders = [select Id, MSAReference__c from Agreement__c where MSAReference__c in :msaAgreements.keyset()];
			for(Agreement__c taskOrder:taskOrders)
			{
				if(msaTaskOrderMap.get(taskOrder.MSAReference__c) == null){
					msaTaskOrderMap.put(taskOrder.MSAReference__c, new list<Agreement__c>());
				}
				msaTaskOrderMap.get(taskOrder.MSAReference__c).add(taskOrder);
			}
			
			for(ProjectAgreement__c projectAgreement: [select Id, Project__c, Agreement__c from ProjectAgreement__c where Agreement__c in :taskOrders])
			{
				projectIds.add(projectAgreement.Project__c);

				if(agreementProjectIdMap.get(projectAgreement.Agreement__c) == null){
					agreementProjectIdMap.put(projectAgreement.Agreement__c, new list<Id>());
				}

				agreementProjectIdMap.get(projectAgreement.Agreement__c).add(projectAgreement.Project__c);
			}

			map<Id, pse__Proj__c> projectMap = new map<Id, pse__Proj__c>([select Id, isSegmented__c, clAECOMSegmentationReason__c, SegmentationStatus__c from pse__Proj__c where Id in :projectIds]);
			
			//final processing for the msa agreement
			
			for(Agreement__c msaAgreement:msaAgreements.values())
			{
				for(Agreement__c taskOrder:msaTaskOrderMap.get(msaAgreement.Id))
				{
					//for(Id projectId:agreementProjectIdMap.get(taskOrder.Id)){}
					updatedProjects.addall(handleProjectUpdate(agreementProjectIdMap.get(taskOrder.Id), projectMap, msaAgreement));

				}				
			}
		}
		else if(nonMSAAgreements.size() > 0)
		{

			for(ProjectAgreement__c projectAgreement:[select Id, Project__c, Agreement__c from ProjectAgreement__c where Agreement__c in :nonMSAAgreements.keyset()])
			{
				projectIds.add(projectAgreement.Project__c);

				if(agreementProjectIdMap.get(projectAgreement.Agreement__c) == null){
					agreementProjectIdMap.put(projectAgreement.Agreement__c, new list<Id>());
				}

				agreementProjectIdMap.get(projectAgreement.Agreement__c).add(projectAgreement.Project__c);				
			}
			
			map<Id, pse__Proj__c> projectMap = new map<Id, pse__Proj__c>([select Id, isSegmented__c, clAECOMSegmentationReason__c, SegmentationStatus__c from pse__Proj__c where Id in :projectIds]);

			//final processing for the msa agreement
			pse__Proj__c updatedProject;
			for(Agreement__c agreement:nonMSAAgreements.values())
			{
				//for(Id projectId:agreementProjectIdMap.get(agreement.Id))
				updatedProjects.addall(handleProjectUpdate(agreementProjectIdMap.get(agreement.Id), projectMap, agreement));
			}				
		}
		if(updatedProjects.size() > 0)
			update updatedProjects;		
	}
	
	public static void handleAgreementBeforeUpdate(map<Id, Agreement__c> oldAgreementMap, map<Id, Agreement__c> newAgreementMap)
	{
		if (!ECO_TriggerSettings.getIsTriggerEnabled('AGREEMENT_populateAgreementNumber') || !run) {
			return;
		}
		
		list<Id> projectIds = new list<Id>();
		list<Agreement__c> agreementsWithNoProjectNumber = new list<Agreement__c>();

		for(Agreement__c agreement:newAgreementMap.values())
		{		
			if(agreement.ChangeManagerApprovedForSynch__c == true && oldAgreementMap.get(agreement.Id).ChangeManagerApprovedForSynch__c == false)
			{
				if(agreement.AgreementNumber__c == null)
				{
					projectIds.add(agreement.Project__c);
					agreementsWithNoProjectNumber.add(agreement);
				}
			}	
			else if(agreement.OracleSyncStatus__c == 'S' && oldAgreementMap.get(agreement.Id).OracleSyncStatus__c != 'S' && agreement.ActionCode__c == 'C')
				agreement.ActionCode__c = 'U';
			else if(agreement.OracleSyncStatus__c == 'E' && oldAgreementMap.get(agreement.Id).OracleSyncStatus__c != 'E')
				agreement.ChangeManagerIsChanged__c = true;
		}
		
		if(!agreementsWithNoProjectNumber.isEmpty())
		{
			map<Id, pse__Proj__c> projectMap = new map<Id, pse__Proj__c>([select Id, OracleProjectNumber__c from pse__Proj__c where Id in :projectIds]);
			for(Agreement__c agreement:agreementsWithNoProjectNumber)
			{
				if(projectMap.get(agreement.Project__c).OracleProjectNumber__c == null)
				{
					agreement.addError('This agreement is associated to Project that does not have an Oracle Project Number.  Please get an Oracle Project Number before proceeding with Synch!');
				}
				else
				{
					agreement.AgreementNumber__c = projectMap.get(agreement.Project__c).OracleProjectNumber__c + '-' + String.ValueOf(agreement.ProjectAgreementRecordCount__c);
				}
			}	
		}					
	}

	public static void handleChangedScopePackage(Map<Id, Agreement__c> newAgreementMap, Map<Id, Agreement__c> oldAgreementMap)
	{
		if (!ECO_TriggerSettings.getIsTriggerEnabled('AGREEMENT_ScopePackageChange') || !run) {
			return;
		}	
		Map<Id, Id> agreementScopeMap = new Map<Id,Id>();
		for(Agreement__c agreement:newAgreementMap.values())
		{
			if(agreement.ScopePackage__c != oldAgreementMap.get(agreement.Id).ScopePackage__c && agreement.ScopePackage__c != null)
			{
				agreementScopeMap.put(agreement.Id, agreement.ScopePackage__c);
			}
		}
		if(!agreementScopeMap.values().isEmpty())
		{
			Map<Id, Packages__c> scopeMap = new Map<Id, Packages__c>([select Id, Scope_Details__c from Packages__c where Id in :agreementScopeMap.values()]);

			Agreement__c updatedAgreement;
			for(Id agreementId:agreementScopeMap.keySet())
			{
				updatedAgreement = newAgreementMap.get(agreementId);
				updatedAgreement.ScopeOfServices__c = scopeMap.get(agreementScopeMap.get(agreementId)).Scope_Details__c;
			}
		}
	}
	
	public static void calculateTaskOrderValueForMSA(list<Agreement__c> agreements)
	{
		if (!ECO_TriggerSettings.getIsTriggerEnabled('AGREEMENT_CalcMSAValue') || !run) {
			return;
		}
		
		set<Id> msaAgreementIds = new set<Id>();
		
		for(Agreement__c agreement:agreements)
		{
			if(agreement.IsTaskOrder__c && agreement.MSAReference__c != null)
				msaAgreementIds.add(agreement.MSAReference__c);				
		}
		
		if(msaAgreementIds.size() > 0)
		{		
			map<Id, list<Agreement__c>> msaTaskOrderMap = new map<Id, list<Agreement__c>>();
			for(Agreement__c taskOrder:[select Id, Amount__c, MSAReference__c, FundingCurrencyCode__c from Agreement__c where MSAReference__c in :msaAgreementIds and IsTaskOrder__c = true])
			{
				if(msaTaskOrderMap.get(taskOrder.MSAReference__c) == null)
					msaTaskOrderMap.put(taskOrder.MSAReference__c, new list<Agreement__c>());
				msaTaskOrderMap.get(taskOrder.MSAReference__c).add(taskOrder);		
			}

			Decimal totalMSAValue = 0;
			list<Agreement__c> msaAgreements = [select Id, FundingCurrencyCode__c, TotalTaskOrdersValue__c from Agreement__c where Id in :msaAgreementIds];
			for(Agreement__c msaAgreement:msaAgreements)
			{
				for(Agreement__c taskOrder:msaTaskOrderMap.get(msaAgreement.Id))
				{
					if(msaAgreement.FundingCurrencyCode__c != taskOrder.FundingCurrencyCode__c && taskOrder.Amount__c != null)
						totalMSAValue += taskOrder.Amount__c * ECO_Service_ExchangeRate.getExchangeRate(taskOrder.FundingCurrencyCode__c, msaAgreement.FundingCurrencyCode__c, Date.today());
					else
					{
						if(taskOrder.Amount__c != null)
						{
							totalMSAValue += taskOrder.Amount__c;
						}
					}
				}
				msaAgreement.TotalTaskOrdersValue__c =	totalMSAValue;	
			}
			if(msaAgreements.size() > 0)
				update msaAgreements;
		} 		
	}
}
//					agreement.addError('This agreement is associated to Project that does not have an Oracle Project Number.  Please get an Oracle Project Number before proceeding with Synch');