/** ---------------------------------------------------------------------------------------
* @Description When a new Customer, Vendor, or Site is required we have a formal process
* to ensure that duplicates are not created, and populate the Oracle system with the Salesforce Id's
* for integration purposes<br/>
*
* Stakeholders:
* Jessica Fan, Stephanie Sun-Clark<br/>
* @Author AECOM - Steve MunLeeuw, Duke Ames
* @Date Aug 2016
*----------------------------------------------------------------------------------------*/
public with sharing class ECO_GBSEditController {
    ECO_GBSCore core;
    private ApexPages.StandardController controller;

    public String requestType {get; set;}
    public SharedServicesRequest__c ssr {get; set;}
    public Boolean IsNewRequest {get; set;}

    // if status = processing only status and owner fields can be edited
    public Boolean ShowEditFieldsProcessingOnly {get { return core.isEditProcessingOnly; }}

    public Boolean UserIsGBSAdmin {get { return core.isUserGBSAdmin; }}
    public Boolean ERPSystemIsOracle {get; set;}

    public Show show {get; set;}
    public Required required { get; set;}
    public String actionName { get {
            return [SELECT Name FROM RecordType WHERE Id = :ssr.RecordTypeId LIMIT 1].Name;
        }}
    public String OwnerName { get { 
            return ssr.Id == null ? UserInfo.getName() : [SELECT Owner.Name FROM SharedServicesRequest__c WHERE Id = :ssr.Id LIMIT 1].Owner.Name; 
        }}


    public ECO_GBSEditController (ApexPages.StandardController controller)
    {
        this.controller = controller;
        ssr = (SharedServicesRequest__c)controller.getRecord();
        core = new ECO_GBSCore(ssr);

        //default values
        If (ssr.Requestor__c == null){ ssr.Requestor__c = UserInfo.getUserId(); }  //init the Requestor
        If (ssr.OwnerId == null){ ssr.OwnerId = UserInfo.getUserId(); }  //init the Owner

        requestType = ApexPages.currentPage().getParameters().get('requestType');
        //Wizard will pass in the requestType, record edit will not have that context
        if(requestType == null){
            IsNewRequest = false;
            requestType = core.requestType;
        }
        else{
            IsNewRequest = true;
            ssr.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(SharedServicesRequest__c.sObjectType, requestType);
            ssr.Geography__c = ApexPages.currentPage().getParameters().get('geography');
            ssr.VendorType__c = ApexPages.currentPage().getParameters().get('vendorType');
            ssr.CustomerStatus__c = ApexPages.currentPage().getParameters().get('customerStatus');
            ssr.ERPSystem__c = ApexPages.currentPage().getParameters().get('erpSystem');
            ssr.Account__c = ApexPages.currentPage().getParameters().get('account');
            ssr.SiteAddressType__c = ApexPages.currentPage().getParameters().get('siteAddressType');
        }

        if (ssr.ERPSystem__c == 'Oracle' || ssr.ERPSystem__c == 'EIC Oracle')
            ERPSystemIsOracle = true;

        initShow();
    }

    public PageReference save(){

        //validation
        if(ssr.RemitIsPrimaryAddress__c){
            if(ssr.RemitToAddressLine1__c == null ||
                ssr.RemitToCity__c == null ||
                ssr.RemitToStateProvinceEmirate__c == null ||
                ssr.RemitToCountry__c == null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Remit address fields are required when selected as the primary address.'));
                    return null;
                }
        }
        if(ssr.BillingAddress1isPrimary__c){
            if(ssr.BillingStreetPOBox__c == null ||
                ssr.BillingAddressCity__c == null ||
                ssr.BillingStateProvinceEmirate__c == null ||
                ssr.BillingAddressCountry__c == null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Billing address fields are required when selected as the primary address.'));
                    return null;
                }
        }

        if(ssr.Id == null){
            insert ssr;
        }
        else{
            update ssr;
        }
        PageReference details = new PageReference('/apex/ECO_GBSDetails?id=' + ssr.Id);
        details.setRedirect(true);

        return details;
    }

    private void initShow(){
        show = new Show();
        required = new Required();

        if(requestType == 'CreateCustomer'){
            show.Agis = false;
            show.BankInfo = false;
            show.BizReg = false;
            show.CompanyReg = false;
            show.CustomerName = true;
            show.CustomerNameLocalized = true;
            show.CustomerStatus = true;
            show.IdCopy = false;
            show.Intercompany = true;
            show.PaymentTerms = true;
            show.ParentAccount = true;
            show.PrimaryAddress = true;
            show.ProfileClass = true;
            show.ReferenceSite = false;
            show.SiteAddressType = false;
            show.Subs = false;
            show.TaxReg = false;
            show.Vat = false;
            show.W9 = false;

            show.AddressSection = true;
            show.AdditionalContactSection = true;
            show.BillingAddressSection = true;
            show.BillingContactSection = true;
            show.CustomerSection = true;
            show.GbsChecklistSection = UserIsGBSAdmin;
            show.TaxSection = true;

            if(ssr.Geography__c == 'Americas'){
                show.FiscalId = true;
                show.SicCode = false;
                show.SicDescription = false;
                show.USFedGov = true;
            }
            if(ssr.Geography__c == 'EMEA&I'){
                show.FiscalId = true;
                show.SicCode = false;
                show.SicDescription = false;
            }
            if(ssr.Geography__c == 'APAC'){
                show.FiscalId = false;
                show.SicCode = true;
                show.SicDescription = true;
            }

            //required
            required.BillingContact = true;
            required.ParentAccount = false;
            required.PaymentTerms = true;
        }

        if(requestType == 'CreateVendor'){
            //show.Account = true;
            show.BusinessRegistrationCertificateAsia = true;
            show.CompanyRegistrationNo = true;
            show.CustomerName = true;
            show.CustomerNameLocalized = true;
            show.OrganizationType = true;
            show.PrimaryAddress = true;
            show.ReferenceSite = true;
            show.SicCode = true;
            show.SicDescription = true;
            show.VendorType = true;

            show.AdditionalContactSection = true;
            show.AddressSection = true;
            show.AdvantageSection = true;
            show.BankingInformationSection = true;
            show.GbsChecklistSection = UserIsGBSAdmin;
            show.FiscalId = true;
            show.PaymentDetailsSection = true;
            show.PaymentDetailsGBSSection = UserIsGBSAdmin;
            show.PrimaryContactSection = true;
            show.RemitSection = true;
            show.TaxSection = true;
            if(ssr.Geography__c == 'Americas'){
                show.SocioSection = true;
                show.Tin = true;
                show.W9 = true;
                show.CompanyReg = false;
                show.Subs = false;
                show.Vat = false;
                show.BizReg = false;
                show.IdCopy = false;
                show.DesktopCheck = false;
            }
            if(ssr.Geography__c == 'EMEA&I'){
                show.EqualOppSection = true;
                show.CompanyReg = true;
                show.Subs = false;
                show.BizReg = false;
                show.IdCopy = false;
            }
            if(ssr.Geography__c == 'APAC'){
                show.Aboriginal = true;
                show.SicCode = true;
                show.SicDescription = true;
                show.CompanyReg = false;
                show.Subs = true;
                show.BizReg = true;
            }
            if(ssr.VendorType__c == 'Contractor' || ssr.VendorType__c == 'Subconsultant' || ssr.VendorType__c == 'Subcontractor' || ssr.VendorType__c == 'Time Sheet Contactor' || ssr.VendorType__c == 'Time Sheet Contractor (PAYE)') {
                show.AdditionalSubSection = true;
            }
        }

        if(requestType == 'AddSite'){
            show.Account = true;
            show.AdditionalContactSection = true;
            show.AdditionalInfoSection = true;
            show.SiteAddressType = true;

            if(ssr.SiteAddressType__c == 'Vendor Account Site'){
                show.AddressSection = true;
                show.AdvantageSection = true;
                show.BankingInformationSection = true;
                show.PrimaryContactSection = true;
                show.PaymentDetailsSection = true;
                show.PrimaryAddress = true;
                show.RemitSection = true;
            }
            else{                       //Customer Account Site
                show.AddressSection = true;
                show.BillingContactSection = true;
            }
            //required
            required.Account = true;
            required.BillingContact = true;
        }

        if(requestType == 'UpdateSite'){
            show.Account = true;
            show.AdditionalContactSection = true;
            show.AdditionalInfoSection = true;
            show.SiteAddressType = true;

            required.Account = true;

            if(ssr.SiteAddressType__c == 'Vendor Account Site'){
                show.TobeUpdatedSection = true;
                show.AddressSection = true;
                show.PrimaryContactSection = true;
                show.BillingContactSection = true;
                show.AdvantageSection = true;
            }
            else{                       //Customer Account Site
                show.AddressSection = true;
                show.BillingContactSection = true;
                show.TobeUpdatedSection = true;

                required.AddressRequired = false;
            }
        }

        if(requestType == 'GeneralRequest'){
            show.Account = true;
            show.BillingContact = true;
            show.Contact = true;
            show.ContactName = true;
            show.Site = true;

            show.RequestNotesSection = true;
            show.RequestorDetailsSection = true;
        }
    }

    public PageReference back(){
        PageReference gbsSelector = new PageReference('/apex/ECO_GBSSelector');
        gbsSelector.getParameters().put('requestType', this.requestType);
        gbsSelector.getParameters().put('geography', ssr.Geography__c);
        gbsSelector.getParameters().put('vendorType', ssr.VendorType__c);
        gbsSelector.getParameters().put('erpSystem', ssr.ERPSystem__c);
        gbsSelector.getParameters().put('customerStatus', ssr.CustomerStatus__c);
        gbsSelector.getParameters().put('siteAddressType', ssr.SiteAddressType__c);
        gbsSelector.getParameters().put('account', ssr.Account__c);
        
        return gbsSelector;
    }
    
    public PageReference cancel(){

        PageReference prCancel;

        if (IsNewRequest)
            prCancel = new PageReference('/apex/ECO_GlobalBusinessService');
        else
            prCancel = new PageReference('/' + ssr.ID);
        
        return prCancel;
    }

    /** ---------------------------------------------------------------------------------------
    * @Description Nested class used to store what fields and sections should be displayed
    *
    *----------------------------------------------------------------------------------------*/
    public class Show{
        public Show(){
            Agis = true;
            BankInfo = true;
            BizReg = true;
            CompanyReg = true;
            DesktopCheck = true;
            IdCopy = true;
            Subs = true;
            TaxReg = true;
            Vat = true;
        }

        public Boolean Aboriginal { get; set;}
        public Boolean Account { get; set;}
        public Boolean Agis { get; set;}
        public Boolean BankInfo { get; set;}
        public Boolean BillingContact { get; set;}
        public Boolean BizReg { get; set;}
        public Boolean BusinessRegistrationCertificateAsia { get; set;}
        public Boolean CompanyReg { get; set;}
        public Boolean CompanyRegistrationNo { get; set;}
        public Boolean Contact { get; set;}
        public Boolean ContactName { get; set;}
        public Boolean CustomerName { get; set;}
        public Boolean CustomerNameLocalized { get; set;}
        public Boolean CustomerStatus { get; set;}
        public Boolean DesktopCheck { get; set;}
        public Boolean FiscalId { get; set;}
        public Boolean IdCopy { get; set;}
        public Boolean Intercompany { get; set;}
        public Boolean OrganizationType { get; set;}
        public Boolean PaymentTerms { get; set;}
        public Boolean ParentAccount { get; set;}
        public Boolean PrimaryAddress { get; set;}
        public Boolean ProfileClass { get; set;}
        public Boolean ReferenceSite { get; set;}
        public Boolean SicCode { get; set;}
        public Boolean SicDescription { get; set;}
        public Boolean Site { get; set;}
        public Boolean SiteAddressType { get; set;}
        public Boolean Subs { get; set;}
        public Boolean TaxReg { get; set;}
        public Boolean USFedGov { get; set;}
        public Boolean Tin { get; set;}
        public Boolean Vat { get; set;}
        public Boolean VendorType { get; set;}
        public Boolean W9 { get; set;}
 

        public Boolean AdditionalInfoSection { get; set;}
        public Boolean AdditionalContactSection { get; set;}
        public Boolean AdditionalSubSection { get; set;}
        public Boolean AddressSection { get; set;}
        public Boolean AdvantageSection { get; set;}
        public Boolean BankingInformationSection { get; set;}
        public Boolean BillingAddressSection { get; set;}
        public Boolean BillingContactSection { get; set;}
        public Boolean CustomerSection { get; set;}
        public Boolean EqualOppSection {get; set;}
        public Boolean GbsChecklistSection { get; set;}
        public Boolean PaymentDetailsSection { get; set;}
        public Boolean PaymentDetailsGBSSection { get; set;}
        public Boolean PrimaryContactSection { get; set;}
        public Boolean RemitSection { get; set;}
        public Boolean RequestorDetailsSection { get; set;}
        public Boolean RequestNotesSection { get; set;}
        public Boolean SocioSection { get; set;}
        public Boolean TaxSection { get; set;}
        public Boolean TobeUpdatedSection { get; set;}
    }

    /** ---------------------------------------------------------------------------------------
    * @Description Nested class used to store what fields are required
    *
    *----------------------------------------------------------------------------------------*/
    public class Required{

        public Required(){
            AddressRequired = true;
        }
        public Boolean Account { get; set;}
        public Boolean AddressRequired { get; set;}
        public Boolean BillingContact { get; set;}
        public Boolean ParentAccount { get; set;}
        public Boolean PaymentTerms { get; set;}
    }
}