/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_AECOMTeamTriggerTest
*              PURPOSE: Test class for SGT_AECOMTeamTrigger
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
@isTest
private class SGT_AECOMTeamTriggerTest {
	
	@isTest static void testAfterInsert() {
		SGT_TestUtil.setupHttpMock();

		List<User> users = SGT_TestUtil.createTestUser(1);
		List<SGT_Sales_Goal__c> salesGoals = SGT_TestUtil.createTestEmployeeSaleGoals(1, users);
		Opportunity opp = SGT_TestUtil.createTestOpportunity();
		Opportunity opp2 = SGT_TestUtil.createTestOpportunity();

		List<AECOM_team__c> teams = new List<AECOM_team__c>();
		AECOM_team__c team = new AECOM_team__c(
			Employee_User__c = users[0].Id,
			Opportunity__c = opp.Id
		);
		AECOM_team__c team2 = new AECOM_team__c(
			Employee_User__c = users[0].Id,
			Opportunity__c = opp2.Id
		);
		teams.add(team);
		teams.add(team2);
		insert teams;

		SGT_Goal_Opportunity__c goalOpp = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Opportunity__c =: opp.Id];
		System.assertEquals(opp.Id, goalOpp.Opportunity__c);
		System.assertEquals(salesGoals[0].Id, goalOpp.Sales_Goal__c);

		SGT_Goal_Opportunity__c goalOpp2 = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Opportunity__c =: opp2.Id];
		System.assertEquals(opp2.Id, goalOpp2.Opportunity__c);
		System.assertEquals(salesGoals[0].Id, goalOpp2.Sales_Goal__c);

	}

	@isTest static void testAfterDelete() {
		SGT_TestUtil.setupHttpMock();

		List<User> users = SGT_TestUtil.createTestUser(1);
		List<SGT_Sales_Goal__c> salesGoals = SGT_TestUtil.createTestEmployeeSaleGoals(1, users);
		Opportunity opp = SGT_TestUtil.createTestOpportunity();

		AECOM_team__c team = new AECOM_team__c(
			Employee_User__c = users[0].Id,
			Opportunity__c = opp.Id
		);
		insert team;

		SGT_Goal_Opportunity__c goalOpp = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Opportunity__c =: opp.Id];
		System.assertEquals(opp.Id, goalOpp.Opportunity__c);
		System.assertEquals(salesGoals[0].Id, goalOpp.Sales_Goal__c);

		delete team;

		List<SGT_Goal_Opportunity__c> goalOpps = [Select Id from SGT_Goal_Opportunity__c where Id =: goalOpp.Id];
		System.assertEquals(0, goalOpps.size());
	}

	@isTest static void testAfterUpdate() {
		SGT_TestUtil.setupHttpMock();
		
		List<User> users = SGT_TestUtil.createTestUser(2);
		List<SGT_Sales_Goal__c> salesGoals = SGT_TestUtil.createTestEmployeeSaleGoals(1, users);
		Opportunity opp = SGT_TestUtil.createTestOpportunity();
		Opportunity opp2 = SGT_TestUtil.createTestOpportunity();
		List<AECOM_team__c> teams = new List<AECOM_team__c>();
		AECOM_team__c team = new AECOM_team__c(
			Employee_User__c = users[0].Id,
			Opportunity__c = opp.Id
		);
		AECOM_team__c team2 = new AECOM_team__c(
			Employee_User__c = users[0].Id,
			Opportunity__c = opp2.Id
		);
		teams.add(team);
		teams.add(team2);
		insert teams;

		//---Let's check that the goal opportunities were made
		SGT_Goal_Opportunity__c goalOpp = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Opportunity__c =: opp.Id];
		System.assertEquals(opp.Id, goalOpp.Opportunity__c);

		SGT_Goal_Opportunity__c goalOpp2 = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Opportunity__c =: opp2.Id];
		System.assertEquals(opp2.Id, goalOpp2.Opportunity__c);

		team.Opportunity__c = opp2.Id;
		team2.Employee_User__c = users[1].Id;
		teams.clear();
		teams.add(team);
		teams.add(team2);
		update teams;

		List<SGT_Goal_Opportunity__c> oldGoalOpps = [Select Id from SGT_Goal_Opportunity__c where Id =: goalOpp.Id OR Id =: goalOpp2.Id];
		System.assertEquals(0, oldGoalOpps.size());

		List<SGT_Goal_Opportunity__c> newGoalOpps = [Select Id, Sales_Goal__c, Opportunity__c 
													from SGT_Goal_Opportunity__c 
													where Opportunity__c =: opp2.Id];
		System.assertEquals(2, newGoalOpps.size());

	}
	
	
}