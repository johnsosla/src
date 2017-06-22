/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_OpportunityMatching_Test
*              PURPOSE: Test class for SGT_OpportunityMatching
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
@isTest
private class SGT_OpportunityMatching_Test
{
	@isTest
	static void testQueryString()
	{
		SGT_Sales_Goal__c sg = SGT_TestUtil.createTestBusinessLineSalesGoal();

		String queryStr = SGT_OpportunityMatching.getOpportunityQuerySoqlForSalesGoal(sg);

		System.assertNotEquals(0, queryStr.length());


		try {
			Database.query('SELECT Id FROM Opportunity WHERE ' + queryStr);
		}
		catch (Exception e) {
			System.assert(false, 'Should not have encountered an error while querying for Opportunities: ' + e.getMessage() + ' -- ' + e.getStackTraceString());
		}
	}

	@isTest
	static void testInMemoryMatch()
	{
		SGT_TestUtil.setupHttpMock();
		
		Opportunity o = SGT_TestUtil.createTestOpportunity();
		SGT_Sales_Goal__c sg = SGT_TestUtil.createTestBusinessLineSalesGoal();

		Boolean isOpportunityMatch = SGT_OpportunityMatching.isOpportunityMatch(new SGT_SalesGoal(sg), new SGT_Opportunity(o));

	}


	@isTest
	static void testCriteriaQueryString()
	{
		Opportunity o = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 5, 1));
		Opportunity o2 = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 5, 1));
		o2.Enterprise_Service__c = 'Economics';
		update o2;


		SGT_SalesGoal sg = SGT_TestUtil.createTestBusinessLineSalesGoalWithCriteria();

		Test.startTest();

		 String queryStr = SGT_Opportunity.find.getQueryStringForSalesGoals(new List<SGT_SalesGoal> {sg});

		 List<Opportunity> Opportunities = Database.query(queryStr);

		Test.stopTest();

		System.assertEquals(1, Opportunities.size());


	}

	@isTest
	static void testCriteriaMatch() 
	{
		Opportunity o = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 5, 1));
		SGT_SalesGoal sg = SGT_TestUtil.createTestBusinessLineSalesGoalWithCriteria();

		// Re-query to get lookup field relationship values
		o = SGT_Opportunity.find.findByIdSet(new Set<Id> {o.Id })[0];

		Boolean isOpportunityMatch = SGT_OpportunityMatching.isOpportunityMatch(sg, new SGT_Opportunity(o));

		System.assert(isOpportunityMatch, 'Opportunity should match on Enterprise_Service__c value');

		o.Enterprise_Service__c = 'Economics';
		isOpportunityMatch = SGT_OpportunityMatching.isOpportunityMatch(sg, new SGT_Opportunity(o));

		System.assert(!isOpportunityMatch, 'Opportunity should not match on Enterprise_Service__c value');
	}

	@isTest
	static void testComplexCriteriaQueryString() 
	{
		Opportunity o = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 5, 1));
		Opportunity o2 = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 5, 1));
		o2.Enterprise_Service__c = 'Economics';
		update o2;


		SGT_SalesGoal sg = SGT_TestUtil.createTestBusinessLineSalesGoalWithComplexCriteria();

		Test.startTest();

		String queryStr = SGT_Opportunity.find.getQueryStringForSalesGoals(new List<SGT_SalesGoal> {sg});

		List<Opportunity> Opportunities = Database.query(queryStr);

		Test.stopTest();

		System.assertEquals(1, Opportunities.size());
	}

	@isTest
	static void testComplexCriteriaInMemoryMatch()
	{
		Opportunity o = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 5, 1));
		Opportunity o2 = SGT_TestUtil.createTestOpportunity(Date.newInstance(2016, 5, 1));
		o2.Enterprise_Service__c = 'Economics';
		update o2;

		// Re-query to get lookup relationship fields
		o = SGT_Opportunity.find.findByIdSet(new Set<Id> {o.Id })[0];
		o2 = SGT_Opportunity.find.findByIdSet(new Set<Id> {o2.Id })[0];

		SGT_SalesGoal sg = SGT_TestUtil.createTestBusinessLineSalesGoalWithComplexCriteria();

		Test.startTest();

		Boolean isOpportunityMatch = SGT_OpportunityMatching.isOpportunityMatch(sg, new SGT_Opportunity(o));

		System.assert(isOpportunityMatch, 'First Opportunity should match');

		isOpportunityMatch = SGT_OpportunityMatching.isOpportunityMatch(sg, new SGT_Opportunity(o2));

		System.assert(!isOpportunityMatch, 'Second Opportunity should NOT match, because it is Economics Enterprise Service');

		Test.stopTest();
	}
}