/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_SalesGoalTriggerTest
*              PURPOSE: Test class for SGT_SalesGoalTrigger
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
@isTest
private class SGT_SalesGoalTriggerTest {


	@isTest static void testAfterInsert() {
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

		SGT_Sales_Goal__Share sharingRule = [Select Id, ParentId, UserOrGroupId from SGT_Sales_Goal__Share where RowCause =: Schema.SGT_Sales_Goal__Share.RowCause.Employee_Sales_Goal__c];
		System.assertEquals(users[0].Id, sharingRule.UserOrGroupId);
		System.assertEquals(salesGoals[0].Id, sharingRule.ParentId);									
	}

	@isTest static void testBusinessLineAfterInsert() {
		SGT_TestUtil.setupHttpMock();

		SGT_OpportunityAsyncGoalCalc.suppressCalc = true; // Prevent async opportunity goal calc from running as this was creating duplicates in this test method

		Opportunity opp = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 1, 1));

		Opportunity opp2 = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 1, 1));
		opp2.Enterprise_Service__c = 'Consulting';
		update opp2;

		Opportunity opp3 = SGT_TestUtil.createTestOpportunity(Date.newInstance(2018, 1, 1));

		Test.startTest();

		SGT_Sales_Goal__c sg = SGT_TestUtil.createTestBusinessLineSalesGoal();

		Test.stopTest();

		System.debug(LoggingLevel.ERROR, 'Opp Ids: ' + opp.Id + '|' + opp2.Id + '|' + opp3.Id);


		List<SGT_Goal_Opportunity__c> goalOpps = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c];

        for (SGT_Goal_Opportunity__c goalOpp : goalOpps) {
        	System.debug(LoggingLevel.ERROR, 'Id: ' + goalOpp.Id + ' | GoalOpp Opp Id: ' + goalOpp.Opportunity__c);
        }


		System.assertEquals(1, goalOpps.size(), 'Should only have created one goal opp');

		System.assertEquals(opp.Id, goalOpps[0].Opportunity__c);
		System.assertEquals(sg.Id, goalOpps[0].Sales_Goal__c);		
	}

	@isTest static void testUserAfterUpdate() {
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
		SGT_Sales_Goal__Share sharingRule = [Select Id, ParentId, UserOrGroupId from SGT_Sales_Goal__Share 
											where RowCause =: Schema.SGT_Sales_Goal__Share.RowCause.Employee_Sales_Goal__c
												AND ParentId =: salesGoals[0].Id];
		System.assertEquals(users[0].Id, sharingRule.UserOrGroupId);
		System.assertEquals(salesGoals[0].Id, sharingRule.ParentId);									
		SGT_Goal_Opportunity__c goalOpp = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Sales_Goal__r.User__c =: users[0].Id];
		for(SGT_Sales_Goal__c salesGoal : salesGoals) {
			if(salesGoal.User__c == users[0].Id) {
				salesGoal.User__c = users[1].Id;
			}
		}
		update salesGoals;

		List<SGT_Goal_Opportunity__c> oldGoalOpp = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Sales_Goal__r.User__c =: users[0].Id];
		System.assertEquals(0, oldGoalOpp.size());

		List<SGT_Goal_Opportunity__c> newGoalOpp = [Select Id, Sales_Goal__c, Opportunity__c 
											from SGT_Goal_Opportunity__c 
											where Sales_Goal__r.User__c =: users[1].Id];
		System.assertEquals(2, newGoalOpp.size(), 'Should include users[0] and existing Sales Goals');

		sharingRule = [Select Id, ParentId, UserOrGroupId from SGT_Sales_Goal__Share 
						where RowCause =: Schema.SGT_Sales_Goal__Share.RowCause.Employee_Sales_Goal__c
							AND ParentId =: salesGoals[0].Id];
		System.assertEquals(users[1].Id, sharingRule.UserOrGroupId);
		System.assertEquals(salesGoals[0].Id, sharingRule.ParentId);									
	}

	@isTest static void testBusinessLineAfterUpdate() {
		SGT_TestUtil.setupHttpMock();

		SGT_OpportunityAsyncGoalCalc.suppressCalc = true;

		Opportunity opp = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 1, 1));
		Opportunity opp2 = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 1, 1));
		Opportunity opp3 = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 1, 1));
		opp3.Enterprise_Service__c = 'Test Service';
		update opp3;

		
		SGT_Sales_Goal__c salesGoal = SGT_TestUtil.createTestBusinessLineSalesGoal();

		Test.startTest();
		salesGoal.Enterprise_Service__c = 'Test Service';
		update salesGoal;
		Test.stopTest();

		List<SGT_Goal_Opportunity__c> goalOpps = [Select Id, Opportunity__c from SGT_Goal_Opportunity__c where Sales_Goal__c =: salesGoal.Id];

		System.assertEquals(1, goalOpps.size());
		System.assertEquals(opp3.Id, goalOpps[0].Opportunity__c);
	}

	@isTest static void testFilterCheck() {
		SGT_TestUtil.setupHttpMock();

		SGT_Sales_Goal__c salesGoal = SGT_TestUtil.createTestBusinessLineSalesGoal();
		salesGoal.Region__c = 'EMEA';

		try {
			update salesGoal;
		} catch (Exception e) {
			System.assert(e.getMessage().contains('You can associate only one of the following categories with the sales goal record: ' + 
										'AECOM Work, Enterprise Service, End-Client Sector, Client Subgroup, Geographic, Project Delivery Method, ' +
										'or Hierarchy Group.'));
		}
	}
	
}