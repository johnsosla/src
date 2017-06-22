public with sharing class ECO_RMASummaryControllerPdf extends ECO_RMASummaryController {
        
        public String pdfFileName  {get;set;}
        	
        public List<ECO_Utils_Activities.Attendee> lAttendees {get; set;}
        
        public map<string, list<Answer__c>> mDoAAnswers {get; set;}
        public map<string, list<Answer__c>> mNotDoAAnswers {get; set;}
        public Map<Id, Risk__c> questionToRiskMap { get; set; }  // Key is TemplateQuestion__c id
        public Map<Id, DOARegister__c> questionToDOAMap { get; set; }  // Key is TemplateQuestion__c id
    	public List<String> questionnaireNameToMNotDoAAnswersOrderedKeys {get;set;}
    
        public Boolean showDOASection {get; set;}
        public Answer__c DOA_SectionAnswer {get;set;}
        
        public Map<String, Map<string, list<Answer__c>>> questionnaireNameToMDoAAnswers {get; set;}
        public Map<String, Map<string, list<Answer__c>>> questionnaireNameToMNotDoAAnswers {get; set;}
        public Map<String, Map<Id, Risk__c>> questionnaireNameToQuestionToRiskMap {get; set;}
        public Map<String, Map<Id, DOARegister__c>> questionnaireNameToQuestionToDOAMap {get; set;}

        public Map<String, Boolean> questionnaireNameToShowDOASection {get; set;}
        public Map<String, Answer__c> questionnaireNameToDOA_SectionAnswer {get; set;}
        
        public ECO_RMASummaryControllerPdf(ApexPages.StandardController oStandardController) {
                super(oStandardController);
                // getAnswersForAllQuestionnaires();
                getWrappedAnswersForAllQuestionnaires();
                if (oQuestionnaireSet.GoNoGo_Review__c != null) {
                        ProjectReview__c oGoNoGo = [select EventID__c from ProjectReview__c where Id = :oQuestionnaireSet.GoNoGo_Review__c];
                        lAttendees = ECO_Utils_Activities.getAttendees(oGoNoGo.EventID__c);
                }
                System.debug('completed getWrappedAnswersForAllQuestionnaires!');
                // pdf file name format is {project-number}_{form}_{version-description}_{date}
                // TODO: find out what is {version-description}
                Datetime myDatetime = Datetime.now();
                String myDatetimeStr = myDatetime.format('yyyyMMdd');
                pdfFileName = theProject.ProjectNumber__c + '_RMASummary_' + oQuestionnaireSet.Name + '_' + myDatetimeStr + '.pdf';
                System.debug('pdfFileName: ' + pdfFileName);
                Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + pdfFileName);
        }

        public void getWrappedAnswersForAllQuestionnaires() {
                questionnaireNameToMDoAAnswers = new Map<String, Map<string, list<Answer__c>>>();
                questionnaireNameToMNotDoAAnswers = new Map<String, Map<string, list<Answer__c>>>();
                questionnaireNameToQuestionToRiskMap = new Map<String, Map<Id, Risk__c>>();
                questionnaireNameToQuestionToDOAMap = new Map<String, Map<Id, DOARegister__c>>();
                questionnaireNameToShowDOASection = new Map<String, Boolean>();
                questionnaireNameToDOA_SectionAnswer = new Map<String, Answer__c>();
            	questionnaireNameToMNotDoAAnswersOrderedKeys = new List<String>();
                            
                // for each of the lQuestionnaires, get answers by using ECO_Utils_Questionnaire.GetAnswers(oQuestionnaireId)
                for (Questionnaire__c eachQuestionnaire : lQuestionnaires){
                    System.debug('eachQuestionnaire.Name: ' + eachQuestionnaire.Name);
                    mDoAAnswers = new map<string, list<Answer__c>>();
                    mNotDoAAnswers = new map<string, list<Answer__c>>();
                    questionToRiskMap = new Map<Id, Risk__c>();
                    questionToDOAMap = new Map<Id, DOARegister__c>();
                    
                    //questionnaireNameToMDoAAnswers.put(eachQuestionnaire.Name, mDoAAnswers);
                    questionnaireNameToMNotDoAAnswers.put(eachQuestionnaire.Name, mNotDoAAnswers);
                    questionnaireNameToMNotDoAAnswersOrderedKeys.add(eachQuestionnaire.Name);
                    questionnaireNameToQuestionToRiskMap.put(eachQuestionnaire.Name, questionToRiskMap);
                    questionnaireNameToQuestionToDOAMap.put(eachQuestionnaire.Name, questionToDOAMap);
                    questionnaireNameToShowDOASection.put(eachQuestionnaire.Name, false);
                    questionnaireNameToDOA_SectionAnswer.put(eachQuestionnaire.Name, NULL);
                    
                    List<Answer__c> lAnswers = ECO_Utils_Questionnaire.GetAnswers(eachQuestionnaire.Id);
                    //for(Answer__c oAnswer : [Select Id, Questionnaire__r.QuestionnaireTemplate__r.SortOrder__c From Answer__c Where Id IN :lAnswers ORDER BY Questionnaire__r.QuestionnaireTemplate__r.SortOrder__c]){
                    for(Answer__c oAnswer : lAnswers ){    
                        if(oAnswer.TemplateQuestion__r.IsDoATrigger__c && ('Yes'.equalsIgnoreCase(oAnswer.Value__c) || 'Unknown'.equalsIgnoreCase(oAnswer.Value__c)  || 'True'.equalsIgnoreCase(oAnswer.Value__c))){
                            if(!mDoAAnswers.containsKey(oAnswer.TemplateQuestion__r.QuestionSet__c)){
                                mDoAAnswers.put(oAnswer.TemplateQuestion__r.QuestionSet__c, new list<Answer__c>());
                            }
                            
                            mDoAAnswers.get(oAnswer.TemplateQuestion__r.QuestionSet__c).add(oAnswer);
                            
                            // Show the answers section if the section header is 'yes'
                            //if(oAnswer.TemplateQuestion__r.isDOAmaster__c && 'Yes'.equalsIgnoreCase(oAnswer.Value__c)) {
                                questionnaireNameToShowDOASection.put(eachQuestionnaire.Name, true);
                                questionnaireNameToMDoAAnswers.put(eachQuestionnaire.Name, mDoAAnswers);
                            //}
                            
                            //Preload the DOA map
                            DOARegister__c newDOA = new DOARegister__c();
                            newDOA.Questionnaire__c = eachQuestionnaire.Id;
                            newDOA.DCSsubDOA__c = oAnswer.TemplateQuestion__r.DCSSubDOA__c;
                            newDOA.EnterpriseDOA__c = oAnswer.TemplateQuestion__r.EnterpriseDOA__c;
                            newDOA.DOATrigger__c = oAnswer.TemplateQuestion__r.Question_1__c;
                            newDOA.RiskTitle__c = oAnswer.TemplateQuestion__r.RiskTitle__c;
                            newDOA.TemplateQuestion__c = oAnswer.TemplateQuestion__c;
                            
                            questionToDOAMap.put(oAnswer.TemplateQuestion__c, newDOA);
                        }
                        else
                        {
                            if(!oAnswer.TemplateQuestion__r.isDOAmaster__c){
                                if(!mNotDoAAnswers.containsKey(oAnswer.TemplateQuestion__r.QuestionSet__c))
                                {
                                    system.debug('putting: ' + oAnswer.TemplateQuestion__r.QuestionSet__c);
                                    mNotDoAAnswers.put(oAnswer.TemplateQuestion__r.QuestionSet__c, new list<Answer__c>());
                                }
            
                                mNotDoAAnswers.get(oAnswer.TemplateQuestion__r.QuestionSet__c).add(oAnswer);
                            } 
                            else {
                                questionnaireNameToDOA_SectionAnswer.put(eachQuestionnaire.Name, oAnswer);
                                // DOA_SectionAnswer = oAnswer;
                                if(oAnswer.Value__c == 'True' || oAnswer.Value__c == 'Unknown' || oAnswer.Value__c == 'Yes'){
                                    questionnaireNameToShowDOASection.put(eachQuestionnaire.Name, true);
                                }
                            }
                        }
                        // Preload the risk map
                        questionToRiskMap.put(oAnswer.TemplateQuestion__c, new Risk__c());
                    }
                
                    for (Risk__c r : ECO_Service_Risks.getRisksForAnswers(lAnswers)) {
                            questionToRiskMap.put(r.Answer__r.TemplateQuestion__c, r);
                    }
            
                    for (DOARegister__c d : ECO_Service_Risks.getDOAForAnswers(lAnswers)) {
                        questionToDOAMap.put(d.TemplateQuestion__c, d);
                    }
                }
        }
        
        public PageReference doShowDOASection () {
        showDOASection = true;
        return null;
    }
    
    public PageReference doHideDOASection () {
        showDOASection = false;
        return null;
    }
    
/*            
	public void getAnswersForAllQuestionnaires() {
            mDoAAnswers = new map<string, list<Answer__c>>();
            mNotDoAAnswers = new map<string, list<Answer__c>>();
            questionToRiskMap = new Map<Id, Risk__c>();
            questionToDOAMap = new Map<Id, DOARegister__c>();
                
                // for each of the lQuestionnaires, get answers by using ECO_Utils_Questionnaire.GetAnswers(oQuestionnaireId)
                //for (Questionnaire__c eachQuestionnaire : lQuestionnaires){
                for (Questionnaire__c eachQuestionnaire : [Select Id , Name
															, ProjectRisk__c
															, DoATriggers__c
															, PercentComplete__c 
                                                      		, QuestionnaireTemplate__r.SortOrder__c
													FROM Questionnaire__c 
													Where Id IN :lQuestionnaires
                                                           ORDER BY QuestionnaireTemplate__r.SortOrder__c  ]){
                        
                        List<Answer__c> lAnswers = ECO_Utils_Questionnaire.GetAnswers(eachQuestionnaire.Id);
                for(Answer__c oAnswer : lAnswers)
                {
                        if(oAnswer.TemplateQuestion__r.IsDoATrigger__c)
                    {
                                if(!mDoAAnswers.containsKey(oAnswer.TemplateQuestion__r.QuestionSet__c))
                        {
                            mDoAAnswers.put(oAnswer.TemplateQuestion__r.QuestionSet__c, new list<Answer__c>());
                        }
        
                        mDoAAnswers.get(oAnswer.TemplateQuestion__r.QuestionSet__c).add(oAnswer);
                        
                        // Show the answers section if the section header is 'yes'
                        if(oAnswer.TemplateQuestion__r.isDOAmaster__c && 'Yes'.equalsIgnoreCase(oAnswer.Value__c)) 
                        {
                                doShowDOASection();
                        }
        
                        //Preload the DOA map
                        DOARegister__c newDOA = new DOARegister__c();
                        newDOA.Questionnaire__c = eachQuestionnaire.Id;
                        newDOA.DCSsubDOA__c = oAnswer.TemplateQuestion__r.DCSSubDOA__c;
                        newDOA.EnterpriseDOA__c = oAnswer.TemplateQuestion__r.EnterpriseDOA__c;
                        newDOA.DOATrigger__c = oAnswer.TemplateQuestion__r.Question_1__c;
                        newDOA.RiskTitle__c = oAnswer.TemplateQuestion__r.RiskTitle__c;
                        newDOA.TemplateQuestion__c = oAnswer.TemplateQuestion__c;
                        
                        questionToDOAMap.put(oAnswer.TemplateQuestion__c, newDOA);
                        }
                    else
                    {
                        if(!oAnswer.TemplateQuestion__r.isDOAmaster__c){
                            if(!mNotDoAAnswers.containsKey(oAnswer.TemplateQuestion__r.QuestionSet__c))
                            {
                                system.debug('putting: ' + oAnswer.TemplateQuestion__r.QuestionSet__c);
                                mNotDoAAnswers.put(oAnswer.TemplateQuestion__r.QuestionSet__c, new list<Answer__c>());
                            }
        
                            mNotDoAAnswers.get(oAnswer.TemplateQuestion__r.QuestionSet__c).add(oAnswer);
                        } else {
                            DOA_SectionAnswer = oAnswer;
                            if(DOA_SectionAnswer.Value__c == 'True' || DOA_SectionAnswer.Value__c == 'Unknown' || DOA_SectionAnswer.Value__c == 'Yes'){
                                showDOASection = true;
                            }
                        }
                        }
                    // Preload the risk map
                    questionToRiskMap.put(oAnswer.TemplateQuestion__c, new Risk__c());
                }
                
                for (Risk__c r : ECO_Service_Risks.getRisksForAnswers(lAnswers)) {
                        questionToRiskMap.put(r.Answer__r.TemplateQuestion__c, r);
                }
        
                for (DOARegister__c d : ECO_Service_Risks.getDOAForAnswers(lAnswers)) {
                    questionToDOAMap.put(d.TemplateQuestion__c, d);
                }
                }
        }
        
*/
}