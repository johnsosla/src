@isTest
private class ECO_PMD_Risk_Register_Contr_Test {
	
	@testSetup static void setup(){ 
        ECO_ProjectTriggers.run = false;
        
        User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
        insert testUser;

        pse__Proj__c testProj = ECO_Utils_Testing.createTestProject('Test-PMD');
        insert testProj;

    }
    
    static testMethod void initNullConstructor(){
		Test.startTest(); 

        pse__Proj__c testProj = [select id from pse__Proj__c LIMIT 1];  
        
		//ApexPages.StandardController sc = new ApexPages.StandardController(testProj);
		//ECO_PMD_Risk_Register_Controller ctr = new ECO_PMD_Risk_Register_Controller (sc);
        
        ECO_PMD_Risk_Register_Controller.RiskRegister riskreg = new ECO_PMD_Risk_Register_Controller.RiskRegister();
        riskreg = ECO_PMD_Risk_Register_Controller.ProjectRiskRegister(testProj.Id);

        PageReference pageRef = Page.eco_pmd_projectdashboard;
        pageRef.getParameters().put('id', String.valueOf(testProj.Id));
        Test.setCurrentPage(pageRef);

        Test.stopTest(); 

        System.assertNotEquals(riskreg, null);

	}	
	
}