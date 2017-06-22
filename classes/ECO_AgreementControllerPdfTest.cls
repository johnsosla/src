/**
 * @author Sujit Kumar
 * @date June 14, 2016
 */
@isTest
private class ECO_AgreementControllerPdfTest {

    Static User testUser;
    Static Contact testContact;
    Static Id recordTypeId;
    Static List<ProjectTeamMember__c> projectMembers;
    Static List<ProjectRole__c> projectRoles;

    static testMethod void testAgreementControllerPdfForPrimeAgreement()
    {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTaskTriggers.run = true;

        pse__Proj__c project = [select Id, ProjectNumber__c from pse__Proj__c limit 1];

        Account testAccount = new Account();
        testAccount.Name = 'test account';
        insert testAccount;        

        Site__c testSite = new Site__c();
        testSite.Account__c = testAccount.Id;
        testSite.CurrencyIsoCode = 'USD';
        testSite.City__c = 'Winnipeg';      
        testSite.VendorSiteID__c = '654321';
        testSite.CustomerAccountSiteID__c = '666666';

        insert testSite;        

        Project_Site__c testProjectSite = new Project_Site__c();
        testProjectSite.BillingContactID__c = '1234';
        testProjectSite.Project__c = project.Id;
        testProjectSite.Site__c = testSite.Id;
        testProjectSite.Contribution__c = 100;
        insert testProjectSite;        

        ECO_AgreementTriggerHandler.run = false;

        Id primeRecordTypeId = [select Id from RecordType where Name = 'Prime' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
        agreement.Account__c = testAccount.Id;
        agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        agreement.TotalApprovedRevenueLimit__c = 1000;
        insert agreement;
        
        ECO_AgreementTriggerHandler.run = true;
        ECO_ProjectTriggers.run = true;

        Test.startTest();
        agreement = [select Id, Name, RecordTypeId, Account__c, Project__c, RelatedProjectCount__c, FundingCurrencyCode__c, Amount__c, TotalApprovedRevenueLimit__c from Agreement__c limit 1];

        ApexPages.StandardController sc = new ApexPages.StandardController(agreement);        
        ECO_AgreementControllerPdf ecoAgreementControllerPdf = new ECO_AgreementControllerPdf(sc);
        ecoAgreementControllerPdf.init();

        Datetime myDatetime = Datetime.now();
        String myDatetimeStr = myDatetime.format('yyyyMMdd');
        String actualPdfFileName = project.ProjectNumber__c + '_Agreement_' + agreement.Name + '_' + myDatetimeStr + '.pdf';
        
        System.assertEquals(ecoAgreementControllerPdf.pdfFileName, actualPdfFileName);
        
        Test.stopTest();
    }
}