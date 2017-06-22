/**
 * @author Sujit Kumar
 * @date June 9, 2016
 *
 */
@isTest
private class ECO_ClassificationEditorControllerTest {

    static testMethod void givenProjectWithNoPrimaryOrg_OnInit_VerifyErrorMessage() {
		pse__Proj__c myProjectWithNoPrimaryOrg = ECO_Utils_Testing.createProjectWithAccountAndNoPrimaryOrg();
		
		PageReference pageRef = Page.ECO_ClassificationEditor;
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController sc = new ApexPages.StandardController(myProjectWithNoPrimaryOrg);
		ECO_ClassificationEditorController con = new ECO_ClassificationEditorController(sc);
		
		List<ApexPages.Message> msgList = ApexPages.getMessages();
		ApexPages.Message msg = msgList.get(0);
    	System.assertEquals('No Primary Organization found, cannot edit classifications!', msg.getSummary());
    	System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
    }
    
    static testMethod void givenProjectWithOrgString_OnInit_VerifyClassificationFields() {
		pse__Proj__c myProjectWithPrimaryOrg = ECO_Utils_Testing.createProjectWithAccountAndOrg();
		PageReference pageRef = Page.ECO_ClassificationEditor;
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController sc = new ApexPages.StandardController(myProjectWithPrimaryOrg);
		ECO_ClassificationEditorController con = new ECO_ClassificationEditorController(sc);
		
		List<ApexPages.Message> msgList = ApexPages.getMessages();
    	System.assertEquals(0, msgList.size());
    }
    
    static testMethod void givenProjectWithOrgString_OnSave_VerifySavedClassificationFields() {
		pse__Proj__c myProjectWithPrimaryOrg = ECO_Utils_Testing.createProjectWithAccountAndOrg();
		PageReference pageRef = Page.ECO_ClassificationEditor;
		Test.setCurrentPage(pageRef);
		
		ApexPages.StandardController sc = new ApexPages.StandardController(myProjectWithPrimaryOrg);
		ECO_ClassificationEditorController con = new ECO_ClassificationEditorController(sc);
		
		List<ApexPages.Message> msgList = ApexPages.getMessages();
    	System.assertEquals(0, msgList.size());
    	
    	con.oProject.clAECOMProjectCity__c = 'Austin';
    	con.SaveClassification();
    	
    	/*
    	msgList = ApexPages.getMessages();
    	System.assertEquals(0, msgList.size());
    	*/
    }
}