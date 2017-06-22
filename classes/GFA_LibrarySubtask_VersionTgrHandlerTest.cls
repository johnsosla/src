@isTest
public class GFA_LibrarySubtask_VersionTgrHandlerTest {
    @isTest
    public static void GFA_LibrarySubtask_VersionTgrHandlerTest() {

        //GFA_LibrarySubtaskTriggerHandler HandleAfterInsert
        GFA_LibrarySubtask ls = GFA_TestUtils.createTestLibrarySubtasks(1)[0];
        List<GFA_Library_Subtask__c> lsList = new List<GFA_Library_Subtask__c>();
        
        Test.startTest();

        lsList.add((GFA_Library_Subtask__c)ls.getObj());

        GFA_Library_Subtask_Version__c lsv = [Select ID, Version_Status__c, Version_No__c From GFA_Library_Subtask_Version__c
                                              Where Library_Subtask__c = :ls.getId()];
        System.assertEquals(lsv.Version_No__c, 1);
        System.assertEquals(lsv.Version_Status__c, GFA_LibrarySubtaskVersion.STATUS_PENDING);

        ls.setActive();
        ls.save();
        GFA_LibrarySubtaskVersion lsvModel = new GFA_LibrarySubtaskVersion(lsv);
        lsvModel.setStatusActive();
        lsvModel.save();

        GFA_LibrarySubtaskVersion lsv2 = GFA_TestUtils.createTestLibrarySubtaskVersions(1, new List<GFA_LibrarySubtask> {ls})[0];
        lsv2.setStatus(GFA_LibrarySubtaskVersion.STATUS_PENDING);
        lsv2.save();
        lsv2.obj.Description__c = 'Test12345';
        lsv2.save();

        GFA_Library_Subtask_Version__c lsv2Requery = [Select ID, Version_Status__c, Version_No__c, Description__c From GFA_Library_Subtask_Version__c
                Where Id = :lsv2.getId() Order By Version_No__c Desc];
        System.assertEquals(2, lsv2Requery.Version_No__c);
        System.assertEquals(GFA_LibrarySubtaskVersion.STATUS_PENDING, lsv2Requery.Version_Status__c);
        System.assertEquals('Test12345', lsv2Requery.Description__c);


        //GFA_LibrarySubtask_VersionTriggerHandler HandleBeforeUpdate( Update existing active record to archived)
        GFA_LibrarySubtaskVersion lsv2Model = new GFA_LibrarySubtaskVersion(lsv2Requery);
        lsv2Model.setStatusActive();
        lsv2Model.save();

        List<GFA_Library_Subtask_Version__c> lsv3List = [Select ID, Version_Status__c, Version_No__c From GFA_Library_Subtask_Version__c
                Where Library_Subtask__c = :ls.getId() Order By Version_No__c Desc];
        System.assertEquals(lsv3List[0].Version_No__c, 2);
        System.assertEquals(lsv3List[0].Version_Status__c, 'Active');

        System.assertEquals(lsv3List[1].Version_No__c, 1);
        System.assertEquals(lsv3List[1].Version_Status__c, 'Archived');

        GFA_TestUtils.createTestLibrarySubtaskVersions(1, new List<GFA_LibrarySubtask> {ls});

        //GFA_LibrarySubtask_VersionTriggerHandler HandleBeforeupdate( Update active record)
        try {
            GFA_LibrarySubtaskVersion lsv3Model = new GFA_LibrarySubtaskVersion(lsv3List[0]);
            lsv3Model.save();

        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('Active or Archived record cannot be edited') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }


        //GFA_LibrarySubtask_VersionTriggerHandler HandleBeforeupdate( Update archived record)
        try {
            GFA_LibrarySubtaskVersion lsv3Model = new GFA_LibrarySubtaskVersion(lsv3List[1]);
            lsv3Model.save();

        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('Active or Archived record cannot be edited') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        //GFA_LibrarySubtask_VersionTriggerHandler HandleBeforeDelete( Delete archived record)
        try {
            GFA_LibrarySubtaskVersion lsv3Model = new GFA_LibrarySubtaskVersion(lsv3List[1]);
            lsv3Model.destroy();

        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('Active or Archived record cannot be deleted') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        //GFA_LibrarySubtask_VersionTriggerHandler HandleBeforeDelete( Delete active record)
        try {
            GFA_LibrarySubtaskVersion lsv3Model = new GFA_LibrarySubtaskVersion(lsv3List[0]);
            lsv3Model.destroy();

        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('Active or Archived record cannot be deleted') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        //GFA_LibrarySubtask_VersionTriggerHandler HandleAfterUpdate( Update Pending record)
        Map<String, Schema.RecordTypeInfo> mParentRtInfo = GFA_Library_Subtask__c.SObjectType.getDescribe().getRecordTypeInfosByName();

        GFA_LibrarySubtask ls1 = GFA_TestUtils.createTestLibrarySubtasks(1)[0];
        List<GFA_Library_Subtask__c> lsList1 = new List<GFA_Library_Subtask__c>();

        lsList1.add((GFA_Library_Subtask__c)ls1.getObj());

        GFA_Library_Subtask__c subtask = [Select Id, RecordTypeId From GFA_Library_Subtask__c
                                              Where Id = :ls1.getId()];
        System.assertEquals(subtask.RecordTypeId, mParentRtInfo.get(GFA_LibrarySubtask.RT_PENDING).getRecordTypeId());

        ls1.setDescription('Test');
        ls1.save();

        //GFA_LibrarySubtaskTriggerHandler HandleBeforeDelete( Delete Active record)
        try {
            ls1.setActive();
            ls1.save();

            GFA_Library_Subtask__c subtask1 = [Select Id, RecordTypeId From GFA_Library_Subtask__c
                                              Where Id = :ls1.getId()];


            GFA_LibrarySubtask ls3Model = new GFA_LibrarySubtask(subtask1);
            ls3Model.destroy();

        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('Active Subtask Cannot be deleted') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

		Test.stopTest();
    }

    @isTest
    public static void testHandleBeforeLibrarySubtaskInsert() {
        
        Integer rand = Math.round(Math.random()*10000);

        Profile appUserProfile = [Select Id, Name From Profile Where Name =: 'AECOM Standard User - Americas'];
        User tempUser = new User();
            tempUser.FirstName = 'test';
            tempUser.LastName = 'lastName';
            tempUser.Alias = 'test';
            tempUser.Email = 'SFDCTestCase@aecom.com';
            tempUser.Username ='rMaG2470@test.aecom.com'+rand;
            tempUser.CommunityNickname = 'testNick';
            tempUser.ProfileId = appUserProfile.Id;
            tempUser.EmailEncodingKey='UTF-8';
            tempUser.LanguageLocaleKey='en_US';
            tempUser.LocaleSidKey='en_US';
            tempUser.TimeZoneSidKey='America/Los_Angeles';
            tempUser.Status__c = rsProfile.S_PENDING;
            tempUser.IsActive = true;
            tempUser.AboutMe = 'test test test';
            tempUser.Bio__c = 'test';
            tempUser.Geography__c = '0xDEADBEEF';
            tempUser.Supergeography__c = 'Americas';

        System.runAs(tempUser) {
            try {
                GFA_Library_Subtask__c subtask = new GFA_Library_Subtask__c(
                    Name = 'Test lib',
                    Project_Sponsor__c = 'Client',
                    Discipline__c = 'IT',
                    Group__c = 'Construction Services',
                    Operating_Group__c = 'CS-EIC',
                    Impact_Level__c = 'Normal',
                    Risk_Level__c = 'Low'
                );
            insert subtask;
        } catch (Exception e) {
                Boolean expectedExceptionThrown = e.getMessage().contains('Only Admins can create Library Subtask') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
        }
    }
}