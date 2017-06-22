/*******************************************************************************
*
* PURPOSE: Decorator for User object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/

public with sharing class GFA_User extends GFA_BaseModel {

    public static Finder find = new Finder('User');
    private static GFA_User mCurrentUser;

    public static final String ADMIN_PERMISSION_SET = 'GFA_Admins';
    public static final String APP_USER_PERMISSION_SET = 'GFA_App_Users';
    public static final String OTHER_USER_PERMISSION_SET = 'GFA_Other_Users';

    //---Permission set booleans

    private Boolean mIsAdminUser;
    private Boolean mIsAppUser;
    private Boolean mIsOtherUser;

    public User obj {
        get {
            return (User)mObj;
        }
    }

    public GFA_User(User u) {
        super(u);
        setupPermissionSetBooleans();
    }

    public static GFA_User getCurrentUser() {
        if (mCurrentUser == null) {
            mCurrentUser = find.findById(UserInfo.getUserId());
        }
        return mCurrentUser;
    }

    public static void clearCurrentUser() {
        mCurrentUser = null;
    }

    private void setupPermissionSetBooleans() {
        mIsAdminUser = false;
        mIsAppUser = false;
        mIsOtherUser = false;

        for (PermissionSetAssignment assign : [Select Id, PermissionSet.Name from PermissionSetAssignment where AssigneeId = : getId()]) {
            if (assign.PermissionSet.Name == ADMIN_PERMISSION_SET) {
                mIsAdminUser = true;
            } else if (assign.PermissionSet.Name == APP_USER_PERMISSION_SET) {
                mIsAppUser = true;
            } else if (assign.PermissionSet.Name == OTHER_USER_PERMISSION_SET) {
                mIsOtherUser = true;
            }
        }
    }

    public Boolean getIsAdminUser() {
        return mIsAdminUser;
    }
    
    public void setIsAdminUser() {
        if (Test.isRunningTest()) {
            mIsAdminUser = true;
        }
    }

    public Boolean getIsAppUser() {
        return mIsAppUser;
    }

    public Boolean getIsOtherUser() {
        return mIsOtherUser;
    }

    public GFA_FilterManager getParametersAsFilterManager() {
        return (GFA_FilterManager)JSON.deserialize(getParameters(), GFA_FilterManager.class);
    }
    public void setParameters(GFA_FilterManager filter) {
        setParameters(filter.serialize());
    }

    public String getParameters() {
        return obj.GFA_Filter_Parameters__c;
    }
    public void setParameters(String Parameters) {
        obj.GFA_Filter_Parameters__c = Parameters;
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
        }

        public GFA_User findById(Id userId) {
            User u = (User)byId(userId);
            return new GFA_User(u);
        }
    }
}