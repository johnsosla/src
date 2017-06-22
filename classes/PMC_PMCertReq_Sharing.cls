public class PMC_PMCertReq_Sharing {
    public static void handleSharingRules(Map<Id, PMCertReq__c> oldMap, Map<Id, PMCertReq__c> newMap, Boolean isInsert, Boolean isUpdate) {
        List<PMCertReq__share> newShares = new List<PMCertReq__share>();
        

        // Add read access to P&L manager, Sponsor, Interviewer, Candidate, Supervisor
        // Write access is accomplished by changing the owner ID (in visual flows)

        for (PMCertReq__c newRow : newMap.values()) {
            PMCertReq__c oldRow = isInsert ? null : oldMap.get(newRow.Id);
            List<Id> userIds = new List<Id>();

            // It's ok if these already exist -- we are allowing partial success below

            if (newRow.PLMgr__c != null && (isInsert || oldRow.PLMgr__c != newRow.PLMgr__c)) userIds.add(newRow.PLMgr__c);
            if (newRow.Sponsor__c != null && (isInsert || oldRow.Sponsor__c != newRow.Sponsor__c)) userIds.add(newRow.Sponsor__c);
            if (newRow.Interviewer__c != null && (isInsert || oldRow.Interviewer__c != newRow.Interviewer__c)) userIds.add(newRow.Interviewer__c);
            if (newRow.Candidate__c != null && (isInsert || oldRow.Candidate__c != newRow.Candidate__c)) userIds.add(newRow.Candidate__c);
            if (newRow.Candidate_Supervisor__c != null && (isInsert || oldRow.Candidate_Supervisor__c != newRow.Candidate_Supervisor__c)) userIds.add(newRow.Candidate_Supervisor__c);
            if (newRow.Delegated_Interviewer__c != null && (isInsert || oldRow.Delegated_Interviewer__c != newRow.Delegated_Interviewer__c)) userIds.add(newRow.Delegated_Interviewer__c);

            if (userIds.size() > 0) {
                for (Id userId : userIds) {
                    PMCertReq__share share  = new PMCertReq__share();
                    share.ParentId = newRow.Id;
                    share.UserOrGroupId = userId;
                    share.AccessLevel = 'Read';
                    share.RowCause = Schema.PMCertReq__share.RowCause.Full_Access__c;

                    if (userId == newRow.Delegated_Interviewer__c && newRow.CertificationRequestStatus__c == PMC_CertificationRequest.STATUS_SCHEDULE_INTERVIEW) {
                        share.AccessLevel = 'Edit';
                    }

                    newShares.add(share);
                }
            }
        }

        

        if (newShares.size() > 0) {
            List<Database.SaveResult> sr = Database.insert(newShares,false);
        }
    }
}