trigger ECO_User_AllEvents on User (before insert, before update) {
    if (trigger.isBefore) {
        if (trigger.isInsert) {
            ECO_UserTriggers.setDefaultInformation(trigger.new);
        } else if (trigger.isUpdate) {
            ECO_UserTriggers.setDefaultInformation(trigger.new);
        }
    }
}