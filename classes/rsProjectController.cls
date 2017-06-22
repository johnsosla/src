/*************************************************************************
*
* PURPOSE: Controller for the project component used on the rsProject.page
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public with sharing class rsProjectController extends rsSectionController {
    public rsPRTeamEmployee CurrentProject {get; set;}
    private rsPRTeamEmployee mProject {get; set;}
    public String projectKeyPrefix {get; private set;}
    public String profilePartKeyPrefix {get; private set;}
    public String SelectedProjectType {get; set;}
    public String FilterStatus {get; set;}
    public rsFilterManager Filter {get; set;}

    private String mProjectGroupsAutoComplete;

    private Boolean mIsExistingAECOMProject;
    private Boolean misNewAECOMProject;
    private Boolean misNonAECOMProject;

    //--PAGINATION VARIABLES
    private List<rsProjectViewModel> allViewModels;
    private List<Id> allViewModelIds;
    private Map<String, Integer> projectKeyLocation;
    private final Integer PROJECT_RESULT_LIMIT = 20;

    public List<SelectOption> countryList {get; set;} //Country list taken from Profile Parts

    public rsProjectController() {
        super();
        setResultLimit(PROJECT_RESULT_LIMIT);
        setViewLimit(PROJECT_RESULT_LIMIT);
        TotalParts = 0;
        mIsExistingAECOMProject = true;
        mIsNewAECOMProject = false;
        mIsNonAECOMProject = false;
        projectKeyPrefix = Project__c.SObjectType.getDescribe().getKeyPrefix();
        profilePartKeyPrefix = rs_Profile_Part__c.SObjectType.getDescribe().getKeyPrefix();
        CurrentProject = new rsPRTeamEmployee();
        mRecordType = rsPRTeamEmployee.RT_AECOMPROJECT;
        //--Pagination stuff
        if (PageNum == null) {
            PageNum = 1;
        }
        projectKeyLocation = new Map<String, Integer>();

        //Country List population
        sObject sObj = Schema.getGlobalDescribe().get('rs_Profile_Part__c').newSObject() ;
        countryList = rsDataUtils.getPicklistValues(sObj, 'Country__c');
    }

    public override PageReference newPart() {
        mIsError = false;
        CurrentProject = new rsPRTeamEmployee(profile.getId(), mRecordType);
        CurrentProject.setOutputOnResume(true);
        CurrentProject.setInitialLocale(UserInfo.getLocale() );
        enableEditMode();
        if (ApexPages.currentPage().getParameters().get('cmNewPart') == 'true') {
            newAECOMProjectView();
        }
        return null;
    }

    public override PageReference savePart() {
        savePart(false);
        return null;
    }

    public override PageReference savePart(Boolean saveAndApprove) {
        mIsError = false;
        //First check if their profile has been locked while they were editing this part, unless they are a content manager that locked it, in which case they can save just fine
        User profileRequery = getUser();
        if (profileRequery.Profile_Reviewer__c != UserInfo.getUserId() && profileRequery.Is_Profile_Locked__c ) {
            String lockerUrl = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + '/' + profile.getUser().Profile_Reviewer__c;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, Label.Profile_Locked_By_CM + ' <a target="_blank" href="' + lockerUrl + '">' + profile.getUser().Profile_Reviewer__r.Name + ' </a>'));
            mIsError = true;
            return null;
        }

        if (mIsExistingAECOMProject) {
            String whereStr = ' EmployeeUser__c = ' + rsStringUtil.quote(profile.getId()) + ' AND Project_Id__c = ' + rsStringUtil.quote(CurrentProject.getProjectId()) + ' AND Status__c != ' + rsStringUtil.quote(rsPRTeamEmployee.S_ARCHIVED) + ' AND Next_Project_Part__c = null';
            if (mProject != null) {
                whereStr +=  ' AND Id != ' + rsStringUtil.quote(mProject.getId());
            }
            if (rsPRTeamEmployee.find.getByWhere(whereStr).size() > 0) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Project_Already_Added));
                CurrentProject.setProjectId(null);
                mIsError = true;
                return null;
            }
        }

        Boolean isExistingProject = false;
        Integer i = -1;
        for (rsPRTeamEmployee project : profile.getProfileProjects()) {
            i++;
            //If it's our current project OR it's our previous project (this case happens when we save and validation fails and our CurrentProject doesn't have an ID yet but is still should be existing project)
            if (project.getId() == CurrentProject.getId() || (CurrentProject.getId() == null && mProject != null && project.getId() == mProject.getId()) ) {
                isExistingProject = true;
                break;
            }
        }
        //If the status is pending then we'll just save our changes on the old record, no reason to clone
        if (isExistingProject && !mProject.getIsPendingOrInReview() ) {
            PR_Team_Employee__c clone = (PR_Team_Employee__c)CurrentProject.getObj().clone(false, true, false, false);
            clone.Previous_Project_Part__c = CurrentProject.getId();
            clone.ChkUniqueEmp__c = null;
            CurrentProject = new rsPRTeamEmployee(clone);
        }
        setFieldsForSave(CurrentProject, profileRequery, saveAndApprove);


        //TODO We might be able to remove this if statement (below) that checks if we auto-approve, since in setFieldsForSave() called above,
        //we call approval util, which should do this kind of checking for us

        //If this project is auto-approved, then we need to archive the old project before we can save Current to keep the ChkUniqueEmp WF rule happy

        // --------------------------------------
        // The code below appears to be breaking the Save and Approve functionality (AECR-1583). Per TODO comment from a year ago above this
        // may no longer be needed.
        //if (CurrentProject.getStatus() == rsPRTeamEmployee.S_APPROVED && mProject != null) {
        //    System.debug('Archiving project below this line: CurrentProject.getStatus() == rsPRTeamEmployee.S_APPROVED && mProject != null');
        //    mProject.setStatus(rsPRTeamEmployee.S_ARCHIVED);
        //    mProject.setProjectId(null);
        //    mProject.getPRObj().ChkUniqueEmp__c = null;
        //    mProject.save();
        //}
        // --------------------------------------

        try {
            CurrentProject.save();
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
            System.debug ('!!Exception on project save. ' + ex + ex.getStackTraceString());
            mIsError = true;
            return null;
        }

        //Requery the part to get the formula fields evaluated
        CurrentProject = new rsPRTeamEmployee((PR_Team_Employee__c)rsPRTeamEmployee.find.byId(CurrentProject.getId()).getObj());
        CurrentProject.setLocationCountryText(CurrentProject.getLocationCountry());
        CurrentProject.setLocationStateProvinceText(CurrentProject.getLocationStateProvince());
        CurrentProject.setLocationCityText(CurrentProject.getLocationCity());
        CurrentProject.save();
        //Again if the status is pending, we don't need to update the pointer because we aren't cloning to a new object
        if (isExistingProject && !mProject.getIsPendingOrInReview() ) {
            if (mProject.getId() != CurrentProject.getId()) {
                mProject.setNextProjectPart(CurrentProject.getId());
            }
            try {
                mProject.save();
            } catch (DmlException ex) {
                ApexPages.addMessages(ex);
                //System.debug ('!!Exception on old project save. ' + ex + ex.getStackTraceString());
                mIsError = true;
                return null;
            }
        }

        //If this is a new project, or an existing one that wasn't cloned then we need to add it to the list
        if (!isExistingProject) {
            if (profile.getProfileProjects().isEmpty()) {
                profile.getProfileProjects().add(CurrentProject);
            } else {
                profile.getProfileProjects().add(0, CurrentProject);
            }
        } else { //Else we'll just replace the object in the list with updated object
            profile.getProfileProjects().set(i, CurrentProject);
        }
        existingAECOMProjectView();
        mProject = null;
        enableListMode();
        SelectedProjectType = EXISTING_PROJECT;
        updateUserProfileTimestamps();
        updateUserSummary();
        return null;
    }

    public override PageReference saveAndApprove() {
        savePart(true);
        return null;
    }

    private void setFieldsForSave(rsPRTeamEmployee projectPart, User currentUser, Boolean saveAndApprove) {
        setTrackingFields();
        projectPart.setAddedByEmployee(true);
        if (isReviewable(mRecordType, currentUser) || (!saveAndApprove && projectPart.getIsPendingOrInReview())) {
            //System.debug('In reviewable block of setFieldsForSave()');
            projectPart.setDateTimeSentForReview(Datetime.now());
            if (String.isNotBlank(profile.getAssignedContentManagerId())) {
                profile.setProfileReviewer(profile.getAssignedContentManagerId());
            }
            if (profile.getDateTimeSentforReview() == null) {
                profile.setDateTimeSentforReview(Datetime.now());
                profile.setStatus(rsProfile.S_PENDING);
            }
            profile.save();
            projectPart.setStatus(rsPRTeamEmployee.S_PENDING);
        } else {
            rsApprovalUtil.approveProjectPart(projectPart, profile);
        }
    }

    public override PageReference cancelPart() {
        mIsError = false;
        CurrentProject = null;
        mProject = null;
        existingAECOMProjectView();
        enableListMode();
        SelectedProjectType = EXISTING_PROJECT;
        return null;
    }

    public override PageReference deletePart() {
        List<rsPRTeamEmployee> projects = profile.getProfileProjects();
        rsPRTeamEmployee project = null;
        Boolean keepUserLocked = false;
        Integer projectIndex = null;
        for (Integer i = 0; i < projects.size(); i++) {
            if (projects[i].getId() == ApexPages.currentPage().getParameters().get('projectId')) {
                projectIndex = i;
                if (profile.getStatus() == rsProfile.S_INREVIEW) {
                    keepUserLocked = profile.shouldProfileStayLocked( projects[i].getId() );
                }
                break;
            }
        }
        project = projects.remove(projectIndex);

        if (!keepUserLocked) {
            profile.setLock(false);
            profile.setDateTimeSentforReview(null);
            profile.setStatus(rsProfile.S_APPROVED);
            profile.setProfileReviewer(null);
            profile.save();
        }

        //If this part is (pending or in review) and it has a previously approved part, before we delete this one, we archive the old one, so neither will show up in the list.
        if ( (project.getStatus() == rsPRTeamEmployee.S_PENDING || project.getStatus() == rsPRTeamEmployee.S_INREVIEW) && (project.getPreviousProjectPart() != null) ) {
            rsPRTeamEmployee previousProject = new rsPRTeamEmployee( (PR_Team_Employee__c)rsPRTeamEmployee.find.byId(project.getPreviousProjectPart()).getObj() );
            previousProject.setStatus(rsPRTeamEmployee.S_ARCHIVED);
            previousProject.save();
        }
        if (getCanEdit() && project.getOwnerId() != UserInfo.getUserId()) {
            project.setOwnerId(UserInfo.getUserId());
            project.save();
        }

        project.destroy();
        CurrentProject = null;
        enableListMode();
        if ( getProjectViewParts().size() == 0) {

            getPreviousPage();
        }
        return null;
    }

    public override PageReference editPart() {
        for (rsPRTeamEmployee tempProject : profile.getProfileProjects()) {
            if (tempProject.getId() == ApexPages.currentPage().getParameters().get('projectId')) {
                enableEditMode();
                mProject = tempProject;
                CurrentProject = new rsPRTeamEmployee((PR_Team_Employee__c)tempProject.getObj().clone(true, true, false, false));

                if ( (CurrentProject.getRecordTypeId() == rsPRTeamEmployee.getRecordTypeIdByName(rsPRTeamEmployee.RT_AECOMPROJECT) && CurrentProject.getProjectId() != null || (CurrentProject.getPRObj().Previous_Project_Part__c != null && CurrentProject.getPRObj().Previous_Project_Part__r.Project_Id__c != null) ) ) {
                    existingAECOMProjectView();
                } else if ( (CurrentProject.getRecordTypeId() == rsPRTeamEmployee.getRecordTypeIdByName(rsPRTeamEmployee.RT_AECOMPROJECT) && CurrentProject.getProjectId() == null ) ) {
                    newAECOMProjectView();
                } else if ( CurrentProject.getRecordTypeId() == rsPRTeamEmployee.getRecordTypeIdByName(rsPRTeamEmployee.RT_NONAECOMPROJECT) ) {
                    nonAECOMProjectView();
                }
                break;
            }
        }
        //System.assert(CurrentProject != null);
        return null;
    }

    public PageReference archivePart() {
        Integer projectIndex = 0;
        for (rsPRTeamEmployee tempProject : profile.getProfileProjects()) {
            if (tempProject.getId() == ApexPages.currentPage().getParameters().get('projectId')) {
                tempProject.setStatus(rsPRTeamEmployee.S_ARCHIVED);
                tempProject.save();
                enableListMode();
                CurrentProject = null;
                break;
            }
            projectIndex++;
        }
        if (FilterStatus != rsPRTeamEmployee.S_ALL) {
            profile.getProfileProjects().remove(projectIndex);
        }
        return null;
    }

    public PageReference restorePart() {
        Integer projectIndex = 0;
        for (rsPRTeamEmployee tempProject : profile.getProfileProjects()) {
            if (tempProject.getId() == ApexPages.currentPage().getParameters().get('projectId')) {
                //System.debug(tempProject.getId());
                tempProject.setStatus(rsPRTeamEmployee.S_APPROVED);
                tempProject.save();
                enableListMode();
                CurrentProject = null;
                break;
            }
            projectIndex++;
        }
        if (FilterStatus != rsPRTeamEmployee.S_ALL) {
            profile.getProfileProjects().remove(projectIndex);
        }
        return null;
    }

    public override PageReference viewPart() {
        for (rsPRTeamEmployee tempProject : profile.getProfileProjects()) {
            if (tempProject.getId() == ApexPages.currentPage().getParameters().get('projectId')) {
                enableViewMode();
                CurrentProject = tempProject;
                break;
            }
        }
        return null;
    }

    public override PageReference approvePart() {
        String partId = ApexPages.currentPage().getParameters().get('partId');
        for (rsPRTeamEmployee profileProject : profile.getProfileProjects() ) {
            if (profileProject.getId() == partId) {
                rsApprovalUtil.approveProjectPart(profileProject, profile);
                break;
            }
        }

        updateUserSummary();

        return null;
    }

    public String getProjectGroupsAutoComplete() {
        mProjectGroupsAutoComplete = rsProfile.find.getAutoCompleteProjectGroups(profile.getId());
        return mProjectGroupsAutoComplete;
    }

    public List<rsPRTeamEmployee> getProfileProjectParts() {
        return profile.getProfileProjects();
    }

    public List<rsPRTeamEmployee> getAllProjects() {
        List<rsPRTeamEmployee> combinedList = new List<rsPRTeamEmployee>();
        for (rsPRTeamEmployee specificProject : Filter.getProjectSearchResults()) {
            if (FilterStatus != rsPRTeamEmployee.S_ARCHIVED && specificProject.getStatus() != rsPRTeamEmployee.S_ARCHIVED) {
                combinedList.add(specificProject);
            } else if ((FilterStatus == rsPRTeamEmployee.S_ARCHIVED || FilterStatus == rsPRTeamEmployee.S_ALL) && specificProject.getStatus() == rsPRTeamEmployee.S_ARCHIVED) {
                combinedList.add(specificProject);
            }
        }
        return combinedList;
    }

    public rsPRTeamEmployee getProject() {
        return mProject;
    }

    public Boolean getIsExistingAECOMProject() {
        return mIsExistingAECOMProject;
    }

    public Boolean getIsNewAECOMProject() {
        return mIsNewAECOMProject;
    }

    public Boolean getIsNonAECOMProject() {
        return mIsNonAECOMProject;
    }
    public void setIsNonAECOMProject(Boolean val) {
        mIsNonAECOMProject = val;
    }

    public PageReference changeProjectTypeView() {
        if (SelectedProjectType == EXISTING_PROJECT) {
            existingAECOMProjectView();
        } else if (SelectedProjectType == NEW_PROJECT) {
            newAECOMProjectView();
        } else {
            nonAecomProjectView();
        }
        return newPart();
    }

    public PageReference existingAECOMProjectView() {
        mRecordType = rsPRTeamEmployee.RT_AECOMPROJECT;
        mIsExistingAECOMProject = true;
        mIsNewAECOMProject = false;
        mIsNonAECOMProject = false;
        return null;
    }

    public PageReference newAECOMProjectView() {
        mRecordType = rsPRTeamEmployee.RT_AECOMPROJECT;
        mIsExistingAECOMProject = false;
        mIsNewAECOMProject = true;
        mIsNonAECOMProject = false;
        return null;
    }

    public PageReference nonAECOMProjectView() {
        mRecordType = rsPRTeamEmployee.RT_NONAECOMPROJECT;
        mIsExistingAECOMProject = false;
        mIsNewAECOMProject = false;
        mIsNonAECOMProject = true;
        return null;
    }

    public PageReference nonAECOMCheckRT() {
        // Set the appropriate project view
        if (mIsNonAECOMProject) {
            mRecordType = rsPRTeamEmployee.RT_NONAECOMPROJECT;
            nonAecomProjectView();
        } else {
            mRecordType = rsPRTeamEmployee.RT_AECOMPROJECT;
            newAECOMProjectView();
        }
        newPart();
        return null;
    }

    public PageReference newNonAECOMPart() {
        mIsNonAECOMProject = true;
        mRecordType = rsPRTeamEmployee.RT_NONAECOMPROJECT;
        nonAecomProjectView();
        newPart();
        return null;
    }

    public PageReference exportProjectsToExcel() {
        // Placeholder obj to hold project list as JSON in an attachment. Will be deleted once the rsProjectExcelExport page loads.
        rs_Search__c results = new rs_Search__c();
        insert results;

        List<rsPRTeamEmployee> outputProjects = new List<rsPRTeamEmployee>();
        for (rsPRTeamEmployee row : getAllProjects()) {
            if (row.getOutputOnResume()) {
                outputProjects.add(row);
            }
        }

        Attachment a = new Attachment();
        a.ParentId = results.Id;
        a.Body = Blob.valueOf(JSON.serialize(outputProjects));
        a.Name = 'ProjectSearchResults';
        insert a;

        PageReference pg = Page.rsProjectExcelExport;
        pg.getParameters().put('id', results.Id);
        return pg;
    }

    //--PAGINATION METHODS

    public List<rsProjectViewModel> getProjectViewParts() {
        String sortField = ApexPages.currentPage().getParameters().get('sortField');
        String pageChange = ApexPages.currentPage().getParameters().get('pageChange');
        projectKeyLocation = new Map<String, Integer>(); // Key Store for when the projects are looped over

        // If the Projects aren't sorted or on a given page, create a new collection because it doesn't exist yet or one of those would be true
        if ((sortField == null && pageChange == null) || Profile.ResetProjects) {
            Boolean isPageRerender = ApexPages.currentPage().getParameters().get('pageRerender') == 'true';
            // build up a new viewModel
            allViewModelIds = new List<Id>();
            Profile.ResetProjects = false;
            if (!isPageRerender) {
                setResultLimit(PROJECT_RESULT_LIMIT);
                setViewLimit(PROJECT_RESULT_LIMIT);
            }
            TotalParts = isPageRerender ? TotalParts : 0;
            PageNum = isPageRerender ? PageNum : 1;
            ViewIndex = isPageRerender ? ViewIndex : 0;
            for (rsPRTeamEmployee part : getAllProjects()) {
                allViewModelIds.add(part.getId());
            }
            system.debug('this is being run');
        }

        // This block checks if a new record was added, and updates ViewLimit
        // TotalParts starts at 0 when defined, if the allViewModels has a larger size continue
        if (TotalParts != null && TotalParts < allViewModelIds.size()) {
            // getResultLimit() = 10 is const from rsSectionController
            if (TotalParts > 0 && getViewLimit() > 0 && getViewLimit() < getResultLimit() * PageNum) {
                if ( (Math.mod(TotalParts, getViewLimit()) < getResultLimit() && Math.mod(TotalParts, getViewLimit()) > 0) || (PageNum == getNumberOfPages() && Math.mod(TotalParts, getResultLimit()) > 0) ) {
                    setViewLimit(getViewLimit() + 1);
                }
            }
        }

        TotalParts = allViewModelIds.size();
        if (TotalParts < getViewLimit() || (TotalParts > 0 && getViewLimit() == 0) ) {
            setViewLimit(TotalParts);
        }
        List<rsProjectViewModel> viewParts = new List<rsProjectViewModel>();

        // Null check
        if (allViewModelIds != null && !allViewModelIds.isEmpty()) {
            //---Add query method
            Map<Id, Integer> viewIds = new Map<Id, Integer>();
            for (Integer i = ViewIndex; i < getViewLimit(); i++) {
                viewIds.put(allViewModelIds[i], i);
            }
            Map<Integer, rsPRTeamEmployee> projectMap = new Map<Integer, rsPRTeamEmployee>();
            Integer viewModelCount = 0;
            for (rsPRTeamEmployee emp : getAllProjects()) {
                if (viewIds.containsKey(emp.getId())) {
                    projectMap.put(viewIds.get(emp.getId()), emp);
                }
            }
            for (Integer i = ViewIndex; i < getViewLimit(); i++) {
                viewParts.add(new rsProjectViewModel(projectMap.get(i)));
            }
        }
        return viewParts;
    }

    //--END PAGINATION METHODS

    public override PageReference sortParts() {
        String sortField = ApexPages.currentPage().getParameters().get('sortField');
        if (String.isNotBlank(sortField)) {

            if (sortField != getLastSortedBy()) {
                setSortOrder('asc');
                rsProjectViewModel.SortOrder = 'asc';
            }

            rsProjectViewModel.SortField = sortField;
            if (getLastSortedBy() != null) {
                if (sortField == getLastSortedBy()) {
                    if (getSortOrder() == 'asc') {
                        setSortOrder('desc');
                        rsProjectViewModel.SortOrder = 'desc';
                    } else {
                        setSortOrder('asc');
                        rsProjectViewModel.SortOrder = 'asc';
                    }
                }
            }
            //---Requery, readd ids
            List<rsProjectViewModel> allViewModels = new List<rsProjectViewModel>();
            for (rsPRTeamEmployee emp : getAllProjects()) {
                allViewModels.add(new rsProjectViewModel(emp));
            }
            allViewModels.sort();
            allViewModelIds.clear();
            for (rsProjectViewModel model : allViewModels) {
                allViewModelIds.add(model.getObj().getId());
            }
            setLastSortedBy(sortField);
        }
        return null;
    }

    private void updateUserSummary() {
        // Map of projectss that will be summarized in user, keys are user Ids
        Map<Id, List<PR_Team_Employee__c>> projects = new Map<Id, List<PR_Team_Employee__c>>();
        Set<Id> alreadyAddedPPIds = new Set<Id>();

        Set<Id> userIds = new Set<Id>();
        userIds.add(profile.getId());

        // Map of Record Types names and their information
        Map<String, Schema.RecordTypeInfo> mRtInfo = PR_Team_Employee__c.SObjectType.getDescribe().getRecordTypeInfosByName();

        //Map of Projects fields, we'll use this for labeling the User summary
        Map<String, Schema.SObjectField> projectFields = Schema.SObjectType.PR_Team_Employee__c.fields.getMap();

        List<User> users = [Select AECOM_Projects_Summary__c, Non_AECOM_Projects_Summary__c
                            from User
                            where Id IN: userIds];


        // Query projects that are approved to recreate the the summary fields
        List<PR_Team_Employee__c> queryPP = (List<PR_Team_Employee__c>)Database.query('Select ' + String.join(new List<String>(projectFields.keySet()), ',') +
                                            ' from PR_Team_Employee__c' +
                                            ' where Id NOT IN: alreadyAddedPPIds' +
                                            ' AND Status__c = ' + rsStringUtil.quote(rsPRTeamEmployee.S_APPROVED) +
                                            ' AND EmployeeUser__c IN: userIds');

        // Add the queried projects to the Map
        for (PR_Team_Employee__c pp : queryPP) {
            if (projects.containsKey(pp.EmployeeUser__c)) {
                projects.get(pp.EmployeeUser__c).add(pp);
            } else projects.put(pp.EmployeeUser__c, new List<PR_Team_Employee__c> {pp});
        }

        Integer aecomLimit = User.AECOM_Projects_Summary__c.getDescribe().getLength();
        Integer nonAecomLimit = User.Non_AECOM_Projects_Summary__c.getDescribe().getLength();

        // For now we'll only add the required fields to the summary
        // In case of data migration where a lot of the required fields will not be
        // filled out, let's only add them if they have a value
        for (User u : users) {

            Boolean aecomLimitReached = false;
            Boolean nonAecomLimitReached = false;

            // We'll clear the projects summary fields
            u.AECOM_Projects_Summary__c = '';
            u.Non_AECOM_Projects_Summary__c = '';

            // For the case the user doesn't have any previous approved projects
            List<PR_Team_Employee__c> userProjects = projects.containsKey(u.Id) ? projects.get(u.Id) : new List<PR_Team_Employee__c>();
            for (PR_Team_Employee__c pp : userProjects) {
                // AECOM Projects Sub_Practice_Area__cmmary
                if (pp.RecordTypeId == mRtInfo.get(rsPRTeamEmployee.RT_AECOMPROJECT).getRecordTypeId() && !aecomLimitReached) {
                    u.AECOM_Projects_Summary__c += String.isNotBlank(pp.Project_Name__c) ? '[' + projectFields.get('Project_ID__c').getDescribe().getLabel() + ']: ' + pp.Project_Name__c + ', ' : '';
                    u.AECOM_Projects_Summary__c += String.isNotBlank(pp.Project_Role__c) ? '[' + projectFields.get('Project_Role__c').getDescribe().getLabel() + ']: ' + pp.Project_Role__c + ', ' : '';
                    u.AECOM_Projects_Summary__c += String.isNotBlank(pp.Client__c) ? '[' + Label.Client_Name + ']: ' + pp.Client__c + ', ' : '';
                    u.AECOM_Projects_Summary__c += String.isNotBlank(pp.Project_Group_Editable__c) ? '[' + Label.Project_Group + ']: ' + pp.Project_Group_Editable__c + ', ' : '';
                    u.AECOM_Projects_Summary__c += String.isNotBlank(pp.Location_Country__c) ? '[' + Label.Location_Country + ']: ' + pp.Location_Country__c + ', ' : '';
                    if (pp.Date_Involvement_Started__c != null) {
                        u.AECOM_Projects_Summary__c += '[' + Label.Date_Involvement_Started + ']: ' + pp.Date_Involvement_Started__c.format() + ', ';
                    }
                    if (pp.Date_Involvement_Ended__c != null) {
                        u.AECOM_Projects_Summary__c += '[' + Label.Date_Involvement_Ended + ']: ' + pp.Date_Involvement_Ended__c.format() + ', ';
                    }
                    u.AECOM_Projects_Summary__c += String.isNotBlank(pp.Description__c) ? '[' + projectFields.get('Description__c').getDescribe().getLabel() + ']: ' + pp.Description__c : '';
                    u.AECOM_Projects_Summary__c += String.isNotBlank(u.AECOM_Projects_Summary__c) ? '\r\n' : '';

                    // set limit reached and add indicator that more data exists but field cannot hold any more
                    if (u.AECOM_Projects_Summary__c.length() >= aecomLimit) {
                        aecomLimitReached = true;
                        u.AECOM_Projects_Summary__c = u.AECOM_Projects_Summary__c.subString(0, aecomLimit - 3) + '...';
                    }
                }

                // Non-AECOM Projects Summary
                else if (pp.RecordTypeId == mRtInfo.get(rsPRTeamEmployee.RT_NONAECOMPROJECT).getRecordTypeId() && !aecomLimitReached) {
                    u.Non_AECOM_Projects_Summary__c += String.isNotBlank(pp.Project_Name__c) ? '[' + projectFields.get('Project_ID__c').getDescribe().getLabel() + ']: ' + pp.Project_Name__c + ', ' : '';
                    u.Non_AECOM_Projects_Summary__c += String.isNotBlank(pp.Project_Role__c) ? '[' + projectFields.get('Project_Role__c').getDescribe().getLabel() + ']: ' + pp.Project_Role__c + ', ' : '';
                    u.Non_AECOM_Projects_Summary__c += String.isNotBlank(pp.Client__c) ? '[' + Label.Client_Name + ']: ' + pp.Client__c + ', ' : '';
                    u.Non_AECOM_Projects_Summary__c += String.isNotBlank(pp.Project_Group_Editable__c) ? '[' + Label.Project_Group + ']: ' + pp.Project_Group_Editable__c + ', ' : '';
                    u.Non_AECOM_Projects_Summary__c += String.isNotBlank(pp.Location_Country__c) ? '[' + Label.Location_Country + ']: ' + pp.Location_Country__c + ', ' : '';
                    if (pp.Date_Involvement_Started__c != null) {
                        u.Non_AECOM_Projects_Summary__c += '[' + Label.Date_Involvement_Started + ']: ' + pp.Date_Involvement_Started__c.format() + ', ';
                    }
                    if (pp.Date_Involvement_Ended__c != null) {
                        u.Non_AECOM_Projects_Summary__c += '[' + Label.Date_Involvement_Ended + ']: ' + pp.Date_Involvement_Ended__c.format() + ', ';
                    }
                    u.Non_AECOM_Projects_Summary__c += String.isNotBlank(pp.Description__c) ? '[' + projectFields.get('Description__c').getDescribe().getLabel() + ']: ' + pp.Description__c : '';
                    u.Non_AECOM_Projects_Summary__c += String.isNotBlank(u.Non_AECOM_Projects_Summary__c) ? '\r\n' : '';

                    // set limit reached and add indicator that more data exists but field cannot hold any more
                    if (u.Non_AECOM_Projects_Summary__c.length() >= nonAecomLimit) {
                        nonAecomLimitReached = true;
                        u.Non_AECOM_Projects_Summary__c = u.Non_AECOM_Projects_Summary__c.subString(0, nonAecomLimit - 3) + '...';
                    }
                }

                //Break out of this loop, no point if we're not adding anything
                if (aecomLimitReached && nonAecomLimitReached) {
                    break;
                }
            }
        }

        rsDataUtils.save(users);
    }

    public Boolean getIsContentManager() {
        return Profile_Info__c.getInstance().Is_Content_Manager__c;
    }

    public String getEXISTING_PROJECT() {
        return EXISTING_PROJECT;
    }
    public String getNEW_PROJECT() {
        return NEW_PROJECT;
    }
    public String getNON_PROJECT() {
        return NON_PROJECT;
    }

    public static final String EXISTING_PROJECT = 'EXIST';
    public static final String NEW_PROJECT = 'NEW';
    public static final String NON_PROJECT = 'NON';
}