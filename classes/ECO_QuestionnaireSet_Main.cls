public with sharing class ECO_QuestionnaireSet_Main 
{
	public static void UpdateProjectReviewCategory(List<QuestionnaireSet__c> newList)
	{
		Set<Id> projectIDs = new Set<Id>();
		Map<Id,QuestionnaireSet__c> mapQuestionnaires = new Map<Id,QuestionnaireSet__c>();
		for(QuestionnaireSet__c oQS : newList)
		{
			projectIDs.add(oQS.Project__c);
			mapQuestionnaires.put(oQS.Project__c,oQS);
		}
		List<ProjectReview__c> lProjectReviews = new List<ProjectReview__c>([Select Id, Project__c, ProjectReviewCategory__c From ProjectReview__c Where Project__c In :projectIDs]);
		if(!lProjectReviews.isEmpty())
		{
			Map<Id, List<ProjectReview__c>> Proj_ReviewMap = new Map<Id, List<ProjectReview__c>>();
			for(ProjectReview__c oPR : lProjectReviews)
			{
				oPR.ApprovedProjectReviewCategory__c = mapQuestionnaires.get(oPR.Project__c).RequestedProjectCategory__c;
			}
			update lProjectReviews;
		}
		ECO_QuestionnaireSet_TriggerDispatcher.executedMethods.add('UpdateProjectReviewCategory');
	}

	public static void UpdateProjectCategory(List<QuestionnaireSet__c> newList)
	{
		Set<Id> projectIDs = new Set<Id>();
		Map<Id,QuestionnaireSet__c> mapQuestionnaires = new Map<Id,QuestionnaireSet__c>();
		for(QuestionnaireSet__c oQS : newList)
		{
			projectIDs.add(oQS.Project__c);
			mapQuestionnaires.put(oQS.Project__c,oQS);
		}
		List<pse__Proj__c> lProjects = new List<pse__Proj__c>([Select Id From pse__Proj__c Where id In :projectIDs]);
		if(!lProjects.isEmpty())
		{
			for(pse__Proj__c oP : lProjects)
			{
				oP.clAECOMProjectReviewCategory__c = mapQuestionnaires.get(oP.id).RequestedProjectCategory__c;
			}
			update lProjects;
		}
		ECO_QuestionnaireSet_TriggerDispatcher.executedMethods.add('UpdateProjectCategory');		

	}

}