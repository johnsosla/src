public with sharing class ECO_ApprovalKillSwitchController {

    public Deliverable__c oDeliverable {get;set;}
    public list<TechnicalQualityTeam__c> listTQT {get;set;}
    public list<TechnicalQualityTeam__c> listTQTApproved {get;set;}

    public ECO_ApprovalKillSwitchController(ApexPages.StandardController oStandardController) {
        this.oDeliverable = (Deliverable__c)oStandardController.getRecord();

        listTQT = [select id, Status__c from TechnicalQualityTeam__c where Deliverable__c =: this.oDeliverable.id];
    }

    public PageReference killapproval(){

        set<id> TQTIds = new set<id>();
        set<id> TQTIdsApproved = new set<id>();
        listTQTApproved = new list<TechnicalQualityTeam__c>();

        if(listTQT.size() >0){

            for (TechnicalQualityTeam__c t: listTQT) {
                if(t.Status__c == 'Approved'){
                        t.Status__c = 'Recalled';
                        TQTIdsApproved.add(t.id);
                        listTQTApproved.add(t);
                }
                TQTIds.add(t.id);
            }            


            //update the status of all approved TQTs.
            try {
                update listTQTApproved;
            } catch (Exception e) {
                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to update approved records');
                ApexPages.addMessage(oMsg);
                return null;
            }     


            // Find all pending requests and recall them.
            List<ProcessInstance> procins = new List<ProcessInstance>([select Id from ProcessInstance where Status = 'Pending' and TargetObjectId IN:TQTIds]);

            set<id> procIds = new set<id>();

            if (procins.size() > 0) {
                for (ProcessInstance p: procins) {
                    procIds.add(p.id);
                }

                List<ProcessInstanceWorkitem> workitem = new List<ProcessInstanceWorkitem>([select Id from ProcessInstanceWorkitem where ProcessInstanceId IN :procIds]);


                list<Approval.ProcessWorkitemRequest> itemsToUpdate = new list<Approval.ProcessWorkitemRequest>();

                for(ProcessInstanceWorkitem w: workitem){
                    Approval.ProcessWorkitemRequest PWR = new Approval.ProcessWorkitemRequest();
                    PWR.setComments('Killing Pending Request');
                    PWR.setAction('Removed');
                    PWR.setWorkItemId(w.Id);
                    itemsToUpdate.add(PWR);
                }                

                if(itemsToUpdate.size() > 0){
                    list<Approval.ProcessResult> results =  Approval.process(itemsToUpdate);
                }


            }
        }

        PageReference pageRef = new PageReference('/' + this.oDeliverable.id);
        return pageRef;
    }
}