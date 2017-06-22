/*******************************************************************************
*
* PURPOSE: Test class for GFA_ProjectDeliverable
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
@isTest
private class GFA_ProjectDeliverableTest {

    @isTest static void testConstructor() {
        GFA_ProjectDeliverable projectDeliverable = new GFA_ProjectDeliverable();
    }

    @isTest static void testFindBy() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(2);

        GFA_Project_Task__c task = [Select Id from GFA_Project_Task__c where Project_Phase__r.GFA_Project__c = : projects[0].getId() LIMIT 1];

        List<GFA_ProjectTask> tasks = new List<GFA_ProjectTask>();
        tasks.add(new GFA_ProjectTask((GFA_Project_Task__c)task));

        List<GFA_ProjectSubtask> tempSubtasks = GFA_ProjectSubtask.find.findByProjectTaskId(task.Id);
        List<GFA_ProjectDeliverable> projDeliverables = GFA_TestUtils.createTestProjectDeliverables(3, tempSubtasks);

        Map<Id, List<GFA_ProjectDeliverable>> projDelMap = GFA_ProjectDeliverable.find.findByProjectSubtaskIds(tempSubtasks);
        // 3 from above and 2 from the initial creation of the project
        System.assertEquals(5, projDelMap.get(tempSubtasks[0].getId()).size());

        GFA_ProjectDeliverable tempprojDeliverable = GFA_ProjectDeliverable.find.findById(projDeliverables[0].getId());

        tempprojDeliverable.setName('Test Project Deliverable');
        tempprojDeliverable.setLink('www.yahoo.com');

        GFA_ProjectSubtask tempSubtask = GFA_ProjectSubtask.find.findById(tempSubtasks[0].getId());
        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(1);

        List<GFA_LibrarySubtaskVersion> libSubtaskVersions = GFA_TestUtils.createTestLibrarySubtaskVersions(1, libSubtasks);
        tempSubtask.setLibrarySubtaskVersions(libSubtaskVersions);

        Map<Id, List<GFA_ProjectSubtask>> tempSubtasksMap = GFA_ProjectSubtask.find.findByProjectTaskIds(tasks);
        GFA_ProjectSubtask tempSubtask1 = tempSubtasksMap.get(tasks[0].getId())[0];

        System.assertEquals('Test Project Deliverable', tempprojDeliverable.getName());
        System.assertEquals('http://www.yahoo.com', tempprojDeliverable.getLink());
        System.assertEquals(tempSubtask.getId(), tempprojDeliverable.getProjectSubtaskId());
        System.assertEquals(true, tempprojDeliverable.getHiddenDeliverable());
        System.assertEquals(true, tempprojDeliverable.getCanViewDeliverable());

        tempprojDeliverable.setLink('http://www.google.com');
        System.assertEquals('http://www.google.com', tempprojDeliverable.getLink());

        List<GFA_ProjectDeliverable> projDeliverables1 = GFA_ProjectDeliverable.find.findByProjectSubtaskId(tempSubtask.getId());
        System.assertEquals(projDeliverables[0].getProjectSubtaskId(), projDeliverables1[0].getProjectSubtaskId());

        projDeliverables1[0].setProjectSubtaskId(null);
        System.assertEquals(null, projDeliverables1[0].getProjectSubtaskId());
        System.assert(projDeliverables1[0].getProjectSubtaskName().contains('Test Library Subtask'));

        List<GFA_ProjectDeliverable> projDeliverables2 = GFA_ProjectDeliverable.find.findByProjectId(projects[0].getId());
        System.assertEquals(44, projDeliverables2.size());

    }
}