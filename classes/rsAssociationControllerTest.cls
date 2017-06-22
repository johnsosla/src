/*************************************************************************
*
* PURPOSE: Test Class for Controller for Association Section
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
@isTest
private class rsAssociationControllerTest {

    @isTest static void testSaveDelete() {
        User u = [Select Id, Is_Profile_Locked__c, Date_Time_Sent_for_Review__c from User where Id =: UserInfo.getUserId()];
        User newCM = rsTestUtil.createTestUsers(true, 1)[0];
        rsProfile profile = new rsProfile(u);
        rsAssociationController cont = new rsAssociationController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setAssociationName('IEEE');
        cont.CurrentPart.setMemberSince('12/12/2000');
        cont.CurrentPart.setPosition('Member');
        cont.CurrentPart.setOwnerId(newCM.Id);

        Test.startTest();
        PageReference pf = cont.savePart();
        rs_Profile_Part__c pp = [Select Association_Name__c,Member_Since__c,Position__c from rs_Profile_Part__c];
        System.assertEquals( null, pf );
        System.assertEquals( pp.Association_Name__c, 'IEEE' );
        System.assertEquals( true, pp.Member_Since__c.isSameDay(Date.parse('12/12/2000')));
        System.assertEquals( 'Member',pp.Position__c );

        ApexPages.currentPage().getParameters().put('partId', cont.CurrentPart.getId());
        cont.deletePart();
        List<rsProfilePart> profilePartsRequery = rsProfilePart.find.byIdAsSelfOrProxyOrCM(cont.profile.getId());
        System.assertEquals(profilePartsRequery.size(), 0);
        Test.stopTest();
    }

    @isTest static void testCancel() {
        User u = [Select Id, Is_Profile_Locked__c, Date_Time_Sent_for_Review__c from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsAssociationController cont = new rsAssociationController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setAssociationName('IEEE');
        cont.CurrentPart.setMemberSince('12/2000');
        cont.CurrentPart.setPosition('Member');
        cont.savePart();
        rs_Profile_Part__c pp = [Select Id,Association_Name__c,Member_Since__c,Position__c from rs_Profile_Part__c];
        ApexPages.currentPage().getParameters().put('partId', pp.Id);
        cont.editPart();

        cont.CurrentPart.setAssociationName('test');
        cont.CurrentPart.setMemberSince('12/1999');
        cont.CurrentPart.setPosition('Judge');

        Test.startTest();
        PageReference pf = cont.cancelPart();
        cont.editPart();
        Test.stopTest();

        System.assertEquals( null, pf );
        System.assertEquals(cont.CurrentPart.getAssociationName(), 'IEEE');
        System.assertEquals(cont.CurrentPart.getMemberSince(), '12/2000');
        System.assertEquals(cont.CurrentPart.getPosition(),'Member');
    }

}