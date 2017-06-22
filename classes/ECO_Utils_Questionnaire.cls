public with sharing class ECO_Utils_Questionnaire {
    public class EcoServiceException extends Exception {}

    public static list<Questionnaire__c> GetQuestionnaires(Id sQuestionnaireSetId){
        list<Questionnaire__c> lQuestionnaires = new list<Questionnaire__c>([SELECT Id, Name, ProjectRisk__c, DoATriggers__c, PercentComplete__c, QuestionnaireTemplate__c, QuestionnaireTemplate__r.Id FROM Questionnaire__c WHERE QuestionnaireSet__c = :sQuestionnaireSetId]);

        return lQuestionnaires;
    }

    public static list<QuestionnaireSet__c> GetRelatedQuestionnaireSets(Id sProjectId){
        list<QuestionnaireSet__c> lQuestionnaireSets = new list<QuestionnaireSet__c>([SELECT Id
                                                                                           , Name
                                                                                           , ApprovalStatus__c
                                                                                      FROM QuestionnaireSet__c WHERE Project__c = :sProjectId]);

        return lQuestionnaireSets;
    }

    public static integer FindQuestionnaireIndex(list<Questionnaire__c> lQuestionnaires, Questionnaire__c oQuestionnaireToValidate){
        integer iIndex = 0;

        for(Questionnaire__c oQuestionnaire : lQuestionnaires){
            system.debug(oQuestionnaire.QuestionnaireTemplate__c);
            system.debug(oQuestionnaireToValidate.QuestionnaireTemplate__c);

            if(oQuestionnaireToValidate.QuestionnaireTemplate__c == oQuestionnaire.QuestionnaireTemplate__c){
                return iIndex;
            }

            iIndex++;
        }

        throw new EcoServiceException('Record Not Found');

        return iIndex;
    }

    public static list<Answer__c> GetAnswers(Id sQuestionnaireId){
        list<Answer__c> lAnswers = new list<Answer__c>([SELECT  Id
                                                              , Value__c
                                                              , TemplateQuestion__c
                                                              , TemplateQuestion__r.Indented__c
                                                              , TemplateQuestion__r.IsDoATrigger__c
                                                              , TemplateQuestion__r.Question_1__c
                                                              , TemplateQuestion__r.FrQuestion_1__c
                                                              , TemplateQuestion__r.QuestionSet__c
                                                              , TemplateQuestion__r.SectionPrefix__c
                                                              , TemplateQuestion__r.SortOrder__c
                                                              , TemplateQuestion__r.Region__c
                                                              , TemplateQuestion__r.HelpText__c
                                                              , TemplateQuestion__r.Help_Icon_Text__c
                                                              , TemplateQuestion__r.RiskTitle__c
                                                              , TemplateQuestion__r.FrRiskTitle__c
                                                              , TemplateQuestion__r.DCSSubDOA__c
                                                              , TemplateQuestion__r.EnterpriseDOA__c
                                                              , TemplateQuestion__r.isDOAmaster__c
                                                              , Questionnaire__r.QuestionnaireTemplate__r.SortOrder__c
                                                        FROM Answer__c
                                                        WHERE Questionnaire__c = :sQuestionnaireId
                                                        ORDER BY TemplateQuestion__r.SortOrder__c]);
        return lAnswers;
    }

    public static list<Answer__c> GetAnswersRiskAssessment(Id sQuestionnaireId){
        list<Answer__c> lAnswers = new list<Answer__c>([SELECT  Id
                                                              , Value__c
                                                              , TemplateQuestion__c
                                                              , TemplateQuestion__r.Indented__c
                                                              , TemplateQuestion__r.IsDoATrigger__c
                                                              , TemplateQuestion__r.Question_1__c
                                                              , TemplateQuestion__r.FrQuestion_1__c
                                                              , TemplateQuestion__r.QuestionSet__c
                                                              , TemplateQuestion__r.SectionPrefix__c
                                                              , TemplateQuestion__r.SortOrder__c
                                                              , TemplateQuestion__r.Region__c
                                                              , TemplateQuestion__r.HelpText__c
                                                              , TemplateQuestion__r.Help_Icon_Text__c
                                                              , TemplateQuestion__r.RiskTitle__c
                                                              , TemplateQuestion__r.FrRiskTitle__c
                                                              , TemplateQuestion__r.DCSSubDOA__c
                                                              , TemplateQuestion__r.EnterpriseDOA__c
                                                              , TemplateQuestion__r.isDOAmaster__c
                                                              , Questionnaire__r.QuestionnaireTemplate__r.SortOrder__c
                                                        FROM Answer__c
                                                        WHERE Questionnaire__c = :sQuestionnaireId
                                                        AND TemplateQuestion__r.IsDoATrigger__c = false
                                                        AND TemplateQuestion__r.QuestionnaireTemplate__r.Name = 'Risk Assessment'                                                        
                                                        ORDER BY TemplateQuestion__r.SortOrder__c]);
                                                        
        list<Answer__c> lAnswersDoa = new list<Answer__c>([SELECT  Id
                                                              , Value__c
                                                              , TemplateQuestion__c
                                                              , TemplateQuestion__r.Indented__c
                                                              , TemplateQuestion__r.IsDoATrigger__c
                                                              , TemplateQuestion__r.Question_1__c
                                                              , TemplateQuestion__r.FrQuestion_1__c
                                                              , TemplateQuestion__r.QuestionSet__c
                                                              , TemplateQuestion__r.SectionPrefix__c
                                                              , TemplateQuestion__r.SortOrder__c
                                                              , TemplateQuestion__r.Region__c
                                                              , TemplateQuestion__r.HelpText__c
                                                              , TemplateQuestion__r.Help_Icon_Text__c
                                                              , TemplateQuestion__r.RiskTitle__c
                                                              , TemplateQuestion__r.FrRiskTitle__c
                                                              , TemplateQuestion__r.DCSSubDOA__c
                                                              , TemplateQuestion__r.EnterpriseDOA__c
                                                              , TemplateQuestion__r.isDOAmaster__c
                                                              , Questionnaire__r.QuestionnaireTemplate__r.SortOrder__c
                                                        FROM Answer__c
                                                        WHERE Questionnaire__c = :sQuestionnaireId
                                                        AND TemplateQuestion__r.IsDoATrigger__c = true
                                                        AND TemplateQuestion__r.QuestionnaireTemplate__r.Name = 'Risk Assessment'                                                        
                                                        ORDER BY TemplateQuestion__r.DOATriggerSortOrder__c]); 
        lAnswers.addAll(lAnswersDoa);                                                                                                               
        return lAnswers;
    }

    public static list<Answer__c> GetAnswersMarketAssessment(Id sQuestionnaireId){
        list<Answer__c> lAnswers = new list<Answer__c>([SELECT  Id
                                                              //, Score__c
                                                              , ScorePicklist__c
                                                              , IsFreeForm__c
                                                              , FreeForm__c
                                                              , TemplateQuestion__c
                                                              , TemplateQuestion__r.SortOrder__c
                                                              , TemplateQuestion__r.Factor__c
                                                              , TemplateQuestion__r.FrFactor__c
                                                              , TemplateQuestion__r.Rating5__c
                                                              , TemplateQuestion__r.Rating4__c
                                                              , TemplateQuestion__r.Rating3__c
                                                              , TemplateQuestion__r.Rating2__c
                                                              , TemplateQuestion__r.Rating1__c
                                                              , TemplateQuestion__r.FrRating1__c
                                                              , TemplateQuestion__r.FrRating2__c
                                                              , TemplateQuestion__r.FrRating3__c
                                                              , TemplateQuestion__r.FrRating4__c
                                                              , TemplateQuestion__r.FrRating5__c
                                                              , TemplateQuestion__r.HelpText__c
                                                              , TemplateQuestion__r.Question_1__c
                                                              , TemplateQuestion__r.FrQuestion_1__c
                                                        FROM Answer__c
                                                        WHERE Questionnaire__c = :sQuestionnaireId
                                                        AND TemplateQuestion__r.QuestionnaireTemplate__r.Name = 'Market Assessment'                                                        
                                                        AND TemplateQuestion__r.IsActive__c = true
                                                        ORDER BY TemplateQuestion__r.SortOrder__c]);
                                                        
                                                                                                              
        return lAnswers;
    }


    public static Boolean ExportControlExists(Id sQuestionnaireSetId) 
    {
        list<ExportControl__c> lExportControls = new list<ExportControl__c>([Select Id
                                                            , Name
                                                            , Status__c 
                                                    From ExportControl__c 
                                                    WHERE QuestionnaireSet__c = :sQuestionnaireSetId]);
        if(!lExportControls.isEmpty())
        {
            return true;
        }
        return false;
    }
}