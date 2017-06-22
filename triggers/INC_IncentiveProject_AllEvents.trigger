trigger INC_IncentiveProject_AllEvents on IncentiveProject__c (before insert,before Update,after insert, after update) {

    INC_IncentiveProject_Triggers handler = new INC_IncentiveProject_Triggers();
    boolean isTriggerEnabled = ECO_TriggerSettings.getIsTriggerEnabled('INC_IncentiveProject_AllEvents');
    boolean bisRunning = false;
    
    System.Debug(logginglevel.error,'Trigger Running for IncentiveProject before: ' + Trigger.isBefore + ' Insert: ' + Trigger.isInsert);
    
    if(!bisRunning && isTriggerEnabled){
        bisRunning=true;
        if (Trigger.isBefore) {
            
            if(Trigger.isUpdate){
                handler.checkForKeyMetricChanges(Trigger.newMap, Trigger.oldMap);
            }
            
        }else{//end is before
            if(Trigger.isInsert){
                //  System.Debug(logginglevel.error,'After Insert IncentiveProject');
                // handler.AssignDTWAdmin(Trigger.newMap.KeySet());
            }
        }
        
        if (Trigger.isAfter && Trigger.isUpdate) {
            handler.checkForBaselineChanges(Trigger.newMap, trigger.oldMap);
            //the code below doesn't work for formula fields, at least in determining if the field value has changed
            //the field doesn't show a change.  
            system.debug('Re-evaluate Enrollment Plans');
            
            set<Id> lIncentiveProjectIds = new set<Id>();
            
            for(IncentiveProject__c oIncentiveProject : trigger.new){
                if((oIncentiveProject.EnrollmentPlan__c == trigger.oldMap.get(oIncentiveProject.Id).EnrollmentPlan__c)&&
                   (oIncentiveProject.ChangeRequest__c == trigger.oldMap.get(oIncentiveProject.id).ChangeRequest__c)&&
                   (oIncentiveProject.PaymentRequest__c == trigger.oldMap.get(oIncentiveProject.id).PaymentRequest__c)){
                         lIncentiveProjectIds.add(oIncentiveProject.Id);
                }
            }
            
            list<EnrollmentPlan__c> lEnrollmentPlans = new list<EnrollmentPlan__c>([SELECT 
                                                                                     Id
                                                                                   FROM
                                                                                     EnrollmentPlan__c
                                                                                   WHERE
                                                                                     IncentiveProject__c in :lIncentiveProjectIds]);
            
            system.debug(lEnrollmentPlans);
            
            try{
                update lEnrollmentPlans;
                }Catch(Exception e){
                    //most likely a self reference error when setting parent id on ip.  No need to update project anyway
                    System.Debug('logging error: ' + e.getMessage());
                }
        }
    }
}