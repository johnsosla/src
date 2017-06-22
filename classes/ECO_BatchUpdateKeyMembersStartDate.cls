/****************************************************************
Created: Nov 30 2015
Author: Aaron Pettitt(NTT Data)
Purpose : Looks at the Project's Actual Start Date and adjust the key member's start date if they are less
Modifications:
******************************************************************/
global class ECO_BatchUpdateKeyMembersStartDate implements Database.Batchable<sObject>, Schedulable {
	
	String query;
	
	//constructor
	global ECO_BatchUpdateKeyMembersStartDate() {
		
	}

	// ----------------------------------------------------------------------------------------
    // SCHEDULABLE
    // ----------------------------------------------------------------------------------------
	

	global void execute(SchedulableContext context) {
      ECO_BatchUpdateKeyMembersStartDate batch = new ECO_BatchUpdateKeyMembersStartDate();
      Database.executeBatch(batch);
    }

    // ----------------------------------------------------------------------------------------
    // BATCHABLE
    // ----------------------------------------------------------------------------------------
	
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		List<String> validStages = new List<String>{'Planning', 'Excecution', 'Pending Go/No Go'};
		query = 'Select Id, pse__Start_Date__c, ';
		query += '(Select Id, StartDate__c from ProjectTeamMembers__r where ProjectRole__r.Type__c = \'Key Member\') ';
		query += 'From pse__Proj__c ';
		query += 'Where pse__Stage__c IN : validStages';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<pse__Proj__c> projects) {
   		List<ProjectTeamMember__c> projectTeamMembers = new List<ProjectTeamMember__c>();

   		for(pse__Proj__c project : projects){
   			for(ProjectTeamMember__c projectTeamMember : project.ProjectTeamMembers__r){
   				if(projectTeamMember.StartDate__c < project.pse__Start_Date__c){
   					projectTeamMember.StartDate__c = project.pse__Start_Date__c;
   					projectTeamMembers.add(projectTeamMember);
   				}
   			}
   		}

		if(projectTeamMembers.size() > 0){
			update projectTeamMembers;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}