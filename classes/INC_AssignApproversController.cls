public with sharing class INC_AssignApproversController {
	
	public EnrollmentPlan__c oEnrollmentPlan{get;set;}
	
	public map<Id,ApproverWrapper> mapFirstApprovers {get;set;}
	public map<Id,ApproverWrapper> mapSecondApprovers {get;set;}
	public map<Id,ApproverWrapper> mapThirdApprovers {get;set;}
	public String selectedID {get;set;}
	public Boolean bEdit {get;set;}
	public Integer iShowApprover1 {get;set;} /* 1=allow edit of all 2=Allow edit of only 2 and 3 3= no edit*/
	
	public INC_AssignApproversController(ApexPages.StandardController stdController) {
		oEnrollmentPlan = (EnrollmentPlan__c)stdController.getRecord();

		oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{oEnrollmentPlan.ID})[0];
		validateIfEditIsPossible();
		if(iShowApprover1 == 3){
			//CUSTOMLABEL LABEL.DTWINCAACFAERR
			//ApexPages.addMessage(new apexpages.message(apexpages.severity.error,'Only the first approver or DTW Admins can reassign approvers.'));
			ApexPages.addMessage(new apexpages.message(apexpages.severity.error,LABEL.DTWINCAACFAERR));
		
			return;
		}
		bEdit = true;
		getAllApprovers();
		System.Debug(logginglevel.error,'count: ' + mapSecondApprovers.Size());

	}

	private void validateIfEditIsPossible(){
		boolean bisApprover1 = false;
		if(UserInfo.getUserId() == oEnrollmentPlan.Approver1__c){
			bisApprover1 = true;
			
		}
		Set<id> setDTW = new Set<id>();
		map<id,Group> mapgroupIds = new map<id,Group>([Select ID from Group where Name = 'DTW Admins' or Name = 'CORP DTW Admin']);

		for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = :mapGroupIds.keySet()])
		{
    			setDTW.add(m.UserOrGroupId);
		}
		if(setDTW.contains(UserInfo.getUserId())){
			iShowApprover1 = 1; //in the groups so all full edit
		}else{
			if(bisApprover1){
				iShowApprover1 = 2;
			}else{
				iShowApprover1 = 3;
			}
		}
	}
	
	public void AssignApprover1(){
		System.debug(logginglevel.error,'Approver 1 ' + selectedID);
		oEnrollmentPlan.Approver1__c = mapFirstApprovers.get(selectedID).oRoutingMember.Approver1__c;
	}

	public void AssignApprover2(){
		System.Debug(logginglevel.error,'Approver 2 ' + selectedID);
		oEnrollmentPlan.Approver2__c = mapSecondApprovers.get(selectedID).oRoutingMember.Approver2__c;
	}

	public void AssignApprover3(){
		System.Debug(logginglevel.error,'Approver 2 ' + selectedID);
		oEnrollmentPlan.Approver3__c = mapSecondApprovers.get(selectedID).oRoutingMember.Approver3__c;
	}

	public pageReference Save(){
		PageReference returnPage = new pageReference('/apex/INC_EnrollmentApp?id=' + oEnrollmentPlan.ID);
		returnPage.setRedirect(true);
		System.savePoint sp = Database.setSavePoint();
        try{
            update oEnrollmentPlan;
            System.debug(logginglevel.error,'oEnrollmentPlan saved');
     		return returnPage;
        }catch(Exception e){
            system.debug('Handling Exception:  '+e.getMessage());
            Database.rollBack(sp);
            ApexPages.addMessages(e);
            return null;
        }
	}

	public pageReference cancel(){
		PageReference returnPage = new pageReference('/apex/INC_EnrollmentApp?id=' + oEnrollmentPlan.ID);
		returnPage.setRedirect(true);
		return returnPage;
	}
	private void getAllApprovers(){
		set<id> setApprover1 = new set<id>();
		set<id> setApprover2 = new set<id>();
		set<id> setApprover3 = new set<id>();
		
		mapFirstApprovers = new map<id,ApproverWrapper>();
		mapSecondApprovers = new map<id,ApproverWrapper>();
		mapThirdApprovers = new map<id,ApproverWrapper>();

		for(RoutingMember__c rt: [Select ID
											, GeographyDescription__c
											, DistrictDescription__c
											, RegionDescription__c
											, EndMarket__c
											, LegalEntityDescription__c
											, Approver1__c
											, Approver2__c
											, Approver3__c
											, Approver1__r.Name
											, Approver2__r.Name
											, Approver3__r.Name
											, globalDefault__c
									From RoutingMember__c
									where globalDefault__c = false 
									And   GeographyDescription__c =: oEnrollmentPlan.IncentiveProject__r.GeographyDescription__c]){
			System.Debug(logginglevel.error,'routing member: ' + rt.globalDefault__c);
			if(!setApprover1.Contains(rt.Approver1__c)){
				if(rt.Approver1__c != null){
					mapFirstApprovers.put(rt.id,new ApproverWrapper(rt));
					setApprover1.add(rt.Approver1__c);
				}
			}
			if(!setApprover2.Contains(rt.Approver2__c)){
				if(rt.Approver2__c != null){
					mapSecondApprovers.put(rt.id,new ApproverWrapper(rt));
					setApprover2.add(rt.Approver2__c);
				}
			}
			if(!setApprover3.Contains(rt.Approver3__c)){
				if(rt.Approver3__c != null){
					mapThirdApprovers.put(rt.id,new ApproverWrapper(rt));
					setApprover3.add(rt.Approver3__c);
				}
			}

		}

	}

	private class ApproverWrapper{
		public RoutingMember__c oRoutingMember{get;set;}
		public boolean bSelected{get;set;}
		public ApproverWrapper(RoutingMember__c rt){
			oRoutingMember = rt;
			bSelected = false;
		}
	}

}