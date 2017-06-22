@isTest
private class ECO_Utils_Date_Test {
	@TestSetup static void testSetup(){
		ECO_PMD_Utils_Testing.setupTestData();
	}

	@isTest static void test_static_getDateTimeFromPICRequestStatusString(){
		String dtString = '01-OCT-15 10.32.42.000000 PM UTC';
		DateTime result = ECO_Utils_Date.getDateTimeFromPICRequestStatusString(dtString);
		System.AssertEquals(DateTime.newInstanceGmt(2015, 10, 1, 22, 32, 42),result);
	}

	@isTest static void test_static_getPeriodNameFromDate(){
		
		String result = ECO_Utils_Date.getPeriodNameFromDate(Date.newInstance(2015, 1, 15));
    	System.assertEquals('JAN-15',result);
	}
	
	@isTest static void test_static_formatDateAsYYYYDashMMDashdd(){
		String result = ECO_Utils_Date.formatDateAsYYYYDashMMDashdd(Date.newInstance(2015, 1, 15));
    	System.assertEquals('2015-01-15',result);
    }
    
    @isTest static void test_static_formatDateAsMMSlashDDSlashYYYY(){
    	String result = ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(Date.newInstance(2015, 1, 15));
    	System.assertEquals('01/15/2015',result);
    }
    
   	@isTest static void test_static_getStartOfWeekDatesBetweenTwoDates(){
   		List<String> result = ECO_Utils_Date.getStartOfWeekDatesBetweenTwoDates(Date.newInstance(2016,1,7), Date.newInstance(2016,1,21));
   		System.debug(result);  // Jan 3, 10, and 17 (Sundays) mm/dd/yyyy
   		System.assertEquals(3, result.size());
   		System.assertEquals('01/03/2016',result[0]);
   		System.assertEquals('01/10/2016',result[1]);
   		System.assertEquals('01/17/2016',result[2]);
   		
	}
	
	@isTest static void test_static_calcTimePeriods_List(){
		Test.startTest();
		List<Date> enddatelist = new List<Date>();
		endDateList.add(Date.newInstance(2016,1,15));
		endDateList.add(Date.newInstance(2016,2,15));
		List<pse__Time_Period__c> tps = ECO_Utils_Date.calcTimePeriods(endDateList, 'Month');
		Test.stopTest();
		system.assertEquals(2,tps.size());
	}

  	@isTest static void test_static_calcTimePeriods_Range(){
  		Test.startTest();
		List<Date> dates = new List<Date>();
		dates.add(Date.newInstance(2016,1,15));
		dates.add(Date.newInstance(2016,2,15));
		List<pse__Time_Period__c> tps = ECO_Utils_Date.calcTimePeriods(dates[0],dates[1],'Month');
		Test.stopTest();
		system.assertEquals(2,tps.size());
	}

	@isTest static void test_static_getFiscalPeriod(){
		Test.startTest();
		List<Date> dates = new List<Date>();
		dates.add(Date.newInstance(2016,1,15));
		dates.add(Date.newInstance(2016,3,15));
		List<pse__Time_Period__c> tps = ECO_Utils_Date.calcTimePeriods(dates[0],dates[1],'Month');
		System.assertEquals(3,tps.size());
		pse__Time_Period__c tp = ECO_Utils_Date.getFiscalPeriod(dates[1],1,tps);
		Test.stopTest();
		System.assertNotEquals(null,tp);
		System.assertEquals('FY2016-05',tp.TimePeriodCode__c);
	}

    @isTest static void test_static_getProjectEffectiveDate(){

		Integer MAX_QUERY = Limits.getLimitQueries(); 
		Integer NUM_QUERY = MAX_QUERY - 1; 
		System.Debug(Limits.getLimitQueries());
    	Test.startTest();

    	System.Debug(Limits.getLimitQueries());

    	pse__Proj__c project = [SELECT id, name,
                    pse__Start_Date__c, pse__End_Date__c, RevisedStartDate__c, RevisedEndDate__c
                    from pse__proj__c LIMIT 1];
      
    	System.assertEquals(ECO_Utils_Date.getProjectEffectiveDate(project.id,'start'), project.pse__Start_Date__c);
		System.assertEquals(ECO_Utils_Date.getProjectEffectiveDate(project.id,'end'), project.pse__End_Date__c);
    	
    	Test.stopTest();
    }

    @isTest static void test_static_getProjectEffectiveDate2(){

		Test.startTest();

		System.Debug(Limits.getLimitQueries());

    	pse__Proj__c project = [SELECT id, name,
                    pse__Start_Date__c, pse__End_Date__c, RevisedStartDate__c, RevisedEndDate__c
                    from pse__proj__c LIMIT 1];
        
    	System.assertEquals(ECO_Utils_Date.getProjectEffectiveDate(project.id,'start'), project.pse__Start_Date__c);
		System.assertEquals(ECO_Utils_Date.getProjectEffectiveDate(project.id,'end'), project.pse__End_Date__c);

    	project.RevisedEndDate__c = null;
    	System.assertEquals(ECO_Utils_Date.getProjectEffectiveDate(project,'endlatest'), project.pse__End_Date__c);
    	Test.stopTest();
    }

    @isTest static void test_static_getProjectEffectiveDate3(){

    	Test.startTest();

    	System.Debug(Limits.getLimitQueries());

    	pse__Proj__c project = [SELECT id, name,
                    pse__Start_Date__c, pse__End_Date__c, RevisedStartDate__c, RevisedEndDate__c
                    from pse__proj__c LIMIT 1];
        
    	System.assertEquals(ECO_Utils_Date.getProjectEffectiveDate(project.id,'start'), project.pse__Start_Date__c);
		System.assertEquals(ECO_Utils_Date.getProjectEffectiveDate(project.id,'end'), project.pse__End_Date__c);

    	project.RevisedEndDate__c = project.pse__End_Date__c.addDays(-3);
    	System.assertEquals(ECO_Utils_Date.getProjectEffectiveDate(project,'endlatest'), project.pse__End_Date__c);
    	Test.stopTest();
    }        

    @isTest static void test_static_getProjectEffectiveDate4(){

    	Test.startTest();

    	System.Debug(Limits.getLimitQueries());

    	pse__Proj__c project = [SELECT id, name,
                    pse__Start_Date__c, pse__End_Date__c, RevisedStartDate__c, RevisedEndDate__c
                    from pse__proj__c LIMIT 1];
        
    	System.assertEquals(ECO_Utils_Date.getProjectEffectiveDate(project.id,'start'), project.pse__Start_Date__c);
		System.assertEquals(ECO_Utils_Date.getProjectEffectiveDate(project.id,'end'), project.pse__End_Date__c);

    	project.RevisedEndDate__c = project.pse__End_Date__c.addDays(3);
    	System.assertEquals(ECO_Utils_Date.getProjectEffectiveDate(project,'endlatest'), project.RevisedEndDate__c);
    	Test.stopTest();
    } 
}