global with sharing class ECO_PMD_Project_Schedule_Controller extends ECO_Financial_Security{

      private final pse__Proj__c oProject ;

      public string locale { get {return UserInfo.getLocale().replace('_', '-');} }
      
      public ECO_PMD_ProjectWrapper wrapper { get; set; }

      public ECO_PMD_Project_Schedule_Controller() { 
      }

      public ECO_PMD_Project_Schedule_Controller (ApexPages.StandardController oStandardController) {
        this.oProject = (pse__Proj__c)oStandardController.getRecord();
        this.wrapper = new ECO_PMD_ProjectWrapper(this.oProject);
      }

        @RemoteAction
    global static List<pse__Project_Task__c> ProjectScheduleTasks(String projectNum)
    {
        Id projectId = projectNum;

        //List<pse__Project_Task__c>  snapshots;

        List<pse__Project_Task__c> ordered_evs = new List<pse__Project_Task__c> ();
        
        try
        {
            // GET THE LATEST TWO SNAPSHOTS FOR THE PROJECT
            

            List<pse__Project_Task__c> evs  = [SELECT ProjectTaskNumber__c
                , pse__End_Date__c
                , ForecastEndDate__c
                , ScheduleVariance__c
                , pse__Project__c
                , Name
                , pse__Parent_Task__r.Id
                , pse__Order__c
                , pse__Hierarchy_Depth__c
                FROM pse__Project_Task__c
                where pse__Project__c = :projectId 
                ORDER BY pse__Hierarchy_Depth__c asc, pse__Order__c asc,ProjectTaskNumber__c desc];


            ordered_evs = ECO_PMD_Helpers.sortProjecTasks(evs);
            

        }
        catch (Exception ex){

            // HMMM
        }

        return ordered_evs;
    }

}