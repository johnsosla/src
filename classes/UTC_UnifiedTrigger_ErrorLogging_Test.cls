/*************************************************************************
* @Description Test class for UTC_UnifiedTrigger.trigger --> sshUserContactUtils.cls --> createNewContactsForInsertedUsers() and doUpdateContactUsers() methods
*
* @Author      AECOM - Duke Ames
* @Date        08/21/2016
***************************************************************************/

@isTest
private class  UTC_UnifiedTrigger_ErrorLogging_Test {

    private static testMethod void TestUTC_UnifiedTrigger_ErrorLogging(){

        // User JobTitle is 250 char, Contact JobTitle is 240 char
        // Setting User JobTitle > 240 char will cause Contact record insert (created via trigger) to fail and insert ErrorLog record
        String jobTitle = 'Throw                                                                                                                                                                                                                                            Exception';

        ErrorLog__c[] errorLogArray;
        Contact[] contactArray;
        Integer recordCount;

        List<User> userList = new List<User>();

        // Create 2 users, 1 will fail to create new contact, 1 will succeed
        User userForFail = ECO_Utils_Testing.createTestUser('Standard User');
        User userForSuccess = ECO_Utils_Testing.createTestUser('Standard User');

        // REMOVE consultant so trigger UTC_UnifiedTrigger on User will fire
        userForFail.Email = userForFail.Email.remove('consultant');
        userForSuccess.Email = userForSuccess.Email.remove('consultant');
        
        // add jobTitle to userForFail which will cause the contact insert failure
        userForFail.HR_Job_Title__c = jobTitle;

        userList.add(userForFail);
        userList.add(userForSuccess);
        
        Test.startTest();

        insert userList;

        String userForFailId = userList[0].ID;
        String userForSuccessId = userList[1].ID;

        Test.stopTest();

        // Verify ErrorLog created for userForFail
        errorLogArray = [SELECT RecordId2__c FROM ErrorLog__c WHERE RecordId2__c = : userForFailId];
        recordCount = errorLogArray.size();
        System.assertEquals(1, recordCount, 'ErrorLog record not created for creating User Contact record that should have failed');


        // Verify Contact NOT created for userForFail
        contactArray = [SELECT ID FROM Contact WHERE User__c = : userForFailId];
        recordCount = contactArray.size();
        System.assertEquals(0, recordCount, 'User Contact record created when it should have failed due to JobTile too long');


        // Verify Contact created for userForSuccess
        contactArray = [SELECT ID FROM Contact WHERE User__c = : userForSuccessId];
        recordCount = contactArray.size();
        System.assertEquals(1, recordCount, 'User Contact record NOT created for new User');
    }

}