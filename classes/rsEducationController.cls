/*************************************************************************
*
* PURPOSE: Controller for education section
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
global class rsEducationController extends rsSectionController {
    public List<SelectOption> countryList {get; set;}

    public rsEducationController() {
        super();
        mRecordType = rsProfilePart.RT_EDUCATION;
        sObject sObj = Schema.getGlobalDescribe().get('rs_Profile_Part__c').newSObject();
        countryList = new List<SelectOption>{new SelectOption('','--None--')};
        countryList.addAll(rsDataUtils.getPicklistValues(sObj, 'Country__c'));
    }

}