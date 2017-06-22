global class ECO_ProjectCountryAlertBatch extends ECO_BatchAdminService  {
	
	String query = 'SELECT ID, Project__r.EcoSystemReferenceNumber__c, Project__r.name, Project__r.ownerid, Project__r.Project_Manager_User__c, Last_Country_Risk__c, Safety_Rating__c, CountryRisk__r.name FROM ProjectCountry_Risk__c WHERE Change_in_Risk__c > 0.5';
	
    //global Integer batchSize;
    public static final Integer DEFAULT_BATCH_SIZE = 200;
    
    global ECO_ProjectCountryAlertBatch() {
		
	}
    
    global ECO_ProjectCountryAlertBatch(Integer batchSize) {
        if (batchSize != null && batchSize > 0) {
            this.batchSize = batchSize;
        }
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC) {
    this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectCountryAlertBatch', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);
        System.Debug(LoggingLevel.Info, 'Query ' + query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
   		list<PortalMessage__c>  alertsToInsert = new list<PortalMessage__c>();
   		list<ProjectCountry_Risk__c> projectRiskToInsert = new list<ProjectCountry_Risk__c>();
   		ECO_ProjectCountryRiskBatchHelper helper = new ECO_ProjectCountryRiskBatchHelper();

		for(sobject s : scope){
			ProjectCountry_Risk__c item = (ProjectCountry_Risk__c)s;

			alertsToInsert.add(helper.createNewAlert(item.Project__r, date.today(), 'COUNTRY: ' + item.CountryRisk__r.name + ' RISK HAS CHANGED FROM ' + string.valueof(item.Last_Country_Risk__c) + ' to ' + string.valueof(item.Safety_Rating__c))); 

			item.Last_Country_Risk__c = item.Safety_Rating__c;

			projectRiskToInsert.add(item);
		}
    try{
  		insert alertsToInsert;
  		upsert projectRiskToInsert;
    }catch(Exception e){
              ECO_Service_ErrorLog.logException(e);
    }

	}
	
    /**
     * log the finish of this job and call the next batch in the stream if this job is a stream member
     *
     * @Author  NTT Data - Deborah Orth
     * @Date    November 2016
     *
     * @param   BC - Batchable Context
     * @return  
     **/
    global void finish(Database.BatchableContext BC) {
        runNextBatchInStream( BC.getJobId(), 'ECO_ProjectCountryAlertBatch'); 
    }    

    global void execute(SchedulableContext sc)
    {
          if (batchSize == null)
              batchSize = DEFAULT_BATCH_SIZE;
          System.debug('___Batch size='+batchSize);
          ECO_ProjectCountryAlertBatch b = new ECO_ProjectCountryAlertBatch();
          b.batchSize = this.batchSize;
          b.batchStream = this.batchStream;
          b.regionOuIds = this.regionOuIds;
          b.jobName = this.jobName;
          database.executebatch(b, batchSize);
          
    }
}