@isTest(SeeAllData=false)

private class ECO_PMD_ProjectDetails_Controller_Test {

        @testSetup static void setup(){ 
            ECO_ProjectTriggers.run = false;
            
            User testUser = ECO_Utils_Testing.createTestUser('System Administrator');
            insert testUser;

            pse__Proj__c testProj = ECO_Utils_Testing.createTestProject('Test-PMD');
            insert testProj;

        }

        static testMethod void initNullConstructor(){

            Test.startTest();
            pse__Proj__c testProj = [select id from pse__Proj__c where name = 'Test-PMD'];
            ECO_PMD_ProjectDetails_Controller cont = new ECO_PMD_ProjectDetails_Controller();
            cont.currentProjectId = testProj.Id;     
			//cont.initializeProject(cont.currentProjectId);
            
            Test.stopTest();

            System.assertEquals(cont.currentProjectId, testProj.Id);            
            System.assertEquals(cont.initialized, null);
            
            PageReference pageRef = Page.ECO_PMD_ProjectDashboard;
            pageRef.getParameters().put('id', testProj.Id);
            Test.setCurrentPage(pageRef);
        }

        static testMethod void initWithStdController(){
            Test.startTest();  
            pse__Proj__c testProj = [select id from pse__Proj__c where name = 'Test-PMD'];
            ApexPages.StandardController std = new ApexPages.StandardController(testProj);
            ECO_PMD_ProjectDetails_Controller cont = new ECO_PMD_ProjectDetails_Controller(std);
            Test.stopTest();

            System.assertEquals(cont.project.Id, testProj.Id);            
            
        }

}