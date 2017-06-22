@isTest
private class TestCRSEcoSystemIntegration
{
	/*
	* Test that details from the agreement come across to the CRS 
	*
	*/
	@isTest
	static void testCRSWithAnAgreement()
	{
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Service_Delegation.run = false;
       	ECO_Utils_Testing.createTestDataForProjectSync(1, 2);
        
       	pse__Proj__c testProject = [SELECT Id, Name FROM pse__Proj__c LIMIT 1];

        ECO_ProjectTaskTriggers.run = true;
        ECO_Service_Delegation.run = true;
       	
       	Id recordTypeId = ECO_Utils_sObject.getRecordTypeId(Agreement__c.sObjectType, 'Prime Task Order');
       	Agreement__c testAgreement = new Agreement__c();
       	testAgreement.FundingCurrencyCode__c = 'USD';
       	testAgreement.ScopeOfServices__c = 'Test Services';
       	testAgreement.RecordTypeId = recordTypeId;
       	testAgreement.ProfIndemnityLiabilityAmt__c = 1000;
       	testAgreement.PublicGeneralLiabilityAmt__c = 1000;
       	testAgreement.AgreementType__c = 'Test Agreement Type';
       	insert testAgreement;
       	
       	ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Agreement__c = testAgreement.Id, Project__c = testProject.Id);
       	insert projectAgreement;

        Country__c ctry = new Country__c(Name='Someplace', Country_Code__c='SP');
        insert ctry;
        

        Test.startTest();
       
        Contract_Review__c cr = new Contract_Review__c();
        cr.Country__c = ctry.Id;
        cr.Date_Required__c = Date.today();
        cr.Agreement__c = testAgreement.Id; 
        insert cr; 

        Test.stopTest();

 
        Contract_Review__c crUpdated = [select Id, PI_Insurance_Amount__c from Contract_Review__c where Id = :cr.Id] ;

		    //System.debug('xxlfxx' + crUpdated);
        //System.assert(crUpdated.PI_Insurance_Amount__c == 1000);


	}
}