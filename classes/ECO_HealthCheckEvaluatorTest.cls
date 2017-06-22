@isTest(seeAllData=false)
public class ECO_HealthCheckEvaluatorTest {
    static List<pse__Time_Period__c> timePeriods {get; set;}
    static List<ProjectRole__c> projectRoles {get; set;}
    static Map<String, ProjectRole__c> projectRolesMap { get; set; }
    static List<pse__Proj__c> projectsTemp {get; set;}
    static List<pse__Proj__c> projects {get; set;}
    static List<Id> projectIds {get; set;}
    static List<ECO_KPIs__c> KPIs {get; set;}

    @testSetup static void setupTestData() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        projectsTemp = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
        KPIs = Test.loadData(ECO_KPIs__c.sObjectType, 'UT_ECO_KPIs');
        System.debug('___TEST: CustomSettings KPIs='+KPIs);
    }
    
    static testMethod void testEvaluateProject(){
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        System.debug('___SETUP: projects='+projects);
        pse__Proj__c proj1 = (pse__Proj__c) projects[0];
        
        ECO_HealthCheckEvaluator hce = new ECO_HealthCheckEvaluator();
        //OLD: hce.EvaluateProject(proj1.Id);
        projectIds = new List<Id>();
        projectIds.add(proj1.Id);
        hce.EvaluateProjects(projectIds);
    }
}