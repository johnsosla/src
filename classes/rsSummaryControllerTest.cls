/*************************************************************************
*
* PURPOSE: Test Class for Controller for Profile Summary
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsSummaryControllerTest {
    private static testmethod void testGetAreaPointMap() {
        //give our current user CM capabilities so we can see a fake user's pending records
        Profile_Info__c tempProfInfo = new Profile_Info__c();
        tempProfInfo.SetupOwnerId = UserInfo.getUserId();
        tempProfInfo.Is_Content_Manager__c = true;
        insert tempProfInfo;

        rsTestUtil.setupResumeAreaPoints();

        User u = rsTestUtil.createTestUsers(false).get(0);
        System.runAs(u) {
            rsProfile profile = new rsProfile(u);
            rsTestUtil.createTestProfilePartForUserId(profile.getId(), rsProfilePart.RT_TRAINING, 5);
            rsTestUtil.createTestProfilePartForUserId(profile.getId(), rsProfilePart.RT_WORK_HISTORY, 5);
            rsTestUtil.createTestProfilePartForUserId(profile.getId(), rsProfilePart.RT_EDUCATION, 5);
            rsTestUtil.createTestProfilePartForUserId(profile.getId(), rsProfilePart.RT_AWARD, 5);
            rsTestUtil.createTestProfilePartForUserId(profile.getId(), rsProfilePart.RT_CERTIFICATION, 5);
            rsTestUtil.createTestProfilePartForUserId(profile.getId(), rsProfilePart.RT_LANGUAGES, 5);
            rsTestUtil.createTestProfilePartForUserId(profile.getId(), rsProfilePart.RT_PROF_AFFILIATION, 5);
            rsTestUtil.createTestProfilePartForUserId(profile.getId(), rsProfilePart.RT_REGISTRATION, 5);
            rsTestUtil.createTestProfilePartForUserId(profile.getId(), rsProfilePart.RT_TRANSLATIONS, 5);
            rsTestUtil.createTestProfilePartForUserId(profile.getId(), rsProfilePart.RT_PUBLICATION, 5);
            rsTestUtil.createTestProfilePartForUserId(profile.getId(), rsProfilePart.RT_SKILL_INDEX, 5);

            rsTestUtil.createTestProjectPartForUserId(profile.getId(), rsPRTeamEmployee.RT_AECOMPROJECT, 2);
            rsTestUtil.createTestProjectPartForUserId(profile.getId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 2);

            List<rs_Profile_Part__c> updateProfileParts = new List<rs_Profile_Part__c>();
            List<PR_Team_Employee__c> updateProjects = new List<PR_Team_Employee__c>();
            for(rs_Profile_Part__c pp : [Select Id from rs_Profile_Part__c where User__c =: u.Id]) {
                pp.Status__c = rsProfilePart.S_APPROVED;
                updateProfileParts.add(pp);
            }
            for(PR_Team_Employee__c pj : [Select Id from PR_Team_Employee__c where EmployeeUser__c =: u.Id]) {
                pj.Status__c = rsPRTeamEmployee.S_APPROVED;
                updateProjects.add(pj);
            }
            update updateProjects;
            update updateProfileParts;

            Test.startTest();
            rsSummaryController summaryController = new rsSummaryController();
            summaryController.profile = profile;
            Map<String,Integer> testMap = summaryController.getAreaPointMap();
            Map<String,Decimal> testNormalizedMap = summaryController.getNormalizedPointMap();
            Integer totalScore = summaryController.getTotalScore();
            String cmStatus = summaryController.getProfileCMStatus();
            String completionStatus = summaryController.getProfileCompletionStatus();
            Test.stopTest();

            System.assertEquals(testMap.get(rsProfilePart.RT_TRAINING), 5);
            System.assertEquals(testMap.get(rsProfilePart.RT_WORK_HISTORY), 5);
            System.assertEquals(testMap.get(rsProfilePart.RT_EDUCATION), 5);
            System.assertEquals(testMap.get(rsProfilePart.RT_AWARD), 5);
            System.assertEquals(testMap.get(rsProfilePart.RT_CERTIFICATION), 5);
            System.assertEquals(testMap.get(rsProfilePart.RT_LANGUAGES), 5);
            System.assertEquals(testMap.get(rsProfilePart.RT_PROF_AFFILIATION), 5);
            System.assertEquals(testMap.get(rsProfilePart.RT_REGISTRATION), 5);
            System.assertEquals(testMap.get(rsProfilePart.RT_TRANSLATIONS), 5);
            System.assertEquals(testMap.get(rsProfilePart.RT_PUBLICATION), 5);
            System.assertEquals(testMap.get(rsProfilePart.RT_SKILL_INDEX), 5);
            System.assertEquals(testMap.get(rsPRTeamEmployee.RT_AECOMPROJECT), 2);
            System.assertEquals(testMap.get(rsPRTeamEmployee.RT_NONAECOMPROJECT), 2);
            System.assertEquals(totalScore, 59);
            System.assertEquals(cmStatus, rsProfile.S_PENDING);
            System.assertEquals(completionStatus, Label.Fully_Complete);
            System.assertEquals(200,testNormalizedMap.get(rsPRTeamEmployee.RT_AECOMPROJECT));
        }
    }
}