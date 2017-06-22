public with sharing class ECO_RAQuestionnaireController extends ECO_PageControllerBase 
{ 

    public Questionnaire__c oQuestionnaire {get; set;}
    public list<Questionnaire__c> lQuestionnaires {get; set;}
    public ApexPages.StandardController oStandardController {get; set;}
    public Boolean showDOASection {get; set;}
    public Boolean showDOASubSection {get; set;}
    public Answer__c DOA_SectionAnswer {get;set;}

    private integer iIndex {get; set;}

    public class EcoControllerException extends Exception {}

    public map<string, list<Answer__c>> mDoAAnswers {get; set;}
    public map<string, list<Answer__c>> mNotDoAAnswers {get; set;}
    public list<Answer__c> lAnswers {get; set;}
    public Map<Id, Risk__c> questionToRiskMap { get; set; }  // Key is TemplateQuestion__c id
    public Map<Id, DOARegister__c> questionToDOAMap { get; set; }  // Key is TemplateQuestion__c id
    public Map<Id, String> questionToMitigationMap {get; set;}
    public list<TemplateQuestion__c> lTemplateQuestion {get; set;}
    public list<SelectOption> lAnswerValues {get; set;}
    public list<SelectOption> lAnswerValuesBoolean {get; set;}
    public list<Answer__c> deleteAnswer {get;set;}
    public Id selectedQuestionId {get; set;}
    public Id navTargetQuestionnaireId {get;set;}
    public Map<Id, Risk__c> questionToDeleteMap { get; set; }  // Key is risk id
    public list<Risk__c> lRiskToDelete { get; set; } 
    public list<DOARegister__c> lDoaToDelete { get; set; } 
    public String userLanguage {get;set;}

    public ECO_RAQuestionnaireController(ApexPages.StandardController oStandardController) {
        showDOASection = false;
        showDOASubSection = false;
        list<string> lFields = new list<string>();
        lFields.add('QuestionnaireSet__c');
        lFields.add('QuestionnaireSet__r.Project__c');
        lFields.add('QuestionnaireTemplate__c');
        if(!Test.isRunningTest()){
            oStandardController.addFields(lFields);
        }
        userLanguage = UserInfo.getLanguage();
        DOA_SectionAnswer = null;
        //lRiskToDelete = new list<Risk__c>();
        //lDoaToDelete = new list<DOARegister__c>();

        lAnswerValues = new list<SelectOption>{
            //new SelectOption('Yes', 'Yes'),
            //new SelectOption('No', 'No'),
            //new SelectOption('Unknown', 'Unknown')
            new SelectOption('Yes', Label.Yes),
            new SelectOption('No', Label.No),
            new SelectOption('Unknown', Label.Unknown)
        };
        
        lAnswerValuesBoolean = new list<SelectOption>{
            new SelectOption('True', 'True'),
            new SelectOption('False', 'False')
        };

        this.oQuestionnaire = (Questionnaire__c)oStandardController.getRecord();
        this.oStandardController = oStandardController;

        // Need these next lines because some users get this message: SObject row was retrieved via SOQL without querying the requested field: QuestionnaireSet__c.GoNoGoApprover__c
        List<Questionnaire__c> q = [Select QuestionnaireTemplate__c  From Questionnaire__c Where Id = :oQuestionnaire.Id];
        if (q.size() == 1) {         
            oQuestionnaire.QuestionnaireTemplate__c = q[0].QuestionnaireTemplate__c;
        }

        if(ECO_Utils_String.NullCheck(oQuestionnaire.QuestionnaireSet__c) == ''){
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'You have reached this page improperly, please access it from the Project screen.');
            ApexPages.addMessage(oPageMessage);

            return;
        }
        //lTemplateQuestion = new list<TemplateQuestion__c>([Select id From TemplateQuestion__c where Question_1__c = 'Does this project trigger any DoA Items?']);
        refreshData();
    }
    
    public PageReference goToSpecificQuestionnaire () {
        
        doSaveAction();
        
        refreshData();
        
        PageReference oPageReference = Page.ECO_RMAQuestionnaire;

        oPageReference.getParameters().put('id', navTargetQuestionnaireId);
        oPageReference.setRedirect(true);
        
        return oPageReference;
    }
    
    public PageReference doShowDOASection () {
        showDOASection = true;
        showDOASubSection = true;        
        
        return null;
    }
    
    public PageReference doHideDOASection () {
        showDOASection = false;
        showDOASubSection = false;
        return null;
    }
    
    public void refreshData(){
        
        //lQuestionnaires = ECO_Utils_Questionnaire.GetQuestionnaires(oQuestionnaire.QuestionnaireSet__c);
        lQuestionnaires = new list<Questionnaire__c>([SELECT Id
                                                            , Name
                                                            , ProjectRisk__c
                                                            , DoATriggers__c
                                                            , PercentComplete__c
                                                            , QuestionnaireTemplate__r.SortOrder__c
                                                    FROM Questionnaire__c 
                                                    WHERE QuestionnaireSet__c = :oQuestionnaire.QuestionnaireSet__c
                                                     ORDER BY QuestionnaireTemplate__r.SortOrder__c]);
        iIndex = ECO_Utils_Questionnaire.FindQuestionnaireIndex(lQuestionnaires, oQuestionnaire);
        lAnswers = ECO_Utils_Questionnaire.GetAnswersRiskAssessment(oQuestionnaire.Id);
        mDoAAnswers = new map<string, list<Answer__c>>();
        mNotDoAAnswers = new map<string, list<Answer__c>>();
        questionToRiskMap = new Map<Id, Risk__c>();
        questionToDOAMap = new Map<Id, DOARegister__c>();

        System.Debug('BrenbrentBrent ' + lAnswers.size());
    
        for(Answer__c oAnswer : lAnswers)
        {           
            if(oAnswer.TemplateQuestion__r.IsDoATrigger__c)
            {
                if(!mDoAAnswers.containsKey(oAnswer.TemplateQuestion__r.QuestionSet__c))
                {
                    mDoAAnswers.put(oAnswer.TemplateQuestion__r.QuestionSet__c, new list<Answer__c>());
                }
                mDoAAnswers.get(oAnswer.TemplateQuestion__r.QuestionSet__c).add(oAnswer);
                                              
                //Preload the DOA map
                DOARegister__c newDOA = new DOARegister__c();
                newDOA.Questionnaire__c = oQuestionnaire.Id;
                newDOA.DCSsubDOA__c = oAnswer.TemplateQuestion__r.DCSSubDOA__c;
                newDOA.EnterpriseDOA__c = oAnswer.TemplateQuestion__r.EnterpriseDOA__c;
                newDOA.DOATrigger__c = oAnswer.TemplateQuestion__r.Question_1__c;
                newDOA.RiskTitle__c = oAnswer.TemplateQuestion__r.RiskTitle__c;
                newDOA.TemplateQuestion__c = oAnswer.TemplateQuestion__c;    

                if(userLanguage == 'fr'){
                    newDOA.FrRiskTitle__c = oAnswer.TemplateQuestion__r.FrRiskTitle__c;
                    newDOA.FrDOATrigger__c = oAnswer.TemplateQuestion__r.FrQuestion_1__c;
                }
                
                questionToDOAMap.put(oAnswer.TemplateQuestion__c, newDOA);
            }
            else
            {
               // if(!oAnswer.TemplateQuestion__r.isDOAmaster__c){  
                    if(!mNotDoAAnswers.containsKey(oAnswer.TemplateQuestion__r.QuestionSet__c))
                    {                      
                        mNotDoAAnswers.put(oAnswer.TemplateQuestion__r.QuestionSet__c, new list<Answer__c>());
                    }          
                    mNotDoAAnswers.get(oAnswer.TemplateQuestion__r.QuestionSet__c).add(oAnswer);
                    
                // Show the answers section if the section header is 'yes'         
                if(oAnswer.TemplateQuestion__r.isDOAmaster__c && 'Yes'.equalsIgnoreCase(oAnswer.Value__c)) 
                {           
                    doShowDOASection();                 
                }                      
                    
                    
              /*  } else {
                    DOA_SectionAnswer = oAnswer;
                    //DOA_SectionAnswer.Value__c = 'True';
                    showDOASection = true;
                 }*/
            } 

            // Preload the risk map
            questionToRiskMap.put(oAnswer.TemplateQuestion__c, new Risk__c());
        }
        //if(mDoAAnswers.size()>0)
        //    showDOASubSection = true;
        for (Risk__c r : ECO_Service_Risks.getRisksForAnswers(lAnswers)) {
            questionToRiskMap.put(r.Answer__r.TemplateQuestion__c, r);
            System.debug('r:::::' + r);
        }
        System.debug('questionToRiskMap Size::::::'+questionToRiskMap.size()+'    questionToRiskMap::::::::::  '+questionToRiskMap);
        for (DOARegister__c d : ECO_Service_Risks.getDOAForAnswers(lAnswers)) {
            questionToDOAMap.put(d.TemplateQuestion__c, d);
            //d.MitigationStrategy__c = questionToMitigationMap.get(d.TemplateQuestion__c);
        }
        //reset risk and doa lists
        lRiskToDelete = new list<Risk__c>();
        System.debug('refreshData - lRiskToDelete::::'+lRiskToDelete.isEmpty());
        lDoaToDelete = new list<DOARegister__c>();
                
        return;
    }
    
    public PageReference addRiskToAnswer () {
        Risk__c newRisk = new Risk__c();
        if(questionToRiskMap.containsKey(selectedQuestionId) && questionToRiskMap.get(selectedQuestionId).Project__c != null)
        {
            //System.debug('addRiskToAnswer - check for old risk::::' + questionToRiskMap.get(selectedQuestionId).Project__c);
            Risk__c oldRisk = new Risk__c();
            oldRisk = questionToRiskMap.get(selectedQuestionId);  
            newRisk = oldRisk;                            
        }        
        else{
            newRisk.Questionnaire__c = oQuestionnaire.Id;
            newRisk.Project__c = oQuestionnaire.QuestionnaireSet__r.Project__c;
            if(oQuestionnaire.Name == 'SH&E and Resilience')
                newRisk.PlanElement__c = 'SH&E';
            else
                newRisk.PlanElement__c = oQuestionnaire.Name;
        }
        
        questionToRiskMap.put(selectedQuestionId, newRisk);
system.debug('###' + questionToRiskMap);        
        return null;
    }
    
    public PageReference removeRiskFromAnswer () { 
        if(questionToRiskMap.containsKey(selectedQuestionId))
        {
            Risk__c risk = new Risk__c();
            risk = questionToRiskMap.get(selectedQuestionId);
            if(risk.Answer__c!=null){
                lRiskToDelete.add(risk);
            }  
        }       
        questionToRiskMap.put(selectedQuestionId, new Risk__c());       
        return null;
    }
    


    public PageReference addDOARiskToAnswer () 
    {
        if(questionToDOAMap.containsKey(selectedQuestionId))
        {
            DOARegister__c doa = questionToDOAMap.get(selectedQuestionId);

                doa.Project__c = oQuestionnaire.QuestionnaireSet__r.Project__c;
                //doa.MitigationStrategy__c = oQuestionnaire.
                questionToDOAMap.put(selectedQuestionId, doa);
                System.debug('questionToRiskMap[answer.TemplateQuestion__c].RiskMitigation__c::::::'+questionToRiskMap.get(selectedQuestionId));
                //add a risk for each DOA as well
                Risk__c newRisk = new Risk__c();
                if(questionToRiskMap.containsKey(selectedQuestionId) && questionToRiskMap.get(selectedQuestionId).Project__c != null)
                {
                    Risk__c oldRisk = new Risk__c();
                    oldRisk = questionToRiskMap.get(selectedQuestionId);  
                    newRisk = oldRisk;                            
                }        
                else{    
                    newRisk.Questionnaire__c = oQuestionnaire.Id;
                    newRisk.Project__c = oQuestionnaire.QuestionnaireSet__r.Project__c;
                    if(oQuestionnaire.Name == 'SH&E and Resilience'){
                        newRisk.PlanElement__c = 'SH&E';
                    }else{
                        newRisk.PlanElement__c = oQuestionnaire.Name;
                    }
                    //newRisk.PlanElement__c = oQuestionnaire.Name;
                    newRisk.DoATrigger__c = true;
                }
                questionToRiskMap.put(selectedQuestionId, newRisk);
system.debug('!!!' + questionToRiskMap);
        }
        
        return null;
    }
    
    public PageReference removeDOARiskFromAnswer (){        
        if(questionToRiskMap.containsKey(selectedQuestionId))
        {
            Risk__c risk = new Risk__c();
            risk = questionToRiskMap.get(selectedQuestionId);
            if(risk.Answer__c!=null){
                lRiskToDelete.add(risk);
            }
        }    
        questionToDOAMap.put(selectedQuestionId, new DOARegister__c());        
        questionToRiskMap.put(selectedQuestionId, new Risk__c());
               
        return null;
    }
    
    private void doSaveAction () 
    {
        try
        {
            markDOAAnswersAsNoIfParentIsNo();
            questionToMitigationMap = new Map<Id, String>();
            ////oStandardController.save();
            upsert lAnswers;
            // Create our map so we can set the answer field properly on the risks
            Map<Id, Id> questionTemplateToAnswerMap = new Map<Id, Id>();
            Boolean ExportControlExists = ECO_Utils_Questionnaire.ExportControlExists(oQuestionnaire.QuestionnaireSet__c);
            for (Answer__c a : lAnswers) 
            { 
                
                if (a.TemplateQuestion__r.IsDOAMaster__c == true) continue;
                
                questionTemplateToAnswerMap.put(a.TemplateQuestion__c, a.Id);
                if(a.TemplateQuestion__r.RiskTitle__c == 'Export Controls' && !ExportControlExists && (a.Value__c == 'Yes' || a.Value__c == 'Unknown')) 
                {
                    //create Export Control record
                    string projectDescription = [SELECT ProjectDescription__c FROM pse__Proj__c where Id =: oQuestionnaire.QuestionnaireSet__r.Project__c LIMIT 1].ProjectDescription__c;
                    ExportControl__c oEC = new ExportControl__c(Status__c='Open', QuestionnaireSet__c=oQuestionnaire.QuestionnaireSet__c, Project__c = oQuestionnaire.QuestionnaireSet__r.Project__c, ProjectDescription__c = projectDescription);

                    insert oEC;
                    ExportControlExists = true;
                }
                
                //Mark all the DOA answers as No if the DoaMaster question is No
                if(!showDOASubSection)   //DoaMaster question == No
                {
                    if (a.templatequestion__r.IsDoATrigger__c) 
                    {
                        a.Value__c = 'No'; 
                    }                 
                }
                
            }
            System.debug('Reached cleanEmptyRisks!');
            cleanEmptyRisks();
            System.debug('cleanEmptyRisks Passed');
            for (Id i : questionToRiskMap.keySet()) {
                questionToRiskMap.get(i).Answer__c = questionTemplateToAnswerMap.get(i);
                questionToMitigationMap.put(i, questionToRiskMap.get(i).RiskMitigation__c);
            }

            for (Id i : questionToDOAMap.keySet()) {
                
                questionToDOAMap.get(i).Answer__c = questionTemplateToAnswerMap.get(i);
                questionToDOAMap.get(i).MitigationStrategy__c = questionToMitigationMap.get(i);
            } 
            
            upsert questionToRiskMap.values();
            upsert questionToDOAMap.values();
            
            oQuestionnaire.HasDOATriggers__c = showDOASection;
            update oQuestionnaire;


        } 
        catch (Exception e) 
        {
            System.debug('doSaveAction error: ' + e.getMessage());
            //ApexPages.addMessages(e);  // TODO:  Make this pretty
            ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
        }
        System.debug('oSaveAction Finished!');
    }
    
    private void markDOAAnswersAsNoIfParentIsNo () {
        Boolean isSectionHeaderNo = false;
        for (Answer__c a : lAnswers) 
        {
            // Check if this is the header question for the DOA section, and if it's 'No'
            //if (a.TemplateQuestion__r.IsDoATrigger__c 
            if(a.TemplateQuestion__r.isDOAmaster__c
                && 'No'.equalsIgnoreCase(a.Value__c)) {
                    isSectionHeaderNo = true;
                    break;
            }
        }
        
        // If it is equal to 'no', our boolean is true, so let's loop over them again and set the kids to no
        if (isSectionHeaderNo) {
            for (Answer__c a : lAnswers) {
                // Only set to 'no' if the type matches DOA trigger
            if (questionToDOAMAP.containsKey(a.TemplateQuestion__c)) {
                a.Value__c = 'No';
                }
            }
        }
    }
    
    private void cleanEmptyRisks () {   
        System.debug('cleanEmptyRisks line 1::::'+lRiskToDelete);      
        for (Id questionId : questionToRiskMap.keySet()) {
            Risk__c thisRisk = questionToRiskMap.get(questionId);
            Boolean keepThisRisk = false;
            keepThisRisk = (thisRisk.Project__c != null) ? true : false;
            
            if (!keepThisRisk ) {
                questionToRiskMap.remove(questionId); 
                              
            }
        }
        System.debug('Risk to be deleted::::' + lRiskToDelete.isEmpty() + ' | ' + lRiskToDelete);                 
        if(!lRiskToDelete.isEmpty()){
            delete lRiskToDelete;
        }    
        

        for (Id questionId : questionToDOAMap.keySet()) {
            DOARegister__c thisDOA = questionToDOAMap.get(questionId);
            Boolean keepThisDOA = false;
            
            keepThisDOA = (thisDOA.Project__c != null) ? true : false;
            
            if (!keepThisDOA) {
                questionToDOAMap.remove(questionId);
                
            }
        }
        System.debug('DOA to be deleted::::' + lDoaToDelete.isEmpty() + ' | ' + lDoaToDelete); 
        if(!lDoaToDelete.isEmpty()){
            delete lDoaToDelete;
        }
    }

    private boolean checkMitigation(){
        for(string RMKey: questionToRiskMap.keySet()){

            Risk__c risk = questionToRiskMap.get(RMKey);

            //if(risk.Project__c != null && risk.DoATrigger__c==false){
            if(risk.Project__c != null ){
                if(risk.RiskMitigation__c == '' || risk.RiskMitigation__c == null){
                    return true;
                }
            }

        }  

        return false;
    }

    public PageReference SaveNext(){

       List<Questionnaire__c> qs = [Select Id From Questionnaire__c Where QuestionnaireSet__c = :oQuestionnaire.QuestionnaireSet__c And Name = 'Market Assessment' limit 1];
        Id maId = null;
        
        if (qs.size() > 0) {
            maId = qs[0].Id;
        }
        else {
           Questionnaire__c oMA = new Questionnaire__c(Name='Market Assessment', QuestionnaireSet__c=oQuestionnaire.QuestionnaireSet__c);
           insert oMA;
           maId = oMA.Id;
        }
        
        List<Answer__c> ans = [Select Id From Answer__c Where Questionnaire__c = :maId];
        
        if (ans.size() == 0) {
            for (TemplateQuestion__c tq : [Select Id From TemplateQuestion__c Where QuestionnaireTemplate__r.Name = 'Market Assessment']){
                Answer__c an = new Answer__c(Questionnaire__c = maId, TemplateQuestion__c = tq.Id);
                ans.add(an);        
            }
            insert ans;        
        }
                
        
        PageReference oPageReference = Page.ECO_MAQuestionnaire;
        oPageReference.setRedirect(true);
        oPageReference.getParameters().put('questionnaire', maId);

        if(checkMitigation()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Mitigation Strategy: Validation Error: Value is required.'));
            return null;
        }

        doSaveAction();
        
        if (ApexPages.getMessages().size() == 0) {
            refreshData();
            return oPageReference;
        }
        else{
            return null;
        }
      
            
        /*PageReference oPageReference = Page.ECO_RMSummary;

        oPageReference.getParameters().put('Id', oQuestionnaire.QuestionnaireSet__c);
        oPageReference.setRedirect(true);
                
        doSaveAction();
        if (ApexPages.getMessages().size() == 0) {
            refreshData();
            return oPageReference;
        }
        else{
            return null;
        }*/
                
        
        /*
        if(checkMitigation()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Mitigation Strategy: Validation Error: Value is required.'));
            return null;
        }

        if(iIndex + 1 < 0){
            throw new EcoControllerException('Error Cannot Go Next');
        }
        
        iIndex++;
        
        system.debug('lQuestionnaires.size():  '+lQuestionnaires.size());
        
        if (lQuestionnaires.size() <= iIndex) {
            
            List<MarketAssessment__c> lMarketAssessment = [SELECT Id 
                                                            FROM MarketAssessment__c 
                                                            WHERE QuestionnaireSet__c = :oQuestionnaire.QuestionnaireSet__c];
            system.debug('lMarketAssessment:  '+lMarketAssessment);
            if (!lMarketAssessment.isEmpty()) {

                doSaveAction();
                if (ApexPages.getMessages().size() == 0) {
                    refreshData();
                    return new PageReference('/'+lMarketAssessment[0].Id);
                }
                else{
                    return null;
                }
                
            } else {
                //PageReference oPageReference = Page.ECO_RMASummary;
                PageReference oPageReference = Page.ECO_RMSummary;

                oPageReference.getParameters().put('Id', oQuestionnaire.QuestionnaireSet__c);
                oPageReference.setRedirect(true);
                
                doSaveAction();
                if (ApexPages.getMessages().size() == 0) {
                    refreshData();
                    return oPageReference;
                }
                else{
                    return null;
                }
                
                
            }
            
        }
        
        Questionnaire__c oPreviousQuestionnaire = lQuestionnaires.get(iIndex);

        doSaveAction();
        if (ApexPages.getMessages().size() == 0) {
            PageReference oPageReference = Page.ECO_RMAQuestionnaire;

            oPageReference.getParameters().put('Id', oPreviousQuestionnaire.Id);
            oPageReference.setRedirect(true);

            refreshData();

            return oPageReference;
        }else {
            return null;
        }*/
    }

    public PageReference SavePrevious(){

        if(checkMitigation()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Mitigation Strategy: Validation Error: Value is required.'));
            return null;
        }

        if(iIndex - 1 < 0){
            throw new EcoControllerException('Error Cannot Go Previous');
        }

        Questionnaire__c oPreviousQuestionnaire = lQuestionnaires.get(iIndex - 1);

        doSaveAction();
        if (ApexPages.getMessages().size() == 0) {
            PageReference oPageReference = Page.ECO_RMAQuestionnaire;

            oPageReference.getParameters().put('Id', oPreviousQuestionnaire.Id);
            oPageReference.setRedirect(true);

            refreshData();

            return oPageReference;
        }else{
            return null;
        }
    }

    public PageReference SaveRecord(){
        System.debug('SaveRecord hit!');
        if(checkMitigation()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Mitigation Strategy: Validation Error: Value is required.'));
            return null;
        }

        doSaveAction();

        refreshData();

        return null;
    }

    public PageReference ReturnToSummary(){
        //PageReference oPageReference = Page.ECO_RMASummary;
        PageReference oPageReference = Page.ECO_RMSummary;

        oPageReference.getParameters().put('id', oQuestionnaire.QuestionnaireSet__c);
        oPageReference.setRedirect(true);

        refreshData();

        return oPageReference;
    }
    public PageReference SetDefaultNo(){
        for(Answer__c oAnswer : lAnswers){
            
            if(oAnswer.TemplateQuestion__r.IsDoATrigger__c == true && (oAnswer.Value__c == '' || oAnswer.Value__c == null)){
            //if(oAnswer.Value__c == '' || oAnswer.Value__c == null){
                oAnswer.Value__c = 'No';
            }
        }
        return null;
    }
    
    
    
}