/*************************************************************************
*
* PURPOSE: Tests for the Controller for the the page used to assign/reassign Profile Reviews
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsAssignProfileReviewControllerTest {

    private static testmethod void testAssignReview() {
        Test.StartTest();
        User u = [Select Id, ProfileId from User where Id = : UserInfo.getUserId()];
        
        Integer rand = Math.round(Math.random()*10000);

        User personBeingReviewed = new User(LastName = 'lastName', Alias = 'testalis', Email = 'SFDCTestCase@aecom.com', Username = 'rMaG2470@test.aecom.com'+rand,
                                            CommunityNickname = 'testNick', ProfileId = u.ProfileId, EmailEncodingKey = 'UTF-8',
                                            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles');
        insert personBeingReviewed;

        PageReference pr = Page.rsAssignProfileReview;
        pr.getParameters().put('type', rsProfileReviewsController.REV_UN_AMERICAS);
        pr.getParameters().put('UserId', personBeingReviewed.Id);
        Test.setCurrentPage(pr);

        rsAssignProfileReviewController controller = new rsAssignProfileReviewController();
        Test.stopTest();
        System.assertEquals(controller.getReviewee().Id, personBeingReviewed.Id);
        System.assertEquals(controller.getIsReassign(), false);

        controller.getReviewee().Profile_Reviewer__c = u.Id;
        Profile_Info__c customSetting = Profile_Info__c.getInstance();
        customSetting.Is_Content_Manager__c = false;
        upsert customSetting;

        //If the assignee is not a content manager, then the page reference should be null with an Page Message
        System.assertEquals(controller.save(), null);
        System.assert(!ApexPages.getMessages().isEmpty());

        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Okay now make the assignee a content manager and make sure it is assigned correctly
            controller.getReviewee().Profile_Reviewer__c = u.Id;
            customSetting = Profile_Info__c.getInstance();
            customSetting.Is_Content_Manager__c = true;
            upsert customSetting;
        }
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
        	System.assertEquals(controller.save().getUrl(), Page.rsProfileReviews.getUrl());
	        User assertAssignUser = [Select Id, Name, Profile_Reviewer__c from User where Id = :controller.getReviewee().Id];
    	    System.assertEquals(assertAssignUser.Profile_Reviewer__c, u.Id);
        }
    }

}