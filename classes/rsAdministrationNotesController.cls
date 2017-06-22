/*************************************************************************
*
* PURPOSE: Controller for Administration Notes  section
*
* CREATED: 2015 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public with sharing class rsAdministrationNotesController extends rsSectionController {

    public rsAdministrationNotesController() {
        super();
    }

    public override PageReference savePart() {
        profile.save();
        enableListMode();
        return null;
    }

    public override PageReference editPart() {
        enableEditMode();
        return null;
    }

    public override PageReference cancelPart() {
        profile.refreshUser();
        enableListMode();
        return null;
    }

    public Boolean getIsContentManager() {
        return Profile_Info__c.getInstance().Is_Content_Manager__c;
    }
}