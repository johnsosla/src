@isTest
private class TestHRS_Case {

    //Copying Region to Case
    @isTest static void HRS_TestHRS_Case_Contact() {

        TestHRS_Env_Setup.CreateHRSEnv();
        //workaround to trigger code to create contact
        test.StartTest();
        test.StopTest();

        Contact con = [ select Id, MailingCountry from contact where Email = 'SFDCTestCase@aecom.com'];

        Case c = new Case();
        c.contactId = con.Id;
        c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get('HR - Job Title Change').getRecordTypeId();       
        c.Type = 'New Hire';
        c.subject = 'I have a new hire starts tomorrow';
        c.Description = 'Here is the description for the new Hire';
        c.HRS_Org_Department__c = TestHRS_Env_Setup.OrgDepartMap.get('30.AECOM TECH CORP.USLAX5.0737');
        insert c;

        Case verifyCase = [select Id, recordtypeId, Region__c from Case where Id =: c.Id ];
        System.assertEquals( con.MailingCountry , verifyCase.Region__c );
    }

    //Copying Region to Case
    @isTest static void HRS_TestHRS_Case_Additional_Field() {

        TestHRS_Env_Setup.CreateHRSEnv();
        //workaround to trigger code to create contact
        test.StartTest();
        test.StopTest();

        Contact con = [ select Id, MailingCountry, Business_Card_Title__c, Corporate_Title__c, Employee_Category__c, Employee_Number__c, International_Assignment_Status__c,
                        firstname, lastname, Middle_Names__c,Supervisor_Tracking_Id__c,Preferred_Name__c,JobName__c,Service_Line__c  from contact where Email = 'SFDCTestCase@aecom.com'];
        con.Business_Card_Title__c = 'Test Title';
        con.Corporate_Title__c = 'Corp Title';
        con.Employee_Category__c = 'Emp Cate';
        con.Employee_Number__c = '123456';
        con.International_Assignment_Status__c = 'Status';
        con.firstname = 'Wato';
        con.lastname = 'Santiago';
        con.Middle_Names__c = 'Jack';
        con.Supervisor_Tracking_Id__c = '789101112';
        con.Preferred_Name__c = 'Was';
        con.JobName__c = 'ProjTitle';
        con.Service_Line__c = 'Test';

        update con;

        Case c = new Case();
        c.contactId = con.Id;
        c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get('HR - Job Title Change').getRecordTypeId();       
        c.Type = 'New Hire';
        c.subject = 'I have a new hire starts tomorrow';
        c.Description = 'Here is the description for the new Hire';
        c.HRS_Org_Department__c = TestHRS_Env_Setup.OrgDepartMap.get('30.AECOM TECH CORP.USLAX5.0737');
        insert c;

        Case verifyCase = [select Id, recordtypeId, Region__c, Business_Card_Title__c, Corporate_Title__c, Employee_Category__c, Employee_Number__c,
                            Expat_Inpat_TCN_Status__c, First_Name__c,Last_Name__c,Middle_Name__c,Project_Job_Title__c from Case where Id =: c.Id ];
        System.assertEquals( con.MailingCountry , verifyCase.Region__c );

       System.assertEquals( verifyCase.Business_Card_Title__c , 'Test Title' );
       System.assertEquals( verifyCase.Corporate_Title__c , 'Corp Title' );
       System.assertEquals( verifyCase.Employee_Category__c , 'Emp Cate' );
       System.assertEquals( verifyCase.Employee_Number__c , '123456' );
       System.assertEquals( verifyCase.Expat_Inpat_TCN_Status__c , 'Status' );
       System.assertEquals( verifyCase.First_Name__c , 'Wato' );
       System.assertEquals( verifyCase.Last_Name__c , 'Santiago' );
       System.assertEquals( verifyCase.Middle_Name__c , 'Jack' );
       System.assertEquals( verifyCase.Project_Job_Title__c , 'ProjTitle' );



    }



    //HR - Job Title Change
    @isTest static void HRS_TestHRS_Case_HRData() {

        TestHRS_Env_Setup.CreateHRSEnv();

        Case c = new Case();
        c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get('HR - Job Title Change').getRecordTypeId();       
        c.Type = 'New Hire';
        c.subject = 'I have a new hire starts tomorrow';
        c.Description = 'Here is the description for the new Hire';
        c.HRS_Org_Department__c = TestHRS_Env_Setup.OrgDepartMap.get('30.AECOM TECH CORP.USLAX5.0737');
        insert c;

        Case verifyCase = [select Id, recordtypeId from Case where Id =: c.Id ];
        Boolean isHrCaseFlag = HRS_CaseHandler.checkifHRCase( verifyCase.recordtypeId );
        System.assertEquals( isHrCaseFlag , True );

    }

    //HR Exit Management
    @isTest static void HRS_TestHRS_Case_HRExit() {

        TestHRS_Env_Setup.CreateHRSEnv();

        Case c = new Case();
        c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get('HR - Exit Management').getRecordTypeId();       
        c.Type = 'New Hire';
        c.subject = 'I have a new hire starts tomorrow';
        c.Description = 'Here is the description for the new Hire';
        c.HRS_Org_Department__c = TestHRS_Env_Setup.OrgDepartMap.get('30.AECOM TECH CORP.USLAX5.0737');
        insert c;

        Case verifyCase = [select Id, recordtypeId from Case where Id =: c.Id ];
        Boolean isHrCaseFlag = HRS_CaseHandler.checkifHRCase( verifyCase.recordtypeId );
        System.assertEquals( isHrCaseFlag , True );
        
    }

    //HR Leave Management
    @isTest static void HRS_TestHRS_Case_HRLeave() {

        TestHRS_Env_Setup.CreateHRSEnv();

        Case c = new Case();
        c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get('HR - Leave Management').getRecordTypeId();       
        c.Type = 'New Hire';
        c.subject = 'I have a new hire starts tomorrow';
        c.Description = 'Here is the description for the new Hire';
        c.HRS_Org_Department__c = TestHRS_Env_Setup.OrgDepartMap.get('30.AECOM TECH CORP.USLAX5.0737') ;
        insert c;

        Case verifyCase = [select Id, recordtypeId from Case where Id =: c.Id ];
        Boolean isHrCaseFlag = HRS_CaseHandler.checkifHRCase( verifyCase.recordtypeId );
        System.assertEquals( isHrCaseFlag , True );
        
    }

    //HR New Hire/Rehire
    @isTest static void HRS_TestHRS_Case_New_Hire_Insert() {

        TestHRS_Env_Setup.CreateHRSEnv();
        
        test.startTest();

        Case c = new Case();
        c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get('HR - Hire/Rehire/Transfer In').getRecordTypeId();
        c.Type = 'New Hire';
        c.subject = 'I have a new hire starts tomorrow';
        c.Description = 'Here is the description for the new Hire';
        c.HRS_Org_Department__c = TestHRS_Env_Setup.OrgDepartMap.get('30.AECOM TECH CORP.USLAX5.0737');
        insert c;

        test.stopTest();

        Case verifyCase = [select Id, HRS_Operating_Group__c, HRS_Strategic_Business_Unit__c, HRS_Area__c, HRS_Sub_Area__c, HRS_Org_Department__c from case where Id =: c.id ];
        HRS_Org_Department__c org = [select Id, HRS_Operating_Group__c, HRS_Strategic_Business_Unit__c, HRS_Area__c, HRS_Sub_Area__c from HRS_Org_Department__c where Id =: TestHRS_Env_Setup.OrgDepartMap.get('30.AECOM TECH CORP.USLAX5.0737')];
        System.assertEquals( verifyCase.HRS_Operating_Group__c , org.HRS_Operating_Group__c );
        System.assertEquals( verifyCase.HRS_Strategic_Business_Unit__c , org.HRS_Strategic_Business_Unit__c );
        System.assertEquals( verifyCase.HRS_Area__c , org.HRS_Area__c );
        System.assertEquals( verifyCase.HRS_Sub_Area__c , org.HRS_Sub_Area__c );
    }

          
    @isTest static void HRS_TestHRS_Case_New_Hire_Update() {

        TestHRS_Env_Setup.CreateHRSEnv();

        List<HRS_Job_Code_Key_Info__c> HRSystemKeyList = [select HRS_HR_System__c, HRS_Geography__c, HRS_Operating_Group__c from HRS_Job_Code_Key_Info__c ];
        Map<String, String> SystemKeyMapping = new Map<String, String>();
        for ( HRS_Job_Code_Key_Info__c key : HRSystemKeyList ){
            SystemKeyMapping.put( key.HRS_Geography__c+key.HRS_Operating_Group__c , key.HRS_HR_System__c );
        }        

        Case c = new Case();
        c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get('HR - Hire/Rehire/Transfer In').getRecordTypeId();       
        c.Type = 'New Hire';
        c.subject = 'I have a new hire starts tomorrow';
        c.Description = 'Here is the description for the new Hire';
        c.HRS_Org_Department__c = TestHRS_Env_Setup.OrgDepartMap.get('30.AECOM TECH CORP.USLAX5.0737');
        insert c;

        test.startTest();

        c.HRS_Org_Department__c = TestHRS_Env_Setup.OrgDepartMap.get('40.CORPORATE.D67.4071') ;
        update c;

        test.stopTest();

        Case verifyCase = [select Id, HRS_Operating_Group__c, HRS_Strategic_Business_Unit__c, HRS_Area__c, HRS_Sub_Area__c, HRS_Org_Department__c, HR_System_Key__c, Geography__c from case where Id =: c.id ];

        HRS_Org_Department__c orgDept = [ select Id, Name, HRS_Operating_Group__c, HRS_Strategic_Business_Unit__c, HRS_Area__c, HRS_Sub_Area__c from HRS_Org_Department__c where Id =: verifyCase.HRS_Org_Department__c ];

        System.assertEquals( verifyCase.HRS_Operating_Group__c , orgDept.HRS_Operating_Group__c );
        System.assertEquals( verifyCase.HRS_Strategic_Business_Unit__c , orgDept.HRS_Strategic_Business_Unit__c );
        System.assertEquals( verifyCase.HRS_Area__c , orgDept.HRS_Area__c );
        System.assertEquals( verifyCase.HRS_Sub_Area__c , orgDept.HRS_Sub_Area__c );
        System.assertEquals( verifyCase.HR_System_Key__c , SystemKeyMapping.get(verifyCase.Geography__c + verifyCase.HRS_Operating_Group__c));

    }



    @isTest static void HRS_TestHRS_Case_Non_HRS_Case() {

        TestHRS_Env_Setup.CreateHRSEnv();
        
        test.startTest();

        Case c = new Case();
        c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get('Shared Services AP').getRecordTypeId();       
        c.Type = 'New Hire';
        c.subject = 'I have a new hire starts tomorrow';
        c.Description = 'Here is the description for the new Hire';
        c.HRS_Org_Department__c = TestHRS_Env_Setup.OrgDepartMap.get('30.AECOM TECH CORP.USLAX5.0737');
        insert c;

        test.stopTest();

        Case verifyCase = [select Id, HRS_Operating_Group__c, HRS_Strategic_Business_Unit__c, HRS_Area__c, HRS_Sub_Area__c, HRS_Org_Department__c from case where Id =: c.id ];

        System.assertEquals( verifyCase.HRS_Operating_Group__c , null );
        System.assertEquals( verifyCase.HRS_Strategic_Business_Unit__c , null );
        System.assertEquals( verifyCase.HRS_Area__c , null );
        System.assertEquals( verifyCase.HRS_Sub_Area__c , null );
 
    }

    @isTest static void HRS_TestHRS_Case_HRS_Bulkfiy() {

        TestHRS_Env_Setup.CreateHRSEnv();

        test.startTest();

        List<Case> caseList = new List<Case>();

        for ( Integer i = 0; i < 102; i++ ){
            Integer rand = integer.valueof( Math.random()*3 );

            Case c = new Case();
            if ( i == 0 )
                c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get('Shared Services AP').getRecordTypeId();       
            if ( i == 1 )
                c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get('HR - Hire/Rehire/Transfer In').getRecordTypeId();       
            if ( i == 2 )
                c.recordtypeId = TestHRS_Env_Setup.mRtInfo.get('HR - Generic').getRecordTypeId();       

            c.Type = 'New Hire';
            c.subject = 'I have a new hire starts tomorrow' + i ;
            c.Description = 'Here is the description for the new Hire' + i ;
            c.HRS_Org_Department__c = TestHRS_Env_Setup.OrgDepartMap.get('40.CORPORATE.D67.4071');           
            caseList.add( c );

        }

        insert caseList;

        test.stopTest();

        Case verifyCaseHR = [select Id, HRS_Operating_Group__c, HRS_Strategic_Business_Unit__c, HRS_Area__c, HRS_Sub_Area__c, HRS_Org_Department__c from case where recordtypeId =: TestHRS_Env_Setup.mRtInfo.get('HR - Hire/Rehire/Transfer In').getRecordTypeId() limit 1];

        Case verifyCaseNotHR = [select Id, HRS_Operating_Group__c, HRS_Strategic_Business_Unit__c, HRS_Area__c, HRS_Sub_Area__c, HRS_Org_Department__c from case where recordtypeId =: TestHRS_Env_Setup.mRtInfo.get('Shared Services AP').getRecordTypeId() limit 1];

        HRS_Org_Department__c orgDept = [ select Id, Name, HRS_Operating_Group__c, HRS_Strategic_Business_Unit__c, HRS_Area__c, HRS_Sub_Area__c from HRS_Org_Department__c where Id =: verifyCaseHR.HRS_Org_Department__c ];

        System.assertEquals( verifyCaseHR.HRS_Operating_Group__c , orgDept.HRS_Operating_Group__c );
        System.assertEquals( verifyCaseHR.HRS_Strategic_Business_Unit__c , orgDept.HRS_Strategic_Business_Unit__c );
        System.assertEquals( verifyCaseHR.HRS_Area__c , orgDept.HRS_Area__c );
        System.assertEquals( verifyCaseHR.HRS_Sub_Area__c , orgDept.HRS_Sub_Area__c );

        System.assertEquals( verifyCaseNotHR.HRS_Operating_Group__c , null );
        System.assertEquals( verifyCaseNotHR.HRS_Strategic_Business_Unit__c , null );
        System.assertEquals( verifyCaseNotHR.HRS_Area__c , null );
        System.assertEquals( verifyCaseNotHR.HRS_Sub_Area__c , null );
        System.assertEquals( verifyCaseNotHR.HRS_Sub_Area__c , null );


    }

}