/** ------------------------------------------------------------------------------------------------------
* @Description 
*
* @Author Omar.Abdellatief@nttdata.com, Arman.Shah@nttdata.com
* @Date September 2016
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_BudgetResourceTriggers {
	public static Boolean run = true;

    public static Decimal setScaling(Decimal val) {
        return setScaling(val, 2);
    }

    public static Decimal setScaling(Decimal val, Integer precision) {
        val = val == null ? 0 : val;
        val = val.setScale(precision);
        return val;
    }

	/**
	 * @Description A way to identify projects using indirect rates other than company approved indirect rates.
	 *          Check if any of the Burden Rate fields change, and have different values from their CreatedDate.
	 *
	 * @Author  NTT Data - Arman.Shah@nttdata.com
	 * @Date    September 2016
	 *
	 * @param	oldBudgetResourceMap
	 * @param	newBudgetResourceMap
	 * @return 
	 **/
    public static void areBurdenRatesRevised(Map<Id, BudgetResource__c> oldBudgetResourceMap, 
    	Map<Id, BudgetResource__c> newBudgetResourceMap) {

    	Set<Id> budgetHeaderIds = new Set<Id>();
    	try {
	    	for (BudgetResource__c br : oldBudgetResourceMap.values()) {
	    		BudgetResource__c brNew = newBudgetResourceMap.get(br.Id);
	    		System.debug('___br.createdDate='+br.createdDate+', brNew.lastModifiedDate='+brNew.lastModifiedDate);
	    		
	    		/* #US-04170 Although these values are Currency(16, 2), they are stored as Floating Points; thus 
					we have to round them up before comparing, to ensure that the change was made by a User, and not the System.
	    		*/
	    		Decimal brOverrideFringeMultiplier = setScaling(br.OverrideFringeMultiplier__c);
		        Decimal brOverrideFringeMultiplierField = setScaling(br.OverrideFringeMultiplierField__c);  
		        Decimal brOverrideOverheadMultiplier = setScaling(br.OverrideOverheadMultiplier__c);
		        Decimal brOverrideOverheadMultiplierField = setScaling(br.OverrideOverheadMultiplierField__c);  

	    		Decimal brNewOverrideFringeMultiplier = setScaling(brNew.OverrideFringeMultiplier__c);
		        Decimal brNewOverrideFringeMultiplierField = setScaling(brNew.OverrideFringeMultiplierField__c);  
		        Decimal brNewOverrideOverheadMultiplier = setScaling(brNew.OverrideOverheadMultiplier__c);
		        Decimal brNewOverrideOverheadMultiplierField = setScaling(brNew.OverrideOverheadMultiplierField__c);  
	        
				if ( (brNewOverrideFringeMultiplier != brOverrideFringeMultiplier) ||
					 (brNewOverrideOverheadMultiplier != brOverrideOverheadMultiplier) ||
		       		 (brNewOverrideFringeMultiplierField != brOverrideFringeMultiplierField) ||
		        	 (brNewOverrideOverheadMultiplierField != brOverrideOverheadMultiplierField) )
		        {
		        	brNew.IsBurdenRateRevised__c = true;
		        	System.debug('___BurdenRate Revised for BudgetResource '+br.Id);
		        	budgetHeaderids.add(br.BudgetHeader__c);

		        	System.debug('___brNew.OverrideFringeMultiplier__c=' + brNewOverrideFringeMultiplier +
		        		', br.OverrideFringeMultiplier=' + brOverrideFringeMultiplier);

		        	System.debug('___brNew.OverrideOverheadMultiplier__c=' + brNewOverrideOverheadMultiplier +
		        		', br.OverrideOverheadMultiplier__c=' + brOverrideOverheadMultiplier);

		        	System.debug('___brNew.OverrideFringeMultiplierField__c=' + brNewOverrideFringeMultiplierField +
		        		', br.OverrideFringeMultiplierField__c=' + brOverrideFringeMultiplierField);

		        	System.debug('___brNew.OverrideOverheadMultiplierField__c=' + brNewOverrideOverheadMultiplierField +
		        		', br.OverrideOverheadMultiplierField__c=' + brOverrideOverheadMultiplierField);
				}
	    	}
	   	} 
    	catch (Exception e){
		    ECO_Service_ErrorLog.logException(e);
	    }

    	List<BudgetHeader__c> budgetHeaders = [SELECT Id, isBurdenRateRevised__c FROM BudgetHeader__c 
    		WHERE Id IN : budgetHeaderIds];

    	List<BudgetHeader__c> budgetHeadersTemp = new List<BudgetHeader__c>();
    	for (BudgetHeader__c bh : budgetHeaders) {
			bh.isBurdenRateRevised__c = true; // cross-object field update
		    budgetHeadersTemp.add(bh);
		}

    	if (budgetHeadersTemp.size() > 0) {
	    	try {
	    		update budgetHeadersTemp;
	    	} 
	    	catch (Exception e){
			    ECO_Service_ErrorLog.logException(e);
		    }
		}
    }

	/**
	 * @Description
	 *
	 * @Author  NTT Data - <author> - <author email>
	 * @Date    <create date month and year>
	 *
	 * @param	oBudgetResource
	 * @param	oBudgetAssignment
	 * @return 	Boolean
	 **/
    public static Boolean areRatesEqual(BudgetResource__c oBudgetResource, BudgetAssignment__c oBudgetAssignment) {
		if (oBudgetAssignment.OverrideRawCost__c != oBudgetResource.OverrideRawCost__c) return false;
        if (oBudgetAssignment.OverrideFringeMultiplier__c != oBudgetResource.OverrideFringeMultiplier__c) return false;
        if (oBudgetAssignment.OverrideOverheadMultiplier__c != oBudgetResource.OverrideOverheadMultiplier__c) return false;
        if (oBudgetAssignment.OverrideUplift__c != oBudgetResource.OverrideUplift__c) return false;
        if (oBudgetAssignment.MarginType__c != oBudgetResource.MarginType__c) return false;
        if (oBudgetAssignment.OverrideBillRate__c != oBudgetResource.OverrideBillRate__c) return false;
        if (oBudgetAssignment.OverrideFringeMultiplierField__c != oBudgetResource.OverrideFringeMultiplierField__c) return false;
        if (oBudgetAssignment.OverrideOverheadMultiplierField__c != oBudgetResource.OverrideOverheadMultiplierField__c) return false;
        if (oBudgetAssignment.SetZeroETC__c != oBudgetResource.SetZeroETC__c) return false;
        return true;
    }

	/**
	 * @Description
	 *
	 * @Author  NTT Data - <author> - <author email>
	 * @Date    <create date month and year>
	 *
	 * @param	oBudgetResource
	 * @param	oBudgetAssignment
	 * @return 	BudgetAssignment__c
	 **/
    public static BudgetAssignment__c setRatesEqual(BudgetResource__c oBudgetResource, BudgetAssignment__c oBudgetAssignment) {
    	if (oBudgetResource.OverrideRatesOnLines__c) {
	        oBudgetAssignment.OverrideRawCost__c = oBudgetResource.OverrideRawCost__c;
	        oBudgetAssignment.MarginType__c = oBudgetResource.MarginType__c;
	        oBudgetAssignment.OverrideBillRate__c = oBudgetResource.OverrideBillRate__c;
	        oBudgetAssignment.OverrideUplift__c = oBudgetResource.OverrideUplift__c;
	        oBudgetAssignment.SetZeroETC__c = oBudgetResource.SetZeroETC__c;

        	if (oBudgetAssignment.OracleRateScheduleName__c == null || oBudgetAssignment.OracleRateScheduleName__c == '') { 
    	        oBudgetAssignment.OverrideFringeMultiplier__c = oBudgetResource.OverrideFringeMultiplier__c;
    	        oBudgetAssignment.OverrideOverheadMultiplier__c = oBudgetResource.OverrideOverheadMultiplier__c;
    	        oBudgetAssignment.OverrideFringeMultiplierField__c = oBudgetResource.OverrideFringeMultiplierField__c;
    	        oBudgetAssignment.OverrideOverheadMultiplierField__c = oBudgetResource.OverrideOverheadMultiplierField__c;
            }
		}

        return oBudgetAssignment;
    }

	/**
	 * @Description
	 *
	 * @Author  NTT Data - <author> - <author email>
	 * @Date    <create date month and year>
	 *
	 * @param	mBudgetResources - 
	 * @return 	void
	 **/
    public static void setDefaultValues (map<Id, BudgetResource__c> mBudgetResources){
        list<BudgetAssignment__c> lBudgetAssignmentsToUpdate = new list<BudgetAssignment__c>();

        system.debug(mBudgetResources);
        
        for(BudgetAssignment__c oBudgetAssignment : [SELECT id, BudgetResource__c, 
        														OverrideRawCost__c, 
        														OverrideFringeMultiplier__c,
        														OverrideOverheadMultiplier__c,
        														OverrideFringeMultiplierField__c,
        														OverrideOverheadMultiplierField__c,
        														MarginType__c,
        														OverrideBillRate__c,
        														OverrideUplift__c,
        														SetZeroETC__c,
        														OracleRateScheduleName__c
        														FROM BudgetAssignment__c WHERE BudgetResource__c in :mBudgetResources.keySet() ]) {

            BudgetResource__c oBudgetResource = mBudgetResources.get(oBudgetAssignment.BudgetResource__c);
            
            //ARMAN: system.debug(oBudgetResource);
            
            if (oBudgetResource.OverrideRatesOnLines__c && !areRatesEqual(oBudgetResource, oBudgetAssignment) ) {
                setRatesEqual(oBudgetResource, oBudgetAssignment);
                
                system.debug(oBudgetAssignment);
                
                lBudgetAssignmentsToUpdate.add(oBudgetAssignment);
            }
        }

	    //  system.debug('___lBudgetAssignmentsToUpdate='+lBudgetAssignmentsToUpdate);
	    // Disables triggers from running when Budget Assignment rollups retrigger Budget Resources
	    run = false;
	    ECO_TriggerSettings.bypassTrigger('BA');
	    try {
	    	update lBudgetAssignmentsToUpdate;
	    } catch (Exception e){
		    ECO_Service_ErrorLog.logException(e);
	    }
    	ECO_TriggerSettings.clearBypassTrigger('BA'); 
    	run = true;
        
    }
    
	/**
	 * runs before insert
	 *
	 * @Author  NTT Data - <author> - <author email>
	 * @Date    <create date month and year>
	 *
	 * @param	budResToDefault - 
	 * @return 	void
	 **/
	public static void defaultCostRevenueValuesOnHeader (List<BudgetResource__c> budResToDefault) {
		if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('BR_setDefaults')) {
			return;
		}
		Set<Id> allBudgetHeaderIds = new Set<Id>();
		Set<Id> allResourceIds = new Set<Id>();
		Set<String> allExpenditureTypes = new Set<String>();
		
		
		for (BudgetResource__c br : budResToDefault) {
			allBudgetHeaderIds.add(br.BudgetHeader__c);
			allResourceIds.add(br.ProjectTeamMember__c);
			allExpenditureTypes.add(br.ExpenditureType__c);
		}
		
		Map<Id, BudgetHeader__c> headerMap = new Map<Id, BudgetHeader__c>([SELECT Id 
																					, Project__r.DefaultUpliftLabor__c
																					, Project__r.DefaultUpliftSubs__c
																					, Project__r.DefaultUpliftODCs__c
                                                                           			, Project__r.DefaultMarginType__c
                                                                           			//DJO added 4/25/2016
                                                                           			, project__r.ProjectFunctionalCurrencyCode__c 
																			FROM BudgetHeader__c
																			WHERE Id IN :allBudgetHeaderIds]);
																			
		Map<Id, ProjectTeamMember__c> resourceMap = new Map<Id, ProjectTeamMember__c>([SELECT Id
																								, Contact__r.pse__Default_Cost_Rate__c
																								, Contact__r.ExpenditureType__c
																								, Contact__r.currencyIsoCode
																						FROM ProjectTeamMember__c
																						WHERE Id IN :allResourceIds]);
		
		for (BudgetResource__c br : budResToDefault) {
			BudgetHeader__c thisBH = headerMap.get(br.BudgetHeader__c);
			
			if (thisBH != null) {
                if(thisBH.Project__r.DefaultMarginType__c == 'T&M Direct Labour Multiplier') {
                    br.MarginType__c = 'Multiplier';
                }
                
				if (br.OverrideUplift__c == null || br.OverrideUplift__c == 0.00) {
            		if ('Labor/Person'.equalsIgnoreCase(br.ResourceType__c)) {
						br.OverrideUplift__c = thisBH.Project__r.DefaultUpliftLabor__c;
					} else if ('Subcontractor'.equalsIgnoreCase(br.ResourceType__c)) {
						br.OverrideUplift__c = thisBH.Project__r.DefaultUpliftSubs__c;
					} else if ('ODC/FEE'.equalsIgnoreCase(br.ResourceType__c)) {
						br.OverrideUplift__c = thisBH.Project__r.DefaultUpliftODCs__c;
            		}
				}
            	
				// Old style, we replaced this with the stuff above
				//br.OverrideUplift__c = thisBH.Project__r.DefaultUplift__c;
			}
			
			ProjectTeamMember__c thisResource = resourceMap.get(br.ProjectTeamMember__c);
			
			if (thisResource != null) {
				
				if (br.OverrideRawCost__c == null) {
					//DJO 4/27/2016 issue #4278
					br.OverrideRawCost__c = ECO_Utils_Math.ifNull(thisResource.Contact__r.pse__Default_Cost_Rate__c) 
										* ECO_Service_ExchangeRate.getExchangeRate(thisResource.Contact__r.currencyIsoCode, thisBH.Project__r.ProjectFunctionalCurrencyCode__c, Date.today()); 
				}
				
				br.ExpenditureType__c = thisResource.Contact__r.ExpenditureType__c;
			}
			
			
			// TODO:  These are totally temporary and need to be replaced with the burden schedule complex logic
			/*
			if (br.ResourceType__c == 'Labor/Person') {
				br.OverrideFringeMultiplier__c = 50;
				br.OverrideOverheadMultiplier__c = 50;
			}
			*/
			
			br.OverrideRatesOnLines__c = true;
			
		}
	}

	/**
	 * @Description
	 *
	 * @Author  NTT Data - <author> - <author email>
	 * @Date    <create date month and year>
	 *
	 * @param	brNew - 
	 * @return 	void
	 **/
	public static void setCurrency(List<BudgetResource__c> brNew) {
    	if (!run) {
    		return;
    	}
		
		Set<Id> bhIds = new Set<Id>();
		Map<Id, String> mapCurrencies = new Map<Id, String>();

		for (BudgetResource__c br : brNew) {
			bhIds.add(br.BudgetHeader__c);
		}   
		 	
    	// Get project currency
        for (BudgetHeader__c budgetHeader : [Select Id, Project__r.ProjectFunctionalCurrencyCode__c From BudgetHeader__c Where Id In :bhIds]) {
        	mapCurrencies.put(budgetHeader.Id, budgetHeader.Project__r.ProjectFunctionalCurrencyCode__c);
        }

        for (BudgetResource__c br : brNew) {
        	br.CurrencyIsoCode = mapCurrencies.get(br.BudgetHeader__c);
        }
    }

	/**
	 * @Description
	 *
	 * @Author  NTT Data - <author> - <author email>
	 * @Date    <create date month and year>
	 *
	 * @param	brNew - 
	 * @return 	void
	 **/
	public static void calculateMultiplier(List<BudgetResource__c> brNew) {
		if (!run) {
			return;
		}

		// ALERT - this table currently has 55 entries and it's easier to load the whole thing than to try and map
		// by OU ID, but if the table gets a lot bigger, or if there are dupes between orgs, then the mapping will have
		// to happen

		List<BurdenReference__c> references = [select id, Home_Field__c, Schedule__c, OU_ID__c from BurdenReference__c];

		Map<String, Set<String>> referenceMap = new Map<String, Set<String>>();

		for (BurdenReference__c reference : references) {
			String key = reference.Schedule__c + '~' + reference.OU_ID__c;

			Set<String> newSet = referenceMap.get(key);

			if (newSet == null) {
				newSet = new Set<String>();
				referenceMap.put(key, newSet);
			}

			newSet.add(reference.Home_Field__c);

			System.debug('referenceMap - ' + reference.id + ' - ' + reference.Schedule__c + ' - ' + reference.Home_Field__c);
		}

		Set<Id> resourceIds = new Set<Id>();
		Set<Id> headerIds = new Set<Id>();

		for (BudgetResource__c br : brNew) {
			resourceIds.add(br.Resource__c);
			headerIds.add(br.BudgetHeader__c);
		}

		List<Contact> resources = [select id, User__r.ECO_OrgId__c, User__c, User__r.ExpenditureType__c, User__r.ECO_OUID__c from Contact where id in :resourceIds];

		Set<Id> userIds = new Set<Id>();

		for (Contact con : resources) {
			if ((con.User__r.ECO_OUID__c == null) || (con.User__r.ECO_OUID__c.trim().equals(''))) {
				userIds.add(con.User__c);

				continue;
			}

			if ((con.User__r.ECO_OrgId__c == null) || (con.User__r.ECO_OrgId__c.trim().equals(''))) {
				userIds.add(con.User__c);
			}
		}

		if (userIds.size() > 0) {
			List<User> updateUsers = [select id, ECO_OrganizationName__c from User where id in :userIds];
			
		    try {
				update updateUsers;
		    } catch (Exception e){
			    ECO_Service_ErrorLog.logException(e);
		    }

			resources = [select id, User__r.ECO_OrgId__c, User__c, User__r.ExpenditureType__c, User__r.ECO_OUID__c from Contact where id in :resourceIds];
		}

		Map<Id, String> expenditureMap = new Map<Id, String>();

		Set<String> orgIds = new Set<String>();
		Set<String> needed = new Set<String>();

		Map<Id, String> contactOrgMap = new Map<Id, String>();
		Map<Id, String> contactOUIdMap = new Map<Id, String>();

		for (Contact resource : resources) {
			expenditureMap.put(resource.id, resource.User__r.ExpenditureType__c);
			orgIds.add(resource.User__r.ECO_OrgId__c);
			needed.add(resource.User__r.ECO_OrgId__c);
			contactOrgMap.put(resource.id, resource.User__r.ECO_OrgId__c);
			contactOUIdMap.put(resource.id, resource.User__r.ECO_OUID__c);
		}

		for (BudgetResource__c budgetResource : brNew) {
			orgIds.add(budgetResource.ProjectOrgId__c);
			needed.add(budgetResource.ProjectOrgId__c);
		}
		List<BudgetHeader__c> headers = [select id, Project__c, Project__r.CarryingOutOrganization__r.OrgId__c, Project__r.CarryingOutOrganization__r.OUID__c
                                                                           			, Project__r.MultiLineBurdening__c from BudgetHeader__c where id in :headerIds];

		Map<Id, String> orgMap = new Map<Id, String>();
		Map<Id, String> ouIdMap = new Map<Id, String>();
		Map<String, String> parentMap = new Map<String, String>();
		Set<Id> projectIds = new Set<Id>();
		Map<Id, Id> projectIdMap = new Map<Id, Id>();

		for (BudgetHeader__c header : headers) {
			orgIds.add(header.Project__r.CarryingOutOrganization__r.OrgId__c);
			needed.add(header.Project__r.CarryingOutOrganization__r.OrgId__c);
			orgMap.put(header.id, header.Project__r.CarryingOutOrganization__r.OrgId__c);
			ouIdMap.put(header.id, header.Project__r.CarryingOutOrganization__r.OUID__c);

			projectIds.add(header.Project__c);
			projectIdMap.put(header.Project__c, header.id);
		}

		Map<Id, ProjectBurdenMultiplierRequest__c> customMap = new Map<Id, ProjectBurdenMultiplierRequest__c>();

		List<ProjectBurdenMultiplierRequest__c> customRequests = [select id, Project__c, OracleBurdenScheduleName__c, OracleBurdenScheduleNameField__c, EffectiveFrom__c, EffectiveTo__c from ProjectBurdenMultiplierRequest__c where Project__c in :projectIds order by LastModifiedDate];

		Set<String> customScheduleNames = new Set<String>();

		for (ProjectBurdenMultiplierRequest__c customRequest : customRequests) {
			if ((customRequest.EffectiveFrom__c != null) && (customRequest.EffectiveFrom__c > Date.today()))
				continue;

			if ((customRequest.EffectiveTo__c != null) && (customRequest.EffectiveTo__c < Date.today()))
				continue;

			customMap.put(projectIdMap.get(customRequest.Project__c), customRequest);

			if ((customRequest.OracleBurdenScheduleName__c != null) && (!customRequest.OracleBurdenScheduleName__c.trim().equals(''))) {
				customScheduleNames.add(customRequest.OracleBurdenScheduleName__c);
			}

			if ((customRequest.OracleBurdenScheduleNameField__c != null) && (!customRequest.OracleBurdenScheduleNameField__c.trim().equals(''))) {
				customScheduleNames.add(customRequest.OracleBurdenScheduleNameField__c);
			}
		}		

/*
		List<BurdenSchedule__c> customSchedules = [select id, OracleRateScheduleName__c, CostCode__c, Multiplier__c, CostPlusStructure__c from BurdenSchedule__c where OracleRateScheduleName__c in :customScheduleNames];

		Map<String, List<BurdenSchedule__c>> customScheduleMap = new Map<String, List<BurdenSchedule__c>>();

		for (BurdenSchedule__c schedule : customSchedules) {
			List<BurdenSchedule__c> thelist = customScheduleMap.get(schedule.OracleRateScheduleName__c);

			if (thelist == null) {
				thelist = new List<BurdenSchedule__c>();
				customScheduleMap.put(schedule.OracleRateScheduleName__c, thelist);
			}

			thelist.add(schedule);
		}		
*/		

		List<Burden_Org_Hierarchy__c> hierarchy = [select organization_id__c, parent_organization_id__c from burden_org_hierarchy__c where organization_id__c in :needed];

		while (hierarchy.size() > 0) {
			needed = new Set<String>();

			for (Burden_Org_Hierarchy__c level : hierarchy) {
				System.debug('here - ' + level.organization_id__c + ' - ' + level.parent_organization_id__c);

				orgIds.add(level.organization_id__c);

				if (level.parent_organization_id__c != null) {
					needed.add(level.parent_organization_id__c);

					parentMap.put(level.organization_id__c, level.parent_organization_id__c);

					System.debug('putting parent map - ' + level.organization_id__c + ' - ' + level.parent_organization_id__c);
				}
			}

			hierarchy = [select organization_id__c, parent_organization_id__c from burden_org_hierarchy__c where organization_id__c in :needed and organization_id__c not in :orgIds];
		}

		orgIds.addAll(needed);

		List<BurdenSchedule__c> schedules = [select id, OracleRateScheduleName__c, CostCode__c, Multiplier__c, OrgId__c from BurdenSchedule__c where OrgId__c in :orgIds and ((((EffectiveFromDate__c = null) or (EffectiveFromDate__c <= TODAY)) and ((EffectiveToDate__c = null) or (EffectiveToDate__c >= TODAY))) or (OracleRateScheduleName__c in :customScheduleNames))];

		Set<String> costCodes = new Set<String>();
		Map<String, List<BurdenSchedule__c>> costCodeMap = new Map<String, List<BurdenSchedule__c>>();

		for (BurdenSchedule__c schedule : schedules) {
			costCodes.add(schedule.CostCode__c);

			List<BurdenSchedule__c> theList = costCodeMap.get(schedule.OrgId__c);

			if (theList == null) {
				theList = new List<BurdenSchedule__c>();
				costCodeMap.put(schedule.OrgId__c, theList);
			}

			theList.add(schedule);
		}

		List<BurdenStructure__c> structures = [select id, CostPlusStructure__c, ExpenditureType__c, CostCode__c from BurdenStructure__c where CostCode__c in :costCodes and CostPlusStructure__c != null];

		Set<String> costPlusStructures = new Set<String>();

		Map<String, List<BurdenStructure__c>> structureMap = new Map<String, List<BurdenStructure__c>>();

		for (BurdenStructure__c structure : structures) {
			costPlusStructures.add(structure.CostPlusStructure__c);

			String key = structure.CostCode__c + '~' + structure.ExpenditureType__c;

			List<BurdenStructure__c> theList = structureMap.get(key);

			if (theList == null) {
				theList = new List<BurdenStructure__c>();
				structureMap.put(key, theList);
			}

			theList.add(structure);
		}

		List<BurdenSchedule__c> schedules2 = [select id, OracleRateScheduleName__c, CostPlusStructure__c, OrgId__c from BurdenSchedule__c where CostPlusStructure__c in :costPlusStructures and OrgId__c in :orgIds];


		Map<String, List<BurdenSchedule__c>> rateNameMap = new Map<String, List<BurdenSchedule__c>>();

		for (BurdenSchedule__c schedule : schedules2) {
			String key = schedule.CostPlusStructure__c + '~' + schedule.OracleRateScheduleName__c + '~' + schedule.OrgId__c;

			List<BurdenSchedule__c> theList = rateNameMap.get(key);

			if (theList == null) {
				theList = new List<BurdenSchedule__c>();
				rateNameMap.put(key, theList);
			}

			theList.add(schedule);
		}

		List<BudgetHeader__c> headersx = [select id, Project__r.MultiLineBurdening__c from BudgetHeader__c where id in :headerIds];

		Map<Id, Boolean> multiLineMap = new Map<Id, Boolean>();

		for (BudgetHeader__c header : headersx) {
			multiLineMap.put(header.id, header.Project__r.MultiLineBurdening__c);
		}

		for (BudgetResource__c resource : brNew) {
			if(resource.OverrideFringeMultiplier__c == null) resource.OverrideFringeMultiplier__c = 0.0;
			if(resource.OverrideOverheadMultiplier__c == null) resource.OverrideOverheadMultiplier__c = 0.0;
			if(resource.OverrideFringeMultiplierField__c == null) resource.OverrideFringeMultiplierField__c = 0.0;
			if(resource.OverrideOverheadMultiplierField__c == null) resource.OverrideOverheadMultiplierField__c = 0.0;

			if (resource.ResourceType__c != 'Labor/Person') continue;
			Boolean multiLine = multiLineMap.get(resource.BudgetHeader__c);

			System.debug('processing resource - ' + resource);
			System.debug('multiline - ' + multiLine);

			String expenditureType;
			if (resource.Resource__c == null) {
				expenditureType = multiLine ? 'LAB - Professional' : 'LAB - Global Labour 07';
			} else {
				expenditureType = expenditureMap.get(resource.Resource__c);
			}

			System.debug('expenditureType - ' + expenditureType);

			if (expenditureType == null)
				continue;

			Decimal OverrideFringeMultiplier = null;
			Decimal OverrideOverheadMultiplier = null;
			Decimal OverrideFringeMultiplierField = null;
			Decimal OverrideOverheadMultiplierField = null; 	

			String OverrideFringeMultiplierSource = null;
			String OverrideOverheadMultiplierSource = null;
			String OverrideFringeMultiplierFieldSource = null;
			String OverrideOverheadMultiplierFieldSource = null;

			String headerOuID = ouIdMap.get(resource.BudgetHeader__c);
			String contactOuID = (resource.Resource__c == null) ? resource.ProjectOUId__c : contactOUIdMap.get(resource.Resource__c);

			String orgId = null;

			if (headerOuID == null)
				throw new ECO_BurdenMultiplierException('Missing Header OU ID' + resource.BudgetHeader__c);

			if (contactOuID == null)
				throw new ECO_BurdenMultiplierException('Missing Contact OU ID' + resource.Resource__c);

			String useOuID = headerOuID;

			if (headerOuID.equals(contactOuID)) {
				orgId = orgMap.get(resource.BudgetHeader__c);
			} else {
				orgId = (resource.Resource__c == null) ? resource.ProjectOrgId__c : contactOrgMap.get(resource.Resource__c);
				useOuID = contactOuID;
				System.debug('*** cross-charging *** -- ' + headerOuID + ' - ' + contactOuID + ' - ' + orgId);
			}

//			while ((OverrideFringeMultiplier == null) || (OverrideOverheadMultiplier == null) || (OverrideFringeMultiplierField == null) || (OverrideOverheadMultiplierField == null)) {
//				if (orgId == null)
//					break;

			while (orgId != null) {

				List<BurdenSchedule__c> codeList = costCodeMap.get(orgId);

				if (codeList == null) {
					orgId = parentMap.get(orgId);
					System.debug('no code list found - going to parent - ' + orgId);

					continue;
				}

				ProjectBurdenMultiplierRequest__c customRequest = customMap.get(resource.BudgetHeader__c);

				if (customRequest != null) {
					BurdenSchedule__c found = null;

					for (BurdenSchedule__c code : codeList) {
						if (customRequest.OracleBurdenScheduleName__c == null)
							continue;

						if (code.OracleRateScheduleName__c == null)
							continue;

						if (customRequest.OracleBurdenScheduleName__c.equals(code.OracleRateScheduleName__c)) {
							found = code;

							break;
						}
					}

					if (found != null) {
						codeList = new List<BurdenSchedule__c>();
						codeList.add(found);
						
					} else {
						orgId = parentMap.get(orgId);
						System.debug('no code list found for custom - going to parent - ' + orgId);

						continue;
					}
				}

				System.debug('codeList size - ' + codeList.size());

				for (BurdenSchedule__c schedule : codeList) {
//					if ((OverrideFringeMultiplier != null) && (OverrideOverheadMultiplier != null) && (OverrideFringeMultiplierField != null) && (OverrideOverheadMultiplierField != null))
//						break;

					String code = schedule.CostCode__c;

					if (code == null) 
						continue;

					String key2 = code + '~' + expenditureType;

					List<BurdenStructure__c> burdenStructureList = structureMap.get(key2);

					if (burdenStructureList == null)
						continue;

					System.debug('burdenStructureList size  - ' + burdenStructureList.size());	

					for (BurdenStructure__c structure : burdenStructureList) {
//						if ((OverrideFringeMultiplier != null) && (OverrideOverheadMultiplier != null) && (OverrideFringeMultiplierField != null) && (OverrideOverheadMultiplierField != null))
//							break;

						String key1 = structure.CostPlusStructure__c + '~' + schedule.OracleRateScheduleName__c + '~' + orgId;

						List<BurdenSchedule__c> rateNames = rateNameMap.get(key1);

						if (rateNames == null)
							continue;

						System.debug('rateNames size - ' + rateNames.size());

						for (BurdenSchedule__c schedule2 : rateNames) {
//							if ((OverrideFringeMultiplier != null) && (OverrideOverheadMultiplier != null) && (OverrideFringeMultiplierField != null) && (OverrideOverheadMultiplierField != null))
//								break;

							String rateName = schedule2.OracleRateScheduleName__c;

							String keyx = rateName + '~' + useOuID;

							Set<String> rateNameLookup = referenceMap.get(keyx);

							if (rateNameLookup == null)
								continue;

							Boolean foundOne = false;

							if (rateNameLookup.contains('HOME_OFFICE')) {
								if (code.containsIgnoreCase('fringe')) {
									if (OverrideFringeMultiplier == null) {
										OverrideFringeMultiplier = schedule.Multiplier__c;

										System.debug('set home office/fringe to ' + schedule.Multiplier__c);
										foundOne = true;

										OverrideFringeMultiplierSource = rateName;
									} else if (OverrideFringeMultiplierSource.startsWithIgnoreCase(rateName + '_M') && (!multiLine)) { // previous was multiline, project is single line
										OverrideFringeMultiplier = schedule.Multiplier__c;

										System.debug('set home office/fringe single line to ' + schedule.Multiplier__c);
										foundOne = true;

										OverrideFringeMultiplierSource = rateName;
									} else if (rateName.startsWithIgnoreCase(OverrideFringeMultiplierSource + '_M') && multiLine) {  // previous was single line, project is multiline
										OverrideFringeMultiplier = schedule.Multiplier__c;

										System.debug('set home office/fringe multiline to ' + schedule.Multiplier__c);
										foundOne = true;

										OverrideFringeMultiplierSource = rateName;
									}
								} else if (code.containsIgnoreCase('overhead')) {
									if (OverrideOverheadMultiplier == null) {
										OverrideOverheadMultiplier = schedule.Multiplier__c;

										System.debug('set home office/overhead to ' + schedule.Multiplier__c);
										foundOne = true;

										OverrideOverheadMultiplierSource = rateName;
									} else if (OverrideOverheadMultiplierSource.startsWithIgnoreCase(rateName + '_M') && (!multiLine)) {
										OverrideOverheadMultiplier = schedule.Multiplier__c;

										System.debug('set home office/overhead single line to ' + schedule.Multiplier__c);
										foundOne = true;

										OverrideOverheadMultiplierSource = rateName;

									} else if (rateName.startsWithIgnoreCase(OverrideOverheadMultiplierSource + '_M') && multiLine) {
										OverrideOverheadMultiplier = schedule.Multiplier__c;

										System.debug('set home office/overhead multiline to ' + schedule.Multiplier__c);
										foundOne = true;

										OverrideOverheadMultiplierSource = rateName;

									}
								}
							}

							if (rateNameLookup.contains('FIELD_OFFICE')) {
								if (code.containsIgnoreCase('fringe')) {
									if (OverrideFringeMultiplierField == null) {
										OverrideFringeMultiplierField = schedule.Multiplier__c;

										System.debug('set field office/fringe to ' + schedule.Multiplier__c);
										foundOne = true;

										OverrideFringeMultiplierFieldSource = rateName;
									} else if (OverrideFringeMultiplierFieldSource.startsWithIgnoreCase(rateName + '_M') && (!multiLine)) {
										OverrideFringeMultiplierField = schedule.Multiplier__c;

										System.debug('set field office/fringe single line to ' + schedule.Multiplier__c);
										foundOne = true;

										OverrideFringeMultiplierFieldSource = rateName;

									} else if (rateName.startsWithIgnoreCase(OverrideFringeMultiplierFieldSource + '_M') && multiLine) {
										OverrideFringeMultiplierField = schedule.Multiplier__c;

										System.debug('set field office/fringe multiline to ' + schedule.Multiplier__c);
										foundOne = true;

										OverrideFringeMultiplierFieldSource = rateName;

									}
								} else if (code.containsIgnoreCase('overhead')) {
									if (OverrideOverheadMultiplierField == null) {
										OverrideOverheadMultiplierField = schedule.Multiplier__c;

										System.debug('set field office/overhead to ' + schedule.Multiplier__c);
										foundOne = true;

										OverrideOverheadMultiplierFieldSource = rateName;
									} else if (OverrideOverheadMultiplierFieldSource.startsWithIgnoreCase(rateName + '_M') && (!multiLine)) {
										OverrideOverheadMultiplierField = schedule.Multiplier__c;

										System.debug('set field office/overhead single line to ' + schedule.Multiplier__c);
										foundOne = true;

										OverrideOverheadMultiplierFieldSource = rateName;

									} else if (rateName.startsWithIgnoreCase(OverrideOverheadMultiplierFieldSource + '_M') && multiLine) {
										OverrideOverheadMultiplierField = schedule.Multiplier__c;

										System.debug('set field office/overhead multiline to ' + schedule.Multiplier__c);
										foundOne = true;

										OverrideOverheadMultiplierFieldSource = rateName;

									}
								}
							}

							if (foundOne) {
								System.debug('orgId - ' + orgId);
								System.debug('schedule - ' + schedule);
								System.debug('multiplier - ' + schedule.multiplier__c);
								System.debug('costCode - ' + code);
								System.debug('expenditureType matched - ' + expenditureType);
								System.debug('burdenStructure - ' + structure);
								System.debug('rateNames size - ' + rateNames.size());	
								System.debug('rateName - ' + rateName);
								System.debug('ratenamelookup - ' + rateNameLookup);
							}
						}
					}	
				}

				String oldOrgId = orgId;

				orgId = parentMap.get(orgId);

				if (orgId == null) {
					break;
				}

				if (orgId.equals(oldOrgId)) {
					System.debug('not right - the same parent and child - ' + orgId);

					break;
				}
			}

			resource.OverrideFringeMultiplier__c = (OverrideFringeMultiplier == null) ? 0.0 : 100.0 * OverrideFringeMultiplier;
			resource.OverrideOverheadMultiplier__c = (OverrideOverheadMultiplier == null) ? 0.0 : 100.0 * OverrideOverheadMultiplier;
			resource.OverrideFringeMultiplierField__c = (OverrideFringeMultiplierField == null) ? 0.0 : 100.0 * OverrideFringeMultiplierField;
			resource.OverrideOverheadMultiplierField__c = (OverrideOverheadMultiplierField == null) ? 0.0 : 100.0 * OverrideOverheadMultiplierField;
		}
	}
}