public with sharing class ECO_ProjTaskAssignment_Main
{
	public static void createTeamMembersFromTaskAssignments(List<pse__Project_Task_Assignment__c> lProjectTaskAssignments)
	{
		Set<Id> setProjectIds = new Set<Id>();
		Map<Id, List<pse__Project_Task_Assignment__c>> mapProj_PTA = new Map<Id, List<pse__Project_Task_Assignment__c>>();
		for(pse__Project_Task_Assignment__c pta : lProjectTaskAssignments)
		{
			List<pse__Project_Task_Assignment__c> lPTA;
			if(mapProj_PTA.containsKey(pta.pse__Project_ID__c))
				lPTA = mapProj_PTA.get(pta.pse__Project_ID__c);
			else
				lPTA = new List<pse__Project_Task_Assignment__c>();
			lPTA.add(pta);
			mapProj_PTA.put(pta.pse__Project_ID__c, lPTA);
		}
		List<ProjectRole__c> lRoles = new List<ProjectRole__c>([Select Id, Name From ProjectRole__c Where Active__c = true]);
		Map<String, Id> mapRoleNames = new Map<String, Id>();
		for(ProjectRole__c pr : lRoles)
		{
			mapRoleNames.put(pr.Name, pr.Id);
		}
		List<ProjectTeamMember__c> lProjTeamMember = new List<ProjectTeamMember__c>([Select Id, Contact__c, 
																					ProjectRole__c, ProjectRole__r.Name, 
																					ProjectRoleTitle__c, Project__c 
																					From ProjectTeamMember__c 
																					Where Project__c In :mapProj_PTA.keySet()]);
																					
		Map<Id, List<ProjectTeamMember__c>> mapProj_TeamMember = new Map<Id, List<ProjectTeamMember__c>>();
		if(!lProjTeamMember.isEmpty())
		{
			for(ProjectTeamMember__c ptm : lProjTeamMember)
			{
				List<ProjectTeamMember__c> lTeamMembers;
				if(mapProj_TeamMember.containsKey(ptm.Project__c))
					lTeamMembers = mapProj_TeamMember.get(ptm.Project__c);
				else
					lTeamMembers = new List<ProjectTeamMember__c>();
				lTeamMembers.add(ptm);
				mapProj_TeamMember.put(ptm.Project__c, lTeamMembers);
			}
		}
		//determine if the team members already exist, if not create them.
		List<ProjectTeamMember__c> lNewPTMs = new List<ProjectTeamMember__c>();
		
		for(Id projID : mapProj_PTA.keySet())
		{
			List<ProjectTeamMember__c> lTeamMembers = new List<ProjectTeamMember__c>();
			if(mapProj_TeamMember.containsKey(projID))
				lTeamMembers = mapProj_TeamMember.get(projID);
			List<pse__Project_Task_Assignment__c> lPTA = new List<pse__Project_Task_Assignment__c>();
			if(mapProj_PTA.containsKey(projID))
				lPTA = mapProj_PTA.get(projID);
			if(!lTeamMembers.isEmpty())
			{	
				for(pse__Project_Task_Assignment__c assignment : lPTA)
				{
					Boolean matchFound = false;
					for(ProjectTeamMember__c ptm : lTeamMembers)
					{
						if(assignment.pse__Resource__c == ptm.Contact__c && assignment.pse__Resource_Role__c == ptm.ProjectRole__r.Name) //also compare project role titles?
						{
							matchFound = true;
							break;
						}
					}
					if(!matchFound)
					{
						ProjectTeamMember__c newPTM = new ProjectTeamMember__c();
						newPTM.Project__c = assignment.pse__Project_ID__c;
						newPTM.ProjectRole__c = mapRoleNames.get(assignment.pse__Resource_Role__c);
						newPTM.Contact__c = assignment.pse__Resource__c;
						newPTM.ProjectRoleTitle__c = assignment.pse__Resource_Role__c;
						lNewPTMs.add(newPTM);
					}
				}
			}
			else
			{
				//no team members exist yet on the project
				for(pse__Project_Task_Assignment__c assignment : lPTA)
				{
					ProjectTeamMember__c newPTM = new ProjectTeamMember__c();
					newPTM.Project__c = assignment.pse__Project_ID__c;
					newPTM.ProjectRole__c = mapRoleNames.get(assignment.pse__Resource_Role__c);
					newPTM.Contact__c = assignment.pse__Resource__c;
					newPTM.ProjectRoleTitle__c = assignment.pse__Resource_Role__c;
					lNewPTMs.add(newPTM);
				}
			}
		}
		if(!lNewPTMs.isEmpty()) {
			insert lNewPTMs;
		}
			
		
		//tell the dispatcher that this method has completed execution
		ECO_ProjTaskAssignment_TriggerDispatcher.executedMethods.add('CreateTeamMemberFromTaskAssignment');
	}
}