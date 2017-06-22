/*************************************************************************
*
* PURPOSE: Test Class for Controller for Reference Section
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
@isTest
private class rsReferenceControllerTest {

    @isTest static void testGettersAndSetters() {
        User u = [Select Id from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsReferenceController cont = new rsReferenceController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setReferenceFirstName('Test First Name');
        cont.CurrentPart.setReferenceLastName('Test Last Name');
        cont.CurrentPart.setReferenceCompanyName('Test Company');
        cont.CurrentPart.setReferenceTitle('Test Title');
        cont.CurrentPart.setReferenceEmail('test@test.com');
        cont.CurrentPart.setReferencePhone('(602) 456-1234');

        Test.startTest();
        cont.savePart();
        Test.stopTest();

        System.assertEquals('Test First Name',cont.CurrentPart.getReferenceFirstName());
        System.assertEquals('Test Last Name',cont.CurrentPart.getReferenceLastName());
        System.assertEquals('Test Company',cont.CurrentPart.getReferenceCompanyName());
        System.assertEquals('Test Title',cont.CurrentPart.getReferenceTitle());
        System.assertEquals('test@test.com',cont.CurrentPart.getReferenceEmail());
        System.assertEquals('(602) 456-1234',cont.CurrentPart.getReferencePhone());
    }
}