/*******************************************************************************
*
* PURPOSE: Test class for GFA_LibraryPhase
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
@isTest
private class GFA_LibraryPhaseTest {

    @isTest static void testConstructor() {
        GFA_LibraryPhase phase = new GFA_LibraryPhase();
    }

    @isTest static void testGetsAndSets() {
        GFA_LibraryPhase phase = GFA_TestUtils.createTestLibraryPhases(2)[0];

        phase.setName('TEST PHASE');
        phase.setDescription('TEST PHASE');
        phase.setProjectSponsor('TEST SPONSOR');

        System.assertEquals('TEST PHASE', phase.getName());
        System.assertEquals('TEST PHASE', phase.getDescription());
        System.assertEquals('TEST SPONSOR', phase.getProjectSponsor());

        GFA_LibraryPhase phase2 = GFA_LibraryPhase.find.findById(phase.getId());

        System.assertEquals(phase.getId(), phase2.getId());

        List<GFA_LibraryPhase> phaseNotIn = GFA_LibraryPhase.find.findByNotInIds(new Set<Id> {phase.getId()});

        System.assertEquals(1, phaseNotIn.size());
        System.assertNotEquals(phase.getId(), phaseNotIn[0].getId());
    }


}