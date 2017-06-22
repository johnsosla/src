public with sharing class rsLanguagesController extends rsSectionController {
    public String selectedLanguage {get; set;}
    public List<SelectOption> languageList {get; set;}
    public List<SelectOption> languageSkillList {get; set;}
    public List<SelectOption> languageLevelList {get; set;}
    public rsLanguagesController() {
        super();
        mRecordType = rsProfilePart.RT_LANGUAGES;
        sObject sObj = Schema.getGlobalDescribe().get('rs_Profile_Part__c').newSObject() ;
        languageList = new List<SelectOption>();
        languageList.add(new SelectOption('','--None--'));
        languageList.addAll(rsDataUtils.getPicklistValues(sObj, 'Language__c'));
        languageSkillList = rsDataUtils.getPicklistValues(sObj, 'Language_Skill__c');
        languageLevelList = rsDataUtils.getPicklistValues(sObj, 'Language_Level__c');
    }
}