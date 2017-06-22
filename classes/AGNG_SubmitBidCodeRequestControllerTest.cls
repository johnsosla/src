/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM GoNoGo
*              CLASS: AGNG_SubmitBidCodeRequestControllerTest
*              PURPOSE: Test for AGNG_SubmitBidCodeRequestController class 
*              CREATED: 01/2017 Ethos Solutions - www.ethos.com
**/
@isTest
private class AGNG_SubmitBidCodeRequestControllerTest {
    
    @isTest static void testSubmitBidCode() {
        Integer rand = Math.round(Math.random()*10000);

        Opportunity opp = createTest('North America', '');
        Profile adminProfile = [Select Id, Name from Profile where Name = 'Business Administrator'];
        User tempUser = new User();
        tempUser.FirstName = 'test';
        tempUser.LastName = 'lastName';
        tempUser.Alias = 'test';
        tempUser.Email = 'SFDCTestCase' + '@aecom.com';
        tempUser.Username ='rMaG2470@test.aecom.com' + rand;
        tempUser.CommunityNickname = 'testNick';
        tempUser.ProfileId = adminProfile.Id;
        tempUser.EmailEncodingKey='UTF-8';
        tempUser.LanguageLocaleKey='en_US';
        tempUser.LocaleSidKey='en_US';
        tempUser.TimeZoneSidKey='America/Los_Angeles';
        tempUser.IsActive = true;
        tempUser.AboutMe = 'test test test';
        tempUser.Bio__c = 'test';
        tempUser.Geography__c = '0xDEADBEEF';
        tempUser.Supergeography__c = 'Americas';
        insert tempUser;

        System.runAs(tempUser) {
            Test.startTest();
            Go_No_Go_Conversation__c gng = [Select Id, B_P_Charge_Number__c from Go_No_Go_Conversation__c];
            ApexPages.StandardController std = new ApexPages.StandardController(gng);
            AGNG_SubmitBidCodeRequestController cont = new AGNG_SubmitBidCodeRequestController(std);
            cont.submitBidCode();
            Test.stopTest();
        }
        Go_No_Go_Conversation__c gng = [Select Id, B_P_Charge_Number__c from Go_No_Go_Conversation__c];
        //System.assert(String.isNotBlank(gng.B_P_Charge_Number__c));
    }
    
    private static Opportunity createTest(String geoName, String regionName) {
        if(RegionName == '') {
            RegionName = 'Region';
        }
        insert new ExecuteTrigger__c(Name = 'Go/No Go');
        Geography__c g = new Geography__c(Name = geoName);
        insert g;
        Business_Line__c bl = new Business_Line__c(Name = 'Oil & Gas');
        insert bl;
        AECOM_Primary_Department__c dept = new AECOM_Primary_Department__c(Name = 'Dept', Lead_District__c = 'District', Lead_Region__c = RegionName, Geography_Lookup__c = g.Id, Business_Line_Lookup__c = bl.Id, Operating_Group__c = 'DCS AME');
        insert dept;
        Profile p = [select id from profile where name='AECOM Standard User - APAC'];
        User u = new User(LastName = 'Test User', Alias = 'Alias', Username = 'Test@test12343456677.com.12343456677', CommunityNickname = 'NickName', Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = '999999', EMEA_GNG_Approver__c = true);
        insert u;
        Country__c country = new Country__c(Name = 'Test Country');
        insert country;
        Account newAccount = new Account(Name = 'TestAccount', Client_Group__c = 'Industrial/Commercial', CountryLookup__c = country.Id);
        insert newAccount;
        Date d = Date.today();
        RecordType r = [select Id from RecordType where Name = 'Program - APAC' and sObjectType = 'Opportunity'];
        Opportunity newOpp = new Opportunity(Name = 'TestOpp', StageName = '1 Lead', AccountId = newAccount.Id, Probability_Stage__c = 0.1, Description = 'Desc', Project_City__c = 'Test City', Construction_cost__c = 10000, Project_DirectorUser__c = u.Id, Capture_Manager_User__c = u.Id, Date_RFP_expected__c = d, Estimated_work_start_date__c = d, CloseDate = d, Work_end_date_del__c = d, Subs_Other_Revenue__c = 1000, Go_Probability__c = 1, Amount = 2000, Contingent_Liabilities_Notes__c = 'Contingent', CS_Gross_Margin_Percent__c = 20, Enterprise_Service__c = 'Architecture',Contract_Est_Months__c = 1 );
        newOpp.RecordTypeId = r.Id;
        insert newOpp;
        OpportunityTriggerHandler.runAfterUpdate = true;
        newOpp.AECOM_Primary_Dept_Lookup__c = dept.Id;
        update newOpp;
        return newOpp;
    }
    
}