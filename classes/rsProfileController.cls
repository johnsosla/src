/*************************************************************************
*
* PURPOSE: Controller for the personal tab in chatter
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public with sharing class rsProfileController extends rsChatterTabController {

    public rsProfileController() {
        super();
    }

    public Boolean getCanSeeGlobalMobility() {
        if(getIsOwnerOrContentManager()) {
            return true;
        }
        Boolean canSeeGMFields = false;
        SObjectType objToken = Schema.getGlobalDescribe().get('USER');
        Map<String, Schema.SObjectField> objectFields = objToken.getDescribe().fields.getMap();

        for(String field : rsProfile.USER_GLOBAL_MOBILITY_FIELDS) {
            Schema.DescribeFieldResult f = objectFields.get(field).getDescribe();
            if(!f.isAccessible()) {
                canSeeGMFields = false;
                break;
            } else {
                canSeeGMFields = true;
            }
        }
        return canSeeGMFields;
    }

}