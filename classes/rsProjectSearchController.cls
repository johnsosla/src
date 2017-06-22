/*************************************************************************
*
* PURPOSE: Controller for the project component used on the rsProject.page
*
* CREATED: 2015 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
public with sharing class rsProjectSearchController extends rsSectionController {

    public rsFilterManager Filter;
    public rsProjectSearchController() {
       super();
    }

    public rsFilterManager getFilter() {
        if(Filter == null) {
            Filter = new rsFilterManager();
            Filter.UserId = profile.getId();
            Filter.setupProjectSearchFilters();
        }
        return Filter;
    }

    public PageReference searchProjects() {
        Profile.setProfileProjects(getFilter().getProjectSearchResults());
        Profile.ResetProjects = true;
        getFilter().setupProjectSearchFilters();
        return null;
    }
}