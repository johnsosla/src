global class ECO_GroupedBatch_CreateWeeklyRollups implements Database.Batchable<sObject>, Database.Stateful {
/*
AECOM - Jake White

To generate empty WeeklyRollupEntries for a collection of projects based on BatchedObject__c

Supports the process of importing large OUs from Oracle by creating WREs for all possible weeks for a project
Run this after project and expenditureItems are available in the new instance, but before any other setup steps.

Use as:

ECO_GroupedBatch_CreateWeeklyRollups b = new ECO_GroupedBatch_CreateWeeklyRollups(); 
database.executebatch(b,50);

*/
    global integer initialscope;
    global integer totalscope;
    global integer totalwres;
    global integer foundwres;
    global integer runs;
    global boolean isDryRun;

    global ECO_GroupedBatch_CreateWeeklyRollups(){
        this.isDryRun=false;
    }
       
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        this.totalscope = 0;
        this.totalwres=0;
        this.foundwres=0;
        this.runs=0;
        String queryClause = ' from BatchedObject__c where BatchJob__c=\'Setup - Recalc EV\' and Status__c != \'Completed\' and ChildrenComplete__c = false';
        initialscope = database.countquery('SELECT COUNT() ' + queryClause);
        System.debug('.___isDryRun='+this.isDryRun);
        System.debug('.___initialscope='+this.initialscope);
        //DJO 1/17/2017
        return Database.getQueryLocator('select id, sObjectID__c ' + queryClause);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<BatchedObject__c>scope){
         List<Id> BatchedObjectIds = new list<Id>();
         List<Id> BatchedObject_sObjectIds = new list<Id>();
         for(BatchedObject__c obj:scope){BatchedObject_sObjectIds.add(obj.sObjectID__c);BatchedObjectIds.add(obj.id);}

                 Map<Id,AggregateResult> results = new Map<Id,AggregateResult>();
                 /*
                 for(AggregateResult result:[
                     select ExpenditureItem__r.ProjectTask__r.pse__Project__c, count(id) numcdl, min(PADate__c) paMin, max(PADate__c) paMax
                     from CostDistLine__c
                     Where ExpenditureItem__r.ProjectTask__r.pse__Project__c in :BatchedObject_sObjectIds
                     GROUP BY ExpenditureItem__r.ProjectTask__r.pse__Project__c
                     ORDER BY ExpenditureItem__r.ProjectTask__r.pse__Project__c ASC
                 ]){
                 */
                 for(AggregateResult result:[
                     select Project__c , count(id) numcdl, min(ExpenditureItemDate__c) paMin, max(CurrentPADate__c) paMax
                     from ExpendItem__c
                     Where Project__c in :BatchedObject_sObjectIds
                     GROUP BY Project__c
                     ORDER BY Project__c ASC
                 ]){
                     results.put((Id)result.get('Project__c'),result);
                     system.debug('___result='+result);
                 }
                 System.Debug('___results.size()='+results.size());

         Map<Id,ProjectDateCompare> projectDates = new Map<Id, ProjectDatecompare>();
         for(pse__Proj__c project:[
             SELECT id, pse__Start_Date__c, pse__End_Date__c, RevisedStartDate__c, RevisedEndDate__c, TransactionStartDate__c, TransactionEndDate__c, ProjectFunctionalCurrencyCode__c from pse__Proj__c where ID in :BatchedObject_sObjectIds
         ]){
               ProjectDateCompare dc = new ProjectDateCompare(project);
               if (results.containsKey(project.id)) dc.compareToUseToDates((Date) results.get(project.id).get('paMin'),(Date) results.get(project.id).get('paMax'));
               if (project.TransactionStartDate__c != null) dc.compareToUseToDates((Date) project.TransactionStartDate__c,null);
             
             projectDates.put(project.id, dc);
             system.debug('.___project.id,startToUse,endToUse,hasChanged='+project.id+', '+dc.dStartDateToUse+', '+dc.dEndDateToUse+', '+dc.bHasChanged);
         }
         
         Map<String,WeeklyRollupEntry__c> wres = new Map<String,WeeklyRollupEntry__c>();
         for (ProjectDateCompare projectDate:projectDates.values()){
         	Date firstPeriodBegin = ECO_Service_Snapshots.getFirstDateOfWeek(projectDate.dStartDateToUse);
			Date lastPeriodEndsBefore = ECO_Service_Snapshots.getFirstDateOfWeek(projectDate.dEndDateToUse).addDays(7);
			wres.putAll(ECO_ProjectTaskTriggers.generateWeeklyRollupEntriesBetweenDates(firstPeriodBegin , lastPeriodEndsBefore, projectDate.sProjectId, projectDate.theProject));
         }
         this.runs++;
         this.totalscope += scope.size();
         this.totalwres  += wres.size();
         Set<String> keys = wres.keySet();
         List<WeeklyRollupEntry__c> wreExisting = new List<WeeklyRollupEntry__c>([SELECT CompositeKey__c from WeeklyRollupEntry__c where CompositeKey__c in :keys]);
         this.foundwres += wreExisting.size();
         
         if (!this.isDryRun) {
         	upsert wres.values() CompositeKey__c;
         }
         
         System.debug('.___scope.size='+scope.size());
         System.assertEquals(scope.size(),projectDates.size());
         System.debug('.____projectDate.size='+projectDates.size());
         System.debug('.___wres.size='+wres.size());
         System.debug('.___totalscope='+this.totalscope);
         System.debug('.___totalwres='+this.totalwres);
         System.debug('.___foundwres='+foundwres);
         System.debug('.___runs='+this.runs);
         
         //set the child objects as completed, DJO 1/17/2017
         List<BatchedChildObject__c> updateBcoStatus = new List<BatchedChildObject__c>();
         for(BatchedChildObject__c bco : [SELECT Id FROM BatchedChildObject__c WHERE BatchedObject__c IN :BatchedObjectIds]){
            updateBcoStatus.add( new BatchedChildObject__c( Id=bco.Id, ChildStatus__c = 'Completed'));
         }
         try {
           if (!this.isDryRun) {
           	update updateBcoStatus;
           }
         } catch (Exception ex) {
            ECO_Service_ErrorLog.logException(ex, JSON.serialize(updateBcoStatus));            
         }
       }
    
    // Wrap Up after all batches have been run
    global void finish(Database.BatchableContext BC){
        System.debug('.___isDryRun='+this.isDryRun);
        System.debug('.___initialscope='+this.initialscope);
        System.debug('.___totalscope='+this.totalscope);
        System.debug('.___totalwres='+this.totalwres);        
        System.debug('.___foundwres='+this.foundwres);
    }
    
    @TestVisible private class ProjectDateCompare{
        public Id sProjectId {get; set;}
        public pse__Proj__c theProject {get; set;}
        
        
        public Date dProjectStartDate {get; set;}
        public Date dProjectEndDate {get; set;}
        public Date dStartDateToUse {get; set;}
        public Date dEndDateToUse {get; set;}
        
        public Date dProjectForecastStartDate {get; set;}
        public Date dProjectForecastEndDate {get; set;}
        public Date dForecastStartDateToUse {get; set;}
        public Date dForecastEndDateToUse {get; set;}
        
        public boolean bHasChanged {
            get{
                if(dProjectStartDate != dStartDateToUse || dProjectEndDate != dEndDateToUse || 
                   dProjectForecastStartDate != dForecastStartDateToUse || dProjectForecastEndDate != dForecastEndDateToUse){
                       return true;
                   }
                return false;
            }
            set;
        }
        
        public boolean bGenerateAll {
            get{
                if(dProjectStartDate == null || dProjectEndDate == null){
                    return true;
                }
                return false;
            } 
            set;
        }
        
        public boolean bGenerate {
            get{
                if(dProjectStartDate > dStartDateToUse || dProjectEndDate < dEndDateToUse){
                    return true;
                }
                return false;
                }
            set;
        }
        
        public ProjectDateCompare(pse__Proj__c oProject){
            sProjectId = oProject.Id;
            theProject = oProject;
            
            dProjectStartDate = oProject.pse__Start_Date__c;
            dProjectEndDate = oProject.pse__End_Date__c;
            dProjectForecastStartDate = oProject.RevisedStartDate__c;
            dProjectForecastEndDate = oProject.RevisedEndDate__c;
            
            dStartDateToUse = dProjectStartDate;
            dEndDateToUse = dProjectEndDate;
            dForecastStartDateToUse = dProjectForecastStartDate;
            dForecastEndDateToUse = dProjectForecastEndDate;
            
            if (dStartDateToUse == null || dProjectStartDate < dStartDateToUse) dStartDateToUse = dProjectStartDate;
            if (dEndDateToUse == null ||  dProjectEndDate > dEndDateToUse) dEndDateToUse = dProjectEndDate;
            if (dForecastStartDateToUse == null || dProjectForecastStartDate < dForecastStartDateToUse ) dForecastStartDateToUse = dProjectForecastStartDate;
            if (dForecastEndDateToUse == null   || dProjectForecastEndDate > dForecastEndDateToUse ) dForecastEndDateToUse = dProjectForecastEndDate;
        }
        
        public void compareToUseToDates(Date inputStart , Date inputEnd){
            if(inputStart != null && dStartDateToUse == null || inputStart < dStartDateToUse) dStartDateToUse = inputStart;
            if(inputEnd != null && dEndDateToUse == null || inputEnd > dEndDateToUse) dEndDateToUse = inputEnd;
        }
        
        public void compareToTask(pse__Project_Task__c oProjectTask){
            if(dStartDateToUse > oProjectTask.pse__Start_Date__c) dStartDateToUse = oProjectTask.pse__Start_Date__c;
            if(dEndDateToUse < oProjectTask.pse__End_Date__c) dEndDateToUse = oProjectTask.pse__End_Date__c;
            if(dForecastStartDateToUse > oProjectTask.ForecastStartDate__c) dForecastStartDateToUse = oProjectTask.ForecastStartDate__c;
            if(dForecastEndDateToUse < oProjectTask.ForecastEndDate__c) dForecastEndDateToUse = oProjectTask.ForecastEndDate__c;
        }
    }
}