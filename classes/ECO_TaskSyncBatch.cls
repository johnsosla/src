global with sharing class ECO_TaskSyncBatch implements Database.Batchable<Sobject>, Database.Stateful, Database.AllowsCallouts{

	global List<sObject> sObjectList;

	global Set<Id> msgQueuesSubmittedForProcessing;

	global String jobName;

	global ECO_TaskSyncBatch (String jobNameIn, Set<Id> msgQueuesSubmittedForProcessingIn){

		jobName = jobNameIn;
		msgQueuesSubmittedForProcessing = msgQueuesSubmittedForProcessingIn;	//use this to keep track of submitted records as they get processed via @Futurn call
	}

	global Iterable<sObject> start(Database.BatchableContext bc){

		sObjectList = [SELECT Id 
						FROM IntegrationMessageQueue__c 
						WHERE JobName__c = :jobName
						AND Status__c = :ECO_Service_ProjectSync.STATUS_INITIATED
						AND Id NOT IN :msgQueuesSubmittedForProcessing
						ORDER BY CreatedDate DESC
						LIMIT 1];

		return sObjectList;

	}


	global void execute(Database.BatchableContext bc, List<sObject> scope){

		

    }
   

   	global void finish(Database.BatchableContext bc){

   		for(sObject messageQueue : sObjectList){
			ECO_Service_ProjectSync.syncTaskOnly(messageQueue.Id);
			msgQueuesSubmittedForProcessing.add(messageQueue.Id);		  
		}

   		sObjectList = [SELECT Id 
						FROM IntegrationMessageQueue__c 
						WHERE JobName__c = :jobName
						AND Status__c = :ECO_Service_ProjectSync.STATUS_INITIATED
						AND Id NOT IN :msgQueuesSubmittedForProcessing];

		if(!sObjectList.isEmpty()){

			ECO_TaskSyncBatch batchSync = new ECO_TaskSyncBatch(jobName, msgQueuesSubmittedForProcessing);
            Id batchprocessid = Database.executeBatch(batchSync);
		}
   	}

}