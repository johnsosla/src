/** ------------------------------------------------------------------------------------------------------------
* @Description This class runs the Batch job for the "Project Team Members" process, based on the 
*              job Location and can also be rerun for failed jobs.
*
* @Author      NTT Data - Arman Shah
* @Date        September 2016
*--------------------------------------------------------------------------------------------------------------*/
global class ECO_GroupedBatchProjectTeamMember extends ECO_BatchAdminService {
    public static final Integer DEFAULT_BATCH_SIZE = 200;
    public String query                         { get; set; }
    public List<String> fiscalList              { get; set; }
    
    /**
     *  constructor
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/  
    public ECO_GroupedBatchProjectTeamMember() {

    }

    /**
     *  fiscalMethod
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/  
    public List<String> fiscalMethod(String str){
        String Year = str.subStringAfter('FY').subStringBefore('-');
        String Month = str.subStringAfter('FY').subStringAfter('-');
        List<String> fiscalList = new List<String>();
        fiscalList.add(str);
        Integer d =0;
        Integer d1 =0;
        for (Integer i=0; i<=13; i++)
        {
           Integer Mon = Integer.valueOf(Month)-i;
           if (Mon >=1)
           {
              String ste;
              if (Mon <10)
                  ste = 'FY'+Year+'-0'+Mon;
              else
                  ste = 'FY'+Year+'-'+Mon;
              fiscalList.add(ste); 
           }
           else
           {
               Integer lastyear;
               Integer lastYearMonth;
               if(d !=12)
               {
                   lastyear = Integer.valueof(Year)-1;
                    lastYearMonth = 12-d;
                     String ste;
                     if(lastYearMonth <10)
                         ste = 'FY'+lastyear+'-0'+lastYearMonth;
                     else
                         ste = 'FY'+lastyear+'-'+lastYearMonth;
                     
                    fiscalList.add(ste);
                    d = d+ 1; 
               }
               else{
                   lastyear = integer.valueof(Year)-2;
                   lastYearMonth = 12-d1;            
                   String ste;
                   if (lastYearMonth <10)
                       ste = 'FY'+lastyear+'-0'+lastYearMonth;
                   else
                       ste = 'FY'+lastyear+'-'+lastYearMonth;
                         
                   fiscalList.add(ste);
                   d1 = d1+1;
               }
           }
        }  
        return fiscalList;
    }
    
    /**
     *  setup the query to run the batch against
     *
     * @Author  NTT Data - Arman Shah
     * @Date    query changed in August 2016
     *
     * @param   BC
     * @return  Database.QueryLocator
    **/
    global Database.QueryLocator start(Database.BatchableContext BC) {

        //log the job start
        this.logId = ECO_Service_BatchLog.logJobStart('ECO_GroupedBatchProjectTeamMember', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);

        /*List<String> regionOuIds = new list<string>();
        regionOuIds = ECO_GroupedBatchHelper.getListOfRegions();

        query = 'SELECT Id,name,Department__c,  Contact__c,LaborCost01FiscalMonthAgo__c,LaborCost02FiscalMonthAgo__c,'+
            'LaborCost03FiscalMonthsAgo__c,LaborCost04FiscalMonthsAgo__c,LaborCost05FiscalMonthsAgo__c,'+
            'LaborCost06FiscalMonthsAgo__c,LaborCost07FiscalMonthsAgo__c,LaborCost08FiscalMonthsAgo__c,'+
            'LaborCost09FiscalMonthsAgo__c,LaborCost10FiscalMonthsAgo__c,LaborCost11FiscalMonthsAgo__c,'+
            'LaborCost12FiscalMonthsAgo__c,LaborHours01FiscalMonthAgo__c,LaborHours02FiscalMonthsAgo__c,'+
            'LaborHours03FiscalMonthsAgo__c,LaborHours04FiscalMonthsAgo__c,LaborHours05FiscalMonthsAgo__c,'+
            'LaborHours06FiscalMonthsAgo__c,LaborHours07FiscalMonthsAgo__c,LaborHours08FiscalMonthsAgo__c,'+
            'LaborHours09FiscalMonthsAgo__c,LaborHours10FiscalMonthsAgo__c,LaborHours11FiscalMonthsAgo__c,'+
            'LaborHours12FiscalMonthsAgo__c, PersonId__c, Project__c, Project__r.pse__Is_Active__c'+
            ' FROM ProjectTeamMember__c'+
            ' WHERE Project__r.pse__Stage__c=\'Execution\' AND Project__r.ouid__c IN: regionOuIds ';*/

        if( this.isProcessingBlock){
            query = 'SELECT id, ' +
                    'SObjectID__c ' +
                    'FROM BatchedChildObject__c ' + 
                    'WHERE ChildStatus__c != \'Completed\' ' +
                    '   AND PriorityRequestBy__c != null ' +
                    '   AND BatchedObject__r.BatchJob__c=\'Setup - Project Team Members\''; 
        } else {
            query = 'SELECT id, ' +
                    'SObjectID__c ' +
                    'FROM BatchedChildObject__c ' + 
                    'WHERE ChildStatus__c != \'Completed\' ' +
                    '   AND BatchedObject__r.BatchJob__c=\'Setup - Project Team Members\''; 
        }      
        System.debug('PTM SOQL='+query);

        String currentFiscalPeriod = [SELECT id, name, pse__End_Date__c, pse__start_Date__c, TimePeriodCode__c, pse__type__c 
            FROM pse__Time_Period__c WHERE pse__type__c = 'Month' AND pse__start_Date__c <= TODAY AND pse__end_date__c >= TODAY 
            ORDER BY pse__start_date__c DESC LIMIT 1].TimePeriodCode__c;
        this.fiscalList = new List<String>();
        if (currentFiscalPeriod != null) {
           this.fiscalList = fiscalMethod(currentFiscalPeriod );
        }
        return Database.getQueryLocator(query);
    }

    /**
     *  execute
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/  
    global void execute(Database.BatchableContext BC, List<BatchedChildObject__c> scopeBoc) {

        set<id> setPtm = new set<id>();

        for(BatchedChildObject__c boc: scopeBoc){
            setPtm.add(boc.SObjectID__c);
        }

       list<ProjectTeamMember__c> scope = [SELECT Id,name,Department__c,  Contact__c,LaborCost01FiscalMonthAgo__c,LaborCost02FiscalMonthAgo__c,
            LaborCost03FiscalMonthsAgo__c,LaborCost04FiscalMonthsAgo__c,LaborCost05FiscalMonthsAgo__c,
            LaborCost06FiscalMonthsAgo__c,LaborCost07FiscalMonthsAgo__c,LaborCost08FiscalMonthsAgo__c,
            LaborCost09FiscalMonthsAgo__c,LaborCost10FiscalMonthsAgo__c,LaborCost11FiscalMonthsAgo__c,
            LaborCost12FiscalMonthsAgo__c,LaborHours01FiscalMonthAgo__c,LaborHours02FiscalMonthsAgo__c,
            LaborHours03FiscalMonthsAgo__c,LaborHours04FiscalMonthsAgo__c,LaborHours05FiscalMonthsAgo__c,
            LaborHours06FiscalMonthsAgo__c,LaborHours07FiscalMonthsAgo__c,LaborHours08FiscalMonthsAgo__c,
            LaborHours09FiscalMonthsAgo__c,LaborHours10FiscalMonthsAgo__c,LaborHours11FiscalMonthsAgo__c,
            LaborHours12FiscalMonthsAgo__c, PersonId__c, Project__c, Project__r.pse__Is_Active__c
            FROM ProjectTeamMember__c
            WHERE id IN: setPtm];

        String jsonPTM = '';
        jsonPTM = '\n' + JSON.serialize(scope, true);        

        try{
            ECO_Project_TeamMember_Triggers.run = false;
            List<String> projectIdList = new List<String>();
            List<String> personIdList = new List<String>();
            Map<String,decimal> labourHoursMap = new map<String,decimal>();
            Map<String,decimal> labourCostMap = new map<String,decimal>();
            List<ProjectTeamMember__c> teamMemberToBeUpdatedList = new List<ProjectTeamMember__c>();
            for (ProjectTeamMember__c ptm:scope ){
                if (ptm.project__c !=null)
                    projectIdList.add(ptm.project__c);
                if (ptm.personid__c !=null)
                    personIdList.add(ptm.personid__c);
            }
            
            if (projectIdList.size()>0 || personIdList.size()>0)
            {
                for (ExpendItem__c exp :[select id,Quantity__c,  PersonId__c,project__r.pse__Is_Active__c,Project__c,ExpenditureType__c, ExpenditureItemDate__c,ExpenditureDateFiscalMonth__c from ExpendItem__c  where personid__c !=null  and project__r.pse__Is_Active__c = true and project__c IN:projectIdList and personid__c IN:Personidlist and ExpenditureDateFiscalMonth__c IN:fiscalList])
                {
                    if (exp.quantity__c !=null)
                    {
                    
                        if (labourHoursMap.containsKey(exp.personid__c+exp.project__c+exp.ExpenditureDateFiscalMonth__C))
                        {
                                Decimal Qty = labourHoursMap.get(exp.personid__c+exp.project__c+exp.ExpenditureDateFiscalMonth__C) + exp.quantity__c;
                                labourHoursMap.put(exp.personid__c+exp.project__c+exp.ExpenditureDateFiscalMonth__C,qty);
                            
                        }
                        else
                        {
                                labourHoursMap.put(exp.personid__c+exp.project__c+exp.ExpenditureDateFiscalMonth__C,exp.quantity__c);
                        }
                    }
                } 
               
                for (CostDistLine__c cdl :[select id,ExpenditureItem__r.project__c,ExpenditureItem__r.PersonId__c,ExpenditureItem__c,ProjectNumber__c,ProjectFunctionalBurdenedCost__c,PAFiscalMonth__c,ExpenditureItem__r.project__r.pse__Is_Active__c  from CostDistLine__c where ExpenditureItem__r.PersonId__c !=null and ExpenditureItem__r.project__r.pse__Is_Active__c = true and ExpenditureItem__r.project__c IN:projectIdList and ExpenditureItem__r.PersonId__c IN:personIdList and PAFiscalMonth__c IN:fiscalList])
                {
                   if (cdl.ProjectFunctionalBurdenedCost__c !=null)
                    {
                    
                        if (labourCostMap.containsKey(cdl.ExpenditureItem__r.PersonId__c+cdl.ExpenditureItem__r.project__c+cdl.PAFiscalMonth__c))
                        {
                             Decimal Cost = labourCostMap.get(cdl.ExpenditureItem__r.PersonId__c+cdl.ExpenditureItem__r.project__c+cdl.PAFiscalMonth__c)+ cdl.ProjectFunctionalBurdenedCost__c;
                             labourCostMap.put((cdl.ExpenditureItem__r.PersonId__c+cdl.ExpenditureItem__r.project__c+cdl.PAFiscalMonth__c),cost);
                        }
                    }
                    else
                    {
                        labourCostMap.put((cdl.ExpenditureItem__r.PersonId__c+cdl.ExpenditureItem__r.project__c+cdl.PAFiscalMonth__c),cdl.ProjectFunctionalBurdenedCost__c);
                    }
                }
                
                for(ProjectTeamMember__c ptm:scope){
                    if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[0]))
                        ptm.LaborHours01FiscalMonthAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[0]);
                    if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[1]))
                        ptm.LaborHours02FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[1]);
                    if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[2]))
                        ptm.LaborHours03FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[2]);
                    if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[3]))
                        ptm.LaborHours04FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[3]);
                    if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[4]))
                        ptm.LaborHours05FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[4]);
                    if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[5]))
                        ptm.LaborHours06FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[5]);
                    if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[6]))
                        ptm.LaborHours07FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[6]);
                    if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[7]))
                        ptm.LaborHours08FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[7]);
                    if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[8]))
                        ptm.LaborHours09FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[8]);
                    if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[9]))
                        ptm.LaborHours10FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[9]);
                    if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[10]))
                        ptm.LaborHours11FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[10]);
                    if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[11]))
                        ptm.LaborHours12FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[11]);
                    
                    if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[0]))
                        ptm.LaborCost01FiscalMonthAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[0]);
                    if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[1]))
                        ptm.LaborCost02FiscalMonthAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[1]);
                    if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[2]))
                        ptm.LaborCost03FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[2]);
                    if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[3]))
                        ptm.LaborCost04FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[3]);
                    if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[4]))
                        ptm.LaborCost05FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[4]);
                    if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[5]))
                        ptm.LaborCost06FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[5]);
                    if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[6]))
                        ptm.LaborCost07FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[6]);
                    if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[7]))
                        ptm.LaborCost08FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[7]);
                    if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[8]))
                        ptm.LaborCost09FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[8]);
                    if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[9]))
                        ptm.LaborCost10FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[9]);
                    if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[10]))
                        ptm.LaborCost11FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[10]);
                    if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[11]))
                        ptm.LaborCost12FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[11]);
                   
                    teamMemberToBeUpdatedList.add(ptm);
                }
            }
            if(teamMemberToBeUpdatedList.size() > 0)
                update teamMemberToBeUpdatedList ;

            for(BatchedChildObject__c oBatchChild : scopeBoc){
                oBatchChild.ChildStatus__c = 'Completed';
            }

            try{
                update scopeBoc;
            } catch (Exception ex) {
                ECO_Service_ErrorLog.logException(ex, jsonPTM);            
            }

        } catch (Exception ex) {
            ECO_Service_ErrorLog.logException(ex, jsonPTM);            
        }
    }
    
    /**
     *  finish
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/  
    global void finish(Database.BatchableContext BC) {
        //log the end of the job and possible call the next job in the stream
        runNextBatchInStream( BC.getJobId(), 'ECO_ProjectTeamMemberBatch');             
    
    }

    /**
     *  scheduled execute - this should not be run in a scheduled context
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
     * @param   
     **/  
    global void execute(SchedulableContext sc){
        //if (batchSize == null) {
        //    batchSize = = DEFAULT_BATCH_SIZE;
        //}

        //ECO_ProjectTeamMemberBatch b = new ECO_ProjectTeamMemberBatch(batchSize);
        //System.debug('___Batch size='+batchSize);
        //database.executebatch(b, batchSize);
    }
}