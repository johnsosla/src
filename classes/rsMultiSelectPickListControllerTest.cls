@isTest
private class rsMultiSelectPickListControllerTest {
    @isTest static void controllerTest() {
        rsMultiSelectPickListController cont = new rsMultiSelectPickListController();
        sObject sObjPP = Schema.getGlobalDescribe().get('rs_Profile_Part__c').newSObject();
        List<SelectOption> countries = rsDataUtils.getPicklistValues(sObjPP, 'Country__c');

        cont.allOptions = countries;
        cont.selectedOptions = new List<SelectOption>();

        Test.startTest();
        cont.setSelectedOptionsValues('United States;Afghanistan');
        Test.stopTest();

        System.assertEquals(2, cont.selectedOptions.size());
        System.assertEquals('United States', cont.selectedOptions.get(0).getValue());
        System.assertEquals('Afghanistan', cont.selectedOptions.get(1).getValue());
        System.assertEquals('United States;Afghanistan',cont.getSelectedOptionsValues());
    }
}