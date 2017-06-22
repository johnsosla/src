/*************************************************************************
*
* PURPOSE: Controller for trigger that figures out the Client__c name field on PR Team records
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsProjectOwnerNameTriggerTest {


    private static testmethod void testProjectOwnerField() {
        Country__c testCountry = new Country__c(Name = 'Test Country');
        insert testCountry;

        Account testAccount = new Account(Name = 'Test Account', Client_Group__c = 'Private', City__c = 'Test City', Country__c = testCountry.Id);
        insert testAccount;

        Project__c testProject = new Project__c(Name = 'Test Project1',Project_Name__c = 'Test Project1', Project_Description__c = 'Test Project Description 123456789', Owner__c = testAccount.Id);
        insert testProject;

        testProject = [Select Id, name, Owner_Client_Output__c, Project_Name__c, Project_Description__c, Owner__c from Project__c where Id = :testProject.Id];

        Test.startTest();
        PR_Team_Employee__c approvedAECOM = new PR_Team_Employee__c(Status__c = rsPRTeamEmployee.S_APPROVED, Project_Id__c = testProject.Id,
                                            Project_Role__c = 'Test Role', Project_Group_Editable__c ='test group', Location_Country_Editable__c = 'United States',
                                            Location_State_Prov_Emirate_Editable__c = 'Arizona', Description__c = 'test description', Client_Name_Editable__c = 'We shouldnt see this');
        insert approvedAECOM;

        PR_Team_Employee__c pendingAECOM = new PR_Team_Employee__c(Status__c = rsPRTeamEmployee.S_PENDING, Project_Role__c = 'Test Role', Project_Group_Editable__c ='test group',
                                            Location_Country_Editable__c = 'United States', Location_State_Prov_Emirate_Editable__c = 'Arizona',
                                            Description__c = 'test description', Client_Name_Editable__c = 'We shouldnt see this', Previous_Project_Part__c = approvedAECOM.Id);
        insert pendingAECOM;

        PR_Team_Employee__c nonAECOM = new PR_Team_Employee__c(Status__c = rsPRTeamEmployee.S_PENDING, Project_Role__c = 'Test Role', Project_Group_Editable__c ='test group',
                                            Location_Country_Editable__c = 'United States', Location_State_Prov_Emirate_Editable__c = 'Arizona',
                                            Description__c = 'test description', Client_Name_Editable__c = 'We should see this');
        insert nonAECOM;
        Test.stopTest();

        //requery our records to check whether the trigger filled out our Client__c fields correctly
        PR_Team_Employee__c approvedAECOMRequery = [Select Id, Client__c from PR_Team_Employee__c where Id = :approvedAECOM.Id];
        PR_Team_Employee__c pendingAECOMRequery = [Select Id, Client__c from PR_Team_Employee__c where Id = :pendingAECOM.Id];
        PR_Team_Employee__c nonAECOMRequery = [Select Id, Client__c from PR_Team_Employee__c where Id = :nonAECOM.Id];

        //System.assert(approvedAECOMRequery.Client__c == testProject.Owner_Client_Output__c);
        //System.assert(pendingAECOMRequery.Client__c == testProject.Owner_Client_Output__c);
        //System.assert(nonAECOMRequery.Client__c == nonAECOM.Client_Name_Editable__c);


    }
}