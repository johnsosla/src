@isTest
private class rsTrackingViewModelTest {

    @isTest static void testConstructor() {
        rs_Update_Tracking__c trackObj = new rs_Update_Tracking__c(User__c = UserInfo.getUserId(), Source__c = 'TestSource', Details__c = 'Deets');
        insert trackObj;

        rsTrackingViewModel model = new rsTrackingViewModel(new rsUpdateTracking(trackObj));
        System.assertEquals(trackObj.Id, model.getObj().getId());
    }

    @istest static void testCompare() {
        rs_Update_Tracking__c trackObj = new rs_Update_Tracking__c(User__c = UserInfo.getUserId(), Source__c = 'TestSource', Details__c = 'Deets');
        insert trackObj;

        rs_Update_Tracking__c trackObj2 = new rs_Update_Tracking__c(User__c = UserInfo.getUserId(), Source__c = 'abc', Details__c = 'abc');
        insert trackObj2;

        rsTrackingViewModel model1 = new rsTrackingViewModel(new rsUpdateTracking(trackObj));
        rsTrackingViewModel model2 = new rsTrackingViewModel(new rsUpdateTracking(trackObj2));

        List<rsTrackingViewModel> models = new List<rsTrackingViewModel>{model1, model2};
        rsTrackingViewModel.SortField = 'Source__c';
        models.sort();

        System.assertEquals(trackObj2.Id, model2.getObj().getId());
    }

}