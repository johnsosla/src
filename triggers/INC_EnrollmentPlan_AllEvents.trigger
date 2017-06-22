trigger INC_EnrollmentPlan_AllEvents on EnrollmentPlan__c (
    before insert, 
    before update, 
    before delete, 
    after insert, 
    after update, 
    after delete, 
    after undelete) {
        INC_EnrollmentPlanTriggers handler = new INC_EnrollmentPlanTriggers();
        boolean isTriggerEnabled = ECO_TriggerSettings.getIsTriggerEnabled('INC_EnrollmentPlan_AllEvents');
        //boolean bisRunning = false;
        System.Debug(logginglevel.error,'Trigger Running for Enrollment Plan');
        if(isTriggerEnabled){
            //bisRunning=true;
            if (Trigger.isBefore) {
                if(Trigger.isUpdate && INC_EnrollmentPlanTriggers.beforeRunOnce()){
                    System.debug(logginglevel.error,'creating createApprovalComments');
                    System.debug(logginglevel.error,'in Trigger Before update NSR: ' + trigger.New[0].NSRAdjustment__c);
                    handler.createEnrollmentCommentsFromExceptionandMA(trigger.new);
                    
                    System.debug(logginglevel.error,'CurrentForm owner');
                    handler.setIDOnStatusChange(trigger.newMap, trigger.OldMap);
                    handler.setSnapShotValues(trigger.NewMap,Trigger.OldMap);
                    System.debug(logginglevel.error, 'Setting user text fields');
                    handler.setUserTextFields(trigger.New,Trigger.OldMap);

                    //System.debug(logginglevel.error, '*** Update Setting project enrollment status');
                    //handler.setProjectEnrollmentStatus(Trigger.New, Trigger.OldMap);                    

                }else if(Trigger.isInsert){
                    System.debug(logginglevel.error, 'Setting user text fields insert');
                    handler.setUserTextFields(trigger.New,null);
                }
            }else{//end is before
                System.Debug(logginglevel.error,'After Update enrollment' + INC_EnrollmentPlanTriggers.afterRun);
                if(Trigger.isUpdate && INC_EnrollmentPlanTriggers.afterRunOnce()){
                    System.debug(logginglevel.error,'After update trigger EnrollmentPlan__c.');
                    handler.updateParticipants(Trigger.newMap, Trigger.oldMap);
                    
                    System.Debug(logginglevel.error,'createing createParticipantAcknowledgement');
                    handler.createParticipantAcknowledgement(Trigger.NewMap, Trigger.OldMap);
                    
                    //Move Into Handler ~ML
                    list<EnrollmentParticipant__c> lEnrollmentParticipantToUpdate = new list<EnrollmentParticipant__c>();
                    
                    for(EnrollmentParticipant__c oEnrollmentParticipant : [Select id, CalculatedIncentive__c, PaymentAdjustments__c
                                              From EnrollmentParticipant__c
                                              Where EnrollmentPlan__c =: Trigger.NewMap.keySet()]){
                                                  
                        oEnrollmentParticipant.PaymentAmount__c = ECO_Utils_String.NullCheck(oEnrollmentParticipant.CalculatedIncentive__c) + ECO_Utils_String.NullCheck(oEnrollmentParticipant.PaymentAdjustments__c);
                                                  
                        lEnrollmentParticipantToUpdate.add(oEnrollmentParticipant);
                    }
                    System.debug(logginglevel.error,'Updateing enr');
                    Try{
                        update lEnrollmentParticipantToUpdate;
                    }
                    catch(Exception e){
                        System.debug('Catching error ' +  e.getMessage());
                    }
                    System.Debug('finishenrollmentOfChangeRequest');
                    handler.finishenrollmentOfChangeRequest(trigger.newMap,trigger.oldMap);                
                }
                if(Trigger.isInsert) {
                    System.debug(logginglevel.error, '*** Insert Setting project enrollment status');
                    handler.setProjectEnrollmentStatus(Trigger.New, null);                    
                }
                if(Trigger.isUpdate){
                    System.debug(logginglevel.error, '*** Update Setting project enrollment status');
                    handler.setProjectEnrollmentStatus(Trigger.New, Trigger.OldMap);                                        
                }
                if(Trigger.isDelete){
                    System.debug(logginglevel.error, '*** Delete Setting project enrollment status');
                    handler.setProjectEnrollmentStatus(Trigger.Old, null);                                        
                }
            }
        }
}