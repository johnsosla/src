public without sharing class ECO_BudgetTaskService {
	public Enum TotalCalcStrategy { SUM, QUERY }
	public ECO_BudgetTaskService() {
		
	}

	public static Set<String> validateBudgetTasksForOracleSync(Id projectId, Id budgetHeaderId) {
		Set<String> tasksWithErrors = new Set<String>();

		Map<Id, BudgetHeader__c> budgetHeaderMap = new Map<Id, BudgetHeader__c>([Select Id, Status__c, AppliedTotalRevenue__c, Project__r.BudgetStrategyRevenue__c, Project__r.OracleProjectNumber__c,
                                                                                    Project__r.BudgetStrategy__c, MultiLineBurdened__c
                                                                                From BudgetHeader__c Where Project__c = :projectId
                                                                                  And (Id = :budgetHeaderId or Status__c = 'Approved' Or Status__c = 'Forecast')]);


     	Map<String, ECO_CalcualteBudgets.TaskCostDetail> costDetailMap = ECO_CalcualteBudgets.calcTotalBudgetHeaders(projectId, budgetHeaderMap);

     	for(ECO_CalcualteBudgets.TaskCostDetail costDetail:costDetailMap.values()){
     		if (costDetail.resourceListAlias == 'People') {
	     		if (costDetail.forecastQuantity == 0) {
	     			if (costDetail.forecastRawCost != 0 || costDetail.forecastBurdenedCost != 0) {
	     				tasksWithErrors.add(costDetail.taskName);
	     			}
	     		}
	     		if (costDetail.approvedQuantity == 0) {
	     			if (costDetail.approvedRawCost != 0 || costDetail.approvedBurdenedCost != 0) {
	     				tasksWithErrors.add(costDetail.taskName);
	     			}
	     		}
	     	}
     	}

     	return tasksWithErrors;
	}

	public static List<ECO_DTO_BudgetTask> getBudgetTaskListFromProject(Id projectId) {
				List<BudgetTask__c> budgetTasks = [select 
					id,
					name,
					ProjectTask__c,
					ProjectTask__r.name,
					ParentTask__r.ProjectTask__c,
					ProjectTask__r.pse__Parent_Task__c,
					ParentTask__c,
					ProjectTask__r.ProjectTaskNumber__c,
					TaskName__c,
					TotalContingency__c,
					TotalCost__c,
					TotalFringe__c,
					TotalFullyBurdenedLaborRate__c,
					TotalLaborHours__c,
					TotalODCCost__c,
					TotalOverhead__c,
					TotalRawCost__c,
					TotalRevenue__c,
					TotalSubCost__c,
					TotalSubRevenue__c,
					TotalContingencyRevenue__c,
					TotalODCRevenue__c,
					TotalLaborCost__c,
					TotalLaborRevenue__c,
                    OverrideTotalRevenue__c                                
					from BudgetTask__c 
					where BudgetHeader__r.Project__c = :projectId 
					order by ProjectTask__r.ProjectTaskNumber__c, TaskName__c];
//					order by ProjectTask__r.pse__Task_Number__c];
//					order by ProjectTask__r.pse__Order__c];

		List<ECO_DTO_BudgetTask> tempTasks = new List<ECO_DTO_BudgetTask>();

		Map<Id, ECO_DTO_BudgetTask> taskMap = new Map<Id, ECO_DTO_BudgetTask>();

		Set<Id> taskIds = new Set<Id>();

		for (BudgetTask__c task : budgetTasks) {
			taskIds.add(task.id);

			ECO_DTO_BudgetTask newTask = new ECO_DTO_BudgetTask(task.ProjectTask__r);

			tempTasks.add(newTask);
			taskMap.put(newTask.id, newTask);
		}

		for (ECO_DTO_BudgetTask task : tempTasks) {
			if (task.parentTaskId != null) {
				ECO_DTO_BudgetTask parent = taskMap.get(task.parentTaskId);

				parent.addChild(task);
			}
		}

		List<ECO_DTO_BudgetTask> tasks = new List<ECO_DTO_BudgetTask>();

		for (ECO_DTO_BudgetTask task : tempTasks) {
			if (task.parentTaskId == null) {
				setIndentLevel(tasks, task, 0);
			}
		}

		List<BudgetAssignment__c> assignments = [select id, BudgetTask__r.ProjectTask__c, BudgetTask__c, TotalComputedCost__c from BudgetAssignment__c where BudgetTask__c in :taskIds];

		for (BudgetAssignment__c assignment : assignments) {
			ECO_DTO_BudgetTask theTask = taskMap.get(assignment.BudgetTask__r.ProjectTask__c);

			theTask.totalComputedCost += assignment.TotalComputedCost__c;
		}

		// TODO - need to check strategy before calling this line, possibly call a different method
		setBottomUpRollupTotals(tasks);

		return tasks;
	}

	public static List<ECO_DTO_BudgetTask> getBudgetTaskList(Id headerId) {
		return getBudgetTaskList(headerId, null, null, null);
	}

	public static List<ECO_DTO_BudgetTask> getBudgetTaskList(Id headerId, String resourceType) {
		return getBudgetTaskList(headerId, resourceType, null, null);
	}

	public static List<ECO_DTO_BudgetTask> getBudgetTaskList(Id headerId, String resourceType, String parentTaskFilter) {
		return getBudgetTaskList(headerId, resourceType, parentTaskFilter, null);
	}


	public static List<ECO_DTO_BudgetTask> getBudgetTaskList(Id headerId, String resourceType, String parentTaskFilter, Set<String> taskFilters ) {
		Boolean hasParentFilter = parentTaskFilter != null && parentTaskFilter != '-1' ? true : false;
		taskFilters = (taskFilters == null || taskFilters.size() == 0) ? new Set<String> { '%' } : taskFilters;

		system.debug('== parentTaskFilter: "' + parentTaskFilter + '"" - hasParentFilter: ' + hasParentFilter + ' taskFilters: ' + taskFilters);

		String soql = 'SELECT' +
				' id,' +
				' name,' +
				' ProjectTask__c,' +
				' ProjectTask__r.name,' +
				' ParentTask__r.ProjectTask__c,' +
				' ProjectTask__r.pse__Parent_Task__c,' +
				' ParentTask__c,' +
				' ProjectTask__r.ProjectTaskNumber__c,' +
				' ProjectTask__r.WorkTypeName__c,' +
				' ProjectTask__r.OracleRateScheduleName__c,' +
				' ProjectTask__r.pse__Project__r.BudgetStrategy__c,' +
				' TaskName__c,' +
				' TotalContingency__c,' +
				' TotalCost__c,' +
				' TotalFringe__c,' +
				' TotalFullyBurdenedLaborRate__c,' +
				' TotalLaborHours__c,' +
				' TotalODCCost__c,' +
				' TotalOverhead__c,' +
				' TotalRawCost__c,' +
				' TotalRevenue__c,' +
				' TotalSubCost__c,' +
				' TotalSubRevenue__c,' +
				' TotalContingencyRevenue__c,' +
				' TotalODCRevenue__c,' +
				' TotalLaborCost__c,' +
				' TotalLaborRevenue__c,' +
				' OverrideTotalRevenue__c,' + 
				' ProjectTask__r.pse__Top_level_Parent_Task__r.ProjectTaskNumber__c' + 
			' FROM BudgetTask__c ' +
			' WHERE BudgetHeader__c = :headerId AND ProjectTask__r.FinancialTask__c = true';
		if(hasParentFilter){
			soql += ' AND ( (ProjectTask__r.pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :parentTaskFilter AND ProjectTask__r.pse__Task_Key_Chain__c LIKE :taskFilters)';
			soql += ' OR ProjectTask__r.ProjectTaskNumber__c = :parentTaskFilter)';
		}
		soql += ' ORDER BY ProjectTask__r.ProjectTaskNumber__c, TaskName__c';
		if(hasParentFilter){
			soql += ' LIMIT 10000';
		}
		// List<BudgetTask__c> budgetTasks = (List<BudgetTask__c>)Database.query(soql);
// 					order by ProjectTask__r.pse__Order__c];
//					order by ProjectTask__r.pse__Task_Number__c];
		
		System.debug('Heap - after task query: ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
		// List<ECO_DTO_BudgetTask> tempTasks = new List<ECO_DTO_BudgetTask>();

		Map<Id, ECO_DTO_BudgetTask> taskMap = new Map<Id, ECO_DTO_BudgetTask>();

		Set<Id> taskIds = new Set<Id>();

		for (BudgetTask__c task : (List<BudgetTask__c>)Database.query(soql)) {
			
			ECO_DTO_BudgetTask newTask = new ECO_DTO_BudgetTask(task);

			// tempTasks.add(newTask);
			taskMap.put(newTask.id, newTask);
		}

		System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());

		for (ECO_DTO_BudgetTask task : taskMap.values()) {
			if (task.parentTaskId != null) {
				ECO_DTO_BudgetTask parent = taskMap.get(task.parentTaskId);

				if (parent != null)
					parent.addChild(task);
			}
		}

		System.debug('Heap : ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
		List<ECO_DTO_BudgetTask> tasks = new List<ECO_DTO_BudgetTask>();

		if (!hasParentFilter || true) {
			for (ECO_DTO_BudgetTask task : taskMap.values()) {
				if (task.parentTaskId == null) {
					setIndentLevel(tasks, task, 0);
				}
			}
		} else {

			Integer numTasks = 1;
			Boolean stop = false;
			Integer stopIdx = 0;
			for (ECO_DTO_BudgetTask task : taskMap.values()) {
				if (stop) break;
				if (task.taskNumber == parentTaskFilter) {
					
					List<ECO_DTO_BudgetTask> tempTasks2 = new List<ECO_DTO_BudgetTask>();
					tasks.add(task);
					task.indentLevel = 0;
					Integer level = 1;
					/*
					if (nextTaskPage != null) {

						// List<ECO_DTO_BudgetTask> tempChildren = task.children.clone();
						for (Integer i = 0; i < task.children.size(); i++) {
							if( task.children[i].Id == nextTaskPage) {
								break;
							} else {
								task.children.remove(i);
							}

						}

						system.debug(' # of Child tasks: ' + task.children.size());
					}
					*/
					for (Integer i = 0; i < task.children.size(); i++) {

						ECO_DTO_BudgetTask child = task.children[i];


						numTasks += setIndentLevel(tasks, child, level + 1);
											
						if (numTasks > 300) {
							stopIdx = i;
							stop = true;
							break;
						}
						/*
						numTasks += setIndentLevel(tempTasks2, child, level + 1);
											
						if (numTasks > 300) {
							if (tasks.size() <= 1) {
								tasks.addAll(tempTasks2);
							}
							stop = true;
							break;
						} else {
							tasks.addAll(tempTasks2);					
						}
						tempTasks2.clear();
						*/
					}
				}
			}
			// Remove the rest of the children tasks
			for(Integer j = tasks[0].children.size()-1; j > stopIdx; j--) {
				tasks[0].children.remove(j);
			} 

			System.debug('-- Tasks: '+ tasks);
			System.debug('-- Tasks Children: '+' -- children size: ' +tasks[0].children);
		}

		for (ECO_DTO_BudgetTask task : tasks) {
			taskIds.add(task.id);		
		}
		//system.debug('--TaskId size: ' + taskIds.size() + ' -- children size: ' +tasks[0].children.size() );
		System.debug('--TaskId size: ' + taskIds.size());

		// budgetTasks.clear();
		//tempTasks.clear();
		//tempTasks = null; // Save heap
		// budgetTasks = null;
		System.debug('Heap - before AggregateResult: ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
        
		for (AggregateResult ar : [SELECT BudgetTask__r.ProjectTask__c, 
													SUM(EACActualCost__c) EACActualCost__c, 
													SUM(EACActualFringe__c) EACActualFringe__c, 
													SUM(EACActualOverhead__c) EACActualOverhead__c, 
													SUM(EACActualQuantity__c) EACActualQuantity__c, 
													SUM(EACApprovedQuantity__c) EACApprovedQuantity__c, 
													SUM(EACApprovedTotalCost__c) EACApprovedTotalCost__c, 
													SUM(EACForecastQuantity__c) EACForecastQuantity__c, 
													SUM(EACForecastRevenueNumber__c) EACForecastRevenue__c, 
													SUM(EACForecastTotalCost__c) EACForecastTotalCost__c,
													SUM(EACEtcQuantity__c) EACEtcQuantity__c,
													SUM(EACAppliedEtcCost__c) EACAppliedEtcCost__c,
													SUM(EACApprovedRevenue__c) EACApprovedRevenue__c,
													SUM(EACAppliedEtcRevenue__c) EACAppliedEtcRevenue__c,
													SUM(EACRevisedRevenue__c) EACRevisedRevenue__c
													FROM BudgetAssignment__c 
													WHERE BudgetTask__r.BudgetHeader__c = :headerId AND ResourceType__c = :resourceType AND BudgetTask__r.ProjectTask__c IN :taskIds 
													GROUP BY BudgetTask__r.ProjectTask__c]) 
		{
			Id taskKey = (Id)ar.get('ProjectTask__c');
			ECO_DTO_BudgetTask theTask = taskMap.get(taskKey);

			if (theTask == null) continue;
			system.debug('---Omar theTask.taskNumber: ' + theTask.taskNumber + ' ? ' + parentTaskFilter );
            if (hasParentFilter && theTask.taskNumber == parentTaskFilter) {
                theTask = assignTopTotals(theTask, headerId, resourceType, parentTaskFilter );
                taskMap.put(taskKey, theTask);
                system.debug('---Omar ar(EACActualQuantity__c): ' +  (Decimal)ar.get('EACActualQuantity__c'));
                system.debug('---Omar EACActualQuantity__c: ' + theTask.totalEACActualQuantity);
            } else {
                theTask.totalEACActualCost = ifNull((Decimal)ar.get('EACActualCost__c'));
                theTask.totalEACActualCost += ifNull((Decimal)ar.get('EACActualFringe__c'));
                theTask.totalEACActualCost +=  ifNull((Decimal)ar.get('EACActualOverhead__c'));
    
                theTask.totalEACActualQuantity = (Decimal)ar.get('EACActualQuantity__c');
                theTask.totalEACApprovedQuantity = (Decimal)ar.get('EACApprovedQuantity__c');
                theTask.totalEACApprovedTotalCost = (Decimal)ar.get('EACApprovedTotalCost__c');
                theTask.totalEACForecastQuantity = (Decimal)ar.get('EACForecastQuantity__c');
                theTask.totalEACForecastRevenue = (Decimal)ar.get('EACForecastRevenue__c');
                theTask.totalEACForecastTotalCost = (Decimal)ar.get('EACForecastTotalCost__c');
    
                theTask.totalEACEtcQuantity = (Decimal)ar.get('EACEtcQuantity__c');
                theTask.totalEACEtcCost = (Decimal)ar.get('EACAppliedEtcCost__c');
                theTask.totalEACApprovedRevenue = (Decimal)ar.get('EACApprovedRevenue__c');
                theTask.totalEACAppliedEtcRevenue = (Decimal)ar.get('EACAppliedEtcRevenue__c');
                theTask.totalEACRevisedRevenue = (Decimal)ar.get('EACRevisedRevenue__c');

                // system.debug(' -- in AR Loop theTask: ' + theTask.Name + ' - ' + theTask.totalEACActualQuantity );
            }
		}

/*
		ECO_DTO_BudgetTask topTask = taskMap.get(taskKey);

*/		
            if (hasParentFilter) {
            	Id parentTaskId = [SELECT Id, Name, ProjectTask__c FROM BudgetTask__c WHERE BudgetHeader__c = :headerId AND ProjectTask__r.ProjectTaskNumber__c = :parentTaskFilter Limit 1].ProjectTask__c;
                ECO_DTO_BudgetTask topTask = taskMap.get(parentTaskId);
                system.debug('---Omar - taskMap: ' + taskMap);
                system.debug('---Omar - parentTaskId: ' +  parentTaskId + ' topTask: ' + topTask);
                topTask = assignTopTotals(topTask, headerId, resourceType, parentTaskFilter );
                // taskMap.put(taskKey, theTask);
            } 

		System.debug('Heap - after AggregateResult: ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
		for (BudgetAssignment__c assignment : [select id, BudgetTask__r.ProjectTask__c, BudgetTask__c, TotalComputedCost__c from BudgetAssignment__c where BudgetTask__c in :taskIds]) {
			ECO_DTO_BudgetTask theTask = taskMap.get(assignment.BudgetTask__r.ProjectTask__c);

			theTask.totalComputedCost += assignment.TotalComputedCost__c;
		}

		system.debug('--tasks size: ' + tasks.size() + ' -- taskIds.size: ' + taskIds.size());

		taskMap.clear(); // Save heap
		taskIds = null; // Save heap

		// TODO - need to check strategy before calling this line, possibly call a different method
		setBottomUpRollupTotals(tasks, parentTaskFilter);

		return tasks;
	}

	private static Integer setIndentLevel(List<ECO_DTO_BudgetTask> tasks, ECO_DTO_BudgetTask task, Integer level) {
		Integer numTasks = 1;
		task.indentLevel = level;

		tasks.add(task);

		if (task.parentTaskId != null) {
			if (task.parentClasses == null) {
				task.parentClasses = task.parentTaskId;
			} else {
				task.parentClasses += ' ' + task.parentTaskId;
			}
		}

		for (ECO_DTO_BudgetTask child : task.children) {
			numTasks += setIndentLevel(tasks, child, level + 1);
		}
		return numTasks;
	}

	public static Decimal sumColumn(List<ECO_DTO_BudgetTask> budgetTasks, String name) {
		Decimal result = 0;

		for (ECO_DTO_BudgetTask task : budgetTasks) {
//			result += (Decimal) task.obudgettask.get(name);
			if (task.includeThis /* || task.hasChildren */) {
				result += (Decimal) task.getValueByName(name);
			}	
		}

		return result;
	}

	public static Decimal ifNull(Decimal val) {
		return val == null ? 0 : val;
	}
	
	public static ECO_DTO_BudgetTask assignAllTotals(Id headerId, String resourceType) {
        AggregateResult arTop = [SELECT 
									SUM(EACActualCost__c) EACActualCost__c, 
									SUM(EACActualFringe__c) EACActualFringe__c, 
									SUM(EACActualOverhead__c) EACActualOverhead__c, 
									SUM(EACActualQuantity__c) EACActualQuantity__c, 
									SUM(EACApprovedQuantity__c) EACApprovedQuantity__c, 
									SUM(EACApprovedTotalCost__c) EACApprovedTotalCost__c, 
									SUM(EACForecastQuantity__c) EACForecastQuantity__c, 
									SUM(EACForecastRevenueNumber__c) EACForecastRevenue__c, 
									SUM(EACForecastTotalCost__c) EACForecastTotalCost__c,
									SUM(EACEtcQuantity__c) EACEtcQuantity__c,
									SUM(EACAppliedEtcCost__c) EACAppliedEtcCost__c,
									SUM(EACApprovedRevenue__c) EACApprovedRevenue__c,
									SUM(EACAppliedEtcRevenue__c) EACAppliedEtcRevenue__c,
									SUM(EACRevisedRevenue__c) EACRevisedRevenue__c, 
									SUM(CalculatedRevenueNumber__c) CalculatedRevenue__c,
									SUM(FullyBurdenedCostNumber__c) FullyBurdenedCost__c,
									SUM(AppliedTtlRawCstNm__c) AppliedTtlRawCstNm__c,
									SUM(TotalFringe__c) TotalFringe__c,
									SUM(TotalOverhead__c) TotalOverhead__c,
									SUM(Quantity__c) Quantity__c
									FROM BudgetAssignment__c 
									WHERE BudgetTask__r.BudgetHeader__c = :headerId AND ResourceType__c = :resourceType];
           
        return assignTaskValues(new ECO_DTO_BudgetTask(), arTop);
    }

    public static ECO_DTO_BudgetTask assignTopTotals(ECO_DTO_BudgetTask topTask, Id headerId, String resourceType, String parentTaskFilter) {
        AggregateResult arTop = [SELECT 
									SUM(EACActualCost__c) EACActualCost__c, 
									SUM(EACActualFringe__c) EACActualFringe__c, 
									SUM(EACActualOverhead__c) EACActualOverhead__c, 
									SUM(EACActualQuantity__c) EACActualQuantity__c, 
									SUM(EACApprovedQuantity__c) EACApprovedQuantity__c, 
									SUM(EACApprovedTotalCost__c) EACApprovedTotalCost__c, 
									SUM(EACForecastQuantity__c) EACForecastQuantity__c, 
									SUM(EACForecastRevenueNumber__c) EACForecastRevenue__c, 
									SUM(EACForecastTotalCost__c) EACForecastTotalCost__c,
									SUM(EACEtcQuantity__c) EACEtcQuantity__c,
									SUM(EACAppliedEtcCost__c) EACAppliedEtcCost__c,
									SUM(EACApprovedRevenue__c) EACApprovedRevenue__c,
									SUM(EACAppliedEtcRevenue__c) EACAppliedEtcRevenue__c,
									SUM(EACRevisedRevenue__c) EACRevisedRevenue__c, 
									SUM(CalculatedRevenueNumber__c) CalculatedRevenue__c,
									SUM(FullyBurdenedCostNumber__c) FullyBurdenedCost__c,
									SUM(AppliedTtlRawCstNm__c) AppliedTtlRawCstNm__c,
									SUM(TotalFringe__c) TotalFringe__c,
									SUM(TotalOverhead__c) TotalOverhead__c,
									SUM(Quantity__c) Quantity__c
									
									FROM BudgetAssignment__c 
									WHERE BudgetTask__r.BudgetHeader__c = :headerId AND ResourceType__c = :resourceType 
            AND (BudgetTask__r.ProjectTask__r.pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :parentTaskFilter
            OR BudgetTask__r.ProjectTask__r.ProjectTaskNumber__c = :parentTaskFilter)];
           
        return assignTaskValues(topTask, arTop);
    }
    public static ECO_DTO_BudgetTask assignTaskValues(ECO_DTO_BudgetTask theTask, AggregateResult ar) {
        

			theTask.totalEACActualCost = ifNull((Decimal)ar.get('EACActualCost__c'));
			
			theTask.totalEACActualCost += ifNull((Decimal)ar.get('EACActualFringe__c'));
			theTask.totalEACActualCost +=  ifNull((Decimal)ar.get('EACActualOverhead__c'));
			
			theTask.totalEACActualQuantity = (Decimal)ar.get('EACActualQuantity__c');
			theTask.totalEACApprovedQuantity = (Decimal)ar.get('EACApprovedQuantity__c');
			theTask.totalEACApprovedTotalCost = (Decimal)ar.get('EACApprovedTotalCost__c');
			theTask.totalEACForecastQuantity = (Decimal)ar.get('EACForecastQuantity__c');
			theTask.totalEACForecastRevenue = (Decimal)ar.get('EACForecastRevenue__c');
			theTask.totalEACForecastTotalCost = (Decimal)ar.get('EACForecastTotalCost__c');

			theTask.totalEACEtcQuantity = (Decimal)ar.get('EACEtcQuantity__c');
			theTask.totalEACEtcCost = (Decimal)ar.get('EACAppliedEtcCost__c');
			theTask.totalEACApprovedRevenue = (Decimal)ar.get('EACApprovedRevenue__c');
			theTask.totalEACAppliedEtcRevenue = (Decimal)ar.get('EACAppliedEtcRevenue__c');
			theTask.totalEACRevisedRevenue = (Decimal)ar.get('EACRevisedRevenue__c');
        	
        	theTask.totalFringe = ifNull((Decimal)ar.get('TotalFringe__c'));
        	theTask.totalOverhead = ifNull((Decimal)ar.get('TotalOverhead__c'));
        	theTask.totalODCCost = ifNull((Decimal)ar.get('FullyBurdenedCost__c'));
			theTask.totalODCRevenue = ifNull((Decimal)ar.get('CalculatedRevenue__c'));
			theTask.totalRawCost = ifNull((Decimal)ar.get('AppliedTtlRawCstNm__c'));
			theTask.totalRevenue = ifNull((Decimal)ar.get('CalculatedRevenue__c'));
			theTask.totalSubCost = ifNull((Decimal)ar.get('FullyBurdenedCost__c'));
			theTask.totalSubRevenue = ifNull((Decimal)ar.get('CalculatedRevenue__c'));
			theTask.totalLabourCost = ifNull((Decimal)ar.get('FullyBurdenedCost__c'));
			theTask.totalLabourRevenue = ifNull((Decimal)ar.get('CalculatedRevenue__c'));

			theTask.totalLaborHours = ifNull((Decimal)ar.get('Quantity__c'));
			theTask.totalContingency = ifNull((Decimal)ar.get('FullyBurdenedCost__c'));
			theTask.totalContingencyRevenue = ifNull((Decimal)ar.get('CalculatedRevenue__c'));

			
        return theTask;
    }
    public static ECO_DTO_BudgetTask getTotalRow(List<ECO_DTO_BudgetTask> budgetTasks) {
		return getTotalRow(budgetTasks, TotalCalcStrategy.SUM);
	}

	public static ECO_DTO_BudgetTask getTotalRow(List<ECO_DTO_BudgetTask> budgetTasks, TotalCalcStrategy calcStrategy) {
		ECO_DTO_BudgetTask totalRow = new ECO_DTO_BudgetTask();

		if (calcStrategy == TotalCalcStrategy.SUM) {
			totalRow.totalContingency = sumColumn(budgetTasks, 'totalContingency');
			totalRow.totalContingencyRevenue = sumColumn(budgetTasks, 'totalContingencyRevenue');
			totalRow.totalCost = sumColumn(budgetTasks, 'totalCost');
			totalRow.totalComputedCost = sumColumn(budgetTasks, 'totalComputedCost');
			totalRow.totalFringe = sumColumn(budgetTasks, 'totalFringe');
			totalRow.totalFullyBurdenedLaborRate = sumColumn(budgetTasks, 'totalFullyBurdenedLaborRate');
			totalRow.totalLaborHours = sumColumn(budgetTasks, 'totalLaborHours');
			totalRow.totalODCCost = sumColumn(budgetTasks, 'totalODCCost');
			totalRow.totalODCRevenue = sumColumn(budgetTasks, 'totalODCRevenue');
			totalRow.totalOverhead = sumColumn(budgetTasks, 'totalOverhead');
			totalRow.totalRawCost = sumColumn(budgetTasks, 'totalRawCost');
			totalRow.totalRevenue = sumColumn(budgetTasks, 'totalRevenue');
			totalRow.totalSubCost = sumColumn(budgetTasks, 'totalSubCost');
			totalRow.totalSubRevenue = sumColumn(budgetTasks, 'totalSubRevenue');
			totalRow.totalLabourCost = sumColumn(budgetTasks, 'totalLabourCost');
			totalRow.totalLabourRevenue = sumColumn(budgetTasks, 'totalLabourRevenue');

			/* EAC */
			totalRow.totalEACActualCost = sumColumn(budgetTasks, 'totalEACActualCost');
			totalRow.totalEACActualQuantity = sumColumn(budgetTasks, 'totalEACActualQuantity');
			totalRow.totalEACApprovedQuantity = sumColumn(budgetTasks, 'totalEACApprovedQuantity');
			totalRow.totalEACApprovedTotalCost = sumColumn(budgetTasks, 'totalEACApprovedTotalCost');
			totalRow.totalEACForecastQuantity = sumColumn(budgetTasks, 'totalEACForecastQuantity');
			totalRow.totalEACForecastRevenue = sumColumn(budgetTasks, 'totalEACForecastRevenue');
			totalRow.totalEACForecastTotalCost = sumColumn(budgetTasks, 'totalEACForecastTotalCost');
			totalRow.totalEACEtcQuantity = sumColumn(budgetTasks, 'totalEACEtcQuantity');
			totalRow.totalEACEtcCost = sumColumn(budgetTasks, 'totalEACEtcCost');
			totalRow.totalEACApprovedRevenue = sumColumn(budgetTasks, 'totalEACApprovedRevenue');
			totalRow.totalEACRevisedRevenue = sumColumn(budgetTasks, 'totalEACRevisedRevenue');
			totalRow.totalEACAppliedEtcRevenue = sumColumn(budgetTasks, 'totalEACAppliedEtcRevenue');

		} else if (calcStrategy == TotalCalcStrategy.QUERY) {
			system.debug(' -- in getTotalRow == calcStrategy = QUERY:');
			
		}
		//system.debug('totalEACAppliedEtcRevenue: ' + totalRow.totalEACAppliedEtcRevenue);

		// totalRow.totalEACForecastQuantity = sumColumn(budgetTasks, 'totalEACForecastQuantity');

		return totalRow;
	}

    public static void setBottomUpRollupTotals(List<ECO_DTO_BudgetTask> budgetTasks) {
        setBottomUpRollupTotals(budgetTasks, null);
    }
    
	public static void setBottomUpRollupTotals(List<ECO_DTO_BudgetTask> budgetTasks, String parentTaskFilter) {
		Boolean topTaskOnly = false;
		Boolean includeThis = false;

		system.debug('--- Omar - parentTaskFilter: ' + parentTaskFilter);
		for (Integer i = budgetTasks.size() - 1; i >= 0; i--) {
			ECO_DTO_BudgetTask task = budgetTasks.get(i);
			topTaskOnly = ('Top Task' == task.budgetCostStrategy);


			// TODO: Fix this later to calculate top task with a different strategy
			if ((task.children.size() > 0 || task.indentLevel == 0) && task.taskNumber != parentTaskFilter) {
				task.totalContingency = task.getSubtaskTotal('totalContingency');
				task.totalContingencyRevenue = task.getSubtaskTotal('totalContingencyRevenue');
				task.totalCost = task.getSubtaskTotal('totalCost');
				task.totalComputedCost = task.getSubtaskTotal('totalComputedCost');
				task.totalFringe = task.getSubtaskTotal('totalFringe');
				task.totalFullyBurdenedLaborRate = task.getSubtaskTotal('totalFullyBurdenedLaborRate');
				task.totalLaborHours = task.getSubtaskTotal('totalLaborHours');
				task.totalODCCost = task.getSubtaskTotal('totalODCCost');
				task.totalODCRevenue = task.getSubtaskTotal('totalODCRevenue');
				task.totalOverhead = task.getSubtaskTotal('totalOverhead');
				task.totalRawCost = task.getSubtaskTotal('totalRawCost');
				task.totalRevenue = task.getSubtaskTotal('totalRevenue');
				task.totalSubCost = task.getSubtaskTotal('totalSubCost');
				task.totalSubRevenue = task.getSubtaskTotal('totalSubRevenue');
				task.totalLabourCost = task.getSubtaskTotal('totalLabourCost');
				task.totalLabourRevenue = task.getSubtaskTotal('totalLabourRevenue');

				task.totalEACEtcCost = task.getSubtaskTotal('totalEACEtcCost');

				task.totalEACActualCost = task.getSubtaskTotal('totalEACActualCost');
				task.totalEACActualQuantity = task.getSubtaskTotal('totalEACActualQuantity');
				task.totalEACApprovedQuantity = task.getSubtaskTotal('totalEACApprovedQuantity');
				task.totalEACApprovedTotalCost = task.getSubtaskTotal('totalEACApprovedTotalCost');
				task.totalEACForecastQuantity = task.getSubtaskTotal('totalEACForecastQuantity');
				task.totalEACForecastRevenue = task.getSubtaskTotal('totalEACForecastRevenue');
				task.totalEACForecastTotalCost = task.getSubtaskTotal('totalEACForecastTotalCost');
				task.totalEACRevisedRevenue = task.getSubtaskTotal('totalEACRevisedRevenue');
				task.totalEACApprovedRevenue = task.getSubtaskTotal('totalEACApprovedRevenue');
				task.totalEACAppliedEtcRevenue = task.getSubtaskTotal('totalEACAppliedEtcRevenue');	
			}
		}
	}

	public static Decimal sumContingencies(Id  projectId) {
		List<BudgetHeader__c> budgetHeaders = [Select TotalContingencyAmount__c, Project__c From BudgetHeader__c Where Project__c = :projectId];
		Decimal val = 0;

		for(BudgetHeader__c bh : budgetHeaders ) {
			val += bh.TotalContingencyAmount__c;
		}
		return val;
	}

	public static Decimal sumRiskRegister(Id projectId) {
		List<Risk__c> risks =  [Select PostmitigationContingencyTotal__c, Project__c From Risk__c Where Project__c = :projectId];

		Decimal val = 0;

		for(Risk__c risk : risks ) {
			val += risk.PostmitigationContingencyTotal__c;
		}

		return val;
	} 
}