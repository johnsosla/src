/***********************************************************************************************************
PR          :  PR-06193
Requester   :  Karishma Sharma
Author      :  Appirio Offshore (Sumit)
Date        :  Sept 15, 2010  Change 3/16/2011
Purpose     :  The trigger does following-
               1. Set Master Contract Number for the specified Master Contract 
               2. Set Lead District, Lead Region and Geography based on specied AECOM Primary Department
               3. Validate and Set Country(ProjectCountry__c)
**********************************************************************************************************/
trigger OpportunityBeforeInsertBeforeUpdate on Opportunity (Before Insert, Before Update) 
{
    // check if we not need to run trigger if data loading operation is performed
    ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('OpportunityBeforeInsertBeforeUpdate');
    if(ext != null) {
        if(ext.NotRunTrigger__c) {
            return;    
        }
        
    }
    
    System.debug('*********@@@SUMIT IN Opportunity Before Insert/Update Trigger*******************');
    System.debug('IS INSERT OPERATION : '+ Trigger.IsInsert + '*** IS BEFORE OPERATION : ' + Trigger.IsBefore);
    
    Set<id> setOpp = new Set<id>();
    Set<String> deptNames = new Set<String>();
    Set<String> employeeIds = new Set<String>();

    //User currentuser=TaskOrderRollup.getCurrentUser();
    for(Opportunity opp : Trigger.New)
    {
        //--------Added by Radial Web 21 March 2014 Set Oracle Project manager --------
        if (opp.Oracle_PM_Employee_ID__c != null) employeeIds.add(opp.Oracle_PM_Employee_ID__c);
        
        if(Trigger.isInsert) {
            opp.AECOM_Primary_Department_Percent__c = 100;
        }
        
        //------------------------------------------------------------//
        //Added sumit for task -T-12240
        //if(opp.sub_practice_area_eu__c!=null)
        //    opp.practice_area__c = opp.sub_practice_area_eu__c;
        //------------------------------------------------------------------
        // prepare set of Master Contracts
        if(opp.Master_Contract_lookup__c!=null)
        {
            if(Trigger.IsInsert)
                setOpp.add(opp.Master_Contract_lookup__c);
             else If(opp.Master_Contract_lookup__c!=Trigger.OldMap.get(Opp.Id).Master_Contract_lookup__c)
                setOpp.add(opp.Master_Contract_lookup__c);
        }
        // prepare set of AECOM Primary Deppts
        if(opp.AECOM_Primary_Dept_Lookup__c != null)
        {
             if(Trigger.IsInsert)
                deptNames.add(opp.AECOM_Primary_Dept_Lookup__c);
             else If(opp.AECOM_Primary_Dept_Lookup__c != Trigger.OldMap.get(Opp.Id).AECOM_Primary_Dept_Lookup__c)
                deptNames.add(opp.AECOM_Primary_Dept_Lookup__c);
        }         
    }
    //Set Master Contract Number
    if(setOpp.size()>0)
    {
        Map<id,Opportunity> mapOpp = new Map<id,Opportunity>([Select id,Client_Solicitation_ID_number__c,Master_Contract_Number__c,RecordTypeId from  Opportunity where id in:setOpp ]);
        //Code By Sumit related to Task Order Parent Validation...
        Map<Id,RecordType> mapidRecordType = TaskOrderRollup.getOpportunityRecordtypeMapById();
     
        for(Opportunity opp:Trigger.New)
        {
            if(opp.Master_Contract_lookup__c!=null)
            {
                Opportunity OppMaster = mapOpp.get(opp.Master_Contract_lookup__c);
                if(OppMaster!=null)
                {
                    RecordType newOppRT = mapidRecordType.get(opp.RecordTypeId);
                    RecordType parentOppRT = mapidRecordType.get(OppMaster.RecordTypeId);
                    if(newOppRT!=null && parentOppRT!=null)
                    {
                        if(newOppRT.DeveloperName.toLowerCase().indexof('task')>=0 && 
                           parentOppRT.DeveloperName.toLowerCase().indexof('program')<0)
                        {
                            opp.addError('Please select Opportunity of type Program as a Master Contract'); 
                        }
                    }
                    Opp.Master_Contract_Number_Program__c = OppMaster.Master_Contract_Number__c;
                    Opp.Master_Contract_Number__c = OppMaster.Master_Contract_Number__c;
                    if(Trigger.isinsert)
                        Opp.Client_Solicitation_ID_number__c = OppMaster.Client_Solicitation_ID_number__c;
                }
            }
        }
    }
    //--------------------------------------------------------------------------------------------------------------
    // Set Lead District, Lead Region and Geography 
    /*if(deptNames.size()>0)
    {
        Map<String,AECOM_Primary_Department__c> departmentsMap=new Map<String,AECOM_Primary_Department__c>();
        for(AECOM_Primary_Department__c department:[Select ID,Lead_District__c,Lead_Region__c,Geography__c from AECOM_Primary_Department__c where ID in :deptNames])
        {
            departmentsMap.put(department.ID,department);
        }
        for(Opportunity op:Trigger.new)
        {
            AECOM_Primary_Department__c department=departmentsMap.get(op.AECOM_Primary_Dept_Lookup__c);
            if(department !=null)
            {
                op.Lead_District__c = department.Lead_District__c;
                op.Lead_Region__c = department.Lead_Region__c;
                op.Geography__c = department.Geography__c;
            }
        }
    }*/
    //--------------------------------------------------------------------------------------------------------------
    // validate country
    Map<string,string> StateCountry= new Map<string,string>();
    List<ValidState__c> lstStates = TaskOrderRollup.getStateList();
    
    
    for(ValidState__c state:lstStates)
    {
        if(state.Country__c!=null)
            StateCountry.put(state.Name.toLowerCase(),state.Country__c.tolowerCase());
    }
    
    //--------Added by Radial Web 21 March 2014 Set Oracle Project manager --------
    Map<String, AECOM_Employee__c > hrMap = new Map<String, AECOM_Employee__c >();
    List<AECOM_Employee__c> hrEmployees = [SELECT ID, Employee_ID__c FROM AECOM_Employee__c WHERE Employee_ID__c IN :employeeIds];
    for (AECOM_Employee__c emp : hrEmployees) hrMap.put(emp.Employee_ID__c, emp);
    //--------Added by Radial Web 04 April 2014 Set Record Type Text --------
    Map<ID, RecordType> rtMap = TaskOrderRollup.getOpportunityRecordtypeMapById(); 
	//--end Radial
	//
    for(Opportunity opp:Trigger.New)
    {
        //--------Added by Radial Web 21 March 2014 Set Oracle Project manager --------
        if (opp.Oracle_PM_Employee_ID__c == null && opp.Oracle_Project_Manager__c != null) {
            opp.Oracle_Project_Manager__c = null;
        } else if (opp.Oracle_PM_Employee_ID__c != null) {
            AECOM_Employee__c hrEmp = hrMap.get(opp.Oracle_PM_Employee_ID__c);
            if (hrEmp != null) {
                opp.Oracle_Project_Manager__c = hrEmp.ID;
            } else {
                opp.Oracle_Project_Manager__c = null;
            }         
        }
        //--end Radial
        //--------Added by Radial Web 04 April 2014 Set Record Type Text --------
        RecordType rt = rtMap.get(opp.RecordTypeId);
        if (rt != null) {
            opp.RecordTypeText__c = rt.Name;
        }
        //--end Radial
        
        Opp.Master_Contract_Number_Program__c = Opp.Master_Contract_Number__c;
        
        if(TaskOrderRollup.getOpportunityRecordtypeMapById().get(Opp.RecordTypeId).Name.Indexof('Asia')>=0)
            continue;
        
        if(Opp.Project_State_Province__c !=null)
        {
            List<string>states = Opp.Project_State_Province__c.split(';');
            Set<string> diffCountries = new Set<string>();
            for(string st:states)
            {
                if(st!=null)
                {
                    if(StateCountry.get(st.trim().toLowerCase()) != null)
                         diffCountries.add(StateCountry.get(st.trim().toLowerCase()));       
                }
            }
            // If more than one country selected.. show error message
            if(diffCountries.size()>1)
            {
                opp.addError(System.label.MULTICOUNTRY);
            }
            else if(diffCountries.size()==1)
            {
                for(string s : diffCountries)
                {
                    if(s == 'us')
                        Opp.ProjectCountry__c = 'United States';
                    else
                        Opp.ProjectCountry__c = s;
                }
            }
        }
    }

    System.debug('*********@@@SUMIT OUT Opportunity Before Insert/Update Trigger*******************');
    System.debug('IS INSERT OPERATION : '+ Trigger.IsInsert + '*** IS BEFORE OPERATION : ' + Trigger.IsBefore);
}