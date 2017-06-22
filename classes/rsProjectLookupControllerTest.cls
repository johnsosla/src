/*************************************************************************
*
* PURPOSE: Test class for Controller for popup project lookup
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsProjectLookupControllerTest {
    private static testmethod void testLookupController() {
        Country__c testCountry = new Country__c(Name = 'Test Country');
        insert testCountry;

        Account testAccount = new Account(Name = 'Test Account', Client_Group__c = 'Private', City__c = 'Test City', Country__c = testCountry.Id);
        insert testAccount;

        Project__c testProject = new Project__c(Name = 'Test Project1',Project_Name__c = 'Test Project1', Project_Description__c = 'Test Project Description 123456789', Owner__c = testAccount.Id);
        insert testProject;

        Test.startTest();
        rsProjectLookupController cont = new rsProjectLookupController();
        ApexPages.currentPage().getParameters().put('frm', 'testFrmURLParam');
        ApexPages.currentPage().getParameters().put('txt', 'testtxtURLParam');
        cont.SearchName = 'Test Project1';
        cont.refreshResults();
        String getFormTag = cont.getFormTag();
        String getTextBox = cont.getTextBox();
        Test.stopTest();

        System.assertEquals(getFormTag, 'testFrmURLParam');
        System.assertEquals(getTextBox, 'testtxtURLParam');
        System.assertEquals(cont.Projects.size(), 1);
        cont.SearchName = null;
        cont.refreshResults();
        //No search terms should throw an error
        System.assert(!ApexPages.getMessages().isEmpty());
    }
}