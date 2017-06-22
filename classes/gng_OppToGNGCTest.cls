/*************************************************************************
*
* PURPOSE: Unit Test for gng_OppToGNGC class/trigger
*
* CLASS: gng_OppToGNGCTest
* CREATED: 10/28/2014 Ethos Solutions - www.ethos.com
* AUTHOR: Raghuveer Mandali
* UPDATE: Ram Kalagara 10/28/2015. Updated testCreateANZ method to test newly added GNG fields
*         Ram Kalagara 11/23/2015. Rolled back my changes from 10/28 update. Added Enterprise Service required field.
*         Richard Cook 2016-06-08 Added new tests for ePM NZ rollout & fix broken tests
***************************************************************************/
@isTest
private class gng_OppToGNGCTest {
	private static testmethod void testCreateANZ() {
        Test.startTest();
		Opportunity opp = createTest('ANZ', '');
        Test.stopTest();
		//Go_No_Go_Conversation__c gng = [select Id, CurrencyIsoCode, Client_Name__c, Subs_Fee__c, Staff_Time_FBLR_Fee__c, Market_Position_Q11__c, Market_Position_Q12__c, Project_Scope_Summary__c, Project_Location__c, Capital_Value__c, Project_Director__c, Bid_Manager__c, Bid_Director__c, Project_Manager__c, RFT_Issue_Date__c, Project_Start_Date__c, Proposal_Due_Date__c, Project_Duration__c, Subs_Cost__c from Go_No_Go_Conversation__c where Opportunity__c =: opp.Id];
		opp = [select Id, Probability_Stage__c, Go_Probability__c, Description, Construction_cost__c, Project_DirectorUser__c, Capture_Manager_User__c, Date_RFP_expected__c, Estimated_work_start_date__c, Work_end_date_del__c, AccountId, Subs_Other_Revenue__c, Net_Revenue_To_Project__c from Opportunity where Id =: opp.Id];
		User u = [select Id from User where EmployeeNumber = '999999' LIMIT 1];
		//ANZ no longer creates a gng
		/*
		System.assertNotEquals(gng, null);
		System.assertEquals(gng.Market_Position_Q12__c, opp.Probability_Stage__c);
		System.assertEquals(gng.Market_Position_Q11__c, opp.Go_Probability__c);
		System.assertEquals(gng.Project_Scope_Summary__c, opp.Description);
		System.assertEquals(gng.Capital_Value__c, opp.Construction_cost__c);
		System.assertEquals(gng.Project_Director__c, opp.Project_DirectorUser__c);
		System.assertEquals(gng.Bid_Manager__c, u.Id);
		System.assertEquals(gng.Bid_Director__c, opp.Capture_Manager_User__c);
		System.assertEquals(gng.Project_Manager__c, u.Id);
		System.assertEquals(gng.RFT_Issue_Date__c, opp.Date_RFP_expected__c);
		System.assertEquals(gng.Project_Start_Date__c, opp.Estimated_work_start_date__c);
		System.assertEquals(gng.Project_Duration__c, opp.Work_end_date_del__c);
		System.assertEquals(gng.Subs_Cost__c, opp.Subs_Other_Revenue__c);
		System.assertEquals(gng.Client_Name__c, opp.AccountId);
		System.assertEquals(gng.Subs_Fee__c, opp.Subs_Other_Revenue__c);
		System.assertEquals(gng.Staff_Time_FBLR_Fee__c, opp.Net_Revenue_To_Project__c);
		*/
	}

	private static testmethod void testCreateAmericas() {
		Opportunity opp = createTest('North America', '');
		Test.startTest();
		Go_No_Go_Conversation__c gng = [select Id, CurrencyIsoCode, Client_Name__c, Subs_Fee__c, Staff_Time_FBLR_Fee__c, Market_Position_Q11__c, Market_Position_Q12__c, Project_Scope_Summary__c, Project_Location__c, Capital_Value__c, Project_Director__c, Bid_Manager__c, Bid_Director__c, Project_Manager__c, RFT_Issue_Date__c, Project_Start_Date__c, Proposal_Due_Date__c, Project_Duration__c, Subs_Cost__c from Go_No_Go_Conversation__c where Opportunity__c =: opp.Id];
		opp = [select Id, Probability_Stage__c, Go_Probability__c, Description, Construction_cost__c, Project_DirectorUser__c, Capture_Manager_User__c, Date_RFP_expected__c, Estimated_work_start_date__c, Work_end_date_del__c, AccountId, Subs_Other_Revenue__c, Net_Revenue_To_Project__c from Opportunity where Id =: opp.Id];
		User u = [select Id from User where EmployeeNumber = '999999' LIMIT 1];
		Test.stopTest();
		System.assertNotEquals(gng, null);
		System.assertEquals(gng.Market_Position_Q12__c, opp.Probability_Stage__c);
		System.assertEquals(gng.Market_Position_Q11__c, opp.Go_Probability__c);
		System.assertEquals(gng.Project_Scope_Summary__c, opp.Description);
		System.assertEquals(gng.Capital_Value__c, opp.Construction_cost__c);
		System.assertEquals(gng.Project_Director__c, opp.Project_DirectorUser__c);
		System.assertEquals(gng.Bid_Manager__c, u.Id);
		System.assertEquals(gng.Bid_Director__c, opp.Capture_Manager_User__c);
		System.assertEquals(gng.Project_Manager__c, u.Id);
		System.assertEquals(gng.RFT_Issue_Date__c, opp.Date_RFP_expected__c);
		System.assertEquals(gng.Project_Start_Date__c, opp.Estimated_work_start_date__c);
		System.assertEquals(gng.Project_Duration__c, opp.Work_end_date_del__c);
		System.assertEquals(gng.Subs_Cost__c, opp.Subs_Other_Revenue__c);
		System.assertEquals(gng.Client_Name__c, opp.AccountId);
		System.assertEquals(gng.Subs_Fee__c, opp.Subs_Other_Revenue__c);
		System.assertEquals(gng.Staff_Time_FBLR_Fee__c, opp.Net_Revenue_To_Project__c);
	}

	private static testmethod void testCreateEurope() {
		Opportunity opp = createTest('Europe', '');
		Test.startTest();
		opp = [select Id, Probability_Stage__c, Go_Probability__c, Description, Construction_cost__c, Project_DirectorUser__c, Capture_Manager_User__c, Date_RFP_expected__c, Estimated_work_start_date__c, Work_end_date_del__c, AccountId, Subs_Other_Revenue__c, Net_Revenue_To_Project__c from Opportunity where Id =: opp.Id];
		User u = [select Id from User where EmployeeNumber = '999999' LIMIT 1];
		opp.Project_DirectorUser__c = null;
		opp.Project_Director_EMEA__c = u.Id;
        OpportunityTriggerHandler.runAfterUpdate = true;
		update opp;
		Go_No_Go_Conversation__c gng = [select Id, CurrencyIsoCode, Client_Name__c, Subs_Fee__c, Staff_Time_FBLR_Fee__c, Market_Position_Q11__c, Market_Position_Q12__c, Project_Scope_Summary__c, Project_Location__c, Capital_Value__c, Project_Director__c, Bid_Manager__c, Bid_Director__c, Project_Manager__c, RFT_Issue_Date__c, Project_Start_Date__c, Proposal_Due_Date__c, Project_Duration__c, Subs_Cost__c from Go_No_Go_Conversation__c where Opportunity__c =: opp.Id];
		Test.stopTest();
		System.assertNotEquals(gng, null);
		System.assertEquals(gng.Market_Position_Q12__c, opp.Probability_Stage__c);
		System.assertEquals(gng.Market_Position_Q11__c, opp.Go_Probability__c);
		System.assertEquals(gng.Project_Scope_Summary__c, opp.Description);
		System.assertEquals(gng.Capital_Value__c, opp.Construction_cost__c);
		System.assertEquals(gng.Project_Director__c, opp.Project_Director_EMEA__c);
		System.assertEquals(gng.Bid_Manager__c, u.Id);
		System.assertEquals(gng.Bid_Director__c, opp.Bid_DirectorUser__c);
		System.assertEquals(gng.Project_Manager__c, u.Id);
		System.assertEquals(gng.RFT_Issue_Date__c, opp.Date_RFP_expected__c);
		System.assertEquals(gng.Project_Start_Date__c, opp.Estimated_work_start_date__c);
		System.assertEquals(gng.Project_Duration__c, opp.Work_end_date_del__c);
		System.assertEquals(gng.Subs_Cost__c, opp.Subs_Other_Revenue__c);
		System.assertEquals(gng.Client_Name__c, opp.AccountId);
		System.assertEquals(gng.Subs_Fee__c, opp.Subs_Other_Revenue__c);
		System.assertEquals(gng.Staff_Time_FBLR_Fee__c, opp.Net_Revenue_To_Project__c);
	}

	private static testmethod void testCreateViewOnly() {
		Opportunity opp = createTest('Africa', '');
		Test.startTest();
		opp = [select Id, Probability_Stage__c, Go_Probability__c, Description, Construction_cost__c, Project_DirectorUser__c, Bid_ManagerUser__c, Bid_DirectorUser__c, Project_ManagerUser__c, Date_RFP_expected__c, Estimated_work_start_date__c, Work_end_date_del__c, AccountId, Subs_Other_Revenue__c, Net_Revenue_To_Project__c from Opportunity where Id =: opp.Id];
		User u = [select Id from User where EmployeeNumber = '999999' LIMIT 1];
		opp.Project_DirectorUser__c = null;
		opp.Project_Director_EMEA__c = u.Id;
        OpportunityTriggerHandler.runAfterUpdate = true;
		update opp;
		Go_No_Go_Conversation__c gng = [select Id, CurrencyIsoCode, Client_Name__c, Subs_Fee__c, Staff_Time_FBLR_Fee__c, Market_Position_Q11__c, Market_Position_Q12__c, Project_Scope_Summary__c, Project_Location__c, Capital_Value__c, Project_Director__c, Bid_Manager__c, Bid_Director__c, Project_Manager__c, RFT_Issue_Date__c, Project_Start_Date__c, Proposal_Due_Date__c, Project_Duration__c, Subs_Cost__c from Go_No_Go_Conversation__c where Opportunity__c =: opp.Id];
		Test.stopTest();
		System.assertNotEquals(gng, null);
		System.assertEquals(gng.Market_Position_Q12__c, opp.Probability_Stage__c);
		System.assertEquals(gng.Market_Position_Q11__c, opp.Go_Probability__c);
		System.assertEquals(gng.Project_Scope_Summary__c, opp.Description);
		System.assertEquals(gng.Capital_Value__c, opp.Construction_cost__c);
		System.assertEquals(gng.Project_Director__c, opp.Project_Director_EMEA__c);
		System.assertEquals(gng.Bid_Manager__c, u.Id);
		System.assertEquals(gng.Bid_Director__c, opp.Bid_DirectorUser__c);
		System.assertEquals(gng.Project_Manager__c, u.Id);
		System.assertEquals(gng.RFT_Issue_Date__c, opp.Date_RFP_expected__c);
		System.assertEquals(gng.Project_Start_Date__c, opp.Estimated_work_start_date__c);
		System.assertEquals(gng.Project_Duration__c, opp.Work_end_date_del__c);
		System.assertEquals(gng.Subs_Cost__c, opp.Subs_Other_Revenue__c);
		System.assertEquals(gng.Client_Name__c, opp.AccountId);
		System.assertEquals(gng.Subs_Fee__c, opp.Subs_Other_Revenue__c);
		System.assertEquals(gng.Staff_Time_FBLR_Fee__c, opp.Net_Revenue_To_Project__c);
	}
	
	private static testmethod void testEdit() {
		Opportunity opp = createTest('India', '');
		Test.startTest();
		opp.Construction_cost__c = 1;
		update opp;
		Go_No_Go_Conversation__c gng = [select Id, Project_Scope_Summary__c from Go_No_Go_Conversation__c where Opportunity__c =: opp.Id];
		Test.stopTest();
		System.assertEquals(gng.Project_Scope_Summary__c, opp.Description);
	}

	private static testmethod void testDelete() {
		Opportunity opp = createTest('ANZ', 'ANZ VSA');
		Test.startTest();
		delete opp;
		List<Go_No_Go_Conversation__c> gng = [select Id, CurrencyIsoCode, Market_Position_Q11__c, Market_Position_Q12__c, Project_Scope_Summary__c, Project_Location__c, Capital_Value__c, Project_Director__c, Bid_Manager__c, Bid_Director__c, Project_Manager__c, RFT_Issue_Date__c, Project_Start_Date__c, Proposal_Due_Date__c, Project_Duration__c, Subs_Cost__c from Go_No_Go_Conversation__c];
		Test.stopTest();
		System.assertEquals(gng.size(), 0);
	}

	private static testmethod void ePM_ANZ_DisabledRegions() {
        // ANZ NZ disabled for ePM NZ rollout
		Opportunity opp = createTest('ANZ', 'ANZ NZ');
		Test.startTest();
		Test.stopTest();
        List<Go_No_Go_Conversation__c> gng = [select Id, Project_Scope_Summary__c from Go_No_Go_Conversation__c where Opportunity__c =: opp.Id];
        System.assertEquals(gng.size(), 0);
		opp.Construction_cost__c = 1;
		update opp;
        System.assertEquals(gng.size(), 0);
        
	}
    
	private static testmethod void ePM_ANZ_EnabledRegions() {
        // other ANZ regions still should create GNG automatically
        // no longer true with I-1827
		Opportunity opp = createTest('ANZ', 'ANZ VSA');
		Test.startTest();
		Test.stopTest();
        List<Go_No_Go_Conversation__c> gng = [select Id, Project_Scope_Summary__c from Go_No_Go_Conversation__c where Opportunity__c =: opp.Id];
        System.assertEquals(gng.size(), 0);
	}    
    
    

	private static Opportunity createTest(String geoName, string RegionName) {
        if(RegionName == '')
            RegionName = 'Region';
		insert new ExecuteTrigger__c(Name = 'Go/No Go');
		Geography__c g = new Geography__c(Name = geoName);
		insert g;
		Business_Line__c bl = new Business_Line__c(Name = 'Oil & Gas');
		insert bl;
		AECOM_Primary_Department__c dept = new AECOM_Primary_Department__c(Name = 'Dept', Lead_District__c = 'District', Lead_Region__c = RegionName, Geography_Lookup__c = g.Id, Business_Line_Lookup__c = bl.Id);
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
		Opportunity newOpp = new Opportunity(Name = 'TestOpp', StageName = '1 Lead', AccountId = newAccount.Id, Probability_Stage__c = 0.1, Description = 'Desc', Project_City__c = 'Test City', Construction_cost__c = 10000, Project_DirectorUser__c = u.Id, Capture_Manager_User__c = u.Id, Date_RFP_expected__c = d, Estimated_work_start_date__c = d, CloseDate = d, Work_end_date_del__c = d, Subs_Other_Revenue__c = 1000, Go_Probability__c = 1, Amount = 2000, Contingent_Liabilities_Notes__c = 'Contingent', CS_Gross_Margin_Percent__c = 20, Enterprise_Service__c = 'Architecture' );
		newOpp.RecordTypeId = r.Id;
		insert newOpp;
        OpportunityTriggerHandler.runAfterUpdate = true;
		newOpp.AECOM_Primary_Dept_Lookup__c = dept.Id;
		update newOpp;
		return newOpp;
	}
	
}