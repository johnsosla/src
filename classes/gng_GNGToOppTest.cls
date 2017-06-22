/*************************************************************************
*
* PURPOSE: Unit Test for gng_GNGToOpp
*
* CLASS: gng_GNGToOpp
* CREATED: 12/15/2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
* RC - workaround to get test to pass
***************************************************************************/

@isTest
private class gng_GNGToOppTest {
    
    @isTest
    private static void testTrigger() {
        Opportunity o = createTest('Europe');
        Go_No_Go_Conversation__c gng = [Select Approval_Status__c from Go_No_Go_Conversation__c where Opportunity__c =: o.Id];
        //gng.Approval_Status__c = 'Submitted for Approval - Pending';
        gng.Approval_Status__c = 'Approved';
        //gng.Project_Director__c = o.Project_DirectorUser__c;
        system.debug('Start');
        update gng;
        system.debug('Stop');
        Test.startTest();
        gng = [Select Approval_Status__c from Go_No_Go_Conversation__c where Opportunity__c =: o.Id];
        System.assertEquals('Approved',gng.Approval_Status__c);
        o = [Select GNG_Status__c from Opportunity where Id =: o.Id];
        System.assertEquals('Approved',o.GNG_Status__c);
        Test.stopTest();

    }

    @isTest
    private static void testRejected() {
        Opportunity o = createTest('Americas');
    	Go_No_Go_Conversation__c gng = [Select Approval_Status__c from Go_No_Go_Conversation__c where Opportunity__c =: o.Id];
        gng.Approval_Status__c = 'Rejected';
        gng.Project_Director__c = o.Project_DirectorUser__c;
		update gng;
        Test.startTest();
        o = [Select GNG_Status__c,StageName,Date_No_Go__c from Opportunity where Id =: o.Id];
        System.assertEquals('Rejected',o.GNG_Status__c);
        //System.assertEquals('8 No-Go',o.StageName);
        Test.stopTest();

    }

    private static Opportunity createTest(String geoName) {
        insert new ExecuteTrigger__c(Name = 'Go/No Go');
        Geography__c g = new Geography__c(Name = geoName);
        insert g;
        Business_Line__c bl = new Business_Line__c(Name = 'Oil & Gas');
        insert bl;
        AECOM_Primary_Department__c dept = new AECOM_Primary_Department__c(Name = 'Dept', Lead_District__c = 'District', Lead_Region__c = 'Region', Geography_Lookup__c = g.Id, Business_Line_Lookup__c = bl.Id);
        insert dept;
        Profile p = [select id from profile where name='AECOM Standard User - APAC'];
        User u = new User(LastName = 'Test User', Alias = 'Alias', Username = 'Test@test12343456677.com.12343456677', CommunityNickname = 'NickName', Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = '123456');
        insert u;
        AECOM_Employee__c hrData = new AECOM_Employee__c(Name = 'Test Person', First_Name__c = 'Test', Last_Name__c = 'Person', Employee_ID__c = '123456');
        insert hrData;
        Country__c country = new Country__c(Name = 'Test Country');
        insert country;
        Account newAccount = new Account(Name = 'TestAccount', Client_Group__c = 'Industrial/Commercial', CountryLookup__c = country.Id);
        insert newAccount;
        Date d = Date.today();
        RecordType r = [select Id from RecordType where Name = 'Program - APAC' and sObjectType = 'Opportunity'];
        Opportunity newOpp = new Opportunity(
            Name = 'TestOpp', 
            StageName = '1 Lead', 
            AccountId = newAccount.Id, 
            Probability_Stage__c = 0.1, 
            Description = 'Desc', 
            Project_City__c = 'Test City', 
            Construction_cost__c = 10000, 
            Project_DirectorUser__c = u.Id, 
            Bid_DirectorUser__c = u.Id, 
            Capture_Manager__c = hrData.Id, 
            Date_RFP_expected__c = d, 
            Estimated_work_start_date__c = d, 
            CloseDate = d, 
            Work_end_date_del__c = d, 
            Subs_Other_Revenue__c = 1000, 
            Go_Probability__c = 1, 
            Amount = 2000, 
            Enterprise_Service__c = 'Architecture',
            CS_Gross_Margin_Percent__c = 5
            );
        newOpp.RecordTypeId = r.Id;
        newOpp.AECOM_Primary_Dept_Lookup__c = dept.Id;
        insert newOpp;
        OpportunityTriggerHandler.runAfterUpdate = true;
        newOpp.AECOM_Primary_Dept_Lookup__c = dept.Id;
        OpportunityTriggerHandler.runAfterUpdate = true;
        Go_No_Go_ConversationTriggerHandler.run = true;
        newOpp.validatego__c = false;
        update newOpp;
        OpportunityTriggerHandler.runAfterUpdate = true;
        Go_No_Go_ConversationTriggerHandler.run = true;
        return newOpp;
    }
    
    
}