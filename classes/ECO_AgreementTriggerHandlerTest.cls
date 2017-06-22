@isTest
public class ECO_AgreementTriggerHandlerTest {

    static testMethod void testAgreementTriggerHandler() {
   		Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
        
        Agreement__c agreement = new Agreement__c(Project__c = testProject.Id, ProjectAgreementRecordCount__c = 1);
        insert agreement;
        
        agreement.ChangeManagerApprovedForSynch__c = true;
        
        try
    	{
    		update agreement;
    	}
    	catch(Exception e)
		{
			Boolean expectedExceptionThrown =  e.getMessage().contains('This agreement is associated to Project that does not have an Oracle Project Number.  Please get an Oracle Project Number before proceeding with Synch') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
		} 
    }
    
	static testMethod void testAgreementTriggerHandlerUpdateAgreementNumber() {
   		Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
        testProject.OracleProjectNumber__c =  '12345';
        update testProject;

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;

        Id msaRecordType = ECO_Utils_Meta.getRecordTypeId(Agreement__c.sObjectType, 'PrimeMSA');
        Agreement__c msaAgreement = new Agreement__c(ProjectAgreementRecordCount__c = 1, RecordTypeId = msaRecordType);
        insert msaAgreement;

        Agreement__c agreement = new Agreement__c(Project__c = testProject.Id, ProjectAgreementRecordCount__c = 1, MSAReference__c = msaAgreement.Id);
        insert agreement;
   
        agreement.ChangeManagerApprovedForSynch__c = true;
        update agreement;
        
		list<Agreement__c> agreements = [select Id, AgreementNumber__c from Agreement__c order by id desc];
		System.AssertEquals('12345-1', agreements[0].AgreementNumber__c);
    }

    static testMethod void testAgreementTriggerHandlerSegmentation() {


        Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
        testProject.OracleProjectNumber__c =  '12345';
        update testProject;

        Test.startTest();
        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;
        ECO_AgreementTriggerHandler.run = false;
        Id msaRecordType = ECO_Utils_Meta.getRecordTypeId(Agreement__c.sObjectType, 'PrimeMSA');
        Agreement__c msaAgreement = new Agreement__c(ProjectAgreementRecordCount__c = 1, RecordTypeId = msaRecordType);
        insert msaAgreement;        
        
        Id taskOrderRecordType = ECO_Utils_Meta.getRecordTypeId(Agreement__c.sObjectType, 'PrimeTaskOrder');
        Agreement__c agreement = new Agreement__c(Project__c = testProject.Id, ProjectAgreementRecordCount__c = 1, MSAReference__c = msaAgreement.Id, RecordTypeId = taskOrderRecordType);
        insert agreement;
        
        ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Project__c = testProject.Id, Agreement__c = agreement.Id);
        insert projectAgreement;
        ECO_AgreementTriggerHandler.run = true;

        msaAgreement.SegApprovalStatus__c = 'Approved';
        update msaAgreement;

        Test.stopTest();
        //agreement.ChangeManagerApprovedForSynch__c = true;
        //update agreement;
        
        //list<Agreement__c> agreements = [select Id, AgreementNumber__c from Agreement__c order by id desc];
        //System.AssertEquals('12345-1', agreements[0].AgreementNumber__c);
    }    
    
    static testMethod void testAgreementTriggerHandlerSegmentationNonMSA() {
        Account testAccount = new Account();
        testAccount.Name = 'test Account';
        insert testAccount;

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);

        pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];
        testProject.OracleProjectNumber__c =  '12345';
        update testProject;

        ECO_ProjectTriggers.run = true;
        ECO_ProjectTaskTriggers.run = true;
        ECO_AgreementTriggerHandler.run =false;
        
        Id msaRecordType = ECO_Utils_Meta.getRecordTypeId(Agreement__c.sObjectType, 'PrimeMSA');
        Agreement__c msaAgreement = new Agreement__c(ProjectAgreementRecordCount__c = 1, RecordTypeId = msaRecordType);
        insert msaAgreement;        
            
        Id taskOrderRecordType = ECO_Utils_Meta.getRecordTypeId(Agreement__c.sObjectType, 'PrimeTaskOrder');
        Agreement__c agreement = new Agreement__c(Project__c = testProject.Id, ProjectAgreementRecordCount__c = 1, MSAReference__c = msaAgreement.Id, RecordTypeId = taskOrderRecordType);
        insert agreement;
        
        ProjectAgreement__c projectAgreement = new ProjectAgreement__c(Project__c = testProject.Id, Agreement__c = agreement.Id);
        insert projectAgreement;
        ECO_AgreementTriggerHandler.run =true;


        Test.startTest();
        agreement.SegApprovalStatus__c = 'Approved';
        update agreement;
        Test.stopTest();
        //agreement.ChangeManagerApprovedForSynch__c = true;
        //update agreement;
        
        //list<Agreement__c> agreements = [select Id, AgreementNumber__c from Agreement__c order by id desc];
        //System.AssertEquals('12345-1', agreements[0].AgreementNumber__c);
    } 


}