@isTest
public class ECO_AGGRCalculationControllerTest {
	
	static testMethod void testAGGRCalculationController() {
		
		IncentiveProject__c prj1 = new IncentiveProject__c(	name = 'AGGR: test',
	 														ProjectID__c = 'AGGR: test'
	 														);         
        insert prj1;
        
	 	IncentiveProject__c prj = new IncentiveProject__c(	name = 'test',
	 														ProjectID__c = 'test',
	 														ActualContingencyBudgetITD__c = 2.00,
	 														Aggregated_Parent_Project__c = prj1.Id);         
        insert prj;

        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(prj1);
        ECO_AGGRCalculationController testController = new ECO_AGGRCalculationController(sc);
        
        PageReference pageRef = Page.ECO_AGGRCalculation;
        pageRef.getParameters().put('id', String.valueOf(prj1.Id));
        Test.setCurrentPage(pageRef);
    
        
        testController.calculateAGGR();
        testController.back();
       
        IncentiveProject__c prjTest = [select ActualContingencyBudgetITD__c from IncentiveProject__c where Id = : prj1.Id];
        
        System.AssertEquals(prjTest.ActualContingencyBudgetITD__c, 2.00);
        
        
        Test.stopTest();
	}

}