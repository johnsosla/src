@isTest
public class ECO_SafetyHealthEnvironmentContrTest {

    @isTest
    static void testSafetyHealthEnvironmentController()
 	{	

 		ECO_Utils_Testing.createProjectRoles();

		Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		//create create source project 
		pse__Proj__c testProject = new pse__Proj__c();
		testProject.Name = 'test project 1';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;
		insert testProject;
		
		QuestionnaireSet__c	questionnaireSet = new QuestionnaireSet__c(Project__c = testProject.Id);
		insert questionnaireSet;

		Questionnaire__c questionnaire = new Questionnaire__c(Name = 'SH&E and Resilience', QuestionnaireSet__c = questionnaireSet.Id);
		insert questionnaire;
		
		QuestionnaireTemplate__c questionnaireTemplate = new QuestionnaireTemplate__c();
		insert questionnaireTemplate;
		
		TemplateQuestion__c templateQuestion = new TemplateQuestion__c(RiskTitle__c = 'Work Outside Office', QuestionnaireTemplate__c = questionnaireTemplate.Id);
		insert templateQuestion;
			
		templateQuestion = new TemplateQuestion__c(RiskTitle__c = 'Project Travel', QuestionnaireTemplate__c = questionnaireTemplate.Id);
		insert templateQuestion;
		
		templateQuestion = new TemplateQuestion__c(RiskTitle__c = 'Environmental Impacts', QuestionnaireTemplate__c = questionnaireTemplate.Id);
		insert templateQuestion;
		
		list<ProjectActivities__c> lstPA = new list<ProjectActivities__c>();
		lstPA.add(new ProjectActivities__c(Project__c = testProject.id));
		lstPA.add(new ProjectActivities__c(Project__c = testProject.id));
		lstPA.add(new ProjectActivities__c(Project__c = testProject.id));
		insert lstPA;

		list<Induction__c> lstInduction = new list<Induction__c>();
		lstInduction.add(new Induction__c(Project__c = testProject.Id, Name='New Induction', CurrencyIsoCode = testProject.CurrencyIsoCode));
		insert lstInduction;
		

		ApexPages.StandardController sc = new ApexPages.StandardController(testProject);      
        ECO_SafetyHealthEnvironmentController controller = new ECO_SafetyHealthEnvironmentController(sc);
        controller.init();
        controller.getYesNoOptions();
        //controller.createInductionAttachment();
        controller.newInduction();
        controller.getSafetyHealthTravelFiles();
        controller.getSafetyHealthPlanFiles();
        controller.getSafetyHealthInspectionFiles();
        Attachment attachment1 = controller.NewSafetyHealthInspectionAttachment;
        Attachment attachment2 = controller.NewSafetyHealthTravelAttachment;
        Attachment attachment3 = controller.NewSafetyHealthPlanAttachment;
        
        String myString = 'StringToBlob';
		Blob myBlob = Blob.valueof(myString);
		
		controller.NewSafetyHealthInspectionAttachment.Name = 'test1';
        controller.NewSafetyHealthInspectionAttachment.Body = myBlob;
        controller.NewSafetyHealthInspectionAttachment.ContentType = 'test1';
        controller.saveSafetyHealthInspectionAttachmentAndProject();
        System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test1'].size());
        controller.getSafetyHealthInspectionFiles();
		
		controller.NewSafetyHealthTravelAttachment.Name = 'test2';
        controller.NewSafetyHealthTravelAttachment.Body = myBlob;
        controller.NewSafetyHealthTravelAttachment.ContentType = 'test2';
        controller.saveSafetyHealthTravelAttachmentAndProject();
        System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test2'].size());
        controller.getSafetyHealthTravelFiles();
        
		controller.NewSafetyHealthPlanAttachment.Name = 'test3';
        controller.NewSafetyHealthPlanAttachment.Body = myBlob;
        controller.NewSafetyHealthPlanAttachment.ContentType = 'test3';
        controller.saveSafetyHealthPlanAttachmentAndProject();
        System.AssertEquals(1, [select Id, Name from Attachment where Name = 'test3'].size());
        controller.getSafetyHealthPlanFiles();      
        Id idTest = controller.inductionId2;
        String name = controller.inductionName2;
        
		controller.rowNumber = 1;
		controller.rowNumberInduction = 1;
		controller.RemoveProjectActivities();
		controller.RemoveInduciton();
		controller.getImpactStatusOptions();
		//controller.removeattachment();
		//controller.removeattachmentplan();
		controller.save();

		controller.newSafetyHealthInspectionAtt.name = 'test';
		controller.newSafetyHealthInspectionAtt.body = myBlob;

		controller.saveSafetyHealthInspectionAttProj();
		
		//controller.newInductionTeamMember();
		controller.gotoLocationsAndResilience();
		//controller.createInductionAttachment();



 	}
}