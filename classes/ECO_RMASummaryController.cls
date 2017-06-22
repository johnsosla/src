public without sharing virtual class ECO_RMASummaryController extends ECO_PageControllerBase 
{
	public ApexPages.StandardController oStandardController {get; set;}
	public QuestionnaireSet__c oQuestionnaireSet {get; set;}
	public list<Participant__c> lParticipants {get; set;}
	public list<Questionnaire__c> lQuestionnaires {get; set;}
	public list<ExportControl__c> lExportControls {get; set;}
	public list<MarketAssessment__c> lMarketAssessments {get; set;}
	public list<QuestionnaireSet__c> lQuestionnaireSets {get; set;}
	public list<SelectOption> loQuestionnaireSets {get; set;}
	public list<ProjectCountry_Risk__c> lProjectCountryRisks {get; set;}
    public list<ProjectCity__c> lProjectCityRisks {get;set;}
	public list<ProjectOrganization__c> lProjectOrganizations {get; set;}
	public list<Project_Site__c> lProjectSites {get; set;}
	public list<Notification> lNotifications {get; set;}
	public pse__Proj__c theProject { get; set; }
	public string sSelectedQuestionnaireSet {get; set;}
    public string businessUnitValue {get;set;}
	public boolean BeginButtonDisabled {get; set;}
    public boolean isAssessmentStarted {get;set;}
    public boolean businessUnit {get;set;}
	public boolean showGoNoGoButton {get; set;}
	public Id navTargetQuestionnaireId {get;set;}
    public Integer countMA {get;set;}
    public Integer percentMA {get;set;}
	public list<Agreement__c> agreementsWithDOACondtions {get; set;}

	public ECO_RMASummaryController(ApexPages.StandardController oStandardController) {
		this.oStandardController = oStandardController;
		list<string> lFields = new list<string>();
        lFields.add('Name');
        lFields.add('TotalQuestions__c');
        lFields.add('ProjectManager__c');
        lFields.add('Project__r.BusinessUnit__c');
        lFields.add('GoNoGo_Review__c');
        if(!Test.isRunningTest()){
	        oStandardController.addFields(lFields);
        }

		oQuestionnaireSet = (QuestionnaireSet__c)oStandardController.getRecord();

		if(ECO_Utils_String.NullCheck(oQuestionnaireSet.Project__c) == ''){
			oQuestionnaireSet.Project__c = ApexPages.currentPage().getParameters().get('ProjectId');
		}
		if(ECO_Utils_String.NullCheck(oQuestionnaireSet.Name) == ''){
			oQuestionnaireSet.Name = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('qsName'), 'UTF-8');
		}

		if(ECO_Utils_String.NullCheck(oQuestionnaireSet.Project__c) == ''){
			ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'You have reached this page improperly, please access it from the Project screen.');
            ApexPages.addMessage(oPageMessage);
            return;
		}
		
		getTheProject();

		system.debug(oQuestionnaireSet);
			
		lParticipants = new list<Participant__c>([SELECT Id
														, User__c 
												FROM Participant__c 
												WHERE QuestionnaireSet__c = :oQuestionnaireSet.Id]);

        if(lParticipants.size() == 0)
        {
            lParticipants.add(new Participant__c(QuestionnaireSet__c = oQuestionnaireSet.Id));
        }
        
        Date releaseDate = ECONewRMAssessmentDate__c.getInstance().Date__c;
        lQuestionnaires = new list<Questionnaire__c>([SELECT Id
                                                            , Name
                                                            , ProjectRisk__c
                                                            , DoATriggers__c
                                                            , PercentComplete__c 
                                                            , QuestionnaireTemplate__r.SortOrder__c
                                                    FROM Questionnaire__c 
                                                    WHERE QuestionnaireSet__c = :oQuestionnaireSet.Id
                                                     AND CreatedDate < :releaseDate
                                                     ORDER BY QuestionnaireTemplate__r.SortOrder__c]);
		System.debug('BusinessUnit::::::'+oQuestionnaireSet.Project__r.BusinessUnit__c);
        businessUnit = false;
        businessUnitValue = oQuestionnaireSet.Project__r.BusinessUnit__c;
        if(String.isNotBlank(businessUnitValue))
             businessUnit = true;
        System.debug('businessUnitValue:::'+businessUnitValue+'    and businessUnit:::'+businessUnit);
		if(lQuestionnaires.isEmpty())
		{	
			lQuestionnaires = new list<Questionnaire__c>();
			
			String queryString = 'SELECT Id';
			queryString += ' , Name';
            queryString += ' , SortOrder__c';
			queryString += ' , (SELECT Id';
			queryString += ' FROM Questions__r';
            queryString += ' WHERE (GeographiesAvailableTo__c INCLUDES (\''+theProject.CarryingOutOrganization__r.GeographyName__c+'\')';
            queryString += ' OR GeographiesAvailableTo__c = null';
            queryString += ' OR GeographiesAvailableTo__c = \'\'';
            queryString += ' OR GeographiesAvailableTo__c INCLUDES (\'ALL\'))';
            queryString += ' AND (BusinessLinesAvailableTo__c INCLUDES (\''+theProject.CarryingOutOrganization__r.BusinessLineName__c+'\')';	
            queryString += ' OR BusinessLinesAvailableTo__c = null';
            queryString += ' OR BusinessLinesAvailableTo__c = \'\'';
            queryString += ' OR BusinessLinesAvailableTo__c INCLUDES (\'ALL\')) ';	
            queryString += ' AND IsActive__c = true';
            queryString += ' AND (BusinessUnit__c = null OR BusinessUnit__c = \'\' ';
            if(businessUnit)
                queryString += ' OR BusinessUnit__c = :businessUnitValue)';
            else
                queryString += ')';
			queryString += ' )';	
			queryString += ' FROM QuestionnaireTemplate__c where IsRMSection__c = true';
            queryString += ' ORDER BY SortOrder__c';

			System.debug('QuestionnaireTemplate query: ' + queryString);
			
			list<QuestionnaireTemplate__c> lQuestionnaireTemplates = Database.query(queryString);

			for(QuestionnaireTemplate__c oQuestionnaireTemplate : lQuestionnaireTemplates){
				lQuestionnaires.add(new Questionnaire__c(Name = oQuestionnaireTemplate.Name, QuestionnaireTemplate__c = oQuestionnaireTemplate.Id));
			}
		}
		
		lExportControls = new list<ExportControl__c>([Select Id
															, Name
															, Status__c 
                                                      		, SubmittedDate__c
													From ExportControl__c 
													WHERE QuestionnaireSet__c = :oQuestionnaireSet.Id]);
		
		lMarketAssessments = new list<MarketAssessment__c>([Select Id
																	, Name
																	, Status__c 
																	, AwareofOpportunity__c
																	, FreeFormDocumentedBusinessPlan__c
																	, DocumentedBusinessPlan__c
																	, FreeFormDocumentedKeyAccount__c
																	, DocumentedKeyAccount__c
																	, FreeFormStrongClientRelationship__c
																	, StrongClientRelationship__c
																	, FreeFormRecentProjectExperience__c
																	, RecentProjectExperience__c
																	, FreeFormRequiredTechnicalPersonnel__c
																	, RequiredTechnicalPersonnel__c
																	, FreeFormStrongPositiveWin__c
																	, StrongPositiveWin__c
																	, FreeFormAwareofOpportunity__c
																	, AdditionalInformation__c 
																	, FreeFormSufficientTimeandResources__c
																	, SufficientTimeandResources__c
																	, FreeFormIncumbent__c
																	, Incumbent__c
																	, FreeFormDecisionMaker__c
																	, DecisionMaker__c
																	, FreeFormDecisiontoAppoint__c
																	, DecisiontoAppoint__c
																	, ExpertWitnessorLitigationSupport__c
																	, JVinvolvement__c
																	, ProgramManagementServices__c
																	, RFPDevelopmentServices__c
																	, StaffAugmentationorembeddedworkforce__c
																	, FreeFormPotentialConflictofInterest__c
																	, Potentialconflictofinterestissues__c
															From MarketAssessment__c 
															WHERE QuestionnaireSet__c = :oQuestionnaireSet.Id]);
		
												
		lProjectCountryRisks = new list<ProjectCountry_Risk__c>([Select Safety_Rating__c, 
																		CountryName__c 
																From ProjectCountry_Risk__c 
																Where Project__c = :oQuestionnaireSet.Project__c]);
																
		lProjectOrganizations = new list<ProjectOrganization__c>([Select Id
																	From ProjectOrganization__c
																	Where Project__c = :oQuestionnaireSet.Project__c]);
																	
		lProjectSites = new list<Project_Site__c>([Select Account_Name__c, 
															CreditRiskRating__c,
															OracleCustomerNumber__c,
															Address1__c,
															City__c,
															State__c,
															Country__c,
															Postal_Code__c,
															Is_Billing__c,
															Is_Default_Top_Task__c,
															Is_End__c,
															Is_Primary_End__c
													From Project_Site__c
													Where Project__c = :oQuestionnaireSet.Project__c]);

		//Available questionnaire sets
		lQuestionnaireSets = ECO_Utils_Questionnaire.GetRelatedQuestionnaireSets(oQuestionnaireSet.Project__c);
		loQuestionnaireSets = new list<SelectOption>();

		for(QuestionnaireSet__c oQuestionnaireSet : lQuestionnaireSets){
			loQuestionnaireSets.add(new SelectOption(oQuestionnaireSet.Id, oQuestionnaireSet.Name));
		}

		sSelectedQuestionnaireSet = oQuestionnaireSet.Id;
		
		BeginButtonDisabled = false;
		if(String.isBlank(sSelectedQuestionnaireSet))
			BeginButtonDisabled = true;

		if(oQuestionnaireSet.GoNoGo_Review__c != null)
		{
			showGoNoGoButton = false;
		}
		else
		{
			showGoNoGoButton = true;
		}
		
		list<Agreement__c> msaAgreementsWithConditions = [select Id from Agreement__c where Id in (select Agreement__c from DOAConditions__c)];
		
		agreementsWithDOACondtions = [select Id from Agreement__c 
											where Project__c = :theProject.Id and 
												MSAReference__c in :msaAgreementsWithConditions];		
		
		lNotifications = new List<Notification>();
		validate();
		marketAssess();
		System.debug('In controller percentMA:    '+percentMA+'   countMA:  '+countMA);

	}
	
	public PageReference init()
	{
		PageReference oPR;
		Date releaseDate = ECONewRMAssessmentDate__c.getInstance().Date__c;
        	Date projectDate;
        	if (oQuestionnaireSet.Id != null) {
            		projectDate = [Select CreatedDate From QuestionnaireSet__c Where Id = :oQuestionnaireSet.Id].CreatedDate.Date();
            
            		if (projectDate >= releaseDate) {
                		oPR = Page.ECO_RMSummary;  
                		oPR.getParameters().put('id', oQuestionnaireSet.Id);
                		oPR.setRedirect(true);
                		return oPR;            
            		}  
            	}
		System.debug('qsName: ' + ApexPages.currentPage().getParameters().get('qsName'));
		if(ApexPages.currentPage().getParameters().get('qsName') != null)
		{
			oPR = oStandardController.save();
		}
		return oPR;
	}
	
	private boolean allRMAQuestionsHaveBeenAnswered()
	{
		if(oQuestionnaireSet.UnansweredQuestionCount__c == 0 && percentMA == 100)
			return true;
		return false;
	}
	
    public PageReference CancelRM(){
        oQuestionnaireSet.ApprovalStatus__c = 'Cancelled';
        update oQuestionnaireSet;
        PageReference oPR = new PageReference('/' + oQuestionnaireSet.Project__c);
		oPR.setRedirect(true);
		return oPR;
    }


    public PageReference escalateApproval(){
    	try{
    		oQuestionnaireSet.FlagForEscalate__c = true;
    		update oQuestionnaireSet;

	        PageReference oPR = new PageReference('/' + oQuestionnaireSet.id);
			oPR.setRedirect(true);
			return oPR;

    		//ECO_Service_Delegation.escalate(oQuestionnaireSet.Id);
    	} catch(Exception e){
            ApexPages.addMessages(e);
            
        }
        return null;
    }

	public PageReference submitForApproval()
	{
        try{
            if(!allRMAQuestionsHaveBeenAnswered()){
                ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Completion off all R&M assessment questions are required prior to submitting for approval!');
                ApexPages.addMessage(oPageMessage);
                
                return null;
            }

            //
            system.debug( 'Approval submitted user = ' + theProject.ProjectApprover__r.pse__Salesforce_User__c );
            
            Boolean hasPermissionForApprovalProcess = ECO_Service_RecordAccess.getProjectRecordAccessForApprovalProcess ('QuestionnaireSet__c', theProject.Id);
            
            if (! hasPermissionForApprovalProcess)  
            {   
                system.debug( 'No Permission for approval process' );
                
                ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have permission to Submit for Approval');
                ApexPages.addMessage(oPageMessage);            
    
                return null;
            }
    
            //return null;
            // Above line is just for test purposes, will be taken out. BH
            
            // have to set the appover field on the RMA before submitting
            theProject = null;
            getTheProject();
            oQuestionnaireSet.ProjectApprover__c = theProject.ProjectApprover__r.pse__Salesforce_User__c;
            oQuestionnaireSet.PnLManager__c =  theProject.PnLManager__r.pse__Salesforce_User__c;
            //oQuestionnaireSet.ProjectApprover__c = theProject.PnLManager__r.pse__Salesforce_User__c;
    		oQuestionnaireSet.ProjectManager__c = theProject.pse__Project_Manager__r.pse__Salesforce_User__c;
    		oQuestionnaireSet.CaptureManager__c = theProject.CaptureManager__r.pse__Salesforce_User__c;

    		System.debug('***SA***-oQuestionnaireSet');
    		

	        list<QuestionnaireSet__c> lstQSforE = new list<QuestionnaireSet__c>();
	        lstQSforE.add(oQuestionnaireSet);

	        ECO_Service_Delegation.evaluateDelegation(lstQSforE, null);
	        ECO_Service_Delegation.insertDelegations(lstQSforE);    		

            update oQuestionnaireSet;
            
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(oQuestionnaireSet.Id);
            
            // Submit on behalf of a specific submitter
            //req1.setSubmitterId(user1.Id);
            
            // Submit the record to specific process and skip the criteria evaluation
            //req1.setProcessDefinitionNameOrId('PTO_Request_Process');
            //req1.setSkipEntryCriteria(true);
            
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            
            list<QuestionnaireSet__c> lstQS = [select id, ApprovalStatus__c, FlagForEscalate__c  from QuestionnaireSet__c where id =: oQuestionnaireSet.Id];

            oQuestionnaireSet.ApprovalStatus__c = lstQS[0].ApprovalStatus__c;

            return null;
        }catch(Exception e){
            ApexPages.addMessages(e);
            return null;
        }
	}
    public PageReference enableSubmitApex(){
        System.debug('oQuestionnaireSet go no go:'+oQuestionnaireSet.GoNoGoRecommendation__c);
        return null;
    }
	public PageReference goToSpecificQuestionnaire () {
    	
    	PageReference oPageReference = Page.ECO_RMAQuestionnaire;

    	oPageReference.getParameters().put('id', navTargetQuestionnaireId);
    	oPageReference.setRedirect(true);
    	
    	return oPageReference;
    }
    
	public PageReference generatePDF () {
    	PageReference oPageReference = Page.ECO_RMASummaryPdf;
		oPageReference.getParameters().put('id', oQuestionnaireSet.Id);
    	oPageReference.setRedirect(true);
    	return oPageReference;
    }    
	
	public List<Schema.FieldSetMember> getCustomProjSetupFields()
	{
		
		return SObjectType.pse__Proj__c.FieldSets.ProjectFieldsforRMASummary.getFields();
		//return SObjectType.pse__Proj__c.FieldSets.pse_ProjectFieldsforCustomProjectSetup.getFields();
	}
	
	public pse__Proj__c getTheProject()
	{
		if(theProject == null)
		{
			String query = 'SELECT Id, PrimaryEndClient__c, PrimaryBillingClient__c, ProjectOwningOrg__c, ProjectNumber__c, CarryingOutOrganization__c, CarryingOutOrganization__r.Region__c, CarryingOutOrganization__r.GeographyName__c, CarryingOutOrganization__r.BusinessLineName__c, AccountManager__c, pse__Opportunity__c, CaptureManager__r.pse__Salesforce_User__c, pse__Project_Manager__r.pse__Salesforce_User__c, ProjectApprover__r.pse__Salesforce_User__c, PnLManager__r.pse__Salesforce_User__c ';
			// query += 'TotalMargin__c, TotalBidBudget__c, PrimaryEndClient__c, PrimaryBillingClient__c';
			for(Schema.FieldSetMember f : getCustomProjSetupFields()) 
			{
	            query += ', ' + f.getFieldPath();
	        }
	        query += ' FROM pse__Proj__c WHERE Id = \'' + oQuestionnaireSet.Project__c + '\' Limit 1';
	        theProject = Database.query(query);
		}
		return theProject;
	}
	
	public void validate(){
		// System.debug('entering validate');
		if(lExportControls.size() > 0)
		{
			if(lExportControls[0].Status__c != 'Completed')
			{
            	Notification oNote = new Notification('You must complete an Export Controls document due to selections in your Risk Assessment.');
            	lNotifications.add(oNote);
			}
		}

		// System.debug('In validate, check size of lProjectCountryRisks');		
		if(lProjectCountryRisks.size() == 0)
		{
            Notification oNote = new Notification('No Country Selected for this Risk Assessment.');
            lNotifications.add(oNote);
		}
		else
		{
            Integer count = 0;
			// System.debug('In validate, iterate over lProjectCountryRisks');	
			for(ProjectCountry_Risk__c oPCR : lProjectCountryRisks)
			{
				if(oPCR.Safety_Rating__c > 2.9)
				{
                    String notificationString = 'The project has a location with a security risk rating greater than 2.9 ';
                    loadProjectCityRisks(oQuestionnaireSet.Project__c);
                    System.debug('lProjectCityRisks size:'+lProjectCityRisks.size());
                    if(lProjectCityRisks.size()>0){
                        notificationString = notificationString + '( ';
                        for(ProjectCity__c pc :lProjectCityRisks){
                            if(count>0)
                                notificationString = notificationString + ', ';
                            notificationString  = notificationString + pc.CityName__c + ' : ' + pc.SafetyRating__c ;
                            count++;
                        }
                        notificationString = notificationString + ' )';
                    }
                    Notification oNote = new Notification(notificationString);
                    lNotifications.add(oNote);
            		break;
				}
			}
		}
		
		// System.debug('In validate, check size of agreementsWithDOACondtions');
		if(agreementsWithDOACondtions.size() > 0)
		{
        	Notification oNote = new Notification('This project is linked to an MSA that has existing DOA conditions of approval.');
            lNotifications.add(oNote);		
		}

		// System.debug('In validate, null check AccountManager__c');
		if(!(theProject.AccountManager__c == '' || theProject.AccountManager__c ==null))
		{
            Notification oNote = new Notification('One or more of the named clients for this project has a nominated Client Account Manager.  Engage the relevant CAM(s) as early as possible to inform the Go/No Go assessment and Project Plan development.');
        	//Notification oNote = new Notification('One or more of your nominated clients is an ECAM or CAM Account. Please work with the nominated Account Manager.');
            lNotifications.add(oNote);		
		}		
		
		// System.debug('In validate, check size of lProjectOrganizations');		
		if (lProjectOrganizations.size() == 0) {
			ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'No Organization is related to this project. You may not begin an assessment until one is selected.');
            ApexPages.addMessage(oPageMessage);
            BeginButtonDisabled = true;
		}
		
		// System.debug('In validate, start iteration of lProjectSites');
		for(Project_Site__c oPS : lProjectSites)
		{
			String riskRating;
			if(oPS.Is_Billing__c)
			{
				System.debug('CreditRiskRating: ' + oPS.CreditRiskRating__c);
				if(oPS.CreditRiskRating__c <= 1297)
					riskRating = 'severe';
				if(oPS.CreditRiskRating__c >= 1298 && oPS.CreditRiskRating__c <= 1358)
					riskRating = 'medium';
					
				if(riskRating != null)
				{
	            	Notification oNote = new Notification(oPS.Account_Name__c + ' has a ' + riskRating + ' credit risk (' + oPS.CreditRiskRating__c + ')');
            		//This NOTIFICATION has been turned off as of US-03519
            		//lNotifications.add(oNote);
				}
			}
		}
	}
	
    public void loadProjectCityRisks(Id projectId){
        lProjectCityRisks = new List<ProjectCity__c>([Select Id, CityName__c, SafetyRating__c From ProjectCity__c Where Project__c= :projectId AND SafetyRating__c > 2.9]);
    }
    
    public void marketAssess(){
        countMA = 0;
        System.debug('lMarketAssessments.size():   '+lMarketAssessments.size());
        if(lMarketAssessments.size()>0){
            for(MarketAssessment__c oMA : lMarketAssessments){
                if(oMa.DocumentedBusinessPlan__c == 'True' || oMA.DocumentedBusinessPlan__c == 'False')
                    countMA++;
                if(oMa.DocumentedKeyAccount__c == 'True' || oMa.DocumentedKeyAccount__c == 'False')
                    countMA++;
                if(oMa.StrongClientRelationship__c == 'True' || oMa.StrongClientRelationship__c == 'False')
                    countMA++;
                if(oMa.RecentProjectExperience__c == 'True' || oMa.RecentProjectExperience__c == 'False')
                    countMA++;
                if(oMa.RequiredTechnicalPersonnel__c == 'True' || oMa.RequiredTechnicalPersonnel__c == 'False')
                    countMA++;
                if(oMa.StrongPositiveWin__c == 'True' || oMa.StrongPositiveWin__c == 'False')
                    countMA++;
                if(oMa.AwareofOpportunity__c == 'True' || oMa.AwareofOpportunity__c == 'False')
                    countMA++;
                if(oMa.SufficientTimeandResources__c == 'True' || oMa.SufficientTimeandResources__c == 'False')
                    countMA++;
                if(oMa.Incumbent__c == 'True' || oMa.Incumbent__c == 'False')
                    countMA++;
                if(oMa.DecisionMaker__c == 'True' || oMa.DecisionMaker__c == 'False')
                    countMA++;
                if(oMa.DecisiontoAppoint__c == 'True' || oMa.DecisiontoAppoint__c == 'False')
                    countMA++;
                if(oMa.ExpertWitnessorLitigationSupport__c == 'True' || oMa.ExpertWitnessorLitigationSupport__c == 'False')
                    countMA++;
                if(oMa.JVinvolvement__c == 'True' || oMa.JVinvolvement__c == 'False')
                    countMA++;
                if(oMa.ProgramManagementServices__c == 'True' || oMa.ProgramManagementServices__c == 'False')
                    countMA++;
                if(oMa.RFPDevelopmentServices__c == 'True' || oMa.RFPDevelopmentServices__c == 'False')
                    countMA++;
                if(oMa.StaffAugmentationorembeddedworkforce__c == 'True' || oMa.StaffAugmentationorembeddedworkforce__c == 'False')
                    countMA++;
                if(oMa.Potentialconflictofinterestissues__c == 'True' || oMa.Potentialconflictofinterestissues__c == 'False')
                    countMA++;
                if(oMa.Potentialconflictofinterestissues__c == 'True' || oMa.Potentialconflictofinterestissues__c == 'False')
                    countMA++;
                
                
                percentMA = (countMA * 100) / 18;
            }
            
        }
        System.debug('In method...  countMA = '+countMA+'   percentMA='+percentMA);
    }
    
	public PageReference SelectNewQuestionnaire()
	{
		system.debug(sSelectedQuestionnaireSet);
		PageReference oPageReference;
		if(sSelectedQuestionnaireSet != '' && sSelectedQuestionnaireSet != null)
		{
			oPageReference = Page.ECO_RMASummary;
			oPageReference.setRedirect(true);
			oPageReference.getParameters().put('id', sSelectedQuestionnaireSet);
		}
		else
		{
			oPageReference = Page.ECO_RMASummary;
			oPageReference.setRedirect(true);
			oPageReference.getParameters().put('ProjectId', oQuestionnaireSet.Project__c);
			oPageReference.getParameters().put('qsName', EncodingUtil.urlEncode('Follow-up Risk Assessment', 'UTF-8'));
			return oPageReference;
			/*
			oQuestionnaireSet = new QuestionnaireSet__c();
			oQuestionnaireSet.Name = 'Follow-up Risk Assessment';
			oQuestionnaireSet.Project__c = theProject.Id;
			oPageReference = BeginRiskAssessment();
			*/
		}
		return oPageReference;
	}
	
	public PageReference ReturnToProject()
	{
        System.debug('theProject.id:  '+ theProject.Id );
        PageReference oPR = new PageReference('/' + oQuestionnaireSet.Project__c);
		oPR.setRedirect(true);
		return oPR;
	}


	public PageReference BeginRiskAssessment(){
		Questionnaire__c oFirstQuestionnaire = lQuestionnaires.get(0);
		system.debug('lQuestionnaires:  '+ lQuestionnaires);
		system.debug('oQuestionnaireSet.Id:  '+ oQuestionnaireSet.Id);
        try{
            businessUnitValue = oQuestionnaireSet.Project__r.BusinessUnit__c;
            if(String.isNotBlank(businessUnitValue))
                 businessUnit = true;
            
            if(oQuestionnaireSet.Id == null || oFirstQuestionnaire.Id == null)
            {
                if(oQuestionnaireSet.Id == null)
                {
                    if(oQuestionnaireSet.Name == null) 
                    {
                        oQuestionnaireSet.Name = 'Initial Assessment';
                    }
                    insert oQuestionnaireSet;
                }
    
                for(Questionnaire__c oQuestionnaire : lQuestionnaires)
                {
                    oQuestionnaire.QuestionnaireSet__c = oQuestionnaireSet.Id;
                }
    
                insert lQuestionnaires;
                
                String queryString = 'SELECT Id';
                queryString += ' , Name';
                queryString += ' , SortOrder__c';
                queryString += ' , (SELECT Id, IsRMQuestion__c ';
                    queryString += ' FROM Questions__r';
                    /*queryString += ' WHERE ((Region__c INCLUDES (\''+theProject.CarryingOutOrganization__r.Region__c+'\')';
                        queryString += ' OR Region__c = null';
                        queryString += ' OR Region__c = \'\')';
                        queryString += ' OR Region__c INCLUDES (\'ALL\'))';*/
                    queryString += ' WHERE (GeographiesAvailableTo__c INCLUDES (\''+theProject.CarryingOutOrganization__r.GeographyName__c+'\')';
                        queryString += ' OR GeographiesAvailableTo__c = null';
                        queryString += ' OR GeographiesAvailableTo__c = \'\'';
                        queryString += ' OR GeographiesAvailableTo__c INCLUDES (\'ALL\'))';
                    queryString += ' AND (BusinessLinesAvailableTo__c INCLUDES (\''+theProject.CarryingOutOrganization__r.BusinessLineName__c+'\')';	
                        queryString += ' OR BusinessLinesAvailableTo__c = null';
                        queryString += ' OR BusinessLinesAvailableTo__c = \'\'';
                        queryString += ' OR BusinessLinesAvailableTo__c INCLUDES (\'ALL\'))';					
                    queryString += ' AND IsActive__c = true';
                	queryString += ' AND (BusinessUnit__c = null OR BusinessUnit__c = \'\' ';
                    if(businessUnit)
                        queryString += ' OR BusinessUnit__c = :businessUnitValue)';
                    else
                        queryString += ')';
                    queryString += ' )';
                    
                queryString += ' FROM QuestionnaireTemplate__c where IsRMSection__c = true';
                queryString += ' ORDER BY SortOrder__c';
                
    
                map<Id, QuestionnaireTemplate__c> mQuestionnaireTemplates = new map<Id, QuestionnaireTemplate__c>();
                for (QuestionnaireTemplate__c qt : Database.query(queryString)) {
                    mQuestionnaireTemplates.put(qt.Id, qt);
                }
    
                list<Answer__c> lAnswersToInsert = new list<Answer__c>();
    
                for(Questionnaire__c oQuestionnaire : lQuestionnaires){
                    QuestionnaireTemplate__c oQuestionnaireTemplate = mQuestionnaireTemplates.get(oQuestionnaire.QuestionnaireTemplate__c);
    
                    for(TemplateQuestion__c oTemplateQuestion : oQuestionnaireTemplate.Questions__r){
                    	if(oTemplateQuestion.IsRMQuestion__c)
                        	lAnswersToInsert.add(new Answer__c(Questionnaire__c = oQuestionnaire.Id, TemplateQuestion__c = oTemplateQuestion.Id));
                    }
                }
    
                system.debug(lAnswersToInsert);
    
                insert lAnswersToInsert;
                /*
                if(lExportControls.size() == 0)
                {
                    lExportControls = new list<ExportControl__c>();
                    ExportControl__c oEC = new ExportControl__c(Status__c='Open', QuestionnaireSet__c=oQuestionnaireSet.Id);
                    lExportControls.add(oEC);
                    insert oEC;
                }
                */
                System.debug('# MarketAssessments: ' + lMarketAssessments.size());
                if(lMarketAssessments.size() == 0)
                {
                    lMarketAssessments = new list<MarketAssessment__c>();
                    MarketAssessment__c oMA = new MarketAssessment__c(Name='Market Assessment Document', Status__c='Open', QuestionnaireSet__c=oQuestionnaireSet.Id);
                    lMarketAssessments.add(oMA);
                    insert oMA;
                }
                
            }
    
            System.debug('Questionnaire ID: ' + oFirstQuestionnaire.Id);
            PageReference oPageReference = Page.ECO_RMAQuestionnaire;
            oPageReference.setRedirect(true);
            oPageReference.getParameters().put('id', oFirstQuestionnaire.Id);
    
            return oPageReference;
        }catch(Exception e){
            ApexPages.addMessages(e);
            return null;
        }
	}

	public PageReference AddParticipant(){
		lParticipants.add(new Participant__c(QuestionnaireSet__c = oQuestionnaireSet.Id));

		return null;
	}

	public PageReference CreateGoNoGoReview()
	{
		PageReference oPR;
		try
		{
			List<RecordType> LgoNoGORT = new List<RecordType>([Select Id From RecordType Where sObjectType = 'ProjectReview__c' And DeveloperName = 'GoNoGo']);

			if(!LgoNoGORT.isEmpty())
			{
				ProjectReview__c oGoNoGo = new ProjectReview__c();
				oGoNoGo.RecordTypeId = LgoNoGORT[0].Id;
				oGoNoGo.Project__c = oQuestionnaireSet.Project__c;
				oGoNoGo.Name = 'Go/No Go Meeting';
				oGoNoGo.Status__c = 'Assessing';
				List<AgendaItemTemplate__c> lAIT = new List<AgendaItemTemplate__c>([Select Id, Name, ProjectReviewTemplate__c From AgendaItemTemplate__c Where ProjectReviewTemplate__r.TemplateType__c = 'Go/No Go']);

				List<AgendaItem__c> lAI = new List<AgendaItem__c>();
				if(!lAIT.isEmpty())
				{
					oGoNoGo.ProjectReviewTemplate__c = lAIT[0].ProjectReviewTemplate__c;
					insert oGoNoGo;
					oQuestionnaireSet.GoNoGo_Review__c = oGoNoGo.Id;
					update oQuestionnaireSet;
					for(AgendaItemTemplate__c ait : lAIT)
					{
						AgendaItem__c ai = new AgendaItem__c();
						ai.ProjectReview__c = oGoNoGo.Id;
						ai.AgendaItemTemplate__c = ait.Id;
						ai.Name = ait.Name;
						lAI.add(ai);
					}
					insert lAI;
					oPR = Page.ECO_ProjectReviews;
					oPR.setRedirect(true);
					oPR.getParameters().put('id', oGoNoGo.Id);
				}
				showGoNoGoButton = false;
			}
			else
			{
				ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Review cannot be created. RecordType missing.');
            	ApexPages.addMessage(oPageMessage);
			}
		}
		catch(DmlException e)
		{
			System.debug('CreateGoNoGoReview error: ' + e.getMessage());
			ApexPages.addMessages(e);
		}
		return oPR;
	}
	
	class Notification
	{
		public String sMessage {get;set;}
		public Notification(String message)
		{
			this.sMessage = message;
		}
	}
}