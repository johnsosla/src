/*************************************************************************
*
* PURPOSE: Controller for Association Section
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public with sharing class rsAssociationController extends rsSectionController {
    public rsAssociationController() {
        super();
        mRecordType = rsProfilePart.RT_PROF_AFFILIATION;
    }
}