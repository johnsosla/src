@isTest(seealldata=false)
private class ECO_TaskDetailControllerTest
{
    static pse__Proj__c objProj;
    static pse__Project_Task__c objProjTask;
    static pse__Project_Task__c objProjTask2;
    static pse__Project_Task__c objPProjTask;
    
    @testSetup static void initTest() {
    
        //Fix for error "NullPointerException: Attempt to de-reference a null object" - 04-11-2017
        insert new ECO_Limits_Thresholds__c(Budget_TaskLimit__c = 600, SOQL_Limit_Buffer__c = 20, SOQL_per_TaskWeeks__c = 0.0500, EVR_TaskLimit__c = 390);
        
        Integer numOfWeeks = 5, numOfProjectTasks = 5;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.ProjectWrapper myProjWrapper = ECO_Utils_Testing.createProjectWithTasks('A', numOfProjectTasks, numOfWeeks);        
        ECO_ProjectTaskTriggers.run = true;
    }

/*
    static testMethod void myUnitTestTrigger()
    {
        createProject();
        createParentProjectTask();
        Test.StartTest();
        createProjectTask();
        
        objProjTask2.FinancialTask__c = false;
        //Added this to byPass the validation Error during Running test class
        try
        {
            update objProjTask2;
        }
        catch(Exception objExp)
        {}
        Test.StopTest();
    }
    */
    static pse__Proj__c getProject() {
        return [select id from pse__Proj__c limit 1];
    }


    static void simSave(ECO_TaskDetailController objTDC) {
        List<ECO_TaskDetailController.RemoteTaskWrapper> remoteTasks = new List<ECO_TaskDetailController.RemoteTaskWrapper>();

        Integer rowNum = 0;
        for(ECO_TaskDetailController.TaskDetailWrapper tdw : objTDC.lstTaskDetailWrapper) {
            ECO_TaskDetailController.RemoteTaskWrapper rtw = 
                new ECO_TaskDetailController.RemoteTaskWrapper(rowNum++, tdw.objEPT.oprojectTask);

            remoteTasks.add(rtw);            
        }

        ECO_TaskDetailController.updateTasks(remoteTasks);

    }

    static testMethod void myUnitTest1()
    {        
        objProj = getProject();
        list<pse__Proj__c> projs = [select id, Name from pse__Proj__c];

        system.debug('--projs: ' + projs);
        ApexPages.StandardController con = new ApexPages.StandardController(objProj);
        ECO_TaskDetailController objTDC = new ECO_TaskDetailController(con);
        String teststr = objTDC.burdenSchedule;
        List<SelectOption> testoptions = objTdc.lstWorkTypeName;
        teststr = objTDC.burdenScheduleField;
        objTDC.getUserLocale();
        objTDC.intRowNo = 0;
        objTDC.strSelectedAction = 'AddPeerTask';
        objTDC.lstTaskDetailWrapper[0].strSelectedAction = 'AddPeerTask';
        teststr = objTDC.lstTaskDetailWrapper[0].strSelectedWorkTypeName;
        objTDC.lstTaskDetailWrapper[0].strSelectedWorkTypeName  = teststr;
        objTDC.manageRows();

        Test.startTest();
        simSave(objTDC);
        Test.stopTest();
        // objTDC.updateTasks();
        
        //ECO_TaskDetailController.TaskDetailWrapper obj = new ECO_TaskDetailController.TaskDetailWrapper();
    }
    
    static testMethod void testAddSub()
    {
        objProj = getProject();
        ApexPages.StandardController con = new ApexPages.StandardController(objProj);
        ECO_TaskDetailController objTDC = new ECO_TaskDetailController(con);
        objTDC.intRowNo = 0;
        objTDC.strSelectedAction = 'AddSubTask';
        objTDC.lstTaskDetailWrapper[0].strSelectedAction = 'AddSubTask';
        objTDC.manageRows();
        Test.startTest();
        simSave(objTDC);
        Test.stopTest();
        // objTDC.mySave();
        
        //ECO_TaskDetailController.TaskDetailWrapper obj = new ECO_TaskDetailController.TaskDetailWrapper();
    }
    
    static testMethod void testAddSubWPT()
    {
        objProj = getProject();
        ApexPages.StandardController con = new ApexPages.StandardController(objProj);
        ECO_TaskDetailController objTDC = new ECO_TaskDetailController(con);
        objTDC.intRowNo = 0;
        objTDC.strSelectedAction = 'AddSubWPT';
        objTDC.lstTaskDetailWrapper[0].strSelectedAction = 'AddSubWPT';
        objTDC.manageRows();
        Test.startTest();
        simSave(objTDC);
        Test.stopTest();
        // objTDC.mySave();
        
        //ECO_TaskDetailController.TaskDetailWrapper obj = new ECO_TaskDetailController.TaskDetailWrapper();
    }

    static testMethod void myUnitTest3()
    {
        objProj = getProject();
        
        ApexPages.StandardController con = new ApexPages.StandardController(objProj);
        ECO_TaskDetailController objTDC = new ECO_TaskDetailController(con);
        objTDC.intRowNo = 0;
        objTDC.strSelectedAction = 'DeleteTask';
        objTDC.lstTaskDetailWrapper[0].strSelectedAction = 'DeleteTask';
        Test.startTest();
        objTDC.manageRows();
        Test.stopTest();
        //objTDC.mySave();
    }
    
    static testMethod void myUnitTest4()
    {
        // objProj = getProject();
        Test.startTest();
        pse__Proj__c emptyProject = ECO_Utils_Testing.createProject(Date.today(), Date.today().addDays(13));

        ApexPages.StandardController con = new ApexPages.StandardController(emptyProject);
        ECO_TaskDetailController objTDC = new ECO_TaskDetailController(con);
        objTDC.intRowNo = 0;
        
        objTDC.addNewRowTask();
        // objTDC.mySave();
        Test.stopTest();
    }

    static testMethod void myUnitTest5()
    {        
        objProj = getProject();
        Test.setCurrentPage(Page.ECO_TaskDetail);
        ApexPages.currentPage().getParameters().put('parentTaskFilter', '1');
        ApexPages.StandardController con = new ApexPages.StandardController(objProj);
        ECO_TaskDetailController objTDC = new ECO_TaskDetailController(con);

        Test.startTest();
        objTDC.refreshData();
        simSaveAsync(objTDC);
        objTDC.setTaskPagination();

        ECO_TaskDetailController.ErrorRow er = new ECO_TaskDetailController.ErrorRow(1, '');
        ECO_TaskDetailController.updateTask(null);
        ECO_TaskDetailController.test();
        Test.stopTest();
    }
    static void simSaveAsync(ECO_TaskDetailController objTDC) {
        List<ECO_TaskDetailController.RemoteTaskWrapper> remoteTasks = new List<ECO_TaskDetailController.RemoteTaskWrapper>();

        Integer rowNum = 0;
        for(ECO_TaskDetailController.TaskDetailWrapper tdw : objTDC.lstTaskDetailWrapper) {
            ECO_TaskDetailController.RemoteTaskWrapper rtw = 
                new ECO_TaskDetailController.RemoteTaskWrapper(rowNum++, tdw.objEPT.oprojectTask);

            remoteTasks.add(rtw);            
        }

        ECO_TaskDetailController.updateTasksAsync(remoteTasks);

    }
    
    static void createProject()
    {
        objProj = [select Id from  pse__Proj__c limit 1];
    }

    static void createProjectTask()
    {
        list<pse__Project_Task__c> lst = new list<pse__Project_Task__c>();
        objProjTask = new pse__Project_Task__c();
        objProjTask.Name = 'Test Project Task';
        objProjTask.FinancialTask__c = true;
        objProjTask.OracleSyncStatus__c = 'P';
        objProjTask.pse__Project__c = objProj.Id;
        objProjTask.pse__Parent_Task__c = objPProjTask.Id;
        //insert objProjTask ;a
        lst.add(objProjTask);
        objProjTask2 = new pse__Project_Task__c();
        objProjTask2.Name = 'Test Project Task';
        objProjTask2.FinancialTask__c = true;
        objProjTask2.OracleSyncStatus__c = 'P';
        objProjTask2.pse__Project__c = objProj.Id;
        objProjTask2.pse__Parent_Task__c = objPProjTask.Id;
        
        //insert objProjTask2 ;
        lst.add(objProjTask2);
        
        insert lst;
    }
    
    static void createParentProjectTask()
    {
        objPProjTask = new pse__Project_Task__c();
        objPProjTask.Name = 'Test Project Task';
        objPProjTask.FinancialTask__c = true;
        objPProjTask.OracleSyncStatus__c = 'P';
        objPProjTask.pse__Project__c = objProj.Id;
        
        insert objPProjTask ;
    }
}