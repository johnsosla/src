public without sharing class ECO_ProjectTaskService {

  public List<pse__Project_Task__c> lstProjectTasks;
  public Map<Id, ECO_ProjectTask> projectTaskMap;
  public map<id, pse__Proj__c> projMap;
  public List<ECO_ProjectTask> lstProjectTasksSorted;


  public ECO_ProjectTaskService() {
    lstProjectTasks = null;
    projectTaskMap = null;
    projMap = null;    
    lstProjectTasksSorted = null;

    projMap = new map<id, pse__Proj__c>();
    lstProjectTasks = new List<pse__Project_Task__c>();
    lstProjectTasksSorted = new List<ECO_ProjectTask>();
  }

  private void setupData(List<pse__Project_Task__c> tNew){
    // default includeChildren to true for now since we haven't evalueated with methods actually need the earned value children
    setupData(tNew, true);
  }

  private void setupData(List<pse__Project_Task__c> tNew, Boolean includeChildren){
    if (Trigger.isExecuting && 
      (Trigger.isBefore && Trigger.isInsert)) {
      projectTaskMap = new  Map<Id, ECO_ProjectTask> ();
    }

    if(projectTaskMap == null) {

      Set <Id> topParentIds = new Set<Id>();
      Set <Id> taskIds = new Set<Id>();
      Set<Id> parentIds = new Set<Id>();
      Set<Id> projectIds  = new Set<Id>();

      for (pse__Project_Task__c task : tNew) {
        Id topParentId = task.pse__Top_level_Parent_Task__c;
        if (topParentId == null) topParentId = task.Id;
        topParentIds.add(topParentId);
        projectIds.add(task.pse__Project__c);
      }

      // system.debug('topParentIds: ' + topParentIds);
      //projectTaskMap = getProjectTaskMap(new ECO_ProjectTasksSelector().selectByTopLevelTask(topParentIds));
      
      projMap = new map<id, pse__Proj__c>();
      lstProjectTasks = new List<pse__Project_Task__c>();
      lstProjectTasksSorted = new List<ECO_ProjectTask>();

      projectTaskMap = getProjectTaskMap(ECO_ProjectTasksSelector.selectByProject(projectIds, includeChildren));
      /*
      for(ECO_ProjectTask ept: projectTaskMap.values()){
        projMap.put(ept.oProjectTask.pse__Project__r.id, ept.oProjectTask.pse__Project__r);
        lstProjectTasks.add(ept.oProjectTask);
        lstProjectTasksSorted.add(ept);
      }

      lstProjectTasksSorted.sort();
      */
    }
  }

  public List<pse__Project_Task__c> returnTasks(List<pse__Project_Task__c> tNew){
    List<pse__Project_Task__c> returnTaskList = new list<pse__Project_Task__c>();

    setupData(tNew);
    system.debug(' projectTaskMap size' + projectTaskMap.size());
    for(pse__Project_Task__c pt: tNew){

      returnTaskList.add(projectTaskMap.get(pt.id).oProjectTask);
    }

    return returnTaskList;
  }

  public Map<Id, ECO_ProjectTask>  returnMapProjectTask(List<pse__Project_Task__c> tNew){
    return returnMapProjectTask(tNew, false);
  }

  public Map<Id, ECO_ProjectTask>  returnMapProjectTask(List<pse__Project_Task__c> tNew, Boolean includeChildren){
    setupData(tNew, includeChildren);

    return projectTaskMap;   
  }

  public list<pse__Proj__c> returnProjects(List<pse__Project_Task__c> tNew){
    setupData(tNew);

    return projMap.values();
  }


  public static List<pse__Time_Period__c> calcTimePeriods  = new List<pse__Time_Period__c>();
 /* public static List<pse__Time_Period__c> calcTimePeriods (list<date> enddatelist ,string type){
      List<pse__Time_Period__c> calcTimePeriods = new list<pse__Time_Period__c>([select id,TimePeriodCode__c,pse__End_Date__c,pse__Start_Date__c from pse__Time_Period__c where pse__Type__c =:type and pse__Start_Date__c <=:enddatelist and pse__End_Date__c  >=:enddatelist]);
  return calcTimePeriods ;
  }
  */


  public static list<pse__Project_Task__c> queryTask(Set<Id> projectIds) {
        return ECO_ProjectTasksSelector.selectByProject(projectIds);
        /*
        return [select Id,
                            Name,
                            ForecastEndDate__c,
                            pse__order__c,
                            ProjectTaskNumber__c,
                            ForecastStartDate__c,
                            IsBillable__c,
                            IsChargeable__c,
                            EarnedValueCurve__c,
                            Duration__c,
                            FinancialTask__c,
                            pse__Start_Date__c, 
                            pse__End_Date__c, 
                            pse__Start_Date_Time__c, 
                            pse__End_Date_Time__c,
                            Task_Sequence_No__c,
                            WorkTypeName__c,
                            pse__Parent_Task__c,
                            OracleSyncStatus__c,
                            TaskOrg__c,
                            Burden_Reference_Schedule_Name__c,
                            TotalApprovedCost__c,
                            TotalEstimateCost__c,
                            pse__Hierarchy_Depth__c,
                            pse__Project__c,
                            pse__Project__r.id,
                            pse__Project__r.PrimarySiteId__c,
                            pse__Project__r.pse__Stage__c,
                            pse__Project__r.RevisedStartDate__c,
                            pse__Project__r.RevisedEndDate__c,
                            pse__Project__r.pse__Start_Date__c,
                            pse__Project__r.pse__End_Date__c,
                            pse__Project__r.ProjectFunctionalCurrencyCode__c,
                            pse__Project__r.CarryingOutOrganization__c,
                            pse__Project__r.CarryingOutOrganization__r.OUID__c,
                            pse__Parent_Task__r.OracleSyncStatus__c,
                            pse__Parent_Task__r.pse__Top_level_Parent_Task__c,
                            CarryingOutOrganization__r.OUID__c,
                            (SELECT Id 
                                , ThisWeekNumber__c
                                FROM EarnedValueSnapshots__r)
                                
                  from pse__Project_Task__c 
                  where pse__Project__c IN :projectIds 
                  order by ProjectTaskNumber__c, Name]; 
            */   

  }


  public Map<Id, ECO_ProjectTask> getProjectTaskMap(Set<Id> projectIds) {
    return getProjectTaskMap(ECO_ProjectTasksSelector.selectByProject(projectIds));
    // return new Map<Id, ECO_ProjectTask>();
  }

  public Map<Id, ECO_ProjectTask> getProjectTaskMap(List<pse__Project_Task__c> projectTasks) {

    List<ECO_ProjectTask> tempTasks = new List<ECO_ProjectTask>();

    Map<Id, ECO_ProjectTask> taskMap = new Map<Id, ECO_ProjectTask>();

    for (pse__Project_Task__c task : projectTasks) {
      ECO_ProjectTask newTask = new ECO_ProjectTask(task);

      tempTasks.add(newTask);
      taskMap.put(newTask.id, newTask);
    }

    tempTasks.sort();
    lstProjectTasksSorted = tempTasks;
    Decimal lastPeerOrder = 0;

    for (ECO_ProjectTask task : lstProjectTasksSorted) {
      if (task.parentTaskId != null) {
        ECO_ProjectTask parent = taskMap.get(task.parentTaskId);

        parent.addChild(task);
      } else {
        task.peerOrder = lastPeerOrder++;
      }
    }

    return taskMap;
  }

  public List<ECO_ProjectTask> getProjectTaskList(Id projectId) {
    return getProjectTaskList(projectId, null);
  }
  public List<ECO_ProjectTask> getProjectTaskList(Id projectId, String filter) {
    return getProjectTaskList(projectId, filter, null);
  }
  // This is the only call that sets indent levels
  public List<ECO_ProjectTask> getProjectTaskList(Id projectId, String filter, Integer lmt) {
    Map<Id, ECO_ProjectTask> taskMap = getProjectTaskMap(
      ECO_ProjectTasksSelector.selectSummaryByProject(new Set<Id> {projectId}, filter, lmt));

    List<ECO_ProjectTask> tasks = new List<ECO_ProjectTask>();

    for (ECO_ProjectTask task : taskMap.values()) {
      if (task.parentTaskId == null) {
        setIndentLevel(tasks, task, 0);
      }
    }

    projectTaskMap = taskMap;
    return tasks;
  }

  // This is the only call that sets indent levels
  public List<ECO_ProjectTask> getProjectTaskListByFilters(Id projectId, String parentTaskfilter, Set<String> taskRangeFilters, Integer lmt) {
    Map<Id, ECO_ProjectTask> taskMap = getProjectTaskMap(
      ECO_ProjectTasksSelector.selectSummaryByProjectFilterTasks(new Set<Id> {projectId}, parentTaskfilter, taskRangeFilters, lmt));

    List<ECO_ProjectTask> tasks = new List<ECO_ProjectTask>();

    for (ECO_ProjectTask task : taskMap.values()) {
      if (task.parentTaskId == null) {
        setIndentLevel(tasks, task, 0);
      }
    }

    projectTaskMap = taskMap;
    return tasks;
  }

  private static void setIndentLevel(List<ECO_ProjectTask> tasks, ECO_ProjectTask task, Integer level) {
    task.indentLevel = level;

    tasks.add(task);

    if (task.parentTaskId != null) {
      if (task.parentClasses == null) {
        task.parentClasses = task.parentTaskId;
      } else {
        task.parentClasses += ' ' + task.parentTaskId;
      }
    }

    for (ECO_ProjectTask child : task.children) {
      setIndentLevel(tasks, child, level + 1);
    }
  }

  public static Integer loadParentTaskFilter(Id projectId, String parentTaskFilter, List<SelectOption> taskFilterOptions, List<SelectOption> taskFilterOptions2, List<SelectOption> taskFilterOptions3, List<SelectOption> taskFilterOptions4, List<SelectOption> taskFilterOptions5) {
    Set<String> parentTasks = new Set<String>();

    //get the full list of tasks
    List<pse__Project_Task__c> projectTasks = [SELECT 
                    Id,
                    ProjectTaskNumber__c,
                    pse__Parent_Task__c
                  FROM pse__Project_Task__c 
                  WHERE pse__Project__c = :projectId AND pse__Top_level_Parent_Task__c = null
                  ORDER BY ProjectTaskNumber__c];
    //no tasks yet, so get out of here
    if( projectTasks.isEmpty()){
      return 0;
    }

    //find the distinct list of parent tasks
    for( pse__Project_Task__c pt : projectTasks ){
        parentTasks.add( pt.ProjectTaskNumber__c);
    }

    //build the filter list of parent tasks
    Integer taskCount = 0;
    for( String parent : parentTasks){
      if (parent == null){ 
        continue;
      }
      if(taskCount < 999) {
        taskFilterOptions.add( new SelectOption(parent, parent));
      }
      else if(taskCount < 1999) {
        taskFilterOptions2.add( new SelectOption(parent, parent));
      }
      else if(taskCount < 2999) {
        taskFilterOptions3.add( new SelectOption(parent, parent));
      }
      else if(taskCount < 3999) {
        taskFilterOptions4.add( new SelectOption(parent, parent));
      }
      else if(taskCount < 4999) {
        taskFilterOptions5.add( new SelectOption(parent, parent));
      }
      taskCount ++;
    }

    if( parentTaskFilter == null || parentTaskFilter == '-1'){
      return ((Integer)[SELECT count() 
        FROM pse__Project_Task__c 
        WHERE pse__Project__c = :projectId ]);
    }

    return ((Integer)[SELECT count() 
        FROM pse__Project_Task__c 
        WHERE pse__Project__c = :projectId
          AND (pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = :parentTaskFilter
            OR ProjectTaskNumber__c = :parentTaskFilter)]);
  }
}