/*************************************************************************
*
* PURPOSE: Test Class for Controller for Certification Section
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
@isTest
private class rsCertifiationControllerTest {

    @isTest static void testSavePart() {
        User u = [Select Id from User where Id = : UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsCertificationController cont = new rsCertificationController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setCertificationTitle('Cert Title');
        cont.CurrentPart.setCertificationDescription('Cert Description');
        cont.CurrentPart.setDateCertified('12/30/2013');

        Test.startTest();
        PageReference pf = cont.savePart();
        Test.stopTest();

        rs_Profile_Part__c pp = [Select Certification_Title__c, Certification_Description__c, Date_Certified__c from rs_Profile_Part__c];
        System.assertEquals( null, pf );
        System.assertEquals( pp.Certification_Title__c, 'Cert Title');
        System.assertEquals( pp.Certification_Description__c, 'Cert Description');
        System.assertEquals( true, pp.Date_Certified__c.isSameDay(Date.parse('12/30/2013')));
    }

    @isTest static void testCancelPart() {
        User u = [Select Id from User where Id = : UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsCertificationController cont = new rsCertificationController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setCertificationTitle('Cert Title');
        cont.CurrentPart.setCertificationDescription('Cert Description');
        cont.CurrentPart.setDateCertified('12/30/2013');
        cont.savePart();
        rs_Profile_Part__c pp = [Select Certification_Title__c, Certification_Description__c, Date_Certified__c from rs_Profile_Part__c];
        ApexPages.currentPage().getParameters().put('partId', pp.Id);
        cont.editPart();

        cont.CurrentPart.setCertificationTitle('Cert Titlezzzzzz');
        cont.CurrentPart.setCertificationDescription('Cert Descriptionzzzzzz');
        cont.CurrentPart.setDateCertified('1/5/2013');

        Test.startTest();
        PageReference pf = cont.cancelPart();
        cont.editPart();
        Test.stopTest();

        System.assertEquals( null, pf );
        System.assertEquals( cont.CurrentPart.getCertificationTitle(), 'Cert Title');
        System.assertEquals( cont.CurrentPart.getCertificationDescription(), 'Cert Description');
        System.assertEquals( cont.CurrentPart.getDateCertified(), '12/30/2013');

    }

    @isTest static void testMovePart() {
        User u = [Select Id from User where Id = : UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);

        rsProfilePart cert1 = new rsProfilePart(UserInfo.getUserId(), rsProfilePart.RT_CERTIFICATION);
        cert1.setCertificationTitle('Cert Title');
        cert1.setCertificationDescription('Cert Description');
        cert1.setDateCertified('12/30/2013');
        cert1.setPartSequence(0);
        cert1.save();

        rsProfilePart cert2 = new rsProfilePart(UserInfo.getUserId(), rsProfilePart.RT_CERTIFICATION);
        cert2.setCertificationTitle('Cert Title1');
        cert2.setCertificationDescription('Cert Description1');
        cert2.setDateCertified('12/30/2014');
        cert2.setPartSequence(1);
        cert2.save();

        rsCertificationController part1 = new rsCertificationController();
        part1.profile = profile;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('partId', cert2.getId());
        part1.movePartUp();
        part1.movePartDown();
        part1.movePartUp();
        Test.stopTest();

        rs_Profile_Part__c requery = [Select certification_Title__c, Part_Sequence__c from rs_Profile_Part__c where Certification_Title__c = 'Cert Title'];
        rs_Profile_Part__c requery2 = [Select certification_Title__c, Part_Sequence__c from rs_Profile_Part__c where Certification_Title__c = 'Cert Title1'];
        System.assertEquals(1, requery.Part_Sequence__c);
        System.assertEquals(0, requery2.Part_Sequence__c);
    }

}