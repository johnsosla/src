trigger INC_Participant_AllEvents on EnrollmentParticipant__c (
    after insert, 
    after update, 
    after delete) {

        if (Trigger.isafter && Trigger.isupdate) {
            INC_ParticipantTrigger.CheckChanges(trigger.new, trigger.oldMap);
        }

        if (Trigger.isafter && Trigger.isinsert) {
            INC_ParticipantTrigger.HandleParticipantAddDelete(trigger.new);
        }

        if (Trigger.isafter && Trigger.isdelete) {
            INC_ParticipantTrigger.HandleParticipantAddDelete(trigger.old);
        }
}