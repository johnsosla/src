/** ------------------------------------------------------------------------------------------------------
 * @Description the test class for the ECO_UpdateFundingLoadBatch.cls
 *
 * @Author      NTT Data - Arman Shah
 * @Date        January 2017
 *-----------------------------------------------------------------------------------------------------*/
@isTest
private class ECO_UpdateFundingLoadBatch_Test {
	
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
        List<pse__Project_Task__c> ptList = new List<pse__Project_Task__c>();

        //query = 'select Id, Name, EnableTopTaskCustomerFlag__c, isSegmented__c, SegmentationStatus__c, 
        //clAECOMSegmentationReason__c, CreatedById from pse__Proj__c where ProjectLevelFundingFlag__c = false 
        //and isConverted__c = true';
        for (pse__Proj__c proj : projects) {
            projectIds.add(proj.Id);
            proj.OuIdText__c = '147';
            proj.pse__Start_Date__c = Date.today()-35;
            proj.pse__End_Date__c = Date.today()+35;
            proj.Name = 'TestProj_' + proj.Id;
            proj.isSegmented__c = true;
            proj.SegmentationStatus__c = 'Test';
            proj.clAECOMSegmentationReason__c = 'Conversion';
            proj.ProjectLevelFundingFlag__c = false;
            proj.isConverted__c = true;

            /*SELECT pse__Project__c projectId, count(Id) taskCount FROM pse__Project_Task__c 
                                WHERE pse__Project__c in :projectIds and IsTopLevelTask__c = true
                                GROUP BY pse__Project__c */
            pse__Project_Task__c pt = new pse__Project_Task__c();
            pt.pse__Project__c = proj.Id;
            ptList.add(pt);
        }
        update projects;
        insert ptList;
    }

    //Tests: execute(Database.BatchableContext BC, List<pse__Proj__c> scope)
    static testMethod void testExecute() {

        projects = [select Id, Name, EnableTopTaskCustomerFlag__c, isSegmented__c, SegmentationStatus__c, 
        	clAECOMSegmentationReason__c, CreatedById from pse__Proj__c where ProjectLevelFundingFlag__c = false 
        	AND isConverted__c = true];

        System.assert(projects != null);
        System.debug('___Projects='+projects);

        projectIds = new List<Id>();
        for (pse__Proj__c proj : projects) {
            projectIds.add(proj.Id);
        }
        System.assert(projectIds != null);
        System.debug('___projectIds='+projectIds);
        DateTime asOf = DateTime.now();
		ECO_UpdateFundingLoadBatch batch =
            	new ECO_UpdateFundingLoadBatch();
        Test.startTest();
		Database.executeBatch(batch, 10);
		Test.stopTest();
        System.Assert(projectIds.size() > 0);
    }
}