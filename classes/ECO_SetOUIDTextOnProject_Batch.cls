global class ECO_SetOUIDTextOnProject_Batch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT ID, OUID__c, OUIDText__c  FROM pse__Proj__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
          for(pse__Proj__c p : (pse__Proj__c[])scope){
             p.OUIDText__c = p.OUID__c;
          }

          Database.SaveResult[] srList = database.update(scope, false);

          // Iterate through each returned result
          for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
              // Operation failed, so get all errors                
              for(Database.Error err : sr.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Fields that affected this error: ' + err.getFields());
              }
            }
          }
    }

    global void finish(Database.BatchableContext BC) {
    }
}
// Usage in execute anonymous:
// ECO_SetOUIDTextOnProject_Batch b = new ECO_SetOUIDTextOnProject_Batch();
// database.executeBatch(b);