global class EndClientSector_Batch implements Database.Batchable<sObject> {

public Integer batchSize {get; set;}
    //public String query = 'select id, End_Client_Sector_Text__c from Opportunity where Client_Group__c=\'National Government\' and Client_Subgroup__c=\'Defense - Army\'';
    public String query = 'select id, End_Client_Sector_Text__c from Opportunity where Client_Subgroup__c != \'\' and Client_Subgroup__c !=null';
       
    global EndClientSector_Batch() {
        if (batchSize == null) {
            batchSize = 200;
        }
    }

    //global void execute(SchedulableContext context) {
    //    if (batchSize == null) {
    //        batchSize = 200;
    //    }
    //    EndClientSector_Batch batch = new EndClientSector_Batch();
    //    Database.executeBatch(batch, batchSize);
    //}

    // ----------------------------------------------------------------------------------------
    // BATCHABLE
    // ----------------------------------------------------------------------------------------


    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> opportunities) {
        OpportunityTriggerHandler.runAfterUpdate = false;       
        //UPDATE RECORD TO FIRE OFF WORKFLOW RULE
        try{
           Database.update(opportunities, false);
        }
        catch(exception ex){
            System.debug(ex);
        }
 
    }

    global void finish(Database.BatchableContext BC) {

    }

}