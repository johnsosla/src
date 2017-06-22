public with sharing class ECO_MAQuestionnaireController {

    public Questionnaire__c MarketAssessment { get; set; }
    
    //public MarketAssessment__c oMarketAssessment {get; set;}
    public ApexPages.StandardController oStandardController {get; set;}
    public list<SelectOption> lAnswerValuesBoolean {get; set;}
    public Id questionnaireId {get; set;}
    public list<Answer__c> lAnswers {get; set;}
    public String userLanguage {get;set;}
    
    public ECO_MAQuestionnaireController()
    {
       /* list<string> lFields = new list<string>();
        lFields.add('QuestionnaireSet__c');

        if (!Test.isRunningTest()) {
          oStandardController.addFields(lFields);
        }
        
        lAnswerValuesBoolean = new list<SelectOption>{
            new SelectOption('True', 'Yes'),
            new SelectOption('False', 'No')
        };
        
        this.oMarketAssessment = (MarketAssessment__c)oStandardController.getRecord();
        this.oStandardController = oStandardController;
        */
        
        Id questionnaireId = ApexPages.currentPage().getParameters().get('questionnaire');
        
        if(questionnaireId == null)
        {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'You have reached this page improperly, please access it from the Project screen.');
            ApexPages.addMessage(oPageMessage);
            return;
        }        
        userLanguage = UserInfo.getLanguage();
        MarketAssessment = [Select Id, Name, QuestionnaireSet__r.ApprovalStatus__c From Questionnaire__c Where Id = :questionnaireId];
        lAnswers = ECO_Utils_Questionnaire.GetAnswersMarketAssessment(questionnaireId);
              
    }
    public PageReference SaveRecord()
    {
        for (Answer__c a : lAnswers) {
            a.Factor__c = a.TemplateQuestion__r.Factor__c;
            if(userLanguage == 'fr'){
                a.FrFactor__c = a.TemplateQuestion__r.FrFactor__c;
            }
            if (a.ScorePicklist__c == '5'){ 
                a.Rating__c = a.TemplateQuestion__r.Rating5__c;
                if(userLanguage == 'fr'){
                    a.FrRating__c = a.TemplateQuestion__r.FrRating5__c;
                }
            }
            if (a.ScorePicklist__c == '4'){
                a.Rating__c = a.TemplateQuestion__r.Rating4__c;
                if(userLanguage == 'fr'){
                    a.FrRating__c = a.TemplateQuestion__r.FrRating4__c;
                }
            }
            if (a.ScorePicklist__c == '3'){
                a.Rating__c = a.TemplateQuestion__r.Rating3__c;
                if(userLanguage == 'fr'){
                    a.FrRating__c = a.TemplateQuestion__r.FrRating3__c;
                }
            }
            if (a.ScorePicklist__c == '2'){
                a.Rating__c = a.TemplateQuestion__r.Rating2__c;
                if(userLanguage == 'fr'){
                    a.FrRating__c = a.TemplateQuestion__r.FrRating2__c;
                }
            }
            if (a.ScorePicklist__c == '1'){
                a.Rating__c = a.TemplateQuestion__r.Rating1__c;
                if(userLanguage == 'fr'){
                    a.FrRating__c = a.TemplateQuestion__r.FrRating1__c;
                }
            }   


        }
        update lAnswers;
    
        //oStandardController.save();
        //RefreshData();
        return null;
    }
    
    public void RefreshData()
    {
        
    }

    //public PageReference Cancel(){
    //    PageReference oPageReference = Page.ECO_RMASummary;

    //    oPageReference.getParameters().put('Id', oMarketAssessment.QuestionnaireSet__c);
    //    oPageReference.setRedirect(true);
        
    //    return oPageReference;
    //}

    public PageReference SaveNext()
    {

        for (Answer__c a : lAnswers) {
            a.Factor__c = a.TemplateQuestion__r.Factor__c;
            if (a.ScorePicklist__c == '5') a.Rating__c = a.TemplateQuestion__r.Rating5__c;
            if (a.ScorePicklist__c == '4') a.Rating__c = a.TemplateQuestion__r.Rating4__c;
            if (a.ScorePicklist__c == '3') a.Rating__c = a.TemplateQuestion__r.Rating3__c;
            if (a.ScorePicklist__c == '2') a.Rating__c = a.TemplateQuestion__r.Rating2__c;
            if (a.ScorePicklist__c == '1') a.Rating__c = a.TemplateQuestion__r.Rating1__c;
        }
        
        try {
            update lAnswers;  
        } catch(Exception e){
            ApexPages.addMessages(e);
            ECO_Service_ErrorLog.logException(e);
            return null;
        }         


        //oStandardController.save();
        //RefreshData();
        //PageReference oPageReference = Page.ECO_RMASummary;
        PageReference oPageReference = Page.ECO_RMSummary;
        
        oPageReference.getParameters().put('id', MarketAssessment.QuestionnaireSet__c);
        oPageReference.setRedirect(true);
        
        return oPageReference;
    }
    
    public PageReference ReturnToSummary()
    {
        //PageReference oPageReference = Page.ECO_RMASummary;
        PageReference oPageReference = Page.ECO_RMSummary;

        oPageReference.getParameters().put('id', MarketAssessment.QuestionnaireSet__c);
        oPageReference.setRedirect(true);
        
        return oPageReference;
    }    
    
    
}