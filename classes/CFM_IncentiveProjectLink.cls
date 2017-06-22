public class CFM_IncentiveProjectLink {
	public static Boolean triggerWasRun = false;

	public static void linkFromIncentiveProject(Map<Id, IncentiveProject__c> newMap) {
		if (!triggerWasRun) {
			triggerWasRun = true;

			List<String> projectNumbers = new List<String>();

			for (IncentiveProject__c proj : newMap.values()) {
				projectNumbers.add(proj.ProjectID__c);
			}

			// Find any related project profiles that have not already been linked
			List<Project__c> relatedProjects = [Select Id, Oracle_Project_Number__c from Project__c where Oracle_Project_Number__c in :projectNumbers and CFM_Incentive_Project__c = null];

			if (relatedProjects.size() > 0) {
				Map<String, IncentiveProject__c> projectNumberToIncentiveProject = new Map<String, IncentiveProject__c>();
				for (IncentiveProject__c proj : newMap.values()) {
					projectNumberToIncentiveProject.put(proj.ProjectID__c, proj);
				}


				for (Project__c relatedProject : relatedProjects) {
					if (projectNumberToIncentiveProject.containsKey(relatedProject.Oracle_Project_Number__c)) {
						IncentiveProject__c iProj = projectNumberToIncentiveProject.get(relatedProject.Oracle_Project_Number__c);
						relatedProject.CFM_Incentive_Project__c = iProj.Id;
					}
				}

				update relatedProjects;
			}

		}
	}

public static void linkFromProjectProfile(Map<Id, Project__c> newMap) {
		if (!triggerWasRun) {
			triggerWasRun = true;

			List<String> projectNumbers = new List<String>();
			List<Project__c> projectsToLink = new List<Project__c>();

			for (Project__c newProj : newMap.values()) {
				if (String.isBlank(newProj.CFM_Incentive_Project__c)) {
					projectsToLink.add(newProj);
					projectNumbers.add(newProj.Oracle_Project_Number__c);
				}
			}

			List<IncentiveProject__c> incentiveProjects = [Select Id, ProjectID__c from IncentiveProject__c where ProjectID__c in :projectNumbers];

			Map<String, IncentiveProject__c> projectNumberToIncentiveProject = new Map<String, IncentiveProject__c>();
			for (IncentiveProject__c row : incentiveProjects) projectNumberToIncentiveProject.put(row.ProjectID__c, row);


			for (Project__c newProj : projectsToLink) {
				if (projectNumberToIncentiveProject.containsKey(newProj.Oracle_Project_Number__c)) {
					newProj.CFM_Incentive_Project__c = projectNumberToIncentiveProject.get(newProj.Oracle_Project_Number__c).Id;
				}
			}

			// No need to update project profiles, this is a before update trigger
		}
	}
}