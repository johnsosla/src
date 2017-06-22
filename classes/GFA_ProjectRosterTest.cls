/*******************************************************************************
*
* PURPOSE: Test class for GFA_ProjectRoster
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
@isTest
private class GFA_ProjectRosterTest {

    @isTest static void testConstructors() {
        GFA_ProjectRoster projRoster = new GFA_ProjectRoster();
    }

    @isTest static void testGetsAndSets() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(2);

        List<GFA_ProjectRoster> projectRosters = GFA_TestUtils.createTestProjectRosters(1, projects);

        GFA_ProjectRoster projRoster = GFA_ProjectRoster.find.findById(projectRosters[0].getId());

        List<GFA_ProjectRoster> projRosters = GFA_ProjectRoster.find.findByProjectId(projects[0].getId());
        System.assertEquals(projRosters[0].getName(), projRoster.getName());

        projRoster.setRole('General Manager');
        projRoster.setIsActingPM(true);
        System.assertEquals('General Manager', projRoster.getRole());
        System.assertEquals(true, projRoster.getIsActingPM());

        projRoster.setProjectId(projects[0].getId());

        System.assertEquals(projects[0].getId(), projRoster.getProjectId());
        System.assertEquals(UserInfo.getUserId(), projRoster.getTeamMemberUserId());

        GFA_ProjectRoster newRoster = new GFA_ProjectRoster();
        Contact newContact = GFA_TestUtils.createTestContact();
        newContact.Email = 'abc@xyz.com';
        update newContact;
        newRoster.setTeamMemberNameId(newContact.Id);
        newRoster.setProjectId(projects[0].getId());
        newRoster.save();

        newRoster = GFA_ProjectRoster.find.findById(newRoster.getId());
        System.assertEquals(newContact.Id, newRoster.getTeamMemberNameId());

        System.assertEquals('abc@xyz.com', newRoster.getTeamMemberEmail());

        Set<Id> projectIds = new Set<Id>();
        for (GFA_Project item : projects) {
             projectIds.add(item.getId());
        }

        Map<Id, List<GFA_ProjectRoster>> projectRosterList = GFA_ProjectRoster.find.findByProjectIds(projectIds);
        System.assertEquals(projRoster.getId(), projectRosterList.get(projects[0].getId())[0].getId());

    }
}