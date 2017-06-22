public with sharing class ECO_TechnicalQualityReviewTriggers {
	public ECO_TechnicalQualityReviewTriggers() {
		
	}

	public void approveTQTMembers(list<TechnicalQualityReview__c> listNew){
		
		set<String> sRolesToApprove = new set<String>();
		set<id> setDeliverableIDs = new set<id>();

		map<id,id> mapTQTRByDeliverable = new map<id,id>();
		
		for(TechnicalQualityReview__c oTQTR: listNew){
			setDeliverableIDs.add(oTQTR.Deliverable__c);
			if(oTQTR.Approver__c){
				sRolesToApprove.add('Approver');
			}
			if(oTQTR.IndependentReviewer__c){
				sRolesToApprove.add('Independent Reviewer');
			}
			if(oTQTR.LeadVerifier__c){
				sRolesToApprove.add('Lead Verifier');
			}
			if(oTQTR.Reviewer__c){
				sRolesToApprove.add('Reviewer');
			}
			map<id,TechnicalQualityTeam__c> mapTechTeam = new map<id,TechnicalQualityTeam__c>([Select Id
																							  From TechnicalQualityTeam__c
																							  Where Deliverable__c =: setDeliverableIDs
																							  And Role__c =: sRolesToApprove
																							  And Status__c != 'Approved'
																							  And Status__c != 'Submitted']);
			System.Debug(logginglevel.error,'mapTechTeam: ' + mapTechTeam);
			ECO_Service_Deliverable.submitNewTeamMemberforApproval(mapTechTeam);
		}
	}
}