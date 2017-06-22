public class ECO_Service_Budget {

	/**
     * @Description 
     * @Author  NTT Data - Brent Kendall
     * @Date    1/30/2017
     *
     * @param 
     * @return  
     **/
	public static void rollUpValuesToProject(List<BudgetHeader__c> newBHList) {
		
		Set<Id> projectIds = new Set<Id>();
		for(BudgetHeader__c budgetHeader:newBHList) {
			projectIds.add(budgetHeader.Project__c);
		}

		//for(Id projectId:projectIds) {
		if(!System.isBatch() && !System.isFuture() && !System.isQueueable()) {
			ECO_Service_Budget.rollupValuesToProjectAsync(projectIds);
		}
		else {
			ECO_Service_Budget.rollupValuesToProject(projectIds);
		}
		//}

	}

	/**
     * @Description 
     * @Author  NTT Data - Brent Kendall
     * @Date    1/30/2017
     *
     * @param 
     * @return  
     **/

    public static void rollUpValuesToProject(List<BudgetHeader__c> newBHList, List<BudgetHeader__c> oldBHList) {
		
		Set<Id> projectIds = new Set<Id>();
		for(BudgetHeader__c budgetHeader:newBHList) {
			projectIds.add(budgetHeader.Project__c);
		}

		//for(Id projectId:projectIds) {
		if(!System.isBatch() && !System.isFuture() && !System.isQueueable()) {
			ECO_Service_Budget.rollupValuesToProjectAsync(projectIds);
		}
		else {
			ECO_Service_Budget.rollUpValuesToProject(projectIds);
		}
		//}
    }

    @future
    public static void rollupValuesToProjectAsync(Set<Id> projectIds) {
    	ECO_Service_Budget.rollUpValuesToProject(projectIds);
    }

	
	public static void rollUpValuesToProject(Set<Id> projectIds) {

		Map<Id, pse__Proj__c> projectsToUpdate = new Map<Id, pse__Proj__c>([select Id, TotalApprovedRevenue__c, TotalApprovedCost__c, TotalForecastRevenue__c, TotalForecastCost__c, 
																				BudgetStrategyRevenue__c from pse__Proj__c where Id in :projectIds]);

		List<Id> projectLevelStategyProjects = new List<Id>();
		List<Id> topTaskLevelStrategyProjects = new List<Id>();

		if(!projectsToUpdate.values().isEmpty()) {

			for(pse__Proj__c projectToUpdate:projectsToUpdate.values()) {
				projectToUpdate.TotalApprovedRevenue__c = 0;
				projectToUpdate.TotalApprovedCost__c = 0;
				projectToUpdate.TotalForecastRevenue__c = 0;
				projectToUpdate.TotalForecastCost__c = 0;

				if(projectToUpdate.BudgetStrategyRevenue__c == 'Project Level') {
					projectLevelStategyProjects.add(projectToUpdate.Id);
				}
				else {
					topTaskLevelStrategyProjects.add(projectToUpdate.Id);
				}
			}

			//Approved Calculation
			for (BudgetHeader__c bh : [SELECT Project__c, AppliedTotalRevenue__c, TotalCost__c 		
										FROM BudgetHeader__c WHERE Project__c in :projectsToUpdate.keySet()		
											AND Status__c = 'Approved']) {
				pse__Proj__c projectToUpdate = projectsToUpdate.get(bh.Project__c);
				projectToUpdate.TotalApprovedRevenue__c = bh.AppliedTotalRevenue__c + projectToUpdate.TotalApprovedRevenue__c;
				projectToUpdate.TotalApprovedCost__c = bh.TotalCost__c + projectToUpdate.TotalApprovedCost__c;
				projectToUpdate.TotalForecastRevenue__c = bh.AppliedTotalRevenue__c + projectToUpdate.TotalForecastRevenue__c;
				projectToUpdate.TotalForecastCost__c = bh.TotalCost__c + projectToUpdate.TotalForecastCost__c;
			}
			
			//Work at Risk and Forecast Calcuation for Project Level Budget Revenue Strategy
			for (BudgetHeader__c bh : [SELECT Project__c, AppliedTotalRevenue__c, TotalCost__c, WorkAtRisk__c, Status__c
										FROM BudgetHeader__c
										WHERE Project__c in :projectLevelStategyProjects
											AND (Status__c = 'Forecast' 
											  or (Status__c = 'Work at Risk' AND Project__r.BudgetStrategyRevenue__c = 'Project Level'))]) {
				pse__Proj__c projectToUpdate = projectsToUpdate.get(bh.Project__c);
				if((bh.WorkAtRisk__c || bh.Status__c == 'Work at Risk')  && bh.TotalCost__c < bh.AppliedTotalRevenue__c){
					projectToUpdate.TotalForecastRevenue__c = bh.TotalCost__c + projectToUpdate.TotalForecastRevenue__c;
				}
				else {
					projectToUpdate.TotalForecastRevenue__c = bh.AppliedTotalRevenue__c + projectToUpdate.TotalForecastRevenue__c;
				}
				projectToUpdate.TotalForecastCost__c = bh.TotalCost__c + projectToUpdate.TotalForecastCost__c;
			}

			//Work at Risk and Forecast Calculation for Top Task Level Budget Reveneue Stategy
			for(BudgetHeader__c bh : [SELECT Project__c, AppliedTotalRevenue__c, TotalCost__c, WorkAtRisk__c, Status__c
										FROM BudgetHeader__c
										WHERE Project__c in :topTaskLevelStrategyProjects
											AND (Status__c = 'Forecast' or Status__c = 'Work at Risk') ]) {
				pse__Proj__c projectToUpdate = projectsToUpdate.get(bh.Project__c);
				if(!(bh.Status__c == 'Work at Risk') && (!bh.WorkAtRisk__c)) {
					projectToUpdate.TotalForecastRevenue__c = bh.AppliedTotalRevenue__c + projectToUpdate.TotalForecastRevenue__c;
				}
				projectToUpdate.TotalForecastCost__c = bh.TotalCost__c + projectToUpdate.TotalForecastCost__c;
			}

   			Map<Id, Map<Id, Decimal>> topLevelTaskCost = new Map<Id, Map<Id,Decimal>>();
    		Id topLevelTaskId;
    		Decimal topLevelTaskTotal;
    		for(BudgetAssignment__c budgetAssignment:[Select BudgetTask__c, Status__c, AppliedTtlRawCst__c, FullyBurdenedCost__c, TotalOverhead__c, TotalFringe__c, BudgetResource__r.AppliedResourceAlias__c                                        
                                            , BudgetResource__r.AppliedResourceListName__c, BudgetTask__r.BudgetHeader__c, BudgetTask__r.ProjectTask__c, 
                                            BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__c, AppliedRawCost__c, Quantity__c, BudgetTask__r.TotalCost__c
                                            From BudgetAssignment__c 
                                            Where BudgetTask__r.BudgetHeader__r.Project__c in :topTaskLevelStrategyProjects
                                            and (BudgetTask__r.BudgetHeader__r.Status__c = 'Work at Risk' or BudgetTask__r.BudgetHeader__r.WorkAtRisk__c = true)
                                            Order By BudgetTask__r.BudgetHeader__r.CreatedDate]) {

        			if(budgetAssignment.BudgetTask__r.ProjectTask__c == 'a3Ea00000019WAC') {
        				System.Debug('BrentBrentBrent Project Task ' + budgetAssignment.FullyBurdenedCost__c);
        			}


		            if(budgetAssignment.BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__c == null) {
		                topLevelTaskId = budgetAssignment.BudgetTask__r.ProjectTask__c;
		            }
		            else {
		                topLevelTaskId = budgetAssignment.BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__c;
		            }
		            if(!topLevelTaskCost.containsKey(topLevelTaskId)) {
		                topLevelTaskCost.put(topLevelTaskId, new Map<Id, Decimal>());
		            }
		            if(!topLevelTaskCost.get(topLevelTaskId).containsKey(budgetAssignment.BudgetTask__r.BudgetHeader__c)) {
		                topLevelTaskCost.get(topLevelTaskId).put(budgetAssignment.BudgetTask__r.BudgetHeader__c, 0);   
		            }

	            topLevelTaskTotal = topLevelTaskCost.get(topLevelTaskId).get(budgetAssignment.BudgetTask__r.BudgetHeader__c) + budgetAssignment.FullyBurdenedCost__c; 
	            topLevelTaskCost.get(topLevelTaskId).put(budgetAssignment.BudgetTask__r.BudgetHeader__c, topLevelTaskTotal);
	        }

	        if(!topLevelTaskCost.keySet().isEmpty()) {
	        	for(BudgetTask__c budgetTask:[select Id, AppliedTotalRevenue__c, OverrideTotalRevenue__c, TotalCost__c, ProjectTask__c, BudgetHeader__c, BudgetHeader__r.Project__c, 
	        									ProjectTask__r.pse__Top_level_Parent_Task__c, BudgetHeader__r.Project__r.BudgetStrategy__c, BudgetHeader__r.TotalCost__c
                                        from BudgetTask__c where BudgetHeader__r.Project__c in :topTaskLevelStrategyProjects and IsTopLevelTask__c = true and ((BudgetHeader__r.Status__c = 'Forecast' and BudgetHeader__r.WorkAtRisk__c = true) or BudgetHeader__r.Status__c = 'Work at Risk')]) {
            
                	Decimal overrideTotalRevenue;
                	Decimal totalCost = 0;

                	pse__Proj__c projectToUpdate = projectsToUpdate.get(budgetTask.BudgetHeader__r.Project__c);

                	if(budgetTask.OverrideTotalRevenue__c != null) {
                  		overrideTotalRevenue = budgetTask.OverrideTotalRevenue__c;
                	}
                	else {
                  		overrideTotalRevenue = 0;
                	}
	           
	                if(budgetTask.ProjectTask__r.pse__Top_level_Parent_Task__c != null){
	                    topLevelTaskId = budgetTask.ProjectTask__r.pse__Top_level_Parent_Task__c;
	                }
	                else {
	                    topLevelTaskId = budgetTask.ProjectTask__c;  
	                }

	                    if(topLevelTaskCost.containsKey(topLevelTaskId)){
	                    	if(topLevelTaskCost.get(topLevelTaskId).get(budgetTask.BudgetHeader__c) != null) {
	                        	totalCost = topLevelTaskCost.get(topLevelTaskId).get(budgetTask.BudgetHeader__c);
	                        }
	                    }

                    if(totalCost < overrideTotalRevenue) {
                    	projectToUpdate.TotalForecastRevenue__c += totalCost;
                	}
                	else {
                    	projectToUpdate.TotalForecastRevenue__c += overrideTotalRevenue;   
                	}
                }
	        }

			ECO_ProjectTriggers.run = false;
			if(!projectsToUpdate.values().isEmpty()) {
				update projectsToUpdate.values(); 
			}
		}
	
	}

	public static void cloneBudget(Id budgetHeaderId, Boolean isReverse) {
		/*ECO_BudgetHeaderTriggers.run = false;
		ECO_BudgetTaskTriggers.run = false;
		ECO_BudgetResourceTriggers.run = false;
		ECO_BudgetAssignmentTriggers.run = false;*/
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;

		List<BudgetHeader__c> budgetHeader = [select Id, Project__c, RecordTypeId, BudgetName__c, OverrideTotalRevenue__c, BudgetTaskCount__c, BudgetStrategyRevenue__c from BudgetHeader__c where Id = :budgetHeaderId];

		Map<Id, BudgetTask__c> oldBudgetTaskIdNewTaskMap = new Map<Id, BudgetTask__c>();
		Map<Id, BudgetResource__c> oldBudgetResourceIdNewResourceMap = new Map<Id, BudgetResource__c>();

		ECO_BudgetHeaderTriggers.run = false;
		BudgetHeader__c newBudgetHeader = budgetHeader[0].clone(false, true);
		newBudgetHeader.Project__c = budgetHeader[0].Project__c;
		if(!isReverse) {
			newBudgetHeader.BudgetName__c = budgetHeader[0].BudgetName__c + ' - Cloned';
		}
		else {
			newBudgetHeader.BudgetName__c = budgetHeader[0].BudgetName__c + ' - Reversed';
		}
		newBudgetHeader.Status__c = 'Draft';

		if(budgetHeader[0].BudgetStrategyRevenue__c == 'Project Level') {
			if(isReverse) {
				newBudgetHeader.OverrideTotalRevenue__c = 0 - budgetHeader[0].OverrideTotalRevenue__c;
			}
			else {
				newBudgetHeader.OverrideTotalRevenue__c = budgetHeader[0].OverrideTotalRevenue__c;
			}
		}
		newBudgetHeader.BudgetType__c = 'Change Order';
		//newBudgetHeader.RecordTypeId = budgetHeader[0].RecordTypeId;
		insert newBudgetHeader;

		ECO_BudgetTaskTriggers.run = false;
		List<BudgetTask__c> newBudgetTasks = new List<BudgetTask__c>();
		BudgetTask__c newBudgetTask;
		for(BudgetTask__c budgetTask:[select Id, Name, ProjectTask__c, TaskName__c, OverrideTotalRevenue__c, CurrencyIsoCode from BudgetTask__c where BudgetHeader__c = :budgetHeader[0].Id]) {
		    newBudgetTask = budgetTask.clone(false,true);
		    newBudgetTask.BudgetHeader__c = newBudgetHeader.Id;
		    newBudgetTask.Taskname__c = budgetTask.TaskName__c;
		    newBudgetTask.CurrencyIsoCode = budgetTask.CurrencyIsoCode;
		    if(budgetHeader[0].BudgetStrategyRevenue__c != 'Project Level') {
		    	if(isReverse) {
		    		if(budgetTask.OverrideTotalRevenue__c != null) {
		    			newBudgetTask.OverrideTotalRevenue__c = 0 - budgetTask.OverrideTotalRevenue__c;
		    		}
		    		else {
		    			newBudgetTask.OverrideTotalRevenue__c = 0;
		    		}
		    	}
		    	else {
		    		newBudgetTask.OverrideTotalRevenue__c = budgetTask.OverrideTotalRevenue__c;
		    	} 	
		    }
		    newBudgetTasks.add(newBudgetTask);
		    oldBudgetTaskIdNewTaskMap.put(budgetTask.Id, newBudgetTask);
		}
		insert newBudgetTasks;
		//ECO_BudgetTaskTriggers.run = false;
		//ECO_BudgetResourceTriggers.run = false;
		ECO_BudgetResourceTriggers.run = false;
		List<BudgetResource__c> newBudgetResources = new List<BudgetResource__c>();
		BudgetResource__c newBudgetResource;
		for(BudgetResource__c budgetResource:[select Id, Name, ProjectTeamMember__c, Resource__c, ResourceListName__c, OverrideBillRate__c, OverrideFringeMultiplier__c, 
											  OverrideOverheadMultiplier__c, OverrideOverheadMultiplierField__c, OverrideRatesOnLines__c, OverrideRawCost__c, OverrideUplift__c, 
		                                      ResourceName__c, ResourceType__c, TotalCost__c,AppliedBillRate__c, ExpenditureResourceType__c, ExpenditureType__c, ExpenditureTypeCategory__c,
		                                      JobName__c, ColumnHeader__c, MarginType__c, VendorSite__c, PLReportCategory__c, CurrencyIsoCode, OverrideFringeMultiplierField__c
		                                       from BudgetResource__c where BudgetHeader__c = :budgetHeader[0].Id]) {
		    newBudgetResource = budgetResource.clone(false, true);
		    newBudgetResource.BudgetHeader__c = newBudgetHeader.Id;
		    newBudgetResource.ProjectTeamMember__c = budgetResource.ProjectTeamMember__c;
		    newBudgetResource.ResourceListName__c = budgetResource.ResourceListName__c;
		    newBudgetResource.ResourceName__c = budgetResource.ResourceName__c;
		    newBudgetResource.ResourceType__c = budgetResource.ResourceType__c;
		    newBudgetResource.Resource__c = budgetResource.Resource__c;
		    newBudgetResource.OverrideBillRate__c = budgetResource.OverrideBillRate__c;
		    newBudgetResource.OverrideFringeMultiplier__c = budgetResource.OverrideFringeMultiplier__c;
		    newBudgetResource.OverrideFringeMultiplierField__c = budgetResource.OverrideFringeMultiplierField__c;
		    newBudgetResource.OverrideOverheadMultiplier__c = budgetResource.OverrideOverheadMultiplier__c;
		    newBudgetResource.OverrideOverheadMultiplierField__c = budgetResource.OverrideOverheadMultiplierField__c;
		    newBudgetResource.OverrideRawCost__c = budgetResource.OverrideRawCost__c;
		    newBudgetResource.OverrideRatesOnLines__c = budgetResource.OverrideRatesOnLines__c;
		    newBudgetResource.OverrideUplift__c = budgetResource.OverrideUplift__c;
		    newBudgetResource.ExpenditureResourceType__c = budgetResource.ExpenditureResourceType__c;
		    newBudgetResource.ExpenditureType__c = budgetResource.ExpenditureType__c;
		    newBudgetResource.ExpenditureTypeCategory__c = budgetResource.ExpenditureTypeCategory__c;
		    newBudgetResource.JobName__c = budgetResource.JobName__c;
		    newBudgetResource.OverrideUplift__c = budgetResource.OverrideUplift__c;
		    newBudgetResource.MarginType__c = budgetResource.MarginType__c;
		    newBudgetResource.VendorSite__c = budgetResource.VendorSite__c;
		    newBudgetResource.PLReportCategory__c = budgetResource.PLReportCategory__c;
		    newBudgetResource.CurrencyIsoCode = budgetResource.CurrencyIsoCode;
		    newBudgetResource.OverrideOverheadMultiplierField__c = budgetResource.OverrideOverheadMultiplierField__c;
		    //newBudgetResource.ProjectTeamMember__c = budgetResource.ProjectTeamMember__c;
		    //newBudgetResource.Resource__c = budgetResource.Resource__c;
		    newBudgetResources.add(newBudgetResource);
		    oldBudgetResourceIdNewResourceMap.put(budgetResource.Id, newBudgetResource);
		}
		insert newBudgetResources;

		//ECO_BudgetResourceTriggers.run = true;

		/*ECO_MiscSettings__c setting = ECO_MiscSettings__c.getInstance('Clone Batch Task Count Threshold');
		Decimal taskThresholdAmount = 25; 
		if(setting.Value__c != null && setting.Value__c != '' ){
			taskThresholdAmount= 25;//25Decimal.valueOf(setting.Value__C);
		}
		if(budgetHeader[0].BudgetTaskCount__c < taskThresholdAmount) { */
		createBudgetAssigments(ECO_Service_Budget.getBudgetAssignments(budgetHeader[0].Id), isReverse, oldBudgetTaskIdNewTaskMap, oldBudgetResourceIdNewResourceMap);
		/*}
		else {
			Id batchJobId = Database.executeBatch(new ECO_BudgetCloneBatch(budgetHeader[0].Id, isReverse, oldBudgetTaskIdNewTaskMap, oldBudgetResourceIdNewResourceMap), 100);
		}*/
	}

	public static List<BudgetAssignment__c> getBudgetAssignments (Id budgetHeaderId) {
		List<BudgetAssignment__c> budgetAssignments = [select Id, Name, BudgetTask__c, BudgetResource__c, OverrideTotalCost__c, OverrideTotalRawCost__c, OverrideTotalFringe__c,  
													OverrideTotalOverhead__c, OverrideRawCost__c, Quantity__c, ProjectTask__c, OverrideTotalRevenue__c, useEACCalc__c, EACAppliedETCRawCost__c
													,EACForecastFringe__c, AppliedTtlRawCst__c, AppliedTtlRawCstNum__c,EACActualCost__c,EACActualCostRollup__c,EACActualFringe__c,EACActualFringeRollup__c,EACActualOverhead__c
													,EACActualOverheadRollup__c, EACActualQuantity__c, EACActualQuantityRollup__c, EACApprovedQuantity__c, EACApprovedRawCost__c, EACApprovedRevenue__c
													, EACApprovedTotalCost__c, EACForecastOverhead__c, EACForecastQuantity__c, EACForecastRawCost__c, EACForecastRevenueNumber__c, EACForecastTotalCost__c,
													OverrideUplift__c, EACRevisedRevenue__c, CalcRevTrigger__c, OverrideOverheadMultiplierField__c, OverrideFringeMultiplierField__c, CurrencyIsoCode,
													OverrideBillRate__c, OverrideFringeMultiplier__c, EACForecastRevenue__c, OverrideOverheadMultiplier__c, MarginType__c
													 from BudgetAssignment__c 
													where BudgetTask__r.BudgetHeader__c = :budgetHeaderId];
		return budgetAssignments;
	}


	public static void createBudgetAssigments(List<BudgetAssignment__c> budgetAssignments, Boolean isReverse, Map<Id, BudgetTask__c> oldBudgetTaskIdNewTaskMap, Map<Id, BudgetResource__c> oldBudgetResourceIdNewResourceMap) {
		List<BudgetAssignment__c> newBudgetAssignments = new List<BudgetAssignment__c>();
		BudgetAssignment__c newBudgetAssignment;

		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_BudgetAssignmentTriggers.run = false;		

		for(BudgetAssignment__c budgetAssignment:budgetAssignments) {
		    //newBudgetAssignment = budgetAssignment.clone(false, true);
		    newBudgetAssignment = new BudgetAssignment__c();
		    newBudgetAssignment.BudgetTask__c = oldBudgetTaskIdNewTaskMap.get(budgetAssignment.BudgetTask__c).Id;
		    if(oldBudgetResourceIdNewResourceMap.containsKey(budgetAssignment.BudgetResource__c)){
		    	newBudgetAssignment.BudgetResource__c = oldBudgetResourceIdNewResourceMap.get(budgetAssignment.BudgetResource__c).Id;
		    }
		    newBudgetAssignment.ProjectTask__c = budgetAssignment.ProjectTask__c;

		    if(isReverse){
		    	if(budgetAssignment.OverrideTotalRawCost__c != null) {
		    		newBudgetAssignment.OverrideTotalRawCost__c = 0 - budgetAssignment.OverrideTotalRawCost__c;
		    	}

		    	if(budgetAssignment.OverrideTotalCost__c != null) {
			    	newBudgetAssignment.OverrideTotalCost__c = 0 - budgetAssignment.OverrideTotalCost__c;
			    }

			    if(budgetAssignment.OverrideTotalOverhead__c != null) {
			    	newBudgetAssignment.OverrideTotalOverhead__c = 0 - budgetAssignment.OverrideTotalOverhead__c;
			    }

			    if(budgetAssignment.OverrideTotalFringe__c != null) {
			    	newBudgetAssignment.OverrideTotalFringe__c = 0 - budgetAssignment.OverrideTotalFringe__c;
			    }

			    if(budgetAssignment.OverrideRawCost__c != null) {
			    	newBudgetAssignment.OverrideRawCost__c = 0 - budgetAssignment.OverrideRawCost__c;
			    }

			    if(budgetAssignment.OverrideTotalRevenue__c != null) {
			    	newBudgetAssignment.OverrideTotalRevenue__c = 0 - budgetAssignment.OverrideTotalRevenue__c;
				}

			    if(budgetAssignment.Quantity__c != null) {
			    	newBudgetAssignment.Quantity__c = 0 - budgetAssignment.Quantity__c;
			    }
			}
			else {
				newBudgetAssignment.OverrideTotalRawCost__c = budgetAssignment.OverrideTotalRawCost__c;
			    newBudgetAssignment.OverrideTotalCost__c = budgetAssignment.OverrideTotalCost__c;
			    newBudgetAssignment.OverrideTotalOverhead__c = budgetAssignment.OverrideTotalOverhead__c;
			    newBudgetAssignment.OverrideTotalFringe__c = budgetAssignment.OverrideTotalFringe__c;

			    newBudgetAssignment.OverrideRawCost__c = budgetAssignment.OverrideRawCost__c;
			    
			    newBudgetAssignment.OverrideTotalRevenue__c = budgetAssignment.OverrideTotalRevenue__c;


			    System.Debug('BrentBrentBrent budgetAssignment.OverrideBillRate__c ' + budgetAssignment.OverrideBillRate__c);
			    newBudgetAssignment.OverrideBillRate__c = budgetAssignment.OverrideBillRate__c;
			    
			    newBudgetAssignment.Quantity__c = budgetAssignment.Quantity__c;	
			    newBudgetAssignment.OverrideOverheadMultiplier__c = budgetAssignment.OverrideOverheadMultiplier__c;
			    newBudgetAssignment.OverrideOverheadMultiplierField__c = budgetAssignment.OverrideOverheadMultiplierField__c;

			    newBudgetAssignment.OverrideFringeMultiplier__c = budgetAssignment.OverrideFringeMultiplier__c;
			    newBudgetAssignment.OverrideFringeMultiplierField__c = budgetAssignment.OverrideFringeMultiplierField__c;
			    newBudgetAssignment.useEACCalc__c = budgetAssignment.useEACCalc__c;
			    //newBudgetAssignment.EACAppliedETCRawCost__c = budgetAssignment.EACAppliedETCRawCost__c;
			    newBudgetAssignment.EACForecastFringe__c = budgetAssignment.EACForecastFringe__c;
			    newBudgetAssignment.AppliedTtlRawCst__c = budgetAssignment.AppliedTtlRawCst__c;
			    newBudgetAssignment.AppliedTtlRawCstNum__c = budgetAssignment.AppliedTtlRawCstNum__c;
			    newBudgetAssignment.EACActualCost__c = budgetAssignment.EACActualCost__c;
			    newBudgetAssignment.EACActualCostRollup__c = budgetAssignment.EACActualCostRollup__c;	
			    newBudgetAssignment.EACForecastTotalCost__c = budgetAssignment.EACForecastTotalCost__c;	
			    newBudgetAssignment.OverrideUplift__c = budgetAssignment.OverrideUplift__c;	
			    newBudgetAssignment.EACForecastQuantity__c = budgetAssignment.EACForecastQuantity__c;	
			    newBudgetAssignment.EACApprovedTotalCost__c = budgetAssignment.EACApprovedTotalCost__c;	
			    newBudgetAssignment.EACActualQuantity__c = budgetAssignment.EACActualQuantity__c;	
			    newBudgetAssignment.EACActualCostRollup__c = budgetAssignment.EACActualCostRollup__c;
			    newBudgetAssignment.AppliedTtlRawCst__c = budgetAssignment.AppliedTtlRawCst__c;	
			    newBudgetAssignment.CalcRevTrigger__c = budgetAssignment.CalcRevTrigger__c;	
			    newBudgetAssignment.CurrencyIsoCode = budgetAssignment.CurrencyIsoCode;
			    newBudgetAssignment.EACApprovedRevenue__c = budgetAssignment.EACApprovedRevenue__c;
			    newBudgetAssignment.EACForecastRevenue__c = budgetAssignment.EACForecastRevenue__c;
			    newBudgetAssignment.MarginType__c = budgetAssignment.MarginType__c;
			}

		    newBudgetAssignments.add(newBudgetAssignment);
		}
		insert newBudgetAssignments;
	}
}