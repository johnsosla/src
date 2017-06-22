@isTest
private class GFA_ProjectTriggerHandlerTest {

    @isTest static void testAfterUpdate() {
        if (!GFA_User.getCurrentUser().getIsAdminUser()) {
            GFA_User.getCurrentUser().setIsAdminUser();
            
            /*PermissionSet adminSet = [Select Id from PermissionSet where Name = : GFA_User.ADMIN_PERMISSION_SET];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = adminSet.Id,
                    AssigneeId = UserInfo.getUserId());
            insert psa;*/
        }
        
        //GFA_User.clearCurrentUser();
        
        GFA_Project project = GFA_TestUtils.createTestProjects(1)[0];
        GFA_Project_Subtask__c projSubtask = [Select Id, Library_Subtask_Version__c from GFA_Project_Subtask__c];
        projSubtask.Added_By__c = GFA_ProjectSubtask.ADDED_BY_TEMPLATE;
        update projSubtask;
        GFA_Library_Subtask_Version__c version = [Select Id from GFA_Library_Subtask_Version__c where Id = : projSubtask.Library_Subtask_Version__c LIMIT 1];
        version.Scope_of_Service__c = 'Electrical';
        version.Risk_Level__c = 'High';
        update version;

        project.setScopeOfService('Electrical');
        project.setRiskLevel('High');
        project.save();

        Map<Id, List<GFA_ProjectSubtask>> subtaskMap = GFA_ProjectSubtask.find.findByProjectIds(new Set<Id> {project.getId()});
        System.assert(subtaskMap.get(project.getId())[0].getIsApplicable());

        project.setRiskLevel('Low');
        project.save();

        subtaskMap = GFA_ProjectSubtask.find.findByProjectIds(new Set<Id> {project.getId()});
        System.assert(!subtaskMap.get(project.getId())[0].getIsApplicable());
    }

    @isTest static void testAfterUpdateConditionals() {
        if (!GFA_User.getCurrentUser().getIsAdminUser()) {
            GFA_User.getCurrentUser().setIsAdminUser();
            
            /*PermissionSet adminSet = [Select Id from PermissionSet where Name = : GFA_User.ADMIN_PERMISSION_SET];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = adminSet.Id,
                    AssigneeId = UserInfo.getUserId());
            insert psa;*/
        }
        
        //GFA_User.clearCurrentUser();
        //
        GFA_Project project = GFA_TestUtils.createTestProjects(1)[0];
        GFA_Project_Subtask__c projSubtask = [Select Id, Library_Subtask_Version__c from GFA_Project_Subtask__c];
        projSubtask.Added_By__c = GFA_ProjectSubtask.ADDED_BY_TEMPLATE;
        update projSubtask;
        GFA_Library_Subtask_Version__c version = [Select Id from GFA_Library_Subtask_Version__c where Id = : projSubtask.Library_Subtask_Version__c LIMIT 1];
        version.Scope_of_Service__c = '';
        version.Risk_Level__c = 'High';
        update version;

        project.setScopeOfService('');
        project.setRiskLevel('High');
        project.save();

        version.Scope_of_Service__c = 'Electrical';
        version.Risk_Level__c = 'High';
        update version;

        project.setScopeOfService('');
        project.save();

        Map<Id, List<GFA_ProjectSubtask>> subtaskMap = GFA_ProjectSubtask.find.findByProjectIds(new Set<Id> {project.getId()});
        System.assert(subtaskMap.get(project.getId())[0].getIsApplicable());

        project.setRiskLevel('Low');
        project.save();

        subtaskMap = GFA_ProjectSubtask.find.findByProjectIds(new Set<Id> {project.getId()});
        System.assert(!subtaskMap.get(project.getId())[0].getIsApplicable());
    }

    @isTest static void testAfterUpdateProjectNotification() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(2);
        List<GFA_Project_Subtask__c> projSubtasks = [Select Id, Library_Subtask_Version__c from GFA_Project_Subtask__c];
        for (GFA_Project_Subtask__c subtask : projSubtasks) {
            subtask.Added_By__c = GFA_ProjectSubtask.ADDED_BY_TEMPLATE;
        }
        update projSubtasks;
        Map<Id, List<GFA_ProjectPhase>> projectPhaseMap = GFA_ProjectPhase.find.findByProjectIds(projects);

        List<GFA_ProjectPhase> projPhases = new List<GFA_ProjectPhase>();
        for (Id key : projectPhaseMap.keySet()) {
            projPhases.addAll(projectPhaseMap.get(key));
        }

        List<GFA_ProjectPhase> projectPhases = GFA_ProjectPhase.find.findByProjectId(projects[0].getId());
        System.assertEquals(projectPhases[0].getProjectId(), projPhases[0].getProjectId());


        Map<Id, List<GFA_ProjectTask>> projectTaskMap = GFA_ProjectTask.find.findByProjectPhaseIds(projectPhases);

        List<GFA_ProjectTask> projectTasks = new List<GFA_ProjectTask>();
        for (Id key : projectTaskMap.keySet()) {
            projectTasks.addAll(projectTaskMap.get(key));
        }

        Map<Id, List<GFA_ProjectSubtask>> projectTaskSubtaskMap = GFA_ProjectSubtask.find.findByProjectTaskIds(projectTasks);
        List<GFA_ProjectSubtask> projectSubtasks = new List<GFA_ProjectSubtask>();
        for (Id key : projectTaskSubtaskMap.keySet()) {
            projectSubtasks.addAll(projectTaskSubtaskMap.get(key));
        }

        List<GFA_ProjectRoster> rosters = GFA_TestUtils.createTestProjectRosters(1, projects);
        GFA_Project project = projects[0];
        project.setProjectRosters(rosters);
        System.assertEquals(2, rosters.size());

        GFA_Project__c projectStatus = [Select Id, Project_Status__c From GFA_Project__c Where Id = : project.getId()];
        projectStatus.Project_Status__c = 'In Progress';
        update projectStatus;

    }

    @isTest static void testBeforeInsert() {
        Account account = new Account (
            Name = 'Shell Oil Test'
        );
        insert account;

        Opportunity opportunity = new Opportunity(
            Name = 'Shell Oil Opportunity',
            AccountId = account.Id,
            CloseDate = Date.newInstance(2016, 03, 21),
            StageName = '0',
            Probability_Stage__c = 95,
            CurrencyIsoCode = 'USD',
            Capture_Manager_User__c = UserInfo.getUserId(),
            Enterprise_Service__c = 'Engineering'
            );
        insert opportunity;

        GFA_Project__c project = new GFA_Project__c(
            Project_Name__c = 'Test Project',
            Group__c = 'Construction Services',
            Operating_Group__c = 'CS-EIC',
            Complexity__c = 'Medium',
            Risk_Level__c = 'Medium',
            Project_Sponsor__c = 'Client',
            Client__c = null,
            Opportunity__c = opportunity.Id
            );
        insert project;

        GFA_Project__c project1 = [Select Id, Client__r.Name, Opportunity__c From GFA_Project__c Where Id =: project.Id];
        System.assertEquals(account.Name, project1.Client__r.Name);
    }
}