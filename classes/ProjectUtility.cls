public with sharing class ProjectUtility {

	public static ID TYPE_PROGRAM = getProjectRecordType('Program');
	public static ID TYPE_PROJECT = getProjectRecordType('Project');
	public static ID TYPE_TASK_ORDER = getProjectRecordType('Task_Order');

	/**
	* retrieve a map of project record types keyed by ID
	*/
	public static Map<ID, RecordType> projectRecordTypeMap {
		get {
			if (projectRecordTypeMap == null) {
				projectRecordTypeMap = new Map<ID, RecordType>([SELECT ID, Name, DeveloperName FROM RecordType WHERE SobjectType ='Project__c']);
			}
			return projectRecordTypeMap;
		}
		private set;
	}
	
	/**
	* Retrieve the correct record type ID for a requested DEVELOPER NAME (not label)
	*/
	public static ID getProjectRecordType(String developerName) {
		List<RecordType> rtList = projectRecordTypeMap.values();
		for (RecordType rt : rtList) {
			if (rt.DeveloperName == developerName) {
				return rt.ID;
			}
		}
		return null;
	}
	
	/**
	* Watch for changes to record type and clear fields for certain types of transitions
	* does NOT save the project record. Called by Before Update trigger.
	*/
	public static void clearFields(Project__c project, ID newRT, ID oldRT) {
		//Only go thorough these steps if the record type changes
		if (newRT != oldRT) {			
			//Switching from Program to Project or Task Order...clear these fields
			if (oldRT == TYPE_PROGRAM) {
				project.Client_contract__c = null;
				project.Program_ceiling__c = null;
				project.Program_Adjusted_Ceiling__c = null;
				project.Program_Manager__c = null;
				project.Sum_of_Task_Order_Fees__c = null;
				project.Sum_of_Task_Order_Subcontracted_Cost__c = null;
				
			//Switching from TASK ORDER to anything , clear these fields
			} else if (oldRT == TYPE_TASK_ORDER) {
				project.Program_Master_Contract_Name__c = null;
				project.DO_TO_Number__c = null;
				project.DO_TO_Contract_Number__c = null;			
			}
		}
	}
	
	@isTest(seeAllData=false)
	static void testProjectClearFields() {
		//Start with a program
		Account acct = new Account(Name='Test Account');
	    insert acct;
		Project__c newProgram = new Project__c(RecordTypeId=TYPE_PROGRAM, Name='Test', Project_Name__c='Test');
		newProgram.Client_contract__c = '12345678';
		newProgram.Program_ceiling__c = 999;
		newProgram.Program_Adjusted_Ceiling__c = 998;
		newProgram.Sum_of_Task_Order_Fees__c = 111;
		newProgram.Sum_of_Task_Order_Subcontracted_Cost__c = 222;
        newProgram.Owner__c=acct.Id;
        newProgram.project_description__c='Test';
        
		insert newProgram;
		
		//Change to a Project record type and make sure fields clear correctly
		newProgram.RecordTypeId = TYPE_PROJECT;
		update newProgram;
		
		newProgram = [SELECT ID, RecordTypeId, Client_contract__c, Program_ceiling__c, DO_TO_Contract_Number__c, DO_TO_Number__c FROM Project__c WHERE ID = :newProgram.ID];
		System.debug('NEW PROGRAM 1: ' + newProgram);
		System.assertEquals(null, newProgram.Program_ceiling__c);
		
		//Change to a Task order. More fields cleared
		newProgram.RecordTypeId = TYPE_TASK_ORDER;
		newProgram.DO_TO_Contract_Number__c = '999';
		newProgram.DO_TO_Number__c = '888';
		update newProgram;

		//Change to a Project record type and make sure fields clear correctly
		newProgram.RecordTypeId = TYPE_PROJECT;
		update newProgram;
		
		newProgram = [SELECT ID, RecordTypeId, Client_contract__c, Program_ceiling__c, DO_TO_Contract_Number__c, DO_TO_Number__c FROM Project__c WHERE ID = :newProgram.ID];
		System.debug('NEW PROGRAM 2: ' + newProgram);
		System.assertEquals(null, newProgram.DO_TO_Contract_Number__c);
	}
}