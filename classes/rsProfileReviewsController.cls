public with sharing class rsProfileReviewsController {

    public String ProfileReviewViewType {get; set;}

    public String SortDir {get; set;}
    public String SortVal {get; set;}
    public String PartWhereClause {get; set;}
    public String ProjectWhereClause {get; set;}

    private List<SelectOption> mProfileReviewView;
    private Boolean mShowAssignee;

    public User dummyUser {get; set;} //Used for input fields formatting on datetime start field
    public User dummyUser2 {get; set;} //Used for input fields formatting on datetime stop field
    public String SearchLastName {get; set;}
    public String SearchFirstName {get; set;}
    public String SearchGeography {get; set;}
    public String SearchCountry {get; set;}
    public String SearchAssignee {get; set;}

    public rsProfileReviewsController() {
        dummyUser = new User();
        dummyUser2 = new User();
        SortDir = 'asc';
        SortVal = 'Date_Time_Sent_for_Review__c';
        PartWhereClause = 'User__r.Profile_Reviewer__c = ' + rsStringUtil.quote(UserInfo.getUserId()) + ' AND Next_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsProfilePart.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsProfilePart.S_PENDING) + ') AND (User__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR User__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )';
        ProjectWhereClause = ' EmployeeUser__r.Profile_Reviewer__c = ' + rsStringUtil.quote(UserInfo.getUserId()) + ' AND Next_Project_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsPRTeamEmployee.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_PENDING) + ') AND (EmployeeUser__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR EmployeeUser__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )' ;
        ProfileReviewViewType = REV_ASSIGNEDTOME;
    }

    public List<SelectOption> getprofileReviewView() {
        mProfileReviewView = new List<SelectOption>();
        mProfileReviewView.add(new SelectOption(REV_UN_AMERICAS, REV_UNASSIGNED + ' - ' + REV_UN_AMERICAS));
        mProfileReviewView.add(new SelectOption(REV_UN_AMERICAS_CS, REV_UNASSIGNED + ' - ' + REV_UN_AMERICAS_CS));
        mProfileReviewView.add(new SelectOption(REV_UN_APAC, REV_UNASSIGNED + ' - ' + REV_UN_APAC));
        mProfileReviewView.add(new SelectOption(REV_UN_CORPORATE_VAL, REV_UNASSIGNED + ' - ' + REV_UN_CORPORATE));
        mProfileReviewView.add(new SelectOption(REV_UN_EMEA, REV_UNASSIGNED + ' - ' + REV_UN_EMEA));
        mProfileReviewView.add(new SelectOption(REV_UN_GLOBAL_IT, REV_UNASSIGNED + ' - ' + REV_UN_GLOBAL_IT));
        mProfileReviewView.add(new SelectOption(REV_UN_MS_VAL, REV_UNASSIGNED + ' - ' + REV_UN_MS));
        mProfileReviewView.add(new SelectOption(REV_ASSIGNED, REV_ASSIGNED));
        mProfileReviewView.add(new SelectOption(REV_ASSIGNEDTOME, REV_ASSIGNEDTOME));
        mProfileReviewView.add(new SelectOption(REV_COMPLETED, REV_COMPLETED));
        mProfileReviewView.add(new SelectOption(REV_ALL_PENDING, REV_ALL_PENDING));
        return mProfileReviewView;
    }

    public List<Id> getReviewProfiles() {
        List<rs_Profile_Part__c> mReviewProfiles = new List<rs_Profile_Part__c>();
        if (ProfileReviewViewType == REV_UN_AMERICAS || ProfileReviewViewType == REV_UN_AMERICAS_CS
                || ProfileReviewViewType == REV_UN_APAC || ProfileReviewViewType == REV_UN_CORPORATE_VAL || ProfileReviewViewType == REV_UN_EMEA ||
                ProfileReviewViewType == REV_UN_GLOBAL_IT || ProfileReviewViewType == REV_UN_MS_VAL) {
            mReviewProfiles = rsProfilePart.find.reviewUnassigned(dummyUser.Date_Time_Sent_for_Review__c, dummyUser2.Date_Time_Sent_for_Review__c, SearchLastName, SearchFirstName, SearchGeography, SearchCountry, SearchAssignee, ProfileReviewViewType, SortDir);
            PartWhereClause = 'User__r.Profile_Reviewer__c = null AND Next_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsProfilePart.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsProfilePart.S_PENDING) + ') AND (User__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR User__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )';
        } else if (ProfileReviewViewType == REV_ASSIGNED) {
            mReviewProfiles = rsProfilePart.find.reviewAssigned(dummyUser.Date_Time_Sent_for_Review__c, dummyUser2.Date_Time_Sent_for_Review__c, SearchLastName, SearchFirstName, SearchGeography, SearchCountry, SearchAssignee, SortDir);
            PartWhereClause = 'User__r.Profile_Reviewer__c != null AND Next_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsProfilePart.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsProfilePart.S_PENDING) + ') AND (User__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR User__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )';
        } else if (ProfileReviewViewType == REV_COMPLETED) {
            mReviewProfiles = rsProfilePart.find.reviewCompleted(dummyUser.Date_Time_Sent_for_Review__c, dummyUser2.Date_Time_Sent_for_Review__c, SearchLastName, SearchFirstName, SearchGeography, SearchCountry, SearchAssignee, SortDir);
            PartWhereClause = 'Status__c = ' + rsStringUtil.quote(rsProfilePart.S_APPROVED) + 'AND Next_Part__c = null AND Date_Time_Sent_for_Review__c != null AND User__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_APPROVED);
        } else if (ProfileReviewViewType == REV_ALL_PENDING) {
            mReviewProfiles = rsProfilePart.find.reviewAllPending(dummyUser.Date_Time_Sent_for_Review__c, dummyUser2.Date_Time_Sent_for_Review__c, SearchLastName, SearchFirstName, SearchGeography, SearchCountry, SearchAssignee, SortDir);
            PartWhereClause = 'User__r.Profile_Reviewer__c = null AND Next_Part__c = null AND Status__c = ' + rsStringUtil.quote(rsProfilePart.S_PENDING);
        } else {
            ProfileReviewViewType = REV_ASSIGNEDTOME;
            PartWhereClause = 'User__r.Profile_Reviewer__c = ' + rsStringUtil.quote(UserInfo.getUserId()) + ' AND Next_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsProfilePart.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsProfilePart.S_PENDING) + ') AND (User__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR User__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )';
            mReviewProfiles = rsProfilePart.find.reviewAssignedToMe(UserInfo.getUserId(), dummyUser.Date_Time_Sent_for_Review__c, dummyUser2.Date_Time_Sent_for_Review__c, SearchLastName, SearchFirstName, SearchGeography, SearchCountry, SearchAssignee, SortDir);
        }
        //Doing it in a convuluted way because order of the users matter
        List<Id> partIds = new List<Id>();
        Set<Id> addedIds = new Set<Id>();
        for (rs_Profile_Part__c part : mReviewProfiles) {
            if (!addedIds.contains(part.User__c)) {
                partIds.add(part.User__c);
                addedIds.add(part.User__c);
            }
        }

        return partIds;
    }

    public List<Id> getReviewProjects() {
        List<rsPRTeamEmployee> mReviewProjects = new List<rsPRTeamEmployee>();
        if (ProfileReviewViewType == REV_UN_AMERICAS || ProfileReviewViewType == REV_UN_AMERICAS_CS
                || ProfileReviewViewType == REV_UN_APAC || ProfileReviewViewType == REV_UN_CORPORATE_VAL || ProfileReviewViewType == REV_UN_EMEA ||
                ProfileReviewViewType == REV_UN_GLOBAL_IT || ProfileReviewViewType == REV_UN_MS_VAL) {
            mReviewProjects = rsPRTeamEmployee.find.reviewUnassigned(dummyUser.Date_Time_Sent_for_Review__c, dummyUser2.Date_Time_Sent_for_Review__c, SearchLastName, SearchFirstName, SearchGeography, SearchCountry, SearchAssignee, ProfileReviewViewType, SortDir);
            ProjectWhereClause = ' EmployeeUser__r.Profile_Reviewer__c = null AND Next_Project_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsPRTeamEmployee.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_PENDING) + ') AND (EmployeeUser__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR EmployeeUser__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )' ;
        } else if (ProfileReviewViewType == REV_ASSIGNED) {
            mReviewProjects = rsPRTeamEmployee.find.reviewAssigned(dummyUser.Date_Time_Sent_for_Review__c, dummyUser2.Date_Time_Sent_for_Review__c, SearchLastName, SearchFirstName, SearchGeography, SearchCountry, SearchAssignee, SortDir);
            ProjectWhereClause = ' EmployeeUser__r.Profile_Reviewer__c != null AND Next_Project_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsPRTeamEmployee.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_PENDING) + ') AND (EmployeeUser__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR EmployeeUser__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )' ;
        } else if (ProfileReviewViewType == REV_COMPLETED) {
            mReviewProjects = rsPRTeamEmployee.find.reviewCompleted(dummyUser.Date_Time_Sent_for_Review__c, dummyUser2.Date_Time_Sent_for_Review__c, SearchLastName, SearchFirstName, SearchGeography, SearchCountry, SearchAssignee, SortDir);
            ProjectWhereClause = ' Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_APPROVED) + 'AND Next_Project_Part__c = null AND Date_Time_Sent_for_Review__c != null AND EmployeeUser__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_APPROVED);
        } else if (ProfileReviewViewType == REV_ALL_PENDING) {
            mReviewProjects = rsPRTeamEmployee.find.reviewAllPending(dummyUser.Date_Time_Sent_for_Review__c, dummyUser2.Date_Time_Sent_for_Review__c, SearchLastName, SearchFirstName, SearchGeography, SearchCountry, SearchAssignee, SortDir);
            ProjectWhereClause = ' EmployeeUser__r.Profile_Reviewer__c = null AND Next_Project_Part__c = null AND Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_PENDING);
        } else {
            ProfileReviewViewType = REV_ASSIGNEDTOME;
            mReviewProjects = rsPRTeamEmployee.find.reviewAssignedToMe(UserInfo.getUserId(), dummyUser.Date_Time_Sent_for_Review__c, dummyUser2.Date_Time_Sent_for_Review__c, SearchLastName, SearchFirstName, SearchGeography, SearchCountry, SearchAssignee, SortDir);
            ProjectWhereClause = ' EmployeeUser__r.Profile_Reviewer__c = ' + rsStringUtil.quote(UserInfo.getUserId()) + ' AND Next_Project_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsPRTeamEmployee.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_PENDING) + ') AND (EmployeeUser__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR EmployeeUser__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )' ;
        }
        //Doing it in a convuluted way because order of the users matter
        List<Id> projectIds = new List<Id>();
        Set<Id> addedIds = new Set<Id>();
        for (rsPRTeamEmployee project : mReviewProjects) {
            if (!addedIds.contains(project.getUser())) {
                projectIds.add(project.getUser());
                addedIds.add(project.getUser());
            }
        }
        return projectIds;
    }
    public Boolean getShowAssignee() {
        mShowAssignee = ProfileReviewViewType == REV_ASSIGNED;
        return mShowAssignee;
    }

    public PageReference resetSearch() {
        SearchLastName = null;
        SearchFirstName = null;
        SearchGeography = null;
        SearchCountry = null;
        SearchAssignee = null;
        dummyUser.Date_Time_Sent_for_Review__c = null;
        dummyUser2.Date_Time_Sent_for_Review__c = null;
        return null;
    }

    public static final String REV_ALL_PENDING = Label.All_Pending;
    public static final String REV_UNASSIGNED = Label.Unassigned_Profiles;
    public static final String REV_UN_AMERICAS = Label.Unassigned_Profiles_Americas;
    public static final String REV_UN_AMERICAS_CS = Label.Unassigned_Profiles_Americas_CS;
    public static final String REV_UN_APAC = Label.Unassigned_Profiles_APAC;
    public static final String REV_UN_CORPORATE = Label.Unassigned_Profiles_Corporate;
    public static final String REV_UN_CORPORATE_VAL = Label.Unassigned_Profiles_Corporate_Value;
    public static final String REV_UN_EMEA = Label.Unassigned_Profiles_EMEA;
    public static final String REV_UN_GLOBAL_IT = Label.Unassigned_Profiles_Global_IT;
    public static final String REV_UN_MS = Label.Unassigned_Profiles_MS;
    public static final String REV_UN_MS_VAL = Label.Unassigned_Profiles_MS_Value;

    public static final String REV_ASSIGNED = Label.Assigned_Profiles;
    public static final String REV_ASSIGNEDTOME = Label.Assigned_to_Me;
    public static final String REV_COMPLETED = Label.Completed_Profiles;


}