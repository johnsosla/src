@isTest
public class GFA_TemplateCloneControllerTest {
	@isTest
    public static void GFA_TemplateCloneControllerTest() {
		 GFA_Template template = GFA_TestUtils.createTestTemplate(1)[0];

        ApexPages.StandardController sc = new ApexPages.StandardController(template.getObj());
        GFA_TemplateCloneController cont = new GFA_TemplateCloneController(sc);

        PageReference save = cont.saveTemplate();

        List<GFA_Template__c> templateCloned = [Select Id, Name From  GFA_Template__c];
        List<GFA_Template_Phase__c> phaseCloned = [Select Id, Name From  GFA_Template_Phase__c];
        List<GFA_Template_Task__c> taskCloned = [Select Id, Name From  GFA_Template_Task__c];
        List<GFA_Template_Subtask__c> subtaskCloned = [Select Id, Name From  GFA_Template_Subtask__c];

        System.assertEquals(2, templateCloned.size());

        System.assertEquals(2, phaseCloned.size());

        System.assertEquals(2, taskCloned.size());

        System.assertEquals(2, subtaskCloned.size());

        PageReference cancel = cont.cancel();

	}
}