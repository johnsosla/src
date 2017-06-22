@isTest
private class ECO_ProjectTaskServiceTest
{
    static pse__Proj__c objProj;
    static pse__Project_Task__c objProjTask;
    static pse__Project_Task__c objPProjTask;
    static ProjectRole__c objPRole;

    static testMethod void myUnitTest()
    {

        objProj = ECO_Utils_Testing.createProject(); 
        Test.StartTest();

        createParentProjectTask();        
        createProjectTask();
        

        ECO_ProjectTaskService obj = new ECO_ProjectTaskService();
        obj.getProjectTaskList(objProj.Id);
        Test.StopTest();
        //Project Task 
        ECO_ProjectTask objPT = new ECO_ProjectTask();
        objPT.oprojectTask = objProjTask;
        string strName = objPT.name;
        string strTaskName = objPT.taskName;
        string strTaskNumber = objPT.tasknumber; 
    }
    
    static void createProject()
    {
        objProj = [select Id from  pse__Proj__c limit 1];
    }
    
    static void createProjectTask()
    {
        objProjTask = new pse__Project_Task__c();
        objProjTask.Name = 'Test Project Task';
        objProjTask.FinancialTask__c = true;
        objProjTask.OracleSyncStatus__c = 'P';
        objProjTask.pse__Project__c = objProj.Id;
        objProjTask.pse__Parent_Task__c = objPProjTask.Id;
        insert objProjTask ;
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