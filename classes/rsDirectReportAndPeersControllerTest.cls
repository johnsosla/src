/*************************************************************************
*
* PURPOSE: Test Class for rsDirectReportAndPeersController
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina & Brian Lau
***************************************************************************/

@isTest
private class rsDirectReportAndPeersControllerTest {

    @isTest static void testDirectReportController() {
        User testUser = rsTestUtil.createTestUsers(true).get(0);
        Map<Id,User> directReportUsers = new Map<Id,User>(rsTestUtil.createTestUsers(false, 51, testUser.Id));

        rsProfile profile = new rsProfile(testUser);

        rsDirectReportAndPeersController cont = new rsDirectReportAndPeersController();
        cont.profile = profile;

        Test.startTest();

        Integer listLimit = cont.getListLimit();
        Integer popupLimit = cont.getPopupLimit();
        Integer initDirectOffset = cont.getPopupDirectListOffset();

        System.assertEquals(10,listLimit);
        System.assertEquals(25,popupLimit);
        System.assertEquals(0,initDirectOffset);

        List<User> directReportList = cont.getDirectReportList();
        System.assertEquals(listLimit,directReportList.size());
        for(User u : directReportList) {
            System.assert(directReportUsers.containsKey(u.Id));
        }

        System.assertEquals(true, cont.getHasMoreDirectReports());

        List<User> directReportPopupList = cont.getPopupDirectList();
        Set<Id> firstList = new Set<Id>();
        for(User u : directReportPopupList) {
            System.assert(directReportUsers.containsKey(u.Id));
            firstList.add(u.Id);
        }

        cont.directListNextPage();
        System.assertEquals(25, cont.getPopupDirectListOffset());
        for(User u : cont.getPopupDirectList()) {
            System.assert(directReportUsers.containsKey(u.Id));
            System.assert(!firstList.contains(u.Id));
        }

        cont.directListNextPage();
        cont.directListPreviousPage();
        cont.directListPreviousPage();
        System.assertEquals(0, cont.getPopupDirectListOffset());
        for(User u : cont.getPopupDirectList()) {
            System.assert(firstList.contains(u.Id));
        }
        System.assertEquals(true, cont.getHasMoreDirectReports());
        cont.resetLists();
        System.assertEquals(0,cont.getPopupDirectListOffset());
        System.assertEquals(true,cont.getHasMoreDirectReports());
        Test.stopTest();
    }

    @isTest static void testPeerController() {
        User testUser = rsTestUtil.createTestUsers(true).get(0);
        Map<Id,User> peerUsers = new Map<Id,User>(rsTestUtil.createTestUsers(false, 51, testUser.Id));

        rsProfile profile = new rsProfile(peerUsers.values().get(0));

        rsDirectReportAndPeersController cont = new rsDirectReportAndPeersController();
        cont.profile = profile;

        Test.startTest();
        Integer initPeerOffset = cont.getPopupPeerListOffset();

        System.assertEquals(0,initPeerOffset);
        List<User> peersList = cont.getPeerList();
        System.assertEquals(cont.getListLimit(),peersList.size());
        for(User u : peersList) {
            System.assert(peerUsers.containsKey(u.Id));
        }

        System.assertEquals(true, cont.getHasMorePeers());

        List<User> peerPopupList = cont.getPopupPeerList();
        Set<Id> firstList = new Set<Id>();
        for(user u : peerPopupList) {
            System.assert(peerUsers.containsKey(u.Id));
            firstList.add(u.Id);
        }

        cont.PeerListNextPage();
        System.assertEquals(25, cont.getPopupPeerListOffset());
        for(User u : cont.getPopupPeerList()) {
            System.assert(peerUsers.containsKey(u.Id));
            System.assert(!firstList.contains(u.Id));
        }

        cont.PeerListNextPage();
        cont.PeerListPreviousPage();
        cont.PeerListPreviousPage();

        System.assertEquals(0, cont.getPopupPeerListOffset());
        for(User u : cont.getPopupPeerList()) {
            System.assert(firstList.contains(u.Id));
        }
        System.assertEquals(true,cont.getHasMorePeers());
        cont.resetLists();
        System.assertEquals(0,cont.getPopupDirectListOffset());
        System.assertEquals(true,cont.getHasMorePeers());
        Test.stopTest();
    }


}