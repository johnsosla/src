/** ------------------------------------------------------------------------------------------------------
 * @Description the test class for the ECO_QuestionnaireSet_Main.cls
 *
 * @Author      NTT Data - Arman Shah
 * @Date        January 2017
 *-----------------------------------------------------------------------------------------------------*/
@isTest
private class ECO_QuestionnaireSet_Main_Test {
	static List<pse__Time_Period__c> timePeriods {get; set;}
    static List<pse__Proj__c> projects {get; set;}
    static List<Id> projectIds {get; set;}
    static pse__Proj__c proj1 {get; set;}

    @testSetup static void setupTestData() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        projects = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
        projects = [SELECT Id FROM pse__Proj__c];

        projectIds = new List<Id>();
        List<QuestionnaireSet__c> qsList = new List<QuestionnaireSet__c>();
        List<ProjectReview__c> projectReviewsList = new List<ProjectReview__c>();
        for (pse__Proj__c proj : projects) {
            projectIds.add(proj.Id);
            proj.OuIdText__c = '147';
            proj.pse__Start_Date__c = Date.today()-35;
            proj.pse__End_Date__c = Date.today()+35;

            QuestionnaireSet__c qs = new QuestionnaireSet__c();
        	qs.Project__c = proj.Id;
        	qs.RequestedProjectCategory__c = 'C-1';
        	qsList.add(qs);

        	//Select Id, Project__c, ProjectReviewCategory__c From ProjectReview__c
        	ProjectReview__c pr = new ProjectReview__c();
        	pr.Project__c = proj.Id;
        	projectReviewsList.add(pr);
        }
        update projects;
        insert qsList;
        insert projectReviewsList;
    }

	@isTest static void testUpdateProjectReviewCategory() {
		List<QuestionnaireSet__c> qsList = 
			[SELECT Id, Project__c, RequestedProjectCategory__c FROM QuestionnaireSet__c];
		ECO_QuestionnaireSet_Main.UpdateProjectReviewCategory(qsList);
	}
	
	@isTest static void testUpdateProjectCategory() {
		ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
		List<QuestionnaireSet__c> qsList = 
			[SELECT Id, Project__c, RequestedProjectCategory__c FROM QuestionnaireSet__c];
		ECO_QuestionnaireSet_Main.UpdateProjectCategory(qsList);
	}
}