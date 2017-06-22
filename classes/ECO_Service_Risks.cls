public without sharing class ECO_Service_Risks {
    public static List<Risk__c> getRisksForAnswers (List<Answer__c> answers) {
        List<Risk__c> returnList =  [SELECT Id 
                                            , Name
                                            , Answer__c
                                            , Project__c
                                            , PlanElement__c
                                            , PotentialCosts__c
                                            , Questionnaire__c
                                            , RiskConsequence__c
                                            , RiskMitigation__c
                                            , RiskOwner__c
                                            , RiskProbability__c
                                            , Answer__r.TemplateQuestion__c
                                            , RiskDescription__c
                                            , RiskNumber__c
                                            , DoATrigger__c
                                        FROM Risk__c
                                        WHERE Answer__c IN :answers
                                            AND (Answer__r.Value__c = 'Yes'
                                                OR Answer__r.Value__c = 'True'
                                                OR Answer__r.Value__c = 'Unknown')];
        return returnList;
    }

    public static List<DOARegister__c> getDOAForAnswers (List<Answer__c> answers) {
        List<DOARegister__c> returnList =  [SELECT Id 
                                            , Name
                                            , Answer__c
                                            , Project__c
                                            , RiskTitle__c
                                            , DCSsubDOA__c
                                            , Questionnaire__c
                                            , DOATrigger__c
                                            , EnterpriseDOA__c
                                            , TemplateQuestion__c
                                            , MitigationStrategy__c
                                        FROM DOARegister__c
                                        WHERE Answer__c IN :answers
                                            AND (Answer__r.Value__c = 'Yes'
                                                OR Answer__r.Value__c = 'True'
                                                OR Answer__r.Value__c = 'Unknown')];
        return returnList;
    }
    
    public static List<Risk__c> getRisksForProject (Id projectId) {
        List<Risk__c> returnList =  [SELECT Id 
                                            , Name
                                            , Answer__c
                                            , Project__c
                                            , PlanElement__c
                                            , PotentialCosts__c
                                            , Questionnaire__c
                                            , RiskConsequence__c
                                            , RiskMitigation__c
                                            , RiskOwner__c
                                            , RiskProbability__c
                                            , CurrentStatus__c
                                            , Source__c 
                                            , EventPhase__c 
                                            , LikelihoodofOccurrence__c 
                                            , MitigationEffectiveness__c
                                            , Assignedto__c
                                            , LaborCost__c 
                                            , ODCCost__c
                                            , ContingencyPercent__c
                                            , ContingencyDollars__c
                                            , OpportunityFromRisk__c
                                            , AddRiskToKBLib__c 
                                          //  , RiskStatus__c 
                                            , Answer__r.TemplateQuestion__c
                                            , Answer__r.DoATrigger__c
                                            , Answer__r.IsRisk__c
                                            , RiskDescription__c
                                            , RiskNumber__c
                                        FROM Risk__c
                                        WHERE Project__c = :projectId];
        
        return returnList;
    }
}