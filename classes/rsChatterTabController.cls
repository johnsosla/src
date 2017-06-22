/*************************************************************************
*
* PURPOSE: Controller for base class that pages in chatter profile tabs will extend
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public virtual with sharing class rsChatterTabController {

    private Boolean mShowMessages;
    protected Id mUserId;
    private rsProfile mProfile;

    public rsChatterTabController() {
        mShowMessages = false;
        mUserId = ApexPages.currentPage().getParameters().get('sfdc.userId');
        if(mUserId == null) mUserId = UserInfo.getUserId();
        mProfile = rsProfile.find.byUserId(mUserId);
    }

    public Boolean getShowMessages() {
        if(mProfile.getUser().Is_Profile_Locked__c ) {
            String lockerUrl = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/' + mProfile.getUser().Profile_Reviewer__c;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, Label.Profile_Locked_By_CM + ' <a target="_blank" href="' + lockerUrl + '">' + mProfile.getUser().Profile_Reviewer__r.Name +' </a>'));
        }
        mShowMessages = !ApexPages.getMessages().isEmpty();
        return mShowMessages;
    }

    public Boolean getShowNoteToEmployee() {
        if(String.isNotBlank(getProfile().getNoteToEmployee()) && getIsOwnerOrContentManager()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, '<b>' + Schema.SObjectType.User.Fields.rs_Note_To_Employee__c.Label + '</b>: ' + getProfile().getNoteToEmployee()));
            return true;
        } else {
            return false;
        }
    }

    public Id getUserId() {
        return mUserId;
    }

    public rsProfile getProfile() {
        return mProfile;
    }

    public String getPhotoUrl() {
        return mProfile.getUser().SmallPhotoUrl;
    }

    public Boolean getIsSF1(){
        return !rsStringUtil.isNullOrEmpty(
                    ApexPages.currentPage().getParameters().get('sfone')
                );
    }

    public Boolean getIsOwnerOrContentManager() {
        return Profile_Info__c.getInstance().Is_Content_Manager__c
                            || ( UserInfo.getUserId() == mProfile.getId());
    }

    public Boolean getIsReadOnly() {
        return Profile_Info__c.getInstance(mUserId).Is_Read_Only__c;
    }

    public List<String> getUserIdList(){
        List<String> idList = new List<String>();
        idList.add(mUserId);
        return idList;
    }
}