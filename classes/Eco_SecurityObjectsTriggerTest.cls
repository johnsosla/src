@isTest
public class Eco_SecurityObjectsTriggerTest {
 
    static testMethod void RunTestsForTriggers () {
        
		/*final Integer numTestProjectTasks = 20;
		final Integer numTestSubTasksPerTask = 0;
		final Integer numTestProjectMilestones = 30;
		final Integer numTestSubProjects = 50;
		final Integer numTeamMembers = 1;    
        
       	final Integer numTestRisks = 10;*/
        
        		//create project team members
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		List<User> testUsers = new List<User>();
        
        String userName = UserInfo.getUserName();
		User activeUser = [Select Email From User where Username = : userName limit 1];
		String userEmail = activeUser.Email;

        
		/*User testManager = new User();
		testManager.Alias = 'manager';
		testManager.Email ='testmanager_consultant@example.com';
		testManager.EmailEncodingKey ='UTF-8';
		testManager.FirstName = 'test';
		testManager.LastName ='manager';
		testManager.LanguageLocaleKey ='en_US';
		testManager.LocaleSidKey ='en_US';
		testManager.ProfileId = p.Id;
        testManager.TimeZoneSidKey ='America/Los_Angeles';
        testManager.UserName ='testmanager@example.com';
        insert testManager;*/	        
        
		Account testAccount = new Account();
		testAccount.Name = 'test Account';
		insert testAccount;

		/*Contact testContact = new Contact();
		testContact.AccountId = testAccount.Id;
		testContact.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType, ECO_Constants.Contact_PSAResourceRecordTypeName);
		testContact.LastName = 'Test Last Name';
		testContact.FirstName = 'Test First Name';
		testContact.pse__Salesforce_User__c = testManager.Id;
		testContact.pse__Is_Resource_Active__c = true;
		testContact.pse__Is_Resource__c = true;
		insert testContact;*/
        
		//create create source project 
		/*pse__Proj__c testProject = new pse__Proj__c();
		testProject.Name = 'test project 1';
		testProject.pse__Account__c = testAccount.Id;
		testProject.pse__Project_Type__c = 'Customer Project';
		testProject.pse__Billing_Type__c = 'Fixed Price';
		testProject.CurrencyIsoCode = 'USD';
		testProject.pse__Is_Active__c = true;
		insert testProject;*/

		ECO_Service_Delegation.run = false;
		ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 5);
        ECO_ProjectTaskTriggers.run = true;
        ECO_ProjectTriggers.run = true;

        pse__Proj__c testProject = [SELECT Id, pse__Account__c FROM pse__Proj__c];

		//create source risks
		List<Risk__c> testRisks = new List<Risk__c>();
		for(Integer i=0; i<1; i++){
			Risk__c risk = new Risk__c();
			risk.Project__c = testProject.Id;
			risk.RiskDescription__c = 'risk ' + i;
			risk.CurrencyIsoCode = 'USD';
			testRisks.add(risk);
		}
		insert testRisks;
        
		//Test.startTest();
		//return;
        
		pse__Proj__c project = [select Id, Name from pse__Proj__c limit 1];
		project.name = 'Test';
        
        update project;  
        
		Agreement__c agreement = new Agreement__c();
		agreement.Account__c = testAccount.Id;
		agreement.Description__c = 'Test Agreement';
		agreement.CurrencyIsoCode = 'USD';
		agreement.Amount__c = 1000000;
		//insert agreement;


        
		/*pse__Project_Task__c task = new pse__Project_Task__c();
		task.Name = 'top task';
		task.pse__Project__c = testProject.Id;
		task.pse__Start_Date_Time__c = DateTime.now();
		task.pse__End_Date_Time__c = DateTime.now().addDays(1);
		task.pse__Status__c = 'Draft';
		task.FinancialTask__c = false;
		insert task;	*/

        return;
        
		/*Funding__c funding = new Funding__c();
		funding.AllocatedAmount__c = 10000;
		funding.Agreement__c = agreement.Id;
		funding.Project__c = testproject.Id;
		funding.DateAllocatedDate__c = Date.today();
		funding.ProjectTask__c = task.Id;
		insert funding;	        */
        
		CommunicationPlan__c communicationPlan = new CommunicationPlan__c(Project__c = testProject.Id, 
																	      When__c = Date.Today().addDays(-1),
																	      GenerateTask__c = true,
																	      Activity__c = 'Test');


		insert communicationPlan;        
        
		Deliverable__c d = new Deliverable__c( Name = 'Del 1', project__c = testProject.id );
        insert d;
        
    }       
}