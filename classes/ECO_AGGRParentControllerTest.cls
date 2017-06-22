@isTest
public class ECO_AGGRParentControllerTest {
	
	static testMethod void testAGGRParentController() {
		
		
	 	IncentiveProject__c prj = new IncentiveProject__c(	name = 'test',
	 														ProjectID__c = 'test');         
        insert prj;
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(prj);
        ECO_AGGRParentController testController = new ECO_AGGRParentController(sc);
        
        PageReference pageRef = Page.ECO_AGGRParent;
        pageRef.getParameters().put('id', String.valueOf(prj.Id));
        Test.setCurrentPage(pageRef);
    
        
        testController.createAGGR();
        testController.back();
        
        IncentiveProject__c prjTest = [select Id, Aggregated_Parent_Project__c, RecordTypeId from IncentiveProject__c where Id = : prj.Id];
        
        System.AssertNotEquals(prjTest.Aggregated_Parent_Project__c, null);
        
        Test.stopTest();
	}

}