/*************************************************************************
*
* PURPOSE: Controller for Certification Section
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
public with sharing class rsCertificationController extends rsSectionController {
    public rsCertificationController() {
        super();
        mRecordType = rsProfilePart.RT_CERTIFICATION;
    }
}