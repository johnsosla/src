/*************************************************************************
*
* PURPOSE: Test class for rs Update Tracking
*
*
* CREATED: 2015 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
@isTest
private class rsUpdateTrackingTest {

    @isTest static void testConstructors() {
        rsUpdateTracking track1 = new rsUpdateTracking();
        rsUpdateTracking track2 = new rsUpdateTracking(UserInfo.getUserId());

        rs_Update_Tracking__c trackObj = new rs_Update_Tracking__c(User__c = UserInfo.getUserId(), Source__c = 'TestSource', Details__c = 'Deets');
        insert trackObj;

        rsUpdateTracking track3 = new rsUpdateTracking(trackObj);

        System.assertEquals(null, track1.getId());
        System.assertEquals(UserInfo.getUserId(), track2.getUserId());
        System.assertEquals(UserInfo.getUserId(), track3.getUserId());
        System.assertEquals('TestSource', track3.getSource());
        System.assertEquals('Deets', track3.getDetails());
        System.assertEquals(trackObj.Id, track3.getId());
    }

    @isTest static void testFinderMethods() {
        rs_Update_Tracking__c trackObj = new rs_Update_Tracking__c(User__c = UserInfo.getUserId(), Source__c = 'TestSource', Details__c = 'Deets');
        insert trackObj;

        List<rsUpdateTracking> returnList = rsUpdateTracking.find.byUserId(UserInfo.getUserId());

        System.assertEquals(1, returnList.size());
        System.assertEquals(trackObj.Id, returnList[0].getId());
        System.assertEquals(UserInfo.getUserId(), returnList[0].getUserId());
        System.assertEquals('TestSource', returnList[0].getSource());
        System.assertEquals('Deets', returnList[0].getDetails());
        System.assertEquals(trackObj.Id, rsUpdateTracking.find.byTrackId(trackObj.Id).getId());
        System.assertEquals(UserInfo.getName(), returnList[0].getCreatedByName());
        System.assertEquals(Datetime.now().format(), returnList[0].getCreatedDate());
    }

    @isTest static void testGettersAndSetters() {
        rs_Update_Tracking__c trackObj = new rs_Update_Tracking__c(User__c = UserInfo.getUserId(), Source__c = 'TestSource', Details__c = 'Deets');
        insert trackObj;

        rsUpdateTracking track = new rsUpdateTracking(trackObj);
        track.setUserId(null);
        track.setSource('newSource');
        track.setDetails('newDeets');

        System.assertEquals(null, track.getUserId());
        System.assertEquals('newSource', track.getSource());
        System.assertEquals('newDeets', track.getDetails());
    }

}