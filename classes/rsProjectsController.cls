/*************************************************************************
*
* PURPOSE: Controller for the Projects tab in chatter
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public with sharing class rsProjectsController extends rsChatterTabController {

    public rsProjectController ProjectController {get; set;}
    public rsProjectSearchController ProjectSearchController {get; set;}

    public rsProjectsController() {
        super();
        ProjectController = new rsProjectController();
        ProjectController.Profile = getProfile();
        ProjectSearchController = new rsProjectSearchController();
        ProjectSearchController.Profile = getProfile();
        ProjectSearchController.searchProjects();
    }

}