@isTest
private class ECO_BudgetQuestionnaireControllerTest {
    private static final Integer numTestProjectTasks = 10;	
	private static final Integer numTeamMembers = 1;
    
    static testMethod void testBudgetQuestionaire() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        
        //create account and project
		ECO_Utils_Testing.createTestDataForProjectSync(numTestProjectTasks, numTeamMembers);
		pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];
        
        PageReference pageRef = Page.ECO_BudgetQuestionnaire;
        Test.setCurrentPageReference(pageRef);
        
        ECO_BudgetQuestionnaireController con = new ECO_BudgetQuestionnaireController(new ApexPages.StandardController(testProject));
        
        con.theProject.BudgetStrategy__c = 'Top Task';
        con.theProject.BudgetStrategyRevenue__c = 'Top Task';
        con.theProject.BudgetOffline__c = false;
        con.theProject.DefaultMarginType__c = 'Lump Sum';
        con.theProject.EscalationApplies__c = true;
        con.theProject.PaymentTerms__c = '38 DAYS';
        con.theProject.BillingStructure__c = 'Milestone';
        
        con.saveAndReturn();
        
        con.theProject.DefaultMarginType__c = 'T&M Direct Labour Multiplier';
        con.defaulLabourMultiplier = 10;
        con.defaulSubsMultiplier = 10;
        con.defaulODCMultiplier = 10;
        con.saveAndReturn();
        
        con = new ECO_BudgetQuestionnaireController(new ApexPages.StandardController(testProject));
        
        Decimal defaultLabourMultiplier = con.defaulLabourMultiplier;
        Decimal defaulSubsMultiplier =con.defaulSubsMultiplier;
        Decimal defaulODCMultiplier = con.defaulODCMultiplier;
        Boolean IsSynced = con.getIsSynced();
        Attachment attachment = con.docBudgetQuestionnaireAttachment;
        attachment.Name = 'Test';
        Blob bodyBlob = Blob.valueOf('Test Attachment');
        attachment.Body = bodyBlob;        
        con.docBudgetQuestionnaireAttachment = attachment;
        con.saveBudgetQuestionnaireAttachmentAndProject();
        Attachment docBudgetQuestionnaireAttachment = con.docBudgetQuestionnaireAttachment;
        
        list<Attachment> attachedBudgetQuestionnaireFiles = con.getAttachedBudgetQuestionnaireFiles();
        
        con.selectedRecordNumber = 0;
        con.goToAttachmentPage();
        con.removeReloc();
        
        con.calculateMilestones();
		con.removeMilestone();
        con.addTask();
        con.selectedTaskNumber = 1;
        con.removeTask();
        
        con.theProject.pse__Start_Date__c = null;
        con.theProject.pse__End_Date__c = null;
        con.calculateMilestones();
        
        con.theProject.EscalationApplies__c = false;
        con.toggleEscalationSection();
        con.toggleMilestoneSection();
        
        con.cancelAndReturn();
        
    }
}