public with sharing class FormApproverController {

	public Forms__c frm {get;set;}
	public FormApproverController(ApexPages.standardController ctl ) {
		this.frm = (Forms__c)ctl.getRecord();
	}
	
	/**
	* @description retrieve list of approvers for this form
	*/
	public List<Approvers__c> approvers {
		get {
			if (approvers == null) {
				approvers = [SELECT ID, Name, Form__c, Name_Of_Approver__c, Name_of_Approver__r.Name, Approval_Status__c, Approver_Role__c FROM Approvers__c WHERE Form__c = :frm.ID ORDER BY Name_of_Approver__r.Name];
			}
			return approvers;
		}
		set;
	}
	
	/**
	* @description submit all New approvals records to the appropriate approval process. Does not throw any errors.
	*/
	public PageReference submitForApproval() {
		List<Approval.Processsubmitrequest> approvalRequests = new List<Approval.Processsubmitrequest>();
		for (Approvers__c apr : approvers) {
			if (apr.Approval_Status__c == 'New') {
				Approval.Processsubmitrequest req = new Approval.Processsubmitrequest();
				req.setComments('Go/No Go Decision For Form ' + frm.Name);
				req.setObjectId(apr.ID);
				approvalRequests.add(req);
			}
		}
		
		List<Approval.ProcessResult> approvalResults = Approval.process(approvalRequests, false);
		
		PageReference ref = new ApexPages.standardController(frm).view();
		return ref;
	}
	
	@isTest
	static void testFormApproverController() {
		Forms__c frm = new Forms__c();
		insert frm;
		
		Approvers__c appr = new Approvers__c(Form__c = frm.ID);
		appr.Name_of_Approver__c = Userinfo.getUserId();
		appr.Approval_Status__c = 'New';
		insert appr;
		
		ApexPages.Standardcontroller ctl = new ApexPages.Standardcontroller(frm);
		FormApproverController ext = new FormApproverController(ctl);
		ext.submitForApproval();
	}
}