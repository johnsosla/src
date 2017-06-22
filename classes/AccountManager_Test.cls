/*******************************************************************
  Name        :   AccountManager_Test
  Author      :   Sumit(Appirio Off)
  Version     :   1.0 
  Purpose     :   Test Class for AccountManager related Trigger
  Date        :   11-March-2011
********************************************************************/
@isTest
private class AccountManager_Test 
{ 
    static testMethod void myUnitTest() 
    {
        AECOM_Employee__c emp1 = new AECOM_Employee__c(Employee_ID__c='111',    First_Name__c='a1',Last_Name__c='a1',Name='a1 a1');
        AECOM_Employee__c emp2 = new AECOM_Employee__c(Employee_ID__c='112',    First_Name__c='a1',Last_Name__c='a1',Name='a1 a1');
        insert emp1;
        insert emp2;

        Integer iCount;
        List<Account> accList = new List<Account>();
        Account ac = new Account();

        ac.Name = 'name1';
        ac.Type__c = 'Prospect';
        ac.Legacy_AccountID__c = '1100' + system.now();
        ac.Client_Group__c = 'Industrial/Commercial';
        //ac.Client__c = 'Aerospace/Defense';
        ac.City__c = 'BillingCity';
        ac.Street__c = 'Street_1';
        ac.Country__c = 'India';
        ac.State__c = 'BillingState';
        ac.Zip__c = 'BillingPostalCode';
        ac.Account_Manager_User__c = UserInfo.getUserId();
        insert ac;
        ac.Account_Manager_User__c = UserInfo.getUserId();
        update ac;
        //AECOM_team__c  atm =[Select id,Account__c,Employee_User__c,Role__c from AECOM_team__c where Account__c = :ac.Id];
        //atm.Employee_User__c  = UserInfo.getUserId();
        //update atm;
        //try
        //{
        //    delete atm;
        //}
        //catch(exception ex)
        //{
        //}
        AECOM_team__c  atm1=new AECOM_team__c(Account__c=ac.Id,Employee_User__c=UserInfo.getUserId(),Role__c='Account Manager');
        try
        {
            insert atm1;
        }
        catch(exception ex)
        {
        }
        
    }
}