/*************************************************************************
*
* PURPOSE: Test class for rsApprovalUtil class
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsApprovalUtilTest {
    private static testmethod void testApprovePart() {
        //give our current user CM capabilities so we can see a test user's pending records
        Profile_Info__c tempProfInfo = new Profile_Info__c();
        tempProfInfo.SetupOwnerId = UserInfo.getUserId();
        tempProfInfo.Is_Content_Manager__c = true;
        insert tempProfInfo;


        rsProfile testUser = new rsProfile( rsTestUtil.createTestUsers(false).get(0) );
        rsTestUtil.createTestProfilePartForUserId(testUser.getId(), rsProfilePart.RT_WORK_HISTORY, 2);
        rsProfilePart testApprovedPart = testUser.getProfileParts().get(0);
        rsProfilePart testPendingPart = testUser.getProfileParts().get(1);

        testApprovedPart.setStatus(rsProfilePart.S_APPROVED);
        testApprovedPart.setNextPart(testPendingPart.getId());

        testPendingPart.setStatus(rsProfilePart.S_PENDING);
        testPendingPart.setPreviousPart(testApprovedPart.getId());

        Test.startTest();
        rsApprovalUtil.approvePart( (rs_Profile_Part__c)testPendingPart.getObj(), testUser);
        Test.stopTest();

        rsProfilePart testPendingPartRequery = new rsProfilePart((rs_Profile_Part__c)rsProfilePart.find.byId(testPendingPart.getId()).getObj());
        rsProfilePart testApprovedPartRequery = new rsProfilePart((rs_Profile_Part__c)rsProfilePart.find.byId(testApprovedPart.getId()).getObj());
        rsProfile testUserRequery = new rsProfile((User)rsProfile.find.byId(testUser.getId()).getObj() );

        //Our pending part should now be approved, our old approved part should now be archived
        System.assertEquals(testPendingPartRequery.getStatus(), rsProfilePart.S_APPROVED);
        System.assertEquals(testApprovedPartRequery.getStatus(), rsProfilePart.S_ARCHIVED);

        //Since that was our user's only pending part, their entire profile should be approved and unlocked
        System.assertEquals(testUserRequery.getStatus(), rsProfile.S_APPROVED);
        System.assert(!testUserRequery.getLock());

    }
    private static testmethod void testApproveProject() {
        //give our current user CM capabilities so we can see a test user's pending records
        Profile_Info__c tempProfInfo = new Profile_Info__c();
        tempProfInfo.SetupOwnerId = UserInfo.getUserId();
        tempProfInfo.Is_Content_Manager__c = true;
        insert tempProfInfo;


        rsProfile testUser = new rsProfile( rsTestUtil.createTestUsers(false).get(0) );
        rsTestUtil.createTestProjectPartForUserId(testUser.getId(), rsPRTeamEmployee.RT_AECOMPROJECT, 2);
        rsPRTeamEmployee testApprovedPart = testUser.getProfileProjects().get(0);
        rsPRTeamEmployee testPendingPart = testUser.getProfileProjects().get(1);

        testApprovedPart.setStatus(rsPRTeamEmployee.S_APPROVED);
        testApprovedPart.setNextProjectPart(testPendingPart.getId());

        testPendingPart.setStatus(rsPRTeamEmployee.S_PENDING);
        testPendingPart.setPreviousProjectPart(testApprovedPart.getId());

        Test.startTest();
        rsApprovalUtil.approveProjectPart(testPendingPart, testUser);
        Test.stopTest();

        rsPRTeamEmployee testPendingPartRequery = new rsPRTeamEmployee((PR_Team_Employee__c)rsPRTeamEmployee.find.byId(testPendingPart.getId()).getObj());
        rsPRTeamEmployee testApprovedPartRequery = new rsPRTeamEmployee((PR_Team_Employee__c)rsPRTeamEmployee.find.byId(testApprovedPart.getId()).getObj());
        rsProfile testUserRequery = new rsProfile((User)rsProfile.find.byId(testUser.getId()).getObj() );

        //Our pending part should now be approved, our old approved part should now be archived
        System.assertEquals(testPendingPartRequery.getStatus(), rsPRTeamEmployee.S_APPROVED);
        System.assertEquals(testApprovedPartRequery.getStatus(), rsPRTeamEmployee.S_ARCHIVED);

        //Since that was our user's only pending part, their entire profile should be approved and unlocked
        System.assertEquals(testUserRequery.getStatus(), rsProfile.S_APPROVED);
        System.assert(!testUserRequery.getLock());

    }
}