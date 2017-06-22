global without sharing class BatchDeleteProjectSharing extends ECO_BatchAdminService {

    private System.LoggingLevel debugLevel = LoggingLevel.INFO;
    private Date billingDate;
    public static final Integer DEFAULT_BATCH_SIZE = 200;
    
    Map<Id, Account> mapServiceAccountsMissingAccountIdentifierType; 
    
    global String query;

    global BatchDeleteProjectSharing (){
		this.query = 'SELECT Active__c, StartDate__c, EndDate__c, Contact__c, Id, Project__c, contact__r.name, contact__r.pse__Salesforce_User__c FROM ProjectTeamMember__c where Processed_by_DeleteShareBatch__c = false and Active__c = false and EndDate__c <= TODAY order by EndDate__c desc' ;    	
        system.debug( 'BatchDeleteProjectSharing Constructor' );
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug(debugLevel, 'Beginning BatchPreBillingValidation Execution.');
        this.logId = ECO_Service_BatchLog.logJobStart('BatchDeleteProjectSharing', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);
       
        return Database.getQueryLocator(query);
    }
    
    global void execute( Database.BatchableContext BC, List<SObject> projectTeamMemberItemsToProcess ) {
            
        Set<Id> projectIds = new Set<Id> (); 
        Set<String> listOfKeysToDelete = new Set<String> ();
        list<ProjectTeamMember__c> toUpdate = new list<ProjectTeamMember__c>();
        
        system.debug( 'projectTeamMemberItemsToProcess size ' + projectTeamMemberItemsToProcess.size() );
        
        string keyToDel;
        for(ProjectTeamMember__c thisProjectTeamMember : (List<ProjectTeamMember__c>) projectTeamMemberItemsToProcess){
        	 projectIds.add( thisProjectTeamMember.Project__c );
             keyToDel = String.Valueof(thisProjectTeamMember.contact__r.pse__Salesforce_User__c) + String.ValueOf(thisProjectTeamMember.Project__c);
             listOfKeysToDelete.add( keyToDel );
             thisProjectTeamMember.Processed_by_DeleteShareBatch__c = true;
             toUpdate.add(thisProjectTeamMember);
        }     
        
        system.debug( 'listOfKeysToDelete ' + listOfKeysToDelete + ' projectIds ' + projectIds );
        
      	List<pse__Proj__Share> listProjShare = [SELECT id, ParentId, UserOrGroupId, RowCause, AccessLevel from pse__Proj__Share where RowCause = 'KeyMember__c'  and ParentId in : projectIds ];
        
		Map <String,  pse__Proj__Share> mapSearchIdProjectShare = new Map <String,  pse__Proj__Share>();
        
        for(pse__Proj__Share thisProjectShare : (List<pse__Proj__Share>) listProjShare){
            string key = String.Valueof(thisProjectShare.UserOrGroupId) + String.ValueOf(thisProjectShare.ParentId);
            system.debug( 'mapSearchIdProjectShare ' + key );
        	mapSearchIdProjectShare.put( key, thisProjectShare );         
        }  

		List<pse__Proj__Share> projectSharesToDelete = new List<pse__Proj__Share>();
        
		for(string idToDelete: listOfKeysToDelete){
    		if( mapSearchIdProjectShare.get(idToDelete) != null )	
            {
				projectSharesToDelete.add(mapSearchIdProjectShare.get(idToDelete));                              
            }                
   		}  
        
        system.debug( 'projectSharesToDelete ' + projectSharesToDelete + ' projectSharesToDelete size ' + projectSharesToDelete.size() );
        

        Database.DeleteResult[] DR_Dels = Database.delete(projectSharesToDelete, false);
        list<Database.SaveResult> SR = Database.update(toUpdate, false);
        //update toUpdate;
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
        runNextBatchInStream( BC.getJobId(), 'BatchDeleteProjectSharing'); 
    }    

    /**
     * Executes the batch by ensuring that the batch size is set or using the best default, also passes all the class properties forward to the executeBatch
     *
     * @Author  NTT Data - ?
     * @Date    2015
     *
     * @param   context
     * @return  
     **/
    global void execute(SchedulableContext context) {

      if(this.batchSize == null){
        this.batchSize = DEFAULT_BATCH_SIZE;
      }

        BatchDeleteProjectSharing batch = new BatchDeleteProjectSharing();
        batch.batchSize = this.batchSize;
        batch.batchStream = this.batchStream;
        batch.regionOuIds = this.regionOuIds;
        batch.jobName = this.jobName;
        Database.executeBatch(batch, this.batchSize);
    }

}