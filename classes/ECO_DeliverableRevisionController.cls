public with sharing class ECO_DeliverableRevisionController {
	public DeliverableRevision__c mysObject {get;set;}
    public Deliverable__c oDel {get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ECO_DeliverableRevisionController(ApexPages.StandardController stdController) {
        this.mysObject = (DeliverableRevision__c)stdController.getRecord();

        oDel = [select id, Name, Approver__c, NumofRevisions__c from Deliverable__c where id =: mysObject.Deliverable__c];

        mysObject.Approver__c = oDel.Approver__c;
        mysObject.name = oDel.Name + ' - ' + string.valueof(oDel.NumofRevisions__c + 1);

    }

    public pagereference saveDR(){
        insert mysObject;

        return new pagereference('/' + mysObject.id);
    }

}