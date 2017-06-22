public class OpportunityTriggerHandler {
	public static Boolean runAfterUpdate = true;

	public OpportunityTriggerHandler() {}

	public static void handleBeforeInsert(List<Opportunity> opps) {
		// OpportunityBeforeInsertBeforeUpdate Before Insert
		// check if we not need to run trigger if data loading operation is performed
	    ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('OpportunityBeforeInsertBeforeUpdate');
	    if(ext != null) {
	        if(ext.NotRunTrigger__c) {
	            return;    
	        }
	        
	    }
	    
	    Set<id> setOpp = new Set<id>();
	    Set<String> deptNames = new Set<String>();
	    Set<String> employeeIds = new Set<String>();
	    Set<String> projectCountries = new Set<String>();

	    //User currentuser=TaskOrderRollup.getCurrentUser();
	    for(Opportunity opp : opps)
	    {
	        //--------Added by Radial Web 21 March 2014 Set Oracle Project manager --------
	        if (opp.Oracle_PM_Employee_ID__c != null) employeeIds.add(opp.Oracle_PM_Employee_ID__c);
	        
	        /*Commented out as per 2492 - this is what was causing the percent for primary to always be a 100. Have not found a reason for this line.*/
	        //opp.AECOM_Primary_Department_Percent__c = 100;

	        
	        //------------------------------------------------------------//
	        //Added sumit for task -T-12240
	        //if(opp.sub_practice_area_eu__c!=null)
	        //    opp.practice_area__c = opp.sub_practice_area_eu__c;
	        //------------------------------------------------------------------
	        // prepare set of Master Contracts
	        if(opp.Master_Contract_lookup__c!=null)
	        {
	            setOpp.add(opp.Master_Contract_lookup__c);
	        }
	        // prepare set of AECOM Primary Deppts
	        if(opp.AECOM_Primary_Dept_Lookup__c != null)
	        {
	            deptNames.add(opp.AECOM_Primary_Dept_Lookup__c);
	        }   
	        // prepare countries
	        if(opp.ProjectCountry__c != null)
	        {
	        	projectCountries.add(opp.ProjectCountry__c);
	        }
	    }

        //12/16/2015 Steve MunLeeuw.  Bulkifying - Populate Region based on the Country. Lookup Country_Geography_Region_Mapping__c
        if(projectCountries.size()>0)
        {
        	List<Country_Geography_Region_Mapping__c> geographies = getGeographyRegions(projectCountries);
        	for(Opportunity opp:opps){
        		for(Country_Geography_Region_Mapping__c geo:geographies){
        			if(opp.ProjectCountry__c == geo.Country__c){
        				opp.Project_Geography_Region_New__c = geo.Geography_Region__c;
        			}
        		}
        	}
        }


	    //Set Master Contract Number
	    if(setOpp.size()>0)
	    {
	        Map<id,Opportunity> mapOpp = new Map<id,Opportunity>([Select id,Client_Solicitation_ID_number__c,Master_Contract_Number__c,RecordTypeId from  Opportunity where id in:setOpp ]);
	        //Code By Sumit related to Task Order Parent Validation...
	        Map<Id,RecordType> mapidRecordType = TaskOrderRollup.getOpportunityRecordtypeMapById();
	     
	        for(Opportunity opp:opps)
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
	                }
	            }
	        }
	    }
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
	    for(Opportunity opp:opps)
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
	    for(Opportunity opp : opps)
	    {
			system.debug('handleBeforeInsert -> closeDate - Estimated_work_start_date__c: ' + opp.closeDate + ' - ' + opp.Estimated_work_start_date__c);
	    }

	}

	public static void handleBeforeUpdate(Map<Id,Opportunity> newOpps, Map<Id,Opportunity> oldOpps) {
		// OpportunityBeforeInsertBeforeUpdate Before Update
		// check if we not need to run trigger if data loading operation is performed
	    ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('OpportunityBeforeInsertBeforeUpdate');
	    if(ext != null) {
	        if(ext.NotRunTrigger__c) {
	            return;    
	        }
	        
	    }
	    
	    Set<id> setOpp = new Set<id>();
	    Set<String> deptNames = new Set<String>();
	    Set<String> employeeIds = new Set<String>();	    
	    Set<String> projectCountries = new Set<String>();

	    //User currentuser=TaskOrderRollup.getCurrentUser();
	    for(Opportunity opp : newOpps.values())
	    {
	        //--------Added by Radial Web 21 March 2014 Set Oracle Project manager --------
	        if (opp.Oracle_PM_Employee_ID__c != null) employeeIds.add(opp.Oracle_PM_Employee_ID__c);
	        
	        //------------------------------------------------------------//
	        //Added sumit for task -T-12240
	        //if(opp.sub_practice_area_eu__c!=null)
	        //    opp.practice_area__c = opp.sub_practice_area_eu__c;
	        //------------------------------------------------------------------
	        // prepare set of Master Contracts
	        if(opp.Master_Contract_lookup__c!=null)
	        {
	            if(opp.Master_Contract_lookup__c != oldOpps.get(Opp.Id).Master_Contract_lookup__c)
	                setOpp.add(opp.Master_Contract_lookup__c);
	        }
	        // prepare set of AECOM Primary Deppts
	        if(opp.AECOM_Primary_Dept_Lookup__c != null)
	        {
	            if(opp.AECOM_Primary_Dept_Lookup__c != oldOpps.get(Opp.Id).AECOM_Primary_Dept_Lookup__c)
	                deptNames.add(opp.AECOM_Primary_Dept_Lookup__c);
	        }      

	        // prepare countries
	        if(opp.ProjectCountry__c != null)
	        {
	        	projectCountries.add(opp.ProjectCountry__c);
	        }
	    }

        //12/16/2015 Steve MunLeeuw.  Bulkifying - Populate Region based on the Country. Lookup Country_Geography_Region_Mapping__c
        if(projectCountries.size()>0)
        {
        	List<Country_Geography_Region_Mapping__c> geographies = getGeographyRegions(projectCountries);
        	for(Opportunity opp:newOpps.values()){
        		if(geographies.size()>0){
	        		for(Country_Geography_Region_Mapping__c geo:geographies){
	        			if(opp.ProjectCountry__c == geo.Country__c){
	        				opp.Project_Geography_Region_New__c = geo.Geography_Region__c;
	        			}
	        		}
        		}
        	}
        }

	    //Set Master Contract Number
	    if(setOpp.size()>0)
	    {
	        Map<id,Opportunity> mapOpp = new Map<id,Opportunity>([Select id,Client_Solicitation_ID_number__c,Master_Contract_Number__c,RecordTypeId from  Opportunity where id in:setOpp ]);
	        //Code By Sumit related to Task Order Parent Validation...
	        Map<Id,RecordType> mapidRecordType = TaskOrderRollup.getOpportunityRecordtypeMapById();
	     
	        for(Opportunity opp:newOpps.values())
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
	                }
	            }
	        }
	    }
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
	    for(Opportunity opp:newOpps.values())
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
	    for(Opportunity opp : newOpps.values())
	    {
			system.debug('handleBeforeUpdate -> closeDate - Estimated_work_start_date__c: ' + opp.closeDate + ' - ' + opp.Estimated_work_start_date__c);
	    }

	}

	private static String getGeographyRegion(String country)
	{
    	Country_Geography_Region_Mapping__c [] geographyRegions  = [SELECT Id, Geography_Region__c FROM Country_Geography_Region_Mapping__c WHERE Country__c = :country];        	
        if (geographyRegions.size() > 0)
			return geographyRegions[0].Geography_Region__c;
 		else 
        	return null;
	}

	private static List<Country_Geography_Region_Mapping__c> getGeographyRegions(Set<String> countries){
    	List<Country_Geography_Region_Mapping__c> geographyRegions  = [SELECT Id, Country__c, Geography_Region__c FROM Country_Geography_Region_Mapping__c WHERE Country__c IN :countries];

		return geographyRegions;
	}

	public static void handleBeforeDelete(Map<Id,Opportunity> newOpps, Map<Id,Opportunity> oldOpps) {
		//TaskOrderRollup Before Delete
		taskOrderBeforeDelete(newOpps, oldOpps);

		// Before Delete gng_OppToGNGC
		ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('Go/No Go');
		if(ext != null && !ext.NotRunTrigger__c) gng_OppToGNGC.deleteGNGFromOpportunity(oldOpps.keySet());	
	}

	private static void taskOrderBeforeDelete(Map<Id,Opportunity> newOpps, Map<Id,Opportunity> oldOpps) {
		// check if we not need to run trigger if data loading operation is performed
		ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('TaskOrderRollup');
		if(ext != null) {
			if(ext.NotRunTrigger__c) {
			  return;  
			}   
		}

		List<Opportunity> taskOrderOpportunityList = new List<Opportunity>(); 

		
		taskOrderOpportunityList  = oldOpps.values();

		Set<Id> parentOppList = new Set<Id>();
		List<id>childOpp = new List<id>();
		for(Opportunity opp:taskOrderOpportunityList) {
			if(opp.Master_Contract_Lookup__c!=null) {
				parentOppList.add(opp.Master_Contract_Lookup__c);
				childOpp.add(opp.id);
			}
			if(parentOppList.size() > 0 )
				TaskOrderRollup.calculateTaskOrderRollupTasks(parentOppList,childOpp);
		}
	}

	public static void handleAfterInsert(List<Opportunity> opps) {
		//ANZNotifyAccountManagers After Insert
		//TaskrelatedtoPrimaryDepartment After Insert
		//TaskOrderRollup After Insert
		//Adding After Insert for gng_OppToGNGC per AEGNG-192 
		System.debug('****** handleAfterInsert ******');
		List<Id> oppAcctIds = new List<Id>();
		List<Opportunity_Department__c> lstDept = new list<Opportunity_Department__c>();
		Set<Id> parentOppList = new Set<Id>();
		Map<String, List<Opportunity>> oppMap = new Map<String, List<Opportunity>>();
		try
	    {
	        String geography = [select Geography_Allocation__c from User where id = :UserInfo.getUserId()].Geography_Allocation__c;
	        for(Opportunity opp : opps) {
	        	oppAcctIds.add(opp.AccountId);
	        	System.debug('DebugMe:  opp.AECOM_Primary_Dept_Lookup__c - ' + opp.AECOM_Primary_Dept_Lookup__c);
	        	if(opp.AECOM_Primary_Dept_Lookup__c!=null)
	           	{
		           	//Opportunity_Department__c od = new Opportunity_Department__c(Opportunity__c = opp.Id,Split__c=100);
		           	Opportunity_Department__c od = new Opportunity_Department__c(Opportunity__c = opp.Id,Split__c=opp.AECOM_Primary_Department_Percent__c);

		           	od.AECOM_Department__c = opp.AECOM_Primary_Dept_Lookup__c;
		           	od.Primary__c = true;
		           	od.CurrencyISOCode = opp.CurrencyISOCode;

		           	/*ts only*/
		           	//od.Practice_Area__c = opp.Practice_Area_of_Primary_AECOM_Dept__c;

		           	lstDept.add(od);
		           	//GNG insert logic
		           	if(oppMap.containsKey(opp.Geography_Formula__c)) oppMap.get(opp.Geography_Formula__c).add(opp);
               		else oppMap.put(opp.Geography_Formula__c, new List<Opportunity>{opp});
	           	}
	           	
	           	if(opp.Master_Contract_Lookup__c != null) parentOppList.add(opp.Master_Contract_Lookup__c);
	           	if(parentOppList.size() > 0) TaskOrderRollup.calculateTaskOrderRollupTasks(parentOppList,new List<Id>());
	           	
	        }
	        /*
	        US-02492 - This adds the Opportunity Department, but currently this causes the triggers to fire too many times and an overage on the SOQL limit
	        */
	        if(lstDept.size()>0) insert lstDept;

	        if(geography == 'ANZ')
	        {
                //get account managers, client directors and client managers  from account team
                List<AECOM_team__c> team = [SELECT Account__c, Email__c, IsDeleted, Role__c, Employee_User__r.Country FROM AECOM_team__c
                                            WHERE  Account__c IN: oppAcctIds 
                                            AND (Role__c = 'Client Manager' OR Role__c =  'Account Manager' OR Role__c =  'Client Director')
                                            AND IsDeleted = false
                                            AND Employee_User__r.Country in ('Australia', 'New Zealand')];
                //System.debug('DebugMe:  team.size() - ' + team.size());
           
                //add team to list
                List<String> toAddresses = new List<String>();
                for(AECOM_team__c member : team)
                {
                	//System.debug('DebugMe:  member - ' + member);
                    toAddresses.add(member.Email__c);
                }
                
                for(Opportunity opp : opps)
                {
                	//System.debug('DebugMe:  opp - ' + opp);
	               	//Opportunity o = [select id from Opportunity where id = '006e0000005QhNz' limit 1];
	               	HelperMethods.sendTemplatedEmail(toAddresses, null, 'ANZ_Client_Bid_Activity_Template', null, opp.id, null, false, null);
	               	
	            }
	        }
	    for(Opportunity opp : opps)
	    {
			system.debug('handleAfterInsert -> closeDate - Estimated_work_start_date__c: ' + opp.closeDate + ' - ' + opp.Estimated_work_start_date__c);
	    }

	    }
    	catch (Exception e){
    		System.debug(e);
    		//System.debug('Exception stack trace: ' + e.getStackTraceString());
    	}
	}

	public static void handleAfterUpdate(Map<Id,Opportunity> newOpps, Map<Id,Opportunity> oldOpps) {
		// CurrencyChangereflect After Update
		// TaskOrderRollup After Update
		// TaskrelatedtoPrimaryDepartment After update
		// gng_OppToGNGC After update

		//System.debug('***SA-OpportunityTriggerHandler.handleAfterUpdate***');


		Set<id> oppSet = new Set<id>();
		List<Opportunity_Department__c> lstDept = new list<Opportunity_Department__c>();
        Map<id,Id> OppDeptNew = new Map<id,Id>();
        Map<id,Id> OppDeptOld = new Map<id,Id>();
        Map<id,Opportunity_Department__c> OppDeptNew1 = new Map<id,Opportunity_Department__c>();
        Set<Id> parentOppList = new Set<Id>();
        List<Go_No_Go_Conversation__c> existingGNGs = [select Opportunity__c from Go_No_Go_Conversation__c where Opportunity__c in: newOpps.keyset()];
        Set<Id> existingGNGOppIds = new Set<Id>();
        for(Go_No_Go_Conversation__c g : existingGNGs) {
        	existingGNGOppIds.add(g.Opportunity__c);
        }

        system.debug('DebugMe: newOpps.keyset() - ' + newOpps.keyset());
        system.debug('DebugMe: existingGNGOppIds - ' + existingGNGOppIds);
        system.debug('DebugMe: existingGNGs - ' + existingGNGs);
        //Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([select Id, Name from RecordType where sObjectType = 'Opportunity']);

		List<Opportunity> needToCreateGNG = new List<Opportunity>();
		List<Opportunity> needToUpdateGNG = new List<Opportunity>();

	    for(Opportunity opp : newOpps.values())
	    {
	        if(opp.CurrencyIsoCode != oldOpps.get(opp.id).CurrencyIsoCode)
	            oppSet.add(opp.Id);
	        if(opp.AECOM_Primary_Dept_Lookup__c != oldOpps.get(opp.Id).AECOM_Primary_Dept_Lookup__c && 
	        	!ModifyDepartmentController.NotRunOpportunityUpdateTrigger)
            {
                OppDeptNew.put(opp.id,opp.AECOM_Primary_Dept_Lookup__c);
                OppDeptOld.put(opp.id,oldOpps.get(opp.Id).AECOM_Primary_Dept_Lookup__c);
                OppDeptNew1.put(opp.Id,new Opportunity_Department__c(CurrencyISOCode = opp.CurrencyISOCode,Opportunity__c = opp.Id,Split__c=0,AECOM_Department__c=opp.AECOM_Primary_Dept_Lookup__c,Primary__c = true));
            }
            if(!existingGNGOppIds.contains(opp.Id)) needToCreateGNG.add(opp);
			else needToUpdateGNG.add(opp);

			if(opp.Master_Contract_Lookup__c!=null) parentOppList.add(opp.Master_Contract_Lookup__c);
			String oldparent = oldOpps.get(opp.Id).Master_Contract_Lookup__c;
			if(oldparent != null && oldParent !='' && opp.Master_Contract_Lookup__c!=oldparent) parentOppList.add(oldparent);
	    }

	    if(parentOppList.size() > 0) TaskOrderRollup.calculateTaskOrderRollupTasks(parentOppList,new List<id>());
	    if(oppSet.size()>0)
	    {
	    	list<Opportunity_Department__c> lstOppToUpdate = new list<Opportunity_Department__c>();

	        for(List<Opportunity_Department__c> lst:[Select id,Opportunity__c, CurrencyISOCode from 
	                                            Opportunity_Department__c where Opportunity__c in : oppSet])
	        {
	            for(Opportunity_Department__c od:lst)
	                od.CurrencyISOCode = newOpps.get(od.Opportunity__c).CurrencyISOCode;
	            //update lst;
	            lstOppToUpdate.addall(lst);
	        }

	        try{
	        	update lstOppToUpdate;
	        } catch( Exception e){
            	ECO_Service_ErrorLog.logException(e);
        	}
	    }

        if(OppDeptNew.keyset().size()>0)
        {
            for(Opportunity_Department__c opd:[Select id,Primary__c, AECOM_Department__c,Opportunity__c 
                                               from Opportunity_Department__c 
                                               Where Opportunity__c in :OppDeptNew.Keyset() and 
                                               (AECOM_Department__c in :OppDeptNew.Values() OR AECOM_Department__c in :OppDeptOld.Values())])
            {
                if(OppDeptNew.get(opd.Opportunity__c) == opd.AECOM_Department__c)
                {
                    opd.Primary__c = true;
                    OppDeptNew1.put(opd.Opportunity__c,opd);
                }
                if(OppDeptold.get(opd.Opportunity__c) == opd.AECOM_Department__c)
                {
                    opd.Primary__c = false;
                    lstDept.add(opd);
                }
            }
            for(id id1:OppDeptNew1.keyset())
            {
               lstDept.add(OppDeptNew1.get(id1)); 
            }
            upsert lstDept;
       	}

       	System.debug('***SA-OpportunityTriggerHandler.handleAfterUpdate - PreExecuteTrigger***');

       	ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('Go/No Go');

       	System.debug('***SA-OpportunityTriggerHandler.handleAfterUpdate - PostExecuteTrigger***');
       	//system.debug('DebugMe: createGNGFromOpportunity: '  + needToCreateGNG.size() + ' - ' + needToUpdateGNG.size() + ' - ' + ext.NotRunTrigger__c);

       	//Create GNG records
		if(needToCreateGNG.size() > 0 && ext != null && !ext.NotRunTrigger__c) {
			Map<String, List<Opportunity>> regionOppMap = new Map<String, List<Opportunity>>();

			for(Opportunity o : needToCreateGNG) {
				system.debug('DebugMe: o.Geography_Formula__c - ' + o.Geography_Formula__c);
				if(String.isNotBlank(o.Geography_Formula__c)) {
					if(!regionOppMap.keySet().contains(o.Geography_Formula__c)) regionOppMap.put(o.Geography_Formula__c, new List<Opportunity>{o});
					else regionOppMap.get(o.Geography_Formula__c).add(o);
				}
			}

			System.debug('***SA-OpportunityTriggerHandler.handleAfterUpdate - Pregng_OppToGNGC.createGNGFromOpportunity***' + regionOppMap);

			gng_OppToGNGC.createGNGFromOpportunity(regionOppMap);

			System.debug('***SA-OpportunityTriggerHandler.handleAfterUpdate - Postgng_OppToGNGC.createGNGFromOpportunity***');
		}
		//Update GNG records
		else if(needToUpdateGNG.size() > 0  && ext != null && !ext.NotRunTrigger__c) {
			Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
			for(Opportunity o : needToUpdateGNG) {
				if(String.isNotBlank(o.Geography_Formula__c)) oppMap.put(o.Id, o);
			}
			gng_OppToGNGC.updateGNGFromOpportunity(oppMap);
		}

		
	    //3990 : Synching of project with opportunity
	    //System.debug('3990- Begin synching of project with opportunity.');

	    map<Id,list<pse__Proj__c>> mapProjs = new map<Id,list<pse__Proj__c>>();
	    list<pse__Proj__c> listProjs = new list<pse__Proj__c>();
	    list<pse__Proj__c> listProjToUpdate = new list<pse__Proj__c>();

	    set<Id> opptSet = new set<Id>();

	    for(Opportunity opp : newOpps.values())
        {
        	OpptSet.add(opp.Id);
        }

	    try
	    {
	    	listProjs = [select Id, pse__Opportunity__c, Name, AECOMrole__c,RFPIssueDate__c,ProposalSubmittedDate__c,EstAwardDate__c,CaptureManagerUser__c,EstimatedStartDate__c,GoProbability__c,GetProbability__c,EstimatedContractValue__c,CapitalValue__c,TotalBidBudget__c,AECOMLabor__c,Subs__c,ODCs__c,SubsCost__c,ODCsCost__c,ContingencyCost__c from pse__Proj__c where pse__Opportunity__c IN :opptSet];
	    }
		catch( Exception e){
            ECO_Service_ErrorLog.logException(e);
        }	    

        for (pse__Proj__c prj:listProjs)
        {
        	if (!mapProjs.containskey(prj.pse__Opportunity__c))
        	{
        		mapProjs.put(prj.pse__Opportunity__c,new list<pse__Proj__c>());
        	}
        	mapProjs.get(prj.pse__Opportunity__c).add(prj);
        }

	    for(Opportunity opp : newOpps.values())
	    {
	    	if (!mapProjs.containskey(opp.Id))
	    	{
	    		continue;
	    	}


	    	for (pse__Proj__c p: mapProjs.get(opp.Id))
			{
				integer UpdateCount = 0;

				//compare fields
				if (p.AECOMrole__c != opp.AECOM_Role__c) 
				{
					p.AECOMrole__c = opp.AECOM_Role__c; 
					UpdateCount++;
				}
				if (p.RFPIssueDate__c != opp.Date_RFP_expected__c) 
				{
					p.RFPIssueDate__c = opp.Date_RFP_expected__c; 
					UpdateCount++;
				}
				if (p.ProposalSubmittedDate__c != opp.Submittal_Date_Proposal__c) 
				{
					//System.debug('p.ProposalSubmittedDate__c');
					p.ProposalSubmittedDate__c = opp.Submittal_Date_Proposal__c; 
					UpdateCount++;
				}
				//if (p.EstAwardDate__c != opp.Initial_Estimated_Award_Date__c) 
				if (p.EstAwardDate__c != opp.CloseDate) 
				{
					//p.EstAwardDate__c = opp.Initial_Estimated_Award_Date__c; 
					p.EstAwardDate__c = opp.CloseDate;
					UpdateCount++;
				}
				if (p.EstimatedStartDate__c != opp.Estimated_work_start_date__c) 
				{
					p.EstimatedStartDate__c = opp.Estimated_work_start_date__c; 
					UpdateCount++;
				}
				if (opp.Capture_Manager_User__c != null)
				{
					if (p.CaptureManagerUser__c != opp.Capture_Manager_User__c) 
					{
						//System.debug('p.CaptureManagerUser__c');
						p.CaptureManagerUser__c = opp.Capture_Manager_User__c; 

						list<contact> lstContact = new list<contact>();

		                try
		                {
		                	lstContact = [select id, name, pse__Salesforce_User__c from contact where pse__Salesforce_User__c =:p.CaptureManagerUser__c];
		                }
                        catch( Exception e)
                        { 
                            ECO_Service_ErrorLog.logException(e); 
                        }  		                

		                for(contact c: lstContact)
		                {
		                	if(c.id != null)
		                    {
		                        p.CaptureManager__c = c.id;
		                    }
		                }

						UpdateCount++;
					}
				}
				if (p.GoProbability__c != opp.Go_Probability__c) 
				{
					p.GoProbability__c = opp.Go_Probability__c; 
					UpdateCount++;
				}
				if (p.GoProbability__c != opp.Go_Probability__c) 
				{
					p.GoProbability__c = opp.Go_Probability__c; 
					UpdateCount++;
				}
				if (p.GetProbability__c != opp.Probability_Stage__c) 
				{
					p.GetProbability__c = opp.Probability_Stage__c; 
					UpdateCount++;
				}
				if (p.EstimatedContractValue__c != opp.Amount) 
				{
					p.EstimatedContractValue__c = opp.Amount; 
					UpdateCount++;
				}
				if (p.CapitalValue__c != opp.Construction_cost__c) 
				{
					p.CapitalValue__c = opp.Construction_cost__c; 
					UpdateCount++;
				}

				/*Removed as per request.
				if (opp.Subs_Other_Revenue__c != null)
				{
					Decimal split = opp.Subs_Other_Revenue__c/2;

					if (p.SubsCost__c != split)
						p.SubsCost__c = split;

					if (p.ODCsCost__c != split)
						p.ODCsCost__c = split;

					UpdateCount++;
				}
				*/
				
				//US-4943
				if (p.TotalBidBudget__c != opp.B_P_Budget__c)
				{
					p.AECOMLabor__c = opp.B_P_Budget__c;
					p.Subs__c = null;
					p.ODCs__c = null;

					UpdateCount++;
				}

				Decimal epmSubsOtherRevenue = 0;
				if (p.SubsCost__c != null)
					epmSubsOtherRevenue = p.SubsCost__c;
				if (p.ODCsCost__c != null)
					epmSubsOtherRevenue = epmSubsOtherRevenue + p.ODCsCost__c;
                //US-05343
				if (p.ContingencyCost__c != null)
					epmSubsOtherRevenue = epmSubsOtherRevenue + p.ContingencyCost__c;                

				if (epmSubsOtherRevenue != opp.Subs_Other_Revenue__c)
				{
					p.SubsCost__c = opp.Subs_Other_Revenue__c;
					p.ODCsCost__c = null;
                    p.ContingencyCost__c = null;

					UpdateCount++;
				}
		
				//UPDATE PROJECTS IF NEED BE
				if (UpdateCount>0)
				{
					listProjToUpdate.add(p);
				}

			}		    	

	    }

	    if (listProjToUpdate.size()>0)
	    {
	    	try
	    	{
	    		update listProjToUpdate;
			}
			catch (Exception e)
			{
				System.debug('3990- Exception: ' + e.getMessage());
			}
		}

		runAfterUpdate = false;
	}	        

	public static void handleAfterDelete(Map<Id,Opportunity> newOpps, Map<Id,Opportunity> oldOpps) {}	

	public static void handleAfterUndelete(List<Opportunity> opps) {}
}