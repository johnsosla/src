@isTest
public class ECO_MSAFlyoutControllerTest {

    static testMethod void testAgreementControllerForPrimeAgreement()
    {
        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTaskTriggers.run = true;
        ECO_ProjectTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];

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
        testProjectSite.Is_Billing__c = true;
        insert testProjectSite;        

        Id primeRecordTypeId = [select Id from RecordType where Name = 'Prime Task Order' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = primeRecordTypeId);
        agreement.Account__c = testAccount.Id;
        agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        agreement.TotalApprovedRevenueLimit__c = 1000;
        insert agreement;

        Test.startTest();
       
        ECO_MSAFlyoutController flyoutController = new ECO_MSAFlyoutController();

        Test.stopTest();
    } 
    
    static testMethod void testAgreementMSAProgramPlanAttachments()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        //agreement.ProgramPlanAttachment__c = 'tttttt';
        insert agreement;

        Test.startTest();
  
        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;

        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);

        Attachment recommend = controller.programPlanAttach;
        recommend.Name = 'test1';
        recommend.Body = myBlob;
        recommend.ContentType = 'test1';
        controller.overrideProgramPlanAttachmentName = 'Test2';
        controller.saveProgramPlanAttachment();
        controller.getAttachedProgramPlanFiles();
        Test.stopTest();
    }
    
	static testMethod void testAgreementMSAContractAttachments()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        //agreement.ContractAttachment__c = '111111';
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;

        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        
        Attachment recommend = controller.contractAttach;
        recommend.Name = 'test1';
        recommend.Body = myBlob;
        recommend.ContentType = 'test1';
        controller.overrideContractAttachmentName = 'TTT';
        controller.saveContractAttachment();
        controller.getAttachedContractFiles();
    }    
    
    static testMethod void testAgreementMSABusinessDevelopmentAttachments()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        //agreement.BusinessDevelopmentAttachment__c = '222222';
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;

        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        
        Attachment recommend = controller.businessDevelopmentAttach;
        recommend.Name = 'test1';
        recommend.Body = myBlob;
        recommend.ContentType = 'test1';
        controller.overrideBusinessDevelopmentAttachmentName = 'Test2';
        controller.saveBusinessDevelopmentAttachment();
        controller.getAttachedBusinessDevelopmentFiles();
    } 


    static testMethod void testAgreementMSAMeetingMinutesAttachments()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        //agreement.MeetingMinutesAttachment__c = 'ttttttt';
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;

        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        
        Attachment recommend = controller.meetingMinutesAttach;
        recommend.Name = 'test1';
        recommend.Body = myBlob;
        recommend.ContentType = 'test1';
        controller.overrideMeetingMinutesAttachmentName = 'Test2';
        controller.saveMeetingMinutesAttachment();
        controller.getAttachedMeetingMinutesFiles();
    }


    static testMethod void testAgreementMSAGuidanceAttachments()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        //agreement.GuidanceAttachment__c = '123456789';
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;

        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        
        Attachment recommend = controller.guidanceAttach;
        recommend.Name = 'test1';
        recommend.Body = myBlob;
        recommend.ContentType = 'test1';
        controller.overrideGuidanceAttachmentName = 'Test2';
        controller.saveGuidanceAttachment();
        controller.getAttachedGuidanceFiles();
    }

    static testMethod void testAgreementMSACreateNewMSATeamingPartner()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;
        controller.createNewMSATeamingPartner();
    }

    static testMethod void testAgreementMSACreateNewOtherDirectCosts()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;
        controller.createNewOtherDirectCosts();
    }

    static testMethod void testAgreementMSAEditBillingRates()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;
        controller.editBillingRates();
    }


    static testMethod void testAgreementMSAManageFunding()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;
        controller.manageFunding();
    }

    static testMethod void testAgreementMSACreateNewApprovedSub()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;
        controller.createNewApprovedSub();
    }

    static testMethod void testAgreementMSACreateNewNote()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;
        controller.createNewNote();
    }

    static testMethod void testAgreementMSAEditAgreement()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;
        controller.editAgreement();
    }

    static testMethod void testAgreementMSAGetData()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;
        controller.getData();
        ECO_MSAFlyoutController.getRemoteData();
    }

    static testMethod void testAgreementMSASave()
    {
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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime (MSA)' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;
        controller.mode = 'New';
        controller.getPageBlockMode();
        //controller.save();
        controller.mode = '';
        controller.getPageBlockMode();
        controller.save();

    }    

    static testMethod void testAgreementGetMSAAgreement()
    {

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTaskTriggers.run = true;
        ECO_ProjectTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];

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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime Task Order' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;
        controller.project = project;
        controller.agreementId = agreement.Id;
        controller.getMSAAgreement();

    } 

    static testMethod void testAgreementSetLists()
    {

        ECO_ProjectTriggers.run = false;
        ECO_ProjectTaskTriggers.run = false;
        ECO_Utils_Testing.createTestDataForProjectSync(3, 3);
        ECO_ProjectTaskTriggers.run = true;
        ECO_ProjectTriggers.run = true;

        pse__Proj__c project = [select Id from pse__Proj__c limit 1];

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
       
        Id msaRecordTypeId = [select Id from RecordType where Name = 'Prime Task Order' limit 1].Id;
        Agreement__c agreement = new Agreement__c(RecordTypeId = msaRecordTypeId);
        agreement.Account__c = testAccount.Id;
        //agreement.Project__c = project.Id;
        agreement.FundingCurrencyCode__c = 'USD';
        agreement.Amount__c = 1000;
        insert agreement;

        ECO_MSAFlyoutController controller = new ECO_MSAFlyoutController();
        controller.agreement = agreement;
        controller.project = project;
        controller.agreementId = agreement.Id;
        
        controller.otherDirectCosts = new List<OtherDirectCost__c>();
        controller.managementTeamMembers = new list<ManagementTeam__c>();
        controller.approvedSubs = new list<Approved_Sub__c>();
        controller.msaTeamingPartners = new list<MSATeamingPartner__c>();
        controller.relatedAgreements = new list<Agreement__c>(); 
        controller.billingRates = new list<BillRate__c>();  
        controller.notes = new list<Note>();
        controller.fundings = new list<Funding__c>();
        controller.agreementRecordType = null;
    }
}