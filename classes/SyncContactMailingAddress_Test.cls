/*******************************************************************
  Name        :   SyncContactMailingAddress_Test
  Author      :   Ganesh(Appirio Off)
  Version     :   1.0 
  Purpose     :   Test Class for SyncContactMailingAddress Trigger
  Date        :   3-Aug-2010
********************************************************************/
@isTest
private class SyncContactMailingAddress_Test { 
    static testMethod void myUnitTest() {
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
        accList.add(ac);
        
        ac = new Account();
        ac.Name = 'name2';
        ac.Type__c = 'Prospect';
        ac.Legacy_AccountID__c = '1111' + system.now();
        ac.Client_Group__c = 'Industrial/Commercial';
        //ac.Client__c = 'Aerospace/Defense';
        ac.City__c = 'BillingCity';
        ac.Street__c = 'Street1';
        ac.Country__c = 'USA';
        ac.State__c = 'BillingState';
        ac.Zip__c = 'BillingPostalCode';
        accList.add(ac);
        
        insert accList;
        
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.FirstName = 'conName';
        con.LastName = 'conLastName';
        //con.Legacy_AccountID__c = '1000';
        con.Legacy_ContactID__c = '1000' + system.now();
        con.AccountId = accList.get(0).Id;
        conList.add(con);
        
        /* Nirav: Same contact id for so many contacts??*/
        for(iCount = 0; iCount <= 201; iCount++){
            con = new Contact();
            con.AccountId = accList.get(1).Id;
            con.FirstName = 'conName';
            con.LastName = 'conLastName' + iCount;
            //con.Legacy_AccountID__c = '1000'+icount;
            con.Legacy_ContactID__c = 'cd1000'+iCount; // Nirav: Duplicates!!
            conList.add(con);
        }
        
        con = new Contact();
        con.AccountId = accList.get(0).Id;
        con.FirstName = 'conName';
        //con.Legacy_AccountID__c = '1000';
        con.Legacy_ContactID__c = 'ab11090'+ System.now();
        con.LastName = 'conLastName';
        conList.add(con);
        
        
        insert conList;
        
        ac = accList.get(1);
        ac.Name = 'My';
        ac.City__c = 'My City';
        ac.Street__c = 'My Street';
        ac.Country__c = 'My Country';
        ac.State__c = 'My State';
        ac.Zip__c = '112233';
        update ac;
        
        for(Contact cc : [SELECT Id, Name, AccountId, MailingCity , MailingCountry  FROM Contact WHERE AccountId =: accList.get(1).Id limit 1]){
            System.assertEquals(cc.AccountId, accList.get(1).Id);
            //System.assertEquals(cc.MailingCity , accList.get(1).City__c);
            //System.assertEquals(cc.MailingCountry , accList.get(1).Country__c);
        }
         
        ac = accList.get(0);
        ac.Name = 'My';
        ac.City__c = 'My City';
        ac.Street__c = 'Street_1';
        ac.Country__c = 'India';
        ac.State__c = 'BillingState';
        ac.Zip__c = 'BillingPostalCode';
        update ac;
        
        ac.Name = 'My';
        ac.City__c = 'My City';
        ac.Street__c = 'My Street 1';
        ac.Country__c = 'India';
        ac.State__c = 'BillingState';
        ac.Zip__c = 'BillingPostalCode';
        update ac;
        
        ac.Name = 'My';
        ac.City__c = 'My City';
        ac.Street__c = 'My Street 1';
        ac.Country__c = 'My Country';
        ac.State__c = 'BillingState';
        ac.Zip__c = 'BillingPostalCode';
        update ac;
        
        ac.Name = 'My';
        ac.City__c = 'My City';
        ac.Street__c = 'My Street 1';
        ac.Country__c = 'Country';
        ac.State__c = 'My State';
        ac.Zip__c = 'BillingPostalCode';
        update ac;
        
        ac.Name = 'My';
        ac.City__c = 'My City';
        ac.Street__c = 'My Street 1';
        ac.Country__c = 'Country';
        ac.State__c = 'My State';
        ac.Zip__c = '112233';
        update ac;
        con.AccountId = accList.get(1).id;
        update con;
        //Test.stopTest();
    }
    
    /**
    * @description new test for updated trigger...checks CountryLookup and State Province Emirate lookup
    */
    @isTest
    static void testAccountSyncWithCountry() {
    	Country__c newCountry = new Country__c(Name='Test Country 123');
    	insert newCountry;
    	
    	State_Province_Emirate__c newState = new State_Province_Emirate__c(Name='Test State 123');
    	newState.Country__c = newCountry.ID;
    	insert newState;
    	
    	Account ac = new Account();
        
        ac.Name = 'Test Account 123';
        ac.Type__c = 'Prospect';
        ac.Legacy_AccountID__c = '1100' + system.now();
        ac.Client_Group__c = 'Industrial/Commercial';
        //ac.Client__c = 'Aerospace/Defense';
        ac.City__c = 'BillingCity';
        ac.Street__c = 'Street_1';
        //ac.Country__c = 'India';
        //ac.State__c = 'BillingState';
        ac.Zip__c = 'BillingPostalCode';
        ac.CountryLookup__c = newCountry.id;
        ac.State_Province_Emerate__c = newState.ID;
        insert ac;
        
        ac = [SELECT ID, BillingState, BillingCountry FROM Account WHERE ID = :ac.id];
        system.assertEquals('Test Country 123', ac.BillingCountry);
        system.assertEquals('Test State 123', ac.BillingState);
        
        
    }
}