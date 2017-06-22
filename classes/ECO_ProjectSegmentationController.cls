public class ECO_ProjectSegmentationController {
	
	public Agreement__c agreement {get; set;}
	public list<pse__Proj__c> projects {get; set;}
	public String mode {get; set;}
	public String projectId {get; set;}
	
	private boolean isSection2Shown = false;
	
	public ECO_ProjectSegmentationController()
	{
		
	}
	
	public ECO_ProjectSegmentationController(ApexPages.standardController sc)
    {
    	agreement = (Agreement__c)sc.getRecord();
    	mode = '';
    }
	
	public PageReference editSegmentationSurvey()
	{
		mode = 'Edit';
		return null;
	}
	
	public PageReference returnToFunding()
	{
        PageReference pageReference = new PageReference('/apex/ECO_ProjectFunding');
        pageReference.getParameters().put('AgreementId', agreement.Id);
        pageReference.getParameters().put('ProjectId', projectId);
        pageReference.getParameters().put('retURL', '/apex/ECO_AgreementView?'+agreement.Id);
        return pageReference;
	}
		
	public Boolean getShowSection2()
	{
		if(agreement.segSeparateProposal__c == 'No' || agreement.segProposalSubmitted__c == 'No' || agreement.segRightToAccept__c == 'No' || agreement.segSeparateComponents__c == 'No')
			return true;

		return false;
	}
	
	public PageReference submitForApproval()
	{	

        Boolean hasPermissionForApprovalProcess = ECO_Service_RecordAccess.getProjectRecordAccessForApprovalProcess ('Agreement__c', projectId);
        
        PageReference pageReference = new PageReference('/apex/ECO_ProjectSegmentation');
        pageReference.getParameters().put('id', agreement.Id);
        pageReference.getParameters().put('AgreementId', agreement.Id);
        pageReference.getParameters().put('ProjectId', projectId);
        pageReference.setRedirect(true);

        if (! hasPermissionForApprovalProcess && !agreement.IsMSA__c)  
        {   
            system.debug( 'No Permission for approval process' );
            
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have permission to Submit for Approval');
            ApexPages.addMessage(oPageMessage);            

            //return null;
            return pageReference;
        }

		// Create an approval request for the account
       	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(agreement.Id);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);

        return pageReference;
        //return null;
	}	
	
	private void resetSection2()
	{
		agreement.segTermsAndScope__c = null;
		agreement.segSeparatePhases__c = null;
		agreement.segGrossProfitRates__c = null;
		agreement.segSignificantHisory__c = null;		
		agreement.segAggregatePrice__c = null;
		agreement.segPricingPolicy__c = null;
		agreement.segVerifiable__c = null;
	}
	
	public Boolean getShowSection3()
	{
		if(agreement.segTermsAndScope__c == 'No' || agreement.segSeparatePhases__c == 'No' || agreement.segGrossProfitRates__c == 'No' || agreement.segSignificantHisory__c == 'No' || agreement.segAggregatePrice__c == 'No' || agreement.segPricingPolicy__c == 'No' || agreement.segVerifiable__c == 'No')
			return true;
//		if(mode != '')
//		{
//			resetSection3();	
//			resetConclusion();	
//		}
		return false;	
	}	
	
	private void resetSection3()
	{
		agreement.segProductOrServiceDiffers__c = null;
		agreement.segNegotiatedWithoutRegard__c = null;
		agreement.segUnderOriginalContract__c = null;
	}	
				
	private void resetConclusion()
	{
		agreement.segAmendmentOption__c = null;
		agreement.segAdherence__c = null;
		agreement.segOptionDoesNotQualify__c = null;
	}
	
	public void resetSections()
	{
		if(!getShowSection2())
			resetSection2();
		if(!getShowSection3())
			resetSection3();
		if(!getShowConclusion())
			resetConclusion();
		
	}
	
	public Boolean getShowConclusion()
	{
		if(agreement.segSeparateProposal__c == 'Yes' && agreement.segProposalSubmitted__c == 'Yes' && agreement.segRightToAccept__c == 'Yes' && agreement.segSeparateComponents__c == 'Yes')
			return true;
		else if(agreement.segTermsAndScope__c == 'Yes' && agreement.segSeparatePhases__c == 'Yes' && agreement.segGrossProfitRates__c == 'Yes' && agreement.segSignificantHisory__c == 'Yes' && agreement.segAggregatePrice__c == 'Yes' && agreement.segPricingPolicy__c == 'Yes' && agreement.segVerifiable__c == 'Yes')
			return true;
		else if(agreement.segProductOrServiceDiffers__c != null && agreement.segNegotiatedWithoutRegard__c != null && agreement.segUnderOriginalContract__c != null)
			return true;
		//resetConclusion();		
		return false;		
	}
	
	public Boolean getShowApprovalProcess()
	{
		if(agreement.segAmendmentOption__c != null || agreement.segAdherence__c != null || agreement.segOptionDoesNotQualify__c != null)
			return true;
		return false;
	}
	
	public void init()
	{
		projectId = Apexpages.currentPage().getParameters().get('ProjectId');
		//String type = Apexpages.currentPage().getParameters().get('Type');
		agreement = [select Id, IsMSA__c, RecordType.Name, ContractTitle__c, Project__c, Account__c, AgreementNumber__c, segSeparateProposal__c, segProposalSubmitted__c, segRightToAccept__c, segSeparateComponents__c, segTermsAndScope__c,
								segSeparatePhases__c, segGrossProfitRates__c, segSignificantHisory__c, segAggregatePrice__c, SegApprovalStatus__c,
								segPricingPolicy__c, segVerifiable__c, segProductOrServiceDiffers__c, segNegotiatedWithoutRegard__c,
								segUnderOriginalContract__c, segAmendmentOption__c, segAdherence__c, segOptionDoesNotQualify__c, segGroupCFO__c, segDesignee__c	 from Agreement__c where Id = :agreement.Id];
		
		projects = new list<pse__Proj__c>();		
		if(agreement.IsMSA__c)
		{	
			for(Agreement__c taskorder:[select Id, Project__r.Name from Agreement__c where MSAReference__c = :agreement.Id])
			{
				projects.add(taskorder.Project__r);
			}
		}
		else
		{
			for(ProjectAgreement__c projectAgreement:[select Id, Project__r.Name, Agreement__c from ProjectAgreement__c where Agreement__c = :agreement.Id])	
			{
				projects.add(projectAgreement.Project__r);
			}
		}
			
		if(agreement.segGroupCFO__c == null)
		{
    		agreement.segGroupCFO__c = ECO_Service_ProjectTeam.getActiveCFODelegate(projects[0].Id);
    		update agreement;
		}
 
     	if(agreement.segDesignee__c == null)
     	{
    		agreement.segDesignee__c = ECO_Service_ProjectTeam.getActiveProjectFinanceLead(projects[0].Id);
    		update agreement;
     	}
    	
	   	
	}
	
	public list<SelectOption> getYesNoOptions()
	{
	    list<SelectOption> options = new list<SelectOption>();
	    options.add(new SelectOption('Yes', 'Yes'));
	    options.add(new SelectOption('No', 'No'));
	
	    return options;
	}
	
	public PageReference cancel()
	{
       mode = '';
       return null;  
	}
	

	public PageReference returnToAgreement()
	{
        return new PageReference('/' + agreement.Id);        
	}
	
		
	public PageReference save()
	{
		if(agreement.segAmendmentOption__c == 'Yes' && agreement.segOptionDoesNotQualify__c == 'Yes')
		{	
			ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'You can not chose to Segment and Not Segment the contract.  Please switch one of the answers in conclusion section to No based on survey');
            ApexPages.addMessage(oPageMessage);
            return null;
		}
		mode = '';
		
		update agreement;
		
		return null;
	}

}