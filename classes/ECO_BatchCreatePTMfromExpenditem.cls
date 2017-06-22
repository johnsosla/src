/** ------------------------------------------------------------------------------------------------------
* @Description Batch job to create Project Team Members when Expenditure Items with Person Id are loaded into ePM
*
* @Author      NTT Data - Priya Parepalli
* @Date        07/29/2016
*-----------------------------------------------------------------------------------------------------*/
global class ECO_BatchCreatePTMfromExpenditem extends ECO_BatchAdminService {
	//global Integer batchSize;
    public static final Integer DEFAULT_BATCH_SIZE = 200;
    String query;
    
    /**
     * Constructor for Batch Job
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    08/04/2016
     *
     * @param 
     * @return  
     **/
    global ECO_BatchCreatePTMfromExpenditem() {
    }
    
    /**
     * Constructor with batch size parameter
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    date
     *
     * @param 	batchSize - batch size for the job
     * @return  
     **/
    global ECO_BatchCreatePTMfromExpenditem(Integer batchSize) {    
        if (batchSize != null && batchSize > 0) {
            this.batchSize = DEFAULT_BATCH_SIZE;
        }
    }
    
    /**
     * Method contains the Query on which batch job is run
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    08/04/2016
     *
     * @param   context - Batchable Context to start the job
     * @return  Database.QueryLocator - returns the query on which batch job runs
     **/
    global Database.QueryLocator start(Database.BatchableContext context) {
		this.logId = ECO_Service_BatchLog.logJobStart('ECO_BatchCreatePTMfromExpenditem', this.batchStream, this.regionOuIds, context.getJobId(), this.jobName);
        query = 'Select Id, PTMBatchHasRan__c, Project__c, PersonId__c FROM ExpendItem__c Where PersonId__c != NULL AND Project__c != NULL AND PTMBatchHasRan__c = False';
        return Database.getQueryLocator(query);
  	}

  	/**
  	 * Method contains the logic to Insert Project Team Members and Update Expenditure Items
  	 *
  	 * @Author  NTT Data - Priya Parepalli
  	 * @Date    08/04/2016
  	 *
  	 * @param 	BC - batchable context
  	 * @param 	expendItems - list of expenditure items
  	 * @return  
  	 **/
	global void execute(Database.BatchableContext BC, List<ExpendItem__c> expendItems) {
        
		List<ProjectTeamMember__c> lPTMs = new List<ProjectTeamMember__c>();
		List<ProjectTeamMember__c> listPTM_To_Insert = new List<ProjectTeamMember__c>();
		List<ExpendItem__c> listExpendItems_To_Update = new List<ExpendItem__c> ();
		Set<String> personIds = new Set<String>();
		Set<String> projectIds = new Set<String>();
		Set<String> sPersonProject = new Set<String>();
		Set<String> sProjectContact = new Set<String>();
		Map<String,Contact> mPersonContactIds = new Map<String,Contact>();
		
        for(ExpendItem__c eItem : expendItems){
            
			projectIds.add(eItem.Project__c);
			personIds.add(eItem.PersonId__c);
			sPersonProject.add(eItem.PersonId__c+'-'+eItem.Project__c);
			
			//Updating the PTMBatchHasRan__c to true for Expenditure Items on which batch job has run
			eItem.PTMBatchHasRan__c = true;
			listExpendItems_To_Update.add(eItem);
		}
		RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'PSA_Resource' LIMIT 1];

		List<Contact> lContacts = [SELECT Id, Person_ID__c FROM Contact WHERE RecordTypeId =:rt.Id AND Person_ID__c != NULL AND Person_ID__c IN :personIds];
		for(Contact con : lContacts){
			mPersonContactIds.put(con.Person_ID__c, con);
		}
        
        ProjectRole__c role = [Select Id, Name From ProjectRole__c Where Name = 'Other'];

		//lPTMs = [Select Id, Project__c, Contact__c From ProjectTeamMember__c Where Project__c IN :projectIds AND ProjectRoleName__c = 'Other'];
        lPTMs = [Select Id, Project__c, Contact__c From ProjectTeamMember__c Where Project__c IN :projectIds];
		
        for(ProjectTeamMember__c ptm : lPTMs){
			sProjectContact.add(ptm.Project__c+'-'+ptm.Contact__c);
		}
        
		for(String s : sPersonProject){
			String[] str = s.split('-');
			Contact con = mPersonContactIds.get(str[0]);
			Id ProjectId = Id.valueOf(str[1]);
            String personId = str[0];
			
			if(con != NULL && (sProjectContact == NULL || (sProjectContact != null && !sProjectContact.contains(ProjectId+'-'+con.Id)))){
				listPTM_To_Insert.add(new ProjectTeamMember__c(Project__c = ProjectId,
																Contact__c = con.Id,
                                                               	PersonId__c = personId,
																ProjectRole__c = role.Id,
																RecordTypeID = ECO_Utils_Meta.getRecordTypeId(ProjectTeamMember__c.sObjectType,'Team Member')));
			}

		}
        
        if(listPTM_To_Insert != null && listPTM_To_Insert.size()>0){
			try{
	            insert listPTM_To_Insert;
			}catch(Exception e){
	            ECO_Service_ErrorLog.logException(e);
	            
	        }
				
		}
		if(listExpendItems_To_Update != null && listExpendItems_To_Update.size()>0){
			try{
	            update listExpendItems_To_Update;
	        }catch(Exception e){
	            ECO_Service_ErrorLog.logException(e);
	            
	        }
		}

	}

	/**
	 * Method for running the batch job in Schedulable context with default batch size 
	 *
	 * @Author  NTT Data - Priya Parepalli
	 * @Date    08/04/2016
	 *
	 * @param 	context - Schedulable Context
	 * @return  
	 **/
    global void execute(SchedulableContext context) {
	    if (batchSize == null){
          batchSize = DEFAULT_BATCH_SIZE;
        }
	    ECO_BatchCreatePTMfromExpenditem batch = new ECO_BatchCreatePTMfromExpenditem(batchSize);
		batch.batchSize = this.batchSize;
		batch.batchStream = this.batchStream;
		batch.regionOuIds = this.regionOuIds;
		batch.jobName = this.jobName;
	    Database.executeBatch(batch, batchSize);
    }
    
    /**
     * call the next batch in the stream if this job is a stream member
     *
     * @Author  NTT Data - Deborah Orth
     * @Date    November 2016
     *
     * @param 	BC - Batchable Context
     * @return  
     **/
	global void finish(Database.BatchableContext BC) {
		runNextBatchInStream( BC.getJobId(), 'ECO_BatchCreatePTMfromExpenditem'); 
	}

}