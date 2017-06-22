@isTest
public with sharing class Test_CFM_Survey_Response_Trigger {

  @isTest 
  private static void TestCFMSurveyResponseTriggerBeforeInsertDeletedAccount() 
  {
    //I can't merge prior to the Survey Respsonse, system throws ENTITY_IS_DELETED error

    // ---------------         Arrange

    String customerNumber = 'masterAccount';

    Country__c country = new Country__c(Name = 'Test Country');
    insert country;

    Account masterAccount = new Account(Name = 'Master Account', Client_Group__c = 'Industrial/Commercial', CountryLookup__c = country.Id, OracleCustomerNumber__c = customerNumber);
    Account mergeAccount = new Account(Name = 'Merge Account', Client_Group__c = 'Industrial/Commercial', CountryLookup__c = country.Id);
    insert masterAccount;
    insert mergeAccount;

    try{
      merge masterAccount mergeAccount;
    }
    catch(DmlException ex){
      System.debug('error merging accounts:  ' + ex.getMessage());
    }

    Map<Id, Account> activeAccounts = new Map<Id, Account>(
          [select Id
          from Account
          where 
            Name = 'Master Account']);


    // ---------------         Act

    CFM_Survey_Response__c mockSurveyResponse = new CFM_Survey_Response__c(Account__c = mergeAccount.Id, OracleCustomerNumber__c = customerNumber);
    insert mockSurveyResponse;

    // ---------------         Assert

    System.assert(mockSurveyResponse.Account__c != null);
  }

  @isTest 
  private static void TestCFMSurveyResponseTriggerBeforeInsertDeletedAccountNullOracleCustomerNumber() 
  {
    // ---------------         Arrange
    Boolean exceptionOccurred = false;
    String customerNumber = 'masterAccount';

    Country__c country = new Country__c(Name = 'Test Country');
    insert country;

    Account masterAccount = new Account(Name = 'Master Account', Client_Group__c = 'Industrial/Commercial', CountryLookup__c = country.Id, OracleCustomerNumber__c = customerNumber);
    Account mergeAccount = new Account(Name = 'Merge Account', Client_Group__c = 'Industrial/Commercial', CountryLookup__c = country.Id);
    insert masterAccount;
    insert mergeAccount;

    try{
      merge masterAccount mergeAccount;
    }
    catch(DmlException ex){
      System.debug('error merging accounts:  ' + ex.getMessage());
    }

    Map<Id, Account> activeAccounts = new Map<Id, Account>(
          [select Id
          from Account
          where 
            Name = 'Master Account']);


    // ---------------         Act

    CFM_Survey_Response__c mockSurveyResponse = new CFM_Survey_Response__c(Account__c = mergeAccount.Id, OracleCustomerNumber__c = null);
    try{
      insert mockSurveyResponse;
    }
    catch(DmlException ex){
        exceptionOccurred = true;
    }

    // ---------------         Assert
    System.assert(exceptionOccurred == true, 'expected exception' + mockSurveyResponse.Account__c);
  }

  @isTest 
  private static void TestCFMSurveyResponseTriggerBeforeInsertNoAccountUpdateNeeded() 
  {
    CFM_Survey_Response__c mockSurveyResponse = TestCoverageSmokeMocks.mockSurveyResponse(true);
    System.assert(mockSurveyResponse.Account__c != null);
  }
}