public with sharing class INC_ParticipantTrigger {
	public INC_ParticipantTrigger() {
		

	}

	private static Map<ID, EnrollmentPlan__c> getEnrolApprovalMap(list<EnrollmentParticipant__c> lstTarget){
		map<id, EnrollmentPlan__c> mapEP;
		set<id> enrolAppIds = new set<id>();

		for(EnrollmentParticipant__c ep:lstTarget){
			enrolAppIds.add(ep.EnrollmentPlan__c);
		}		

		mapEP = new Map<ID, EnrollmentPlan__c>([select id, EnrollmentStatus__c 
												from EnrollmentPlan__c 
												where id in: enrolAppIds
														AND EnrollmentStatus__c IN ('Pending Approver 1 Action', 'Pending Approver 2 Action', 'Pending Approver 3 Action', 'Pending DTW Admin')
												]);

		return mapEP;
	}

	public static void CheckChanges(list<EnrollmentParticipant__c> lstTarget, map<id, EnrollmentParticipant__c> oldMap){

		
		set<string> fieldsToCheck = new set<string>();
		map<id, EnrollmentPlan__c> mapEP;
		map<id, EnrollmentPlan__c> mapEPtoUpdate = new map<id, EnrollmentPlan__c>();


        for (Schema.FieldSetMember fsmField: SObjectType.EnrollmentParticipant__c.FieldSets.Track_Change.getFields()) {
            fieldsToCheck.add(fsmField.getFieldPath());
        }

		// check to see if the EP of the Participant is in the approval process
		mapEP = getEnrolApprovalMap(lstTarget);


		// if in the approval process get the fields to check
		for(EnrollmentParticipant__c ep:lstTarget){
			if(mapEP.containsKey(ep.EnrollmentPlan__c)){

				EnrollmentPlan__c ea = mapEP.get(ep.EnrollmentPlan__c);

				for(string field:fieldsToCheck){
					if(ep.get(field) != oldMap.get(ep.id).get(field)){
						ea.EPChanged__c = 'Yes';
						mapEPtoUpdate.put(ea.id, ea);
					}
				}

			}
		}		

		if(mapEPtoUpdate.size() > 0){

            try{
                update mapEPtoUpdate.values();

            }catch(Exception e){
                system.debug('Handling Exception:  ' + e.getMessage() + ' ' + e.getStackTraceString());
                system.debug(logginglevel.error, 'participant update field change flagging: ' + e);
         	}
			
		}
		
	}

	public static void HandleParticipantAddDelete(list<EnrollmentParticipant__c> lstTarget){
		map<id, EnrollmentPlan__c> mapEP;
		map<id, EnrollmentPlan__c> mapEPtoUpdate = new map<id, EnrollmentPlan__c>();

		mapEP = getEnrolApprovalMap(lstTarget);

		// if in the approval process get the fields to check
		for(EnrollmentParticipant__c ep:lstTarget){
			if(mapEP.containsKey(ep.EnrollmentPlan__c)){
				EnrollmentPlan__c ea = mapEP.get(ep.EnrollmentPlan__c);
				ea.EPChanged__c = 'Yes';
				mapEPtoUpdate.put(ea.id, ea);
			}
		}

		if(mapEPtoUpdate.size() > 0){

            try{
                update mapEPtoUpdate.values();

            }catch(Exception e){
                system.debug('Handling Exception:  ' + e.getMessage() + ' ' + e.getStackTraceString());
                system.debug(logginglevel.error, 'participant insert/delete field change flagging : ' + e);
         	}
		}

	}

}