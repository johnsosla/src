public with sharing class ECO_ProjTaskAssignment_TriggerDispatcher
{
	//keeps track of what logic has already executed so you can prevent it from executing again
	public static Set<String> executedMethods = new Set<String>();
	
	public static void Main(List<pse__Project_Task_Assignment__c> newList, Map<Id, pse__Project_Task_Assignment__c> newMap, List<pse__Project_Task_Assignment__c> oldList, Map<Id, pse__Project_Task_Assignment__c> oldMap, Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isExecuting)
	{
		//can still have dynamic fine-grain control over what logic executes
		Boolean CreateTeamMemberFromTaskAssignment_Enabled = ECO_TriggerSettings.getIsTriggerEnabled('CreateTeamMemberFromTaskAssignment');
		
		//event-based criteria
		if(isAfter)
		{
			if(isInsert || isUpdate)
			{
				if(CreateTeamMemberFromTaskAssignment_Enabled && !executedMethods.contains('CreateTeamMemberFromTaskAssignment'))
				{
					//if you wanted to create a sub-set of the object list based on some criteria you could do that here
					ECO_ProjTaskAssignment_Main.createTeamMembersFromTaskAssignments(newList);
				}
			}
		}
	}
}