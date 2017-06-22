/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_AllSalesGoalRecalcTest
*              PURPOSE: Test class for SGT_AllSalesGoalRecalculationController/
*						Batch class
*              CREATED: 07/2016 Ethos Solutions - www.ethos.com
**/
@isTest
private class SGT_AllSalesGoalRecalcTest {
	
	@isTest static void testSingleRecalculation() {
		SGT_TestUtil.setupHttpMock();

		List<User> users = SGT_TestUtil.createTestUser(1);
		Opportunity opp = SGT_TestUtil.createTestOpportunity();
		AECOM_team__c team = new AECOM_team__c(
			Employee_User__c = users[0].Id,
			Opportunity__c = opp.Id
		);
		insert team;

		List<SGT_Sales_Goal__c> salesGoals = SGT_TestUtil.createTestEmployeeSaleGoals(1, users);
		SGT_Goal_Opportunity__c goalOpp = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Opportunity__c =: opp.Id];
		System.assertEquals(opp.Id, goalOpp.Opportunity__c);
		System.assertEquals(salesGoals[0].Id, goalOpp.Sales_Goal__c);

		Test.startTest();
		ApexPages.StandardController std = new ApexPages.StandardController(salesGoals[0]);
		SGT_AllSalesGoalRecalculationController cont = new SGT_AllSalesGoalRecalculationController(std);
		cont.recalculateSpecificSalesGoal();
		Test.stopTest();

		SGT_Goal_Opportunity__c goalOpp2 = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Opportunity__c =: opp.Id];
		System.assertNotEquals(goalOpp.Id, goalOpp2.Id);
		System.assertEquals(opp.Id, goalOpp2.Opportunity__c);
		System.assertEquals(salesGoals[0].Id, goalOpp2.Sales_Goal__c);

	}

	@isTest static void testAllSaleGoalsRecalculation() {
		SGT_TestUtil.setupHttpMock();
		
		List<User> users = SGT_TestUtil.createTestUser(2);
		Opportunity opp = SGT_TestUtil.createTestOpportunity();
		List<AECOM_team__c> teams = new List<AECOM_team__c>();
		AECOM_team__c team = new AECOM_team__c(
			Employee_User__c = users[0].Id,
			Opportunity__c = opp.Id
		);
		AECOM_team__c team2 = new AECOM_team__c(
			Employee_User__c = users[1].Id,
			Opportunity__c = opp.Id
		);
		teams.add(team);
		teams.add(team2);
		insert teams;

		List<SGT_Sales_Goal__c> salesGoals = SGT_TestUtil.createTestEmployeeSaleGoals(1, users);
		SGT_Goal_Opportunity__c oldGoalOpp = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Sales_Goal__r.User__c =: users[0].Id];
		SGT_Goal_Opportunity__c oldGoalOpp2 = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Sales_Goal__r.User__c =: users[0].Id];
		Test.startTest();
		ApexPages.StandardSetController std = new ApexPages.StandardSetController(new List<SGT_Sales_Goal__c>());
		SGT_AllSalesGoalRecalculationController cont = new SGT_AllSalesGoalRecalculationController(std);
		cont.recalculateAllSalesGoals();
		Test.stopTest();
		SGT_Goal_Opportunity__c newGoalOpp = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Sales_Goal__r.User__c =: users[0].Id];
		SGT_Goal_Opportunity__c newGoalOpp2 = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Sales_Goal__r.User__c =: users[0].Id];
		System.assertNotEquals(oldGoalOpp.Id, newGoalOpp.Id);
		System.assertEquals(salesGoals[0].Id, newGoalOpp.Sales_Goal__c);
		System.assertEquals(opp.Id, newGoalOpp.Opportunity__c);

		System.assertNotEquals(oldGoalOpp2.Id, newGoalOpp2.Id);
		System.assertEquals(salesGoals[0].Id, newGoalOpp2.Sales_Goal__c);
		System.assertEquals(opp.Id, newGoalOpp2.Opportunity__c);
		
	}
	
	
}