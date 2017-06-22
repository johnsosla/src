public class ECO_AgreementActivitiesController {

	public PageReference redirect()
	{
		String activityType = ApexPages.currentPage().getParameters().get('ActivityType');
		String agreementId = ApexPages.currentPage().getParameters().get('AgreementId');
	
		String objectId = '';
		if(activityType == 'Task')
			objectId = createNewTask(agreementId);
		else 
			objectId = createNewEvent(agreementId);


		PageReference pageRef = new PageReference('/' + objectId + '/e');
        pageRef.getParameters().put('retURL', '/' + agreementId);
        return pageRef;	
	}
	

	public Id createNewTask(String agreementId)
    {
        Id taskRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Task.sObjectType, 'ECOTasks');
       
        Task t = new Task();
        t.WhatId = agreementId;
        t.RecordTypeId = taskRecordTypeId;
        insert t;

        return t.Id;
    }

    public Id createNewEvent(String agreementId)
    {
        Id eventRecordTypeId = ECO_Utils_Meta.getRecordTypeId(EVent.sObjectType, 'EcoProjectEvent');
       
        Event e = new Event();
        e.WhatId = agreementId;
        e.RecordTypeId = eventRecordTypeId;
        e.DurationInMinutes = 60;
        e.ActivityDateTime = DateTime.now().addDays(1);
        insert e;    

        return e.Id;
    }
}