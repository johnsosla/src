/*************************************************************************
*
* PURPOSE: Demo for auto complete
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
global with sharing class rsAutoCompleteTestController {

    public String someValue {get; set;}

    public rsAutoCompleteTestController() {

    }

    public PageReference save() {
        System.debug('someValue: ' + someValue);
        return null;
    }

    @RemoteAction
    global static List<String> getValues(String prefix) {

        List<String> values = new List<String>();
        prefix =  prefix + '%';
        List<rs_Profile_Part__c> parts = [select Name from rs_Profile_Part__c where Name like: prefix limit 10];

        for(rs_Profile_Part__c part : parts) {
            values.add(part.Name);
        }

        return values;

    }
}