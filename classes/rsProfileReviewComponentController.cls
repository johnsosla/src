public with sharing class rsProfileReviewComponentController {

    public List<Id> ProfileIds {get; set;}
    public List<Id> ProjectIds {get; set;}
    public String ViewType {get; set;}
    public String sortDir {get; set;}
    public String sortVal {get; set;}
    public String projWhere {get; set;}
    public String partWhere {get; set;}

    private Map <Id, List<rs_Profile_Part__c>> mUserProfilePartMap;
    private Map <Id, List<rsPRTeamEmployee>> mUserProjectMap;
    private Map <Integer, Id> mSortedUserMap;

    private Map<Id, String> mRtMap;
    private Map<Id, User> mUserMap;

    private Boolean mShowStatus;
    private Boolean mShowCurrentAssignee;
    private Boolean mIsReassign;
    private Boolean mShowAssignAction;
    private Boolean mShowActions;
    private Boolean mShowAssignToMe;


    private Integer counter; // current offset of the searchResults
    private static final Integer RESULT_SIZE = 5; //number of rows shown in the result table

    private static final Map<Id, Schema.RecordTypeInfo> mProfilePartRTInfo;
    static {
        mProfilePartRTInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosById();
    }
    private static final Map<Id, Schema.RecordTypeInfo> mPRTeamEmployeeRTInfo;
    static {
        mPRTeamEmployeeRTInfo = PR_Team_Employee__c.SObjectType.getDescribe().getRecordTypeInfosById();
    }
    public rsProfileReviewComponentController() {
        mUserMap = new Map<Id, User>();
        mRtMap = new Map<Id, String>();
        mSortedUserMap = new Map<Integer, Id>();
        counter = 0;
    }

    public Map<Id, String> getProfileRtMap() {
        if (mRtMap.isEmpty()) {
            for (Id key : mProfilePartRTInfo.keySet()) {
                mRtMap.put(key, mProfilePartRTInfo.get(key).getName());
            }
            for (Id key : mPRTeamEmployeeRTInfo.keySet()) {
                mRtMap.put(key, mPRTeamEmployeeRTInfo.get(key).getName());
            }
        }
        return mRtMap;
    }

    public Map<Integer, Id> getSortedUserMap() {
        if (mSortedUserMap.isEmpty()) {
            createSortedMap(new Set<Id>());
        }
        System.debug('####: ' + mSortedUserMap.size());
        return mSortedUserMap;
    }

    private void removeAssignToFromSortMap(Id assignToMe) {
        mSortedUserMap.clear();
        createSortedMap(new Set<Id> {assignToMe});
    }

    private void createSortedMap(Set<Id> ignoreIds) {
        Integer i = 0;
        Set<Id> addedIds = ignoreIds;
        for (Id userId : ProfileIds) {
            if (!addedIds.contains(userId)) {
                addedIds.add(userId);
                mSortedUserMap.put(i, userId);
                i++;
            }
        }
        for (Id userId : ProjectIds) {
            if (!addedIds.contains(userId)) {
                addedIds.add(userId);
                mSortedUserMap.put(i, userId);
                i++;
            }
        }
    }

    //List of users used in main apex repeat, is filtered by getViewResults() method for pagination
    public List<rsUserViewModel> getUserList() {
        List<User> tempUserList = getUserMap().values();
        List<rsUserViewModel> mUserList = new List<rsUserViewModel>();
        for (User tempUser : tempUserList) {
            mUserList.add(new rsUserViewModel(tempUser));
        }
        rsUserViewModel.SortField = sortVal;
        rsUserViewModel.SortOrder = sortDir;
        mUserList.sort();
        return mUserList;
    }

    public Map<Id, User> getUserMap() {

        Set<Id> userIdSet = new Set<Id>();
        for (Integer i = counter; i < counter + RESULT_SIZE; i++) {
            userIdSet.add(getSortedUserMap().get(i));
        }

        Set<String> fieldsSelect = new Set<String> {'Profile_Reviewer__c', 'Profile_Reviewer__r.Name', 'Name', 'FirstName', 'LastName', 'Manager.Name',
                'Geography__c', 'Region__c', 'Country', 'Office__c', 'Email',
                'Business_Line__c', 'Date_Time_Sent_For_Review__c', 'Is_profile_locked__c', 'Status__c'
                                                   };
        mUserMap = rsProfile.find.byUserIdSetMinFields( userIdSet, fieldsSelect );
        return mUserMap;
    }

    //Builds map of key user with value being a list of all that users' profile parts
    public Map <Id, List<rs_Profile_Part__c>> getUserProfilePartMap() {
        Set<Id> userIds = getUserMap().keySet();
        mUserProfilePartMap = new Map <Id, List<rs_Profile_Part__c>>();
        for (Id userId : userIds) {
            mUserProfilePartMap.put(userId, new List<rs_Profile_Part__c>());
        }
        //--- TODO figure out a better way when to append User__r.
        for (rs_Profile_Part__c profile : rsProfilePart.find.byUsersWhereAndOrder(userIds, partWhere, sortVal != 'Date_Time_Sent_For_Review__c' ? 'User__r.' + sortVal : sortVal, sortDir)) {
            mUserProfilePartMap.get(profile.User__c).add(profile);
        }
        return mUserProfilePartMap;
    }

    //Builds map of key user with value being a list of all that users' projects
    public Map <Id, List<rsPRTeamEmployee>> getUserProjectMap() {
        Set<Id> userIds = getUserMap().keySet();
        mUserProjectMap = new Map <Id, List<rsPRTeamEmployee>>();
        for (Id userId : userIds) {
            mUserProjectMap.put(userId, new List<rsPRTeamEmployee>());
        }
        //--- TODO figure out a better way when to append EmployeeUser__r.
        for (rsPRTeamEmployee project : rsPRTeamEmployee.find.byUsersWhereAndOrder(userIds, projWhere, sortVal != 'Date_Time_Sent_For_Review__c' ? 'EmployeeUser__r.' + sortVal : sortVal, sortDir)) {
            mUserProjectMap.get(project.getUser()).add(project);
        }
        return mUserProjectMap;
    }


    public Boolean getShowStatus() {
        mShowStatus = (ViewType != rsProfileReviewsController.REV_COMPLETED);
        return mShowStatus;
    }
    public Boolean getShowCurrentAssignee() {
        mShowCurrentAssignee = (ViewType == rsProfileReviewsController.REV_ASSIGNED);
        return mShowCurrentAssignee;
    }
    public Boolean getIsReassign() {
        mIsReassign = (ViewType == rsProfileReviewsController.REV_ASSIGNED || ViewType == rsProfileReviewsController.REV_ASSIGNEDTOME);
        return mIsReassign;
    }
    public Boolean getShowAssignAction() {
        mShowAssignAction = (ViewType != rsProfileReviewsController.REV_COMPLETED);
        return mShowAssignAction;
    }
    public Boolean getShowActions() {
        mShowActions = (ViewType == rsProfileReviewsController.REV_ASSIGNEDTOME);
        return mShowActions;
    }
    public Boolean getShowAssignToMe() {
        mShowAssignToMe = (ViewType == rsProfileReviewsController.REV_UN_AMERICAS ||
                           ViewType == rsProfileReviewsController.REV_UN_AMERICAS_CS ||
                           ViewType == rsProfileReviewsController.REV_UN_APAC ||
                           ViewType == rsProfileReviewsController.REV_UN_CORPORATE_VAL ||
                           ViewType == rsProfileReviewsController.REV_UN_EMEA ||
                           ViewType == rsProfileReviewsController.REV_UN_GLOBAL_IT ||
                           ViewType == rsProfileReviewsController.REV_UN_MS_VAL ||
                           ViewType == rsProfileReviewsController.REV_ALL_PENDING
                          );
        return mShowAssignToMe;
    }

    public PageReference assign() {
        PageReference pr = null;
        pr = Page.rsAssignProfileReview;
        pr.getParameters().put('userId', ApexPages.currentPage().getParameters().get('userId') );
        pr.getParameters().put('type', ViewType);
        return pr;
    }

    public PageReference assignToMe() {
        String userId = ApexPages.currentPage().getParameters().get('userId');
        if ( !Profile_Info__c.getInstance(UserInfo.getUserId()).Is_Content_Manager__c ) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Not_Content_Manager));
        } else if (userId == UserInfo.getUserId() ) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Cant_Review_Self));
        } else {
            User employee = mUserMap.get(userId);
            employee.Profile_Reviewer__c = UserInfo.getUserId();
            try {
                rsDataUtils.save(employee);
                removeAssignToFromSortMap(userId);
            } catch (DmlException ex) {
                System.debug('!! Exception Assigning to self :' + ex);
                ApexPages.addMessages(ex);
            }
        }
        return null;
    }

    public PageReference viewProfile() {
        PageReference pr = null;
        pr = new PageReference('/' + ApexPages.currentPage().getParameters().get('userId') );
        pr.getParameters().put('tab', 'Personal');
        return pr;
    }

    //A parameterized action used on commandLinks to perform actions on a collection of profile parts
    //ActionTypes available:
    // 'approve' - Will approve all of the profile parts that are in the user's profile part map & unlock profile & clear date/time when review started
    // 'startReview' - Will lock the profile and set profile part statuses to 'in review'
    // 'stopReview' - Opposite of startReview
    public PageReference updatePartsStatus() {
        String userId = ApexPages.currentPage().getParameters().get('userId');
        String actionType = ApexPages.currentPage().getParameters().get('actionType');
        User currUser = mUserMap.get(userId);
        List<rs_Profile_Part__c> userParts = mUserProfilePartMap.get( userId );
        List<rsPRTeamEmployee> userProjects = mUserProjectMap.get( userId );
        rsProfile profile = new rsProfile(currUser);

        if (actionType == 'approve') {
            rsApprovalUtil.approveProfile(profile, userParts, userProjects);
            removeAssignToFromSortMap(userId);
        } else if (actionType == 'startReview') {
            rsApprovalUtil.startReview(profile, userParts, userProjects);
        } else if (actionType == 'stopReview') {
            rsApprovalUtil.stopReview(profile, userParts, userProjects);
        }
        return null;
    }

    public PageReference approvePart() {
        String userId = ApexPages.currentPage().getParameters().get('userId');
        String partId = ApexPages.currentPage().getParameters().get('partId');
        rsProfile profile = new rsProfile(mUserMap.get(userId));

        List<rs_Profile_Part__c> userParts = mUserProfilePartMap.get( userId );
        Boolean allPartApproved = true;
        Boolean allProjApproved = true;
        if (userParts != null) {

            for (rs_Profile_Part__c profilePart : userParts) {
                if (profilePart.Id == partId) {
                    rsApprovalUtil.approvePart(profilePart, profile);
                } else if ( profilePart.Status__c != rsProfilePart.S_APPROVED) {
                    allPartApproved = false;
                }
            }
        }

        List<rsPRTeamEmployee> userProjects = mUserProjectMap.get( userId );

        if (userProjects != null) {
            for (rsPRTeamEmployee profileProject : userProjects) {
                if (profileProject.getId() == partId) {
                    rsApprovalUtil.approveProjectPart(profileProject, profile);
                } else if (profile.getStatus() != rsPRTeamEmployee.S_APPROVED) {
                    allProjApproved = false;
                }
            }
        }
        if (allProjApproved && allPartApproved) {
            removeAssignToFromSortMap(userId);
        }
        return null;
    }

    public PageReference navToPart() {
        String userId = ApexPages.currentPage().getParameters().get('userId');
        String partId = ApexPages.currentPage().getParameters().get('partId');
        String recordTypeName = ApexPages.currentPage().getParameters().get('recordTypeName');

        PageReference pr = new PageReference('/' + userId);

        //Find out what page we are taking them to
        if (recordTypeName.equalsIgnoreCase(rsProfilePart.RT_PERSONAL)) {
            pr.getParameters().put('tab', 'Personal');
        } else if (recordTypeName.equalsIgnoreCase(rsPRTeamEmployee.RT_AECOMPROJECT) || recordTypeName.equalsIgnoreCase(rsPRTeamEmployee.RT_NONAECOMPROJECT)) {
            pr.getParameters().put('tab', 'Projects');
            if (recordTypeName.equalsIgnoreCase(rsPRTeamEmployee.RT_AECOMPROJECT)) {
                pr.getParameters().put('tab.Projects.subtab', '0');
            } else if (recordTypeName.equalsIgnoreCase(rsPRTeamEmployee.RT_NONAECOMPROJECT)) {
                pr.getParameters().put('tab.Projects.subtab', '1');
            }
        } else if (recordTypeName.equalsIgnoreCase(rsProfilePart.RT_SF254) || recordTypeName.equalsIgnoreCase(rsProfilePart.RT_SF330) ||
                   recordTypeName.equalsIgnoreCase(rsProfilePart.RT_AWARD) || recordTypeName.equalsIgnoreCase(rsProfilePart.RT_CERTIFICATION) ||
                   recordTypeName.equalsIgnoreCase(rsProfilePart.RT_EDUCATION) || recordTypeName.equalsIgnoreCase(rsProfilePart.RT_PROF_AFFILIATION) ||
                   recordTypeName.equalsIgnoreCase(rsProfilePart.RT_FILE) || recordTypeName.equalsIgnoreCase(rsProfilePart.RT_LANGUAGES) ||
                   recordTypeName.equalsIgnoreCase(rsProfilePart.RT_PUBLICATION) || recordTypeName.equalsIgnoreCase(rsProfilePart.RT_REGISTRATION) ||
                   recordTypeName.equalsIgnoreCase(rsProfilePart.RT_SKILL_INDEX) || recordTypeName.equalsIgnoreCase(rsProfilePart.RT_TRAINING) ||
                   recordTypeName.equalsIgnoreCase(rsProfilePart.RT_TRANSLATIONS) || recordTypeName.equalsIgnoreCase(rsProfilePart.RT_WORK_HISTORY) ||
                   recordTypeName.equalsIgnoreCase(rsProfilePart.RT_PERSONAL) || recordTypeName.equalsIgnoreCase(rsProfilePart.RT_REFERENCE)) {
            pr.getParameters().put('tab', 'Skills_and_Qualifications');
            if (recordTypeName.equalsIgnoreCase(rsProfilePart.RT_WORK_HISTORY)) {
                pr.getParameters().put('tab.Skills_and_Qualifications.subtab', '0');
            } else if (recordTypeName.equalsIgnoreCase(rsProfilePart.RT_LANGUAGES) || recordTypeName.equalsIgnoreCase(rsProfilePart.RT_TRANSLATIONS)) {
                pr.getParameters().put('tab.Skills_and_Qualifications.subtab', '1');
            } else if (recordTypeName.equalsIgnoreCase(rsProfilePart.RT_EDUCATION) ||
                       recordTypeName.equalsIgnoreCase(rsProfilePart.RT_SF254) ||
                       recordTypeName.equalsIgnoreCase(rsProfilePart.RT_SF330) ||
                       recordTypeName.equalsIgnoreCase(rsProfilePart.RT_CERTIFICATION) ||
                       recordTypeName.equalsIgnoreCase(rsProfilePart.RT_PROF_AFFILIATION) ||
                       recordTypeName.equalsIgnoreCase(rsProfilePart.RT_REGISTRATION) ||
                       recordTypeName.equalsIgnoreCase(rsProfilePart.RT_TRAINING)
                      ) {
                pr.getParameters().put('tab.Skills_and_Qualifications.subtab', '2');
            } else if (recordTypeName.equalsIgnoreCase(rsProfilePart.RT_AWARD) || recordTypeName.equalsIgnoreCase(rsProfilePart.RT_PUBLICATION)) {
                pr.getParameters().put('tab.Skills_and_Qualifications.subtab', '3');
            } else if (recordTypeName.equalsIgnoreCase(rsProfilePart.RT_REFERENCE) ) {
                pr.getParameters().put('tab.Skills_and_Qualifications.subtab', '4');
            }
        }

        return pr;
    }

    //-- Pagination Methods --//
    public PageReference beginning() {
        counter = 0;
        return null;
    }

    public PageReference previous() {
        if ((counter - RESULT_SIZE) < 0) {
            counter = 0;
        } else {
            counter -= RESULT_SIZE;
        }
        return null;
    }

    public PageReference next() {
        if ((counter + RESULT_SIZE) > getSortedUserMap().size()) {
            counter = getSortedUserMap().size() - Math.mod(getSortedUserMap().size(), RESULT_SIZE);
        } else {
            counter += RESULT_SIZE;
        }
        return null;
    }

    public PageReference end() {
        if (Math.mod(getSortedUserMap().size(), RESULT_SIZE) == 0) {
            counter = getSortedUserMap().size() - RESULT_SIZE;
        } else {
            counter = getSortedUserMap().size() - Math.mod(getSortedUserMap().size(), RESULT_SIZE);
        }
        return null;
    }

    public Boolean getDisabledPrevious() {
        return !(counter > 0);
    }

    public Boolean getDisabledNext() {
        return !((counter + RESULT_SIZE) < getSortedUserMap().size());
    }

    public Integer getPageNumber() {
        Integer retValue = 0;
        if (getSortedUserMap().size() != 0) {
            retValue = counter / RESULT_SIZE + 1;
        }
        return retValue;
    }

    public Integer getFromResult() {
        Integer retVal = 0;
        if (getSortedUserMap().size() != 0) {
            retVal = counter + 1;
        }
        return retVal;
    }

    public Integer getToResult() {
        Integer retVal = 0;
        if (getSortedUserMap().size() != 0) {
            retVal = (counter + RESULT_SIZE) > getSortedUserMap().size() ? getSortedUserMap().size() : counter + RESULT_SIZE;
        }
        return retVal;
    }

    public Integer getTotalSearchResults() {
        return getSortedUserMap().size();
    }

    public Integer getTotalPages() {
        Integer retValue = 0;
        if (Math.mod(getSortedUserMap().size(), RESULT_SIZE) > 0) {
            retValue = getSortedUserMap().size() / RESULT_SIZE + 1;
        } else {
            retValue = getSortedUserMap().size() / RESULT_SIZE;
        }
        return retValue;
    }

    public List<rsUserViewModel> getViewResults() {
        List<rsUserViewModel> allResults = getUserList();

        return allResults;
    }

    public PageReference resetCounter() {
        mSortedUserMap.clear();
        createSortedMap(new Set<Id>());
        counter = 0;
        return null;
    }
    // -- End Pagination Methods -- //
}