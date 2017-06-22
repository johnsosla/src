/*************************************************************************
*
* PURPOSE: Decorator for user. Also maintains a list of rsProfileParts
*          This object is what should be passed around to components
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public with sharing class rsProfile extends rsModel {

    public static Finder find = new Finder('User');
    private List<rsProfilePart> mProfileParts;
    private transient List<rsPRTeamEmployee> mProfileProjects;
    private List<rsUpdateTracking> mUpdateTrackings;
    private List<rsSearch> mProjectGroups;
    public Boolean ResetProjects {get; set;}
    private final static Integer SEARCH_RESULT_SIZE = 1000;
    public User getUser() {
        return (User) mObj;
    }

    public rsProfile(User u) {
        super(u);
        resetProjects = false;
    }

    public void refreshUser() {
        mObj = (User)rsProfile.find.byUserId(this.getId()).getObj();
    }

    public override void save() {
        rsDataUtils.save(mObj);
    }

    public List<rsProfilePart> getProfileParts() {
        if (mProfileParts == null) {
            if (UserInfo.getUserId() == this.getId() || UserInfo.getUserId() == this.getProfileProxy() || Profile_Info__c.getInstance().Is_Content_Manager__c ) {
                mProfileParts = rsProfilePart.find.byIdAsSelfOrProxyOrCM(mObj.Id);
            } else {
                mProfileParts = getProfilePartsEmployeeView();
            }
        }
        return mProfileParts;
    }

    public List<rsPRTeamEmployee> getProfileProjects() {
        if (mProfileProjects == null) {
            if (UserInfo.getUserId() == this.getId() || UserInfo.getUserId() == this.getProfileProxy() || Profile_Info__c.getInstance().Is_Content_Manager__c ) {
                mProfileProjects = rsPRTeamEmployee.find.byIdAsSelfOrProxyOrCM(mObj.Id);
            } else {
                mProfileProjects = getProfileProjectsEmployeeView();
            }
        }
        return mProfileProjects;
    }
    public List<rsPRTeamEmployee> getSortedProfileProjects() {
        List<rsPRTeamEmployee> projects = new List<rsPRTeamEmployee>(getProfileProjects());
        projects.sort();
        return projects;
    }
    public void setProfileProjects(List<rsPRTeamEmployee> projects) {
        mProfileProjects = projects;
    }

    public List<rsSearch> getProjectGroups() {
        if(mProjectGroups == null) {
            mProjectGroups = rsSearch.find.getProjectGroupsByUser(getId());
            mProjectGroups.sort();
        }
        return mProjectGroups;
    }
    public void setProjectGroups(List<rsSearch> groups) {
        mProjectGroups = groups;
    }

    public List<rsUpdateTracking> getProfileUpdateTrackings() {
        if(mUpdateTrackings == null) {
            mUpdateTrackings = rsUpdateTracking.find.byUserId(mObj.Id);
        }
        return mUpdateTrackings;
    }

    public List<rsProfilePart> getProfilePartsEmployeeView() {
        return rsProfilePart.find.byIdAsEmployee(mObj.Id);
    }

    public List<rsPRTeamEmployee> getProfileProjectsEmployeeView() {
        return rsPRTeamEmployee.find.byIdAsEmployee(mObj.Id);
    }

    public List<rsProfilePart> getPartsByType(String type) {
        List<rsProfilePart> parts = new List<rsProfilePart>();
        for (rsProfilePart part : getProfileParts()) {
            if (part.isType(type)) {
                parts.add(part);
            }
        }
        parts.sort();
        return parts;
    }

    public Id getAssignedContentManagerId() {
        return (Id)mObj.get('Assigned_Content_Manager__c');
    }
    public void setAssignedContentManagerId(Id AssignedContentManager) {
        mObj.put('Assigned_Content_Manager__c', AssignedContentManager);
    }


    public void setLock(Boolean lock) {
        mObj.put('Is_Profile_Locked__c', lock);
    }
    public Boolean getLock() {
        return (Boolean) mObj.get('Is_Profile_Locked__c');
    }

    public DateTime getDateTimeSentforReview() {
        return (DateTime) mObj.get('Date_Time_Sent_for_Review__c');
    }
    public void setDateTimeSentforReview(DateTime dtSent) {
        mObj.put('Date_Time_Sent_for_Review__c', dtSent);
    }

    public void setStatus(String status) {
        mObj.put('Status__c', status);
    }
    public String getStatus() {
        return (String) mObj.get('Status__c');
    }

    public void setProfileReviewer(String profileReviewer) {
        mObj.put('Profile_Reviewer__c', profileReviewer);
    }
    public String getProfileReviewer() {
        return (String) mObj.get('Profile_Reviewer__c');
    }

    public void setDateProxyAdded(Date dateProxyAdded) {
        mObj.put('Date_Proxy_Added__c', dateProxyAdded);
    }

    public Id getProfileProxy() {
        return (Id)mObj.get('Profile_Proxy__c');
    }

    public String getCitizenship() {
        return (String)mObj.get('Citizenship__c');
    }

    public void setCitizenship(String citizenship) {
        mObj.put('Citizenship__c', citizenship);
    }

    public String getTermDate() {
        return mObj.get('Term_Date__c') != null ? Date.valueOf(mObj.get('Term_Date__c')).format()
               : '' ;
    }

    public void setTermDate(String termDate) {
        if (String.isNotBlank(termDate)) {
            mObj.put('Term_Date__c', Date.parse(termDate));
        } else {
            mObj.put('Term_Date__c', null);
        }
    }

    public String getLastUserProfileUpdate() {
        return mObj.get('Last_User_Profile_Update__c') != null ? DateTime.valueOf(mObj.get('Last_User_Profile_Update__c')).format()
               : '' ;
    }

    public String getLastCMProfileUpdate() {
        return mObj.get('Last_CM_Profile_Update__c') != null ? DateTime.valueOf(mObj.get('Last_CM_Profile_Update__c')).format()
               : '' ;
    }



    public String getDateOfBirth() {
        return mObj.get('Date_Of_Birth__c') != null ? Date.valueOf(mObj.get('Date_Of_Birth__c')).format()
               : '' ;
    }

    public void setDateOfBirth(String dob) {
        if (String.isNotBlank(dob)) {
            mObj.put('Date_Of_Birth__c', Date.parse(dob));
        } else {
            mObj.put('Date_Of_Birth__c', null);
        }
    }

    public String getTrackingId() {
        return (String)mObj.get('TrackingId__c');
    }

    public void setTrackingId(String trackingId) {
        mObj.put('TrackingId__c', trackingId);
    }

    public String getAdjustedServiceDate() {
        return mObj.get('Adjusted_Service_Date__c') != null ? Date.valueOf(mObj.get('Adjusted_Service_Date__c')).format()
               : '';
    }

    public void setAdjustedServiceDate(String servDate) {
        if (String.isNotBlank(servDate)) {
            mObj.put('Adjusted_Service_Date__c', Date.parse(servDate));
        } else {
            mObj.put('Adjusted_Service_Date__c', null);
        }
    }

    public String getGender() {
        return (String)mObj.get('Gender__c');
    }

    public void setGender(String gender) {
        mObj.put('Gender__c', gender);
    }

    public String getAssignmentStatus() {
        return (String)mObj.get('Assignment_Status__c');
    }

    public void setAssignmentStatus(String assignStatus) {
        mObj.put('Assignment_Status__c', assignStatus);
    }

    public String getEmployeeCategory() {
        return (String)mObj.get('Employee_Category__c');
    }

    public void setEmployeeCategory(String empCat) {
        mObj.put('Employee_Category__c', empCat);
    }

    public String getInternationalAssignmentStatus() {
        return (String)mObj.get('International_Assignment_Status__c');
    }

    public void setInternationalAssignmentStatus(String intlStatus) {
        mObj.put('International_Assignment_Status__c', intlStatus);
    }

    public String getOriginalHireDate() {
        return mObj.get('Original_Hire_Date__c') != null ? Date.valueOf(mObj.get('Original_Hire_Date__c')).format()
               : '';
    }

    public void setOriginalHireDate(String hireDate) {
        mObj.put('Original_Hire_Date__c', hireDate);
    }

    public String getJobFamilyMeaning() {
        return (String)mObj.get('Job_Family_Meaning__c');
    }

    public void setJobFamilyMeaning(String jobFamMeaning) {
        mObj.put('Job_Family_Meaning__c', jobFamMeaning);
    }

    public String getRehireDate() {
        return mObj.get('Rehire_Date__c') != null ? Date.valueOf(mObj.get('Rehire_Date__c')).format()
               : '';
    }

    public void setRehireDate(String rehireDate) {
        if (String.isNotBlank(rehireDate)) {
            mObj.put('Rehire_Date__c', Date.parse(rehireDate));
        } else {
            mObj.put('Rehire_Date__c', null);
        }
    }

    public String getNationality() {
        return (String)mObj.get('Nationality__c');
    }

    public void setNationality(String nationality) {
        mObj.put('Nationality__c', nationality);
    }

    public String getCiscoIPPhone() {
        return (String)mObj.get('Cisco_IP_Phone__c');
    }

    public String getEmployeeNumber() {
        return (String)mObj.get('EmployeeNumber');
    }

    // Global Mobility Fields Start

    public String getInterestCountries() {
        return (String)mObj.get('Interest_Countries__c');
    }

    public void setInterestCountries(String countries) {
        mObj.put('Interest_Countries__c', countries);
    }

    public String getInterestRegions() {
        return (String)mObj.get('Interest_Regions__c');
    }

    public void setInterestRegions(String regions) {
        mObj.put('Interest_Regions__c', regions);
    }

    public String getInterestRelocatingCurrentCountry() {
        return (String)mObj.get('Interest_Relocating_Current_Country__c');
    }

    public void setInterestRelocatingCurrentCountry(String countries) {
        mObj.put('Interest_Relocating_Current_Country__c', countries);
    }

    public String getInterestRelocatingDifferentCountry() {
        return (String)mObj.get('Interest_Relocating_Different_Country__c');
    }

    public String getInterestOperatingGroups() {
        return (String)mObj.get('PP_Interest_Operating_Groups__c');
    }

    public void setInterestOperatingGroups(String opGroups) {
        mObj.put('PP_Interest_Operating_Groups__c', opGroups);
    }

    public void setInterestRelocatingDifferentCountry(String countries) {
        mObj.put('Interest_Relocating_Different_Country__c', countries);
    }

    public String getLengthOfTimeAbroad() {
        return (String)mObj.get('Length_of_Time_Abroad__c');
    }

    public void setLengthOfTimeAbroad(String timeSelect) {
        mObj.put('Length_of_Time_Abroad__c', timeSelect);
    }

    public String getNoInterestCountries() {
        return (String)mObj.get('No_Interest_Countries__c');
    }

    public void setNoInterestCountries(String countries) {
        mObj.put('No_Interest_Countries__c', countries);
    }

    public String getNoInterestRegions() {
        return (String)mObj.get('No_Interest_Regions__c');
    }

    public void setNoInterestRegions(String countries) {
        mObj.put('No_Interest_Regions__c', countries);
    }

    public String getNoInterestOperatingGroups() {
        return (String)mObj.get('PP_No_Interest_Operating_Groups__c');
    }

    public void setNoInterestOperatingGroups(String opGroups) {
        mObj.put('PP_No_Interest_Operating_Groups__c', opGroups);
    }

    public String getTimeToRelocate() {
        return (String)mObj.get('rs_Time_To_Relocate__c');
    }

    public void setTimeToRelocate(String TimeToRelocate) {
        mObj.put('rs_Time_To_Relocate__c', TimeToRelocate);
    }

    public String getAccompaniedStatus() {
        return (String)mObj.get('rs_Accompanied_Status__c');
    }

    public void setAccompaniedStatus(String AccompaniedStatus) {
        mObj.put('rs_Accompanied_Status__c', AccompaniedStatus);
    }

    public Id getManagerId() {
        return (Id)mObj.get('ManagerId');
    }

    public void setProfileUpdated(Boolean isUpdated) {
        mObj.put('Profile_Updated__c', isUpdated);
    }
    public void setLastUpdatedBy(String updatedByType) {
        mObj.put('Last_Updated_By__c', updatedByType);
    }
    public void setDateTimeLastUpdated(DateTime whenLastUpdated) {
        mObj.put('Date_Time_Last_Updated__c', whenLastUpdated);
    }

    // Global Mobility Fields End

    //Various Notes Fields START
    public String getMiscellaneousNotes() {
        return (String)mObj.get('rs_Miscellaneous_Notes__c');
    }
    public void setMiscellaneousNotes(String rsMiscellaneousNotes) {
        mObj.put('rs_Miscellaneous_Notes__c', rsMiscellaneousNotes);
    }

    public String getNoteToUser() {
        return (String)mObj.get('rs_Note_To_User__c');
    }
    public void setNoteToUser(String rsNoteToUser) {
        mObj.put('rs_Note_To_User__c', rsNoteToUser);
    }

    public String getNoteToEmployee() {
        return (String)mObj.get('rs_Note_To_Employee__c');
    }
    public void setNoteToEmployee(String rsNoteToEmployee) {
        mObj.put('rs_Note_To_Employee__c', rsNoteToEmployee);
    }

    //Various Notes Fields END

    //This method is called in deletions/approvals of profile parts and projects to see if there are any other records (other than the one being deleted/approved)
    //that should keep the user's profile locked
    public Boolean shouldProfileStayLocked(Id recordBeingDeletedOrApproved) {
        List<rs_Profile_Part__c> profilePartList = [Select Id from rs_Profile_Part__c where (Status__c = :rsProfilePart.S_INREVIEW OR Status__c = :rsProfilePart.S_PENDING) AND Id != :recordBeingDeletedOrApproved AND User__c = : getUser().Id];
        List<PR_Team_Employee__c> projectList = [Select Id from PR_Team_Employee__c where (Status__c = :rsPRTeamEmployee.S_INREVIEW OR Status__c = :rsPRTeamEmployee.S_PENDING) AND Id != :recordBeingDeletedOrApproved AND EmployeeUser__c = : getUser().Id];
        return (profilePartList.size() > 0 || projectList.size() > 0);
    }
    public class Finder extends rsFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            //AECR-1541, we're only going to import the fields we need
            Set<String> fieldset = new Set<String> {
                'Assigned_Content_Manager__c',
                'Is_Profile_Locked__c',
                'Date_Time_Sent_for_Review__c',
                'Status__c',
                'Country',
                'Profile_Reviewer__c',
                'Date_Proxy_Added__c',
                'Profile_Proxy__c',
                'Citizenship__c',
                'Term_Date__c',
                'Last_User_Profile_Update__c',
                'Last_CM_Profile_Update__c',
                'Date_Of_Birth__c',
                'TrackingId__c',
                'Adjusted_Service_Date__c',
                'Gender__c',
                'Assignment_Status__c',
                'Employee_Category__c',
                'International_Assignment_Status__c',
                'Original_Hire_Date__c',
                'Job_Family_Meaning__c',
                'Rehire_Date__c',
                'Nationality__c',
                'Cisco_IP_Phone__c',
                'EmployeeNumber',
                'Interest_Countries__c',
                'Interest_Regions__c',
                'Interest_Relocating_Current_Country__c',
                'Interest_Relocating_Different_Country__c',
                'Length_of_Time_Abroad__c',
                'No_Interest_Countries__c',
                'No_Interest_Regions__c',
                'rs_Time_To_Relocate__c',
                'rs_Accompanied_Status__c',
                'ManagerId',
                'Profile_Updated__c',
                'Last_Updated_By__c',
                'Date_Time_Last_Updated__c',
                'rs_Miscellaneous_Notes__c',
                'rs_Note_To_User__c',
                'rs_Note_To_Employee__c',
                'rs_Miscellaneous_Notes__c',
                'rs_Note_To_User__c',
                'rs_Note_To_Employee__c',
                'HR_Full_Name__c',
                'HR_Job_Title__c',
                'Years_Of_Experience__c',
                'Supergeography__c',
                'Sub_Business_Line__c',
                'Service_Line__c',
                'Region__c',
                'Geography__c',
                'District__c',
                'Department',
                'Resume_Name__c',
                'Bio__c',
                'Business_Line__c',
                'Years_With_AECOM__c',
                'SmallPhotoUrl',
                'Name',
                'FirstName',
                'LastName',
                'Certified_PM__c',
                'Title'
            };
            setFieldSet(fieldSet);
        }

        public rsProfile byUserId(Id userId) {
            addFields(new Set<String> {'Assigned_Content_Manager__r.Name', 'Profile_Reviewer__r.Name', 'Profile_Proxy__r.Name'});
            return new rsProfile((User)byId(userId).getObj());
        }

        public Map<Id, User> byUserIdSet(Set<Id> userIds) {
            addFields(new Set<String> {'Profile_Reviewer__r.Name', 'Manager.Name'});
            return new Map<Id, User>((List<User>)Database.query(getSelect() + 'where Id IN :userIds'));
        }

        public Map<Id, User> byUserIdSetMinFields(Set<Id> userIds, Set<String> fields) {
            return new Map<Id, User>((List<User>)Database.query('select ' + String.join(new List<String>(fields), ',') + ' from User where Id IN :userIds'));
        }

        //Finds list of user by either their ids, or a where clause
        public List<User> getUsersByIdsOrWhere(Set<Id> userIds, String whereStr) {
            List<User> users = new List<User>();
            if (whereStr != '') {
                users = Database.query(getSelect() + ' where ' + whereStr + ' OR Id IN: userIds LIMIT ' + SEARCH_RESULT_SIZE);
            } else {
                users = Database.query(getSelect() + ' where Id IN: userIds LIMIT ' + SEARCH_RESULT_SIZE);
            }
            return users;
        }

        //Finds list of user by their ids and a where str
        public List<User> getUsersByIdsAndWhere(Set<Id> userIds, String whereStr) {
            List<User> users = new List<User>();
            if (whereStr != '') {
                users = Database.query(getSelect() + ' where ' + whereStr + ' AND Id IN: userIds LIMIT ' + SEARCH_RESULT_SIZE);
            } else {
                users = Database.query(getSelect() + ' where Id IN: userIds LIMIT ' + SEARCH_RESULT_SIZE);
            }
            return users;
        }

        public List<User> getUsersByFind(String findStr, Boolean findInactive) {
            String queryString = 'FIND ' + rsStringUtil.quote(findStr) + ' IN ALL FIELDS RETURNING USER(' + getFields();
            if (!findInactive) {
                queryString += ' where IsActive = true)';
            } else {
                queryString += ')';
            }
            queryString += ' LIMIT ' + SEARCH_RESULT_SIZE;
            System.debug('### rsProfile getUsersByFind qString: ' + queryString);
            List<List<SObject>> resultList = search.query(queryString);
            return (List<User>)resultList[0];
        }

        public List<User> getUsersByFindAndWhere(String findStr, Boolean findInactive, String whereStr) {
            String queryString = 'FIND ' + rsStringUtil.quote(findStr) + ' IN ALL FIELDS RETURNING USER(' + getFields();
            if (!findInactive) {
                queryString += ' where (' + whereStr + ') AND IsActive = true)';
            } else {
                queryString += ' where ' + whereStr + ')';
            }
            queryString += ' LIMIT ' + SEARCH_RESULT_SIZE;
            System.debug('### rsProfile getUsersByFind qString: ' + queryString);
            List<List<SObject>> resultList = search.query(queryString);
            return (List<User>)resultList[0];
        }

        public List<User> getProfileReviewLookupResults(String name) {
            List<Profile_Info__c> profInfos = [select Id, Name, Is_content_manager__c, SetupOwnerId from Profile_Info__c where Is_Content_Manager__c = true];
            Set<String> setupOwnerIds = new Set<String>();
            for (Profile_Info__c info : profInfos) {
                setupOwnerIds.add(info.SetupOwnerId);
            }
            String whereStr = 'where';
            if (!String.isBlank(name)) {
                whereStr += ' Name LIKE ' + rsStringUtil.likeQueryQuote(name) + ' AND ';
            }
            whereStr += ' IsActive = true AND (Id in ' + rsStringUtil.listJoin(new List<String>(setupOwnerIds) ) + ' OR profileId in ' + rsStringUtil.listJoin(new List<String>(setupOwnerIds) ) + ')';
            System.debug('###whereStr: ' + whereStr);
            return new List<User>( (List<User>)Database.query('Select Id, Name from User ' + whereStr + 'LIMIT 500'));

        }

        public String getAutoCompleteProjectGroups(Id userId) {
            List<AggregateResult> projGroupsQuery = [select project_group_editable__c from PR_Team_Employee__c where EmployeeUser__c = :userId GROUP BY project_group_editable__c];
            List<String> groups = new List<String>();
            for (AggregateResult res : projGroupsQuery) {
                groups.add(String.valueOf(res.get('Project_Group_editable__c')));
            }

            String retString = '\"' + String.join(groups, '\",\"') + '\"';
            return retString;
        }

        //This will return the list of users that report to the passed in userId
        public List<User> directReportList(Id userId, Integer queryLimit, Integer offset) {
            String queryStr = 'Select Id, Name, SmallPhotoUrl, HR_Job_Title__c, Phone, City, State, PostalCode from User where isActive = true AND ManagerId = ' + rsStringUtil.quote(userId) + ' order by Name limit ' + String.valueOf(queryLimit);
            if (offset != 0) {
                queryStr += ' OFFSET ' + offset;
            }
            System.debug('###queryStr: ' + queryStr);
            return (List<User>)Database.query(queryStr);
        }

        //This will return the list of users that report to the managerId (excluding the passed in userId)
        public List<User> peerList(Id userId, Id managerId, Integer queryLimit, Integer offset) {
            String queryStr = 'Select Id, Name, SmallPhotoUrl, HR_Job_Title__c, Phone, City, State, PostalCode from User where isActive = true AND ManagerId = ' + rsStringUtil.quote(managerId) + ' AND Id !=' + rsStringUtil.quote(userId) + ' order by Name limit ' + String.valueOf(queryLimit);
            if (offset != 0) {
                queryStr += ' OFFSET ' + offset;
            }
            System.debug('###queryStr: ' + queryStr);
            return (List<User>)Database.query(queryStr);
        }
    }

    //Statuses for the Status__c field
    public static final String S_APPROVED = 'Approved';
    public static final String S_PENDING = 'Pending';
    public static final String S_INREVIEW = 'In Review';
    public static final String S_ARCHIVED = 'Archived';

    //Set of Global Mobility fields
    public static final Set<String> USER_GLOBAL_MOBILITY_FIELDS = new Set<String> { 'Interest_Countries__c',
            'Interest_Regions__c',
            'Interest_Relocating_Current_Country__c',
            'Interest_Relocating_Different_Country__c',
            'Length_of_Time_Abroad__c',
            'No_Interest_Countries__c',
            'No_Interest_Regions__c'
                                                                                  };
}