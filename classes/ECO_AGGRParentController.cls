public with sharing class ECO_AGGRParentController {
    
    private IncentiveProject__c prj; 

    public ECO_AGGRParentController(ApexPages.StandardController stdController) {

        prj = (IncentiveProject__c)stdController.getRecord();
        
        System.Debug('prj' + prj);
        
        String qry = 'select Id, Name, ProjectID__c, Aggregated_Project__c, AggregatorAutonumber__c, RecordTypeId ';
        
        for ( Schema.FieldSetMember f : SObjectType.IncentiveProject__c.FieldSets.AGGRClone.getFields()){
            qry += ',' + f.getFieldPath();
        }
        
        qry += ' from IncentiveProject__c where Id = \'' + prj.Id + '\'';
        
        System.Debug('qry' + qry);
        
        prj = Database.query(qry);                
    }
        
    public PageReference createAGGR(){
        try {
            RecordType rt = [select Id from RecordType where SObjectType = 'IncentiveProject__c' and Name = 'Aggregated Project'];
            
            IncentiveProject__c aggr = new IncentiveProject__c();
            aggr.Name = 'AGGR: ' + prj.Name;
            aggr.ProjectID__c = 'AGGR: ' + Datetime.Now().getTime();
            aggr.Aggregated_Project__c = 'Yes';
            // Setting DTWAdminAttempted__c to true so weekly load doesn't set the owner to DTW Ineligible Queue INC_Service_EnrollmentPlan.assignIneligibleQueue(lNew)
            aggr.DTWAdminAttempted__c = true;             
    
            for ( Schema.FieldSetMember f : SObjectType.IncentiveProject__c.FieldSets.AGGRClone.getFields()){
                aggr.put(f.getFieldPath(), prj.get(f.getFieldPath()));
            }
            
            aggr.RecordTypeId = rt.Id;
            insert aggr;
          
            IncentiveProject__c updAggr = [select Id, ProjectID__c, AggregatorAutonumber__c from IncentiveProject__c where Id =: aggr.Id];
            updAggr.ProjectID__c = updAggr.AggregatorAutonumber__c;
            update updAggr;
            
            prj.Aggregated_Parent_Project__c = aggr.Id;
            
            update prj;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Aggregate successfully created!'));  
        } catch (Exception e){
            ApexPages.addMessages(e);  
        }
        
        return null;
    }
    
    public PageReference back(){
        PageReference pr = new PageReference('/' + prj.Id);
        pr.SetRedirect(true);
        return pr;
    }
}