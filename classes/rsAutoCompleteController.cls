/*************************************************************************
*
* PURPOSE: Auto complete Controller
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
global with sharing class rsAutoCompleteController {
    public rsAutoCompleteController() {

    }

    @RemoteAction
    global static List<String> getValues(String prefix, String fieldName, String sObjectName, String userId, String userField) {

        List<String> values = new List<String>();
        prefix = '%' + prefix + '%';
        String userWhereStr = String.isNotBlank(userId) && String.isNotBlank(userField) ? ' ' + userField + ' =: userId' : '';
        List<AggregateResult> parts = new List<AggregateResult>();
        if(fieldName != 'Skill__c') {
            parts = (List<AggregateResult>)Database.query('Select ' + fieldName + ' from ' + sObjectName + ' where ' + fieldName + ' LIKE ' +
                                                                                    rsStringUtil.quote(prefix) + (String.isNotBlank(userWhereStr) ? ' AND ' + userWhereStr : '') +
                                                                                    ' group by ' + fieldName + ' limit 10');
            for(AggregateResult part : parts) {
                values.add(String.valueOf(part.get(fieldName)));
            }
        } else {
            parts = (List<AggregateResult>)Database.query('Select ' + fieldName + ', Skill_Area__c from ' + sObjectName + ' where ' + fieldName + ' LIKE ' +
                                                                                    rsStringUtil.quote(prefix) + (String.isNotBlank(userWhereStr) ? ' AND ' + userWhereStr : '') +
                                                                                    ' group by ' + fieldName + ', Skill_Area__c limit 10');
            for(AggregateResult part : parts) {
                if(part.get('Skill_Area__c') != null) {
                    values.add(String.valueOf(part.get('Skill_Area__c')) + ' - ' + String.valueOf(part.get(fieldName)));
                } else {
                    values.add(String.valueOf(part.get(fieldName)));
                }
            }
        }


        values.sort();
        return values;
    }

}