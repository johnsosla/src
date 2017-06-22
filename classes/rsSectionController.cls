public virtual with sharing class rsSectionController {

    public rsProfile profile {get; set;}

    public rsProfilePart CurrentPart {get; set;}
    private rsProfilePart mOldPart {get; set;}

    protected String mRecordType;
    protected Boolean mIsError;

    private Boolean mEditMode;
    private Boolean mListMode;
    private Boolean mViewMode;
    private Boolean mCanEdit;


    //--PAGINATION VARIABLES
    private Integer mViewLimit;
    private Integer RESULT_LIMIT = 10;
    public Integer PageNum {get; set;}
    public Integer TotalParts {get; set;}
    private List<rsProfilePart> allParts;
    private List<rsViewModel> allViewModels;
    public Integer ViewIndex {get; set;}

    //--SORT VARIABLES
    private String mLastSortedBy;
    private String mSortOrder;

    public virtual PageReference editPart() {
        for (rsProfilePart part : profile.getProfileParts()) {
            if (part.getId() == ApexPages.currentPage().getParameters().get('partId')) {
                if (part.getObj().get('Status__c') != rsProfilePart.S_INREVIEW || (UserInfo.getUserId() == profile.getProfileReviewer() ) ) {
                    enableEditMode();
                    mOldPart = part;
                    CurrentPart = new rsProfilePart((rs_Profile_Part__c)part.getObj().clone(true, true, false, false));
                } else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'This record is under review and is not currently editable'));
                }
                break;
            }
        }
        System.assert(CurrentPart != null);
        return null;
    }

    public virtual PageReference newPart() {
        mIsError = false;
        System.assert(mRecordType != null);
        CurrentPart = new rsProfilePart(profile.getId(), mRecordType);
        CurrentPart.setInitialLocale(UserInfo.getLocale() );
        enableEditMode();
        return null;
    }

    public virtual PageReference cancelPart() {
        mIsError = false;
        CurrentPart = null;
        mOldPart = null;
        enableListMode();
        return null;
    }

    //Returns true if there is anything at all in
    //the sfone query paramter
    /*public static Boolean getIsSF1(){
        return !rsStringUtil.isNullOrEmpty(
                    ApexPages.currentPage().getParameters().get('sfone')
                );

    }*/

    public Boolean getIsSF1() {
        return !rsStringUtil.isNullOrEmpty(
                   ApexPages.currentPage().getParameters().get('sfone')
               );

    }

    protected virtual User getUser() {

        return [Select Id, Is_Profile_Locked__c, Geography__c,
                Date_Time_Sent_for_Review__c, Profile_Reviewer__c, Status__c
                from User where id = :profile.getId()].get(0);

    }

    public virtual PageReference savePart() {
        savePart(false);
        return null;
    }

    public virtual PageReference savePart(Boolean saveAndApprove) {
        mIsError = false;
        //First check if their profile has been locked while they were editing this part, unless they are a content manager that locked it, in which case they can save just fine
        User profileRequery = getUser();
        String oldStatus = CurrentPart.getStatus();

        if (profileRequery.Profile_Reviewer__c != UserInfo.getUserId() && profileRequery.Is_Profile_Locked__c ) {
            String lockerUrl = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/' + profile.getUser().Profile_Reviewer__c;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, Label.Profile_Locked_By_CM + ' <a target="_blank" href="' + lockerUrl + '">' + profile.getUser().Profile_Reviewer__r.Name + ' </a>'));
            return null;
        }

        //check to make sure this part isn't already in the list otherwise we get display duplicates on edit
        Boolean isExistingPart = false;
        Integer i = -1;
        for (rsProfilePart part : profile.getProfileParts()) {
            i++;
            //If it's our current part OR it's our previous part (this case happens when we save and validation fails and our CurrentPart doesn't have an ID yet but is still should be existing part)
            if (part.getId() == CurrentPart.getId() || (CurrentPart.getId() == null && mOldPart != null && part.getId() == mOldPart.getId()) ) {
                isExistingPart = true;
                break;
            }
        }

        //If the status is pending then we'll just save our changes on the old record, no reason to clone
        if (isExistingPart && !mOldPart.getIsPendingOrInReview() ) {
            rs_Profile_Part__c clone = (rs_Profile_Part__c)CurrentPart.getObj().clone(false, true, false, false);
            clone.Previous_Part__c = CurrentPart.getId();
            CurrentPart = new rsProfilePart(clone);
        }

        try {
            setFieldsForSave(CurrentPart, profileRequery, saveAndApprove);
            CurrentPart.save();
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
            CurrentPart.setStatus(oldStatus);
            System.debug ('!!Exception on profile part save. ' + ex + ex.getStackTraceString());
            return null;
        }

        //Now that we've saved it, we want to put the forward pointer on the old part (if it already existed)
        if (isExistingPart && !mOldPart.getIsPendingOrInReview()) {
            profile.getProfileParts().remove(i);
            if (mOldPart.getId() != CurrentPart.getId()) {
                mOldPart.setNextPart(CurrentPart.getId() );
                //if we have already approved our current part (either CM saved it or non reviewable, then archive the old one)
                if (CurrentPart.getStatus() == rsProfilePart.S_APPROVED) {
                    mOldPart.setStatus(rsProfilePart.S_ARCHIVED);
                }
            }
            try {
                mOldPart.save();
            } catch (DmlException ex) {
                ApexPages.addMessages(ex);
                System.debug ('!!Exception on old profile part save. ' + ex + ex.getStackTraceString());
                return null;
            }
        }

        if (!isExistingPart || (isExistingPart && !mOldPart.getIsPendingOrInReview() ) ) {
            profile.getProfileParts().add(CurrentPart);
        } else { //Else we'll just replace the object in the list with updated object
            profile.getProfileParts().set(i, CurrentPart);
        }
        reorderProjectParts();
        mOldPart = null;
        enableListMode();

        updateUserProfileTimestamps();

        return null;
    }

    //---This will update the user timestamps
    public void updateUserProfileTimestamps() {
        //---Update last modified data on User
        User targetUser = [Select Id, Last_User_Profile_Update__c, Last_CM_Profile_Update__c from User where id = :profile.getId()];

        if (profile.getId() == UserInfo.getUserId()) {
            targetUser.Last_User_Profile_Update__c = DateTime.now();
        }

        try {
            rsDataUtils.save(targetUser);
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
            System.debug ('!!Exception on profile part save, User DateTime update. ' + ex + ex.getStackTraceString());
        }
    }

    public void setFieldsForSave(rsProfilePart profilePart, User currentUser, Boolean saveAndApprove) {
        setTrackingFields();
        if (isReviewable(mRecordType, currentUser) || (!saveAndApprove && profilePart.getIsPendingOrInReview())) {
            profilePart.setDateTimeSentForReview( Datetime.now() );
            if(String.isNotBlank(profile.getAssignedContentManagerId())) {
                profile.setProfileReviewer(profile.getAssignedContentManagerId());
            }
            if (currentUser.Date_Time_Sent_for_Review__c == null) {
                profile.setDateTimeSentforReview(Datetime.now());
                profile.setStatus(rsProfile.S_PENDING);
            }
            profile.save();
            profilePart.setStatus(rsProfilePart.S_PENDING);
        } else {
            rsApprovalUtil.approvePart((rs_Profile_Part__c)profilePart.getObj(), profile);
        }
    }

    public void setTrackingFields() {
        profile.setProfileUpdated(true);
        profile.setDateTimeLastUpdated(DateTime.now());
        if (UserInfo.getUserId() == profile.getId() ) {
            profile.setLastUpdatedBy(Label.Owner);
        } else if (UserInfo.getUserId() == profile.getProfileProxy()) {
            profile.setLastUpdatedBy(Label.Profile_Proxy);
        } else if (Profile_Info__c.getInstance().Is_Content_Manager__c) {
            profile.setLastUpdatedBy(Label.Content_Manager);
        }
        profile.save();
    }


    public virtual PageReference saveAndApprove() {
        savePart(true);
        return null;
    }

    public virtual PageReference deletePart() {
        List<rsProfilePart> parts = profile.getProfileParts();
        rsProfilePart part = null;
        Boolean keepUserLocked = false;
        Integer partIndex = null;
        for (Integer i = 0; i < parts.size(); i++) {
            if (parts[i].getId() == ApexPages.currentPage().getParameters().get('partId')) {
                partIndex = i;
                if (profile.getStatus() == rsProfile.S_INREVIEW || profile.getStatus() == rsProfile.S_PENDING) {
                    keepUserLocked = profile.shouldProfileStayLocked( parts[i].getId() );
                }
                break;
            }
        }
        part = parts.remove(partIndex);
        reorderProjectParts((Integer)part.getPartSequence());
        if (!keepUserLocked) {
            profile.setLock(false);
            profile.setDateTimeSentforReview(null);
            profile.setStatus(rsProfile.S_APPROVED);
            profile.setProfileReviewer(null);
            profile.save();
        }

        //If this part is (pending or in review) and it has a previously approved part, before we delete this one, we archive the old one, so neither will show up in the list.
        if ( (part.getStatus() == rsProfilePart.S_PENDING || part.getStatus() == rsProfilePart.S_INREVIEW) && (part.getPreviousPart() != null) ) {
            rsProfilePart previousPart = new rsProfilePart( (rs_Profile_Part__c)rsProfilePart.find.byId(part.getPreviousPart()).getObj());
            previousPart.setStatus(rsProfilePart.S_ARCHIVED);
            previousPart.save();
        }
        if(getCanEdit() && part.getOwnerId() != UserInfo.getUserId()) {
            part.setOwnerId(UserInfo.getUserId());
            part.save();
        }
        part.destroy();
        enableListMode();
        //Go back to Previous Page if current page has all parts deleted
        if (getViewParts().size() == 0) {
            getPreviousPage();
        }
        return null;
    }

    public virtual PageReference viewPart() {
        for (rsProfilePart part : profile.getProfileParts()) {
            if (part.getId() == ApexPages.currentPage().getParameters().get('partId')) {
                enableViewMode();
                CurrentPart = part;
                break;
            }
        }

        return null;
    }

    public List<rsProfilePart> getParts() {
        return profile.getPartsByType(mRecordType);
    }

    public rsSectionController() {
        mEditMode = false;
        mViewMode = false;
        mListMode = true;
        mIsError = false;

        //--Pagination stuff
        ViewIndex = 0;
        mViewLimit = RESULT_LIMIT;
        if (PageNum == null) {
            PageNum = 1;
        }
    }

    public void enableViewMode() {
        mViewMode = true;
        mEditMode = false;
        mListMode = false;
    }

    public void enableEditMode() {
        mViewMode = false;
        mEditMode = true;
        mListMode = false;
    }

    public void enableListMode() {
        mViewMode = false;
        mEditMode = false;
        mListMode = true;
    }

    public Boolean getIsViewMode() {
        return mViewMode;
    }

    public Boolean getIsListMode() {
        return mListMode;
    }

    public Boolean getIsEditMode() {
        return mEditMode;
    }

    /* A user can edit if they are one of the following
    - A Content Manager
    - The user that this profile is for (self)
    - The proxy for the user this profile is for (proxy)
    AND
    The profile isn't locked by a CM (Is_Profile_Locked__c)

    OR
    if the profile is locked and the current viewer is the current assignee
    */
    public Boolean getCanEdit() {
        mCanEdit =  (   (
                            Profile_Info__c.getInstance().Is_Content_Manager__c
                            || ( UserInfo.getUserId() == profile.getId()    )
                            || ( UserInfo.getUserId() == profile.getObj().get('Profile_Proxy__c') )
                        )
                        &&
                        ( !profile.getUser().Is_Profile_Locked__c )
                    )
                    ||
                    (
                        profile.getUser().Is_Profile_Locked__c
                        && (UserInfo.getUserId() == profile.getObj().get('Profile_Reviewer__c') )
                    );
        return mCanEdit;
    }

    //If the user saving is a content manager then we don't need CM review
    public Boolean isReviewable(String type, User currentUser) {
        rs_Review_Exception__c cmException
            = rs_Review_Exception__c.getValues(currentUser.Geography__c);

        //If we found an exception in custom settings OR if their geography is null and we have a custom setting with "null"
        //then we shouldn't force a review
        if ( cmException != null || ( !String.isNotBlank(currentUser.Geography__c) && rs_Review_Exception__c.getInstance('null') != null ) ) {
            return false;
        }

        if (Profile_Info__c.getInstance().Is_Content_Manager__c) {
            return false;    //---Skip Review if they are a Content Manager
        }

        rsProfile currUser = new rsProfile(currentUser);
        Boolean val = false;
        val =   (
                    type == rsProfilePart.RT_EDUCATION || type == rsProfilePart.RT_PROF_AFFILIATION ||
                    type == rsProfilePart.RT_TRAINING || type == rsProfilePart.RT_AWARD ||
                    type == rsProfilePart.RT_PUBLICATION || type == rsProfilePart.RT_REGISTRATION ||
                    type == rsProfilePart.RT_CERTIFICATION ||  type == rsProfilePart.RT_PERSONAL ||
                    type == rsProfilePart.RT_REFERENCE ||
                    type == rsPRTeamEmployee.RT_AECOMPROJECT || type == rsPRTeamEmployee.RT_NONAECOMPROJECT
                ) &&
                (
                    //If they're a CM saving, then it is not reviewable UNLESS the entire profile is in status in review or pending
                    !Profile_Info__c.getInstance().Is_Content_Manager__c || ( Profile_Info__c.getInstance().Is_Content_Manager__c && (currUser.getStatus() == rsProfile.S_INREVIEW || currUser.getStatus() == rsProfile.S_PENDING) )
                );
        return val;
    }

    //Boolean to show the line item approve in wrench menu
    public Boolean getIsApprovable() {
        return Profile_Info__c.getInstance().Is_Content_Manager__c && (UserInfo.getUserId() == profile.getProfileReviewer() ) && profile.getLock();
    }

    public virtual PageReference approvePart() {
        String partId = ApexPages.currentPage().getParameters().get('partId');
        for (rsProfilePart profilePart : profile.getProfileParts() ) {
            if (profilePart.getId() == partId) {
                rsApprovalUtil.approvePart((rs_Profile_Part__c)profilePart.getObj(), profile);
                break;
            }
        }
        return null;
    }


    //--PAGINATION METHODS

    public List<rsViewModel> getViewParts() {
        String sortField = ApexPages.currentPage().getParameters().get('sortField');
        String pageChange = ApexPages.currentPage().getParameters().get('pageChange');
        if (sortField == null && pageChange == null) {
            allViewModels = new List<rsViewModel>();

            for (rsProfilePart part : profile.getPartsByType(mRecordType)) {
                allViewModels.add(new rsViewModel(part));
            }
        }

        if (TotalParts != null && TotalParts < allViewModels.size()) {
            //new record was added, update ViewLimit
            if (TotalParts > 0 && mViewLimit > 0 && mViewLimit < RESULT_LIMIT * PageNum) {
                if ( (Math.mod(TotalParts, mViewLimit) < RESULT_LIMIT && Math.mod(TotalParts, mViewLimit) > 0) || (PageNum == getNumberOfPages() && Math.mod(TotalParts, RESULT_LIMIT) > 0) ) {
                    ++mViewLimit;
                }
            }
        }

        TotalParts = allViewModels.size();
        if (TotalParts < mViewLimit || (TotalParts > 0 && mViewLimit == 0) ) {
            mViewLimit = TotalParts;
        }
        List<rsViewModel> viewParts = new List<rsViewModel>();

        if (allViewModels != null && !allViewModels.isEmpty()) {
            for (Integer i = ViewIndex; i < mViewLimit; i++) {
                viewParts.add(allViewModels[i]);
            }
        }

        return viewParts;
    }

    public Integer getNumberOfPages() {
        return (Integer)Math.ceil((1.0 * TotalParts) / RESULT_LIMIT);
    }

    public PageReference getNextPage() {

        if (PageNum < getNumberOfPages()) {
            PageNum++;
            if (PageNum == getNumberOfPages()) {
                ViewIndex += RESULT_LIMIT;
                mViewLimit += (mViewLimit + Math.mod(TotalParts, mViewLimit));
            } else {
                ViewIndex += RESULT_LIMIT;
                mViewLimit += RESULT_LIMIT;
            }
        }

        return null;
    }

    public PageReference getPreviousPage() {
        Integer lastPageNum = PageNum;

        if (PageNum > 1) {
            PageNum--;
            if (PageNum > 1 && PageNum < getNumberOfPages()) {
                if (lastPageNum == getNumberOfPages()) {
                    //mViewLimit -= RESULT_LIMIT-1;
                    if (Math.mod(TotalParts, mViewLimit) > 0) {
                        mViewLimit -= (Math.mod(TotalParts, mViewLimit) + 1);
                    } else if (Math.mod(TotalParts, RESULT_LIMIT) > 0) {
                        mViewLimit -= Math.mod(TotalParts, RESULT_LIMIT);
                    } else {
                        mViewLimit -= RESULT_LIMIT;
                    }
                } else {
                    mViewLimit -= RESULT_LIMIT;
                }
                ViewIndex -= RESULT_LIMIT;
            } else if (PageNum > 1 && PageNum == getNumberOfPages()) {
                ViewIndex -= RESULT_LIMIT;
                mViewLimit -= (RESULT_LIMIT + Math.mod(TotalParts, mViewLimit));
            } else if (PageNum == 1) {
                ViewIndex = 0;
                mViewLimit = RESULT_LIMIT;
            }
        }

        return null;
    }

    public Integer getViewLimit() {
        return this.mViewLimit;
    }

    public void setViewLimit(Integer viewLimit) {
        mViewLimit = viewLimit;
    }

    public PageReference getFirstPage() {

        if (PageNum > 1) {
            ViewIndex = 0;
            mViewLimit = RESULT_LIMIT;
            PageNum = 1;
        }

        return null;
    }

    public PageReference getLastPage() {

        if ( PageNum < getNumberOfPages() && (TotalParts - Math.mod(TotalParts, mViewLimit) > 0) ) {
            if (Math.mod(TotalParts, mViewLimit) == 0) {
                ViewIndex = TotalParts - RESULT_LIMIT;
            } else {
                ViewIndex = TotalParts - Math.mod(TotalParts, mViewLimit);
            }
            mViewLimit = TotalParts;
            PageNum = getNumberOfPages();
        }

        return null;
    }

    public Integer getResultLimit() {
        return RESULT_LIMIT;
    }
    public void setResultLimit(Integer newLimit) {
        RESULT_LIMIT = newLimit;
    }

    //--END PAGINATION METHODS

    //--START SORTING LOGIC
    public String getSortOrder() {
        return mSortOrder;
    }
    public void setSortOrder(String order) {
        mSortOrder = order;
    }

    public String getLastSortedBy() {
        return mLastSortedBy;
    }
    public void setLastSortedBy(String sortedBy) {
        mLastSortedBy = sortedBy;
    }

    public virtual PageReference sortParts() {
        String sortField = ApexPages.currentPage().getParameters().get('sortField');
        if (sortField != null) {

            if (this.mSortOrder == null || sortField != this.mLastSortedBy) {
                this.mSortOrder = 'asc';
                rsViewModel.SortOrder = 'asc';
            }

            rsViewModel.SortField = sortField;
            if (this.mLastSortedBy != null) {
                if (sortField == this.mLastSortedBy) {
                    if (this.mSortOrder == 'asc') {
                        this.mSortOrder = 'desc';
                        rsViewModel.SortOrder = 'desc';
                    } else {
                        this.mSortOrder = 'asc';
                        rsViewModel.SortOrder = 'asc';
                    }
                }
            }
            allViewModels.sort();
            this.mLastSortedBy = sortField;
            Integer i = 0;
            for (rsViewModel model : allViewModels) {
                model.getProfilePart().setPartSequence(i);
                i++;
            }
        }
        return null;
    }
    //--END SORTING LOGIC

    public PageReference deleteAttachment() {
        String attachmentId = ApexPages.currentPage().getParameters().get('attachmentId');
        String partId = ApexPages.currentPage().getParameters().get('partId');
        if (attachmentId != null && partId != null) {
            delete [select Id from Attachment where Id = :attachmentId];
            for (rsProfilePart part : profile.getProfileParts()) {
                if (part.getId() == partId) {
                    part.setAttachmentId(null);
                    part.setAttachmentName(null);
                    part.save();
                    break;
                }
            }
        }

        return null;
    }

    //Moves a profile part one higher
    public PageReference movePartUp() {
        reorderProjectParts();
        String partId = ApexPages.currentPage().getParameters().get('partId');
        Integer originalPlace = 0;
        rsProfilePart tempProfilePart;

        List<rsProfilePart> profileParts = profile.getPartsByType(mRecordType);

        for (Integer i = 0; i < profileParts.size(); i++) {
            rsProfilePart part = profileParts.get(i);
            if (part.getId() == partId) {
                originalPlace = i;
                tempProfilePart = part;
                break;
            }
        }
        if (originalPlace <= 0) {
            return null;
        }
        //Updating Part Sequence
        profileParts.get(originalPlace).setPartSequence(originalPlace - 1);
        profileParts.get(originalPlace - 1).setPartSequence(originalPlace);

        profileParts.set(originalPlace, profileParts.get(originalPlace - 1));
        profileParts.set(originalPlace - 1, tempProfilePart);

        //reorderGrouping();
        try {
            rsModel.save(profileParts);
        } catch (DmlException ex) {
            System.debug('!! Exception saving project parts :' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Past_Record_Exception));
        }
        return null;
    }

    //Moves a Project within a profile part one lower
    public PageReference movePartDown() {
        reorderProjectParts();
        String partId = ApexPages.currentPage().getParameters().get('partId');
        Integer originalPlace = 0;
        rsProfilePart tempProfilePart;

        List<rsProfilePart> profileParts = profile.getPartsByType(mRecordType);

        for (Integer i = 0; i < profileParts.size(); i++) {
            rsProfilePart part = profileParts.get(i);
            if (part.getId() == partId) {
                originalPlace = i;
                tempProfilePart = part;
                break;
            }
        }
        while ((originalPlace + 1) >= profileParts.size() && originalPlace > 0) {
            originalPlace--;
        }
        //Updating Part Sequence
        profileParts.get(originalPlace).setPartSequence(originalPlace + 1);
        profileParts.get(originalPlace + 1).setPartSequence(originalPlace);

        profileParts.set(originalPlace, profileParts.get(originalPlace + 1));
        profileParts.set(originalPlace + 1, tempProfilePart);

        try {
            rsModel.save(profileParts);
        } catch (DmlException ex) {
            System.debug('!! Exception saving project parts :' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Past_Record_Exception));
        }
        return null;
    }

    private void reorderProjectParts() {
        List<rsProfilePart> profileParts = profile.getPartsByType(mRecordType);
        Integer nullCount = 0;
        Set<Id> partIds = new Set<Id>();
        for (rsProfilePart part : profileParts) {
            if (part.getPartSequence() == null) {
                part.setPartSequence(nullCount);
                nullCount++;
                partIds.add(part.getId());
            }
        }
        for (rsProfilePart part : profileParts) {
            if (!partIds.contains(part.getId())) {
                part.setPartSequence(part.getPartSequence() + nullCount);
            }
        }
        try {
            rsModel.save(profileParts);
        } catch (DmlException ex) {
            System.debug('!! Exception saving project parts :' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
    }

    private void reorderProjectParts(Integer removeIndex) {
        List<rsProfilePart> profileParts = profile.getPartsByType(mRecordType);
        for (rsProfilePart part : profileParts) {
            if (part.getPartSequence() > removeIndex) {
                part.setPartSequence(part.getPartSequence() - 1);
            }
        }
        try {
            rsModel.save(profileParts);
        } catch (DmlException ex) {
            System.debug('!! Exception saving project parts :' + ex);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
    }

}