@isTest
private class TestHRS_CaseContactExt {

    private static Final Set<String> FieldApiNames = new set<String> {'careerBand','birthDate','religion'};

	private static Case CreateQuickCase( String RTName, Boolean insertFlag, Contact con, String Tracking ){

        Case c = new Case();
        c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get( RTName ).getRecordTypeId();
        if ( con != null ){
        	c.Contact = con;
            c.Case_Requestor__c = con.Id;
        }
        if ( Tracking != null )
            c.Tracking_ID__c = Tracking;
        c.Type = 'Job Title Change';
        c.subject = 'I have a new hire starts tomorrow';
        c.Description = 'Here is the description for the new Hire';
        c.HRS_Org_Department__c = TestHRS_Env_Setup.OrgDepartMap.get('30.AECOM TECH CORP.USLAX5.0737');
        c.Effective_Date__c = Date.today()+1;
        c.Case_Requestor__c = con.Id;
        c.Origin = 'Web';

        if ( insertFlag )
        	insert c;

        return c;
	}

    private static Contact CreateQuickContact(){

        Contact c = new Contact();
        c.firstname = 'Test';
        c.Lastname = 'aecom';
        c.email = 'SFDCTestCase@aecom.com';
        c.Mailingcountry = 'United States';
        c.OracleContactID__c = 'EMPLOYEE-8702312';
        c.TrackingID__c = '8702312';
        insert c;

        return c;
    }

    @isTest static void MissingTrackingId() {

    	TestHRS_Env_Setup.CreateHRSEnv();
        Contact con = CreateQuickContact();
    	Case c = CreateQuickCase('HR - Job Title Change', True, con, null);

        PageReference aPage = Page.HRS_OdataRead;
        ApexPages.currentPage().getParameters().put('Id', c.Id);
        test.setCurrentPage(aPage);
        ApexPages.StandardController ctrl = New ApexPages.StandardController( c ); //Instance of Standard Controller
        HRS_CaseContactExt caseExt = new HRS_CaseContactExt( ctrl );

        System.assertEquals( true, caseExt.isTokenValid );

        caseExt.checkSetupType( 'Job Title Change' );

        System.assertEquals( false, caseExt.isDisplay );
	  
    }

    @isTest static void TestReadPage() {

        TestHRS_Env_Setup.CreateHRSEnv();
        Contact con = CreateQuickContact();
        Case c = CreateQuickCase('HR - Job Title Change', True, con, '8455155');
        
        PageReference aPage = Page.HRS_OdataRead;
        ApexPages.currentPage().getParameters().put('Id', c.Id);

        system.Test.setCurrentPage(aPage);

        ApexPages.StandardController ctrl = New ApexPages.StandardController( c ); //Instance of Standard Controller
        HRS_CaseContactExt caseExt = new HRS_CaseContactExt( ctrl );
        caseExt.hrsManager.pageName = '/apex/HRS_OdataRead?Id='+c.Id;
        System.assertEquals( false, caseExt.isDisplay );
                                
        caseExt.isTokenValid = ECO_Service_Authentication.authenticateOracleToken(UserInfo.getUserId());

        System.assertEquals( true, caseExt.isTokenValid );

        List<HRS_API__mdt> hrsList = [select Id, CaseType__c, Field__c, isActive__c, Order__c, isRead__c, isEdit__c, FieldType__c from HRS_API__mdt where 
                                            CaseType__c = 'Job Title Change' and isActive__c = true  order by Order__c asc ];

        Boolean chk = caseExt.checkSetupType('Job Title Change');

        System.assertEquals( true, chk );    
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock());
        //editEndPointBase + hrsManager.editWorker.dynamicQuery, key, 'eConnect', false, false, hrsManager.MAXTIMEOUT, fid, null, null
        //String url, String keys, String certName, Boolean isPost, Boolean isPut, Integer timeoutNumb, String FredId, String jsonBody, String eTag
        caseExt.validateRetrieve();     

        System.assertEquals( 's2' , caseExt.hrsManager.employee.careerBand );

        caseExt.hrsManager.setPicklistMapping();       
    }

    @isTest static void TestEditPage() {

        TestHRS_Env_Setup.CreateHRSEnv();
        Contact con = CreateQuickContact();
        Case c = CreateQuickCase('HR - Job Title Change', True, con, '8455155');
        
        PageReference aPage = Page.HRS_OdataEdit;
        ApexPages.currentPage().getParameters().put('Id', c.Id);

        system.Test.setCurrentPage(aPage);

        ApexPages.StandardController ctrl = New ApexPages.StandardController( c ); //Instance of Standard Controller
        HRS_CaseContactExt caseExt = new HRS_CaseContactExt( ctrl );
        caseExt.hrsManager.pageName = 'HRS_OdataEdit?Id='+c.Id;
        System.assertEquals( false, caseExt.isDisplay );
                                
        caseExt.isTokenValid = ECO_Service_Authentication.authenticateOracleToken(UserInfo.getUserId());

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock());
        caseExt.hrsManager.editWorker.resultRsp = ECO_Service_Authentication.DynamicProxyRequestNew( 'url','key','eConnect',false,false,caseExt.hrsManager.MAXTIMEOUT ,'test@aecom.com',null,null);

        System.assertEquals( true, caseExt.isTokenValid );

        List<HRS_API__mdt> hrsList = [select Id, CaseType__c, Field__c, isActive__c, Order__c, isRead__c, isEdit__c, FieldType__c from HRS_API__mdt where 
                                            CaseType__c = 'Job Title Change' and isActive__c = true  order by Order__c asc ];

        Boolean chk = caseExt.checkSetupType('Job Title Change');

        System.assertEquals( true, chk );     

        caseExt.hrsManager.setPicklistMapping();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock());
        //editEndPointBase + hrsManager.editWorker.dynamicQuery, key, 'eConnect', false, false, hrsManager.MAXTIMEOUT, fid, null, null
        //String url, String keys, String certName, Boolean isPost, Boolean isPut, Integer timeoutNumb, String FredId, String jsonBody, String eTag
        //caseExt.hrsManager.readWorker.resultRsp = ECO_Service_Authentication.DynamicProxyRequestNew( 'url','key','eConnect',false,false,caseExt.hrsManager.MAXTIMEOUT ,'test@aecom.com',null,null);
        caseExt.validateRetrieve();     

         System.assertEquals( 's2' , caseExt.hrsManager.casepii.careerBand );

        caseExt.hrsManager.setPicklistMapping();   
        String jsons = caseExt.hrsManager.prePopulateJsonStr();          

    }

    @isTest static void TestEditSavePage() {

        TestHRS_Env_Setup.CreateHRSEnv();
        Contact con = CreateQuickContact();
        Case c = CreateQuickCase('HR - Job Title Change', True, con, '8455155');
        
        PageReference aPage = Page.HRS_OdataEdit;
        ApexPages.currentPage().getParameters().put('Id', c.Id);

        system.Test.setCurrentPage(aPage);

        ApexPages.StandardController ctrl = New ApexPages.StandardController( c ); //Instance of Standard Controller
        HRS_CaseContactExt caseExt = new HRS_CaseContactExt( ctrl );
        caseExt.hrsManager.pageName = 'HRS_OdataEdit?Id='+c.Id;
        System.assertEquals( false, caseExt.isDisplay );
                                
        caseExt.isTokenValid = ECO_Service_Authentication.authenticateOracleToken(UserInfo.getUserId());

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock());
        caseExt.hrsManager.editWorker.resultRsp = ECO_Service_Authentication.DynamicProxyRequestNew( 'url','key','eConnect',false,false,caseExt.hrsManager.MAXTIMEOUT ,'test@aecom.com',null,null);

        System.assertEquals( true, caseExt.isTokenValid );

        List<HRS_API__mdt> hrsList = [select Id, CaseType__c, Field__c, isActive__c, Order__c, isRead__c, isEdit__c, FieldType__c from HRS_API__mdt where 
                                            CaseType__c = 'Job Title Change' and isActive__c = true  order by Order__c asc ];

        Boolean chk = caseExt.checkSetupType('Job Title Change');

        System.assertEquals( true, chk );     

        caseExt.hrsManager.setPicklistMapping();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock());
        caseExt.validateRetrieve();     

        caseExt.hrsManager.setPicklistMapping();   
        String jsons = caseExt.hrsManager.prePopulateJsonStr();   

        caseExt.hrsManager.casepii.careerBand = 'E1';
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock());

        system.runAs( TestHRS_Env_Setup.StandardUserMap.get('CEO') ){ 
            caseExt.hrsManager.SaveCase();
        }
    }

    @isTest static void AuthenticationTest() {

        TestHRS_Env_Setup.CreateHRSEnv();
        Contact con = CreateQuickContact();
        Case c = CreateQuickCase('HR - Job Title Change', True, con, '8455155');
        
        PageReference aPage = Page.HRS_OdataEdit;
        ApexPages.currentPage().getParameters().put('Id', c.Id);
        test.setCurrentPage(aPage);
        ApexPages.StandardController ctrl = New ApexPages.StandardController( c ); //Instance of Standard Controller
        HRS_CaseContactExt caseExt = new HRS_CaseContactExt( ctrl );

        caseExt.OracleUserName = 'AECOMQA';
        caseExt.OraclePassword = 'p0ssw0rd';

        ApexPages.currentPage().getParameters().put('username', 'AECOMQA');
        ApexPages.currentPage().getParameters().put('password', 'p0ssw0rd');

        caseExt.authenticateCredentials();
        caseExt.closeAuthenticationWindow();

       // System.assertEquals( 'S3' , caseExt.EmployeePii.careerBand );
       // System.assertEquals( dateTime.valueof('1950-12-31 23:00:00') , caseExt.EmployeePii.birthDate );
       // System.assertEquals( 'Egyptian' , caseExt.EmployeePii.religion );


    }
   @isTest static void TestifRecordisLocked() {

        TestHRS_Env_Setup.CreateHRSEnv();
        Contact con = CreateQuickContact();
        Case c = CreateQuickCase('HR - Job Title Change', True, con, '8455155');
        c.Status = 'In Approval';
        update c;

        PageReference aPage = Page.HRS_OdataEdit;
        ApexPages.currentPage().getParameters().put('Id', c.Id);

        system.Test.setCurrentPage(aPage);

        ApexPages.StandardController ctrl = New ApexPages.StandardController( c ); //Instance of Standard Controller
        HRS_CaseContactExt caseExt = new HRS_CaseContactExt( ctrl );
        caseExt.hrsManager.pageName = 'HRS_OdataEdit?Id='+c.Id;
        caseExt.validateRetrieve();  
        System.assertEquals( true , caseExt.hrsManager.isLocked );

   }

   @isTest static void TestifRecordNoTracking() {

        TestHRS_Env_Setup.CreateHRSEnv();
        Contact con = CreateQuickContact();

        Case c = CreateQuickCase('HR - Job Title Change', True, con, '8455155');
        c.Tracking_ID__c = '';
        update c; 

        PageReference aPage = Page.HRS_OdataEdit;
        ApexPages.currentPage().getParameters().put('Id', c.Id);

        system.Test.setCurrentPage(aPage);

        ApexPages.StandardController ctrl = New ApexPages.StandardController( c ); //Instance of Standard Controller
        HRS_CaseContactExt caseExt = new HRS_CaseContactExt( ctrl );
        caseExt.hrsManager.pageName = 'HRS_OdataEdit?Id='+c.Id;
        caseExt.validateRetrieve();  

   }

   @isTest static void TestifRecordisNoSetup() {

        TestHRS_Env_Setup.CreateHRSEnv();
        Contact con = CreateQuickContact();
        con.TrackingID__c = '';
        update con;

        Case c = CreateQuickCase('HR - Supervisor Change', True, con, '8455155');

        PageReference aPage = Page.HRS_OdataEdit;
        ApexPages.currentPage().getParameters().put('Id', c.Id);

        system.Test.setCurrentPage(aPage);

        ApexPages.StandardController ctrl = New ApexPages.StandardController( c ); //Instance of Standard Controller
        HRS_CaseContactExt caseExt = new HRS_CaseContactExt( ctrl );
        caseExt.hrsManager.pageName = 'HRS_OdataEdit?Id='+c.Id;
        caseExt.validateRetrieve();  
        System.assertEquals( false , caseExt.isDisplay );

   }

    @isTest static void testHRSapiController() {


        TestHRS_Env_Setup.CreateHRSEnv();
        Contact con = CreateQuickContact();
        Case c = CreateQuickCase('HR - Job Title Change', True, con, '8455155');
        
        PageReference aPage = Page.HRS_OdataEdit;
        ApexPages.currentPage().getParameters().put('Id', c.Id);

        system.Test.setCurrentPage(aPage);

        ApexPages.StandardController ctrl = New ApexPages.StandardController( c ); //Instance of Standard Controller
        HRS_CaseContactExt caseExt = new HRS_CaseContactExt( ctrl );
        caseExt.hrsManager.pageName = 'HRS_OdataEdit?Id='+c.Id;
       
        HRS_apiDataController apiCtrl = new HRS_apiDataController();
        apiCtrl.columns = 1;
        apiCtrl.isEdit = true;
        apiCtrl.sethrsManager( caseExt.hrsManager );
        system.assertEquals( apiCtrl.columns, 1 );
        system.assertEquals( apiCtrl.isEdit, true );

        system.assertEquals( apiCtrl.gethrsManager(), caseExt.hrsManager );
    }

    @isTest static void testJson2Case() {
        String json = '{"emergencyContactOtherPersonalPhone":"4153545585","emergencyContactHomePhone":"4153545586","emergencyContactCountry":"China","emergencyContactCounty":"ABC",';
                json += '"emergencyContactPostalCode":"94152","emergencyContactState":"ShenZhen","emergencyContactCity":"Garden","emergencyContactAddress2":"Apt 2","emergencyContactAddress1":"123 St.",';
                json += '"emergencyContactLastName":"ABC","emergencyContactMiddleName":"Ambbd","emergencyContactFirstName":"Abdd","emergencyContactRelationship":"Dad","careerBand":"S3",';
                json += '"socialSecurityNumberNationalId":"A156","religion":"UNASSIGNED","registeredDisabled":"N","nationality":"China","homePostalCode":"90017","homeStateOrRegion":';
                json += '"Alabama","homeCountry":"United States","homeCity":"Los Angeles","homeAddressLine3":"ADDRESS_LINE3","homeAddressLine2":"ADDRESS_LINE2","homeAddressLine1":';
                json += '"555 S Flower St","passportExpiryDate":"2016-10-12","passportIssueDate":"2016-10-12","passportNumber":"A#434232","visaExpiryDate":"2016-10-12","visaIssueDate":';
                json += '"2016-10-12","i9Status":"CX_I9_STATUS","vetsStatus":"Armed Forces Service Medal (AFSM) Veteran","birthDate":"1951-01-01","maritalStatus":"Married","gender":';
                json += '"F","homeNumber":"5105689512","monthlySalary":5200,"yearlySalary":62400,"hourlyRate":0,"hourlyPayRate":0,"trackingId":"8307642","CaseNumber":"00152598",';
                json += '"allowanceAmount":55,"monthlyAllowance":25,"homeState":"CA","bankingInformation":"NoBank","firstName":"LaLa","surname":"Land","personalEmail":"abc@aecom.com",';
                json += '"militarySpouse":"Yes","emergencyContactName":"Bob","ibanNumber":"A454","bankName":"WellsFargo","accountNumber":"1381564485","payrollTaxState":"California",';
                json += '"citizenshipLpr":"A454","mobile":"3124568125","ethnicity":"Test","loaType":"TestLoa","detailsForTermination":"TestTerm","terminationReason":"TestTermReason","caseStatus":"New",';
                json += '"sendToAddress":"abc address","emergencyContactCellNumber":"4153545585","emergencyContactWorkNumber":"4153545585","externalContactId":"003252","externalCaseId":"12332"}';
        
        JSON2Case obj = JSON2Case.parse(json);
        System.assert(obj != null);
        System.assertEquals( 55, obj.allowanceAmount );
        System.assertEquals( 25, obj.monthlyAllowance );
        System.assertEquals( 'CA', obj.homeState );
        System.assertEquals( 'NoBank', obj.bankingInformation );
        System.assertEquals( 'LaLa', obj.firstName );
        System.assertEquals( 'Land', obj.surname );
        System.assertEquals( 'abc@aecom.com', obj.personalEmail );
        System.assertEquals( 'Yes', obj.militarySpouse );
        System.assertEquals( 'Bob', obj.emergencyContactName );
        System.assertEquals( 'Dad', obj.emergencyContactRelationship );
        System.assertEquals( '8307642', obj.trackingId ); 
        System.assertEquals( '00152598', obj.CaseNumber ); 
        System.assertEquals( '4153545586', obj.emergencyContactHomePhone );
        System.assertEquals( '4153545585', obj.emergencyContactOtherPersonalPhone ); 
        System.assertEquals( '94152', obj.emergencyContactPostalCode ); 
        System.assertEquals( '4153545585', obj.emergencyContactOtherPersonalPhone ); 
        System.assertEquals( 'ABC', obj.emergencyContactLastName ); 
        System.assertEquals( 'A156', obj.socialSecurityNumberNationalId ); 
        System.assertEquals( obj.careerBand, 'S3' ); 
        System.assertEquals( obj.religion, 'UNASSIGNED' ); 
        System.assertEquals( obj.registeredDisabled, 'N' ); 
        System.assertEquals( obj.nationality, 'China' ); 
        System.assertEquals( obj.homePostalCode, '90017' ); 
        System.assertEquals( obj.homeStateOrRegion, 'Alabama' ); 
        System.assertEquals( obj.homeCountry, 'United States' ); 
        System.assertEquals( obj.homeCity, 'Los Angeles' ); 
        System.assertEquals( obj.homeAddressLine3, 'ADDRESS_LINE3' ); 
        System.assertEquals( obj.homeAddressLine2, 'ADDRESS_LINE2' ); 
        System.assertEquals( obj.homeAddressLine1, '555 S Flower St' ); 
        System.assertEquals( obj.passportNumber, 'A#434232' ); 
        System.assertEquals( obj.i9Status, 'CX_I9_STATUS' ); 
        System.assertEquals( obj.vetsStatus, 'Armed Forces Service Medal (AFSM) Veteran' ); 
        System.assertEquals( obj.maritalStatus, 'Married' ); 
        System.assertEquals( obj.gender, 'F' ); 
        System.assertEquals( obj.homeNumber, '5105689512' ); 
        System.assertEquals( obj.monthlySalary, 5200 ); 
        System.assertEquals( obj.yearlySalary, 62400 ); 
        System.assertEquals( obj.hourlyRate, 0 ); 
        System.assertEquals( obj.hourlyPayRate, 0 ); 
        System.assertEquals( 'S3', obj.careerBand ); 
        System.assertEquals( 'A454', obj.ibanNumber ); 
        System.assertEquals( 'WellsFargo', obj.bankName ); 
        System.assertEquals( '1381564485', obj.accountNumber ); 
        System.assertEquals( 'California', obj.payrollTaxState ); 
        System.assertEquals( 'A454', obj.citizenshipLpr ); 
        System.assertEquals( '3124568125', obj.mobile ); 
        System.assertEquals( 'China', obj.emergencyContactCountry ); 
        System.assertEquals( 'ShenZhen', obj.emergencyContactState ); 
        System.assertEquals( 'Garden', obj.emergencyContactCity ); 
        System.assertEquals( 'Apt 2', obj.emergencyContactAddress2 ); 
        System.assertEquals( '123 St.', obj.emergencyContactAddress1 ); 
        System.assertEquals( 'Test', obj.ethnicity ); 
        System.assertEquals( 'TestLoa', obj.loaType ); 
        System.assertEquals( 'TestTerm', obj.detailsForTermination ); 
        System.assertEquals( 'TestTermReason', obj.terminationReason ); 
        System.assertEquals( 'Abdd', obj.emergencyContactFirstName ); 
        System.assertEquals( 'Ambbd', obj.emergencyContactMiddleName ); 
        System.assertEquals( 'abc address', obj.sendToAddress ); 
        System.assertEquals( '4153545585', obj.emergencyContactCellNumber ); 
        System.assertEquals( '4153545585', obj.emergencyContactWorkNumber ); 
        System.assertEquals( '003252', obj.externalContactId ); 
        System.assertEquals( '12332', obj.externalCaseId ); 
        System.assertEquals( 'New', obj.caseStatus ); 
        System.assertEquals( 'ABC', obj.emergencyContactCounty ); 



              
        Map<String, Object> CaseTestMap = JSON2Case.parseValue( json ); 

        System.assertEquals( 'S3', CaseTestMap.get( 'careerBand' ) ); 
        System.assertEquals( '555 S Flower St', CaseTestMap.get( 'homeAddressLine1' ) ); 

    }

  @isTest static void testJsonEmployee() {

        String  BodyResult =  '{ "@odata.context":"https://nadtc1vap029.acm.ext/hr/odata/v1/$metadata#employees/$entity","TrackingId":"8307642",';
                BodyResult += '"amountIncrease":0,"yearlySalary":62400.25,"assignmentCategory":"Full Time","assignmentStatus":null,"assignmentStatusType":"A",';
                BodyResult += '"backupApprover1":"Yuen, Tung Kwan (Escode)","backupApprover2":"LI, KWOK WAI ALBERT","bargainingUnit":null,"birthDate":';
                BodyResult += '"1951-01-01","careerBand":"S3","costType":"50","eeoCategory":"UNASSIGNED","eeoStCode":null,"eligibleSickPay":';
                BodyResult += '"UNASSIGNED","expenditureType":"LAB - Professional","fteStandardHours":0,"gender":"F","glLocation":null,"gtlDataControl":null,';
                BodyResult += '"homeAddressLine1":"555 S Flower St","homeAddressLine2":null,"homeAddressLine3":null,"homeCity":"Los Angeles","homeCountry":"United States"';
                BodyResult += ',"homeStateOrRegion":"CA","homePostalCode":"90017","hrJobCode":"BDVBDV420","i9Status":null,"languageCode":"ZH-CN","languageDescription"';
                BodyResult += ':"Simplified Chinese","lastSalaryChangeDate":"2014-07-01","loaActualStartDate":null,"loaActualEndDate":null,"maritalStatus":';
                BodyResult += '"Married","monthlySalary":null,"nationality":"China","opie":"76003","overtimeEligibility":"N","payCurrency":"CNY","payEffectiveDate":';
                BodyResult += '"2015-01-01","payFrequency":"W","payrollName":"CNY Monthly","ethnicity":"Test","registeredDisabled":null,"religion":"UNASSIGNED",';
                BodyResult += '"salaryGrade":"11","salaryIncreasePercent":0,"sourceCountry":"CHINA","subfunction":"UNASSIGNED","suiState":null,"terminationType":"UNASSIGNED",';
                BodyResult += '"timekeeper1":"LI, JINGJING","timekeeper2":"Hu, Miao (Alice)","timekeeper3":"LI, NA","timekeeperFlag":"N","unionCode":"N","unionName":';
                BodyResult += '"UNASSIGNED","workState":null,"workerCompCode":null,"workingHours":39.5 }';

        JSON2Employee EmployeeTestData = JSON2Employee.parse( bodyResult ); 

        System.assertEquals( '8307642', EmployeeTestData.TrackingId);                             
        System.assertEquals( 0, EmployeeTestData.amountIncrease);                             
        System.assertEquals( 62400.25, EmployeeTestData.yearlySalary);                              
        System.assertEquals( 'Full Time', EmployeeTestData.assignmentCategory);  
        System.assertEquals( null, EmployeeTestData.assignmentStatus);  
        System.assertEquals( 'A', EmployeeTestData.assignmentStatusType);  
        System.assertEquals( 'Yuen, Tung Kwan (Escode)', EmployeeTestData.backupApprover1);  
        System.assertEquals( 'LI, KWOK WAI ALBERT', EmployeeTestData.backupApprover2);  
        System.assertEquals( null, EmployeeTestData.bargainingUnit);  
        System.assertEquals( '50', EmployeeTestData.costType);  
        System.assertEquals( 'UNASSIGNED', EmployeeTestData.eeoCategory);  
        System.assertEquals( null, EmployeeTestData.eeoStCode);  
        System.assertEquals( 'UNASSIGNED', EmployeeTestData.eligibleSickPay); 
        System.assertEquals( 'LAB - Professional', EmployeeTestData.expenditureType);  
        System.assertEquals( 'F', EmployeeTestData.gender);  
        System.assertEquals( null, EmployeeTestData.glLocation);  
        System.assertEquals( null, EmployeeTestData.gtlDataControl);    
        System.assertEquals( EmployeeTestData.homeAddressLine1 , '555 S Flower St' );
        System.assertEquals( EmployeeTestData.homeAddressLine2 , null );
        System.assertEquals( EmployeeTestData.homeAddressLine3 , null );
        System.assertEquals( EmployeeTestData.homeCity , 'Los Angeles' );
        System.assertEquals( EmployeeTestData.homeCountry , 'United States' );
        System.assertEquals( EmployeeTestData.homeStateOrRegion , 'CA' );
        System.assertEquals( EmployeeTestData.homePostalCode , '90017' );
        System.assertEquals( EmployeeTestData.hrJobCode , 'BDVBDV420' );
        System.assertEquals( EmployeeTestData.i9Status , null );
        System.assertEquals( EmployeeTestData.languageCode , 'ZH-CN' );
        System.assertEquals( EmployeeTestData.languageDescription , 'Simplified Chinese' );
        System.assertEquals( EmployeeTestData.loaActualStartDate , null );
        System.assertEquals( EmployeeTestData.loaActualEndDate , null );
        System.assertEquals( EmployeeTestData.maritalStatus , 'Married' );
        System.assertEquals( EmployeeTestData.monthlySalary , null );
        System.assertEquals( EmployeeTestData.nationality , 'China' );
        System.assertEquals( EmployeeTestData.opie , '76003' );
        System.assertEquals( EmployeeTestData.overtimeEligibility , 'N' );
        System.assertEquals( EmployeeTestData.payCurrency , 'CNY' );
        System.assertEquals( EmployeeTestData.payFrequency , 'W' );
        System.assertEquals( EmployeeTestData.payrollName , 'CNY Monthly' );
        System.assertEquals( EmployeeTestData.ethnicity , 'Test' );
        System.assertEquals( EmployeeTestData.registeredDisabled , null );
        System.assertEquals( EmployeeTestData.religion , 'UNASSIGNED' );
        System.assertEquals( EmployeeTestData.salaryGrade , '11' );
        System.assertEquals( EmployeeTestData.salaryIncreasePercent, 0 );
        System.assertEquals( EmployeeTestData.sourceCountry , 'CHINA' );
        System.assertEquals( EmployeeTestData.subfunction , 'UNASSIGNED' );
        System.assertEquals( EmployeeTestData.suiState , null );
        System.assertEquals( EmployeeTestData.terminationType , 'UNASSIGNED' );
        System.assertEquals( EmployeeTestData.timekeeper1 , 'LI, JINGJING' );
        System.assertEquals( EmployeeTestData.timekeeper2 , 'Hu, Miao (Alice)' );
        System.assertEquals( EmployeeTestData.timekeeper3 , 'LI, NA' );
        System.assertEquals( EmployeeTestData.timekeeperFlag , 'N' );
        System.assertEquals( EmployeeTestData.unionCode , 'N' );
        System.assertEquals( EmployeeTestData.unionName , 'UNASSIGNED' );
        System.assertEquals( EmployeeTestData.workState , null );
        System.assertEquals( EmployeeTestData.workerCompCode , null );
        System.assertEquals( EmployeeTestData.workingHours, 39.5 );

        Map<String, Object> EmployeeTestMap = JSON2Employee.parseValue( bodyResult ); 

        System.assertEquals( 'Full Time', EmployeeTestMap.get( 'assignmentCategory' ) ); 
        System.assertEquals( 39.5, EmployeeTestMap.get( 'workingHours' ) ); 
        System.assertEquals( 'LI, JINGJING', EmployeeTestMap.get( 'timekeeper1' ) ); 
        System.assertEquals( 'F', EmployeeTestMap.get( 'gender' ) ); 

    }

}