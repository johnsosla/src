public with sharing class ECO_pse_Project_Main 
{
    public static void EvaluateHealthyStart(List<pse__Proj__c> newList)
    {
        Integer revenueThreshold = 5000000;
        Integer marginLossThreshold = 500000;
        Set<Id> setProjectIDs = new Set<Id>();
        
        for(pse__Proj__c proj : newList)
        {
            setProjectIDs.add(proj.Id);
        }
        
        List<ProjectReview__c> lProjectReviews = new List<ProjectReview__c>([Select Id, Name, Project__c, RecordType.Name, RecordType.DeveloperName From ProjectReview__c Where (RecordType.DeveloperName = 'HealthyStart' Or RecordType.DeveloperName = 'HealthyRestart') And Project__c In :setProjectIDs]);
        
        Map<Id,ProjectReview__c> mHealthyStarts = new Map<Id,ProjectReview__c>();
        Map<Id,ProjectReview__c> mHealthyRestarts = new Map<Id,ProjectReview__c>();
        Map<String,Id> mRecordTypes = new Map<String,Id>();
        List<RecordType> lRecordTypes = new List<RecordType>([Select Id, Name, DeveloperName From RecordType Where SObjectType = 'ProjectReview__c']);
        if(!lRecordTypes.isEmpty())
        {
            for(RecordType rt : lRecordTypes)
            {
                mRecordTypes.put(rt.Name,rt.Id);
            }
        }
        
        for(ProjectReview__c oPR : lProjectReviews)
        {
            if(oPR.RecordType.DeveloperName == 'HealthyStart')
            {
                mHealthyStarts.put(oPR.Project__c,oPR);
            }
            else if(oPR.RecordType.DeveloperName == 'HealthyRestart')
            {
                mHealthyRestarts.put(oPR.Project__c,oPR);
            }
        }
        
        List<ProjectReview__c> lNewReviews = new List<ProjectReview__c>();
        for(pse__Proj__c proj : newList)
        {
            if(proj.clAECOMProjectReviewCategory__c == 'C-0' || proj.clAECOMProjectReviewCategory__c == 'C-1' || (proj.clAECOMProjectReviewCategory__c == 'C-2' && proj.pse__Revenue__c > revenueThreshold))
            {
                //Healthy Start
                if(!mHealthyStarts.containsKey(proj.Id))
                {
                    ProjectReview__c newPR = new ProjectReview__c();
                    newPR.Project__c = proj.Id;
                    newPR.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(ProjectReview__c.sObjectType, ECO_Constants.ProjectReview_HealthyStartRecordTypeDeveloperName);
                    newPR.Name = 'Healthy Start Review';
                    newPR.Status__c = 'New';
                    lNewReviews.add(newPR);
                }
            }
            if(proj.MarginLoss__c > marginLossThreshold)
            {
                //Healthy Restart
                if(!mHealthyRestarts.containsKey(proj.Id))
                {
                    ProjectReview__c newPR = new ProjectReview__c();
                    newPR.Project__c = proj.Id;
                    newPR.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(ProjectReview__c.sObjectType, ECO_Constants.ProjectReview_HealthyReStartRecordTypeDeveloperName);
                    newPR.Name = 'Healthy Restart Review';
                    newPR.Status__c = 'New';
                    lNewReviews.add(newPR);
                }
            }
        }
        if(!lNewReviews.isEmpty())
        {
            insert lNewReviews;
        }
        
        ECO_pse_Project_TriggerDispatcher.executedMethods.add('EvaluateHealthyStart');
    }
}