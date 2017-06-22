@isTest(seeAllData=false)
private class ECO_PackageTriggerHelperTest {
    static List<pse__Time_Period__c> timePeriods {get; set;}
    static List<pse__Proj__c> projects {get; set;}
    static List<Id> projectIds {get; set;}
    static pse__Proj__c proj1 {get; set;}
    static List<RecordType> rtList {get; set;}
    static Map<Id, RecordType> mRecordTypes;
    
    @testSetup static void setupTestData() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_ProjectReviewTrigger.run = false;
        
        timePeriods = Test.loadData(pse__Time_Period__c.sObjectType, 'UT_TimePeriods');
        List<pse__Proj__c> projectsTemp = Test.loadData(pse__Proj__c.sObjectType, 'UT_Project');
        
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
        
        System.debug('___SETUP: projects='+projects);
        proj1 = (pse__Proj__c) projects[0];
        
        rtList = 
           [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true];
        
        System.debug('___SETUP: rtList='+rtList);
        System.debug('___SETUP: rtId='+rtList[0].Id);
        mRecordTypes = new Map<Id, RecordType>();
        for (RecordType rt : rtList) {
            mRecordTypes.put(rt.Id, rt);
        }
        System.debug('___ mRecordTypes ='+ mRecordTypes);
    }
    
    static void configProjectReview() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_ProjectReviewTrigger.run = false;
        
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];

        rtList = 
            [Select Name, Id From RecordType where sObjectType='ProjectReview__c' and isActive=true
             AND Name='BIM Healthy Start'];
        System.debug('___SETUP: rtList='+rtList);
        Id rtId = rtList[0].Id;
        System.debug('___SETUP: rtId='+rtList[0].Id);
        
        mRecordTypes = new Map<Id, RecordType>();
        for (RecordType rt : rtList) {
            mRecordTypes.put(rt.Id, rt);
        }
        System.debug('___ mRecordTypes ='+ mRecordTypes);
        
        ProjectReview__c pRev = new ProjectReview__c(Project__c = proj1.Id);
        pRev.Name = 'Test ProjectReview';
        pRev.RecordTypeId = rtId;
        pRev.MeetingMinutes__c = 'Test 1';
        pRev.SafetyExceptionReport__c = '1';
        pRev.ClientRelations__c = '2';
        pRev.ChangeManagementExceptionReport__c = '3';
        pRev.FinancialPerformanceExceptionReport__c = '4';
        pRev.SheduleExceptionReport__c = '5'; 
        pRev.QualityException__c = '6'; 
        pRev.RiskManagement__c = '7'; 
        pRev.StaffResourcesExceptionReport__c = '8'; 
        pRev.SubsExceptionReport__c = '9';
        pRev.ScheduledDate__c = Date.today() + 10;
        insert pRev;
        System.debug('___pRev='+pRev);
        
        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Name='Test PRT', 
            Purpose__c='Test1', TemplateType__c = 'BIM Healthy Start');
        insert prt;
        System.debug('___ProjectReviewTemplate__c prt='+prt);
    }
    
    static testMethod void testConstructor() {
        ECO_PackageTriggerHelper pth = new ECO_PackageTriggerHelper();
    }
    
    static testMethod void testSetChangeManagerIsChanged() {
        configProjectReview();
        Map<Id, Packages__c> oldMap = new Map<Id, Packages__c>(); 
        List<Packages__c> updatedScopeList = new List<Packages__c>();
        ECO_PackageTriggerHelper.setChangeManagerIsChanged(
            oldMap, updatedScopeList);
    }
    
    static testMethod void testAttachHealthStart() {
        configProjectReview();
        List<Packages__c> newPackageList = new List<Packages__c>();
        Packages__c pckg1 = new Packages__c(Name='Pkg 1', Scope__c = proj1.Id, 
        	Utilize_BMI_Technology__c=true, ChangeManagerIsChanged__c=false);
        System.debug('___pckg1='+pckg1);
        newPackageList.add(pckg1);
        ECO_PackageTriggerHelper.attachHealthStart(
            newPackageList, null);
    }
    
    static testMethod void testAttachHealthStart_NoPRT() {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_ProjectReviewTrigger.run = false;
        
        projects = [SELECT Id,Name,CurrencyIsoCode,RecordTypeId,pse__Account__c,
            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c];
            
        proj1 = (pse__Proj__c) projects[0];
        
        ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(Name='Test PRT', 
            Purpose__c='Test1', TemplateType__c = 'Performance Review');
        insert prt;
        
        List<Packages__c> newPackageList = new List<Packages__c>();
        Packages__c pckg1 = new Packages__c(Name='Pkg 1', Scope__c = proj1.Id, 
        	Utilize_BMI_Technology__c=true, ChangeManagerIsChanged__c=false);
        System.debug('___pckg1='+pckg1);
        newPackageList.add(pckg1);
        ECO_PackageTriggerHelper.attachHealthStart(
            newPackageList, null);
    }
}