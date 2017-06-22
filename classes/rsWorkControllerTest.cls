/*************************************************************************
*
* PURPOSE: Test Class for Controller for Work History Section
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsWorkControllerTest {

    private static testmethod void testSave() {
        User u = [Select Id from User where Id = : UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsWorkController cont = new rsWorkController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setCompanyName('Ethos');
        cont.CurrentPart.setJobTitle('Developer');
        cont.CurrentPart.setStartDate('6/1992');
        cont.CurrentPart.setEndDate('7/2014');
        cont.CurrentPart.setCity('Phoenix');
        cont.CurrentPart.setWorkHistoryState('Arizona');
        cont.CurrentPart.setWorkHistoryCountry('United States');
        cont.CurrentPart.setCurrent(false);


        Test.startTest();
        PageReference pf = cont.savePart();
        System.assertEquals('Ethos', cont.CurrentPart.getCompanyName());
        System.assertEquals('Developer', cont.CurrentPart.getJobTitle());
        System.assertEquals('06/1992', cont.CurrentPart.getStartDate());
        System.assertEquals('07/2014', cont.CurrentPart.getEndDate());
        System.assertEquals('Phoenix', cont.CurrentPart.getCity());
        System.assertEquals('Arizona', cont.CurrentPart.getWorkHistoryState());
        System.assertEquals('United States', cont.CurrentPart.getWorkHistoryCountry());
        System.assertEquals(false, cont.CurrentPart.getCurrent());
        Test.stopTest();

        rs_Profile_Part__c pp = [Select Company_Name__c, Job_Title__c, Start_Date__c, End_Date__c, City__c, Work_History_State__c, Work_History_Country__c from rs_Profile_Part__c];
        System.assertEquals( null, pf );
        System.assertEquals( 'Ethos', pp.Company_Name__c );
        System.assertEquals( 'Developer', pp.Job_Title__c );
        System.assert(pp.Start_Date__c.isSameDay(Date.parse('6/01/1992')));
        System.assert(pp.End_Date__c.isSameDay(Date.parse('7/01/2014')));
        System.assertEquals( 'Phoenix', pp.City__c);
        System.assertEquals( 'Arizona', pp.Work_History_State__c);
        System.assertEquals( 'United States', pp.Work_History_Country__c);
    }

    private static testmethod void testCancel() {
        //TODO
    }

}