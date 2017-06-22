/*************************************************************************
*
* PURPOSE: Controller for Registration Component in Credentials Section
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/

public with sharing class rsRegistrationController extends rsSectionController {
    public List<SelectOption> countryList {get; set;}
    public rsRegistrationController() {
        super();
        mRecordType = rsProfilePart.RT_REGISTRATION;
        sObject sObj = Schema.getGlobalDescribe().get('rs_Profile_Part__c').newSObject() ;
        countryList = rsDataUtils.getPicklistValues(sObj, 'Country__c');
    }
}