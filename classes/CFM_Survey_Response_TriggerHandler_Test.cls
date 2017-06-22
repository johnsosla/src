@isTest
public class CFM_Survey_Response_TriggerHandler_Test{

	@isTest
	static void SurveyResponseUpdatedWithProject(){
		//Arrange
		
        // ECO_Utils_Testing.createProjectRoles();
		Account ownerAccount = new Account(Name = 'owner');
		insert ownerAccount;
        
		String oracleProjectNumber = '123';
//		Opportunity opp = new Opportunity(Name = 'opp', StageName = 'Open', CloseDate = Date.today());
        Opportunity opp = new Opportunity(
			Name = 'opp',
			StageName = 'Open',
			AccountId = ownerAccount.Id,
			TO_Procurement_Method__c = 'Test Method',
			Enterprise_Service__c = 'Asset Management',
			CloseDate = Date.today(),
			Estimated_work_start_date__c = Date.today().addDays(90)
		);
		insert opp;

		pse__Proj__c project = new ECO_Utils_Testing.ProjectBuilder().build(false);
		project.OracleProjectnumber__c = oracleProjectNumber;

		project.pse__Opportunity__c = opp.Id;
		insert project;

		Project__c projectProfile = new Project__c(
			Oracle_Project_Number__c = oracleProjectNumber,
			Owner__c = ownerAccount.Id,
			Project_Description__c = 'descr'
			);
		insert projectProfile;

		CFM_Survey_Response__c surveyResponse = new CFM_Survey_Response__c(
			Account__c = ownerAccount.Id,
			Project__c = projectProfile.Id
			);


		//Act
		insert surveyResponse;

		//Assert
		CFM_Survey_Response__c updatedSurveyResponse = [SELECT Project_FF__c FROM CFM_Survey_Response__c WHERE Id = :surveyResponse.Id LIMIT 1];
		system.assertNotEquals(null, updatedSurveyResponse.Project_FF__c);
		system.assertEquals(project.Id, updatedSurveyResponse.Project_FF__c);

	}
}