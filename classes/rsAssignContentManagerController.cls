public with sharing class rsAssignContentManagerController extends rsSectionController {

    private User mCurrentUser;
    private String mCMPhotoURL;

    public rsAssignContentManagerController() {
        super();
    }

    public User getCurrentUser() {
        if (mCurrentUser == null) {
            mCurrentUser = profile.getUser();
        }
        return mCurrentUser;
    }

    public override PageReference editPart() {
        enableEditMode();
        return null;
    }

    public override PageReference savePart() {
        try {
            profile.save();
            profile.refreshUser();
            mCurrentUser = profile.getUser();
        } catch (DmlException ex) {
            if(ex.getMessage().toLowerCAse().contains('circular')) {
                profile.setAssignedContentManagerId(null);
                return null;
            } else {
                throw ex;
            }
        }
        enableListMode();
        return null;
    }

    public override PageReference cancelPart() {
        // Re-query profile to re-populated assigned content manager with previous values.
        profile.refreshUser();
        mCurrentUser = (User)profile.getObj();

        enableListMode();
        return null;
    }

    public PageReference removeAssignedContentManger() {
        profile.setAssignedContentManagerId(null);
        profile.save();
        return savePart();
    }

    public String getCMPhotoURL() {
        mCMPhotoURL = null;
        if (getHasContentManagerAssigned()) {
            mCMPhotoURL = ConnectApi.ChatterUsers.getPhoto(null, profile.getAssignedContentManagerId()).smallPhotoUrl;
        }
        return mCMPhotoURL;
    }

    public Boolean getHasContentManagerAssigned() {
        return String.isNotBlank(profile.getAssignedContentManagerId());
    }

    public Boolean getIsOwner() {
        return getCurrentUser().Id == UserInfo.getUserId();
    }

}