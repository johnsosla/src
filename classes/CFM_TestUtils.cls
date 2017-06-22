public class CFM_TestUtils {
	public static void createTestSurveyBatch() {
		createTestSurveyBatch(1, true);
	}

	public static void createAecomTestAccount() {
		Account a = new Account();
		a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('AECOM Internal Account').getRecordTypeId();
		a.Name = 'AECOM';


		insert a;
	}

	public static void createTestSurveyBatch(Integer numberOfProjects, Boolean createBatchProjects) {
		createTestSurveyBatch(numberOfProjects, createBatchProjects, false);
	}

	public static void createTestSurveyBatch(Integer numberOfProjects, Boolean createBatchProjects, Boolean assignAllToSamePm) {
		CFM_Survey_Batch__c surveyBatch = new CFM_Survey_Batch__c();
		surveyBatch.Survey_Name__c = 'Test Survey Name';
		surveyBatch.Survey_Close_Date__c = Date.today();
		surveyBatch.Target_Survey_Date__c = Date.today();
		surveyBatch.Status__c = CFM_SurveyBatch.STATUS_NEW;

		insert surveyBatch;

		List<Project__c> projects = createTestProjects(numberOfProjects, assignAllToSamePm);


		if (createBatchProjects) {
			List<CFM_Survey_Batch_Project__c> batchProjects = new List<CFM_Survey_Batch_Project__c>();

			for (Project__c project : projects) {
				CFM_Survey_Batch_Project__c batchProject = new CFM_Survey_Batch_Project__c();
				batchProject.Survey_Batch__c = surveyBatch.Id;
				batchProject.Project__c = project.Id;
				batchProject.Status__c = CFM_SurveyBatchProject.STATUS_NEW;
				batchProject.Add_Method__c = 'Manual Selection';
				batchProjects.add(batchProject);
			}
			
			insert batchProjects;
		}
		
	}

	public static void createTestBatchForReassignment() {
		CFM_Survey_Batch__c surveyBatch = new CFM_Survey_Batch__c();
		surveyBatch.Survey_Name__c = 'Test Survey Name';
		surveyBatch.Survey_Close_Date__c = Date.today();
		surveyBatch.Target_Survey_Date__c = Date.today();
		surveyBatch.Status__c = CFM_SurveyBatch.STATUS_NEW;

		insert surveyBatch;
	}


	public static User createTestUser(String email, String alias) {
		return createTestUser(email, alias, true);
	}

	private static Profile standardProfile;

	public static User createTestUser(String email, String alias, Boolean shouldInsert) {
		if (standardProfile == null) standardProfile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = alias, CommunityNickname=alias, Email=email, 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=email,
            Geography_Allocation__c='Corporate');

        if (shouldInsert) insert u;

        return u;
	}


	public static Contact createTestContact(String firstName, String lastName, String email) {
		return createTestContact(firstName, lastName, email, true);
	}

	public static Contact createTestContact(String firstName, String lastName, String email, Boolean shouldInsert) {
		Contact c = new Contact(FirstName=firstName, LastName=lastName, Email=email);
		if (shouldInsert) insert c;
		return c;
	}

	public static void createTestTaskSubAndDescSettings() {
		List<CFM_Task_Subject_and_Description__c> newTranslations = new List<CFM_Task_Subject_and_Description__c>();

		newTranslations.add(new CFM_Task_Subject_and_Description__c(Name = '1', Subject__c = 'Please Review your Projects and Confirm or Reject.', Language__c = 'en_US', Description__c = 'PM Survey Project Verification Needed' ));
		newTranslations.add(new CFM_Task_Subject_and_Description__c(Name = '2', Subject__c = '請檢查您的項目，並確認或拒絕.', Language__c = 'zh_CN', Description__c = 'PM調查項目需要驗證' ));
		newTranslations.add(new CFM_Task_Subject_and_Description__c(Name = '3', Subject__c = '请检查您的项目，并确认或拒绝.', Language__c = 'zh_TW', Description__c = 'PM调查项目需要验证' ));

		insert newTranslations;
	}


	public static void createTestHierarchies() {
		User u1 = createTestUser('aecomhierarchy1test@aecom.com', 'aechier1');
		User u2 = createTestUser('aecomhierarchy2test@aecom.com', 'aechier2');

		CFM_Survey_Case_Hierarchy__c def = new CFM_Survey_Case_Hierarchy__c();
		def.Is_Default_Rule__c = true;
		def.Step_1_Days__c = 1;
		def.Step_2_Days__c = 1;
		def.Step_1_Email__c = 'Level_1_4_Initial_Alert_E_mail_to_FUO';
		def.Step_2_Email__c = 'Escalation_1_E_mail_to_EO';
		def.Step_3_Email__c = 'Escalation_2_E_mail_to_Client_Care';
		def.Step_1_Assign_To__c = u1.Id;
		def.Step_2_Assign_To__c = u1.Id;
		def.Step_3_Assign_To__c = u1.Id;
		def.Area_Manager__c = u1.Id;
		def.Business_Line_Leader__c = u1.Id;
		def.Regional_Quality_Manager__c = u1.Id;
		def.Risk_Manager__c = u1.Id;
		insert def;

		CFM_Survey_Case_Hierarchy__c h = new CFM_Survey_Case_Hierarchy__c();
		h.Is_Default_Rule__c = false;
		h.Step_1_Days__c = 1;
		h.Step_2_Days__c = 1;
		h.Step_1_Email__c = 'Level_1_4_Initial_Alert_E_mail_to_FUO';
		h.Step_2_Email__c = 'Escalation_1_E_mail_to_EO';
		h.Step_3_Email__c = 'Escalation_2_E_mail_to_Client_Care';
		h.Operating_Group__c = 'DCS AME';
		h.Lead_District__c = 'Midwest';
		h.Step_1_Assign_To__c = u2.Id;
		h.Step_2_Assign_To__c = u2.Id;
		h.Step_3_Assign_To__c = u2.Id;
		def.Area_Manager__c = u2.Id;
		def.Business_Line_Leader__c = u2.Id;
		def.Regional_Quality_Manager__c = u2.Id;
		def.Risk_Manager__c = u2.Id;
		insert h;

	}

    public static List<Project__c> createTestProjects(Integer numberOfProjects) {
        return createTestProjects(numberOfProjects, false);
    }

	public static List<Project__c> createTestProjects(Integer numberOfProjects, Boolean assignAllToSamePm) {
		Country__c c = new Country__c();
		c.Name = 'America';
		c.Country_Code__c = 'US';
		c.Region__c = 'Test Region';
		insert c;

		Account a = new Account();
		a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account Record Type - Global').getRecordTypeId();
		a.Name = 'Test Account';
		a.Client_Group__c = 'Test';
		a.Client_Subgroup__c = 'Test 2';
		a.Type__c = 'Client/Prospect';
		a.City__c = 'Test City';
		a.CountryLookup__c = c.Id;
		insert a;

		AECOM_Primary_Department__c department = new AECOM_Primary_Department__c();
		department.Name = 'Test Department';
		department.Group_Division__c = 'Construction Services';
		department.Operating_Group__c = 'DCS AME';
		department.Lead_District__c = 'Midwest';
        department.Lead_Region__c = 'Test';
		insert department;

		List<User> userList = new List<User>();
		for (Integer i = 0; i < numberOfProjects; i++) {
			userList.add(createTestUser('projectmanagertest' + i + '@aecom.com', 'pmtest' + i, false));
		}

		insert userList;

		List<Contact> contactList = new List<Contact>();
		for (Integer i = 0; i < numberOfProjects; i++) {
			contactList.add(createTestContact('Test' + i, 'SurveyContact' + i, 'test@test.com' + i, false));
		}

		insert contactList;

		List<Project__c> newProjects = new List<Project__c>();

		for (Integer i = 0; i < numberOfProjects; i++) {
			Project__c newProject = new Project__c();
			newProject.RecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
			newProject.Name = 'Test Project ' + i;
			// Not using lookup field for now newProject.CFM_Department__c = department.Id;
			newProject.OracleDepartment__c = department.Name;
			newProject.CFM_Survey_Contact__c = contactList[i].Id;
			newProject.Project_Description__c = 'Test ' + i;
			newProject.Owner__c = a.Id;
			if (assignAllToSamePm) {
				newProject.Oracle_Project_Manager_lookup__c = userList[0].Id;
			}
			else {
				newProject.Oracle_Project_Manager_lookup__c = userList[i].Id;	
			}
			newProject.OraclePercentComplete__c = 80;
			newProject.Oracle_Client__c = a.Id;
			newProjects.add(newProject);
		}

		insert newProjects;
		

		return newProjects;
	}

	private static AECOM_Primary_Department__c department;

	public static Opportunity createTestOpportunity(Date closeDate, Account acct) {
		if (department == null) {
			department = new AECOM_Primary_Department__c(
				Name = 'Test Department',
				Group_Division__c = 'DCS',
				Operating_Group__c = 'Americas'
			);

			insert department;
		}

		Opportunity opp = new Opportunity(
			Name = 'TestOpp',
			StageName = '1 Lead',
			AccountId = acct.Id,
			TO_Procurement_Method__c = 'Test Method',
			Enterprise_Service__c = 'Asset Management',
			CloseDate = closeDate,
			Estimated_work_start_date__c = closeDate.addDays(90),
			AECOM_Primary_Dept_Lookup__c = department.Id
		);
		insert opp;
		return opp;
	}

	public static List<pse__Proj__c> createTestEPMProjects(Integer numberOfProjects, Boolean shouldInsert) {
		Country__c c = new Country__c();
		c.Name = 'America';
		c.Country_Code__c = 'US';
		c.Region__c = 'Test Region';
		insert c;

		Account a = new Account();
		a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account Record Type - Global').getRecordTypeId();
		a.Name = 'Test Account';
		a.Client_Group__c = 'Test';
		a.Client_Subgroup__c = 'Test 2';
		a.Type__c = 'Client/Prospect';
		a.City__c = 'Test City';
		a.CountryLookup__c = c.Id;
		insert a;

		List<User> userList = new List<User>();
		for (Integer i = 0; i < numberOfProjects; i++) {
			userList.add(createTestUser('PMtest' + i + '@aecom.com', 'PMtest1' + i, false));
		}

		insert userList;

		List<Contact> contactList = new List<Contact>();
		for (Integer i = 0; i < numberOfProjects; i++) {
			contactList.add(createTestContact('Test' + i, 'SurveyContact' + i, 'test@test.com' + i, false));
		}

		insert contactList;

		List<Opportunity> oppList = new List<Opportunity>();
		for (Integer i = 0; i < numberOfProjects; i++) {
			oppList.add(createTestOpportunity(Date.today(), a));
		}

		List<pse__Proj__c> newProjects = new List<pse__Proj__c>();

		for (Integer i = 0; i < numberOfProjects; i++) {
			pse__Proj__c newProject = new ECO_Utils_Testing.ProjectBuilder().build(false);
			newProject.Name = 'Test Project ' + i;
			newProject.pse__Opportunity__c = oppList.get(i).Id;
			newProject.pse__Account__c = a.Id;
			newProject.pse__Project_Type__c = 'Customer Project';
			newProject.pse__Billing_Type__c = 'Fixed Price';
			newProject.CurrencyIsoCode = 'USD';
			newProject.CaptureManager__c = contactList[i].Id;
			newProject.pse__Is_Active__c = true;
			newProject.EnableTopTaskCustomerFlag__c = false;
			newProject.EstimatedEndDate__c = Date.today().addDays(180);
			newProjects.add(newProject);
		}

		if (shouldInsert) {
			insert newProjects;
		}
		
		return newProjects;
	}

	public static List<CFM_Survey_Response__c> createTestSurveyResponses(Integer numberOfResponsesPerProject, List<CFM_Survey_Batch_Project__c> surveyBatchProjects, Boolean shouldInsert) {
		
		List<CFM_Survey_Response__c> newSurveyResponses = new List<CFM_Survey_Response__c>();

		for (CFM_Survey_Batch_Project__c surveyBatchProject : surveyBatchProjects) {
			for (Integer i = 0; i < numberOfResponsesPerProject; i++) {
				CFM_Survey_Response__c newSurveyResponse = new CFM_Survey_Response__c(
					Account__c = surveyBatchProject.Account_ID__c,
					Project__c = surveyBatchProject.Project__c,
					Survey_Batch_Project__c = surveyBatchProject.Id
				);
				newSurveyResponses.add(newSurveyResponse);
			}
		}

		if (shouldInsert) {
			insert newSurveyResponses;
		}

		return newSurveyResponses;
	}
}