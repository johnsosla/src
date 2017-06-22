@isTest
private class INC_Matching_Service_Test
{
 
	@isTest
	static void TestSingleAssignment()
	{
		ECO_TriggerSettings__c setting = new ECO_TriggerSettings__c();
        setting.Name = 'INC_IncentiveProject_AllEvents';
        setting.isEnabled__c = true;
        insert setting;

        ECO_TriggerSettings__c setting2 = new ECO_TriggerSettings__c();
        setting2.Name = 'INC_EnrollmentPlan_AllEvents';
        setting2.isEnabled__c = true;
        insert setting2;

		list<User> lusers = new list<User>();
		User runningUser = INC_Utils_Testing.createUser();
		User DTWAdminWater = INC_Utils_Testing.createUser();
		DTWAdminWater.UserName = DTWAdminWater.userName + '2';
		DTWAdminWater.CommunityNickname = DTWAdminWater.CommunityNickname + '2';
        DTWAdminWater.FederationIdentifier = DTWAdminWater.FederationIdentifier + '2';
        DTWAdminWater.OracleEmployeeId__c = DTWAdminWater.OracleEmployeeId__c + '2';
        DTWAdminWater.TrackingID__c = DTWAdminWater.TrackingID__c + '2';
        DTWAdminWater.URS_FIM_GUID__c = DTWAdminWater.URS_FIM_GUID__c + '2';
		DTWAdminWater.Email = '2' + DTWAdminWater.Email;
		User DTWAdminTest = INC_Utils_Testing.createUser();
		DTWAdminTest.UserName = DTWAdminTest.userName + '3';
		DTWAdminTest.CommunityNickname = DTWAdminTest.CommunityNickname + '3';
        DTWAdminTest.FederationIdentifier = DTWAdminTest.FederationIdentifier + '3';
        DTWAdminTest.OracleEmployeeId__c = DTWAdminTest.OracleEmployeeId__c + '3';
        DTWAdminTest.TrackingID__c = DTWAdminTest.TrackingID__c + '3';
        DTWAdminTest.URS_FIM_GUID__c = DTWAdminTest.URS_FIM_GUID__c + '3';
		DTWAdminTest.Email = '3' + DTWAdminTest.Email;
		lUsers.add(runningUser);
		lUsers.add(DTWAdminWater);
		lUsers.add(DTWAdminTest);
		System.Debug(logginglevel.error,'ru ' + runningUser.CommunityNickname);
		System.Debug(logginglevel.error,'DTWAdminWater ' + DTWAdminWater.CommunityNickname);
		System.Debug(logginglevel.error,'DTWAdminTest ' + DTWAdminTest.CommunityNickname);
		insert lUsers;

		map<String,User> mUsers = new map<String,User>();
		mUsers.put('Approver1', lUsers[0]);
        mUsers.put('Approver2', lUsers[0]);
        mUsers.put('Approver3', lUsers[0]);
        mUsers.put('DTW Admin', lUsers[0]);

		list<OrganizationString__c> lOrgStrings = new list<OrganizationString__c>();
		lOrgStrings = INC_Utils_Testing.createOrganizationString();
		insert lOrgStrings;
		OrganizationString__c Org1;
		OrganizationString__c Org2;
		for(OrganizationString__c org: lOrgStrings){
			if(org.OrganizationName__c == 'Water Organization'){
				Org2 = org;
			}else{
				Org1 = org;
			}
		}
		System.Debug(logginglevel.error,'Org 2 ' + Org2);
		System.Debug(logginglevel.error,'Org 1 ' + Org1);
		//routing members
		Group publicGroup = INC_Utils_Testing.createPublicGroup('Southeast');
		insert publicGroup;
		list<RoutingMember__c> lRouting = new list<RoutingMember__c>();
		RoutingMember__c DefaultRout = INC_Utils_Testing.createRoutingMemberRules(mUsers).get('LA Metro');
		DefaultRout.GeographyDescription__c = 'Water Geo';
		DefaultRout.DTW_Approver_Group__c = 'Southeast';

		lRouting.add(DefaultRout);
		RoutingMember__c DTWAdminActualWater = INC_Utils_Testing.createRoutingMemberRules(mUsers).get('LA Metro');
		DTWAdminActualWater.GeographyDescription__c = Org2.GeographyName__c;
		DTWAdminActualWater.RegionDescription__c = Org2.Region__c;
		DTWAdminActualWater.EndMarket__c = Org2.BusinessLineName__c;
		DTWAdminActualWater.DistrictDescription__c = Org2.District__c;
		DTWAdminActualWater.DTW_Approver_Group__c = 'Southeast';
		DTWAdminActualWater.Approver1__c = DTWAdminWater.ID;

		lRouting.Add(DTWAdminActualWater);
	
		RoutingMember__c  TestingRouting = INC_Utils_Testing.createRoutingMemberRules(mUsers).get('LA Metro');
		TestingRouting.GeographyDescription__c = Org1.GeographyName__c;
		TestingRouting.RegionDescription__c = Org1.Region__c;
		TestingRouting.EndMarket__c = Org1.BusinessLineName__c;
		TestingRouting.DistrictDescription__c = Org1.District__c;
		TestingRouting.DTW_Approver_Group__c = 'Southeast';
		TestingRouting.Approver1__c = DTWAdminTest.ID;

		lRouting.add(TestingRouting);
		insert lRouting;
		
		System.Debug(logginglevel.error,' DTWAdminWater: ' + DTWAdminWater.id);

		System.Debug(logginglevel.error,' DTWAdminActualWater: ' + DTWAdminActualWater.DTWAdmin__c);


		IncentiveProject__c WaterProject = INC_Utils_Testing.createIncentiveProject();
		WaterProject.GeographyDescription__c = DTWAdminActualWater.GeographyDescription__c;
		WaterProject.RegionDescription__c = DTWAdminActualWater.RegionDescription__c;
		WaterProject.EndMarket__c = DTWAdminActualWater.EndMarket__c;
		WaterProject.DistrictDescription__c = DTWAdminActualWater.DistrictDescription__c;
		WaterProject.OrgCarryingOutProject__c = Org2.Name;
		IncentiveProject__c WaterProject2;
		Test.startTest();
		
		System.RunAs(DTWAdminTest){
		  insert WaterProject;
		  INC_FindDTWAdminForNewIncentiveProjects batch = new INC_FindDTWAdminForNewIncentiveProjects();
		  database.executebatch(batch);
		 TestingRouting.GlobalDefault__c = true;
		 update TestingRouting;
		} 
		/*
		System.RunAs(DTWAdminTest){
		 WaterProject2 = INC_Utils_Testing.createIncentiveProject();
		 WaterProject2.OwnerID = runningUser.id;
		 TestingRouting.OwnerID = DTWAdminTest.id;
		 insert WaterProject2;
		  INC_FindDTWAdminForNewIncentiveProjects batch2 = new INC_FindDTWAdminForNewIncentiveProjects();
		  database.executebatch(batch2);
		}*/
		
		Test.stopTest();
		//WaterProject = [Select ID, DTWAdmin__c,OrgCarryingOutProject__c From IncentiveProject__c where id=: WaterProject.id];
		//  System.Assert(WaterProject.DTWAdmin__c == DTWAdminTest.ID,'DTWAdminTest should be : ' + DTWAdminTest.ID + ' not:' + WaterProject.DTWAdmin__c);
		//WaterProject2 = [Select ID, DTWAdmin__c,OrgCarryingOutProject__c,OwnerID From IncentiveProject__c where id=: WaterProject2.id];
		  //System.Assert(WaterProject2.OwnerID == DTWAdminTest.ID,'OwnerID should be : ' + DTWAdminTest.ID + ' not:' + WaterProject2.OwnerID);
	} 

	@isTest
	static void testPointMatching(){
		ECO_TriggerSettings__c setting = new ECO_TriggerSettings__c();
        setting.Name = 'INC_IncentiveProject_AllEvents';
        setting.isEnabled__c = true;
        insert setting;

        ECO_TriggerSettings__c setting2 = new ECO_TriggerSettings__c();
        setting2.Name = 'INC_EnrollmentPlan_AllEvents';
        setting2.isEnabled__c = true;
        insert setting2;

		list<User> lusers = new list<User>();
		User runningUser = INC_Utils_Testing.createUser();
		User DTWAdminWater = INC_Utils_Testing.createUser();
		User DTWAdminWater2 = INC_Utils_Testing.createUser();
		User DTWAdminTest = INC_Utils_Testing.createUser();
	
		runningUser.CommunityNickname = 'Nick1';

		DTWAdminWater.userName = DTWAdminWater.userName + '2';
		DTWAdminWater.CommunityNickname = 'nick223r2423';
        DTWAdminWater.FederationIdentifier = DTWAdminWater.FederationIdentifier + '2';
        DTWAdminWater.OracleEmployeeId__c = DTWAdminWater.OracleEmployeeId__c + '2';
        DTWAdminWater.TrackingID__c = DTWAdminWater.TrackingID__c + '2';
        DTWAdminWater.URS_FIM_GUID__c = DTWAdminWater.URS_FIM_GUID__c + '2';
		DTWAdminWater.Email = '2' + DTWAdminWater.Email;
	
		DTWAdminTest.userName = DTWAdminTest.userName + '3';
		DTWAdminTest.CommunityNickname = 'nick31234124';
        DTWAdminTest.FederationIdentifier = DTWAdminTest.FederationIdentifier + '3';
        DTWAdminTest.OracleEmployeeId__c = DTWAdminTest.OracleEmployeeId__c + '3';
        DTWAdminTest.TrackingID__c = DTWAdminTest.TrackingID__c + '3';
        DTWAdminTest.URS_FIM_GUID__c = DTWAdminTest.URS_FIM_GUID__c + '3';
		DTWAdminTest.Email = '3' + DTWAdminTest.Email;
	
		DTWAdminWater2.userName = DTWAdminWater2.userName + '4';
		DTWAdminWater2.CommunityNickname = 'nick414312';
        DTWAdminWater2.FederationIdentifier = DTWAdminWater2.FederationIdentifier + '4';
        DTWAdminWater2.OracleEmployeeId__c = DTWAdminWater2.OracleEmployeeId__c + '4';
        DTWAdminWater2.TrackingID__c = DTWAdminWater2.TrackingID__c + '4';
        DTWAdminWater2.URS_FIM_GUID__c = DTWAdminWater2.URS_FIM_GUID__c + '4';
		DTWAdminWater2.Email = '4' + DTWAdminWater2.Email;
		lUsers.add(runningUser);
		lUsers.add(DTWAdminWater);
		lUsers.add(DTWAdminTest);
		lUsers.add(DTWAdminWater2);
		
		insert lUsers;

		List<OrganizationString__c> lOrgStrings = new List<OrganizationString__c>();
		OrganizationString__c Org1 = INC_Utils_Testing.createTestOrg();
		OrganizationString__c Org2 = INC_Utils_Testing.createTestOrg();
		Org1.Name = Org1.OrganizationName__c;
		Org1.Region__c = 'Test Region';

		Org2.OrganizationName__c = 'Water Organization';
		Org2.Name = 'Water Organization';
		Org2.BusinessLineName__c = 'Water';
		Org2.Department__c = 'Water Department';
		Org2.District__c = 'Water District';
		Org2.Description__c = 'Water org string';
		Org2.GeographyName__c = 'Water Geo';
		Org2.Region__c = 'Water Region';
		Org2.OrgID__c = '227';
		Org2.OUID__c = '999';

		lOrgStrings.add(Org1);
		lOrgStrings.add(Org2);
		insert lOrgStrings;

		//routing members
		list<RoutingMember__c> lRouting = new list<RoutingMember__c>();
		RoutingMember__c DefaultRout = INC_Utils_Testing.CreateRoutingMember(runningUser);
		DefaultRout.GeographyDescription__c = 'Water Geo';
		lRouting.add(DefaultRout);
		RoutingMember__c DTWAdminActualWater = INC_Utils_Testing.CreateRoutingMember(DTWAdminWater);
		DTWAdminActualWater.GeographyDescription__c = Org2.GeographyName__c;
		DTWAdminActualWater.EndMarket__c = Org2.BusinessLineName__c;
		DTWAdminActualWater.DistrictDescription__c = Org2.District__c;
	
		lRouting.Add(DTWAdminActualWater);

		RoutingMember__c DTWAdminActualWater2 = INC_Utils_Testing.CreateRoutingMember(DTWAdminWater2);
		DTWAdminActualWater2.GeographyDescription__c = Org2.GeographyName__c;
		DTWAdminActualWater2.RegionDescription__c = Org2.Region__c;
		DTWAdminActualWater2.DistrictDescription__c = Org2.District__c;
	
		lRouting.Add(DTWAdminActualWater2);

		RoutingMember__c  TestingRouting = INC_Utils_Testing.createRoutingMember(DTWAdminTest);
		TestingRouting.GeographyDescription__c = Org1.GeographyName__c;
		TestingRouting.RegionDescription__c = Org1.Region__c;
		TestingRouting.EndMarket__c = Org1.BusinessLineName__c;
		TestingRouting.DistrictDescription__c = Org1.District__c;
		
		RoutingMember__c GlobalDefault = INC_Utils_Testing.createRoutingMember(DTWAdminTest);
		GlobalDefault.GlobalDefault__c = true;
		insert GlobalDefault;

		lRouting.add(TestingRouting);
		insert lRouting;

		IncentiveProject__c WaterProject = INC_Utils_Testing.createIncentiveProject();
		WaterProject.GeographyDescription__c = DTWAdminActualWater.GeographyDescription__c;
		WaterProject.RegionDescription__c = DTWAdminActualWater.RegionDescription__c;
		WaterProject.EndMarket__c = DTWAdminActualWater.EndMarket__c;
		WaterProject.DistrictDescription__c = DTWAdminActualWater.DistrictDescription__c;
		WaterProject.OrgCarryingOutProject__c = Org2.Name;
	
		IncentiveProject__c TestProject = INC_Utils_Testing.createIncentiveProject();
		TestProject.GeographyDescription__c = TestingRouting.GeographyDescription__c;
		TestProject.RegionDescription__c = TestingRouting.RegionDescription__c;
		TestProject.EndMarket__c = TestingRouting.EndMarket__c;
		TestProject.DistrictDescription__c = TestingRouting.DistrictDescription__c;
		TestProject.OrgCarryingOutProject__c = Org1.Name;

		Test.startTest();
		System.RunAs(DTWAdminWater2){
		  	insert WaterProject;
		  	INC_FindDTWAdminForNewIncentiveProjects batch = new INC_FindDTWAdminForNewIncentiveProjects();
		  	database.executebatch(batch);
		  } 
		System.RunAs(DTWAdminTest){
		  	insert TestProject;
		  	INC_FindDTWAdminForNewIncentiveProjects batch2 = new INC_FindDTWAdminForNewIncentiveProjects();
		  	database.executebatch(batch2); 
		  }
		Test.stopTest();
		  WaterProject = [Select ID, DTWAdmin__c From IncentiveProject__c where id=: WaterProject.id];
		  System.Assert(WaterProject.DTWAdmin__c == DTWAdminWater2.ID,'DTWAdmin should be : ' + DTWAdminWater2.ID + ' not:' + WaterProject.DTWAdmin__c);
		  TestProject = [Select ID, DTWAdmin__c From IncentiveProject__c where id=: TestProject.id];
		  System.Assert(TestProject.DTWAdmin__c == DTWAdminTest.ID,'DTWAdminTest should be Test: ' + DTWAdminTest.ID + ' not:' + TestProject.DTWAdmin__c);
		
	} 

	@isTest
	static void testBulkInsert(){
		ECO_TriggerSettings__c setting = new ECO_TriggerSettings__c();
        setting.Name = 'INC_IncentiveProject_AllEvents';
        setting.isEnabled__c = true;
        insert setting;

        ECO_TriggerSettings__c setting2 = new ECO_TriggerSettings__c();
        setting2.Name = 'INC_EnrollmentPlan_AllEvents';
        setting2.isEnabled__c = true;
        insert setting2;

		list<User> lusers = new list<User>();
		User runningUser = INC_Utils_Testing.createUser();
		User DTWAdminWater = INC_Utils_Testing.createUser();
		
		DTWAdminWater.userName = DTWAdminWater.userName + '2';
		DTWAdminWater.CommunityNickname = DTWAdminWater.CommunityNickname + '2';
        DTWAdminWater.FederationIdentifier = DTWAdminWater.FederationIdentifier + '2';
        DTWAdminWater.OracleEmployeeId__c = DTWAdminWater.OracleEmployeeId__c + '2';
        DTWAdminWater.TrackingID__c = DTWAdminWater.TrackingID__c + '2';
        DTWAdminWater.URS_FIM_GUID__c = DTWAdminWater.URS_FIM_GUID__c + '2';
		DTWAdminWater.Email = '2' + DTWAdminWater.Email;
		
		User DTWAdminTest = INC_Utils_Testing.createUser();
		DTWAdminTest.userName = DTWAdminTest.userName + '3';
		DTWAdminTest.CommunityNickname = DTWAdminTest.CommunityNickname + '3';
        DTWAdminTest.FederationIdentifier = DTWAdminTest.FederationIdentifier + '3';
        DTWAdminTest.OracleEmployeeId__c = DTWAdminTest.OracleEmployeeId__c + '3';
        DTWAdminTest.TrackingID__c = DTWAdminTest.TrackingID__c + '3';
        DTWAdminTest.URS_FIM_GUID__c = DTWAdminTest.URS_FIM_GUID__c + '3';
		DTWAdminTest.Email = '3' + DTWAdminTest.Email;
		lUsers.add(runningUser);
		lUsers.add(DTWAdminWater);
		lUsers.add(DTWAdminTest);
		insert lUsers;

		List<OrganizationString__c> lOrgStrings = new List<OrganizationString__c>();
		OrganizationString__c Org1 = INC_Utils_Testing.createTestOrg();
		OrganizationString__c Org2 = INC_Utils_Testing.createTestOrg();
		Org1.Name = Org1.OrganizationName__c;
		Org1.Region__c = 'Test Region';

		Org2.OrganizationName__c = 'Water Organization';
		Org2.Name = 'Water Organization';
		Org2.BusinessLineName__c = 'Water';
		Org2.Department__c = 'Water Department';
		Org2.District__c = 'Water District';
		Org2.Description__c = 'Water org string';
		Org2.GeographyName__c = 'Water Geo';
		Org2.Region__c = 'Water Region';
		Org2.OrgID__c = '227';
		Org2.OUID__c = '999';

		lOrgStrings.add(Org1);
		lOrgStrings.add(Org2);
		insert lOrgStrings;

		Group publicGroup = INC_Utils_Testing.createPublicGroup('Southeast');
		insert publicGroup;

		//routing members
		list<RoutingMember__c> lRouting = new list<RoutingMember__c>();
		RoutingMember__c DefaultRout = INC_Utils_Testing.CreateRoutingMember(runningUser);
		DefaultRout.GeographyDescription__c = 'Water Geo';
		lRouting.add(DefaultRout);
		RoutingMember__c DTWAdminActualWater = INC_Utils_Testing.CreateRoutingMember(DTWAdminWater);
		DTWAdminActualWater.GeographyDescription__c = Org2.GeographyName__c;
		DTWAdminActualWater.RegionDescription__c = Org2.Region__c;
		DTWAdminActualWater.EndMarket__c = Org2.BusinessLineName__c;
		DTWAdminActualWater.DistrictDescription__c = Org2.District__c;
		DTWAdminActualWater.DTW_Approver_Group__c = 'Southeast';
	
		lRouting.Add(DTWAdminActualWater);
	
		RoutingMember__c  TestingRouting = INC_Utils_Testing.createRoutingMember(DTWAdminTest);
		TestingRouting.GeographyDescription__c = Org1.GeographyName__c;
		TestingRouting.RegionDescription__c = Org1.Region__c;
		TestingRouting.EndMarket__c = Org1.BusinessLineName__c;
		TestingRouting.DistrictDescription__c = Org1.District__c;
		TestingRouting.GlobalDefault__c = true;

		lRouting.add(TestingRouting);
		insert lRouting;

		//create 200 routing members to test the assignment properly
		list<RoutingMember__c> listBulkRouting = new list<RoutingMember__c>();
		for(Integer i=0; i<200; i++){
			RoutingMember__c rt = new RoutingMember__c();
			rt.GeographyDescription__c = Org2.GeographyName__c;
			rt.RegionDescription__c = Org2.Region__c;
			rt.EndMarket__c = Org2.BusinessLineName__c + String.ValueOf(i);
			rt.DistrictDescription__c = Org2.District__c;
			rt.DTW_Approver_Group__c = 'Southeast';
			RoutingMember__c rt2 = new RoutingMember__c();
			rt2.GeographyDescription__c = Org1.GeographyName__c;
			rt2.RegionDescription__c = Org1.Region__c;
			rt2.EndMarket__c = Org1.BusinessLineName__c + String.ValueOf(i);
			rt2.DistrictDescription__c = Org1.District__c;
			rt2.DTW_Approver_Group__c = 'Southeast';
			listBulkRouting.add(rt);
			listBulkRouting.add(rt2);
		}

		insert listBulkRouting;

		list<IncentiveProject__c> lInserts = new list<IncentiveProject__c>();
		for(Integer i=0; i<=1; i++){
			IncentiveProject__c WaterProject = INC_Utils_Testing.createIncentiveProject();
			WaterProject.Name = WaterProject.Name + String.valueOf(i);
			WaterProject.GeographyDescription__c = DTWAdminActualWater.GeographyDescription__c;
			WaterProject.RegionDescription__c = DTWAdminActualWater.RegionDescription__c;
			WaterProject.EndMarket__c = DTWAdminActualWater.EndMarket__c;
			WaterProject.DistrictDescription__c = DTWAdminActualWater.DistrictDescription__c;
			WaterProject.OrgCarryingOutProject__c = Org2.Name;
			lInserts.add(WaterProject);
		}
		
		
		
		Test.startTest();
		System.RunAs(DTWAdminWater){
		  insert LInserts;
		  INC_FindDTWAdminForNewIncentiveProjects batch = new INC_FindDTWAdminForNewIncentiveProjects();
		  database.executebatch(batch);
		  set<id> setInc = new set<id>();
		  //change data from field sets to test the update code in mass
		  list<Schema.FieldSetMember> listFields = SObjectType.IncentiveProject__c.FieldSets.KeyMetricChangesTrigger.getFields();
          lInserts = [Select ID from IncentiveProject__c];   	
       	  for(IncentiveProject__c ip: lInserts){
       	  	setInc.add(ip.id);
           	for(Schema.FieldSetMember fsmField: listFields) {
      	   		try{
      	   			Ip.put(fsmField.getFieldPath(),'100');
      	   			}catch(Exception e){
      	   				try{
      	   					IP.put(fsmField.getFieldPath(),100);
      	   				}catch(Exception e2){
      	   					//do nothing because we are trying to update a formula field
      	   				}

      	   			}
      	   	}
      	  }
      	  INC_Service_EnrollmentPlan.EnrollmentProcesses(setInc);
		  update lInserts;
		}
		  
		Test.stopTest();
		for(IncentiveProject__c ip: [Select ID, DTWAdmin__c From IncentiveProject__c]){
		  	System.Assert(IP.DTWAdmin__c == DTWAdminWater.ID,'DTWAdminTest should be : ' + DTWAdminWater.ID + ' not:' + IP.DTWAdmin__c);
		  }
	} 

	@isTest
	static void testNoRoutingMemeber(){
		ECO_TriggerSettings__c setting = new ECO_TriggerSettings__c();
        setting.Name = 'INC_IncentiveProject_AllEvents';
        setting.isEnabled__c = true;
        insert setting;

        ECO_TriggerSettings__c setting2 = new ECO_TriggerSettings__c();
        setting2.Name = 'INC_EnrollmentPlan_AllEvents';
        setting2.isEnabled__c = true;
        insert setting2;
        
		list<User> lusers = new list<User>();
		User runningUser = INC_Utils_Testing.createUser();
		User DTWAdminWater = INC_Utils_Testing.createUser();
	
		DTWAdminWater.userName = DTWAdminWater.userName + '2';
		DTWAdminWater.CommunityNickname = DTWAdminWater.CommunityNickname + '2';
        DTWAdminWater.FederationIdentifier = DTWAdminWater.FederationIdentifier + '2';
        DTWAdminWater.OracleEmployeeId__c = DTWAdminWater.OracleEmployeeId__c + '2';
        DTWAdminWater.TrackingID__c = DTWAdminWater.TrackingID__c + '2';
        DTWAdminWater.URS_FIM_GUID__c = DTWAdminWater.URS_FIM_GUID__c + '2';
		DTWAdminWater.Email = '2' + DTWAdminWater.Email;
	
		User DTWAdminTest = INC_Utils_Testing.createUser();
		DTWAdminTest.userName = DTWAdminTest.userName + '3';
		DTWAdminTest.CommunityNickname = DTWAdminTest.CommunityNickname + '3';
        DTWAdminTest.FederationIdentifier = DTWAdminTest.FederationIdentifier + '3';
        DTWAdminTest.OracleEmployeeId__c = DTWAdminTest.OracleEmployeeId__c + '3';
        DTWAdminTest.TrackingID__c = DTWAdminTest.TrackingID__c + '3';
        DTWAdminTest.URS_FIM_GUID__c = DTWAdminTest.URS_FIM_GUID__c + '3';
		DTWAdminTest.Email = '3' + DTWAdminTest.Email;
		lUsers.add(runningUser);
		lUsers.add(DTWAdminWater);
		lUsers.add(DTWAdminTest);
		insert lUsers;

		List<OrganizationString__c> lOrgStrings = new List<OrganizationString__c>();
		OrganizationString__c Org1 = INC_Utils_Testing.createTestOrg();
		OrganizationString__c Org2 = INC_Utils_Testing.createTestOrg();
		Org1.Name = Org1.OrganizationName__c;
		Org1.Region__c = 'Test Region';

		Org2.OrganizationName__c = 'Water Organization';
		Org2.Name = 'Water Organization';
		Org2.BusinessLineName__c = 'Water';
		Org2.Department__c = 'Water Department';
		Org2.District__c = 'Water District';
		Org2.Description__c = 'Water org string';
		Org2.GeographyName__c = 'Water Geo';
		Org2.Region__c = 'Water Region';
		Org2.OrgID__c = '227';
		Org2.OUID__c = '999';

		lOrgStrings.add(Org1);
		lOrgStrings.add(Org2);
		insert lOrgStrings;

		IncentiveProject__c WaterProject = INC_Utils_Testing.createIncentiveProject();
		WaterProject.OrgCarryingOutProject__c = Org2.Name;
		Test.startTest();
		  insert WaterProject;
		  WaterProject = [Select ID, DTWAdmin__c From IncentiveProject__c where id=: WaterProject.id];
		  System.Assert(WaterProject.DTWAdmin__c == null,'DTWAdminTest should be null');
		Test.stopTest();

	} 
	
 
}