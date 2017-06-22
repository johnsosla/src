/*************************************************************************
*
* PURPOSE: Test Class for Controller for Projects component
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
private class rsProjectControllerTest {
    private static testmethod void testNewCancel() {
        Test.startTest();
        rsProjectController cont = new rsProjectController();
        cont.profile = rsProfile.find.byUserId(UserInfo.getUserId());
        PageReference newResult = cont.newPart();
        Test.stopTest();

        System.assertEquals(newResult, null);
        System.assert(cont.getisEditMode() );
        PageReference cancelResult = cont.cancelPart();
        System.assertEquals(cancelResult, null);
        System.assertEquals(cont.getProject(), null);
        System.assertEquals(cont.CurrentProject, null);
        System.assert(cont.getIsListMode() );
    }

    private static testmethod void testSaveDelete() {
        //Create a new work history record that we'll reference when we create a non aecom project
        rsTestUtil.createTestProfilePartForUserId(UserInfo.getUserId(), rsProfilePart.RT_WORK_HISTORY, 1);
        rsProfilePart workHistoryRecord =  rsProfilePart.find.byIdAsSelfOrProxyOrCM(UserInfo.getUserId()).get(0) ;
        User newCM = rsTestUtil.createTestUsers(true, 1)[0];
        Test.startTest();
        rsProjectController cont = new rsProjectController();
        cont.profile = rsProfile.find.byUserId(UserInfo.getUserId());
        cont.Filter = new rsFilterManager();
        cont.Filter.UserId = cont.profile.getId();
        cont.Filter.setupProjectSearchFilters();
        cont.newPart();
        //Test create new AECOM Project
        cont.newAECOMProjectView();
        cont.CurrentProject.setProjectNameEditable('Test Project Name');
        cont.CurrentProject.setProjectNumberEditable('123456789');
        cont.CurrentProject.setProjectGroup('Test Project Group');
        cont.CurrentProject.setLocationCountryEditable('United States');
        cont.CurrentProject.setProjectRole('Architect');
        cont.CurrentProject.setLocationStateProvinceEditable('Arizona');
        cont.CurrentProject.setClientNameEditable('Test Client Name');
        cont.CurrentProject.setLocationCityEditable('Test City');
        cont.CurrentProject.setDateInvolvementStarted('10/11/12');
        cont.CurrentProject.setDateInvolvementEnded('01/02/13');
        cont.CurrentProject.setOutputonResume(true);
        cont.CurrentProject.setRoleDescription('Here is a role description');
        cont.savePart();

        cont.newPart();
        //Test create new Non-AECOM Project
        cont.nonAECOMProjectView();
        cont.setisNonAECOMProject(true);
        cont.nonAECOMCheckRT();
        cont.CurrentProject.setProjectNameEditable('Test Project Name');
        cont.CurrentProject.getObj().put('Work_History__c', workHistoryRecord.getId() );
        cont.CurrentProject.setProjectGroup('Test Project Group');
        cont.CurrentProject.setLocationCountryEditable('United States');
        cont.CurrentProject.setProjectRole('Architect');
        cont.CurrentProject.setLocationStateProvinceEditable('Arizona');
        cont.CurrentProject.setClientNameEditable('Test Client Name');
        cont.CurrentProject.setLocationCityEditable('Test City');
        cont.CurrentProject.setDateInvolvementStarted('10/11/12');
        cont.CurrentProject.setDateInvolvementEnded('01/02/13');
        cont.CurrentProject.setOutputonResume(true);
        cont.CurrentProject.setRoleDescription('Here is a role description');
        cont.CurrentProject.setOwnerId(newCM.Id);
        cont.savePart();


        Test.stopTest();

        List<rsPRTeamEmployee> profileProjects = cont.getAllProjects();
        System.assertEquals(profileProjects.size(), 2);

        System.assertEquals(cont.getIsExistingAECOMProject(), true);
        System.assertEquals(cont.getIsNewAECOMProject(), false);
        System.assertEquals(cont.getIsNonAECOMProject(), false);

        ApexPages.currentPage().getParameters().put('projectId', cont.CurrentProject.getId());
        cont.deletePart();

        List<rsPRTeamEmployee> profileProjectsRequery = rsPRTeamEmployee.find.byIdAsSelfOrProxyOrCM(cont.profile.getId());
        System.assertEquals(profileProjectsRequery.size(), 1);
    }

    private static testmethod void testEditView() {
        Test.startTest();
        rsProjectController cont = new rsProjectController();
        cont.profile = rsProfile.find.byUserId(UserInfo.getUserId());
        PageReference newResult = cont.newPart();
        cont.newAECOMProjectView();
        cont.CurrentProject.setDateInvolvementStarted('10/2012');
        cont.CurrentProject.setDateInvolvementEnded('01/2013');
        cont.CurrentProject.setProjectRole('Here is a test project role');
        cont.CurrentProject.setRoleDescription('Here is a role description');
        cont.savePart();

        ApexPages.currentPage().getParameters().put('projectId', cont.CurrentProject.getId());

        cont = new rsProjectController();
        cont.profile = rsProfile.find.byUserId(UserInfo.getUserId());
        System.assertEquals(cont.profile.getProfileProjects().size(), 1);
        cont.editPart();
        System.assert(cont.CurrentProject != null);
        System.assert(cont.getIsEditMode() );
        cont.savePart();
        System.assertEquals('10/2012', cont.CurrentProject.getDateInvolvementStarted());
        System.assertEquals('01/2013', cont.CurrentProject.getDateInvolvementEnded());
        System.assertEquals('Here is a test project role', cont.CurrentProject.getProjectRole());
        System.assertEquals('Here is a role description', cont.CurrentProject.getRoleDescription());
        System.assert(cont.getIsListMode() );
        cont.viewPart();
        System.assert(cont.getIsViewMode() );
        System.assert(cont.CurrentProject != null);

        Test.stopTest();
    }

    private static testmethod void testApprovePart() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_AECOMPROJECT, 1);

        Test.startTest();
        rsProjectController cont = new rsProjectController();
        cont.profile = rsProfile.find.byUserId(UserInfo.getUserId());
        rsPRTeamEmployee partToBeApproved = cont.profile.getProfileProjects().get(0);
        ApexPages.currentPage().getParameters().put('partId', partToBeApproved.getId() );
        cont.approvePart();
        Test.stopTest();

        rsPRTeamEmployee partToBeApprovedRequery = new rsPRTeamEmployee((PR_Team_Employee__c)rsPRTeamEmployee.find.byId(partToBeApproved.getId()).getObj());
        System.assert(partToBeApprovedRequery.getStatus() == rsPRTeamEmployee.S_APPROVED);
    }

    private static testmethod void testViewParts() {
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_AECOMPROJECT, 1);
        rsTestUtil.createTestProjectPartForUserId(UserInfo.getUserId(), rsPRTeamEmployee.RT_NONAECOMPROJECT, 1);

        PR_Team_Employee__c proj = [Select Id, Project_Group_Editable__c from PR_Team_Employee__c where EmployeeUser__c = : UserInfo.getUserId() AND RecordType.Name = : rsPRTeamEmployee.RT_NONAECOMPROJECT];
        proj.Project_Group_Editable__c = 'New Group';
        update proj;

        Test.startTest();
        rsProjectController cont = new rsProjectController();
        cont.profile = rsProfile.find.byUserId(UserInfo.getUserId());
        cont.Filter = new rsFilterManager();
        cont.Filter.UserId = cont.profile.getId();
        cont.Filter.setupProjectSearchFilters();
        cont.getProjectViewParts();

        ApexPages.currentPage().getParameters().put('sortField', 'Project_Group_Editable__c');
        cont.sortParts();
        System.assertEquals(proj.Id, cont.getProjectViewParts()[0].getObj().getId());

        cont.sortParts();
        System.assertEquals(proj.Id, cont.getProjectViewParts()[1].getObj().getId());

        cont.sortParts();
        System.assertEquals(proj.Id, cont.getProjectViewParts()[0].getObj().getId());
        Test.stopTest();
    }

    private static testmethod void testNewNonAECOMPart() {
        rsProjectController cont = new rsProjectController();
        cont.profile = rsProfile.find.byUserId(UserInfo.getUserId());

        Test.startTest();
        cont.newNonAECOMPart();
        Test.stopTest();

        System.assertEquals(true, cont.getIsNonAECOMProject());
        System.assertEquals(false, cont.getIsNewAECOMProject());
        System.assertEquals(false, cont.getIsExistingAECOMProject());

    }

    private static testmethod void testSelectedProjectTypes() {
        rsProjectController cont = new rsProjectController();
        cont.profile = rsProfile.find.byUserId(UserInfo.getUserId());

        Test.startTest();
        System.assertEquals(rsProjectController.EXISTING_PROJECT, cont.getEXISTING_PROJECT());
        System.assertEquals(rsProjectController.NEW_PROJECT, cont.getNEW_PROJECT());
        System.assertEquals(rsProjectController.NON_PROJECT, cont.getNON_PROJECT());
        cont.SelectedProjectType = rsProjectController.EXISTING_PROJECT;
        cont.changeProjectTypeView();
        System.assertEquals(true, cont.getIsExistingAECOMProject());

        cont.SelectedProjectType = rsProjectController.NEW_PROJECT;
        cont.changeProjectTypeView();
        System.assertEquals(true, cont.getIsNewAECOMProject());
        System.assertEquals(false, cont.getIsExistingAECOMProject());

        cont.SelectedProjectType = rsProjectController.NON_PROJECT;
        cont.changeProjectTypeView();
        System.assertEquals(true, cont.getIsNonAECOMProject());
        System.assertEquals(false, cont.getIsExistingAECOMProject());
        System.assertEquals(false, cont.getIsNewAECOMProject());
        Test.stopTest();
    }

    private static testmethod void testArchive() {
        rsProjectController cont = new rsProjectController();
        cont.profile = rsProfile.find.byUserId(UserInfo.getUserId());
        PageReference newResult = cont.newPart();
        cont.newAECOMProjectView();
        cont.CurrentProject.setDateInvolvementStarted('10/2012');
        cont.CurrentProject.setDateInvolvementEnded('01/2013');
        cont.CurrentProject.setProjectRole('Here is a test project role');
        cont.CurrentProject.setRoleDescription('Here is a role description');
        cont.savePart();
        ApexPages.currentPage().getParameters().put('projectId', cont.CurrentProject.getId());

        Test.startTest();
        String projectId = cont.CurrentProject.getId();
        cont.archivePart();
        System.assertEquals(0, cont.profile.getProfileProjects().size());
        Test.stopTest();

        PR_Team_Employee__c emp = [Select Id, Status__c from PR_Team_Employee__c where Id = : projectId];
        System.assertEquals(rsPRTeamEmployee.S_ARCHIVED, emp.Status__c);
    }

    private static testmethod void testRestore() {
        rsProjectController cont = new rsProjectController();
        cont.profile = rsProfile.find.byUserId(UserInfo.getUserId());
        PageReference newResult = cont.newPart();
        cont.newAECOMProjectView();
        cont.CurrentProject.setDateInvolvementStarted('10/2012');
        cont.CurrentProject.setDateInvolvementEnded('01/2013');
        cont.CurrentProject.setProjectRole('Here is a test project role');
        cont.CurrentProject.setRoleDescription('Here is a role description');
        cont.savePart();
        ApexPages.currentPage().getParameters().put('projectId', cont.CurrentProject.getId());

        Test.startTest();
        String projectId = cont.CurrentProject.getId();
        cont.restorePart();
        System.assertEquals(0, cont.profile.getProfileProjects().size());
        Test.stopTest();

        PR_Team_Employee__c emp = [Select Id, Status__c from PR_Team_Employee__c where Id = : projectId];
        System.assertEquals(rsPRTeamEmployee.S_APPROVED, emp.Status__c);
    }

}