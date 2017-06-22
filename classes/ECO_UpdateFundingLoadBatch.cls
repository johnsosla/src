global class ECO_UpdateFundingLoadBatch implements Database.Batchable<sObject> {
    
    String query;
    
    global ECO_UpdateFundingLoadBatch() {

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        query = 'select Id, Name, EnableTopTaskCustomerFlag__c, isSegmented__c, SegmentationStatus__c, clAECOMSegmentationReason__c, CreatedById from pse__Proj__c where ProjectLevelFundingFlag__c = false and isConverted__c = true';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<pse__Proj__c> projects) {

        Set<Id> projectIds = new Set<Id>();
        for(pse__Proj__c project:projects)
        {
            projectIds.add(project.Id);
        }         

        Set<Id> segmentedProjectIds = new Set<Id>();
        for(AggregateResult ar:[SELECT pse__Project__c projectId, count(Id) taskCount FROM pse__Project_Task__c 
                                WHERE pse__Project__c in :projectIds and IsTopLevelTask__c = true
                                GROUP BY pse__Project__c])
        {
            if((Decimal)ar.get('taskCount') > 1 )
            {
                System.Debug('Segmented ProjectId: ' + (Id)ar.get('projectId'));
                segmentedProjectIds.add((Id)ar.get('projectId'));
            }
        }
        System.Debug('Segmented Count:' + segmentedProjectIds.size());

        /*Set<Id> topTaskProjectIds = new Set<Id>();  
        for(AggregateResult ar:[SELECT pse__Project__c projectId, count(Id) taskCount FROM pse__Project_Task__c 
                        WHERE pse__Project__c in :projectIds and IsTopLevelTask__c = true
                        and TopTaskOwningCustomer__c != null
                        GROUP BY pse__Project__c])
        {       
            if((Decimal)ar.get('taskCount') > 0 )
            {
                System.Debug('Enable Top Task Customer ProjectId: ' + (Id)ar.get('projectId'));
                topTaskProjectIds.add((Id)ar.get('projectId'));
            }
        }
        System.Debug('Enable Top Task Customer Count:' + topTaskProjectIds.size());*/

        Boolean modified = false;
        List<pse__Proj__c> updatedProjects = new List<pse__Proj__c>();
        for(pse__Proj__c project:projects)
        {
            if(segmentedProjectIds.contains(project.Id))
            {
                project.isSegmented__c = true;
                //project.SegmentationStatus__c = 'Segmented';
                project.clAECOMSegmentationReason__c = 'Segmentable';
                modified = true;
            }

            /*if(topTaskProjectIds.contains(project.Id))
            {
                project.EnableTopTaskCustomerFlag__c = true;
                modified = true;
            }*/

            if(modified)
                updatedProjects.add(project);
            modified = false;
        }
        if(!updatedProjects.isEmpty())
            update updatedProjects;

    }  
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}