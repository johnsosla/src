public class ECO_ProjectReviewRecordTypeController {
        
        public pse__Proj__c theProject {get; set;}

        public ECO_ProjectReviewRecordTypeController(ApexPages.StandardController oStandardController) 
        {
                theProject = (pse__Proj__c)oStandardController.getRecord();     
        }
        
        public void init()
        {
//              String projectId;
//              if(oProjectReview.Project__c == null)
//                      projectId= ApexPages.currentPage().getParameters().get('ProjectId');
//              else
//                      projectId = oProjectReview.Project__c;
//              theProject = [select Id, Name from pse__Proj__c where Id = :projectId];
        }
        
        public PageReference cancel()
        {
                return new PageReference('/' + theProject.Id);
        }
        
        public list<ProjectReview__c> getProjectReviews()
        {
                return [select Id, Name, RecordType.Name, Status__c, IsPerformanceReview__c, ScheduledDate__c, CompletedDate__c, ResponsiblePerson__c, Responsible_Person__c from ProjectReview__c where Project__c = :theProject.Id];
        }
        
        public PageReference createNewProjectReview()
        {
                String selectedRecordType = ApexPages.currentPage().getParameters().get('RecordType');
                //String projectId = ApexPages.currentPage().getParameters().get('ProjectId');
                //ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Brent' + selectedRecordType);
        //ApexPages.addMessage(oPageMessage);
                //return null;
        
                RecordType recordType = [select Id, Name from RecordType where SobjectType = 'ProjectReview__c' and Name = :selectedRecordType limit 1];
        
                if(selectedRecordType == 'Project Performance Review'  || selectedRecordType == 'Monthly Project Review' )  
                     return new PageReference('/apex/ECO_ProjectPerformanceReviews?ProjectId=' + theProject.Id + '&' + 'RecordTypeId=' + recordType.Id);        

                return new PageReference('/apex/ECO_ProjectReviews?ProjectId=' + theProject.Id + '&' + 'RecordTypeId=' + recordType.Id);
        
                //else
                //      return new PageReference('/apex/ECO_ProjectReviews?ProjectId=' + projectId + '&' + 'RecordTypeId=' + recordType.Id);
        }
}