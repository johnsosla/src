/*******************************************************************************
*
* PURPOSE: Test class for GFA_LibrarySubtask
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
@isTest
private class GFA_LibrarySubtaskTest {

    @isTest static void testConstructor() {
        GFA_LibrarySubtask subtask = new GFA_LibrarySubtask();
    }

    @isTest static void testGetsAndSets() {
        GFA_LibrarySubtask subtask = new GFA_LibrarySubtask();
        RecordType rt = [Select Id from RecordType where DeveloperName = : GFA_LibrarySubtask.RT_PENDING AND sObjectType = : 'GFA_Library_Subtask__c'];
        subtask.setName('TEST Name');
        subtask.setProjectSponsor('Client');
        subtask.setDiscipline('Test Discipline');
        subtask.setScopeOfService('Test Scope of Service');
        subtask.setRiskLevel('Test Risk');
        subtask.setImpactLevel('Test Impact');
        subtask.setGroup('Test Group');
        subtask.setOperatingGroup('Test Operating');
        subtask.setBusinessLine('Test Business');
        subtask.setDescription('Test Description');
        subtask.setRecordTypeId(rt.Id);

        System.assertEquals('TEST Name', subtask.getName());
        System.assertEquals('Client', subtask.getProjectSponsor());
        System.assertEquals('Test Discipline', subtask.getDiscipline());
        System.assertEquals('Test Scope of Service', subtask.getScopeOfService());
        System.assertEquals('Test Risk', subtask.getRiskLevel());
        System.assertEquals('Test Impact', subtask.getImpactLevel());
        System.assertEquals('Test Group', subtask.getGroup());
        System.assertEquals('Test Operating', subtask.getOperatingGroup());
        System.assertEquals('Test Business', subtask.getBusinessLine());
        System.assertEquals('Test Description', subtask.getDescription());
        System.assertEquals(rt.Id, subtask.getRecordTypeId());
        System.assert(subtask.isNew());
    }

    @isTest static void testFindBy() {
        List<GFA_LibrarySubtask> libSubtasks = GFA_TestUtils.createTestLibrarySubtasks(10);

        for (GFA_LibrarySubtask libSubtask : libSubtasks) {
            libSubtask.setActive();
        }
        GFA_BaseModel.save(libSubtasks);

        List<GFA_LibrarySubtaskVersion> libSubtaskVersions = GFA_TestUtils.createTestLibrarySubtaskVersions(1, libSubtasks);


        GFA_LibrarySubtask libSubtask = GFA_LibrarySubtask.find.findById(libSubtasks[0].getId());
        List<GFA_LibrarySubtask> libSubtasksNotIn = GFA_LibrarySubtask.find.findByNotInIds(new Set<Id> {libSubtask.getId()});
        libSubtask.setVersions(libSubtaskVersions);

        //Status set to 'Pending' in TestUtil
        System.assertEquals(libSubtaskVersions[0].getStatus(), 'Pending');
        System.assertEquals(libSubtaskVersions.size(), libSubtask.getVersions().size());
        System.assertEquals(libSubtaskVersions[0].getId(), libSubtask.getVersions()[0].getId());
        System.assertEquals(9, libSubtasksNotIn.size());
        System.assert(libSubtaskVersions[0].isExisting());

        GFA_LibrarySubtaskVersion cloneVersion = new GFA_LibrarySubtaskVersion((GFA_Library_Subtask_Version__c)libSubtaskVersions[0].cloneModel().getObj());
        System.assertEquals(libSubtaskVersions[0].getLibrarySubtaskName(), cloneVersion.getLibrarySubtaskName());

        GFA_LibrarySubtaskCriteria criteria = new GFA_LibrarySubtaskCriteria();
        criteria.ExcludeIds = new Set<Id> {libSubtask.getId()};
        List<GFA_LibrarySubtask> libSubtaskCriteria = GFA_LibrarySubtask.find.findByCriteria(criteria);
        System.assertEquals(9, libSubtaskCriteria.size());

        GFA_LibrarySubtask.find.setFieldSet(new Set<String>());

    }
}