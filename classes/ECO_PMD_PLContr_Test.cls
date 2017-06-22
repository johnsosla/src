@isTest
private class ECO_PMD_PLContr_Test {
	
	@testSetup static void setup(){ 		
        //ECO_ProjectTriggers.run = false;	
        ECO_PMD_Utils_Testing.setupTestData(); 
 
 		List<pse__Proj__c> projects = [
			SELECT Id, Name,
				CurrencyIsoCode,RecordTypeId,pse__Account__c,
	            pse__End_Date__c,pse__Project_Status__c,pse__Stage__c,pse__Start_Date__c,
	            OracleProjectnumber__c,EstimatedEndDate__c,EstimatedStartDate__c,
	            ProjectFunctionalCurrencyCode__c,RevisedStartDate__c,RevisedEndDate__c,
	            pse__Account__r.Name,pse__Project_Manager__c,ProjectReviewCategory__c 
            FROM pse__Proj__c
        ];
        ECO_Service_ProjectSnapshots ps = new ECO_Service_ProjectSnapshots();
        ps.computeSnapshots(Date.newInstance(2015,12,15), projects, ECO_Service_ProjectSnapshots.SnapshotKeyRule.MONTH_END);
        upsert ps.projectSnapshots.values() Snapshot_Project_Key__c;
 
    }
	
    static testMethod void test_Component(){
		Test.startTest(); 

        pse__Proj__c testProj = [select id, Name, OracleProjectNumber__c from pse__Proj__c LIMIT 1];  

        ECO_PMD_PL_Controller cont = new ECO_PMD_PL_Controller();
        
        Test.stopTest(); 

	}

	static testMethod void test_ProjectSnapshot_MashUp(){
    	Test.startTest();  
        
        //Use a project that has an auto-generated project snapshot
        ProjectSnapshot__c testProj = [select Project__c from ProjectSnapshot__c
                WHERE SnapshotDate__c != null  
                AND SnapshotType__c='Auto'
                LIMIT 1];  
        //testProj.SnapshotType__c='Auto';
        //update testProj;
       
        ECO_PMD_PL_Controller cont = new ECO_PMD_PL_Controller();

		ECO_PMD_PL_Controller.ProjectSnapshot_MashUp testProjectSnapshot_MashUp = ECO_PMD_PL_Controller.ProjectSnapshot(String.valueOf(testProj.Project__c));            

		Test.stopTest();			

    }		


    
}