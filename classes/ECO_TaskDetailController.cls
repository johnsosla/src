global class ECO_TaskDetailController extends ECO_Financial_Security 
{
    pse__Proj__c theProject { get; set;}
    public Id projectId { get; set;}
    public transient List<ECO_ProjectTask> tasks {get; set;}
    public transient Map<Id,ECO_ProjectTask> mapTasksById {get; set;}

    public integer intRowNo{get;set;}
    public boolean boolShowNewBtn{get;set;}
    public transient list<TaskDetailWrapper> lstTaskDetailWrapper{get;set;}

    List<pse__Project_Task__c> lstProjTaskToDelete;
    public Map<string,string> mapPicklistLabelToValue = new map<string,string>();
    public String strSelectedAction {get; set;}

    public List<SelectOption> burdenSchedules {get; set;}
    public String burdenSchedule {get; set;}
    public String burdenScheduleField {get; set;}
    public Boolean showBurdenSchedule {get; set;}

    public String getUserLocale() {
        return UserInfo.getLocale();
    }

    public class AsyncJobException extends Exception {  }

    global class RemoteTaskWrapper {
        Integer rowNum;
        pse__Project_Task__c task;
        string[] fieldsToNull;

        public RemoteTaskWrapper(Integer rowNum, pse__Project_Task__c task) {
            this.rowNum = rowNum;
            this.task = task;
            fieldsToNull = new List<String>();
        }
    }


    global class ErrorRow {
        Integer rowNum;
        String errorMessage;

        public ErrorRow(Integer rowNum, String errorMessage) {
            this.rowNum = rowNum;
            this.errorMessage =errorMessage;
        }
    }

    @RemoteAction
    global static Boolean updateTask(RemoteTaskWrapper pt)
    {
        system.debug(LoggingLevel.INFO, pt);

        return true;
    }

    @Future
    global static void test()
    {

    }

    @RemoteAction
    global static Id updateTasks(List<RemoteTaskWrapper> remoteTasks) {
        ECO_TaskDetailUpdateQueueableJob asyncInstance = new ECO_TaskDetailUpdateQueueableJob(remoteTasks);
        Id jobId = System.enqueueJob(asyncInstance);
        return jobId;
    }

    @RemoteAction
    global static List<ErrorRow> pollAsyncUpdate(Id jobId) {
        // Check if job just crashed - most liekly due to a cpu tiem limit error        
        AsyncApexJob jobInfo = [SELECT Status, ExtendedStatus, NumberOfErrors FROM AsyncApexJob Where Id = :jobId];
        if (jobInfo.Status == 'Failed') throw new AsyncException('Async Job Failed - ' + jobInfo.ExtendedStatus);

        // Check to see if there's a response yet
        List<AsyncResponse__c> result = [Select Id, JobId__c, ReturnValue__c From AsyncResponse__c Where JobId__c = :jobId];

        if (result.size() == 0) return new List<ErrorRow> { new ErrorRow(-1337,'WAITING')} ;


        return (List<ErrorRow>)JSON.deserialize(result[0].ReturnValue__c, List<ErrorRow>.class);
    }

    // This gets called from the queuable in a different execution context
    global static List<ErrorRow> updateTasksAsync(List<RemoteTaskWrapper> remoteTasks)
    {
        system.debug(LoggingLevel.INFO, remoteTasks);

        List<pse__Project_Task__c> ptsToUpsert = new List<pse__Project_Task__c>();
        List<pse__Project_Task__c> lstProjTaskToInsert = new list<pse__Project_Task__c>();
        List<pse__Project_Task__c> lstProjTaskToUpdate = new list<pse__Project_Task__c>();
        Map<Integer, Integer> mapUpdateRowNumByIdx = new Map<Integer, Integer> ();
        Map<Integer, Integer> mapInsertRowNumByIdx = new Map<Integer, Integer> ();

        Integer updateIdx = 0;
        Integer insertIdx=0;
        Map<Integer, Integer> mapUpsertRowNum = new Map<Integer, Integer> ();
        // Set fields to null if they were blank on the page
        for(RemoteTaskWrapper rtw : remoteTasks) {
            Date startDate = rtw.task.pse__Start_Date__c;
            Date endDate= rtw.task.pse__End_Date__c;
            for (String fieldApiName : rtw.fieldsToNull) {
                if (fieldApiName == 'pse__Start_Date__c' || fieldApiName == 'pse__End_Date__c') continue;
                
                rtw.task.put(fieldApiName, null);                
            }

            if (rtw.task.Id == null) {
                mapInsertRowNumByIdx.put(updateIdx++, rtw.rowNum);
                lstProjTaskToInsert.add(rtw.task);
            } else {
                mapUpdateRowNumByIdx.put(insertIdx++, rtw.rowNum);
                lstProjTaskToUpdate.add(rtw.task);
            }

            ptsToUpsert.add(rtw.task);
            Date dummyStartDate =  rtw.task.DummyStartDate__c == null ? null : convertDate(rtw.task.DummyStartDate__c).dateGMT();
            Date dummyEndDate   =  rtw.task.DummyEndDate__c == null ? null : convertDate(rtw.task.DummyEndDate__c).dateGMT();


            DateTime dummyStartDateTime = convertDate(dummyStartDate);
            DateTime dummyEndDateTime = convertDate(dummyEndDate);
	    
            system.debug('Dummy  Dates Before: ' + rtw.task.DummyStartDate__c + ' - ' + rtw.task.DummyEndDate__c);
            system.debug('Dummy  Dates After: ' + dummyStartDate + ' - ' + dummyEndDate);
            system.debug('Dummy  DateTimes After: ' + dummyStartDateTime + ' - ' + dummyEndDateTime);
            system.debug('Actual Dates: ' + rtw.task.pse__Start_Date__c + ' - ' + rtw.task.pse__End_Date__c);
            system.debug('Actual DateTimes: ' + rtw.task.pse__Start_Date_Time__c + ' - ' + rtw.task.pse__End_Date_Time__c);
	    
            if (dummyStartDate != rtw.task.pse__Start_Date__c) {
                rtw.task.pse__Start_Date_Time__c = dummyStartDateTime;
            }

            if (dummyEndDate != rtw.task.pse__End_Date__c ) {
                rtw.task.pse__End_Date_Time__c = dummyEndDateTime;
            }

            // system.debug('rtw.task - ' + rtw.task );
        }
    
        Savepoint sp = Database.setSavepoint();
        // ECO_pseProjectTaskTriggers.externalTriggerStart();
        Boolean isDMLErrorFound = false;
        List<ErrorRow> errors = new List<ErrorRow>();

        try {           
            ECO_ProjectTaskValidator.CONFIG_DISABLED = true;
            Database.SaveResult[] srListUpdate = Database.update(lstProjTaskToUpdate, false);
            updateIdx = 0;
            insertIdx=0;
            for(Database.SaveResult srru : srListUpdate )
            {
                RemoteTaskWrapper rtw = remoteTasks[updateIdx++];
                if(!srru.isSuccess())
                {
                    isDMLErrorFound = true;
                    for(Database.Error objerru : srru.getErrors())
                    {
                        system.debug(LoggingLevel.ERROR, objerru.getMessage());
                        String[] errSplit = objerru.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
                        String errMsg = errSplit.size() > 1 ? errSplit[errSplit.size()-1] : objerru.getMessage();
                        // lstTaskDetailWrapper[rowNum].strErrorMsg = errMsg;
                        errors.add(new ErrorRow(mapUpdateRowNumByIdx.get(updateIdx-1), errMsg));
                    }
                }
            }
            
            Database.SaveResult[] srListInsert = Database.insert(lstProjTaskToInsert, false);
            
            for(Database.SaveResult srr : srListInsert)
            {
                RemoteTaskWrapper rtw = remoteTasks[insertIdx++];
                if(!srr.isSuccess())
                {
                    isDMLErrorFound = true;
                    for(Database.Error objerr : srr.getErrors())
                    {
                        system.debug(LoggingLevel.ERROR, objerr.getMessage());
                        String[] errSplit = objerr.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
                        String errMsg = errSplit.size() > 1 ? errSplit[errSplit.size()-1] : objerr.getMessage();
                        //lstTaskDetailWrapper[rowNum].strErrorMsg = errMsg;
                        errors.add(new ErrorRow(mapInsertRowNumByIdx.get(insertIdx-1), errMsg));
                    }
                }
            }
            
            // mapUpdateRowNum.put(rowsAdded++, intCount);
            //upsert ptsToUpsert;
            /*
            Database.UpsertResult[] upsertResults = Database.upsert(ptsToUpsert, false);

            Integer updateIdx = 0;
            for(Database.UpsertResult srru : upsertResults )
            {
                RemoteTaskWrapper rtw = remoteTasks[updateIdx++];

                if(!srru.isSuccess())
                {
                    isDMLErrorFound = true;
                    for(Database.Error objerru : srru.getErrors())
                    {
                        system.debug(LoggingLevel.ERROR, objerru.getMessage());
                        String[] errSplit = objerru.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
                        String errMsg = errSplit.size() > 1 ? errSplit[errSplit.size()-1] : objerru.getMessage();
                        errors.add(new ErrorRow(rtw.rowNum, errMsg));
                    }
                }
            }
            */
            lstProjTaskToUpdate.addAll(lstProjTaskToInsert);
            ECO_ProjectTaskValidator.CONFIG_DISABLED = false;
            // Save some time validating the upsert if there was an error for another reason
            if (!isDMLErrorFound) {
                List<string> validationErrors = ECO_ProjectTaskValidator.validateForInsertAndUpdate(lstProjTaskToUpdate, new ECO_ProjectTaskService());
                if (validationErrors.size() != 0) {
                    isDMLErrorFound = true;
                }
            }
            return errors;
        } catch (Exception ex) {
            isDMLErrorFound = true;
            errors.add(new ErrorRow(-1, ex.getMessage()));
            system.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            return errors;
        } finally {
            if (isDMLErrorFound) {
                Database.rollback(sp);
            }
            return errors;
        }
    }

    public List<SelectOption> taskPageOptions               { get; set; }
    public String taskRange                                 { get; set; }
    public String oldParentTaskFilter   { get; set; }
    public String parentTaskFilter                          { get; set; }
    public Boolean tooManyTasks                             { get; set; }
    public List<SelectOption> taskFilterOptions             { get; set; }
    public List<SelectOption> taskFilterOptions2            { get; set; }
    public List<SelectOption> taskFilterOptions3            { get; set; }
    public List<SelectOption> taskFilterOptions4            { get; set; }
    public List<SelectOption> taskFilterOptions5            { get; set; }

    //Class Constructor
    public ECO_TaskDetailController(ApexPages.StandardController con) 
    {
        lstProjTaskToDelete = new list<pse__Project_Task__c>();
        theProject = ECO_Service_Projects.getProjectById(con.getId());
        projectId = theProject.Id;
        intRowNo = 0;
        boolShowNewBtn = false;
    	this.taskFilterOptions = new List<SelectOption>();
        this.taskFilterOptions2 = new List<SelectOption>();
        this.taskFilterOptions3 = new List<SelectOption>();
        this.taskFilterOptions4 = new List<SelectOption>();
        this.taskFilterOptions5 = new List<SelectOption>();
        this.taskFilterOptions.add( new SelectOption( '-1', 'All'));

        //get the requested filter task from the param list
        this.parentTaskFilter = ApexPages.currentPage().getParameters().get('parentTaskFilter');
        // this.taskRange = ApexPages.currentPage().getParameters().get('taskRange');
        if( this.parentTaskFilter == null){
            this.parentTaskFilter = '-1';
        }
        this.oldParentTaskFilter = this.parentTaskFilter;

        this.tooManyTasks = false;
        Integer taskListSize = ECO_ProjectTaskService.loadParentTaskFilter(projectId, parentTaskFilter, taskFilterOptions, taskFilterOptions2, taskFilterOptions3, taskFilterOptions4, taskFilterOptions5);
        if( taskListSize > ECO_DTO_BudgetLabourWrapper.taskLimit && this.parentTaskFilter == '-1'){
            this.tooManyTasks = true;
            return;
        }
        reload();
    }

    public void loadBurdenSchedules() {
        List<BurdenSchedule__c> scheduleListRaw = [select id, OracleRateScheduleName__c from BurdenSchedule__c];

        Set<String> schedules = new Set<String>();

//      for (BurdenReference__c reference : references) {
//          schedules.add(reference.Schedule__c);
//      }

        for (BurdenSchedule__c schedule : scheduleListRaw) {
            schedules.add(schedule.OracleRateScheduleName__c);
        }

        List<String> scheduleList = new List<String>(schedules);

        scheduleList.sort();

        burdenSchedules = new List<SelectOption>();
        burdenSchedules.add(new SelectOption('', '-- None --'));

        boolean found = false;
        boolean foundField = false;

        for (String schedule : scheduleList) {
            burdenSchedules.add(new SelectOption(schedule, schedule));
        }

    }

    public static Datetime convertDate(Date dt) {
        if (dt == null) return null;

        return datetime.newInstanceGmt(dt.year(),dt.month(),dt.day());
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
        String strPageNum = System.currentPageReference().getParameters().get('pagenum');
        pageReference.getParameters().clear();
        pageReference.getParameters().put('Id', this.projectId);
        pageReference.getParameters().put('pagenum', strPageNum);
        pageReference.getParameters().put('parentTaskFilter', this.parentTaskFilter);

        if (oldParentTaskFilter == this.parentTaskFilter && 
            taskRange != null) 
        {
            pageReference.getParameters().put('taskRange', taskRange);
        }
        
        pageReference.setRedirect(true);

        return pageReference;
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
        Id projId = theProject.Id;

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

    public void reload() 
    {
        List<ProjectTeamMember__c> listPTM = [ SELECT Id, Name, User__c, Project__c, Active__c FROM ProjectTeamMember__c 
        WHERE Project__c = :theProject.Id
        AND Contact__r.pse__Salesforce_User__c = :userinfo.getuserId() 
        AND (projectRole__r.Name = 'Project Accountant' OR projectRole__r.Name = 'Project Accountant 2')];

        showBurdenSchedule = (listPTM.size() > 0) || ApexPages.currentPage().getParameters().get('showBurdenSchedule') != null;
        
        ECO_ProjectTaskService ets = new ECO_ProjectTaskService();
        String filter = '';
        Set<String> taskFilters = null;
        if( parentTaskFilter != null && parentTaskFilter != '-1'){
            taskFilters = setTaskPagination();
            taskFilters = (taskFilters == null || taskFilters.size() == 0) ? new Set<String> { '%' } : taskFilters;

           String taskFiltersStr = String.join(new List<String>(taskFilters),'\',\'');
          filter += '( ( pse__Top_level_Parent_Task__r.ProjectTaskNumber__c = \'' + parentTaskFilter + '\' AND pse__Task_Key_Chain__c LIKE {\'' + taskFiltersStr + '\'}  )';
          filter += ' OR ProjectTaskNumber__c = \'' + parentTaskFilter + '\')';
           

        } else {
            filter = null;
        }
        tasks = ets.getProjectTaskListByFilters(projectId, parentTaskFilter, taskFilters,  999);
        mapTasksById = ets.projectTaskMap;

        lstTaskDetailWrapper = new list<TaskDetailWrapper>();
        list<SelectOption> lstWorkTypeName = new list<SelectOption>();
        lstWorkTypeName.add(new SelectOption('',Label.EcoGeneralNone));
        for(string strLbl : mapPicklistLabelToValue.keySet())
        {
            lstWorkTypeName.add(new SelectOption(strLbl,mapPicklistLabelToValue.get(strLbl)));
        }
        
        loadBurdenSchedules();

        lstActions = new List<SelectOption>();
        lstActions.add(new SelectOption('',Label.Task_Detail_Select_Task_Select_Action));
        lstActions.add(new SelectOption('AddPeerTask',Label.Task_Detail_Select_Task_Add_Peer_Task));
        lstActions.add(new SelectOption('AddSubTask',Label.Task_Detail_Select_Task_Add_Sub_Task));
        lstActions.add(new SelectOption('AddSubWPT',Label.Task_Detail_Select_Task_Add_Sub_Work_Plan_Task));
        lstActions.add(new SelectOption('DeleteTask',Label.Task_Detail_Select_Task_Delete_Task));

        lstWPTActions = new List<SelectOption>();  
        lstWPTActions.add(new SelectOption('',Label.Task_Detail_Select_Task_Select_Action));
        lstWPTActions.add(new SelectOption('AddSubWPT',Label.Task_Detail_Select_Task_Add_Sub_Work_Plan_Task));
        lstWPTActions.add(new SelectOption('DeleteTask',Label.Task_Detail_Select_Task_Delete_Task));

        for(ECO_ProjectTask obj : tasks)
        {
            TaskDetailWrapper objTD = new TaskDetailWrapper(obj);
            /*
            if(obj.oprojectTask.ForecastStartDate__c == null && obj.oprojectTask.pse__Start_Date_Time__c != null)
            {
                obj.oprojectTask.ForecastStartDate__c = obj.oprojectTask.pse__Start_Date_Time__c.date();
            }
            if(obj.oprojectTask.ForecastEndDate__c == null && obj.oprojectTask.pse__End_Date_Time__c != null)
            {
                obj.oprojectTask.ForecastEndDate__c = obj.oprojectTask.pse__End_Date_Time__c.date();
            }
            */
            lstTaskDetailWrapper.add(objTD);    
        }
        if(lstTaskDetailWrapper.size() == 0)
        {
            boolShowNewBtn = true;
        }
    }

    public List<SelectOption> lstActions {get; set;}
    public List<SelectOption> lstWPTActions {get; set;}
    public List<SelectOption> lstWorkTypeName { 
        get {
            if (lstWorkTypeName == null) {
                Schema.DescribeFieldResult fieldResult = pse__Project_Task__c.WorkTypeName__c.getDescribe();
                lstWorkTypeName = new List<SelectOption>();
                lstWorkTypeName.add(new SelectOption('','--None--'));        

                for( Schema.PicklistEntry f : fieldResult.getPicklistValues())
                {
                    lstWorkTypeName.add(new SelectOption(f.getValue(), f.getLabel()));
                }
            }

            return lstWorkTypeName;
        }
        private set;
    }

    public class TaskDetailWrapper
    {
        public  ECO_ProjectTask objEPT{get;set;}
        public string strSelectedAction{get;set;}
        public string strSelectedWorkTypeName {
            get {
                return objEPT.oprojectTask.WorkTypeName__c;
            }
            set {
                objEPT.oprojectTask.WorkTypeName__c = value;    
            }
        }
        public Boolean hasChanged {get; set;}
        public boolean boolShowInput{get;set;}
        public string strSub_PeerTask{get;set;}
        public string strErrorMsg{get;set;}
        public boolean isErrorRow{get;set;}
        public  Blob oldHash {get; set;}
        public boolean isNew {get;set;}
        
        public TaskDetailWrapper(ECO_ProjectTask obj)
        {

            // obj.oProjectTask.DummyStartDate__c = obj.oProjectTask.pse__Start_Date_Time__c.dateGmt();
            // obj.oProjectTask.DummyEndDate__c = obj.oProjectTask.pse__End_Date_Time__c.dateGmt();

            oldHash = ECO_Utils_Meta.getHash(obj.oProjectTask);
            strErrorMsg = '';
            isErrorRow = false;
            objEPT = obj;
            this.strSelectedAction = '';
            strSub_PeerTask = '';
            boolShowInput = false;
            hasChanged = false;
            if (strSelectedWorkTypeName == null) {
                strSelectedWorkTypeName = 'Home Office';
            }
            /*
            lstAction.add(new SelectOption('','Select Action'));
            lstAction.add(new SelectOption('AddPeerTask','Add Peer Task'));
            
            //if(objEPT.oprojectTask.OracleSyncStatus__c == 'P' || objEPT.oprojectTask.OracleSyncStatus__c == 'E')
            //{
                lstAction.add(new SelectOption('AddSubTask','Add Sub Task'));
                
            //}
            lstAction.add(new SelectOption('DeleteTask','Delete Task'));
            */
            
        }
    }
    
    public pagereference manageRows()
    {
        reload();

        try
        {
            TaskDetailWrapper objTDW = lstTaskDetailWrapper[intRowNo];

            //lstProjTaskToDelete.clear();
            if(objTDW != null)
            {
                objTDW.strSelectedAction = strSelectedAction;
                system.debug(LoggingLevel.INFO, 'strSelectedAction: ' + strSelectedAction);
                if(objTDW.strSelectedAction.EqualsIgnoreCase('AddPeerTask') || 
                    objTDW.strSelectedAction.EqualsIgnoreCase('AddSubTask') ||
                    objTDW.strSelectedAction.EqualsIgnoreCase('AddSubWPT') )
                {
                    
                    pse__Project_Task__c objPT = objTDW.objEPT.oprojectTask.clone(false, false, false, false); 

                    system.debug('AddTask before: ' + objPT);
                    objPT.pse__Order__c = null;
                    ECO_ProjectTask objECO = new ECO_ProjectTask(objPT);

                    objPT.Name = '';
                    objPT.ProjectTaskNumber__c = null;
                    objPT.IsChargeable__c = true;

                    if(objTDW.strSelectedAction.EqualsIgnoreCase('AddSubTask'))
                    {
                        objTDW.objEPT.oprojectTask.IsChargeable__c = false;
                        objPT.pse__Parent_Task__c = objTDW.objEPT.oprojectTask.Id;
                        objTDW.hasChanged = true;
                    } else if(objTDW.strSelectedAction.EqualsIgnoreCase('AddSubWPT') ) {
                        objPT.IsWorkPlanTask__c = true;
                        objPT.IsChargeable__c =  false;
                        objPT.FinancialTask__c = false;
                        objPT.IsBillable__c = false;
                        objPT.pse__Parent_Task__c = objTDW.objEPT.oprojectTask.Id;
                        objTDW.hasChanged = true;
                    }
                    
                    ECO_ProjectTask ecoParentTask = mapTasksById.get(objPT.pse__Parent_Task__c);

                    if (ecoParentTask!= null) {

                        ecoParentTask.addChild(objECO);
                    }

                    // objECO.oprojectTask = objPT;
                    system.debug('AddTask after: ' + objPT);
                    TaskDetailWrapper obj = new TaskDetailWrapper(objECO);
                    
                    if(objTDW.strSelectedAction.EqualsIgnoreCase('AddPeerTask'))
                        obj.strSub_PeerTask = 'Peer Task';
                    else if(objTDW.strSelectedAction.EqualsIgnoreCase('AddSubTask') || objTDW.strSelectedAction.EqualsIgnoreCase('AddSubWPT') )
                        obj.strSub_PeerTask = 'Sub Task';
                        
                    obj.boolShowInput = true;
                    if(intRowNo+1 == lstTaskDetailWrapper.size())
                        lstTaskDetailWrapper.add(obj);
                    else
                        lstTaskDetailWrapper.add(intRowNo+1,obj);
                }
                else if(objTDW.strSelectedAction.EqualsIgnoreCase('DeleteTask'))
                {
                    lstProjTaskToDelete.add(lstTaskDetailWrapper[intRowNo].objEPT.oprojectTask);
                    
                    lstTaskDetailWrapper.Remove(intRowNo);
                    delete lstProjTaskToDelete;
                }
            }
        }
        catch(Exception ex) {
            system.debug(LoggingLevel.ERROR, 'Line: ' + ex.getLineNumber() + ' - ' + ex.getMessage() );
             system.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,ex.getMessage()));        
        }
        
        return null;
    }
    
    public pagereference addNewRowTask()
    {
        try
        {
            reload();
             system.debug(LoggingLevel.ERROR, '567');
            if(lstTaskDetailWrapper.size() == 0)
            {
                ECO_ProjectTask objECO = new ECO_ProjectTask();
                pse__Project_Task__c objPT = new pse__Project_Task__c();
                objECO.oProjectTask = objPT;
                objPT.Name = '';
                objPT.ProjectTaskNumber__c = null;
                objPT.pse__Project__c = theProject.id;
                objPT.FinancialTask__c = true;
                objPT.IsChargeable__c = true;
                objPT.IsBillable__c = true;
                objPT.pse__Start_Date_Time__c = datetime.newInstance(theProject.EstimatedStartDate__c.year(), theProject.EstimatedStartDate__c.month(),theProject.EstimatedStartDate__c.day());
                Date endDate = theProject.EstimatedEndDate__c == Null ? theProject.EstimatedStartDate__c : theProject.EstimatedEndDate__c;
                objPT.pse__End_Date_Time__c = datetime.newInstance(endDate.year(), endDate.month(),endDate.day());
                //objPT.ForecastStartDate__c = theProject.EstimatedStartDate__c;
                // objPT.ForecastEndDate__c = theProject.EstimatedEndDate__c == Null ? theProject.EstimatedStartDate__c : theProject.EstimatedEndDate__c;
                objPT.EarnedValueCurve__c = 'Even';            
                list<SelectOption> lstWorkTypeName = new list<SelectOption>();
                lstWorkTypeName.add(new SelectOption('','--None--'));
                for(string strLbl : mapPicklistLabelToValue.keySet())
                {
                    lstWorkTypeName.add(new SelectOption(strLbl,mapPicklistLabelToValue.get(strLbl)));
                }
                
                TaskDetailWrapper obj = new TaskDetailWrapper(objECO);
                
                objECO.oprojectTask = objPT;
                
                obj.strSub_PeerTask = '';
                
                obj.boolShowInput = true;
                
                
                lstTaskDetailWrapper.add(obj);
                
                boolShowNewBtn = false;
            }
        }
        catch(Exception ex)
        {
            system.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,ex.getMessage()));
        }
        
        return null;
    }
}