public with sharing class rsSummaryController extends rsSectionController{
    private Map<String,Integer> mAreaPointMap;

    private static final Map<Id,Schema.RecordTypeInfo> mRtInfo;
    private Integer mTotalScore;
    private String mProfileCMStatus;
    private Boolean mShowCMActions;
    private Boolean mShowStartReview;
    private String mProfileCompletionStatus;
    static {
        mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosById().clone();
        mRtInfo.putAll( PR_Team_Employee__c.SObjectType.getDescribe().getRecordTypeInfosById() );
    }

    public rsSummaryController() {
        super();
    }

    //This will return a map of the current user's profile parts. The key of the map is the record type name, and the value a counter of parts in that record type
    public Map<String,Integer> getAreaPointMap(){
        mAreaPointMap = new Map<String,Integer>();
        List<rsProfilePart> parts = profile.getProfilePartsEmployeeView();
        List<rsPRTeamEmployee> projects = profile.getProfileProjectsEmployeeView();

        for(rsProfilePart profilePart : parts){
            Schema.RecordTypeInfo rt = mRtInfo.get((Id)profilePart.getObj().get('RecordTypeId'));
            String currRtName = rt.getName();

            //ignore 254 and 330 records
            if(currRtName.equalsIgnoreCase(rsProfilePart.RT_SF254) || currRtName.equalsIgnoreCase(rsProfilePart.RT_SF330) ) continue;

            if (mAreaPointMap.containsKey(currRtName) && rt.isAvailable()){
                mAreaPointMap.put(currRtName, (mAreaPointMap.get(currRtName)) + 1);
            } else if(rt.isAvailable()){
                mAreaPointMap.put(currRtName, 1);
            }
        }
        for(rsPRTeamEmployee proj : projects) {
            //ignore projects with no description on them
            if ( String.isBlank( proj.getRoleDescription() ) ) continue;
            Schema.RecordTypeInfo rt = mRtInfo.get((Id)proj.getObj().get('RecordTypeId'));
            String currRtName = rt.getName();
            if (mAreaPointMap.containsKey(currRtName) && rt.isAvailable()){
                mAreaPointMap.put(currRtName, (mAreaPointMap.get(currRtName)) + 1);
            } else if(rt.isAvailable()){
                mAreaPointMap.put(currRtName, 1);
            }
        }
        for(Schema.RecordTypeInfo rt : mRtInfo.values())
        {
            String rtName = rt.getName();
            if(!mAreaPointMap.containsKey(rtName)
               && !rtName.equalsIgnoreCase(rsProfilePart.RT_SF254)
               && !rtName.equalsIgnoreCase(rsProfilePart.RT_SF330)
               && rt.isAvailable())
            {
                mAreaPointMap.put(rtName, 0);
            }
        }


        return mAreaPointMap;
    }

    public Map<String,Decimal> getNormalizedPointMap(){
        Map<String,Decimal> tempMap = new Map<String,Decimal>();
        Map<String,Integer> pointMap = getAreaPointMap();

        for(String s : pointMap.keySet() ) {

            Decimal points = 1;
            rs_Resume_Area_Points__c  areaPts = rs_Resume_Area_Points__c.getValues(s);
            if(areaPts != null && areaPts.Total__c > 0) {
                points = areaPts.Total__c;
            }


            tempMap.put(s,(pointMap.get(s)/points) * 100);
        }
        return tempMap;
    }


    public Integer getTotalScore() {
        mTotalScore = 0;
        Map<String,Integer> tempMap = getAreaPointMap();
        for(Integer currValue : tempMap.values() ) {
                mTotalScore += currValue;
        }
        return mTotalScore;
    }

    public String getProfileCMStatus() {
        mProfileCMStatus = (String) profile.getObj().get('Status__c');
        return mProfileCMStatus;
    }

    public String getProfileCompletionStatus() {
        Map<String,Decimal> pointMap = getNormalizedPointMap();
        Integer neededCompleteScore = pointMap.size();
        Decimal currScore = 0;
        // Using the normalized point map if they have completed
        // the section we'll give them a point otherwise, we'll just
        // add the normalized points
        for(String key : pointMap.keySet()) {
            currScore += pointMap.get(key) >= 1 ? 1 : pointMap.get(key);
        }
        Decimal ratio = neededCompleteScore > 0 ? (currScore/neededCompleteScore) : 0;
        if ( ratio < 0.33 ) {
            mProfileCompletionStatus = Label.Incomplete;
        } else if ( ratio > 0.33 && ratio <= 0.66 ) {
            mProfileCompletionStatus = Label.Partially_Complete;
        } else if ( ratio > 0.66 ) {
            mProfileCompletionStatus = Label.Fully_Complete;
        }
        return mProfileCompletionStatus;
    }

    public PageReference updateProfileStatus() {
        String actionType = ApexPages.currentPage().getParameters().get('actionType');
        List<rs_Profile_Part__c> approvedPartList = new List<rs_Profile_Part__c>();
        List<rsPRTeamEmployee> approvedProjList = new List<rsPRTeamEmployee>();
        for(rsProfilePart part : profile.getProfileParts() ) {
            if (part.getStatus() == rsProfilePart.S_PENDING || part.getStatus() == rsProfilePart.S_INREVIEW) {
                part.setStatus(rsProfilePart.S_APPROVED);
                approvedPartList.add((rs_Profile_Part__c)part.getObj());
            }
        }
        for(rsPRTeamEmployee proj : profile.getProfileProjects() ) {
            if (proj.getStatus() == rsPRTeamEmployee.S_PENDING || proj.getStatus() == rsPRTeamEmployee.S_INREVIEW) {
                proj.setStatus(rsPRTeamEmployee.S_APPROVED);
                approvedProjList.add(proj);
            }
        }

        if (actionType == 'approve') {
            rsApprovalUtil.approveProfile(profile, approvedPartList, approvedProjList);
        } else if (actionType == 'startReview') {
            rsApprovalUtil.startReview(profile, approvedPartList, approvedProjList);
        } else if (actionType == 'stopReview') {
            rsApprovalUtil.stopReview(profile, approvedPartList, approvedProjList);
        }
        return null;
    }

    public Boolean getShowCMActions() {
        mShowCMActions = Profile_Info__c.getInstance().Is_Content_Manager__c && (UserInfo.getUserId() == profile.getProfileReviewer() );
        return mShowCMActions;
    }

    public Boolean getShowStartReview() {
        mShowStartReview = profile.getStatus() == rsProfile.S_PENDING;
        return mShowStartReview;
    }
}