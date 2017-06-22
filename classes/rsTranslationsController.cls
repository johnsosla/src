public with sharing class rsTranslationsController extends rsSectionController {
    public List<SelectOption> languageList {get; set;}
    public rsTranslationsController() {
        super();
        mRecordType = rsProfilePart.RT_TRANSLATIONS;
        sObject sObj = Schema.getGlobalDescribe().get('rs_Profile_Part__c').newSObject() ;
        //languageList = rsDataUtils.getPicklistValues(sObj, 'Language__c');

        languageList = new List<SelectOption>();
        languageList.add(new SelectOption('','--None--'));
        languageList.addAll(rsDataUtils.getPicklistValues(sObj, 'Language__c'));
    }
}