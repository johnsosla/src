/*
*    Project Name        : eConnect
*    Project NameSpace   : HRS
*    Description         : Apex Class to Insertion/Updation of Case Records
*                        : This class will only called by case trigger.
*/

Public Class HRS_CaseHandler{

    //create a mapping for case record type
    //public static Map<String, Schema.RecordTypeInfo> mRtInfo = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
    public static Set<Id> hrsRTInfo = new Set<Id>();

    /*   Method to validate if the case record type is HR only
    *    @param RecordtypeId : Id
    *    return: if HR Case record type true, otherwise false
    */ 
    public static Boolean checkifHRCase (  Id recordtypeId  ){

        //assume the case is not a HR case
        Boolean isHRCase = false;

        if ( hrsRTInfo.size() == 0 ){
            List<RecordType> rtCaseList =  [ SELECT Id FROM RecordType where sobjectType = 'Case' and DeveloperName like '%HR_%' ];
            hrsRTInfo = ( new Map<Id, RecordType>( rtCaseList ) ).keySet();
        }

        if ( hrsRTInfo.contains( recordtypeId ) )
            isHRCase = true;

        return isHRCase;
    }

    /*   Method to copy Area field from Contact and update case Region
    *    @param CaseList: list of the case records
    *    return: void 
    */  
    public static void autoPopulateRegionEntitlementOnCase (  List<Case> CaseList  ){

        Set<Id> ContactIDSet = new Set<Id>();
        List<Contact> ContactList = new List<Contact>();
        Map<Id, String> ContactReportToMap = new Map<Id, String>();
        List<EntitlementContact> ECList = new List<EntitlementContact>();
        Map<Id, Id> ECmap = new Map<Id, Id>();

        for ( Case hrCase : CaseList ){
            if ( hrCase.ContactId != null && checkifHRCase ( hrCase.RecordTypeId ) )
                ContactIDSet.add( hrCase.ContactId );
        }

        // Copying Contact Region to Case Record
        if ( ContactIDSet.size() > 0 ){
            ContactList = [select Id, ReportsTo.Name, MailingCountry from Contact where id in : ContactIDSet ];

            for ( Contact c : ContactList){
                ContactReportToMap.put( c.Id, c.ReportsTo.Name );

            }


            for ( Case hrCase : CaseList ){
                if ( checkifHRCase ( hrCase.RecordTypeId ) && hrCase.ContactId != null && ContactReportToMap.get( hrCase.ContactId ) != null )
                    hrCase.Supv_Name__c = ContactReportToMap.get( hrCase.ContactId );
            }
        }


        // Copying Contact Entitlement Record to Case Record
        if ( ContactIDSet.size() > 0  ) {
            ECList = [ SELECT ContactId, EntitlementId FROM EntitlementContact WHERE ContactId in : ContactIDSet];

            for ( EntitlementContact ec : ECList){
                ECmap.put( ec.ContactId , ec.EntitlementId );
            }

            for ( Case hrCase : CaseList ){
                if ( checkifHRCase ( hrCase.RecordTypeId ) && hrCase.ContactId != null && ECmap.get( hrCase.ContactId ) != null )
                    hrCase.EntitlementId = ECmap.get( hrCase.ContactId );
            }            
        }

    }

    /*   Method to auto populate selected picklist value if the Org Dept is definded
    *    @param CaseList: list of the case records
    *    return: void 
    */  
    public static void autoPopulateSelectionValueOnCase( List<Case> CaseList, Map<Id, Case> oldMap ){

        //To store only Hr case we need to work with
        List<Case> HrCaseList = new List<Case>();
        //To store only values that you want to predefine
        List<Case> PreDefinedCaseList = new List<Case>();
        //To store Set of OrgDeptID
        Set<Id> OrgDeptIdSet = new Set<Id>();

        //Capture only the record type for HR and add into the list and SetId
        for ( Case hrCase : CaseList ){

            if ( checkifHRCase ( hrCase.RecordTypeId ) ){                 
                if ( oldMap != null ){
                    Case oldCase = oldMap.get( hrCase.Id);

                    if ( hrCase.HRS_Org_Department__c != null && hrCase.HRS_Org_Department__c != oldCase.HRS_Org_Department__c ) { 
                        HrCaseList.add( hrCase );
                        PreDefinedCaseList.add( hrCase );
                        OrgDeptIdSet.add( hrCase.HRS_Org_Department__c );
                    }

                } else {

                    if ( hrCase.HRS_Org_Department__c != null  ) { 
                        HrCaseList.add( hrCase );
                        PreDefinedCaseList.add( hrCase );
                        OrgDeptIdSet.add( hrCase.HRS_Org_Department__c );
                    }
                    
                }
            }
        }

        //Creating a Map for Org Dept requested for this update
        Map<Id, HRS_Org_Department__c> OrgDeptDataList = new Map<Id, HRS_Org_Department__c>( [ select Id, HRS_Operating_Group__c, HRS_Strategic_Business_Unit__c, HRS_Area__c, HRS_Sub_Area__c, HRS_Geography__c from HRS_Org_Department__c where id in: OrgDeptIdSet ]);


        //We are assuming the field is empty and begin backfilling the data 
        //Only looping the HR Case
        for ( Case caseToPreFill : HrCaseList ){

            //ensure the map is not empty and ensure each element is not null before backfilling
            //Error handling as data might not be always there?

            if ( OrgDeptDataList.get( caseToPreFill.HRS_Org_Department__c ) != null  ){
 
                if ( OrgDeptDataList.get( caseToPreFill.HRS_Org_Department__c ).HRS_Operating_Group__c != null ){
                    caseToPreFill.HRS_Operating_Group__c = OrgDeptDataList.get( caseToPreFill.HRS_Org_Department__c ).HRS_Operating_Group__c;
                }

                if ( OrgDeptDataList.get( caseToPreFill.HRS_Org_Department__c ).HRS_Strategic_Business_Unit__c != null ){
                    caseToPreFill.HRS_Strategic_Business_Unit__c = OrgDeptDataList.get( caseToPreFill.HRS_Org_Department__c ).HRS_Strategic_Business_Unit__c;
                }

                if ( OrgDeptDataList.get( caseToPreFill.HRS_Org_Department__c ).HRS_Area__c != null ){
                    caseToPreFill.HRS_Area__c = OrgDeptDataList.get( caseToPreFill.HRS_Org_Department__c ).HRS_Area__c;
                }

                if ( OrgDeptDataList.get( caseToPreFill.HRS_Org_Department__c ).HRS_Sub_Area__c != null ){
                    caseToPreFill.HRS_Sub_Area__c = OrgDeptDataList.get( caseToPreFill.HRS_Org_Department__c ).HRS_Sub_Area__c;
                } 

                if ( OrgDeptDataList.get( caseToPreFill.HRS_Org_Department__c ).HRS_Geography__c != null ){
                    caseToPreFill.Geography__c = OrgDeptDataList.get( caseToPreFill.HRS_Org_Department__c ).HRS_Geography__c;
                }                                   
            }        
        }

    }

    /*   Method to pre populate HR System Code after Organization
    *    @param CaseList: list of the case records
    *    return: void 
    */  
    public static void autoPopulateHRSysCodeOnCase ( List<Case> CaseList, Map<Id, Case> oldMap ){
        //creating a list with all the HRS system key
        List<HRS_Job_Code_Key_Info__c> HRSystemKeyList = [select HRS_HR_System__c, HRS_Geography__c, HRS_Operating_Group__c from HRS_Job_Code_Key_Info__c ];
        //Mapping of Geo & OperatingGroup, System Key
        Map<String, String> SystemKeyMapping = new Map<String, String>();
        //Putting the Geo & OperatingGroup, System Key into Mapping
        for ( HRS_Job_Code_Key_Info__c key : HRSystemKeyList ){
            SystemKeyMapping.put( key.HRS_Geography__c+key.HRS_Operating_Group__c , key.HRS_HR_System__c );
        }
        //Loop through all the case record
        for ( Case hrCase : CaseList ){
            //first validate if it HR case
            if ( checkifHRCase ( hrCase.RecordTypeId ) ) { 
                if ( oldMap != null ){
                    Case oldCase = oldMap.get( hrCase.Id);
                //Update the HR system key, if org department has been changed
                if ( oldMap != null && hrCase.HRS_Org_Department__c != oldCase.HRS_Org_Department__c  &&
                     SystemKeyMapping.get( hrCase.Geography__c + hrCase.HRS_Operating_Group__c ) != null ) { 
                    hrCase.HR_System_Key__c = SystemKeyMapping.get( hrCase.Geography__c + hrCase.HRS_Operating_Group__c );
                } else if ( SystemKeyMapping.get( hrCase.Geography__c + hrCase.HRS_Operating_Group__c ) != null )
                    hrCase.HR_System_Key__c = SystemKeyMapping.get( hrCase.Geography__c + hrCase.HRS_Operating_Group__c );
                }

            }                    
        }

    }

    /*   Method to pre populate Contact info into Case record
    *    Case field and contact field is one to one mapping
    *    @param CaseList: list of the case records
    *    return: void 
    */  
    public static void autoPopulateContactInfoOnCase ( List<Case> CaseList ){

        List<String> case_fields = new List<String>{ 'Adjusted_Service_Dates__c','Business_Card_Title__c','Corporate_Title__c','Employee_Category__c','Employee_Number__c','Expat_Inpat_TCN_Status__c','First_Name__c','Hire_Date_First_Day_Worked__c','Last_Name__c',
                                                     'Middle_Name__c','HRS_Operating_Group__c','Preferred_First_Name__c','Project_Job_Title__c','Service_Line__c','HRS_Strategic_Business_Unit__c','HRS_Sub_Area__c','Supervisor_Employee_ID__c','Supervisor_Tracking_ID__c',
                                                     'Termination_Date__c','Tracking_ID__c','Work_Email__c','Work_Phone__c','Region__c','Name_Suffix__c','HRS_Area__c' };
        List<String> contact_fields = new List<String>{ 'Adjusted_Service_Date__c','Business_Card_Title__c','Corporate_Title__c','Employee_Category__c','Employee_Number__c','International_Assignment_Status__c','firstname','Original_Hire_Date__c','lastname',
                                                        'Middle_Names__c','Level2Org__c','Preferred_Name__c','JobName__c','Service_Line__c','Level3Org__c','Level5Org__c','ManagerID__c','Supervisor_Tracking_Id__c','EffectiveEndDate__c','TrackingID__c','Email',
                                                        'OtherPhone','MailingCountry','Suffix__c','Level4Org__c'};
        
        Set<String> officeNameSet = new Set<String>();
        Map<Id, String> contactOfficeNameMap = new Map<Id, String>();
        Map<Id, Id> contactOfficeIdMap = new Map<Id, Id>();
        Map<String, Id> officeNameMap = new Map<String, Id>();

        Set<Id> contactIDSet = new Set<Id>();
        Map<String, String> caseContactMap = new Map<String, String>();

        for ( Case hrCase : CaseList ){ 
            if ( hrCase.ContactId != null && checkifHRCase ( hrCase.RecordTypeId ) )
                contactIDSet.add( hrCase.ContactId );
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>([select Adjusted_Service_Date__c,Business_Card_Title__c,Corporate_Title__c,Employee_Category__c,Employee_Number__c,International_Assignment_Status__c,firstname,Original_Hire_Date__c,lastname,Middle_Names__c,
                                                            Level2Org__c,Preferred_Name__c,JobName__c,Service_Line__c,Level3Org__c,Level5Org__c,ManagerID__c,Supervisor_Tracking_Id__c,EffectiveEndDate__c,TrackingID__c,Email,OtherPhone,MailingCountry, Suffix__c,
                                                            Level4Org__c, Office__c from Contact where Id =: contactIDSet ]);

        for ( Integer i = 0; i < case_fields.size(); i++ ){
            caseContactMap.put( case_fields[i], contact_fields[i] );
        }

        for ( Contact con : contactMap.values() ){
            if ( con.Office__c != null ){
                officeNameSet.add( con.Office__c );
                contactOfficeNameMap.put( con.Id , con.Office__c );
            }
        }

        if ( officeNameSet.size() > 0 ){

            List<HRS_Office_Location__c> olList = [ select Id, Name from HRS_Office_Location__c where name =: officeNameSet ];

            for ( HRS_Office_Location__c hrsol : olList ){
                officeNameMap.put( hrsol.Name, hrsol.Id );
            }

            for ( Id contactId : contactOfficeNameMap.keySet() ){
                if ( contactOfficeNameMap.get( contactId ) != null &&  officeNameMap.get( contactOfficeNameMap.get( contactId ) ) != null  )
                    contactOfficeIdMap.put( contactId , officeNameMap.get( contactOfficeNameMap.get( contactId ) ) );
            }
        }

        for ( Case hrCase : CaseList ){ 
            //for static case field
            for ( String s : case_fields ){
                if ( caseContactMap.get(s) != null && contactMap.get( hrCase.ContactID ) != null && contactMap.get( hrCase.ContactID ).get( caseContactMap.get(s) ) != null )
                    hrCase.put( s, contactMap.get( hrCase.ContactID ).get( caseContactMap.get(s) ));
            }
            //for office loaction
            if ( officeNameSet.size() > 0 && contactOfficeIdMap != null && contactOfficeIdMap.get( hrCase.ContactID ) != null ){
                hrCase.put( 'Office_Location__c' , contactOfficeIdMap.get( hrCase.ContactID ) );
            }
        }
    }

    /*   Method to pre populate Employee API into Case record
    *    it uses future call method as trigger can't initiate http calls
    *    @param CaseList: list of the case records
    *    return: void 
    */ 
    public static void autoPopulateFromAPIData( List<Case> CaseList ){

        Set<Id> caseIDSet = new Set<Id>();

        for ( Case hrCase : CaseList ){
            if ( hrCase.ContactId != null && checkifHRCase ( hrCase.RecordTypeId ) ){
                caseIDSet.add( hrCase.Id );
            }
        }

        processFromAPIData( caseIDSet );
    }

    /*   Method to pre populate Employee API into Case record
    *    it uses future call method as trigger can't initiate http calls
    *    @param CaseList: list of the case records
    *    return: void 
    */ 
    @Future(callout=true)
    public static void processFromAPIData( Set<Id> CaseIdList ){

        String key = '';
        String fid = '';        

        try { 
            User user = [select Id, ShaKey__c, FederationIdentifier from User where Id = :UserInfo.getUserId()];
            key = user.ShaKey__c;
            fid = user.FederationIdentifier;     
        } catch (Exception ex ){
            System.debug('This user doesn\'t exist: ' + ex.getMessage());            
        }   

        Set<String> numberFieldsSet = new Set<String>{'salaryIncreasePercent'};

        List<Case> caseList = [ select Id, Tracking_ID__c, Type, Workers_Comp_Code__c  from Case where Id =: CaseIdList ];
        ECO_IntegrationEndpoints__c employeeEP, caseEP;
        employeeEP = ECO_IntegrationEndpoints__c.getInstance('HRS_EMPLOYEE');

        List<Case> updateCase = new List<Case>();

        for ( Case hrsCase : caseList ) { 

            List<HRS_API__mdt> hrsList = [select Id, CaseAPI__c, Field__c, FieldType__c from HRS_API__mdt where CaseAPI__c != '' and CaseType__c =: hrsCase.Type and isActive__c = true];

            HRSWorker autoWorker = new HRSWorker();
            autoWorker.baseUrl = employeeEP.EndPointUrl__c;

            for ( HRS_API__mdt mdt : hrsList ){
                autoWorker.fieldsList.add( mdt.Field__c );
            }

            if ( autoWorker.fieldsList.size() > 0 ){ 
                autoWorker.dynamicQuery = '?$select=' + String.join ( autoWorker.fieldsList, ',');
                autoWorker.resultRsp = ECO_Service_Authentication.DynamicProxyRequestNew( autoWorker.baseUrl +'(\''+ hrsCase.Tracking_ID__c +'\')' + autoWorker.dynamicQuery , key, 'eConnect', false, false, 120000, fid, null, null );
                if ( autoWorker.resultRsp != null &&  autoWorker.resultRsp.getbody() != '' )            
                    autoWorker.keyValueMap = JSON2Employee.parseValue( autoWorker.resultRsp.getbody() );

                for ( HRS_API__mdt mdt : hrsList ){

                    if ( autoWorker.keyValueMap.get(mdt.Field__c) != null && mdt.FieldType__c != 'Date' && numberFieldsSet.contains( mdt.Field__c ) )
                        hrsCase.put( mdt.CaseAPI__c , autoWorker.keyValueMap.get(mdt.Field__c) ) ;
                    if ( autoWorker.keyValueMap.get(mdt.Field__c) != null && mdt.FieldType__c != 'Date' && !numberFieldsSet.contains( mdt.Field__c ) )
                        hrsCase.put( mdt.CaseAPI__c , String.valueOf( autoWorker.keyValueMap.get(mdt.Field__c) ) ) ;
                    if ( autoWorker.keyValueMap.get(mdt.Field__c) != null && mdt.FieldType__c == 'Date' ){
                        //2015-01-01
                        String[] dateStr = String.valueOf( autoWorker.keyValueMap.get(mdt.Field__c) ).split('-');
                        Date myDate = date.newinstance(Integer.valueOf(dateStr[0]), Integer.valueOf(dateStr[1]), Integer.valueOf(dateStr[2]));
                        hrsCase.put( mdt.CaseAPI__c , myDate );
                    }

                }

                updateCase.add( hrsCase );
            }
        }

        try { 
            if ( updateCase.size() > 0 )
                update updateCase; 
        } catch ( Exception ex ){
            System.debug('The following exception has occurred: ' + ex.getMessage());
        }
    }    
  
}