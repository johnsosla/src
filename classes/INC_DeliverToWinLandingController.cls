public without sharing class INC_DeliverToWinLandingController {
    public list<IncentiveProject__c> lstIP {get;set;}
    public list<IncentiveProject__c> lstIPShort {get;set;}
    public list<INC_LandingPageResourceLinks__c> lstResources {get;set;}
    public list<INC_LandingPageReportCharts__c> lstCharts {get;set;}
    public list<EnrollmentPlan__c> lstEnrollmentPlan {get;set;}
    public list<ParticipantAcknowledgement__c> lstPartAck {get;set;}
    public list<ApprovalItem> lstApprovalItem {get;set;}
    public list<ApprovalItem> lstApprovalItemShort {get;set;}
    public list<ApprovalItem> lstApprovalItemPA {get;set;}
    public list<ApprovalItem> lstApprovalItemShortPA {get;set;}
    public boolean bMore {get;set;}
    public boolean bMoreAck {get;set;}
    public boolean bMoreProj {get;set;}


    public class ApprovalItem {
        public EnrollmentPlan__c oEP {get;set;}
        public ParticipantAcknowledgement__c oPA {get;set;}
        public ProcessInstance oPI {get;set;}
        public string name {get;set;}
        public id objectId {get;set;}
        public string type {get;set;}
        public date submitDate {get;set;}
        public decimal formstatusage {get;set;}
        public string status {get;set;}
        public string projectNum {get;set;}
        public string lastActor {get;set;}
        public decimal GrossRevenueBacklog {get;set;}


        public ApprovalItem(EnrollmentPlan__c oEP, ProcessInstance oPI){
            this.oEP = oEP;
            this.oPI = oPI;
            this.type = this.oEP.ApplicationType__c;
            this.name = this.oEP.name;
            this.objectId = this.oEP.id;
            this.formstatusage = this.oEP.FormStatusAge__c;
            this.status = this.oEP.EnrollmentStatus__c;
            this.projectNum = this.oEP.ProjectID__c;
            this.GrossRevenueBacklog = this.oEP.IncentiveProject__r.GRBacklog__c;

        }

        public ApprovalItem(ParticipantAcknowledgement__c oPA){
            this.oPA = oPA;
            this.type = 'Participation Acknowledgement';
            this.name = this.oPA.ProjectName__c;
            this.objectId = this.oPA.id;
            this.submitDate = this.oPA.Sent_Date__c;
            this.status = this.oPA.Status__c;
            this.projectNum = this.oPA.ParticipantID__r.EnrollmentPlan__r.ProjectID__c;
        }

        public ApprovalItem(EnrollmentPlan__c oEP){
            this.oEP = oEP;
            this.type = this.oEP.ApplicationType__c;
            this.name = this.oEP.name;
            this.objectId = this.oEP.id;
            this.formstatusage = this.oEP.FormStatusAge__c;
            this.status = this.oEP.EnrollmentStatus__c;
            this.projectNum = this.oEP.ProjectID__c;
            this.GrossRevenueBacklog = this.oEP.IncentiveProject__r.GRBacklog__c;

        }

    }

    public INC_DeliverToWinLandingController() {
    
        bMore = false;
        bMoreProj = false;
        bMoreAck = false;
        lstApprovalItem = new list<ApprovalItem>();
        lstApprovalItemPA = new list<ApprovalItem>();

        getProjects();
        getLinks();
        getApprovalItems();
        getCharts();


        if(lstApprovalItem.size() > 5){
            lstApprovalItemShort = new list<ApprovalItem>();
            lstApprovalItemShort.add(lstApprovalItem[0]);
            lstApprovalItemShort.add(lstApprovalItem[1]);
            lstApprovalItemShort.add(lstApprovalItem[2]);
            lstApprovalItemShort.add(lstApprovalItem[3]);
            lstApprovalItemShort.add(lstApprovalItem[4]);

        } else {
            lstApprovalItemShort = lstApprovalItem;
        }

        if(lstApprovalItemPA.size() > 5){
            lstApprovalItemShortPA = new list<ApprovalItem>();
            lstApprovalItemShortPA.add(lstApprovalItemPA[0]);
            lstApprovalItemShortPA.add(lstApprovalItemPA[1]);
            lstApprovalItemShortPA.add(lstApprovalItemPA[2]);
            lstApprovalItemShortPA.add(lstApprovalItemPA[3]);
            lstApprovalItemShortPA.add(lstApprovalItemPA[4]);

        } else {
            lstApprovalItemShortPA = lstApprovalItemPA;
        }


        if(lstIP.size() > 5){
            lstIPShort = new list<IncentiveProject__c>();
            lstIPShort.add(lstIP[0]);
            lstIPShort.add(lstIP[1]);
            lstIPShort.add(lstIP[2]);
            lstIPShort.add(lstIP[3]);
            lstIPShort.add(lstIP[4]);

        } else {
            lstIPShort = lstIP;
        }


    }

    private void getProjects(){


        list<ParticipantAcknowledgement__c> listPA = [  select id, ParticipantID__r.EnrollmentPlan__c
                                                        from ParticipantAcknowledgement__c where 
                                                        OwnerId=:UserInfo.getUserId() and Acknowledged__c != 'No' and ParticipantID__c != null limit 1000];

        set<id> sIncP = new set<id>();

        for(ParticipantAcknowledgement__c p:listPA){
            sIncP.add(p.ParticipantID__r.EnrollmentPlan__c);
        }



        string strSOQL = 'SELECT ';
        
        for (Schema.FieldSetMember fsmField: SObjectType.IncentiveProject__c.FieldSets.LandingPageDisplay.getFields()) {
            strSOQL += fsmField.getFieldPath() + ', ';
        }
        
        string struserid = UserInfo.getUserId();

        //strSOQL += 'ID FROM IncentiveProject__c WHERE EnrollmentStatus__c=\'Enrolled\' limit 5';

        //strSOQL += 'ID, EnrollmentPlan__c FROM IncentiveProject__c WHERE EnrollmentPlan__c !=null and OwnerId=:struserid and X60DaysClosed__c != \'Yes\' ORDER BY EnrollmentPlan__r.FormEnrollmentDate__c  DESC limit 500';

        strSOQL += 'ID, EnrollmentPlan__c,ChangeRequest__c, ChangeRequest__r.EnrollmentStatus__c FROM IncentiveProject__c WHERE EnrollmentPlan__c !=null and X60DaysClosed__c != \'Yes\' and EnrollmentPlan__c IN:sIncP  ORDER BY EnrollmentPlan__r.FormEnrollmentDate__c  DESC limit 500';

        lstIP = (list<IncentiveProject__c>)Database.query(strSOQL);     
    }

    private void getLinks(){
        lstResources = [select name, Link__c from INC_LandingPageResourceLinks__c order by Priority__c asc];

    }

    private void getCharts(){

        //list<RoutingMember__c> listAdmin = [select id from RoutingMember__c where DTWAdmin__c =: UserInfo.getUserId() limit 1];
        //list<RoutingMember__c> listApprove = [select id from RoutingMember__c where Approver1__c =: UserInfo.getUserId() or Approver2__c =: UserInfo.getUserId() or Approver3__c =: UserInfo.getUserId() limit 1];

        string strSOQL = 'SELECT name, Col_1_Chart__c, Col_2_Chart__c, Col_3_Chart__c, Col_4_Chart__c, group__c from INC_LandingPageReportCharts__c LIMIT 1';

        //if(listAdmin.size() >0) {
        //    strSOQL += ' group__c = \'ADMIN\' OR ' ;
        //}

        //if(listApprove.size() >0) {
        //    strSOQL += ' group__c = \'APPROVE\' OR ' ;
        //}

        //strSOQL += ' group__c = \'PM\' order by Group__c, Row_Number__c asc';

        lstCharts = (list<INC_LandingPageReportCharts__c>)Database.query(strSOQL);  

    }


    private void getApprovalItems(){

        list<ProcessInstanceStep> lstStep = [select id, StepStatus, ActorId, ProcessInstanceid, ProcessInstance.targetObjectId, ProcessInstance.createddate from ProcessInstanceStep  where (StepStatus = 'Pending' or StepStatus = 'Approved') AND ActorId =: UserInfo.getUserId() and ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObject.Type = 'EnrollmentPlan__c'];
        list<ProcessInstanceWorkItem> lstWFI = [select id, ProcessInstanceid, ProcessInstance.targetObjectId, ProcessInstance.createddate, ActorId from ProcessInstanceWorkItem  where ProcessInstance.Status = 'Pending' AND ActorId =: UserInfo.getUserId() and ProcessInstance.TargetObject.Type = 'EnrollmentPlan__c'];

        set<id> setPIid = new set<id>();

        for(ProcessInstanceStep pis: lstStep){
            setPIid.add(pis.ProcessInstanceid);
        }

        for(ProcessInstanceWorkItem pis: lstWFI){
            setPIid.add(pis.ProcessInstanceid);
        }


        //list<ProcessInstance> lstPI = [SELECT targetObjectId FROM ProcessInstance WHERE Status = 'Pending' AND TargetObject.Type = 'EnrollmentPlan__c' AND ActorId =: UserInfo.getUserId()];
        list<ProcessInstance> lstPI = [SELECT id, targetObjectId, createddate, (SELECT Id, StepStatus, Actor.name FROM StepsAndWorkitems where StepStatus='Approved' Order By SystemModStamp Desc) FROM ProcessInstance WHERE id IN: setPIid];

        map<id, ProcessInstance> lstEPPending = new map<id, ProcessInstance>();

        for(ProcessInstance PI: lstPI){
            lstEPPending.put(PI.targetObjectId, PI);
        }

        // ENR & CCR with 'Pending PM Action'
        lstEnrollmentPlan = [select id, name, EnrollmentStatus__c, ProjectID__c, ApplicationType__c, FormStatusAge__c, IncentiveProject__r.GRBacklog__c, WorkflowOwner__c from EnrollmentPlan__c where IncentiveProject__r.ProjectManager__c = :UserInfo.getUserId() and EnrollmentStatus__c = 'Pending PM Action' order by FormStatusAge__c desc limit 1000];

        for(EnrollmentPlan__c ep:lstEnrollmentPlan){
            lstApprovalItem.add(new ApprovalItem(ep));
        }

        lstEnrollmentPlan = [select id, name, EnrollmentStatus__c, ProjectID__c, ApplicationType__c, FormStatusAge__c, IncentiveProject__r.GRBacklog__c, WorkflowOwner__c from EnrollmentPlan__c where id IN:lstEPPending.keyset() order by FormStatusAge__c desc limit 1000];

        for(EnrollmentPlan__c ep:lstEnrollmentPlan){
            lstApprovalItem.add(new ApprovalItem(ep, lstEPPending.get(ep.id)));
        }

        //lstPartAck = [select id, EnrollmentAppName__c, ProjectName__c, Sent_Date__c from ParticipantAcknowledgement__c where Acknowledged__c != 'Yes' and ParticipantID__c != null and ownerid=:UserInfo.getUserId() limit 5];
        lstPartAck = [select id, EnrollmentAppName__c, ProjectName__c, Sent_Date__c, Status__c, ParticipantID__r.EnrollmentPlan__r.ProjectID__c from ParticipantAcknowledgement__c where OwnerId=:UserInfo.getUserId() and Acknowledged__c != 'Yes' and ParticipantID__c != null and X60DaysClosed__c != 'Yes' order by Sent_Date__c desc limit 1000];

        for(ParticipantAcknowledgement__c pa:lstPartAck){
            lstApprovalItemPA.add(new ApprovalItem(pa));
        }

    }

    public pagereference more(){
        bMore = true;
        return null;
    }

    public pagereference less(){
        bMore = false;
        return null;
    }

    public pagereference moreAck(){
        bMoreAck = true;
        return null;
    }

    public pagereference lessAck(){
        bMoreAck = false;
        return null;
    }

    public pagereference moreProj(){
        bMoreProj = true;
        return null;
    }

    public pagereference lessProj(){
        bMoreProj = false;
        return null;
    }
}