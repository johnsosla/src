/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_TestUtil
*              PURPOSE: Provide test objects for various test classes
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
//@isTest
public class SGT_TestUtil {
	private static Map<String, Schema.RecordTypeInfo> mRtInfo = SGT_Sales_Goal__c.SObjectType.getDescribe().getRecordTypeInfosByName();

	public static Account createTestAccount() {
		Account newAccount = new Account(
			Name = 'Test Account'
		);
		insert newAccount;
		return newAccount;
	}

	public static Opportunity createTestOpportunity() {
		return createTestOpportunity(Date.today());
	}

	private static AECOM_Primary_Department__c department;

	public static Opportunity createTestOpportunity(Date closeDate) {
		if (department == null) {
			department = new AECOM_Primary_Department__c(
				Name = 'Test Department',
				Group_Division__c = 'DCS',
				Operating_Group__c = 'Americas'
			);

			insert department;
		}

		Opportunity opp = new Opportunity(
			Name = 'TestOpp',
			StageName = '1 Lead',
			AccountId = createTestAccount().Id,
			TO_Procurement_Method__c = 'Test Method',
			Enterprise_Service__c = 'Asset Management',
			CloseDate = closeDate,
			Estimated_work_start_date__c = closeDate.addDays(90),
			AECOM_Primary_Dept_Lookup__c = department.Id
		);
		insert opp;
		return opp;
	}

	public static SGT_Sales_Goal__c createTestBusinessLineSalesGoal() {
		SGT_Sales_Goal__c goal = new SGT_Sales_Goal__c(
			Name = 'Test Sales Goal',
			Bookings_Goal__c = 10000,
			Enterprise_Service__c = 'Asset Management;Architecture',
			RecordTypeId = mRtInfo.get(SGT_SalesGoalTriggerHandler.RT_BUSINESS_LINE).getRecordTypeId(),
			Fiscal_Year__c = '2016',
			Fiscal_Year_Start__c = Date.newInstance(2016, 1, 1),
			Fiscal_Year_End__c = Date.newInstance(2016, 12, 31),
			Operating_Group__c = 'Americas'
		);

		insert goal;

		return goal;
	}

	public static SGT_SalesGoal createTestBusinessLineSalesGoalWithCriteria() {
		SGT_SalesGoal goal = new SGT_SalesGoal(createTestBusinessLineSalesGoal());

		List<SGT_LogicRow> logicRows = new List<SGT_LogicRow>();
		logicRows.add(new SGT_LogicRow(1, 'Enterprise_Service__c', SGT_LogicRow.OP_EQUALS, 'Asset Management;Architecture'));

		goal.updateCriteria(logicRows, false, null);

		goal.save();

		return goal;
	}

		public static SGT_SalesGoal createTestBusinessLineSalesGoalWithComplexCriteria() {
		SGT_SalesGoal goal = new SGT_SalesGoal(createTestBusinessLineSalesGoal());

		List<SGT_LogicRow> logicRows = new List<SGT_LogicRow>();
		logicRows.add(new SGT_LogicRow(1, 'Enterprise_Service__c', SGT_LogicRow.OP_EQUALS, 'Asset Management'));
		logicRows.add(new SGT_LogicRow(2, 'Enterprise_Service__c', SGT_LogicRow.OP_EQUALS, 'Architecture'));
		logicRows.add(new SGT_LogicRow(3, 'Enterprise_Service__c', SGT_LogicRow.OP_NOTEQUAL, 'Economics'));

		goal.updateCriteria(logicRows, true, '(1 OR 2) AND 3');

		goal.save();

		return goal;
	}

	public static List<SGT_Sales_Goal__c> createTestEmployeeSaleGoals(Integer numOfSaleGoals, List<User> users) {
		List<SGT_Sales_Goal__c> newGoals = new List<SGT_Sales_Goal__c>();
		for(Integer i = 0; i < numOfSaleGoals; i++) {
			for(User user : users) {
				SGT_Sales_Goal__c goal = new SGT_Sales_Goal__c(
					Name = 'Test Sales Goal',
					User__c = user.Id,
					Bookings_Goal__c = 10000,
					Operating_Group__c = null,
					Fiscal_Year__c = '2016',
					RecordTypeId = mRtInfo.get(SGT_SalesGoalTriggerHandler.RT_EMPLOYEE).getRecordTypeId()
				);
				newGoals.add(goal);
			}
		}
		insert newGoals;
		return newGoals;
	}

	public static List<User> createTestUser(Integer numOfUsers) {
		Profile adminProfile = [Select Id, Name from Profile where Name = 'AECOM Standard User - Americas'];
		List<User> userList = new List<User>();
		for (Integer i = 0; i < numOfUsers; i++) {
			User tempUser = new User();
			tempUser.FirstName = 'test';
			tempUser.LastName = 'lastName' + String.ValueOf(i);
			tempUser.Alias = 'test'+String.ValueOf(i);
			tempUser.Email = 'SFDCTestCase' + String.ValueOf(i) + '@aecom.com';
			tempUser.Username ='111111@test.com'+String.ValueOf(i);
			tempUser.CommunityNickname = 'testNick'+String.ValueOf(i);
			tempUser.ProfileId = adminProfile.Id;
			tempUser.EmailEncodingKey='UTF-8';
			tempUser.LanguageLocaleKey='en_US';
			tempUser.LocaleSidKey='en_US';
			tempUser.TimeZoneSidKey='America/Los_Angeles';
			tempUser.IsActive = true;
			userList.add(tempUser);
		}
		insert userList;
		return userList;
	}

	public static void setupHttpMock() {
		Test.setMock(HttpCalloutMock.class, new OpportunityServiceMockImpl());
	}

	public class OpportunityServiceMockImpl implements HttpCalloutMock {
		// For ESB_OpportunityServiceBusCallout class which calls out on opportunity insert
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(204);
            return res;
        }
    }

    public class StopWatch {

    	private Integer startTime = -1;

    	public StopWatch() {

    	}

    	public void start() {
    		startTime = Limits.getCpuTime();
    	}

    	public void reset() {
    		startTime = -1;
    	}

    	public Integer getElapsed() {
    		return Limits.getCpuTime() - startTime;
    	}

    	public void stamp(String msg) {
    		System.debug(LoggingLevel.DEBUG, '### ' + msg + ' -- ' + getElapsed());
    	}

    }
	
}