/** ------------------------------------------------------------------------------------------------------
* @Description the page controller for the ECO_BudgetHeader.page
*
* @Author      NTT Data - Omar Abdel-Latief & Deborah Orth
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_BudgetHeaderController extends ECO_Financial_Security {
	public ApexPages.StandardController stdController {get; set;}
	public ECO_DTO_BudgetHeaderWrapper budgetWrapper {get; set;}

	public List<SelectOption> taskPageOptions             { get; set; }
	public String taskRange                                 { get; set; }
	public String oracleTaskError_str					{get; set; }
	public ECO_DTO_BudgetHeader selectedDtoBudget {get; set;}
	public Map<String, Decimal> values { 
		get { return selectedDtoBudget.values; } 
		private set; 
	}
	public Boolean canModify { 
        get {
            if(canModify == null) canModify = ECO_BudgetGenericDetailController.checkIsSaveAllowed(headerId);
            return canModify;
        } 
        private set; 
    }
	public Integer getTaskLimit() { return ECO_DTO_BudgetLabourWrapper.taskLimit; }
	
	/** 
	* @Description  this is a calculated GrossMargin per NetServiceRevenue field,
	*               depending on an EAC, Change Order or Estimate; and 
	*               whether the Status is 'Draft' for an EAC, or 'Forecast' or Approved for 
	*               a ChangeORder or Estimate 
	* @Author       NTT Data - Omar Abdel-Latief &  Arman Shah
	* @Date         September 2016
	**/

	public Decimal NSR {
		get {
			if (isEAC) {
				NSR = budgetWrapper.getForecastTotalNetServiceRevenue;
			}
			else {
				NSR = budgetWrapper.getBudgetTotalNetServiceRevenue;
			}

			NSR += (budgetHeader.Status__c == 'Draft' ? values.get('NetServicesRevenue__c') : 0);
			return NSR;
		}

		private set;
	}

	public Decimal getRevisedGMNSR {
		get {
			if (NSR != 0) {
				Decimal GM = 0;
				if (isEAC) {
				 	GM = budgetWrapper.getForecastTotalGrossMargin;
				}
				else {
					GM = budgetWrapper.getBudgetTotalGrossMargin;
				}

				GM += (budgetHeader.Status__c == 'Draft' ? values.get('GrossMargin__c') : 0);
				return (100*GM/NSR).setScale(2);
			}
			return 0.0;
		}
	}

	/** 
	* @Description  this is a calculated NetMargin per NetServiceRevenue field,
	*               depending on an EAC, Change Order or Estimate; and 
	*               whether the Status is 'Draft' for an EAC, or 'Forecast' or Approved for 
	*               a ChangeORder or Estimate 
	* @Author       NTT Data - Omar Abdel-Latief &  Arman Shah
	* @Date         September 2016
	**/
	public Decimal getRevisedNMNSR {
		get {
			if (NSR != 0) {
				Decimal NM = 0;
				if (isEAC) {
				 	NM = budgetWrapper.getForecastTotalNetMargin;
				} else {
					NM = budgetWrapper.getBudgetTotalNetMargin;
				}
				NM += (budgetHeader.Status__c == 'Draft' ? values.get('NetMargin__c') : 0);
				return (100*NM/NSR).setScale(2);
			}
			return 0.0;
		}
	}

	public Decimal getRevisedSalaryCostMultiplier() {
		String statuses = '';
		Id bhId = budgetHeader.Status__c == 'Draft' ? headerId : null;

		if (isEAC) {
			statuses = ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST;
		} else {
			statuses = ECO_DTO_BudgetHeader.STATUS_APPROVED;
		}

		return budgetWrapper.calculateTotalDTOproperty(statuses, 
			'salaryCostMultiplier', null, null, bhId).setScale(1);   
	}
	
	public Decimal getRevisedAverageLabourRatePerHour() {
		String statuses = '';
		Id bhId = budgetHeader.Status__c == 'Draft' ? headerId : null;

		if (isEAC) {
			statuses = ECO_DTO_BudgetHeader.STATUS_APPROVED + ',' + ECO_DTO_BudgetHeader.STATUS_FORECAST;
		} else {
			statuses = ECO_DTO_BudgetHeader.STATUS_APPROVED;
		}

		return budgetWrapper.calculateTotalDTOproperty(statuses, 
			'averageLabourRatePerHour', null, null, bhId).setScale(2);   
	}
	public Id headerId {get; set;}

	public List<ECO_DTO_BudgetTask> tasks {get; set;}

	public ECO_DTO_BudgetTask totalRow {get; set;}
	
	public String projectCurrency {get; set;}
	public String laborPage {get; set;}
	public String subPage {get; set;}
	public String odcPage {get; set;}
	public String contingencyPage {get; set;}
	private BudgetHeader__c budgetHeader;

	public pse__Proj__c theProject { get; set; }

	public Boolean isEAC {get; set;}

	//task filtering for projects with more than 1000 tasks
	public String parentTaskFilter                          { get; set; }
	public Boolean tooManyTasks                             { get; set; }
	public List<SelectOption> taskFilterOptions				{ get; set; }

	public Boolean isBurdenRateRevised {get; set;}
	

	/**
	 * Extension controller constructor, gets necessary fields from the Budget Header record, 
	 * loads the tasks and calculates summary information about the budget
	 *
	 * @Author  NTT Data - Omar Abdel-Latief & Deborah Orth
	 * @Date    2016
	 *
	 * @param   stdController 
	 * @return     
	 **/
	public ECO_BudgetHeaderController(ApexPages.StandardController stdController) {
		this.stdController = stdController;

		List<String> fields = new List<String>();

		fields.add('Project__c');
		fields.add('AppliedTotalRevenue__c');

		if (!Test.isRunningTest()) {
		  stdController.addFields(fields);
		}

		headerId = stdController.getId();

		//DJO 8/2016 issue 5113 - add filter by parent task
		this.taskFilterOptions = new List<SelectOption>();
		this.taskFilterOptions.add( new SelectOption( '-1', 'All'));

		//get the requested filter task from the param list
		this.parentTaskFilter = ApexPages.currentPage().getParameters().get('parentTaskFilter');
		if( this.parentTaskFilter == null){
			this.parentTaskFilter = '-1';
		}

		this.tooManyTasks = false;
		Integer taskListSize = loadParentTaskFilter();
		if( taskListSize > ECO_DTO_BudgetLabourWrapper.taskLimit && this.parentTaskFilter == '-1') {
			this.tooManyTasks = true;
			return;
		}

		reload();
		
		isEAC = false;

		BudgetHeader__c budgetHeader = [SELECT Id, Project__c, RecordType.DeveloperName, 
			BudgetType__c, Status__c, isBurdenRateRevised__c, NetServicesRevenue__c, GrossMargin__c, NetMargin__c
			FROM BudgetHeader__c WHERE Id = :headerId];
		String recordTypeName = budgetHeader.RecordType.DeveloperName;
		if (recordTypeName != 'EAC') {
			laborPage = 'ECO_BudgetLabourDetail';
			subPage = 'ECO_BudgetSubDetail';
			odcPage = 'ECO_BudgetODCDetail';
			contingencyPage = 'ECO_BudgetContingency';
		} else {
			laborPage = 'ECO_BudgetLabourEAC';
			subPage = 'ECO_BudgetSubDetailEAC';
			odcPage = 'ECO_BudgetODCDetailEAC';
			contingencyPage = 'ECO_BudgetContingencyEAC';
			isEAC = true;
		}

		theProject = ECO_Service_Projects.getProjectById(budgetHeader.Project__c);
		budgetWrapper = new ECO_DTO_BudgetHeaderWrapper(theProject.Id);

		selectedDtoBudget = budgetWrapper.findBudgetHeaderDTOById(Id.valueOf(headerId));
		
		isBurdenRateRevised = budgetHeader.isBurdenRateRevised__c;

		Set<String> oracleTaskErrors = ECO_BudgetTaskService.validateBudgetTasksForOracleSync(theProject.Id, headerId);
		
		if (oracleTaskErrors.size() > 0) {
			oracleTaskError_str = String.join(new List<String>(oracleTaskErrors), ', ');
		}

	}

	/**
	 * refreshes the data on oparent task filter change
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August 2016
	 *
	 * @param    
	 * @return   PageReference  
	 **/
	public PageReference refreshData(){
		PageReference pageReference = new PageReference(ApexPages.currentPage().getUrl());
		pageReference.getParameters().clear();
		pageReference.getParameters().put('Id', headerId );
		pageReference.getParameters().put('parentTaskFilter', this.parentTaskFilter);
		pageReference.setRedirect(true);

		if (taskRange != null) pageReference.getParameters().put('taskRange', taskRange);

		return pageReference;

	}
	
	/**
	 * Saves any Budget Task information that may have been updated by the user and reloads the page
	 *
	 * @Author  NTT Data - Omar Abdel-Latief & Deborah Orth
	 * @Date    2016
	 *
	 * @param    
	 * @return  PageReference   
	 **/
	public PageReference saveBudget() {
		stdController.save();
		
		List<BudgetTask__c> budgetTasks = new List<BudgetTask__c>();
		
		for (ECO_DTO_BudgetTask task : tasks) {
			BudgetTask__c bt = new BudgetTask__c( Id=task.budgetTaskId, OverrideTotalRevenue__c = task.pageOverrideTotalRevenue);
			budgetTasks.add(bt);
		}
		
		try {
			update budgetTasks;
		} catch (Exception e){
			ECO_Service_ErrorLog.logException(e);
		}

		PageReference pageReference = new PageReference(ApexPages.currentPage().getUrl());
		pageReference.getParameters().clear();
		pageReference.getParameters().put('Id', headerId );
		if( this.parentTaskFilter != null){
			pageReference.getParameters().put('parentTaskFilter', this.parentTaskFilter);
		}
		pageReference.setRedirect(true);

		return pageReference;
	}
	
	/**
	 * Loads the task data and sums the budget information for the top of the page
	 *
	 * @Author  NTT Data - Omar Abdel-Latief & Deborah Orth
	 * @Date    2016
	 *
	 * @param    
	 * @return     
	 **/
	public void reload() {
		this.budgetHeader = (BudgetHeader__c)stdController.getRecord();

		//get all tasks so that we can calculate the totals correctly
		// this.tasks = ECO_BudgetTaskService.getBudgetTaskList(headerId);
		// totalRow = ECO_BudgetTaskService.getTotalRow(this.tasks);

		//now get the tasks based on the filter, if set
		if( this.parentTaskFilter != null && this.parentTaskFilter != '-1'){
			Set<String> taskFilters = setTaskPagination();
			this.tasks = null;
			this.tasks = ECO_BudgetTaskService.getBudgetTaskList(headerId, null, this.parentTaskFilter, taskFilters);
		} else {
			this.tasks = ECO_BudgetTaskService.getBudgetTaskList(headerId);
		}

		totalRow = ECO_BudgetTaskService.getTotalRow(this.tasks);
	}
	
	private Integer getCounts(Map<Id, pse__Project_Task__c> mapTaskCounts, pse__Project_Task__c task) {
	  Integer count = 1;

	  for (pse__Project_Task__c child : task.pse__Immediate_Sub_Tasks__r) {
	    count += getCounts(mapTaskCounts, child);
	  }

	  return count;
	}
	public Set<String> setTaskPagination() {
      taskRange = System.currentPageReference().getParameters().get('taskRange');

      String startTaskName;
      String stopTaskName;

      Id startTaskId = null; 
      Id stopTaskId = null; 

      if(taskRange != null) {
        String[] arrTaskRange = taskRange.split(' - ');
        startTaskName = arrTaskRange[0];
        stopTaskName = arrTaskRange[1];
      }

      taskPageOptions = new List<SelectOption>();
      Set<String> taskFilters = new Set<String>();
      if (parentTaskFilter != null && parentTaskFilter != '-1') {
        Id projId = [Select Id, Project__c From BudgetHeader__c Where Id = :budgetHeader.Id].Project__c;

        List<pse__Project_Task__c> ptCounts = 
          [SELECT Id, pse__Task_Key__c, pse__Hierarchy_Depth__c, ProjectTaskNumber__c, (Select Id FROM pse__Immediate_Sub_Tasks__r)
          FROM pse__Project_Task__c 
          WHERE pse__Project__c = :projId AND (pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :parentTaskFilter)
          ORDER BY ProjectTaskNumber__c, Name ];

        Map<Id, pse__Project_Task__c> mapTaskCounts = new Map<Id, pse__Project_Task__c>(ptCounts);

        // system.debug('--nextTaskPage : ' + nextTaskPage);
        Integer runningTotal = 0;
        Boolean foundStartingTask = true; // (nextTaskPage == null);

        // system.debug('--nextTaskPage : ' + nextTaskPage + ' - foundStartingTask: ' + foundStartingTask);
        Id tempStartId;
        String tempStartTaskName;
        Id tempStopId;
        Boolean firstTaskPage = (taskRange == null);
        for (pse__Project_Task__c task : ptCounts) {
          if (!foundStartingTask) {
            if (task.Id == startTaskId ) foundStartingTask = true;
            else continue;
          }

          if (task.pse__Hierarchy_Depth__c == 1) {
            runningTotal += getCounts(mapTaskCounts, task);

            if (tempStartTaskName == null) {
              tempStartId = task.Id;
              tempStartTaskName = task.ProjectTaskNumber__c;
            }

            if (firstTaskPage || (startTaskName <= task.ProjectTaskNumber__c && task.ProjectTaskNumber__c <= stopTaskName)) {
              taskFilters.add('%' + task.pse__Task_Key__c + '%');
            }

            if(runningTotal > 300) {
              firstTaskPage = false;
              taskPageOptions.add(new SelectOption(tempStartTaskName + ' - ' + task.ProjectTaskNumber__c, tempStartTaskName + ' - ' + task.ProjectTaskNumber__c ));
              tempStartTaskName = null;
              runningTotal = 0;
            }
          }
        }

        // Make sure we get the last one
        
        if (tempStartId == null && ptCounts.size() > 0) {
          pse__Project_Task__c lastTask = ptCounts[ptCounts.size() - 1];
          taskPageOptions.add(new SelectOption(tempStartTaskName + ' - ' + lastTask.ProjectTaskNumber__c, tempStartTaskName + ' - ' + lastTask.ProjectTaskNumber__c ));
        }

      }

      return taskFilters;
    }

	/**
	 * Loads the task filter list
	 *
	 * @Author  NTT Data - Omar Abdel-Latief & Deborah Orth
	 * @Date    2016
	 *
	 * @param    
	 * @return   Integer  
	 **/
	public Integer loadParentTaskFilter() {
		Set<String> parentTasks = new Set<String>();

		//get the full list of tasks
		List<BudgetTask__c> budgetTasks = [SELECT 
										Id,
										ProjectTask__r.ProjectTaskNumber__c,
										ProjectTask__r.pse__Parent_Task__c,
										ProjectTask__r.pse__Top_level_Parent_Task__r.ProjectTaskNumber__c,
										ParentTask__c
									FROM BudgetTask__c 
									WHERE BudgetHeader__c = :this.headerId
									ORDER BY ProjectTask__r.pse__Top_level_Parent_Task__r.ProjectTaskNumber__c];
		//no tasks yet, so get out of here
		if( budgetTasks.isEmpty()){
			return 0;
		}

		//find the distinct list of parent tasks
		for( budgetTask__c bt : budgetTasks ){
			if( bt.ProjectTask__r.pse__Top_level_Parent_Task__r.ProjectTaskNumber__c != null){
				parentTasks.add( bt.ProjectTask__r.pse__Top_level_Parent_Task__r.ProjectTaskNumber__c);
			}
		}

		//build the filter list of parent tasks
		for( String parent : parentTasks){
			this.taskFilterOptions.add( new SelectOption(parent, parent));
		}

		if( this.parentTaskFilter == null || this.parentTaskFilter == '-1'){
			return budgetTasks.size();
		}

		return ((Integer)[SELECT count() 
				FROM BudgetTask__c 
				WHERE BudgetHeader__c = :this.headerId 
					AND (ProjectTask__r.pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :this.parentTaskFilter
						OR ProjectTask__r.ProjectTaskNumber__c = :this.parentTaskFilter)]);
	}
}