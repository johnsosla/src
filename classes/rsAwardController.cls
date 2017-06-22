/*************************************************************************
*
* PURPOSE: Controller for awards section
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public with sharing class rsAwardController extends rsSectionController {
    public rsAwardController() {
        super();
        mRecordType = rsProfilePart.RT_AWARD;
    }
}