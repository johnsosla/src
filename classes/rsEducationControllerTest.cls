/*******************************************************************************
*
* PURPOSE: Test controller for the Education section in Skills & Qualifications
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
********************************************************************************/
@isTest
private class rsEducationControllerTest {

    @isTest static void testSavePart() {
        User u = [Select Id, Date_Time_Sent_for_Review__c from User where Id = : UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsEducationController cont = new rsEducationController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setInstitution('Test Institution');
        cont.CurrentPart.setDegree('Degree');
        cont.CurrentPart.setDegreeSpecialty('Test Specialty');
        cont.CurrentPart.setInstitutionCountry('United States');
        cont.CurrentPart.setYearObtained(1992);

        Test.startTest();
        PageReference pf = cont.savePart();
        Test.stopTest();

        rs_Profile_Part__c pp = [Select Institution__c, Degree__c, Degree_Specialty__c, Institution_Country__c, Year_Obtained__c from rs_Profile_Part__c];

        System.assertEquals( null, pf);
        System.assertEquals( pp.Institution__c, cont.CurrentPart.getInstitution());
        System.assertEquals( pp.Degree__c, cont.CurrentPart.getDegree());
        System.assertEquals( pp.Degree_Specialty__c, cont.CurrentPart.getDegreeSpecialty());
        System.assertEquals( pp.Institution_Country__c, cont.CurrentPart.getInstitutionCountry());
        System.assertEquals( pp.Year_Obtained__c, cont.CurrentPart.getYearObtained());
    }

    @isTest static void testCancelPart() {
        User u = [Select Id, Date_Time_Sent_for_Review__c from User where Id = : UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsEducationController cont = new rsEducationController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setInstitution('Test Institution');
        cont.CurrentPart.setDegree('Degree');
        cont.CurrentPart.setDegreeSpecialty('Test Specialty');
        cont.CurrentPart.setInstitutionCountry('United States');
        cont.CurrentPart.setYearObtained(1992);
        cont.savePart();
        rs_Profile_Part__c pp = [Select Institution__c, Degree__c, Degree_Specialty__c, Institution_Country__c, Year_Obtained__c
                                 from rs_Profile_Part__c];
        ApexPages.currentPage().getParameters().put('partId', pp.Id);
        cont.editPart();

        cont.CurrentPart.setInstitution('Another Institution');
        cont.CurrentPart.setDegree('Different Degree');
        cont.CurrentPart.setDegreeSpecialty('Fake Specialty');
        cont.CurrentPart.setInstitutionCountry('Canada');
        cont.CurrentPart.setYearObtained(2008);

        Test.startTest();
        PageReference pf = cont.cancelPart();
        cont.editPart();
        Test.stopTest();

        System.assertEquals( null, pf);
        System.assertEquals( cont.CurrentPart.getInstitution(), 'Test Institution');
        System.assertEquals( cont.CurrentPart.getDegree(), 'Degree');
        System.assertEquals( cont.CurrentPart.getDegreeSpecialty(), 'Test Specialty');
        System.assertEquals( cont.CurrentPart.getInstitutionCountry(), 'United States');
        System.assertEquals( cont.CurrentPart.getYearObtained(), 1992);
    }

    @isTest static void testMovePart() {
        User u = [Select Id from User where Id = : UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);

        rsProfilePart edu1 = new rsProfilePart(UserInfo.getUserId(), rsProfilePart.RT_EDUCATION);
        edu1.setDegree('Degree');
        edu1.setYearObtained(1999);
        edu1.setPartSequence(0);
        edu1.save();

        rsProfilePart edu2 = new rsProfilePart(UserInfo.getUserId(), rsProfilePart.RT_EDUCATION);
        edu2.setDegree('Degree1');
        edu2.setYearObtained(2000);
        edu2.setPartSequence(1);
        edu2.save();

        rsEducationController part1 = new rsEducationController();
        part1.profile = profile;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('partId', edu2.getId());
        part1.movePartUp();
        part1.movePartDown();
        part1.movePartUp();
        Test.stopTest();

        rs_Profile_Part__c requery = [Select Degree__c, Part_Sequence__c from rs_Profile_Part__c where Degree__c = 'Degree'];
        rs_Profile_Part__c requery2 = [Select Degree__c, Part_Sequence__c from rs_Profile_Part__c where Degree__c = 'Degree1'];
        System.assertEquals(1, requery.Part_Sequence__c);
        System.assertEquals(0, requery2.Part_Sequence__c);

    }

}