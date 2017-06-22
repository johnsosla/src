public with sharing class rsWorkController extends rsSectionController {
    public List<SelectOption> countryList {get; set;}
    public rsWorkController() {
        super();
        mRecordType = rsProfilePart.RT_WORK_HISTORY;
        sObject sObj = Schema.getGlobalDescribe().get('rs_Profile_Part__c').newSObject() ;
        countryList = rsDataUtils.getPicklistValues(sObj, 'Country__c');
    }

    public override PageReference savePart() {
        if (checkCurrentParts()) {
            savePart(false);
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.More_Than_One_Current_Employment_Error));
        }

        return null;
    }

    private Boolean checkCurrentParts() {
        if (!CurrentPart.getCurrent()) {
            return true;
        } else {
            Boolean isCurrentDifferent = false;
            for (rsProfilePart part : getParts()) {
                if (part.getCurrent() && part.getId() != CurrentPart.getId()) {
                    isCurrentDifferent = true;
                }
            }
            return !isCurrentDifferent;
        }
    }

}