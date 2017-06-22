/*************************************************************************
*
* PURPOSE: Controller for personal information section
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public with sharing class rsPersonalController extends rsSectionController {
    private User mCurrentUser;
    private rsProfilePart mListHead;

    public rsPersonalController() {
        super();
        mRecordType = rsProfilePart.RT_PERSONAL;
    }

    public override PageReference editPart() {
        if( mListHead == null) {
            //This should only be entered the first time the user ever edits their personal information.
            //Everytime after this, we will just be adding a new node in the linked list
            super.newPart();
        } else {
            ApexPages.currentPage().getParameters().put('partId', mListHead.getId());
            super.editPart();
        }
        enableEditMode();
        return null;
    }

    public override PageReference savePart() {
        PageReference pr = super.savePart();
        profile.refreshUser();
        return pr;
    }


    public User getCurrentUser() {
        mCurrentUser = profile.getUser();
        return mCurrentUser;
    }

    public rsProfilePart getListHead() {
        mListHead = getParts().size() > 0 ? getParts().get(0) : new rsProfilePart(profile.getId(), mRecordType);
        CurrentPart = mListHead;
        return mListHead;
    }

    public Boolean getIsOwnerOrContentManager() {
        return Profile_Info__c.getInstance().Is_Content_Manager__c
                            || ( UserInfo.getUserId() == profile.getId());

    }

    public Boolean getIsContentManager() {
        return Profile_Info__c.getInstance().Is_Content_Manager__c;

    }
}