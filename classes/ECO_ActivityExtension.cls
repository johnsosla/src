/*
	Purpose: - Redirect page to the proper record type

	Created By: Aaron Pettitt

	Revision Log:  
	 	v1.0 - (AP 12/04/2015) -- created
	 	v1.1 - (Tom Smalara 1/13/2016 - Added code to default Related To field to Project)
*/
public with sharing class ECO_ActivityExtension {

	//constructor
	public ECO_ActivityExtension() {

	}

	//retrieves the sobject and record type by name and redirects to the proper page
	public PageReference Redirect(){
		try{
			String recordType = ApexPages.currentPage().getParameters().get('sObject');
			String projectId = ApexPages.currentPage().getParameters().get('ProjectId');
	
			String objectId = '';
			if(recordType == 'Task')
				objectId = createNewTask(projectId);		
			else 
				objectId = createNewEvent(projectId);				        	
		        	
			Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe();
			SObjectType sObj = sObjectMap.get(ApexPages.currentPage().getParameters().get('sObject'));
			PageReference pageRef = new PageReference('/' + objectId + '/e');
			Map<String, String> pageParameterMap = pageRef.getParameters();
			pageParameterMap.putAll(ApexPages.currentPage().getParameters());
			pageParameterMap.put('nooverride', '1');
			pageParameterMap.put('RecordType', ECO_Utils_Meta.getRecordTypeId(sObj, ApexPages.currentPage().getParameters().get('recordType')));
			pageParameterMap.put('ProjectID', projectId);
			return pageRef;
		}
		catch(Exception ex){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error redirecting page: ' + ex.getMessage()));
		}
		return null;
	}

	public Id createNewTask(String projectId)
    {
        Id taskRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Task.sObjectType, 'ECOTasks');
       
        Task t = new Task();
        t.WhatId = projectId;
        t.RecordTypeId = taskRecordTypeId;
        insert t;

        return t.Id;
    }

    public Id createNewEvent(String projectId)
    {
        Id eventRecordTypeId = ECO_Utils_Meta.getRecordTypeId(EVent.sObjectType, 'EcoProjectEvent');
       
        Event e = new Event();
        e.WhatId = projectId;
        e.RecordTypeId = eventRecordTypeId;
        e.DurationInMinutes = 60;
        e.ActivityDateTime = DateTime.now().addDays(1);
        insert e;    

        return e.Id;
    }
   
}