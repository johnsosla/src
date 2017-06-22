/*******************************************************************************
*
* PURPOSE: Test class for GFA_Template
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
@isTest
private class GFA_TemplateTest {

    @isTest static void testConstructor() {
        GFA_Template temp = new GFA_Template();
    }

    @isTest static void testGetsAndSets() {
        List<GFA_Project> projects = GFA_TestUtils.createTestProjects(1);
        List<GFA_Template> templates = GFA_TestUtils.createTestTemplate(1);
        GFA_Template template = GFA_Template.find.findById(templates[0].getId());
        List<GFA_TemplatePhase> templatePhases = GFA_TemplatePhase.find.findByTemplateId(template.getId());

        template.setTemplatePhases(templatePhases);
        template.setGroup('Test Group');
        template.setOperatingGroup('Test Operating');
        template.setBusinessLine('Test Business');
        template.setProjectSponsor('Test ProjectSponsor');

        template.setStatusPending();
        System.assertEquals(GFA_Template.STATUS_PENDING, template.getStatus());
        template.setStatusPublished();
        System.assertEquals(GFA_Template.STATUS_PUBLISHED, template.getStatus());
        template.setStatusWithdrawn();
        System.assertEquals(GFA_Template.STATUS_WITHDRAWN, template.getStatus());

        System.assertEquals(templatePhases.size(), template.getTemplatePhases().size());
        System.assertEquals(templatePhases[0].getId(), template.getTemplatePhases()[0].getId());

        template.setTemplateName('templateName');
        System.assertEquals('templateName', template.getTemplateName());

        System.assertEquals('Test Group', template.getGroup());
        System.assertEquals('Test Operating', template.getOperatingGroup());
        System.assertEquals('Test Business', template.getBusinessLine());
        System.assertEquals('Test ProjectSponsor', template.getProjectSponsor());

        projects[0].setGroup('Test Group');
        projects[0].setOperatingGroup('Test Operating');
        projects[0].setBusinessLine('Test Business');
        projects[0].setProjectSponsor('Test ProjectSponsor');
        template.setStatusPublished();
        System.assertEquals(GFA_Template.STATUS_PUBLISHED, template.getStatus());
        System.assertEquals(Date.today(), template.getDatePublished());

        List<GFA_Template> templateList = GFA_Template.find.findByMatchingProject(projects[0]);

        System.assertEquals(0, templateList.size());

    }

}