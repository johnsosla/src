public without sharing virtual class ECO_RMSummaryController extends ECO_PageControllerBase 
{
    public ApexPages.StandardController oStandardController {get; set;}
    public QuestionnaireSet__c oQuestionnaireSet {get; set;}
    public list<Participant__c> lParticipants {get; set;}
    public list<Questionnaire__c> lQuestionnaires {get; set;}
    public list<Questionnaire__c> lQuestionnairesInit {get; set;}    
    public list<ExportControl__c> lExportControls {get; set;}
    public list<Questionnaire__c> lMarketAssessments {get; set;}
    public list<Questionnaire__c> lMarketAssessmentInit {get; set;}    
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
    public Integer scoreMA {get;set;}
    public Integer percentMA {get;set;}
    public String recommendationMA {get;set;}    
    public list<Agreement__c> agreementsWithDOACondtions {get; set;}
    public Id questionnaireId {get; set;}
    public String oldQSName {get; set;}
    public Boolean hasUpdateAccess {get; set;}

    public ECO_RMSummaryController(ApexPages.StandardController oStandardController) {
        hasUpdateAccess = false;
        this.oStandardController = oStandardController;
        list<string> lFields = new list<string>();
        lFields.add('Name');
        lFields.add('TotalQuestions__c');
        lFields.add('ProjectManager__c');
        lFields.add('Project__r.BusinessUnit__c');
        lFields.add('GoNoGo_Review__c');
        lFields.add('GoNoGoApprover__c');
        if(!Test.isRunningTest()){
            oStandardController.addFields(lFields);
        }

        oQuestionnaireSet = (QuestionnaireSet__c)oStandardController.getRecord();

        // Need these next lines because some users get this message: SObject row was retrieved via SOQL without querying the requested field: QuestionnaireSet__c.GoNoGoApprover__c
        List<QuestionnaireSet__c> qs = [Select GoNoGoApprover__c From QuestionnaireSet__c Where Id = :oQuestionnaireSet.Id];
        if (qs.size() == 1) {         
            oQuestionnaireSet.GoNoGoApprover__c = qs[0].GoNoGoApprover__c;
        }
    
        if(ECO_Utils_String.NullCheck(oQuestionnaireSet.Project__c) == ''){
            oQuestionnaireSet.Project__c = ApexPages.currentPage().getParameters().get('ProjectId');
        }

        if(ECO_Utils_String.NullCheck(oQuestionnaireSet.Name) == ''){
            oQuestionnaireSet.Name = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('qsName'), 'UTF-8');
        }
        oldQSName = oQuestionnaireSet.Name;

        if(ECO_Utils_String.NullCheck(oQuestionnaireSet.Project__c) == ''){
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'You have reached this page improperly, please access it from the Project screen.');
            ApexPages.addMessage(oPageMessage);
            return;
        }
          
        getTheProject();

        if(ECO_Service_Users.isSystemAdminstrator(UserInfo.getProfileId()) || ECO_Service_RecordAccess.getRecordAccess(theProject.Id, 'QuestionnaireSet__c')) {
            hasUpdateAccess = true;
        }

        system.debug(oQuestionnaireSet);
            
        lParticipants = new list<Participant__c>([SELECT Id
                                                        , User__c 
                                                FROM Participant__c 
                                                WHERE QuestionnaireSet__c = :oQuestionnaireSet.Id]);

        if(lParticipants.size() == 0)
        {
            lParticipants.add(new Participant__c(QuestionnaireSet__c = oQuestionnaireSet.Id));
        }

        lQuestionnaires = new list<Questionnaire__c>([SELECT Id
                                                            , Name
                                                            , ProjectRisk__c
                                                            , DoATriggers__c
                                                            , PercentComplete__c 
                                                            , QuestionnaireTemplate__r.SortOrder__c
                                                    FROM Questionnaire__c 
                                                    WHERE QuestionnaireSet__c = :oQuestionnaireSet.Id
                                                    AND Name = 'Risk Assessment'
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
            //queryString += ' FROM QuestionnaireTemplate__c where IsRMSection__c = true';
            queryString += ' FROM QuestionnaireTemplate__c where Name = \'Risk Assessment\'';

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
        
        lMarketAssessmentInit = new List<Questionnaire__c>();
        lMarketAssessmentInit.add(new Questionnaire__c(Name = 'Market Assessment'));
        lQuestionnairesInit = new List<Questionnaire__c>();
        lQuestionnairesInit.add(new Questionnaire__c(Name = 'Risk Assessment'));        
        
        /*lMarketAssessments = new list<MarketAssessment__c>([Select Id
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
                                                            WHERE QuestionnaireSet__c = :oQuestionnaireSet.Id]);   */  
                                           
        lMarketAssessments = [Select Id, Name From Questionnaire__c Where QuestionnaireSet__c = :oQuestionnaireSet.Id And Name = 'Market Assessment'];
                                                
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
        System.debug('In controller percentMA:    '+percentMA+'   countMA:  '+scoreMA);

    }
    
    public PageReference init()
    {
    
      /*  if(lMarketAssessments.size() == 0)
        {
            lMarketAssessments = new list<Questionnaire__c>();
            Questionnaire__c oMA = new Questionnaire__c(Name='Market Assessment', QuestionnaireSet__c=oQuestionnaireSet.Id);
            lMarketAssessments.add(oMA);
            insert oMA;
        }   */    

        PageReference oPR;

        //Redirect if an old project        
        Date releaseDate = ECONewRMAssessmentDate__c.getInstance().Date__c;

        Date projectDate;
        if (oQuestionnaireSet.Id != null) {
            projectDate = [Select CreatedDate From QuestionnaireSet__c Where Id = :oQuestionnaireSet.Id].CreatedDate.Date();
            
            if (projectDate < releaseDate) {
                oPR = Page.ECO_RMASummary;  
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
        //return oPR;
        return null;
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
            //Already approved - Don't submit again.
            if([select ApprovalStatus__c from QuestionnaireSet__c where id =: oQuestionnaireSet.Id].ApprovalStatus__c == 'Approved') {
                return null;
            }
        
        
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
            oQuestionnaireSet.GoNoGoApprover__c = theProject.GoNoGoApprover__r.pse__Salesforce_User__c;

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
        
        //PageReference oPageReference = Page.ECO_RMAQuestionnaire;
        PageReference oPageReference = Page.ECO_RAQuestionnaire;

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
            String query = 'SELECT Id, PrimaryEndClient__c, PrimaryBillingClient__c, ProjectOwningOrg__c, ProjectNumber__c, CarryingOutOrganization__c, CarryingOutOrganization__r.Region__c, CarryingOutOrganization__r.GeographyName__c, CarryingOutOrganization__r.BusinessLineName__c, AccountManager__c, pse__Opportunity__c, CaptureManager__r.pse__Salesforce_User__c, pse__Project_Manager__r.pse__Salesforce_User__c, ProjectApprover__r.pse__Salesforce_User__c, PnLManager__r.pse__Salesforce_User__c, GoNoGoApprover__r.pse__Salesforce_User__c ';
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
                Notification oNote = new Notification(Label.RMA_Export_Controls_Document_Missing);
                lNotifications.add(oNote);
            }
        }

        // System.debug('In validate, check size of lProjectCountryRisks');     
        if(lProjectCountryRisks.size() == 0)
        {
            Notification oNote = new Notification(Label.RMA_No_Country_Selected);
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
                    String notificationString = Label.RMA_Location_Security_Risk_Greater_Than_2_9+' ';
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
                    Notification oNote = new Notification(notificationString.left(1000));
                    lNotifications.add(oNote);
                    break;
                }
            }
        }
        
        // System.debug('In validate, check size of agreementsWithDOACondtions');
        if(agreementsWithDOACondtions.size() > 0)
        {
            Notification oNote = new Notification(Label.RMA_MSA_Has_Existing_DOA_Conditions_of_Approval);
            lNotifications.add(oNote);      
        }

        // System.debug('In validate, null check AccountManager__c');
        if(!(theProject.AccountManager__c == '' || theProject.AccountManager__c ==null))
        {
            Notification oNote = new Notification(Label.RMA_Has_Nominated_Client_Account_Manager);
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
    
        
        List<Questionnaire__c> qs = [Select Id From Questionnaire__c Where QuestionnaireSet__c = :oQuestionnaireSet.Id And Name = 'Market Assessment'];
        
        if (qs.size() > 0) {
            questionnaireId = qs[0].Id;
            List<Answer__c> lAnswers = [SELECT  Id, Score__c FROM Answer__c WHERE Questionnaire__c = :questionnaireId AND TemplateQuestion__r.QuestionnaireTemplate__r.Name = 'Market Assessment' And TemplateQuestion__r.IsActive__c = true];  
    
            if (lAnswers.size() > 0) {
                scoreMA = 0;
                percentMA = 0;
                for (Answer__c a : lAnswers) 
                {
                    if (a.Score__c != null) {
                        scoreMA += Integer.valueOf(a.Score__c);            
                        percentMA++;
                    }                
                }
                                       
                recommendationMA = 'Go';
                if (scoreMA < 44) recommendationMA = 'Review Required';
                if (scoreMA < 33) recommendationMA = 'No Go';

                percentMA = Integer.valueOf(percentMA * 100 / lAnswers.size());
            }
        }

    }
    
    public PageReference SelectNewQuestionnaire()
    {
        system.debug('sSelectedQuestionnaireSet' + sSelectedQuestionnaireSet);
        PageReference oPageReference;
        if(sSelectedQuestionnaireSet != '' && sSelectedQuestionnaireSet != null)
        {
            oPageReference = Page.ECO_RMSummary;
            oPageReference.setRedirect(true);
            oPageReference.getParameters().put('id', sSelectedQuestionnaireSet);
        }
        else
        {
            oPageReference = Page.ECO_RMSummary;
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
    
        if (oQuestionnaireSet.Id == null && oStandardController.getId() != null) {
            oQuestionnaireSet.Id = oStandardController.getId();
        }
        
        try {
            if (oQuestionnaireSet != null && hasUpdateAccess) {     
            //if (oQuestionnaireSet != null) {        
                update oQuestionnaireSet;
            }    
        } catch(Exception e){
            ApexPages.addMessages(e);
            ECO_Service_ErrorLog.logException(e);
            return null;
        }          
    
        Questionnaire__c oFirstQuestionnaire;
            
        if (lQuestionnaires.size() > 0) {
            oFirstQuestionnaire = lQuestionnaires.get(0);
        }    
            
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
               // queryString += ' , IsDoATrigger__c';
                queryString += ' , (SELECT Id, IsRMQuestion__c, IsDOATrigger__c ';
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
                    
                //queryString += ' FROM QuestionnaireTemplate__c where IsRMSection__c = true';
                queryString += ' FROM QuestionnaireTemplate__c where Name = \'Risk Assessment\'';
                
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
                            lAnswersToInsert.add(new Answer__c(Questionnaire__c = oQuestionnaire.Id, TemplateQuestion__c = oTemplateQuestion.Id , DOATrigger__c = oTemplateQuestion.IsDOATrigger__c));
                    }
                }
    
                system.debug('lAnswersToInsert' + lAnswersToInsert.size());
    
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
                /*if(lMarketAssessments.size() == 0)
                {
                    lMarketAssessments = new list<MarketAssessment__c>();
                    MarketAssessment__c oMA = new MarketAssessment__c(Name='Market Assessment', Status__c='Open', QuestionnaireSet__c=oQuestionnaireSet.Id);
                    lMarketAssessments.add(oMA);
                    insert oMA;
                }*/
                
            }
    
            System.debug('Questionnaire ID: ' + oFirstQuestionnaire.Id);
            //PageReference oPageReference = Page.ECO_RMAQuestionnaire;
            PageReference oPageReference = Page.ECO_RAQuestionnaire;
            oPageReference.setRedirect(true);
            oPageReference.getParameters().put('id', oFirstQuestionnaire.Id);
    
            return oPageReference;
        }catch(Exception e){
            ApexPages.addMessages(e);
            return null;
        }
    }

    public PageReference BeginMarketAssessment(){
        
        List<Questionnaire__c> qs = [Select Id From Questionnaire__c Where QuestionnaireSet__c = :oQuestionnaireSet.Id And Name = 'Market Assessment' limit 1];
        Id maId = null;
        
        if (qs.size() > 0) {
            maId = qs[0].Id;
        }
        else {
           Questionnaire__c oMA = new Questionnaire__c(Name='Market Assessment', QuestionnaireSet__c=oQuestionnaireSet.Id);
           
            try {
                insert oMA;   
            } catch(Exception e){
                ApexPages.addMessages(e);
                ECO_Service_ErrorLog.logException(e);
                return null;
            }                                    
           maId = oMA.Id;
        }
        
        List<Answer__c> ans = [Select Id From Answer__c Where Questionnaire__c = :maId];
        
        if (ans.size() == 0) {
            for (TemplateQuestion__c tq : [Select Id, Question_1__c From TemplateQuestion__c Where QuestionnaireTemplate__r.Name = 'Market Assessment']){
                Answer__c an = new Answer__c(Questionnaire__c = maId, TemplateQuestion__c = tq.Id, IsFreeForm__c = (tq.Question_1__c == 'Additional Information'));
                ans.add(an);        
            }
            
            try {
                insert ans;   
            } catch(Exception e){
                ApexPages.addMessages(e);
                ECO_Service_ErrorLog.logException(e);
                return null;
            }             
                  
        }
             
           
        
        PageReference oPageReference = Page.ECO_MAQuestionnaire;
        oPageReference.setRedirect(true);
        oPageReference.getParameters().put('questionnaire', maId);
    
        return oPageReference;        
        
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
    
    public PageReference Save(){
    
        //oStandardController.save();

        oQuestionnaireSet.Id = oStandardController.getId();
        
        try {
            update oQuestionnaireSet;
        } catch(Exception e){
            ApexPages.addMessages(e);
            ECO_Service_ErrorLog.logException(e);
            return null;
        }         
                
        PageReference oPageReference = new PageReference('/' + oQuestionnaireSet.Id); 

        //PageReference oPageReference = Page.ECO_RMSummary;
        //oPageReference.getParameters().put('id', oQuestionnaireSet.Id);

        oPageReference.setRedirect(true);

        return oPageReference;

    }    
}