@isTest
public class GFA_ProjectRosterControllerTest {
    @isTest
    public static void GFA_ProjectRosterControllerTest() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);

        List<GFA_ProjectRoster> projRosters = GFA_TestUtils.createTestProjectRosters(1, projects);

        ApexPages.StandardController sc = new ApexPages.StandardController((GFA_Project_Roster__c)projRosters[0].getObj());
        GFA_ProjectRosterController cont = new GFA_ProjectRosterController(sc);

        System.assert(cont.editPR().getUrl().containsIgnoreCase('GFA_ProjectRosterEdit'));

        cont.projectRoster.setIsActingPM(true);
        cont.savePR();

        List<GFA_Project_Roster__c> updatedRosters = [Select Id, Is_Acting_Project_Manager__c From GFA_Project_Roster__c];

        System.assertEquals(1, updatedRosters.size());
        System.assertEquals(true, updatedRosters[0].Is_Acting_Project_Manager__c);

        cont.cancelPR();
        cont.deletePr();

        List<GFA_Project_Roster__c> delRosters = [Select Id From GFA_Project_Roster__c];

        System.assertEquals(0, delRosters.size());


        ApexPages.currentPage().getParameters().put('projectid', projects[0].getId());
        GFA_ProjectRoster projectRosterNew = new GFA_ProjectRoster();
        ApexPages.StandardController sc1 = new ApexPages.StandardController((GFA_Project_Roster__c)projectRosterNew.getObj());
        GFA_ProjectRosterController cont1 = new GFA_ProjectRosterController(sc1);

        cont1.projectRoster.setRole('HR Manager');

        cont1.savePR();
        System.assertEquals('HR Manager', cont1.projectRoster.getRole());
        cont.readSelectedIdListFromPage();
        cont.getCurrentPageResults();
        cont.populateSelectedIdListToPage();
        cont.checkAllAction();

    }
}