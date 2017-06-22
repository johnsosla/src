/*************************************************************************
*
* PURPOSE: Controller for EMEA embedded VF page
*
* CLASS: gng_EMEA_PageLayout_Controller
* CREATED: 12/15/2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/

public with sharing class gng_EMEA_PageLayout_Controller {

	private Go_No_Go_Conversation__c gng;
	private static final Set<String> EXTRA_FIELDS = new Set<String>{'Bid_Manager__r.Name', 'Project_Director__r.Name'};
	public gng_GNGDao gDao = gng_GNGDao.getInstance();
	public gng_ApprovalProcessDao apDao = gng_ApprovalProcessDao.getInstance();
	public Boolean refreshPage { get; set; }
	public Boolean isEdit {get;set;}
	public String approvalComment {get;set;}

	public gng_EMEA_PageLayout_Controller(ApexPages.StandardController cont) {
		gDao.addFields(EXTRA_FIELDS);
		gng = (Go_No_Go_Conversation__c)gDao.getSObjectById(cont.getId());
		refreshPage = false;
		isEdit = false;
	}

	public Go_No_Go_Conversation__c getGNG() {
		return gng;
	}

	public PageReference submitForApproval() {
		refreshPage = submitGNG('Submitting for approval');
		return null;
	}

	public Boolean submitGNG(String comment) {
		Boolean shouldRefresh = true;
		gDao.save(gng);
		try {
			apDao.submitApprovalProcess(gng.Id, comment);
		} catch (DmlException ex) {
			if(ex.getMessage().contains('MANAGER_NOT_DEFINED')) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'A Project Director has not been added for this GNG record'));
				shouldRefresh = false;
			}
			else throw ex;
		}
		return shouldRefresh;
	}

	public void approveGNG() {
		gng.Skip_Approval__c = true;
		completeTask();
		try{
			submitGNG(String.isNotBlank(approvalComment) ? approvalComment: 'Approving Request');
		}
		catch(Exception e) {}
		refreshPage = true;
	}

	public void rejectGNG() {
		gng.Skip_Approval__c = false;
		completeTask();
		try{
			submitGNG(String.isNotBlank(approvalComment) ? approvalComment : 'Rejecting Request');
		}
		catch(Exception e) {}
		refreshPage = true;
	}

	public Boolean getIsProjectDirector() {
		return gng.Project_Director__c == UserInfo.getUserId();
	}

	public Boolean getIsInSubmittableState() {
		return !getIsProjectDirector() && !apDao.isUnderApproval(gng.Id);
	}

	public void editMode() {
		isEdit = true;
	}

	private void completeTask() {
		try{
			List<Task> tasks = [select id, Status from Task where WhatId =: gng.Id and Status != 'Completed'];
			if(tasks.size() > 0) {
				for(Task t : tasks) {
					t.Status = 'Completed';
				}
			}
			update tasks;
		}
		catch(Exception e) {
			system.debug('Couldn\'t complete task: ' + e);
		}	
	}

	public void saveGNG() {
		gDao.save(gng);
		isEdit = false;
	}
}