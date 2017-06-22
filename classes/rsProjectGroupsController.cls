/*************************************************************************
*
* PURPOSE: Controller for the project group component used on the rsProject.page
*
* CREATED: 2015 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
public with sharing class rsProjectGroupsController extends rsSectionController {

    private List<SelectOption> mProjectGroupOptions;
    private List<SelectOption> mAssignedProjectOptions;
    private List<SelectOption> mUnassignedProjectOptions;
    private rsSearch mNewProjectGroup;
    private List<rsSearch> mDeleteList;
    private List<String> mSelectedProjects;
    private List<String> mSelectedUnassignedProjects;
    private String mUnassignedProjectsSource;

    private Map<Id, Integer> groupSeqMap;
    private Map<Id, Integer> projectSeqMap;
    private Map<Id, String> projectGroupMap;

    public String ProjectGroupSearch {get; set;}
    public String SelectedProjectGroup {get; set;}
    public String UnassignedProjectSearch {get; set;}

    private Boolean isFirstRun = true;

    public rsProjectGroupsController() {
        mDeleteList = new List<rsSearch>();
        groupSeqMap = new Map<Id, Integer>();
        projectSeqMap = new Map<Id, Integer>();
        projectGroupMap = new Map<Id, String>();
    }

    public List<SelectOption> getProjectGroupOptions() {
        if (mProjectGroupOptions == null) {
            mProjectGroupOptions = new List<SelectOption>();
            Set<String> groups = new Set<String>();
            for (rsSearch pGroup : Profile.getProjectGroups()) {
                groups.add(pGroup.getName());
                mProjectGroupOptions.add(new SelectOption(pGroup.getName(), pGroup.getName()));
            }
            for (rsPRTeamEmployee emp : isFirstRun ? Profile.getSortedProfileProjects()
                    : getUpdatedSortedList(Profile.getSortedProfileProjects())) {
                isFirstRun = false;
                String key = rsStringUtil.toTitleCase(emp.getProjectGroup());
                if (!groups.contains(key) && String.isNotBlank(key)) {
                    groups.add(key);
                    rsSearch projGroup = new rsSearch();
                    projGroup.setName(key);
                    projGroup.setUserId(Profile.getId());
                    projGroup.setGroupSequence(emp.getGroupSequence());
                    projGroup.setSearchType(rsSearch.PROJECT_GROUP);
                    Profile.getProjectGroups().add(projGroup);
                    mProjectGroupOptions.add(new SelectOption(projGroup.getName(), projGroup.getName()));
                }
                if (String.isNotBlank(emp.getProjectGroup())) {
                    groupSeqMap.put(emp.getId(), emp.getGroupSequence());
                    projectSeqMap.put(emp.getId(), emp.getProjectSequence());
                    projectGroupMap.put(emp.getId(), emp.getProjectGroup());
                }
            }
        }
        return mProjectGroupOptions;
    }

    // For AssignedProject and UnassignedProject
    public String getOptionStringSet(rsPRTeamEmployee emp) {
        // Always add the projectName
        String mOptionString = emp.getProjectName();

        // Add the projectNumber to the string unless it is blank/null then leave a blank space
        if (String.isNotBlank(emp.getProjectNumber())) {
            mOptionString += ', ' + emp.getProjectNumber();
        } else {
            mOptionString += ', ';
        }

        // Add the clientName to the string unless it is blank/null then leave a blank space
        if (String.isNotBlank(emp.getClientName())) {
            mOptionString += ', ' + emp.getClientName();
        } else {
            mOptionString += ', ';
        }
        return mOptionString;
    }

    private List<rsPRTeamEmployee> getUpdatedSortedList(List<rsPRTeamEmployee> emps) {
        List<rsPRTeamEmployee> newEmpList = new List<rsPRTeamEmployee>();
        for (rsPRTeamEmployee emp : emps) {
            emp.setGroupSequence(groupSeqMap.get(emp.getId()));
            emp.setProjectSequence(projectSeqMap.get(emp.getId()));
            emp.setProjectGroup(projectGroupMap.get(emp.getId()));
            newEmpList.add(emp);
        }
        newEmpList.sort();
        return newEmpList;
    }

    public List<SelectOption> getAssignedProjectOptions() {
        if (mAssignedProjectOptions == null) {
            mAssignedProjectOptions = new List<SelectOption>();
            if (String.isNotBlank(SelectedProjectGroup)) {
                for (rsPRTeamEmployee emp : getUpdatedSortedList(Profile.getSortedProfileProjects())) {
                    if (emp.getProjectGroup() == SelectedProjectGroup) {
                        mAssignedProjectOptions.add(new SelectOption( emp.getId() , getOptionStringSet(emp) ));
                    }
                }
            }
        }
        return mAssignedProjectOptions;
    }

    public List<SelectOption> getUnassignedProjectOptions() {
        if (mUnassignedProjectOptions == null) {
            mUnassignedProjectOptions = new List<SelectOption>();
            for (rsPRTeamEmployee emp : Profile.getSortedProfileProjects()) {
                if (String.isBlank(emp.getProjectGroup())) {
                    mUnassignedProjectOptions.add(new SelectOption( emp.getId() , getOptionStringSet(emp) ));
                }
            }
        }
        return mUnassignedProjectOptions;
    }

    public String getUnassignedProjectsSource() {
        if (mUnassignedProjectsSource == null) {
            Set<String> returnString = new Set<String>();
            for (SelectOption op : getUnassignedProjectOptions()) {
                returnString.add(op.getLabel());
            }
            mUnassignedProjectsSource = '\"' + String.join(new List<String>(returnString), '\",\"') + '\"';
        }
        return mUnassignedProjectsSource;
    }

    public List<String> getSelectedProjects() {
        if (mSelectedProjects == null) {
            mSelectedProjects = new List<String>();
        }
        return mSelectedProjects;
    }
    public void setSelectedProjects(List<String> projects) {
        mSelectedProjects = projects;
    }

    public List<String> getSelectedUnassignedProjects() {
        if (mSelectedUnassignedProjects == null) {
            mSelectedUnassignedProjects = new List<String>();
        }
        return mSelectedUnassignedProjects;
    }
    public void setSelectedUnassignedProjects(List<String> projects) {
        mSelectedUnassignedProjects = projects;
    }

    public PageReference moveProjectsUp() {
        if (!getSelectedProjects().isEmpty()) {
            Set<String> selProjects = new Set<String>(getSelectedProjects());
            for (Integer i = 0; i < getAssignedProjectOptions().size(); i++) {
                SelectOption currProject = getAssignedProjectOptions()[i];
                if (selProjects.contains(currProject.getValue()) && i > 0) {
                    SelectOption temp = getAssignedProjectOptions()[i - 1];
                    mAssignedProjectOptions.set(i - 1, currProject);
                    mAssignedProjectOptions.set(i, temp);
                }
            }
        }
        return null;
    }

    public PageReference moveProjectsDown() {
        if (!getSelectedProjects().isEmpty()) {
            Set<String> selProjects = new Set<String>(getSelectedProjects());
            for (Integer i = getAssignedProjectOptions().size() - 1; i >= 0; i--) {
                SelectOption currProject = getAssignedProjectOptions()[i];
                if (selProjects.contains(currProject.getValue()) && i < getAssignedProjectOptions().size() - 1) {
                    SelectOption temp = getAssignedProjectOptions()[i + 1];
                    mAssignedProjectOptions.set(i + 1, currProject);
                    mAssignedProjectOptions.set(i, temp);
                }
            }
        }
        return null;
    }

    public PageReference changeSelectedProjectGroup() {
        Integer sequence = 0;
        for (SelectOption op : getProjectGroupOptions()) {
            for (rsPRTeamEmployee emp : getUpdatedSortedList(Profile.getSortedProfileProjects())) {
                if (projectGroupMap.get(emp.getId()) == op.getValue()) {
                    groupSeqMap.put(emp.getId(), sequence);
                }
            }
            sequence++;
        }
        sequence = 0;
        for (SelectOption op : getAssignedProjectOptions()) {
            for (rsPRTeamEmployee emp : getUpdatedSortedList(Profile.getSortedProfileProjects())) {
                if (emp.getId() == op.getValue()) {
                    projectSeqMap.put(emp.getId(), sequence);
                    sequence++;
                    break;
                }
            }
        }
        mAssignedProjectOptions = null;
        return null;
    }

    public rsSearch getNewProjectGroup() {
        if (mNewProjectGroup == null) {
            mNewProjectGroup = new rsSearch();
        }
        return mNewProjectGroup;
    }

    public PageReference addNewProjectGroup() {
        if (String.isNotBlank(mNewProjectGroup.getName())) {
            mNewProjectGroup.setName(rsStringUtil.toTitleCase(mNewProjectGroup.getName()));
            mNewProjectGroup.setSearchType(rsSearch.PROJECT_GROUP);
            mNewProjectGroup.setUserId(Profile.getId());
            for (SelectOption op : mProjectGroupOptions) {
                if (mNewProjectGroup.getName() == op.getValue()) {
                    mNewProjectGroup = new rsSearch();
                    return null;
                }
            }
            mProjectGroupOptions.add(new SelectOption(mNewProjectGroup.getName(), mNewProjectGroup.getName()));
            Profile.getProjectGroups().add(mNewProjectGroup);
            mNewProjectGroup = new rsSearch();
        }
        return null;
    }

    public PageReference deleteProjectGroup() {
        if (String.isNotBlank(SelectedProjectGroup)) {
            mProjectGroupOptions = null;
            for (Integer i = Profile.getProjectGroups().size() - 1; i >= 0; i--) {
                rsSearch pGroup = Profile.getProjectGroups()[i];
                if (SelectedProjectGroup == pGroup.getName()) {
                    mDeleteList.add(Profile.getProjectGroups().remove(i));
                    break;
                }
            }
            for (rsPRTeamEmployee emp : getUpdatedSortedList(Profile.getSortedProfileProjects())) {
                if (emp.getProjectGroup() == SelectedProjectGroup) {
                    projectGroupMap.put(emp.getId(), '');
                    groupSeqMap.remove(emp.getId());
                    projectSeqMap.remove(emp.getId());
                }
            }
        }
        SelectedProjectGroup = '';
        mAssignedProjectOptions = null;
        mUnassignedProjectOptions = null;
        return null;
    }

    public PageReference refreshProjectGroups() {
        SelectedProjectGroup = '';
        ProjectGroupSearch = '';
        UnassignedProjectSearch = '';
        mProjectGroupOptions = null;
        mAssignedProjectOptions = null;
        mUnassignedProjectOptions = null;
        mUnassignedProjectsSource = null;
        mNewProjectGroup = new rsSearch();
        mDeleteList = new List<rsSearch>();
        mSelectedProjects = new List<String>();
        mSelectedUnassignedProjects = new List<String>();
        Profile.setProfileProjects(null);
        Profile.setProjectGroups(null);
        return null;
    }

    public PageReference moveProjectGroupUp() {
        if (String.isNotBlank(SelectedProjectGroup)) {
            mProjectGroupOptions = null;
            for (Integer i = 0; i < Profile.getProjectGroups().size(); i++) {
                rsSearch pGroup = Profile.getProjectGroups()[i];
                if (SelectedProjectGroup == pGroup.getName()) {
                    if (i == 0) {
                        break;
                    } else {
                        rsSearch prevGroup = Profile.getProjectGroups()[i - 1];
                        Profile.getProjectGroups().set(i - 1, pGroup);
                        Profile.getProjectGroups().set(i, prevGroup);
                        break;
                    }
                }
            }
        }
        return null;
    }

    public PageReference moveProjectGroupDown() {
        if (String.isNotBlank(SelectedProjectGroup)) {
            mProjectGroupOptions = null;
            for (Integer i = 0; i < Profile.getProjectGroups().size(); i++) {
                rsSearch pGroup = Profile.getProjectGroups()[i];
                if (SelectedProjectGroup == pGroup.getName()) {
                    if (i == Profile.getProjectGroups().size() - 1) {
                        break;
                    } else {
                        rsSearch nextGroup = Profile.getProjectGroups()[i + 1];
                        Profile.getProjectGroups().set(i + 1, pGroup);
                        Profile.getProjectGroups().set(i, nextGroup);
                        break;
                    }
                }
            }
        }
        return null;
    }

    public PageReference moveUnassignedToAssigned() {
        if (!getSelectedUnassignedProjects().isEmpty() && String.isNotBlank(SelectedProjectGroup)) {
            Set<String> unassignedProjects = new Set<String>(mSelectedUnassignedProjects);
            for (Integer i = getUnassignedProjectOptions().size() - 1; i > -1; i--) {
                SelectOption currProject = getUnassignedProjectOptions()[i];
                if (unassignedProjects.contains(currProject.getValue())) {
                    getAssignedProjectOptions().add(getUnassignedProjectOptions().remove(i));
                    for (rsPRTeamEmployee emp : getUpdatedSortedList(Profile.getSortedProfileProjects())) {
                        if (emp.getId() == currProject.getValue()) {
                            emp.setProjectGroup(SelectedProjectGroup);
                            projectGroupMap.put(emp.getId(), SelectedProjectGroup);
                            break;
                        }
                    }
                }
            }
            mSelectedUnassignedProjects = null;
            mUnassignedProjectsSource = null;
        }
        return null;
    }

    public PageReference moveAssignedToUnassigned() {
        if (!getSelectedProjects().isEmpty()) {
            Set<String> assignedProjects = new Set<String>(mSelectedProjects);
            for (Integer i = getAssignedProjectOptions().size() - 1; i > -1; i--) {
                SelectOption currProject = getAssignedProjectOptions()[i];
                if (assignedProjects.contains(currProject.getValue())) {
                    getUnassignedProjectOptions().add(getAssignedProjectOptions().remove(i));
                    for (rsPRTeamEmployee emp : getUpdatedSortedList(Profile.getSortedProfileProjects())) {
                        if (emp.getId() == currProject.getValue()) {
                            projectGroupMap.remove(emp.getId());
                            projectSeqMap.remove(emp.getId());
                            groupSeqMap.remove(emp.getId());
                            System.debug('AssignedToUnassigned: ' + emp.getProjectName());
                            System.debug('GroupSequence: ' + groupSeqMap.get(emp.getId()));
                            System.debug('ProjectGroupMap: ' + projectGroupMap.get(emp.getId()));
                            break;
                        }
                    }
                }
            }
            mSelectedProjects = null;
            mUnassignedProjectsSource = null;
        }
        return null;
    }

    public PageReference searchProjectGroups() {
        mProjectGroupOptions = null;
        if (String.isNotBlank(ProjectGroupSearch)) {
            List<SelectOption> newListOptions = new List<SelectOption>();
            for (SelectOption op : getProjectGroupOptions()) {
                if (op.getValue().containsIgnoreCase(ProjectGroupSearch)) {
                    newListOptions.add(op);
                }
            }
            mProjectGroupOptions = newListOptions;
        }
        return null;
    }

    public PageReference searchUnassignedProjects() {
        if (String.isNotBlank(UnassignedProjectSearch)) {
            mUnassignedProjectOptions = null;
            for (Integer i = getUnassignedProjectOptions().size() - 1; i > -1; i--) {
                SelectOption currOption = getUnassignedProjectOptions()[i];
                if (!currOption.getLabel().containsIgnoreCase(UnassignedProjectSearch)) {
                    getUnassignedProjectOptions().remove(i);
                }
            }
        } else {
            mUnassignedProjectOptions = null;
        }
        return null;
    }

    public PageReference saveProjectGroups() {
        changeSelectedProjectGroup();
        Integer sequence = 0;
        for (SelectOption op : getProjectGroupOptions()) {
            for (rsSearch projGroup : Profile.getProjectGroups()) {
                projGroup.setOwnerId(Profile.getId());
                if (projGroup.getName() == op.getValue()) {
                    projGroup.setGroupSequence(sequence);
                    sequence++;
                    break;
                }
            }
        }
        for (rsPRTeamEmployee emp : Profile.getSortedProfileProjects()) {
            for (rsSearch pGroup : Profile.getProjectGroups()) {
                if (projectGroupMap.get(emp.getId()) == pGroup.getName() && String.isNotBlank(pGroup.getName())) {
                    groupSeqMap.put(emp.getId(), Integer.valueOf(pGroup.getGroupSequence()));
                }
            }
        }

        for (rsPRTeamEmployee emp : Profile.getSortedProfileProjects()) {
            emp.setGroupSequence(groupSeqMap.get(emp.getId()));
            emp.setProjectSequence(projectSeqMap.get(emp.getId()));
            emp.setProjectGroup(projectGroupMap.get(emp.getId()));
        }
        List<rsModel> saveList = new List<rsModel>();
        saveList.addAll((List<rsModel>)Profile.getProjectGroups());
        saveList.addAll((List<rsModel>)Profile.getSortedProfileProjects());
        rsModel.save(saveList);

        if (!mDeleteList.isEmpty()) {
            rsModel.destroy(mDeleteList);
        }
        Profile.setProfileProjects(null);
        return null;
    }
}