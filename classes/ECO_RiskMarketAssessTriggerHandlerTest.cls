@isTest
private class ECO_RiskMarketAssessTriggerHandlerTest {

    // testMethod
    static  void handleRiskMarketAssessmentStatusUpdate() {
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
		testProject.pse__Stage__c = 'Pending Go/No Go';
		insert testProject;
		
		QuestionnaireSet__c newQuestionnaireSet = new QuestionnaireSet__c();
		newQuestionnaireSet.Project__c = testProject.Id;
		newQuestionnaireSet.ApprovalStatus__c = 'Pending Approval';
		insert newQuestionnaireSet;
		
		newQuestionnaireSet.ApprovalStatus__c = 'Approved';
		newQuestionnaireSet.GoNoGoRecommendation__c = 'Go';
		update newQuestionnaireSet;
		
		pse__Proj__c project = [select Id, pse__Stage__c, RecordType.Name from pse__Proj__c where Id = :testProject.Id];
		System.AssertEquals('Customer Project (Planning)', project.RecordType.Name);
		System.AssertEquals('Planning', project.pse__Stage__c);
    }

    // testMethod
    static  void handleRiskMarketAssessmentStatusUpdate2() {
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
		testProject.pse__Stage__c = 'Pending Go/No Go';
		insert testProject;
		
		QuestionnaireSet__c newQuestionnaireSet = new QuestionnaireSet__c();
		newQuestionnaireSet.Project__c = testProject.Id;
		newQuestionnaireSet.ApprovalStatus__c = 'Pending Approval';
		insert newQuestionnaireSet;
		
		newQuestionnaireSet.ApprovalStatus__c = 'Approved';
		newQuestionnaireSet.GoNoGoRecommendation__c = 'No Go';
		update newQuestionnaireSet;
		
		pse__Proj__c project = [select Id, pse__Stage__c, RecordType.Name from pse__Proj__c where Id = :testProject.Id];
		System.AssertEquals('Customer Project (Unapproved)', project.RecordType.Name);
		System.AssertEquals('Pending Go/No Go', project.pse__Stage__c);
    }    
    
}