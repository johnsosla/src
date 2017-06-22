/*************************************************************************
*
* PURPOSE: Controller for file section in profile
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public with sharing class rsFileController extends rsSectionController {
    public rsFileController() {
        super();
        mRecordType = rsProfilePart.RT_FILE;
    }
}