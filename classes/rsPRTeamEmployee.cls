/*************************************************************************
*
* PURPOSE: Decorator for PR Team Employee (Junction between user and project database)
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public class rsPRTeamEmployee extends rsModel {

    public static Finder find = new Finder('PR_Team_Employee__c');
    private static final Integer SEARCH_RESULT_SIZE = 2000;
    private static final Integer LIST_SIZE_LIMIT = 10000;
    private static final Map<String, Schema.RecordTypeInfo> mRtInfo;
    static {
        mRtInfo = PR_Team_Employee__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    }

    public rsPRTeamEmployee() {
        super(new PR_Team_Employee__c());
    }

    public rsPRTeamEmployee(PR_Team_Employee__c pte) {
        super(pte);
    }

    public rsPRTeamEmployee(Id userId, String type) {
        super(new PR_Team_Employee__c(EmployeeUser__c = userId,
                                      RecordTypeId = mRtInfo.get(type).getRecordTypeId(), OwnerId = userId)
             );
    }

    public PR_Team_Employee__c getPRObj() {
        return (PR_Team_Employee__c) super.getObj();
    }

    public static Id getRecordTypeIdByName(String typeName) {
        return mRtInfo.get(typeName).getRecordTypeId();
    }

    public Id getProjectId() {
        return (Id) mObj.get('Project_ID__c');
    }
    public void setProjectId(Id projId) {
        mObj.put('Project_ID__c', projId);
    }

    public String getDateInvolvementStarted() {
        return mObj.get('Date_Involvement_Started__c') != null ? DateTime.newInstance(Date.valueOf(this.mObj.get('Date_Involvement_Started__c')), Time.newInstance(0, 0, 0, 0)).format('MM/yyyy') : null ;
    }
    public void setDateInvolvementStarted(String dateStarted) {
        if (String.isNotBlank(dateStarted)) {
            List<String> dates = dateStarted.split('/');
            Date newDate;
            if (dates.size() == 2 ) {
                dates.add(0, '01');
                newDate = Date.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[1]), Integer.valueOf(dates[0]));
            }
            mObj.put('Date_Involvement_Started__c', newDate);
        } else {
            mObj.put('Date_Involvement_Started__c', null);
        }
    }

    public String getDateInvolvementEnded() {
        return mObj.get('Date_Involvement_Ended__c') != null ? DateTime.newInstance(Date.valueOf(this.mObj.get('Date_Involvement_Ended__c')), Time.newInstance(0, 0, 0, 0)).format('MM/yyyy') : null ;
    }

    public void setDateInvolvementEnded(String dateEnded) {
        if (String.isNotBlank(dateEnded)) {
            List<String> dates = dateEnded.split('/');
            Date newDate;
            if (dates.size() == 2 ) {
                dates.add(0, '01');
                newDate = Date.newInstance(Integer.valueOf(dates[2]), Integer.valueOf(dates[1]), Integer.valueOf(dates[0]));
            }
            mObj.put('Date_Involvement_Ended__c', newDate);
        } else {
            mObj.put('Date_Involvement_Ended__c', null);
        }
    }

    public String getProjectRole() {
        return (String) mObj.get('Project_Role__c');
    }
    public void setProjectRole(String role) {
        mObj.put('Project_Role__c', role);
    }

    public String getRoleDescription() {
        return (String) mObj.get('Description__c');
    }
    public void setRoleDescription(String role) {
        mObj.put('Description__c', role);
    }

    public Boolean getOutputOnResume() {
        return (Boolean) mObj.get('Output_on_Resume__c');
    }
    public void setOutputOnResume(Boolean output) {
        mObj.put('Output_on_Resume__c', output);
    }

    public Id getNextProjectPart() {
        return (Id)this.mObj.get('Next_Project_Part__c');
    }

    public void setNextProjectPart(Id partId) {
        mObj.put('Next_Project_Part__c', partId);
    }

    public Id getPreviousProjectPart() {
        return (Id)this.mObj.get('Previous_Project_Part__c');
    }

    public void setPreviousProjectPart(Id partId) {
        mObj.put('Previous_Project_Part__c', partId);
    }

    public Datetime getDateTimeSentForReview() {
        return (Datetime)mObj.get('Date_Time_Sent_for_Review__c');
    }

    public void setDateTimeSentForReview(Datetime dateTimeSent) {
        mObj.put('Date_Time_Sent_for_Review__c', dateTimeSent);
    }

    public String getStatus() {
        return (String) mObj.get('Status__c');
    }
    public void setStatus(String statusToSet) {
        mObj.put('Status__c', statusToSet);
    }

    public String getProjectName() {
        return (String) mObj.get('Project_Name__c');
    }

    public String getLocationCountry() {
        return (String) mObj.get('Location_Country__c');
    }
    public String getLocationCountryText() {
        return (String) mObj.get('Location_Country_Text__c');
    }
    public void setLocationCountryText(String country) {
        mObj.put('Location_Country_Text__c', country);
    }
    public String getLocationStateProvince() {
        return (String) mObj.get('Location_State_Prov_Emirate__c');
    }
    public String getLocationStateProvinceText() {
        return (String) mObj.get('Location_State_Prov_Emirate_Text__c');
    }
    public void setLocationStateProvinceText(String state) {
        mObj.put('Location_State_Prov_Emirate_Text__c', state);
    }
    public String getLocationCity() {
        return (String) mObj.get('Location_City__c');
    }
    public String getLocationCityText() {
        return (String)mObj.get('Location_City_Text__c');
    }
    public void setLocationCityText(String LocationCityText) {
        mObj.put('Location_City_Text__c', LocationCityText);
    }
    public String getProjectNumber() {
        return (String) mObj.get('Project_Number_Calculated__c');
    }
    public String getClientName() {
        return (String) mObj.get('Client__c');
    }

    public String getInitialLocale() {
        return (String) mObj.get('Initial_Locale__c');
    }
    public void setInitialLocale(String locale) {
        mObj.put('Initial_Locale__c', locale);
    }

    public Id getUser() {
        return (Id) mObj.get('EmployeeUser__c');
    }
    public void setUser(Id userId) {
        mObj.put('EmployeeUser__c', userId);
    }

    public Id getRecordTypeId() {
        return (Id) mObj.get('RecordTypeId');
    }
    public void setRecordTypeId(Id idToSet) {
        mObj.put('RecordTypeId', idToSet);
    }

    public String getProjectNameEditable() {
        return (String)mObj.get('Project_Name_Editable__c');
    }
    public void setProjectNameEditable(String projectNameToSet) {
        mObj.put('Project_Name_Editable__c', projectNameToSet);
    }
    public String getProjectGroup() {
        return (String)mObj.get('Project_Group_Editable__c');
    }
    public void setProjectGroup(String projectGroupToSet) {
        mObj.put('Project_Group_Editable__c', projectGroupToSet);
    }
    public String getLocationCityEditable() {
        return (String)mObj.get('Location_City_Editable__c');
    }
    public void setLocationCityEditable(String locationCityToSet) {
        mObj.put('Location_City_Editable__c', locationCityToSet);
    }
    public String getClientNameEditable() {
        return (String)mObj.get('Client_Name_Editable__c');
    }
    public void setClientNameEditable(String clientNameToSet) {
        mObj.put('Client_Name_Editable__c', clientNameToSet);
    }
    public String getProjectNumberEditable() {
        return (String)mObj.get('Project_Number_Editable__c');
    }
    public void setProjectNumberEditable(String projectNumberToSet) {
        mObj.put('Project_Number_Editable__c', projectNumberToSet);
    }

    public String getLocationCountryEditable() {
        return (String) mObj.get('Location_Country_Editable__c');
    }
    public void setLocationCountryEditable(String locationCountryToSet) {
        mObj.put('Location_Country_Editable__c', locationCountryToSet);
    }
    public String getLocationStateProvinceEditable() {
        return (String) mObj.get('Location_State_Prov_Emirate_Editable__c');
    }
    public void setLocationStateProvinceEditable(String locationStateProvEmirateToSet) {
        mObj.put('Location_State_Prov_Emirate_Editable__c', locationStateProvEmirateToSet);
    }
    public Id getWorkHistory() {
        return (Id) mObj.get('Work_History__c');
    }
    public void setWorkHistory(Id workHistoryToSet) {
        mObj.put('Work_History__c', workHistoryToSet);
    }

    public String getWorkHistoryName() {
        return getWorkHistory() != null ? this.getPRObj().Work_History__r.Company_Name__c : '';
    }
    public Boolean getAddedByEmployee() {
        return (Boolean) mObj.get('Added_By_Employee__c');
    }
    public void setAddedByEmployee(Boolean isAddedByEmployee) {
        mObj.put('Added_By_Employee__c', isAddedByEmployee);
    }

    public Integer getGroupSequence() {
        return Integer.valueOf(mObj.get('Group_Sequence__c'));
    }
    public void setGroupSequence(Integer seq) {
        mObj.put('Group_Sequence__c', seq);
    }
    public Integer getProjectSequence() {
        return Integer.valueOf(mObj.get('Project_Sequence__c'));
    }
    public void setProjectSequence(Integer seq) {
        mObj.put('Project_Sequence__c', seq);
    }

    public Boolean getIsPendingOrInReview() {
        return (getStatus() == rsPRTeamEmployee.S_PENDING) || (getStatus() == rsPRTeamEmployee.S_INREVIEW);
    }

    public Boolean getIsApproved() {
        return getStatus() == S_APPROVED;
    }

    public Boolean getIsArchived() {
        return getStatus() == S_ARCHIVED;
    }

    public Boolean getIsNonAECOMProject() {
        return mObj.get('Non_AECOM_Project__c') != null ? (Boolean) mObj.get('Non_AECOM_Project__c') || getRecordTypeId() == getRecordTypeIdByName(RT_NONAECOMPROJECT) : false;
    }

    public String getLastModifiedName() {
        return ((PR_Team_Employee__c)mObj).LastModifiedBy.Name;
    }

    public String getLastModifedDate() {
        return ((PR_Team_Employee__c)mObj).LastModifiedDate.format();
    }

    public Id getOwnerId() {
        return (Id)mObj.get('OwnerId');
    }
    public void setOwnerId(Id OwnerId) {
        mObj.put('OwnerId', OwnerId);
    }


    public override Integer compareTo(Object compareTo) {
        rsPRTeamEmployee compareItem = (rsPRTeamEmployee)compareTo;
        if (compareItem.getGroupSequence() != null && getGroupSequence() != null) {
            if (compareItem.getGroupSequence() == getGroupSequence()) {
                if (compareItem.getProjectSequence() != null && getProjectSequence() != null) {
                    return getProjectSequence() - compareItem.getProjectSequence();
                } else if (compareItem.getProjectSequence() == null) {
                    return -1;
                } else {
                    return 1;
                }
            } else {
                return getGroupSequence() - compareItem.getGroupSequence();
            }
        } else if (compareItem.getGroupSequence() == null) {
            return -1;
        } else {
            return 1;
        }
    }

    public class Finder extends rsFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            Set<String> fieldSet = new Set<String> {
                'RecordTypeId',
                'Initial_Locale__c',
                'Client__c',
                'Client_Name_Editable__c',
                'Date_Involvement_Ended__c',
                'Date_Involvement_Started__c',
                'Date_Time_Sent_for_Review__c',
                'Group_Sequence__c',
                'Location_City__c',
                'Location_City_Editable__c',
                'Location_Country__c',
                'Location_State_Prov_Emirate__c',
                'Next_Project_Part__c',
                'Output_on_Resume__c',
                'Previous_Project_Part__c',
                'Project_ID__c',
                'Project_Name__c',
                'Project_Name_Editable__c',
                'Project_Group_Editable__c',
                'Project_Number_Calculated__c',
                'Project_Number_Editable__c',
                'Project_Sequence__c',
                'Description__c',
                'Status__c',
                'EmployeeUser__c',
                'Added_By_Employee__c',
                'Work_History__c',
                'Non_AECOM_Project__c',
                'Project_Id__r.Name',
                'Project_ID__r.Project_Country__c',
                'Previous_Project_Part__r.Project_ID__r.Name',
                'Work_History__r.Company_Name__c',
                'Project_Role__c',
                'Location_Country_Editable__c',
                'Location_State_Prov_Emirate_Editable__c',
                'LastModifiedBy.Name',
                'LastModifiedDate',
                'OwnerId',
                'Location_City_Text__c',
                'Location_Country_Text__c',
                'Location_State_Prov_Emirate_Text__c'
            };
            setFieldSet(fieldSet);
        }

        public override rsModel byId(Id recId) {
            return new rsModel(Database.query(getSelect() + 'where Id =: recId'));
        }

        public List<rsPRTeamEmployee> byIdAsSelfOrProxyOrCM(Id userId) {
            return getByWhere('EmployeeUser__c = ' + rsStringUtil.quote(userId) + ' AND Next_Project_Part__c = null Order By Group_Sequence__c ASC, Project_Sequence__c ASC LIMIT ' + SEARCH_RESULT_SIZE);
        }

        public List<rsPRTeamEmployee> byIdAsEmployee(Id userId) {
            return getByWhere('EmployeeUser__c = ' + rsStringUtil.quote(userId) + ' AND Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_APPROVED) + ' Order By Group_Sequence__c ASC, Project_Sequence__c ASC LIMIT ' + SEARCH_RESULT_SIZE);
        }

        public List<rsPRTeamEmployee> byIdList(List<Id> projIds) {
            return getByWhere('Id IN (\'' + String.join(projIds, '\',\'') + '\')');
        }

        public List<PR_Team_Employee__c> byIdListNonDec(List<Id> projIds) {
            return getByWhereNonDec('Id IN (\'' + String.join(projIds, '\',\'') + '\')');
        }

        public List<rsPRTeamEmployee> byUsers(Set<Id> userIds) {
            List<rsPRTeamEmployee> projects = new List<rsPRTeamEmployee>();
            for (PR_Team_Employee__c project : Database.query(getSelect() + 'where EmployeeUser__c IN: userIds')) {
                projects.add(new rsPRTeamEmployee(project));
            }
            return projects;
        }

        public List<rsPRTeamEmployee> byUsersWhereAndOrder(Set<Id> userIds, String whereStr, String sortVal, String sortDir) {
            List<rsPRTeamEmployee> projects = new List<rsPRTeamEmployee>();
            String whereClause = String.isNotBlank(whereStr) ? '(' + whereStr + ') AND ' : '';
            for (PR_Team_Employee__c project : Database.query(getSelect() + 'where ' + whereClause + ' EmployeeUser__c IN: userIds ORDER BY ' + sortVal + ' ' + sortDir)) {
                projects.add(new rsPRTeamEmployee(project));
            }
            return projects;
        }

        public List<rsPRTeamEmployee> getByWhereAndSelect(String whereStr, String selectStr) {
            System.debug('###' + whereStr);
            List<rsPRTeamEmployee> returnList = new List<rsPRTeamEmployee>();
            List<PR_Team_Employee__c> emps = (List<PR_Team_Employee__c>)Database.query(selectStr + ' where ' + whereStr);
            for (PR_Team_Employee__c pte : emps) {
                returnList.add(new rsPRTeamEmployee(pte));
            }
            return returnList;
        }

        public List<rsPRTeamEmployee> getByWhere(String whereStr) {
            System.debug('###' + whereStr);
            List<rsPRTeamEmployee> returnList = new List<rsPRTeamEmployee>();
            List<PR_Team_Employee__c> emps = (List<PR_Team_Employee__c>)Database.query(getSelect() + ' where ' + whereStr);
            for (PR_Team_Employee__c pte : emps) {
                returnList.add(new rsPRTeamEmployee(pte));
            }
            return returnList;
        }

        public List<PR_Team_Employee__c> getByWhereNonDec(String whereStr) {
            System.debug('###' + whereStr);
            List<PR_Team_Employee__c> emps = (List<PR_Team_Employee__c>)Database.query(getSelect() + ' where ' + whereStr);
            return emps;
        }

        public List<PR_Team_Employee__c> getByWhereNonDec(String whereStr, Set<Id> projIds) {
            System.debug('###' + whereStr);
            List<PR_Team_Employee__c> emps = (List<PR_Team_Employee__c>)Database.query(getSelect() + ' where ' + whereStr + ' OR Id IN: projIds ');
            return emps;
        }

        public List<rsPRTeamEmployee> getByFind(String findStr) {
            List<rsPRTeamEmployee> returnList = new List<rsPRTeamEmployee>();
            String queryString = 'FIND ' + rsStringUtil.quote(findStr) + ' IN ALL FIELDS RETURNING PR_Team_Employee__c(' + getFields() + ')';
            List<List<SObject>> resultList = search.query(queryString);
            System.debug('#### queryString getByFind rsPRTeamEmployee: ' + queryString);
            for (PR_Team_Employee__c pte : (List<PR_Team_Employee__c>)resultList[0]) {
                returnList.add(new rsPRTeamEmployee(pte));
            }
            return returnList;
        }

        public List<PR_Team_Employee__c> getByFindNonDec(String findStr) {
            String queryString = 'FIND ' + rsStringUtil.quote(findStr) + ' IN ALL FIELDS RETURNING PR_Team_Employee__c(' + getFields() + ')';
            List<List<SObject>> resultList = search.query(queryString);
            System.debug('#### queryString getByFind rsPRTeamEmployee: ' + queryString);
            return (List<PR_Team_Employee__c>)resultList[0];
        }


        // ---- The following 4 methods (and 1 util method) are used on profile reviews ---- //
        //All 4 methods check BOTH the project approval status and the User approval status
        public List<rsPRTeamEmployee> reviewUnassigned(DateTime searchDateTimeSentForReviewStart, DateTime searchDateTimeSentForReviewStop, String searchLastName, String searchFirstName, String searchGeography, String searchCountry, String searchAssignee, String superGeography, String sortDir) {
            String selectStr = 'SELECT Id, RecordTypeId, Date_Time_Sent_for_Review__c, Status__c, EmployeeUser__r.Profile_Reviewer__c, EmployeeUser__r.Profile_Reviewer__r.Name, EmployeeUser__r.FirstName, EmployeeUser__r.Name, EmployeeUser__r.LastName, EmployeeUser__r.Manager.Name, EmployeeUser__r.Geography__c, EmployeeUser__r.Region__c, EmployeeUser__r.Country, EmployeeUser__r.Office__c, EmployeeUser__r.Business_Line__c, Previous_Project_Part__c from PR_Team_Employee__c';
            String whereStr = ' EmployeeUser__r.Profile_Reviewer__c = null AND Next_Project_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsPRTeamEmployee.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_PENDING) + ') AND (EmployeeUser__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR EmployeeUser__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )' ;
            if ( !String.isBlank(superGeography) ) {
                if (rs_Additional_Geography_Countries__c.getInstance(superGeography) != null) {
                    whereStr += ' AND (EmployeeUser__r.Supergeography__c LIKE ' + rsStringUtil.quote(superGeography + '%') + ' OR EmployeeUser__r.Country IN ' + createStringInSet(rs_Additional_Geography_Countries__c.getInstance(superGeography).Countries__c) + ') ';
                } else {
                    whereStr += ' AND (EmployeeUser__r.Supergeography__c LIKE ' + rsStringUtil.quote(superGeography + '%') + ')';
                }
            }
            whereStr += buildFilterStrForReview(searchDateTimeSentForReviewStart, searchDateTimeSentForReviewStop, searchLastName, searchFirstName, searchGeography, searchCountry, searchAssignee);
            whereStr += ' ORDER BY Date_Time_Sent_for_Review__c ' + sortDir;
            return getByWhereAndSelect(whereStr, selectStr);

        }

        public List<rsPRTeamEmployee> reviewAllPending(DateTime searchDateTimeSentForReviewStart, DateTime searchDateTimeSentForReviewStop, String searchLastName, String searchFirstName, String searchGeography, String searchCountry, String searchAssignee, String sortDir) {
            String selectStr = 'SELECT Id, RecordTypeId, Date_Time_Sent_for_Review__c, Status__c, EmployeeUser__r.Profile_Reviewer__c, EmployeeUser__r.Profile_Reviewer__r.Name, EmployeeUser__r.FirstName, EmployeeUser__r.Name, EmployeeUser__r.LastName, EmployeeUser__r.Manager.Name, EmployeeUser__r.Geography__c, EmployeeUser__r.Region__c, EmployeeUser__r.Country, EmployeeUser__r.Office__c, EmployeeUser__r.Business_Line__c, Previous_Project_Part__c from PR_Team_Employee__c';
            String whereStr = ' EmployeeUser__r.Profile_Reviewer__c = null AND Next_Project_Part__c = null AND Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_PENDING);
            whereStr += buildFilterStrForReview(searchDateTimeSentForReviewStart, searchDateTimeSentForReviewStop, searchLastName, searchFirstName, searchGeography, searchCountry, searchAssignee);
            whereStr += ' ORDER BY Date_Time_Sent_for_Review__c ' + sortDir;
            return getByWhereAndSelect(whereStr, selectStr);

        }

        public List<rsPRTeamEmployee> reviewAssigned(DateTime searchDateTimeSentForReviewStart, DateTime searchDateTimeSentForReviewStop, String searchLastName, String searchFirstName, String searchGeography, String searchCountry, String searchAssignee, String sortDir) {
            String selectStr = 'SELECT Id, RecordTypeId, Date_Time_Sent_for_Review__c, Status__c, EmployeeUser__r.Profile_Reviewer__c, EmployeeUser__r.Profile_Reviewer__r.Name, EmployeeUser__r.FirstName, EmployeeUser__r.Name, EmployeeUser__r.LastName, EmployeeUser__r.Manager.Name, EmployeeUser__r.Geography__c, EmployeeUser__r.Region__c, EmployeeUser__r.Country, EmployeeUser__r.Office__c, EmployeeUser__r.Business_Line__c, Previous_Project_Part__c from PR_Team_Employee__c';
            String whereStr = ' EmployeeUser__r.Profile_Reviewer__c != null AND Next_Project_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsPRTeamEmployee.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_PENDING) + ') AND (EmployeeUser__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR EmployeeUser__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )' ;
            whereStr += buildFilterStrForReview(searchDateTimeSentForReviewStart, searchDateTimeSentForReviewStop, searchLastName, searchFirstName, searchGeography, searchCountry, searchAssignee);
            whereStr += ' ORDER BY Date_Time_Sent_for_Review__c ' + sortDir;
            return getByWhereAndSelect(whereStr, selectStr);
        }

        public List<rsPRTeamEmployee> reviewAssignedToMe(String id, DateTime searchDateTimeSentForReviewStart, DateTime searchDateTimeSentForReviewStop, String searchLastName, String searchFirstName, String searchGeography, String searchCountry, String searchAssignee, String sortDir) {
            String selectStr = 'SELECT Id, RecordTypeId, Date_Time_Sent_for_Review__c, Status__c, EmployeeUser__r.Profile_Reviewer__c, EmployeeUser__r.Profile_Reviewer__r.Name, EmployeeUser__r.FirstName, EmployeeUser__r.Name, EmployeeUser__r.LastName, EmployeeUser__r.Manager.Name, EmployeeUser__r.Geography__c, EmployeeUser__r.Region__c, EmployeeUser__r.Country, EmployeeUser__r.Office__c, EmployeeUser__r.Business_Line__c, Previous_Project_Part__c from PR_Team_Employee__c';
            String whereStr = ' EmployeeUser__r.Profile_Reviewer__c = ' + rsStringUtil.quote(id) + ' AND Next_Project_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsPRTeamEmployee.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_PENDING) + ') AND (EmployeeUser__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR EmployeeUser__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )' ;
            whereStr += buildFilterStrForReview(searchDateTimeSentForReviewStart, searchDateTimeSentForReviewStop, searchLastName, searchFirstName, searchGeography, searchCountry, searchAssignee);
            whereStr += ' ORDER BY Date_Time_Sent_for_Review__c ' + sortDir;
            return getByWhereAndSelect(whereStr, selectStr);
        }

        public List<rsPRTeamEmployee> reviewCompleted(DateTime searchDateTimeSentForReviewStart, DateTime searchDateTimeSentForReviewStop, String searchLastName, String searchFirstName, String searchGeography, String searchCountry, String searchAssignee, String sortDir) {
            String selectStr = 'SELECT Id, RecordTypeId, Date_Time_Sent_for_Review__c, Status__c, EmployeeUser__r.Profile_Reviewer__c, EmployeeUser__r.Profile_Reviewer__r.Name, EmployeeUser__r.FirstName, EmployeeUser__r.Name, EmployeeUser__r.LastName, EmployeeUser__r.Manager.Name, EmployeeUser__r.Geography__c, EmployeeUser__r.Region__c, EmployeeUser__r.Country, EmployeeUser__r.Office__c, EmployeeUser__r.Business_Line__c, Previous_Project_Part__c from PR_Team_Employee__c';
            String whereStr = ' Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_APPROVED) + 'AND Next_Project_Part__c = null AND Date_Time_Sent_for_Review__c != null AND EmployeeUser__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_APPROVED);
            whereStr += buildFilterStrForReview(searchDateTimeSentForReviewStart, searchDateTimeSentForReviewStop, searchLastName, searchFirstName, searchGeography, searchCountry, searchAssignee);
            whereStr += ' ORDER BY Date_Time_Sent_for_Review__c ' + sortDir + ' LIMIT ' + LIST_SIZE_LIMIT;
            return getByWhereAndSelect(whereStr, selectStr);
        }

        private String buildFilterStrForReview(DateTime searchDateTimeSentForReviewStart, DateTime searchDateTimeSentForReviewStop, String searchLastName, String searchFirstName, String searchGeography, String searchCountry, String searchAssignee) {
            String filterStr = '';
            Boolean isAndAdded = false;
            if (searchDateTimeSentForReviewStart != null && searchDateTimeSentForReviewStop != null ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' (EmployeeUser__r.Date_Time_Sent_for_Review__c >= ' + searchDateTimeSentForReviewStart.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' AND EmployeeUser__r.Date_Time_Sent_for_Review__c <= ' + searchDateTimeSentForReviewStop.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ')';
            } else if (searchDateTimeSentForReviewStart != null ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' EmployeeUser__r.Date_Time_Sent_for_Review__c >= ' + searchDateTimeSentForReviewStart.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            } else if (searchDateTimeSentForReviewStop != null ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' EmployeeUser__r.Date_Time_Sent_for_Review__c <= ' + searchDateTimeSentForReviewStop.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            }

            if (String.isNotBlank(searchLastName) ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' EmployeeUser__r.LastName LIKE ' + rsStringUtil.likeQueryQuote(searchLastName);
            }
            if (String.isNotBlank(searchFirstName) ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' EmployeeUser__r.FirstName LIKE ' + rsStringUtil.likeQueryQuote(searchFirstName);
            }
            if (String.isNotBlank(searchGeography) ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' EmployeeUser__r.Geography__c LIKE ' + rsStringUtil.likeQueryQuote(searchGeography);
            }
            if (String.isNotBlank(searchCountry) ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' EmployeeUser__r.Country LIKE ' + rsStringUtil.likeQueryQuote(searchCountry);
            }
            if (String.isNotBlank(searchAssignee) ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' ( EmployeeUser__r.Profile_Reviewer__r.FirstName LIKE ' + rsStringUtil.likeQueryQuote(searchAssignee) + 'OR EmployeeUser__r.Profile_Reviewer__r.LastName LIKE ' + rsStringUtil.likeQueryQuote(searchAssignee) + ')';
            }
            if (isAndAdded) {
                filterStr += ')';
            }
            return filterStr;
        }

        public List<SelectOption> getProjectGroupsByUserId(String userId) {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--' + Label.None + '--'));
            if (String.isNotBlank(userId)) {
                String query = 'Select Project_Group_Editable__c pGroup ' +
                               'from PR_Team_Employee__c ' +
                               'where EmployeeUser__c =: userId ' +
                               'Group By Project_Group_Editable__c ' +
                               'Order by Project_Group_Editable__c ASC';
                for (AggregateResult result : (List<AggregateResult>)Database.query(query)) {
                    Object val = result.get('pGroup');
                    if (val != null) {
                        options.add(new SelectOption((String)val, (String)val));
                    }
                }
            }
            return options;
        }

        public List<SelectOption> getProjectNamesByUserId(String userId) {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--' + Label.None + '--'));
            if (String.isNotBlank(userId)) {
                String query = 'Select Project_Name_Editable__c pName, Project_ID__r.Name prName ' +
                               'from PR_Team_Employee__c ' +
                               'where EmployeeUser__c =: userId ' +
                               'Group By Project_ID__r.Name,Project_Name_Editable__c';
                Set<String> projectNames = new Set<String>();
                for (AggregateResult result : (List<AggregateResult>)Database.query(query)) {
                    Object val = result.get('pName');
                    Object val2 = result.get('prName');
                    if (val != null) {
                        projectNames.add((String)val);
                    }
                    if (val2 != null) {
                        projectNames.add((String)val2);
                    }
                }
                for (String projectName : projectNames) {
                    options.add(new SelectOption(projectName, projectName));
                }
                options.sort();
            }
            return options;
        }

        public List<SelectOption> getClientNamesByUserId(String userId) {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--' + Label.None + '--'));
            if (String.isNotBlank(userId)) {
                String query = 'Select Client__c cName ' +
                               'from PR_Team_Employee__c ' +
                               'where EmployeeUser__c =: userId ' +
                               'Group By Client_Name_Editable__c, Client__c, Client_Name__c ' +
                               'Order by Client_Name_Editable__c, Client__c, Client_Name__c ASC';
                Set<String> clientNames = new Set<String>();
                for (AggregateResult result : (List<AggregateResult>)Database.query(query)) {
                    Object val = result.get('cName');
                    if (val != null) {
                        clientNames.add((String)val);
                    }
                }
                for (String clientName : clientNames) {
                    options.add(new SelectOption(clientName, clientName));
                }
            }
            options.sort();
            return options;
        }

        public List<SelectOption> getLocationCountriesByUserId(String userId) {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--' + Label.None + '--'));
            if (String.isNotBlank(userId)) {
                String query = 'Select Project_ID__r.Project_Country__c projCountry, Location_Country_Editable__c editCountry ' +
                               'from PR_Team_Employee__c ' +
                               'where EmployeeUser__c =: userId ' +
                               'Group By Project_ID__r.Project_Country__c, Location_Country_Editable__c ' +
                               'Order by Project_ID__r.Project_Country__c ASC, Location_Country_Editable__c ASC';
                Set<String> countries = new Set<String>();
                for (AggregateResult result : (List<AggregateResult>)Database.query(query)) {
                    Object val1 = result.get('projCountry');
                    Object val2 = result.get('editCountry');
                    if (val1 != null) {
                        countries.add((String)val1);
                    }
                    if (val2 != null) {
                        countries.add((String)val2);
                    }
                }
                for (String country : countries) {
                    options.add(new SelectOption(country, country));
                }
                options.sort();
            }
            return options;
        }

        public List<SelectOption> getLocationCitiesByUserId(String userId) {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--' + Label.None + '--'));
            if (String.isNotBlank(userId)) {
                String query = 'Select Project_ID__r.Project_City__c pCity, Location_City_Editable__c eCity ' +
                               'from PR_Team_Employee__c ' +
                               'where EmployeeUser__c =: userId ' +
                               'Group By Project_ID__r.Project_City__c, Location_City_Editable__c ' +
                               'Order by Project_ID__r.Project_City__c ASC, Location_City_Editable__c ASC';
                Set<String> countries = new Set<String>();
                for (AggregateResult result : (List<AggregateResult>)Database.query(query)) {
                    Object val1 = result.get('pCity');
                    Object val2 = result.get('eCity');
                    if (val1 != null) {
                        countries.add((String)val1);
                    }
                    if (val2 != null) {
                        countries.add((String)val2);
                    }
                }
                for (String country : countries) {
                    options.add(new SelectOption(country, country));
                }
                options.sort();
            }
            return options;
        }

        public List<SelectOption> getRecordTypes() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--' + Label.None + '--'));
            options.add(new SelectOption(mRtInfo.get(rsPRTeamEmployee.RT_AECOMPROJECT).getRecordTypeId(), rsPRTeamEmployee.RT_AECOMPROJECT));
            options.add(new SelectOption(mRtInfo.get(rsPRTeamEmployee.RT_NONAECOMPROJECT).getRecordTypeId(), rsPRTeamEmployee.RT_NONAECOMPROJECT));
            return options;
        }

        public List<SelectOption> getStatusOptions() {
            List<SelectOption> options = new List<SelectOption>();
            sObject sObj = Schema.getGlobalDescribe().get('PR_Team_Employee__c').newSObject();
            options.add(new SelectOption('', '--' + Label.None + '--'));
            for (SelectOption op : rsDataUtils.getPicklistValues(sObj, 'Status__c')) {
                if (op.getValue() != S_INREVIEW) {
                    options.add(op);
                }
            }
            options.add(new SelectOption(Label.All, Label.All));
            return options;
        }

        public List<rsPRTeamEmployee> byCriteria(rsPRTeamEmployeeCriteria criteria) {
            String whereStr = criteria.getWhereClause() + ' Order By Group_Sequence__c ASC, Project_Sequence__c ASC, CreatedDate DESC LIMIT ' + SEARCH_RESULT_SIZE ;
            if (String.isNotBlank(criteria.SearchText) && criteria.SearchText.length() > 1) {
                String query = 'FIND ' + rsStringUtil.quote(criteria.SearchText + '*') + ' IN ALL FIELDS RETURNING ' +
                               'PR_Team_Employee__c( ' + getFields() +  ' where ' + whereStr + ')';
                System.debug('BY CRITERIA QUERY: ' + query);
                List<List<SObject>> soslRequestList = Search.query(query);
                List<rsPRTeamEmployee> returnList = new List<rsPRTeamEmployee>();
                for (PR_Team_Employee__c emp : (List<PR_Team_Employee__c>)soslRequestList[0]) {
                    returnList.add(new rsPRTeamEmployee(emp));
                }
                return returnList;
            } else if (String.isBlank(criteria.SearchText)) {
                return getByWhere(whereStr);
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MIN2CHAR));
                return new List<rsPRTeamEmployee>();
            }
        }

    }



    public static final String RT_AECOMPROJECT = 'AECOM Project';
    public static final String RT_NONAECOMPROJECT = 'Non-AECOM Project';

    //Statuses for the Status__c field
    public static final String S_APPROVED = 'Approved';
    public static final String S_PENDING = 'Pending';
    public static final String S_INREVIEW = 'In Review';
    public static final String S_ARCHIVED = 'Archived';

    //Status All for filter selction option
    public static final String S_ALL = 'All';

    //Key for Projects with unspecified Project Groups
    public static final String K_UNSPECIFIED = 'Unspecified';
}