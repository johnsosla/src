@isTest
public with sharing class ECO_CreateMSAContactTest {
	
	static testMethod void testCancelNewContact() {
		
		Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;
        
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c testProject = [select Id, Name from pse__Proj__c limit 1];
        
        Agreement__c agreement = new Agreement__c();
        agreement.Account__c = testAccount.Id;
        
        insert agreement;

        ManagementTeam__c managementTeam = new ManagementTeam__c(Agreement__c = agreement.Id);
        insert managementTeam;

        ApexPages.StandardController standardController = new ApexPages.StandardController(managementTeam);
        ECO_CreateMSAContact msaContact = new ECO_CreateMSAContact(standardController);

        msaContact.init();
        msaContact.cancelNewContact();
	}

	static testMethod void testCreateNewContact() {
		
		Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;
        
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c testProject = [select Id, Name from pse__Proj__c limit 1];
        
        Agreement__c agreement = new Agreement__c();
        agreement.Account__c = testAccount.Id;
        
        insert agreement;

        ManagementTeam__c managementTeam = new ManagementTeam__c(Agreement__c = agreement.Id);
        insert managementTeam;

        ApexPages.StandardController standardController = new ApexPages.StandardController(managementTeam);
        ECO_CreateMSAContact msaContact = new ECO_CreateMSAContact(standardController);

        msaContact.init();
        msaContact.createNewContact();
        msaContact.contact.LastName = 'Test';
        msaContact.contact.FirstName = 'Test';
        msaContact.saveNewContact();
        msaContact.save();
	}	
}