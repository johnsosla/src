public with sharing class INC_EnrollmentPlanTriggers {

    Private Static Boolean beforeRun = true;
    Public Static Boolean afterRun = true;
    
    Public Static Boolean beforeRunOnce() {
        if(beforeRun) {
            beforeRun = false;
            return true;
        }else {
            return beforeRun;
        }    
    }
    
    Public Static Boolean afterRunOnce() {
        if(afterRun) {
            afterRun = false;
            System.Debug(logginglevel.error,'afterRunOnce true');
            return true;
        }else {
        	System.Debug(logginglevel.error,'afterRunOnce false');
            return afterRun;
        }    
    }
    
	public INC_EnrollmentPlanTriggers() {}

	public void setIDOnStatusChange(map<id,EnrollmentPlan__c>mapNew, map<id,EnrollmentPlan__c>mapOld){
		set<id> setEP = new set<id>();
		System.Debug(logginglevel.error,'setIDOnStatusChange ' + mapnew + ' ' + mapold);
		for(EnrollmentPlan__c ep: mapNew.Values()){
			if(ep.EnrollmentStatus__c != mapOld.get(ep.id).EnrollmentStatus__c &&
				(ep.EnrollmentStatus__c == 'Rejected' || ep.EnrollmentStatus__c == 'Rejected for Correction')){
				setEP.add(ep.id);
			}
		}

		if(setEP != null && setEP.size() > 0){


			for(ProcessInstance pi: [Select id,LastActorId, TargetObjectId, (SELECT Id, ActorID, CreatedDate, StepStatus, Comments FROM Steps order by CreatedDate desc)
											  ,(SELECT Id, ActorId, ProcessInstanceId FROM Workitems)
											  ,(Select Id, ActorId, IsPending, StepStatus from StepsandWorkItems)
 				from ProcessInstance where TargetObjectId =: setEP]){
 								System.debug(logginglevel.error, 'pi: ' + pi.LastActorId);

 				
 				mapNew.get(pi.TargetObjectId).CurrentApprovalOwner__c = pi.Steps[0].ActorID;
 				
			}
		}
	}

	public void createEnrollmentCommentsFromExceptionandMA(list<EnrollmentPlan__c> listEnrollmentPlans){
		INC_Service_EnrollmentPlan.createEnrollmentcomment(listEnrollmentplans);
		for(EnrollmentPlan__c ep: listEnrollmentplans){
			ep.ExceptionComments__c = null;
			ep.MA_Comments__c = null;
		}
	}

	public void updateParticipants(map<id,EnrollmentPlan__c> mapNew, map<id,EnrollmentPlan__c> mapOld){
		set<id> enrollmentPlans = new set<id>();
		set<id> closedPlans = new set<id>();
		set<id> baselineGrossPlans = new set<id>();

		set<id> allPlans = new set<id>();
		for(EnrollmentPlan__c EnrollPlan: mapNew.Values()){
			System.debug(logginglevel.error,'Update Participants: ' + EnrollPlan.EnrollmentStatus__c);
			if(EnrollPlan.EnrollmentStatus__c == 'Enrolled' && 
				(EnrollPlan.EnrollmentStatus__c != mapOld.get(EnrollPlan.ID).EnrollmentStatus__c)){
				enrollmentPlans.add(EnrollPlan.ID);
				allPlans.add(EnrollPlan.ID);
			}
			if(EnrollPlan.EnrollmentStatus__c == 'Closed - No Award' &&
				(EnrollPlan.EnrollmentStatus__c != mapOld.get(EnrollPlan.ID).EnrollmentStatus__c)){
				closedPlans.add(EnrollPlan.id);
				allPlans.add(EnrollPlan.ID);
			}

			if((EnrollPlan.GrossMarginAmountScopeChange__c != mapOld.get(EnrollPlan.ID).GrossMarginAmountScopeChange__c)||
				(EnrollPlan.GrossMarginAmountAdjustment__c != mapOld.get(EnrollPlan.ID).GrossMarginAmountAdjustment__c)){
				baselineGrossPlans.add(EnrollPlan.ID);
				allPlans.add(EnrollPlan.ID);
			}


		}
		System.Debug(logginglevel.error,'Plans to fix participants ' + enrollmentPlans);
		if(allPlans != null && allPlans.size() > 0){
			list<EnrollmentParticipant__c> listUpdates = new list<EnrollmentParticipant__c>();
			Id readOnlyTypeId = ECO_Utils_sObject.getRecordTypeId(EnrollmentParticipant__c.sObjectType,'Read Only Participant');
			if(readOnlyTypeId == null){
               readOnlyTypeId = INC_Service_EnrollmentPlan.getRecordTypeId('EnrollmentParticipant__c', 'Read Only Participant');
        	}
			System.Debug(logginglevel.error,'Readonly ID ' + readOnlyTypeId);

			for(EnrollmentParticipant__c EP: [Select id
													   ,RecordTypeId
													   ,EnrollmentPlan__c
													   ,Closed_No_Award__c
													   ,Baseline_Margin_Change__c
				       						  From EnrollmentParticipant__c
				       						  Where EnrollmentPlan__c =: allPlans]){
				System.Debug(logginglevel.error,'Found participants: ' + EP);
				boolean bUpdated = false;
				if(enrollmentPlans.Contains(ep.EnrollmentPlan__c)){
					EP.RecordTypeId = readOnlyTypeId;
					bUpdated = true;
				}

				if(closedPlans.Contains(EP.EnrollmentPlan__c)){
					EP.Closed_No_Award__c = true;
					System.Debug(logginglevel.error,'Setting closed award to true. ' + ep);
					bUpdated = true;
				}

				if(baselineGrossPlans.Contains(EP.EnrollmentPlan__c)){
					EP.Baseline_Margin_Change__c = true;
					bUpdated = true;
				}

				if(bUpdated){
					listUpdates.add(EP);
				}
			}

			if(listUpdates != null && listUpdates.size() > 0){
				System.Debug(logginglevel.error,'Saving participants' + listUpdates.size());
				System.savePoint sp = Database.setSavePoint();
		        try{
		            Update listUpdates;
		        }catch(Exception e){
		            system.debug('Handling Exception:  '+e.getMessage() + ' ' + e.getStackTraceString());
		            system.debug(logginglevel.error, 'enrollmentPlan creation error: ' + e);
		            Database.rollBack(sp);
		        }
			}
		}
	}

	public void finishenrollmentOfChangeRequest(map<id,EnrollmentPlan__c>mapNew, map<id,EnrollmentPlan__c>mapOld){
		map<id,id> mapIncentiveByEnrollment = new map<id,id>();
		set<id> enrollmentAppsToUpdate = new set<id>();
		set<id> rejectedPlans = new set<id>();
		for(EnrollmentPlan__c enr: mapNew.Values()){
			if(enr.ApplicationType__c == 'CCR'){
				System.Debug('statuses: '+enr.NAME + ' ' + enr.EnrollmentStatus__c + ' ' + mapOld.get(enr.ID).EnrollmentStatus__c);
				if(enr.EnrollmentStatus__c == 'Enrolled' && mapOld.get(enr.ID).EnrollmentStatus__c != 'Enrolled'){
					if(mapNew.containsKey(enr.ParentApplication__c)){
						mapNew.get(enr.ParentApplication__c).EnrollmentStatus__c = 'Archived';
					}else{
						enrollmentAppsToUpdate.add(enr.ParentApplication__c);
					}
					mapIncentiveByEnrollment.put(enr.IncentiveProject__c,enr.Id);
				}else{
					if(enr.EnrollmentStatus__c == 'Rejected' && 
				  	(mapOld.get(enr.ID).EnrollmentStatus__c != 'Rejected')){
						rejectedPlans.add(enr.ID);
						mapIncentiveByEnrollment.put(enr.IncentiveProject__c,enr.Id);
					}
				}
			}
		}

		System.Debug('enrollmentAppsToUpdate ' + enrollmentAppsToUpdate);

		if(enrollmentAppsToUpdate != null && enrollmentAppsToUpdate.size()> 0){
			list<EnrollmentPlan__c> listEnrollments = new list<EnrollmentPlan__c>();
			for(EnrollmentPlan__c EP: [Select ID
												, EnrollmentStatus__c
									   From EnrollmentPlan__c
									   Where id In :enrollmentAppsToUpdate]){
				EP.EnrollmentStatus__c = 'Archived';
				listEnrollments.add(EP);
			}
			System.SavePoint sp = Database.setSavePoint();
			if(listEnrollments != null && listEnrollments.size() > 0){
				try{
					update listEnrollments;
				}catch(Exception E){
					System.Debug(logginglevel.error,'Problem updateing enrollmentPlans ' + e.getMessage());
				}
			}
		}

		if(mapIncentiveByEnrollment != null && mapIncentiveByEnrollment.size() > 0){
			list<IncentiveProject__c> listIncentive = new list<IncentiveProject__c>();
			for(IncentiveProject__c INC: [Select ID
												   , ChangeRequest__c
												   , EnrollmentPlan__c
										  From IncentiveProject__c
										  where ID =: mapIncentiveByEnrollment.KeySet()]){
				if(!rejectedPlans.Contains(mapIncentiveByEnrollment.get(INC.ID))){
					INC.EnrollmentPlan__c = mapIncentiveByEnrollment.get(INC.ID);
				}
				INC.ChangeRequest__c = null;
				listIncentive.add(INC);
			}
			System.SavePoint sp = Database.setSavePoint();
			if(listIncentive != null && listIncentive.size() > 0){
				try{
					update listIncentive;
				}catch(Exception E){
					System.Debug(logginglevel.error,'Problem updateing listIncentive ' + e.getMessage());
				}
			}
		}
	}
    
    public void setUserTextFields(List<EnrollmentPlan__c> newENR, map<ID,EnrollmentPlan__c> oldMap){
    	map<id,String> mapUserNames = new map<id,String>();
    	Set<id> setUsr = new set<id>();
    	for(EnrollmentPlan__c ePlan : newENR){
    		System.Debug(logginglevel.error,'Eplan: '  + Eplan + ' oldMap: ' + oldMap);
    		if(oldMap != null && oldMap.size() > 0){
    			if(ePlan.Approver1__c != oldMap.Get(eplan.id).Approver1__c){
    				setUsr.add(ePlan.Approver1__c);
    			}
    			if(ePlan.Approver2__c != oldMap.Get(eplan.id).Approver2__c){
    				setUsr.add(ePlan.Approver2__c);
    			}
    			if(ePlan.Approver3__c != oldMap.Get(eplan.id).Approver3__c){
    				setUsr.add(ePlan.Approver3__c);
    			}
    			if(ePlan.CurrentApprovalOwner__c != oldMap.Get(eplan.id).CurrentApprovalOwner__c){
    				setUsr.add(ePlan.CurrentApprovalOwner__c);
    			}
    			if(ePlan.DTWAdmin__c != oldMap.Get(eplan.id).DTWAdmin__c){
    				setUsr.add(ePlan.DTWAdmin__c);
    			}
    		}else{
    			setUsr.add(ePlan.Approver1__c);
    			setUsr.add(ePlan.Approver2__c);
    			setUsr.add(ePlan.Approver3__c);
    			setUsr.add(ePlan.CurrentApprovalOwner__c);
    			setUsr.add(ePlan.DTWAdmin__c);
    		}
    	}

    	System.Debug(logginglevel.error,'setUsr: ' + setUsr);

    	if(setUsr != null && setUsr.size() > 0){
    		for(User usr: [Select ID,FirstName,LastName from User where id =: setUsr]){
    			mapUserNames.put(usr.ID, usr.FirstName + ' ' + usr.LastName);
    		}
    	}

    	for(EnrollmentPlan__c enr: newENR){
    		if(mapUserNames.containsKey(enr.Approver1__c)){
    			enr.Approver1Name__c = mapUserNames.get(enr.Approver1__c);
    		}
    		if(mapUserNames.containsKey(enr.Approver2__c)){
    			enr.Approver2Name__c = mapUserNames.get(enr.Approver2__c);
    		}
    		if(mapUserNames.containsKey(enr.Approver3__c)){
    			enr.Approver3Name__c = mapUserNames.get(enr.Approver3__c);
    		}
    		if(mapUserNames.containsKey(enr.CurrentApprovalOwner__c)){
    			enr.CurrentApproverOwnerName__c = mapUserNames.get(enr.CurrentApprovalOwner__c);
    		}
    		if(mapUserNames.containsKey(enr.DTWAdmin__c)){
    			enr.DTWAdminName__c = mapUserNames.get(enr.DTWAdmin__c);
    		}
    	}
    }

    /**
     * This method is responsible for creating Participant Acknowledgement records
     * Work Item: WI-003593
     * Built By: Sanchivan Sivadasan 
     */
    public void createParticipantAcknowledgement(Map<Id, EnrollmentPlan__c> newMap, Map<Id, EnrollmentPlan__c> oldMap ) {
        System.Debug(logginglevel.error,'creating acknowledgements' + newMap);
        String sfMngr = null;
        Set<Id> ePlanIdsEnrolled = new Set<Id>();
        // Collect all Enrollments that are enrolled
        for(EnrollmentPlan__c ePlan : newMap.values()) {
            System.debug('Looping through Enrollment Plan');
            System.debug('ePlan.EnrollmentStatus__c:' + ePlan.EnrollmentStatus__c);
            System.debug('oldMap.get(ePlan.Id).EnrollmentStatus__c:' + oldMap.get(ePlan.Id).EnrollmentStatus__c);
            if(ePlan.EnrollmentStatus__c == 'Enrolled' && oldMap.get(ePlan.Id).EnrollmentStatus__c != 'Enrolled') {
                ePlanIdsEnrolled.add(ePlan.Id);
            }
        }
        System.Debug(logginglevel.error,'ePlanIdsEnrolled ' + ePlanIdsEnrolled);

        List<ParticipantAcknowledgement__c> participantAcknowledgementsToCreate = new List<ParticipantAcknowledgement__c>();
        
        //IF ccr Get a list of participants from parent apps
        list<id> listParentIDForCCR = new list<id>();
        for(EnrollmentPlan__c ep: newMap.Values()){
        	System.Debug(LoggingLevel.error,'ep check for ccr: ' + ep.ApplicationType__c);
        	if(EP.ApplicationType__c == 'CCR'){
        		listParentIDForCCR.add(EP.ParentApplication__c);
        	}
        }

        System.debug(logginglevel.error,'listParentIDForCCR: ' + listParentIDForCCR);

        map<String,EnrollmentParticipant__c> mapCurrentParticipantsByEmail = new map<String,EnrollmentParticipant__c>();
        if(listParentIDForCCR != null && listParentIDForCCR.size() > 0){
        	for(EnrollmentParticipant__c oEnrollmentParticipant: [Select ID
        																	, EmployeeName__r.Email
        																	, EmployeeName__r.pse__Salesforce_User__c
        																	, EmployeeName__r.pse__Salesforce_User__r.ManagerId
        																	, EmployeeStatus__c
        																	, TargetIncentivePoolAllocated__c
        																	, CurrencyISOCode
        																	, StartDateonProject__c
        																	, EndDateonProject__c
        																	, EnrollmentPlan__c
        																	From EnrollmentParticipant__c 
        																	where EnrollmentPlan__c =: listParentIDForCCR]){

        		mapCurrentParticipantsByEmail.put(oEnrollmentParticipant.EmployeeName__r.Email,oEnrollmentParticipant);
        																		
        	}
        }

        System.Debug(logginglevel.error,'mapCurrentParticipantsByEmail ' + mapCurrentParticipantsByEmail);
        // Retrieve all Enrollment Participants for the Enrolled Enrollments which has a Status of Active and Target Allocation > 0
        // Then prepare Participant Acknowledgement records that needs to be inserted
        map<Id,Id> mapAckKnowledgementToMoveByOriginalPartID = new map<Id,Id>();

        for(EnrollmentParticipant__c ePar : [SELECT Id
        											, EmployeeName__r.Email
        											, EmployeeName__r.pse__Salesforce_User__c 
        											, EmployeeName__r.pse__Salesforce_User__r.ManagerId
        											, EmployeeStatus__c
        											, TargetIncentivePoolAllocated__c
        											, CurrencyISOCode
        											, StartDateonProject__c
        											, EndDateonProject__c
        											, EnrollmentPlan__c
        											, ProjectEndDate__c
        									 FROM EnrollmentParticipant__c 
                                             WHERE EnrollmentPlan__c in : ePlanIdsEnrolled 
                                             AND EmployeeStatus__c = 'Active' 
                                             AND TargetIncentivePoolAllocated__c > 0
                                             AND EmployeeName__r.pse__salesforce_user__c != null]) {
        	System.Debug(logginglevel.error,'Found participant ' + ePar.EmployeeName__r.Email);
            ParticipantAcknowledgement__c pA = new ParticipantAcknowledgement__c();
			
            if(mapCurrentParticipantsByEmail != null && mapCurrentParticipantsByEmail.size() > 0){
            	if(mapCurrentParticipantsByEmail.containsKey(ePar.EmployeeName__r.Email)){

            		if(mapCurrentParticipantsByEmail.get(ePar.EmployeeName__r.Email).TargetIncentivePoolAllocated__c !=
            			ePar.TargetIncentivePoolAllocated__c){
            			System.Debug(logginglevel.error,'Part target not = old target: ' + epar.EmployeeName__r.Email);
            			//pA.RecordTypeId = Schema.SObjectType.ParticipantAcknowledgement__c.getRecordTypeInfosByName().get('Sent').getRecordTypeId();
						ID rectypeId = ECO_Utils_sObject.getRecordTypeId(ParticipantAcknowledgement__c.sObjectType,'Sent');
						if(rectypeId == null){
               				rectypeId = INC_Service_EnrollmentPlan.getRecordTypeId('ParticipantAcknowledgement__c', 'Sent');
        				}
						pA.RecordTypeId = rectypeId;
						pA.OwnerId = ePar.EmployeeName__r.pse__Salesforce_User__c;
                            
						sfMngr = ePar.EmployeeName__r.pse__Salesforce_User__r.ManagerId;
						if (String.IsBlank(sfMngr))
							//pA.Manager__c = null;
							pA.Manager__c = ePar.EmployeeName__r.pse__Salesforce_User__c ;
						else
							pA.Manager__c = sfMngr;                            
						//pA.Manager__c = ePar.EmployeeName__r.pse__Salesforce_User__r.ManagerId;
						pA.ParticipantID__c = ePar.Id;
						pA.CurrencyISOCode = ePar.CurrencyISOCode;
						pA.NotificationFlag__c = 'Change';	
						//pA.Approver1Email__c = ePar.Approver1__c;
						//pA.Enrollment_Application__c = ePar.EnrollmentPlan__c;
						/*pA.EnrollmentAppNameatSnapshot__c = ePar.EnrollmentAppName__c;
						pA.ProjectStartDateatSnapshot__c = ProjectStartDate__c;
						pA.ProjectEndDateatSnapshot__c = ePar.ProjectEndDate__c;
						pA.PotentialPayoutatSnapshot__c = ePar.PotentialPayout__c;
						pA.TargetAtSnapshot__c = ePar.Target__c;
						pA.ParticipantProjectEndDateSnapshot__c = ePar.
						pA.ParticipantProjectStartDateSnapshot__c
						*/
					}else{
            			System.Debug(logginglevel.error,'No change move acknowledgements: ' + epar.EmployeeName__r.Email);
            			mapAckKnowledgementToMoveByOriginalPartID.put(mapCurrentParticipantsByEmail.get(ePar.EmployeeName__r.Email).ID,ePar.ID);
            		}

            	}else{//new participant
            		pa.NotificationFlag__c = 'New';
            		//pA.RecordTypeId = Schema.SObjectType.ParticipantAcknowledgement__c.getRecordTypeInfosByName().get('Sent').getRecordTypeId();
					Id rectypeId = ECO_Utils_sObject.getRecordTypeId(ParticipantAcknowledgement__c.sObjectType,'Sent');
					if(rectypeId == null){
               			rectypeId = INC_Service_EnrollmentPlan.getRecordTypeId('ParticipantAcknowledgement__c', 'Sent');
        			}
					pA.RecordTypeId = rectypeId;
					pA.OwnerId = ePar.EmployeeName__r.pse__Salesforce_User__c;
					
					sfMngr = ePar.EmployeeName__r.pse__Salesforce_User__r.ManagerId;
					if (String.IsBlank(sfMngr))
						//pA.Manager__c = null;
						pA.Manager__c = ePar.EmployeeName__r.pse__Salesforce_User__c ;
					else
						pA.Manager__c = sfMngr;                    
                    //pA.Manager__c = ePar.EmployeeName__r.pse__Salesforce_User__r.ManagerId;
					pA.ParticipantID__c = ePar.Id;
					pA.CurrencyISOCode = ePar.CurrencyISOCode;	
            	}
            }else{
            	//new
            	pa.NotificationFlag__c = 'New';
            	//pA.RecordTypeId = Schema.SObjectType.ParticipantAcknowledgement__c.getRecordTypeInfosByName().get('Sent').getRecordTypeId();
				Id rectypeId = ECO_Utils_sObject.getRecordTypeId(ParticipantAcknowledgement__c.sObjectType,'Sent');
				if(rectypeId == null){
               		rectypeId = INC_Service_EnrollmentPlan.getRecordTypeId('ParticipantAcknowledgement__c', 'Sent');
        		}	
				pA.RecordTypeId = rectypeId;
				pA.OwnerId = ePar.EmployeeName__r.pse__Salesforce_User__c;
                
				sfMngr = ePar.EmployeeName__r.pse__Salesforce_User__r.ManagerId;
				if (String.IsBlank(sfMngr))
					//pA.Manager__c = null;
					pA.Manager__c = ePar.EmployeeName__r.pse__Salesforce_User__c ;
				else
					pA.Manager__c = sfMngr;	                
				//pA.Manager__c = ePar.EmployeeName__r.pse__Salesforce_User__r.ManagerId;
				pA.ParticipantID__c = ePar.Id;
				pA.CurrencyISOCode = ePar.CurrencyISOCode;
			}

            if(pa != null && pa.ParticipantID__c != null){    
            	System.Debug(logginglevel.error,'adding pa to list to create: ' + pa);                               
				participantAcknowledgementsToCreate.add(pA);
			}
        }
        
        List<ParticipantAcknowledgement__c> participantAcknowledgementsToUpdate = new list<ParticipantAcknowledgement__c>();
        System.Debug(logginglevel.error,'mapAckKnowledgementToMoveByOriginalPartID: ' + mapAckKnowledgementToMoveByOriginalPartID);
        if(mapAckKnowledgementToMoveByOriginalPartID != null && mapAckKnowledgementToMoveByOriginalPartID.size() > 0){
        	for(ParticipantAcknowledgement__c oAcknowledge : [Select Id
        															   ,EnrollmentApplicationID__c
        															   ,ParticipantID__c
        															from ParticipantAcknowledgement__c 
        															where ParticipantID__c =: mapAckKnowledgementToMoveByOriginalPartID.KeySet()]){
        		System.Debug(logginglevel.error,'oAcknowledge ' + oAcknowledge);
        		oAcknowledge.ParticipantID__c = mapAckKnowledgementToMoveByOriginalPartID.get(oAcknowledge.ParticipantID__c);
        		oAcknowledge.NotificationFlag__c = 'None';
        		participantAcknowledgementsToUpdate.add(oAcknowledge);
        		System.debug(logginglevel.error,'oAcknowledge after changes ' + oAcknowledge.ParticipantID__c);
        	}
        }

        // Create the Participant Acknowledgements
        System.debug(logginglevel.error,'participantAcknowledgementsToCreate ' + participantAcknowledgementsToCreate.size());
        System.debug(logginglevel.error,'participantAcknowledgementsToUpdate: ' + participantAcknowledgementsToUpdate);
        if((participantAcknowledgementsToCreate != null && participantAcknowledgementsToCreate.size() > 0) || 
        	participantAcknowledgementsToUpdate != null && participantAcknowledgementsToUpdate.size() > 0) {
            System.Debug(logginglevel.error,'Creating participant acknowledgements' + participantAcknowledgementsToCreate.size());
            System.savePoint sp = Database.setSavePoint();
            
            try{
            	System.Debug(logginglevel.error,'Inserting acknowledgements');
                
                if(participantAcknowledgementsToCreate != null && participantAcknowledgementsToCreate.size() > 0){
                	Insert participantAcknowledgementsToCreate;
            	}
                
                System.debug(logginglevel.error,'Updating acknowledgements');
                
                if(participantAcknowledgementsToUpdate != null && participantAcknowledgementsToUpdate.size() > 0){
                	update participantAcknowledgementsToUpdate;
                }
 				set<string> sPAid = new set<string>();

 				for(ParticipantAcknowledgement__c p: participantAcknowledgementsToCreate){
 					if(p.id != null){
 							sPAid.add(p.id);
 					}
            	}

            	if(sPAid.size() >0){
            		INC_EnrollmentLetterAttach.attachEnrollmentLetter(sPAid);
            	}

            }catch(Exception e){
                system.debug('Handling Exception:  ' + e.getMessage() + ' ' + e.getStackTraceString());
                system.debug(logginglevel.error, 'participant acknowledgement creation error: ' + e);
                Database.rollBack(sp);
            }
        }
    }	

    public void setSnapShotValues(Map<Id, EnrollmentPlan__c> mapNew, Map<Id, EnrollmentPlan__c> mapOld){
    	set<id> setReQueryPlans = new set<id>();
    	System.Debug(logginglevel.error,'mapNew: ' + mapNew);
    	System.Debug(logginglevel.error,'mapOld: ' + mapold);
    	for(EnrollmentPlan__c EP: mapNew.Values()){
    		if((EP.EnrollmentStatus__c == 'Enrolled' && mapOld.get(EP.ID).EnrollmentStatus__c != 'Enrolled')){
    			if(EP.ApplicationType__c=='ENR'){// || (EP.ApplicationType__c == 'CCR' && EP.IncentivePlanContractType__c == 'Fixed Price')){
    				setReQueryPlans.add(EP.ID);
    			}
    		}
    	}

    	//requery plans to get cross object values for snapshots
    	if(setReQueryPlans != null && setReQueryPlans.size() > 0){
    		for(EnrollmentPlan__c EP: [Select ID
    										, GrossMarginAmountScopeChange__c
    										, GrossMarginAmountAdjustment__c
    										, GrossMarginAdjustment__c
    										, NSRAdjustment__c
    										, DTWComplete__c
    										, ApprovedSubsODC__c
    										, BaselineGrossMargin__c
    										, BaselineGrossRevenue__c
    										, BaselineGMofNSR__c
    										, BaselineGrossRevenueSnapshot__c
    										, BaselineMarginofNSRatSnapshot__c
    										, BaselineNSRatSnapshot__c
    										, BaselineDPEatSnapshot__c
    										, ITDCostCompleteatSnapshot__c
    										, DTWCompleteSnapshot__c
    										, BaselineNSR__c
    										, BaselineDPE__c
    										, IncentiveProject__r.ApprovedNetMarginBudget__c 
    										, IncentiveProject__r.ApprovedGrossMarginBudget__c
    										, IncentiveProject__r.ApprovedNSRBudget__c
    										, IncentivePlan__r.ContractSubType__c
    										, IncentiveProject__r.ApprovedGrossRevenueBudget__c
    										, IncentiveProject__r.ApprovedODCBudget__c
    										, IncentiveProject__r.ApprovedSubsBudget__c
    										, IncentiveProject__r.ApprovedContingencyBudget__c
    										, IncentiveProject__r.ApprovedDPEBudget__c
    										, IncentiveProject__r.ApprovedGrossMarginofNSR__c
    										, IncentiveProject__r.ApprovedNMofNSR__c
    										, IncentiveProject__r.ActualPercentProjectCompleteITD__c
    										From EnrollmentPlan__c where id =: setReQueryPlans]){

				mapNew.get(EP.ID).ApprovedRevenueBudgetatSnapshot__c = EP.IncentiveProject__r.ApprovedGrossRevenueBudget__c;
    			mapNew.get(EP.ID).ApprovedSubsBudgetatSnapshot__c = EP.IncentiveProject__r.ApprovedSubsBudget__c;
    			mapNew.get(EP.ID).ApprovedODCBudgetatSnapshot__c = EP.IncentiveProject__r.ApprovedODCBudget__c;
    			mapNew.get(EP.ID).ApprovedContingencyBudgetatsnapshot__c = EP.IncentiveProject__r.ApprovedContingencyBudget__c;
				mapNew.get(EP.ID).ApprovedNSRBudgetatSnapshot__c = EP.IncentiveProject__r.ApprovedNSRBudget__c;
    			mapNew.get(EP.ID).ApprovedDPEBudgetatSnapshot__c = EP.IncentiveProject__r.ApprovedDPEBudget__c;
    			mapNew.get(EP.ID).ApprovedGrossMarginBudgetatSnapshot__c = EP.IncentiveProject__r.ApprovedGrossMarginBudget__c;
    			mapNew.get(EP.ID).ApprovedGrossMarginofNSRatSnapshot__c = EP.IncentiveProject__r.ApprovedGrossMarginofNSR__c;
    			mapNew.get(EP.ID).ApprovedNetMarginBudgetatSnapshot__c = EP.IncentiveProject__r.ApprovedNetMarginBudget__c;
    			mapNew.get(EP.ID).ApprovedNetMarginofNSRatSnapShot__c = EP.IncentiveProject__r.ApprovedNMofNSR__c;
    			mapNew.get(EP.ID).DTWCompleteSnapshot__c = EP.DTWComplete__c;
    			
    			if(EP.IncentivePlan__r.ContractSubType__c == 'Gross Margin'){
    				mapNew.get(EP.ID).BaselineGrossMarginatSnapshot__c = EP.BaselineGrossMargin__c;
    			}else{
					mapNew.get(EP.ID).BaselineNetMarginatSnapshot__c = EP.BaselineGrossMargin__c;
				}

				mapNew.get(EP.ID).BaselineGrossRevenueSnapshot__c = EP.BaselineGrossRevenue__c;
				mapNew.get(EP.ID).BaselineMarginofNSRatSnapshot__c = EP.BaselineGMofNSR__c;
    			mapNew.get(EP.ID).BaselineNSRatSnapshot__c = EP.BaselineNSR__c;
    			mapNew.get(EP.ID).BaselineDPEatSnapshot__c = EP.BaselineDPE__c;
    			mapNew.get(EP.ID).ITDCostCompleteatSnapshot__c = EP.IncentiveProject__r.ActualPercentProjectCompleteITD__c;
    		}
    	}
    }

    public void setProjectEnrollmentStatus(List<EnrollmentPlan__c> newENR, Map<Id, EnrollmentPlan__c> oldMap){
		list<IncentiveProject__c> projectsToUpdate = new list<IncentiveProject__c>();		
        list<EnrollmentPlan__c> enrollmentPlans = new list<EnrollmentPlan__c>();
    	if(oldMap != null && oldMap.size() > 0) {
    		for(EnrollmentPlan__c p: newENR){
    			if(p.EnrollmentStatus__c != oldMap.get(p.ID).EnrollmentStatus__c){
                	enrollmentPlans.add(p);
            	}
            }
        } else {
        	enrollmentPlans = newENR;
        }
    	for(EnrollmentPlan__c plan : enrollmentPlans){
			set<String> enrPlans = new set<String>();
			set<String> ccrPlans = new set<String>();
			set<String> payPlans = new set<String>();
			EnrollmentPlan__c latestPlan = new EnrollmentPlan__c();
			Integer i = 0;
		    String projectEnrollmentStatus;
    		for(EnrollmentPlan__c EP : [Select ID
    			                              ,ApplicationType__c
										      ,EnrollmentStatus__c
										      ,Name
									    From  EnrollmentPlan__c
 									    Where IncentiveProject__c = :plan.IncentiveProject__c
 									    Order By CreatedDate Desc]){
    			if (i == 0) {
    				latestPlan = EP;
    				i++;
    			}
    			if (EP.ApplicationType__c == 'ENR' && !enrPlans.contains(EP.EnrollmentStatus__c)) {
    			    System.Debug(logginglevel.error,'*** in ENR Add ');
    				enrPlans.add(EP.EnrollmentStatus__c);
    			} else if (EP.ApplicationType__c == 'CCR' && !ccrPlans.contains(EP.EnrollmentStatus__c)) {
    				ccrPlans.add(EP.EnrollmentStatus__c);
				} else if (EP.ApplicationType__c == 'PAY' && !payPlans.contains(EP.EnrollmentStatus__c)) {
    				payPlans.add(EP.EnrollmentStatus__c);
				} 
	    	}
		    		
		    if (payPlans.size() > 0 && (payPlans.contains('Closed') || payPlans.contains('Closed - No Award'))) {
	    		projectEnrollmentStatus = payPlans.contains('Closed') ? 'Closed' : 'Closed - No Award';
		    } else if ((ccrPlans.size() > 0 && ccrPlans.contains('Enrolled')) || (enrPlans.size() > 0 && enrPlans.contains('Enrolled'))) {
		    		projectEnrollmentStatus = 'Enrolled';
		    } else {
		    	projectEnrollmentStatus = latestPlan.EnrollmentStatus__c;
		    }
    		IncentiveProject__c project = [Select ID, ProjectEnrollmentStatus__c
										   From  IncentiveProject__c
	 									   Where ID =: plan.IncentiveProject__c];
		    project.ProjectEnrollmentStatus__c = projectEnrollmentStatus;
    		projectsToUpdate.add(project);
    	}
    	if (projectsToUpdate.size() > 0)
    		update projectsToUpdate;
    }










































}