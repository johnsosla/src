public class ECO_RiskMarketAssessmentTriggerHandler {

	public static void handleRiskMarketAssessmentAfterUpdate(map<Id, QuestionnaireSet__c> oldQuestionnaireSetMap, map<Id, QuestionnaireSet__c> newQuestionnaireSetMap)
	{

		list<Id> projectIdsToUpdate = new list<Id>();
		map<Id, String> projectRMAssessmentStatus = new map<Id, String>();
		map<Id, QuestionnaireSet__c> projectRMAMap = new Map<Id, QuestionnaireSet__c>();

		//To check for Submitted Status.
		map<Id, String> projectRMAssessmentSubmitStatus = new map<Id, String>();
		
		for(QuestionnaireSet__c newQuestionaireSet: newQuestionnaireSetMap.values())
		{	
			projectRMAMap.put(newQuestionaireSet.Project__c, newQuestionaireSet);
			if(newQuestionaireSet.ApprovalStatus__c == 'Approved' && oldQuestionnaireSetMap.get(newQuestionaireSet.Id).ApprovalStatus__c != 'Approved')
			{
				projectIdsToUpdate.add(newQuestionaireSet.Project__c);	
				projectRMAssessmentStatus.put(newQuestionaireSet.Project__c,'Approved');	
			}			
			if(newQuestionaireSet.ApprovalStatus__c == 'Pending Approval' && oldQuestionnaireSetMap.get(newQuestionaireSet.Id).ApprovalStatus__c != 'Pending Approval')
			{
				projectIdsToUpdate.add(newQuestionaireSet.Project__c);	
				projectRMAssessmentStatus.put(newQuestionaireSet.Project__c,'Pending');	
			}			
			if(newQuestionaireSet.ApprovalStatus__c == 'Rejected' && oldQuestionnaireSetMap.get(newQuestionaireSet.Id).ApprovalStatus__c != 'Rejected')
			{
				projectIdsToUpdate.add(newQuestionaireSet.Project__c);	
				projectRMAssessmentStatus.put(newQuestionaireSet.Project__c,'Rejected');	
			}

			//To account for the submission of the Risk and Market Asessment
			System.debug('3150 : newQuestionaireSet.ApprovalStatus__c : ' + newQuestionaireSet.ApprovalStatus__c);
			
			if(newQuestionaireSet.ApprovalStatus__c != 'Pending Approval')
			{
				//System.debug('3150 : Submission of Risk and Management Assessment');

				projectRMAssessmentSubmitStatus.put(newQuestionaireSet.Project__c,'Submitted');	

				list<pse__proj__c> projectsToUpdateRMASubmit = [select Id, Name, pse__Opportunity__c, pse__Opportunity__r.Opportunity_ID__c, pse__Project_Status__c, RecordTypeId, ProgBarGoNoGoApproval__c, ProjectReviewCategory__c from pse__Proj__c where Id in :projectRMAssessmentSubmitStatus.keyset()];

				for(pse__proj__c project:projectsToUpdateRMASubmit)
				{
					//system.debug('3150 : project.Id - ' + project.Id);
					//system.debug('3150 : project.Name - ' + project.Name);

					list<Go_No_Go_Conversation__c> lstgonogo = [Select Id, Name, Opportunity__c, Opportunity_Name__c From Go_No_Go_Conversation__c Where Opportunity__c=:project.pse__Opportunity__c];

					for (Go_No_Go_Conversation__c gn:lstgonogo)
					{
						//system.debug('3150 : gn.Opportunity__c:  ' + gn.Opportunity__c);
						//system.debug('3150 : gn.Opportunity_Name__c:  ' + gn.Opportunity_Name__c);

						//If Opportunity is returned with a valid value, update the RMAssessment checkbox
						if (gn.Opportunity__c != null)
						{
							list<Go_No_Go_Conversation__c> gngToUpdateRM = new list<Go_No_Go_Conversation__c>();
							list<Go_No_Go_Conversation__c> gngs = [Select epmrmassessment__c from Go_No_Go_Conversation__c WHere Id =:gn.Id];

							for (Go_No_Go_Conversation__c gng: gngs)
							{
								//system.debug('3150 : epmrmassessment__c:  ' + gng.epmrmassessment__c);

								if (!gng.epmrmassessment__c)
								{
									gng.epmrmassessment__c = true;
									gngToUpdateRM.add(gng);
								}
							}

							if(gngToUpdateRM.size() > 0)
							{
								try
								{
									update gngToUpdateRM;
								}
								catch(DMLException e)
								{
									system.debug( 'ECO_RiskMarketAssessmentTriggerHandler-gngToUpdateRM-Update-DMLException: ' + e.getMessage());
								}
							}							
						}
					}
				}
			}

		}	
		System.debug('US-04496 : projectRMAssessmentStatus.keyset().size()' + projectRMAssessmentStatus.keyset().size());	
		if(projectRMAssessmentStatus.keyset().size() > 0)
		{
			Id recordTypeId = [select Id, DeveloperName from RecordType where DeveloperName = 'CustomerProjectNotSynced' limit 1].Id;
			list<pse__Proj__c> projectsToUpdate = new list<pse__Proj__c>();	

			//2492 Added the fields pse__Opportunity__c, pse__Opportunity__r.name to this query for use in update of Opp StageName later
			//list<pse__proj__c> projects = [select Id, Name, pse__Project_Status__c, RecordTypeId, ProgBarGoNoGoApproval__c, ProjectReviewCategory__c, pse__Stage__c, CaptureManagerUser__c, CaptureManager__r.pse__Salesforce_User__c from pse__Proj__c where Id in :projectRMAssessmentStatus.keyset()];
			list<pse__proj__c> projects = [select Id, Name, pse__Opportunity__c, pse__Opportunity__r.name, pse__Project_Status__c, RecordTypeId, ProgBarGoNoGoApproval__c, ProjectReviewCategory__c, pse__Stage__c, CaptureManagerUser__c, CaptureManager__r.pse__Salesforce_User__c, ProjectOwnerContact__c from pse__Proj__c where Id in :projectRMAssessmentStatus.keyset()];
			
			list<Task> tasks = new list<Task>();
			for(pse__proj__c project:projects)
			{
				//System.debug('project.capture manager:::'+project.CaptureManagerUser__c);
    			//System.debug('project.owner:::'+project.ProjectOwnerContact__c);
    			System.debug('US-04496 : projectRMAssessmentStatus::::' + projectRMAssessmentStatus.get(project.Id));
    			System.debug('US-04496 : GoNoGoRecommendation__c::::' + projectRMAMap.get(project.Id).GoNoGoRecommendation__c);
    			System.debug('US-04496 : project.pse__Stage__c::::' + project.pse__Stage__c);
				if(projectRMAssessmentStatus.get(project.Id) == 'Approved' && projectRMAMap.get(project.Id).GoNoGoRecommendation__c == 'Go'){
                    if(project.pse__Stage__c == 'Pending Go/No Go' || project.pse__Stage__c == 'No-Go'){
                        project.pse__Stage__c = 'Planning';
						project.RecordTypeId = recordTypeId;
                        if(!String.isBlank(project.CaptureManager__r.pse__Salesforce_User__c)){
                            System.debug('Setting Project Owner = Capture Manager::: Project Owner before change:::'+project.OwnerId +'   capture manager::'+project.CaptureManager__r.pse__Salesforce_User__c);
                            project.OwnerId = project.CaptureManager__r.pse__Salesforce_User__c;
                            System.debug('After setting project owner:::'+project.OwnerId);
                        }
                    }

		            if (project.pse__Stage__c == 'Planning')
		            {
		            	//2492 - Update the Opp Stage Name to 2 as long as its not set to 2A or 2B
		            	opportunity oOpp = [select id, StageName from opportunity where id=: project.pse__Opportunity__c];

		            	if (oOpp.StageName != '2A Capture - LOI' && oOpp.StageName != '2B Capture - EOI' )
			            {
			            	oOpp.StageName = '2 Capture';
			            	oOpp.Previous_StageName__c = oOpp.StageName;//'2 Capture';
			            	//Reserved for ProjOpptyClosureStatus__c update once the picklist on the project side is updated with complete values.
			            	//Also, check to see if there could be a situation where the ProjOpptyClosureStatus__c could have 2A or 2B
			            	//with Opp Stage Name having different values. If so, put an if condition before update gainst project just like Opp above.
			            	//project.ProjOpptyClosureStatus__c = '2 Capture'; 
				            try
				            {
				                update oOpp;
				            }
							catch( Exception e)
							{
								ECO_Service_ErrorLog.logException(e);
							}
			            }
		        	}

					if(projectRMAMap.get(project.Id).RequestedProjectCategory__c != null && projectRMAMap.get(project.Id).RequestedProjectCategory__c != '' )
						project.clAECOMProjectReviewCategory__c = projectRMAMap.get(project.Id).RequestedProjectCategory__c; 
					else
						project.clAECOMProjectReviewCategory__c = project.ProjectReviewCategory__c; 	
				}
				else if(projectRMAssessmentStatus.get(project.Id) == 'Approved' && projectRMAMap.get(project.Id).GoNoGoRecommendation__c == 'No Go'){
					Id userId;
                    if( !String.isBlank(project.CaptureManagerUser__c)){
                        System.debug('inside 1');
                        userId = project.CaptureManagerUser__c;
                    }
                    else if(!String.isBlank(project.CaptureManager__r.pse__Salesforce_User__c)){
                        userId = project.CaptureManager__r.pse__Salesforce_User__c;
                        System.debug('inside 2');
                    }
                    else{
                        userId = UserInfo.getUserId();
                        System.debug('inside 3');
                    }
                    System.debug('userId:::'+userId);
                    Task newTask = new Task(Description = 'Project Closure Required',
                                    		Priority = 'Normal', 
                                    		Subject = 'Project Closure Required', 
                                    		IsReminderSet = true, 
                                    		ReminderDateTime = System.now()+7, 
                                    		WhatId = project.Id,
                                            OwnerId = userId);     
                    

             		tasks.add(newTask);	
                    
				}
					
				project.ProgBarGoNoGoApproval__c = projectRMAssessmentStatus.get(project.Id);

				projectsToUpdate.add(project);
			}
			
			if(tasks.size() > 0)
				insert tasks;
			
			if(projectsToUpdate.size() > 0)
			{
				System.debug('***SA***-projectsToUpdate');
				update projectsToUpdate;			
			}
		}

	}
}