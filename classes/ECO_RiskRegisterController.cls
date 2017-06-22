public with sharing class ECO_RiskRegisterController {
        private class RiskRegisterException extends Exception {}
        
        private System.LoggingLevel debugLevel = LoggingLevel.INFO;
        
        public pse__Proj__c theProject                  { get; set; }
        public Map<Integer, Risk__c> risks                { get; set; }
        public Integer selectedRiskNumber               { get; set; }
        public Boolean isCopySectionShown               { get; set; }
        public Risk__c projectFieldProvider             { get; set; }
        
        private String retURL;
        private String projectId;
        private String riskId;

        
        public ECO_RiskRegisterController (ApexPages.StandardController con) {
                projectId = ApexPages.currentPage().getParameters().get('projectId');
                riskId = ApexPages.currentPage().getParameters().get('id');
                retURL = ApexPages.currentPage().getParameters().get('retURL');
                
                if (ECO_Utils_String.NullCheck(riskId) != '') {
                        projectId = [SELECT Id
                                                                , Project__c 
                                                FROM Risk__c 
                                                WHERE Id = :riskId].Project__c;
                }
                
                if (ECO_Utils_String.NullCheck(projectId) == '') {
                        ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'You have reached this page improperly, please access it from the Project screen.');
            ApexPages.addMessage(oPageMessage);
            return;
                }
                
                if (ECO_Utils_String.NullCheck(retURL) == '') {
                        retURL = '/'+projectId;
                } else {
                        retURL = EncodingUtil.urlDecode(retURL, 'UTF-8');
                }
                
                refreshProjectAndRisks();
                
                isCopySectionShown = false;
                
                projectFieldProvider = new Risk__c();
                        
        }
        
        private void refreshProjectAndRisks () {
                theProject = ECO_Service_Projects.getProjectById((Id)projectId);
                
                risks = new Map<Integer, Risk__c>();
                
                Integer i = 1;
                for (Risk__c r : ECO_Service_Risks.getRisksForProject(theProject.Id)) {
                        risks.put(i, r);
                        i++;
                }
        }

        public PageReference customSave(){
                PageReference pr = ApexPages.currentPage();
                pr.setRedirect(true);
                return pr;
        }
        
        public PageReference showCopyFromExisting () {
                system.debug(debugLevel, 'Before:  '+isCopySectionShown);
                isCopySectionShown = true;
                system.debug(debugLevel, 'After:  '+isCopySectionShown);
                return null;
        }
        
        public PageReference save () {
                try { 
                        upsert risks.values();
                } catch (Exception e) {
                        ApexPages.addMessages(e);
                }
                
                refreshProjectAndRisks();
                
                //return new PageReference(theProject.Id);
                return null;
        }
        
        public PageReference backToProject () {
                return new PageReference(retURL);
        }
        
        public PageReference searchKnowledge () {
                return null;
        }
        
        public PageReference addRisk () {
                Risk__c newRisk = new Risk__c();
                newRisk.Project__c = theProject.Id;
                risks.put(getNewRiskNumber(), newRisk);
                return null;
        }
        
        public PageReference copyFromExisting () {
                isCopySectionShown = false;
                
                ECO_ProjectCloningService cloner = new ECO_ProjectCloningService();
                cloner.newProjectId = theProject.Id;
                Integer riskNumber = getNewRiskNumber();
                for (Risk__c r : cloner.cloneProjectRisksAndReturnRisks(projectFieldProvider.Project__c)) {
                        risks.put(riskNumber, r);
                        riskNumber++;
                }
                                
                return null;
        }
        
        private Integer getNewRiskNumber () {
                Integer i = 1;
                for (Integer r : risks.keySet()) {
                        if (i <= r) {
                                i = r+1;
                        }
                }
                return i;
        }
}