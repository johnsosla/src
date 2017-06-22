/*************************************************************************
*
* PURPOSE: Util methods for approving Profile Part and PR Team records
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public class rsApprovalUtil {

    //This will approve an entire profile
    //pass in the two lists of parts & projects that are pending/in review
    public static void approveProfile(rsProfile profile, List<rs_Profile_Part__c> partsToBeApproved, List<rsPRTeamEmployee> projectsToBeApproved) {
        if (partsToBeApproved != null && partsToBeApproved.size() > 0) {
            for (rs_Profile_Part__c profilePart : partsToBeApproved){
                profilePart.Status__c = rsProfilePart.S_APPROVED;
                rsProfilePart part = new rsProfilePart(profilePart);
                if(part.isType(rsProfilePart.RT_PERSONAL)) {
                    //update all of the user fields
                    profile.getObj().put('Resume_Name__c', part.getResumeName() );
                    profile.getObj().put('Resume_Title__c', part.getResumeTitle() );
                    profile.getObj().put('Years_with_Other_Firms__c', part.getYearsWithOtherFirms() );
                    profile.getObj().put('Bio__c', part.getBio() );
                }
            }
        }
        if(projectsToBeApproved != null && projectsToBeApproved.size() > 0) {
            for (rsPRTeamEmployee profileProject : projectsToBeApproved){
                profileProject.setStatus(rsPRTeamEmployee.S_APPROVED);
            }
        }

        updatePreviousParts(partsToBeApproved);
        updatePreviousProjects(projectsToBeApproved);

        update partsToBeApproved;
        rsModel.save(projectsToBeApproved);

        profile.setLock(false);
        profile.setDateTimeSentforReview(null);
        profile.setStatus(rsProfile.S_APPROVED);
        profile.setProfileReviewer(null);
        profile.save();
    }

    //Lock profile and move parts/projects to 'In Review' status
    public static void startReview(rsProfile profile, List<rs_Profile_Part__c> partsToBeApproved, List<rsPRTeamEmployee> projectsToBeApproved) {
        if(partsToBeApproved != null && partsToBeApproved.size() > 0) {
            for (rs_Profile_Part__c profilePart : partsToBeApproved){
                profilePart.Status__c = rsProfilePart.S_INREVIEW;
            }
        }
        if(projectsToBeApproved != null && projectsToBeApproved.size() > 0) {
            for (rsPRTeamEmployee profileProject : projectsToBeApproved){
                profileProject.setStatus(rsPRTeamEmployee.S_INREVIEW);
            }
        }

        update partsToBeApproved;
        rsModel.save(projectsToBeApproved);

        profile.setLock(true);
        profile.setStatus(rsProfile.S_INREVIEW);
        profile.save();
    }

    //Unlock profile and move parts/projects to 'Pending' status
    public static void stopReview(rsProfile profile, List<rs_Profile_Part__c> partsToBeApproved, List<rsPRTeamEmployee> projectsToBeApproved) {
        if (partsToBeApproved != null && partsToBeApproved.size() > 0) {
            for (rs_Profile_Part__c profilePart : partsToBeApproved){
                profilePart.Status__c = rsProfilePart.S_PENDING;
            }
        }
        if(projectsToBeApproved != null && projectsToBeApproved.size() > 0) {
            for (rsPRTeamEmployee profileProject : projectsToBeApproved){
                profileProject.setStatus(rsPRTeamEmployee.S_PENDING);
            }
        }

        update partsToBeApproved;
        rsModel.save(projectsToBeApproved);

        profile.setLock(false);
        profile.setStatus(rsProfile.S_PENDING);
        profile.save();
    }


    //Approve a single part
    public static void approvePart(rs_Profile_Part__c partToBeApproved, rsProfile profile){
        rsProfilePart part = new rsProfilePart(partToBeApproved);
        if(part.isType(rsProfilePart.RT_PERSONAL)) {
            //update all of the user fields
            profile.getObj().put('Resume_Name__c', part.getResumeName() );
            profile.getObj().put('Resume_Title__c', part.getResumeTitle() );
            profile.getObj().put('Years_with_Other_Firms__c', part.getYearsWithOtherFirms() );
            profile.getObj().put('Bio__c', part.getBio() );
            profile.save();
        }

        partToBeApproved.Status__c = rsProfilePart.S_APPROVED;
        updatePreviousParts(new List<rs_Profile_Part__c>{partToBeApproved} );
        upsert partToBeApproved;
        checkLock(profile, partToBeApproved.Id );
    }

    //Approve a single project part
    public static void approveProjectPart(rsPRTeamEmployee projectToBeApproved, rsProfile profile){
        projectToBeApproved.setStatus(rsPRTeamEmployee.S_APPROVED);
        updatePreviousProjects(new List<rsPRTeamEmployee>{projectToBeApproved} );
        projectToBeApproved.save();
        checkLock(profile, projectToBeApproved.getId() );
    }

    //Before a list of items or a single item is approved, we want to archive the old version first
    public static void updatePreviousParts(List<rs_Profile_Part__c> profileParts) {
        List<Id> previousPartIds = new List<Id>();
        for (rs_Profile_Part__c currRec : profileParts) {
            if (currRec.Previous_Part__c != null) {
                previousPartIds.add(currRec.Previous_Part__c);
            }
        }
        if(previousPartIds.size() > 0) {
            List<rs_Profile_Part__c> previousPartSaveList = rsProfilePart.find.byIdList(previousPartIds);
            for(rs_Profile_Part__c part : previousPartSaveList) {
                part.Status__c = rsProfilePart.S_ARCHIVED;
            }
            update previousPartSaveList;
        }
    }

    //Before a list of items or a single item is approved, we want to archive the old version first
    public static void updatePreviousProjects(List<rsPRTeamEmployee> projects) {
        List<Id> previousProjectList = new List<Id>();
        for (rsPRTeamEmployee currRec : projects) {
            if (currRec.getPreviousProjectPart() != null) {
                previousProjectList.add(currRec.getPreviousProjectPart());
            }
        }
        if (previousProjectList.size() > 0) {
            List<rsPRTeamEmployee> previousProjSaveList = rsPRTeamEmployee.find.byIdList(previousProjectList);
            for(rsPRTeamEmployee prevProject : previousProjSaveList) {
                prevProject.setProjectId(null);
                prevProject.getPRObj().ChkUniqueEmp__c = null;
                prevProject.setStatus(rsPRTeamEmployee.S_ARCHIVED);
            }
            rsModel.save(previousProjSaveList);
        }
    }

    //If the user has no more items in pending or in review, then this method will unlock them
    private static void checkLock(rsProfile profile, Id partId) {
        if (!profile.shouldProfileStayLocked(partId)) {
            //This means we just approved the final part that the user had, therefore we should unlock and clear the time the user was sent for review
            profile.setLock(false);
            profile.setDateTimeSentforReview(null);
            profile.setStatus(rsProfile.S_APPROVED);
            profile.setProfileReviewer(null);
            profile.save();
        }
    }
}