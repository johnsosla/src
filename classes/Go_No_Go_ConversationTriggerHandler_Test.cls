/** ---------------------------------------------------------------------------------------
* @Description Unit Test for Go_No_Go_ConversationTriggerHandler
*
* @Author AECOM - Steve MunLeeuw
* @Date July 2016
*----------------------------------------------------------------------------------------*/
@isTest
private class Go_No_Go_ConversationTriggerHandler_Test{

    /**
    * unhnalded exception: You cannot update Go Probability, Probability until Go/No Go Conversation is Approved/Rejected
    *
    **/
    //@isTest
    //private static void handleAfterUpdate_Exception_US_05132(){
    //    ECO_ProjectTriggers.run = false;
    //    //arrange
    //    insert new ExecuteTrigger__c(Name = 'Go/No Go');
    //    ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
    //    pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    //    Opportunity o = [SELECT Id, RecordTypeText__c FROM Opportunity WHERE Id = :p.pse__Opportunity__c];

    //    //act
    //    //OpportunityTrigger on Opportunity trigger event AfterUpdate has already been run; skipping
    //    OpportunityTriggerHandler.runAfterUpdate = true;
    //    o.RecordTypeText__c = 'EMEA';
    //    update o;

    //    Test.startTest();
    //    Go_No_Go_Conversation__c gng = [SELECT Id FROM Go_No_Go_Conversation__c WHERE Opportunity__c = :o.Id];
    //    gng.B_P_Charge_Number__c = 'myChargeNumber';
    //    gng.Approval_Status__c = 'Submitted for Approval - Pending';
    //    gng.Project_Start_Date__c = Date.Today();

    //    try{
    //        update gng;
    //    }
    //    catch(Exception e){
    //        //assert
    //        system.assert(e.getMessage().contains('Approved/Rejected'));

    //    }

    //    OpportunityTriggerHandler.runAfterUpdate = true;
    //    o.RecordTypeText__c = 'Americas';
    //    update o;
    //    Test.stopTest();
    //}
}