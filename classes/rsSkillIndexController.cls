public with sharing class rsSkillIndexController extends rsSectionController {
    public List<SelectOption> skillAreaList {get; set;}
    public List<SelectOption> skillLevelList {get; set;}
    //public List<SelectOption> specialtyList {get; set;}
    public rsSkillIndexController() {
        super();
        mRecordType = rsProfilePart.RT_SKILL_INDEX;
        sObject sObj = Schema.getGlobalDescribe().get('rs_Profile_Part__c').newSObject();
        skillAreaList = new List<SelectOption>{(new SelectOption('','--None--'))};
        skillAreaList.addAll(rsDataUtils.getPicklistValues(sObj, 'Skill_Area__c'));
        skillLevelList = rsDataUtils.getPicklistValues(sObj, 'Skill_Level__c');
        //specialtyList = rsDataUtils.getPicklistValues(sObj, 'Specialty__c');
    }
}