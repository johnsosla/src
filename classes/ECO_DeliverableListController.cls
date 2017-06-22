public class ECO_DeliverableListController {
    public pse__Proj__c thisProject {get; set;}
    public ApexPages.StandardController oStandardController {get; set;}
    public ECO_DeliverableListController(ApexPages.StandardController oStandardController){
        this.oStandardController = oStandardController; 
        thisProject = (pse__Proj__c)oStandardController.getRecord();
    }
    
    public PageReference returnProj(){
        return new PageReference('/' + thisProject.Id);
    }

    public List<Deliverable__c> getDeliverables(){
        List <Deliverable__c> deliverList = 
            new List<Deliverable__c>([ Select id, Name, Status__c, DeliverableType__c, DateSubmitted__c, DueDate__c, 
                DeliverablesOwner__r.name, Project_Scope__c, Project_Scope__r.Name From Deliverable__c 
                Where Project__c = :thisProject.Id ]);
        return deliverList;
    }
    public List<TechnicalQualityReview__c> getTQRs(){
        List<TechnicalQualityReview__c> lTQR = new List<TechnicalQualityReview__c>([Select Id, Name, Deliverable__c, DeliverableRevision__c, Deliverable__r.Project__c, TotalNumberOfReviews__c, TotalReviewsCompleted__c From TechnicalQualityReview__c Where Deliverable__r.Project__c = :thisProject.Id ]);
        return lTQR;
    } 
    public PageReference deleteDeliver(){
        Id delId = ApexPages.currentPage().getParameters().get('recid');
        Deliverable__c delRecord = [Select id From Deliverable__c where id = :delId];
        System.debug('Deliverable id:  '+delRecord.Id);
        if(delRecord != null)
            delete delRecord;
        return null;
    }  
    public PageReference backToDeliverables(){
        return new PageReference('/' + thisProject.Id);
    } 
    public PageReference newDeliverable(){
		Deliverable__C oDeliver = new Deliverable__C();
        oDeliver.Project__c = thisProject.id;
        oDeliver.Name = 'New Deliverable';
        try{
            Insert oDeliver;
        }catch (exception e){
            System.debug('Exception: '+e);
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to create new deliverable: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }
        System.debug('oDeliver id:  '+oDeliver.Id);
        System.debug('oDeliver project id:  '+oDeliver.Project__c);
        //return new PageReference('/'+oDeliver.Id+'/e?retURL=/apex/ECO_DeliverableList?id='+thisProject.id);
        return new PageReference('/'+oDeliver.Id+'/e?retURL='+oDeliver.Id);
    }   
    public PageReference exportCSV(){
        String reportId = ReportDetails__c.getInstance('Deliverables List for Export Function').Report_Id__c;
        String projectId = thisProject.id;
        projectId = projectId.substring(0, 15);
        System.debug('reportId:  '+reportId);
        return new PageReference('/'+reportId+'?pv0='+projectId);
    }
    
}