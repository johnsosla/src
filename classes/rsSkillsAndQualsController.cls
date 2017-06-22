/*************************************************************************
*
* PURPOSE: Controller for the Skills and Qualifications tab in chatter
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public with sharing class rsSkillsAndQualsController extends rsChatterTabController {
    private Boolean mShowSFDiscipline;

    public rsSkillsAndQualsController() {
        super();
        mShowSFDiscipline = false;
    }

    public Boolean getShouldShowSFDiscipline() {
        mShowSFDiscipline = Profile_Info__c.getInstance().Is_Content_Manager__c;
        return mShowSFDiscipline;
    }

}