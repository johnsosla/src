/** ------------------------------------------------------------------------------------------------------
 * @Description: Test coverage for the ECO_ProjectTeamFlyoutController Apex Controller. 
 * @Author:      NTT Data - Priya Parepalli
 * @Date:        07/19/2016
 *-----------------------------------------------------------------------------------------------------*/
@isTest
private class ECO_ProjectTeamFlyoutTest {
    static testMethod void ECO_ProjectTeamFlyoutController_UnitTest() {
        pse__Proj__c testProj = ECO_Utils_Testing.createProject();
        
        User user1 = ECO_Utils_Testing.createTestUser('Standard User');
        User user2 = ECO_Utils_Testing.createTestUser('System Administrator');
        List<User> lUser = new List<User>();
        lUser.add(user1);
        lUser.add(user2);
        insert lUser;
        
        Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Contact.sObjectType, 'PSA Resource');
        Contact testContact = new Contact();
        testContact.Email = user1.Email;
        testContact.FirstName = user1.FirstName;
        testContact.LastName =  user1.LastName;
        testContact.Phone = '55555555555';
        testContact.pse__Salesforce_User__c = user1.Id;
        testContact.RecordTypeId = recordTypeId;
        testContact.User__c = user1.Id;
        insert testContact;
        
        ProjectRole__c projectRole = new ProjectRole__c();
        projectRole.Name = 'ORM Contact';
        projectRole.Type__c = 'Team Member';
        projectRole.Active__c = true;
        insert projectRole;
        
        Test.startTest();
        ECO_ProjectTeamFlyoutController con = new ECO_ProjectTeamFlyoutController();
        con.sProjectId = testProj.Id;
        list<ProjectTeamMember__c> lPTM = con.lProjectTeamMembers;
        
        ProjectTeamMember__c ptm = new ProjectTeamMember__c();
        ptm = con.oProjectTeamMember;
        ptm.Contact__c = testContact.Id;
        ptm.ProjectRole__c = projectRole.Id;
        con.saveTeamMember();
        Test.stopTest();
    }
}