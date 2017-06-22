/*************************************************************************
*
* PURPOSE: Controller for profile proxy section
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public with sharing class rsProfileProxyController extends rsSectionController {

    private User mCurrentUser;
    private String mProxyPhotoUrl;
    private Boolean mHasProxy;
    private Id mOldProxy;

    public rsProfileProxyController() {
        super();
    }

    public override PageReference editPart() {
        mOldProxy = mCurrentUser.Profile_Proxy__c;
        enableEditMode();
        return null;
    }
    public override PageReference cancelPart() {
        mCurrentUser = (User)rsProfile.find.byId(profile.getId()).getObj();
        enableListMode();
        return null;
    }
    public override PageReference savePart() {
        Boolean isURS = Profile_Info__c.getInstance(mCurrentUser.Profile_Proxy__c).Is_Read_Only__c;
        if(mCurrentUser.Profile_Proxy__c != null) {
            profile.setDateProxyAdded(Date.today());
        }
        try {
            if(!isURS) {
            //TODO -- this needs to be fixed.. I just realized what
            //a horrible thing I've done here. Right now I'm relying on the
            //fact that mCurrentUser and profile are are pointing to the
            //same reference to the same user and that modifying
            //mCurrentUser and then calling profile.save() actually
            //works this needs to be changed so that we are only
            //screwing around with rsProfile profile. I'm sorry everyone.

                mCurrentUser.Last_Profile_Proxy__c = mOldProxy;
                if(mOldProxy != mCurrentUser.Profile_Proxy__c && mCurrentUser.Profile_Proxy__c != null) {
                    //If a person is assigned as profile proxy, application needs to
                    //send an email notification to that person and the profile owner.
                    mCurrentUser.Send_Proxy_Notification__c = 'Change';
                    mCurrentUser.Profile_Proxy_Email__c
                        = [select Email from User where Id =: mCurrentUser.Profile_Proxy__c].Email;

                }
                else if(mOldProxy != null && mCurrentUser.Profile_Proxy__c == null) {
                    //If a an existing profile proxy is unassigned, application needs to send
                    //an email notification to the profile owner only
                    mCurrentUser.Send_Proxy_Notification__c = 'Removal';
                }
                else {
                    mCurrentUser.Send_Proxy_Notification__c = null;
                }
                profile.save();
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Read_Only_Proxy_Error));
                return null;
            }
        } catch (DmlException dmlEx) {
            if (dmlEx.getMessage().toLowerCase().contains('circular') ) {
                    mCurrentUser.Profile_Proxy__c = null;
                    return null;
                }
                else throw dmlEx;
        }
        enableListMode();
        return null;
    }
    public User getCurrentUser(){
        if(mCurrentUser == null) {
            mCurrentUser = profile.getUser();
        }
        return mCurrentUser;
    }

    public String getProxyPhotoUrl() {
        mProxyPhotoUrl = null;
        if(getHasProxy() ) {
            mProxyPhotoUrl = ConnectApi.ChatterUsers.getPhoto(null,getCurrentUser().Profile_Proxy__c).smallPhotoUrl;
        }
        return mProxyPhotoUrl;
    }

    public Boolean getHasProxy() {
        mHasProxy = getCurrentUser().Profile_Proxy__c != null;
        return mHasProxy;
    }

    public Boolean getIsOwner() {
        return getCurrentUser().Id == UserInfo.getUserId();
    }

    public PageReference removeProxy() {
        mOldProxy = mCurrentUser.Profile_Proxy__c;
        mCurrentUser.Profile_Proxy__c = null;
        profile.setDateProxyAdded(null);
        return savePart();
    }
}