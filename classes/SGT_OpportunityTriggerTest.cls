/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_OpportunityTriggerTest
*              PURPOSE: Test class for SGT_OpportunityTriggerHandler
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
@isTest
public class SGT_OpportunityTriggerTest {

	@isTest static void testOpportunityInsert() {
		SGT_TestUtil.setupHttpMock();

		SGT_Sales_Goal__c sg = SGT_TestUtil.createTestBusinessLineSalesGoal();

		Test.startTest();
		Opportunity opp = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 1, 1));
		Opportunity opp2 = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 2, 1));

		// Opportunity outside of the fiscal year should not create a Goal Opp
		Opportunity opp3 = SGT_TestUtil.createTestOpportunity(Date.newInstance(2017, 1, 1));
		Opportunity opp4 = SGT_TestUtil.createTestOpportunity(Date.newInstance(2015, 12, 12));
		Test.stopTest();
		List<SGT_Goal_Opportunity__c> goalOpps = [Select Id from SGT_Goal_Opportunity__c];

		System.assertEquals(3, goalOpps.size(), 'Should have created three goal opportunities');
	}

	@isTest static void testBusinessLineOpportunityAfterUpdate() {
		SGT_TestUtil.setupHttpMock();

		SGT_Sales_Goal__c sg = SGT_TestUtil.createTestBusinessLineSalesGoal();
		SGT_Sales_Goal__c sg2 = SGT_TestUtil.createTestBusinessLineSalesGoal();
		sg2.Enterprise_Service__c = 'Test Service';
		update sg2;

		Opportunity opp = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 1, 1));
		opp = SGT_Opportunity.find.findByWhere(' ID = ' + SGT_BaseFinder.quote(opp.Id))[0];
		insert SGT_SalesGoal.createGoalOpportunity(sg, opp);
		Test.startTest();
		SGT_Goal_Opportunity__c goalOpp = [Select Id, Sales_Goal__c from SGT_Goal_Opportunity__c where Opportunity__c =: opp.Id];
		System.assertEquals(goalOpp.Sales_Goal__c, sg.Id);
		opp.Enterprise_Service__c = 'Test Service';
		update opp;
		Test.stopTest();
		goalOpp = [Select Id, Sales_Goal__c from SGT_Goal_Opportunity__c where Opportunity__c =: opp.Id AND Sales_Goal__r.Enterprise_Service__c = 'Test Service'];
		System.assertEquals(goalOpp.Sales_Goal__c, sg2.Id);
	}

	@isTest static void testUserOpportunityAfterUpdate() {
		SGT_TestUtil.setupHttpMock();
		
		List<User> users = SGT_TestUtil.createTestUser(1);
		Opportunity opp = SGT_TestUtil.createTestOpportunity();
		List<AECOM_team__c> teams = new List<AECOM_team__c>();
		AECOM_team__c team = new AECOM_team__c(
			Employee_User__c = users[0].Id,
			Opportunity__c = opp.Id
		);
		teams.add(team);
		insert teams;

		List<SGT_Sales_Goal__c> sgs = SGT_TestUtil.createTestEmployeeSaleGoals(1, users);
		Test.startTest();
		SGT_Goal_Opportunity__c goalOpp = [Select Id, Sales_Goal__c from SGT_Goal_Opportunity__c where Opportunity__c =: opp.Id];
		System.assertEquals(goalOpp.Sales_Goal__c, sgs[0].Id);
		opp.Amount = 100000;
		update opp;
		Test.stopTest();
		goalOpp = [Select Id, Gross_AECOM_Contract_Revenue__c from SGT_Goal_Opportunity__c where Opportunity__c =: opp.Id];
		opp = [Select Id, Amount from Opportunity where Id =: opp.Id];
		System.assertEquals(100000, opp.Amount);
		System.assertEquals(100000, goalOpp.Gross_AECOM_Contract_Revenue__c);

	}

}