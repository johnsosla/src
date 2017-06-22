@isTest
public class TestHRS_Env_Setup {

    public static Final Set<String> OrgDepartNameValues = new set<String> {'30.AECOM TECH CORP.USLAX5.0737','40.CORPORATE.D67.4071'};
    public static Final Set<String> BusinessGroupNameValues = new set<String> {'Corporate','End Markets'};
    public static Final Set<String> OperatingGroupNameValues = new set<String> {'Corporate','DCS - Americas'};
    public static Final Set<String> GeoNameValues = new set<String> {'AECOM Corp','Americas'};
    public static Final Set<String> StrategicBUNameValues = new set<String> {'AECOM Corp','NA - Mgmt'};
    public static Final Set<String> AreaNameValues = new set<String> {'AECOM Corp','NA - Corporate Canada'};
    public static Final Set<String> SubAreaNameValues = new set<String> {'AECOM Corp','NA - Corporate Canada'};
    public static Final Set<String> HRSystemNameValues = new set<String> {'AE-USSA','AE-AF','EC','MS'};
    public static Final Set<String> EndPointNames = new set<String> {'Project Sync 2','HRS_EMPLOYEE','HRS_CASE'};
    public static Final Set<String> EntitlementNames = new set<String> {'HR Global SLA - AMER ET','HR APAC (Melbourne)','HR EMIA (Middle East)','HR EMIA (London)'};

    public static Id aecomaccountId;
    public static Map<String, Id> OrgDepartMap = new Map<String, Id>();
	public static Map<String, User> StandardUserMap {get; set;}

    public static Map<String, Schema.RecordTypeInfo> mRtInfo = Case.SObjectType.getDescribe().getRecordTypeInfosByName();

	@testSetup
	public static void CreateHRSEnv(){	

		HRS_TestHRS_DataSetup();
		HRS_StandardUserSetup();
		HRS_OrgDepartmentSetup();
		HRS_CreateHRSystemKeyData();
        CreateECOIntegrationSetting();
        CreateEntitlements();

	}

    static void HRS_TestHRS_DataSetup() {

        Account acct = new Account(Name = 'Uncategorized Vendor');
        insert acct;

        Account acct2 = new Account(Name = 'AECOM Internal Account');
        insert acct2;

        aecomaccountId = acct2.Id;

        ssh_User_Contact_Settings__c custSetting = new ssh_User_Contact_Settings__c();
        custSetting.Name = 'Default';
        custSetting.External_Vendor_Uncategorized_Account__c = acct.Id;
        custSetting.External_Vendor_Record_Type__c = 'Vendor';
        custSetting.Employee_Record_Type__c = 'PSA_Resource';
        custSetting.Internal_User_Account__c = acct2.Id;
        insert custSetting;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User u = new User(Alias = 'jtest', Email = 'SFDCTestCase@aecom.com', OfficeCountry__c = 'United States',
                          EmailEncodingKey = 'UTF-8', LastName = 'Tester', LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_US', ProfileId = p.Id, Department = 'Fake Department', 
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = 'joe@ssh.com.test', TrackingID__c = 'AF1230');

        insert u;   

        Group g1 = new Group(Name = 'SS-AP Cases', Type = 'Queue');
        insert g1;

        QueuesObject q1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            q1 = new QueueSObject(QueueID = g1.Id, SObjectType = 'Case');
            insert q1;
        }

    }

	public static void HRS_StandardUserSetup() {
    	StandardUserMap = new Map<String, User>();
      	Profile p = [select id from profile where name='Standard User'];

        User ceoUser = new User(alias = 'standceo', email='standarduserceo@aecom.com', isActive = true, FederationIdentifier = 'standarduserceo@aecom.com',
        emailencodingkey='UTF-8', lastname='ceo', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, EmployeeNumber = '10001',
        timezonesidkey='America/Los_Angeles', username='test3ceo@aecom.com', FirstName = 'ceo', Title='ceo', ShaKey__c = 'aslkfjasofjeaofie', 
        NormalTransDateTime__c = DateTime.now()+1, OfficeCountry__c = 'United Kingdom', TrackingID__c = 'AF1231' );
        insert ceoUser;
        StandardUserMap.put( 'CEO', ceoUser );


        User svpUser = new User(alias = 'standt2', email='standarduser2@aecom.com', isActive = true, FederationIdentifier = 'standarduser2@aecom.com',
        emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, EmployeeNumber = '10003',
        timezonesidkey='America/Los_Angeles', username='test3svp@aecom.com', FirstName = 'John2', Title='VP,Vice President', OfficeCountry__c = 'Taiwan'
        , TrackingID__c = 'AF1232' );
        insert svpUser;
        StandardUserMap.put( 'SVP', svpUser ); 
    

        User hiringManager = new User(alias = 'standt5', email='standarduser5@aecom.com', isActive = true, FederationIdentifier = 'standarduser5@aecom.com',
        emailencodingkey='UTF-8', lastname='Testing5', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, EmployeeNumber = '10006',
        timezonesidkey='America/Los_Angeles', username='test3hm@aecom.com', FirstName = 'John5', Title='Second Level manager', OfficeCountry__c = 'United States'
        , TrackingID__c = 'AF1233' );
        insert hiringManager;
        StandardUserMap.put( 'HM', hiringManager ); 
	}

	public static void HRS_CustomSettingSetup() {

	}

	public static void HRS_OrgDepartmentSetup() {

        List<String> OrgDepartNames = new List<String>( OrgDepartNameValues ); 
        List<String> BusinessGroupNames = new List<String>( BusinessGroupNameValues ); 
        List<String> OperatingGroupNames = new List<String>( OperatingGroupNameValues ); 
        List<String> GeoNames = new List<String>( GeoNameValues ); 
        List<String> StrategicBUNames = new List<String>( StrategicBUNameValues ); 
        List<String> AreaNames = new List<String>( AreaNameValues ); 
        List<String> SubAreaNames = new List<String>( SubAreaNameValues ); 

        Integer counter = 0;
        List<HRS_Org_Department__c> OrgDepartList = new List<HRS_Org_Department__c>();

        for ( String orgDepName : OrgDepartNames ){

            HRS_Org_Department__c OD = new HRS_Org_Department__c();
        
            OD.Name = orgDepName;
            OD.HRS_Business_Group__c = BusinessGroupNames[ counter ];
            OD.HRS_Operating_Group__c = OperatingGroupNames[ counter ];
            OD.HRS_Geography__c = GeoNames[ counter ];
            OD.HRS_Strategic_Business_Unit__c = StrategicBUNames[ counter ];
            OD.HRS_Area__c = AreaNames[ counter ];
            OD.HRS_Sub_Area__c = SubAreaNames[ counter ];
        
            OrgDepartList.add( OD );
            counter++;
        }

        Database.SaveResult[] results = Database.insert( OrgDepartList );
        Integer i = 0;
        for ( Database.SaveResult sr : results ){
          OrgDepartMap.put( OrgDepartNames[i] , sr.getId() );
          i++;
        }  

	}

	public static void JobCodeSetup() {

	}

    public static void HRS_CreateHRSystemKeyData(){

        List<String> GeoNames = new List<String>( GeoNameValues );
        List<String> OperatingGroupNames = new List<String>( OperatingGroupNameValues );
        List<String> HRSystemNames = new List<String>( HRSystemNameValues ); 

        Integer counter = 0;
        List<HRS_Job_Code_Key_Info__c> JobCodeKeyList = new List<HRS_Job_Code_Key_Info__c>();

        for ( String Geo : GeoNames ){
            for ( String OperGrp : OperatingGroupNames ){
                HRS_Job_Code_Key_Info__c jck = new HRS_Job_Code_Key_Info__c();
                jck.HRS_Geography__c = Geo;
                jck.HRS_Operating_Group__c = OperGrp;
                jck.HRS_HR_System__c = HRSystemNames[counter];
                jck.Name = HRSystemNames[counter];
                counter++;
                JobCodeKeyList.add( jck );
            }
        }

        insert JobCodeKeyList;
    }

    public static void CreateECOIntegrationSetting(){

        List<ECO_IntegrationEndpoints__c> EndpointList = new List<ECO_IntegrationEndpoints__c>();

        for ( String epName : EndPointNames ){
            ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c();
            endpoint.Name = epName;
            endpoint.EndPointUrl__c = 'test';

            EndpointList.add( endpoint );
        }

        insert EndpointList;

    }

	public static void OfficeLocationSetup() {

	}

    public static void CreateEntitlements(){

        List<Entitlement> EntitlementList = new List<Entitlement>();

        for ( String entitleName : EntitlementNames ){
            Entitlement e = new Entitlement();
            e.Name = entitleName;
            e.AccountId = aecomaccountId;
            e.StartDate = Date.today();
            e.EndDate = Date.today()+10;

            EntitlementList.add( e );
        }

        insert EntitlementList;

    }
}