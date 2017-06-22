@isTest
private class ECO_ProjectCountryAlertBatchTest {
	static void init(){

		ECO_Utils_Testing.createTestDataForOrgFinder();

		CountryRisk__c cr = new CountryRisk__c (name='US' , alias__c='US');
		insert cr;
	}

	private static testMethod void TestBatchPlain(){
		
  		ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
		ECO_ProjectTriggers.run = false;
		ECO_ProjectTaskTriggers.run = false;
		init();
       	ECO_ProjectTaskTriggers.run = true;
		ECO_ProjectTriggers.run = true; 

       	String projName = 'My Test Project';
        pse__Proj__c testProject = [select id from pse__Proj__c limit 1];

		list<contact> lstCon = [select id from contact limit 2];


		list<ProjectTeamMember__c> lstPTM = new list<ProjectTeamMember__c>();
		contact con1 = lstCon[0];
		ProjectRole__c projectRole1 = [select id from ProjectRole__c where Name = 'Project Manager'];

		ProjectTeamMember__c ptm1 = new ProjectTeamMember__c(Contact__c = con1.id, Project__c = testProject.id, ProjectRole__c = projectRole1.id, StartDate__c = Date.today());
		lstPTM.add(ptm1);


		contact con2 = lstCon[1];
		ProjectRole__c projectRole = [select id from ProjectRole__c where Name = 'Resilience Director'];

		ProjectTeamMember__c ptm = new ProjectTeamMember__c(Contact__c = con2.id, Project__c = testProject.id, ProjectRole__c = projectRole.id, StartDate__c = Date.today());
		lstPTM.add(ptm);

		insert lstPTM;	

		test.starttest();

    	ApexPages.StandardController sc = new ApexPages.StandardController(testProject);        
    	ECO_ResilienceController con = new ECO_ResilienceController(sc);
        con.init();

        con.idCityID = 'US,US,US';

        con.AddCity();
        con.SaveSelectedLocations();


        

        list<ProjectCountry_Risk__c> listPCR = [select id from ProjectCountry_Risk__c];

        for(ProjectCountry_Risk__c pcr: listPCR){
        	pcr.Last_Country_Risk__c = 10;
        }

        update listPCR;


    	ECO_ProjectCountryAlertBatch c = new ECO_ProjectCountryAlertBatch();
    	Database.executeBatch(c);
    	test.stoptest();

    }


	private static testMethod void TestBatchSize(){
		

		test.starttest();


    	ECO_ProjectCountryAlertBatch c = new ECO_ProjectCountryAlertBatch(1);
    	Database.executeBatch(c);
    	test.stoptest();

    }

	/*private static testMethod void TestBatchPM(){
		
		init();
        

       	String projName = 'My Test Project';
        pse__Proj__c testProject = [select id from pse__Proj__c limit 1];

		list<contact> lstCon = [select id from contact limit 2];


		list<ProjectTeamMember__c> lstPTM = new list<ProjectTeamMember__c>();
		contact con1 = lstCon[0];
		ProjectRole__c projectRole1 = [select id from ProjectRole__c where Name = 'Project Manager'];

		ProjectTeamMember__c ptm1 = new ProjectTeamMember__c(Contact__c = con1.id, Project__c = testProject.id, ProjectRole__c = projectRole1.id);
		lstPTM.add(ptm1);


		contact con2 = lstCon[1];
		ProjectRole__c projectRole = [select id from ProjectRole__c where Name = 'Resilience Director'];

		ProjectTeamMember__c ptm = new ProjectTeamMember__c(Contact__c = con2.id, Project__c = testProject.id, ProjectRole__c = projectRole.id);
		lstPTM.add(ptm);

		insert lstPTM;	

		test.starttest();

    	ApexPages.StandardController sc = new ApexPages.StandardController(testProject);        
    	ECO_ResilienceController con = new ECO_ResilienceController(sc);
        con.init();

        con.idCityID = 'US,US,US';

        con.AddCity();
        con.SaveSelectedLocations();


        

        list<ProjectCountry_Risk__c> listPCR = [select id from ProjectCountry_Risk__c];

        for(ProjectCountry_Risk__c pcr: listPCR){
        	pcr.Last_Country_Risk__c = 10;
        }

        update listPCR;


    	ECO_ProjectCountryAlertBatch c = new ECO_ProjectCountryAlertBatch(ptm1.id);
    	Database.executeBatch(c);
    	test.stoptest();

    }*/

	private static testMethod void TestSchedule(){
		String CRON_EXP = '0 0 0 15 3 ? 2050';
		String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new ECO_ProjectCountryAlertBatch());

    }

}