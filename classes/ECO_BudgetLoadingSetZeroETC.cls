public with sharing class ECO_BudgetLoadingSetZeroETC extends ECO_Financial_Security {

	private final BudgetHeader__c budgetHeader;
    public String resourceType {get; set;}

    public String status {get; set;}
    public Id jobId {get; set;}

    public Integer counter {get; set;}
    public Integer interval {get; set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ECO_BudgetLoadingSetZeroETC(ApexPages.StandardController stdController) {
        this.budgetHeader = (BudgetHeader__c)stdController.getRecord();
    }

     public void doAction() {
        this.interval = 5; // Every {interval} sec poll
        this.counter = 0;
        this.status = 'Zeroing out ETC on Budget Assignments..';
        this.resourceType = ApexPages.currentPage().getParameters().get('resourcetype');
        
        jobId = AsyncSetZeroETC.run(budgetHeader.Id, resourceType);
     
    }

    public PageReference pollEacStatus() {
        counter += interval;
        AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobId];

        status = jobInfo.Status;

        if (jobInfo.Status == 'Completed') {
            PageReference oPageReference = Page.ECO_BudgetLabourEAC;
            oPageReference.setRedirect(true);
            oPageReference.getParameters().put('Id', budgetHeader.Id);
            return oPageReference;
        } 
        else if (jobInfo.Status == 'Failed') {
            status = 'Zeroing out ETCs Failed... See Error logs for details ';
        }

        return null;
    }

}