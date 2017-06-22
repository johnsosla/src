public with sharing class ECO_BudgetEACLoadingController extends ECO_Financial_Security {

	private final sObject mysObject;
    public String action {get; set;}
    public Id sProjectId {get; set;}
    public String status {get; set;}
    public Id jobId {get; set;}

    public Integer counter {get; set;}
    public Integer interval {get; set;}
    public AsyncCreateEAC asyncInstance {get; set;}
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ECO_BudgetEACLoadingController(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        this.sProjectId = stdController.getId();
        this.action = ApexPages.currentPage().getParameters().get('action');
        this.interval = 5; // Every {interval} sec poll
        this.counter = 0;
    }

    public String getRecordName() {
        return 'Hello ' + (String)mysObject.get('name') + ' (' + (Id)mysObject.get('Id') + ')';
    }

    public void doAction() {
        status = 'Creating EAC...';
        asyncInstance = new AsyncCreateEAC(action, sProjectId);
        jobId = System.enqueueJob(asyncInstance);
    }

    public PageReference pollEacStatus() {
        counter += interval;
        AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobId];

        status = jobInfo.Status;

        if (jobInfo.Status == 'Completed') {
            List<BudgetHeader__c> bhs = [Select Id FROM BudgetHeader__c Where Project__c = :sProjectId ORDER BY CreatedDate desc LIMIT 1];
            if (bhs.size() > 0) {
                PageReference oPageReference = Page.ECO_BudgetHeader;
                oPageReference.setRedirect(true);
                oPageReference.getParameters().put('Id', bhs[0].Id);
                return oPageReference;
            }
        } else if (jobInfo.Status == 'Failed') {
            status = 'EAC Generation Failed... See Error logs for details ';
        }

        return null;
    }
}