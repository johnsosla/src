/*************************************************************************
*
* PURPOSE: Test Class for Controller for Profile Project model class
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsProjectTest {
    private static testmethod void testPRTeamEmployeeDataAccess() {
        Country__c testCountry = new Country__c(Name = 'Test Country');
        insert testCountry;

        Account testAccount = new Account(Name = 'Test Account', Client_Group__c = 'Private', City__c = 'Test City', Country__c = testCountry.Id);
        insert testAccount;

        Project__c testProject = new Project__c(Name = 'Test Project1',Project_Name__c = 'Test Project1', Project_Description__c = 'Test Project Description 123456789', Owner__c = testAccount.Id);
        insert testProject;

        Test.startTest();
        rsProject tempProj = new rsProject(testProject);
        tempProj.getProjectName();
        tempProj.getProjectNumber();
        tempProj.getLocation();
        tempProj.getClientName();
        Test.stopTest();
    }
}