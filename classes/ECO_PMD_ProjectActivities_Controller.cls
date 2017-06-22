global with sharing class ECO_PMD_ProjectActivities_Controller {

   public ECO_PMD_ProjectActivities_Controller(){
    }

    @RemoteAction
    global static ProjectActivitesSummary GetActivitesSummary(String projectNum)
    {
       
        Id projectId = projectNum;
 
        ProjectActivitesSummary summary = new ProjectActivitesSummary();

        List<Task> taskData = [ SELECT ActivityDate
                                        , WhatId
                                        , RecordTypeId
                                        , Description
                                        , Subject
                                        , Status
                                        , IsClosed
                                FROM 
                                    Task
                                WHERE 
                                    whatId = :projectId
                                    ];

        Integer listsize = taskData.size();                        
 
        summary.countDueNext7Days = database.countQuery(
            'SELECT COUNT() FROM Task Where whatId = :projectId AND IsClosed = FALSE AND ActivityDate = NEXT_N_DAYS:7'
            );
        summary.countOpenPastDue = database.countQuery(
            //'SELECT COUNT() FROM Task Where whatId = :projectId AND IsClosed = FALSE AND (ActivityDate < TODAY OR ActivityDate > TODAY)'
            'SELECT COUNT() FROM Task Where whatId = :projectId AND IsClosed = FALSE AND ActivityDate < TODAY' 
            );
        summary.countOpen = database.countQuery(
            'SELECT COUNT() FROM Task Where whatId = :projectId AND IsClosed = FALSE'
            );
        return summary;
    }

    global class ProjectActivitesSummary
    {
        public ProjectActivitesSummary()
        {
            error = '';
            nodata = false;

            countOpen = 0;
            countOpenPastDue = 0;
            countDueNext7Days = 0;
        }

        public String error;
        public Boolean nodata;

        public Integer  countOpen;
        public Integer  countOpenPastDue;
        public Integer  countDueNext7Days;
        
    }
}