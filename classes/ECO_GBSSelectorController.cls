/** ---------------------------------------------------------------------------------------
* @Description Wizard for the GBS process.  In this step the user selects some basic information
* the next page can then display fewer fields<br/>
*
* Stakeholders:
* Jessica Fan, Stephanie Sun-Clark<br/>
* @Author AECOM - Steve MunLeeuw, Duke Ames
* @Date Aug 2016
*----------------------------------------------------------------------------------------*/
public with sharing class ECO_GBSSelectorController {

    public String requestType {get; set;}
    public SharedServicesRequest__c ssr {get; set;}

    public String actionName { get {
            return [SELECT Name FROM RecordType WHERE Id = :ssr.RecordTypeId LIMIT 1].Name;
        }}

    public ECO_GBSSelectorController (ApexPages.StandardController controller)
    {
        this.requestType = ApexPages.currentPage().getParameters().get('requestType');

        ssr = (SharedServicesRequest__c)controller.getRecord();
        if(ssr == null){ ssr = new SharedServicesRequest__c();}
System.debug('DebugMe requestType: ' + requestType);
        ssr.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(SharedServicesRequest__c.sObjectType, requestType);
        ssr.Geography__c = ApexPages.currentPage().getParameters().get('geography');
        ssr.VendorType__c = ApexPages.currentPage().getParameters().get('vendorType');
        ssr.CustomerStatus__c = ApexPages.currentPage().getParameters().get('customerStatus');
        ssr.ERPSystem__c = ApexPages.currentPage().getParameters().get('erpSystem');
        ssr.Account__c = ApexPages.currentPage().getParameters().get('account');
        ssr.SiteAddressType__c = ApexPages.currentPage().getParameters().get('siteAddressType');
    }

    public PageReference back(){
        PageReference gbs = new PageReference('/apex/ECO_GlobalBusinessService');
        
        return gbs;
    }

    public PageReference next(){
        PageReference gbsEdit = new PageReference('/apex/ECO_GBSEdit');
        gbsEdit.getParameters().put('requestType', this.requestType);
        gbsEdit.getParameters().put('geography', ssr.Geography__c);
        gbsEdit.getParameters().put('vendorType', ssr.VendorType__c);
        gbsEdit.getParameters().put('customerStatus', ssr.CustomerStatus__c);
        gbsEdit.getParameters().put('erpSystem', ssr.ERPSystem__c);
        gbsEdit.getParameters().put('account', ssr.Account__c);
        gbsEdit.getParameters().put('siteAddressType', ssr.SiteAddressType__c);

        return gbsEdit;
    }
}