/** ---------------------------------------------------------------------------------------
* @Description When a new Customer, Vendor, or Site is required we have a formal process
* to ensure that duplicates are not created, and populate the Oracle system with the Salesforce Id's
* for integration purposes<br/>
* More information may be found on Box: https://aecom.box.com/s/kmszcj7qvvphezt7k1jbnsdid3xsal1b<br/>
* 
* Stakeholders:
* Jessica Fan, Stephanie Sun-Clark<br/>
* @Author AECOM - Steve MunLeeuw, Duke Ames
* @Date Aug 2016 - not sure of the original author, or when it was created
*----------------------------------------------------------------------------------------*/
public with sharing class ECO_GlobalBusinessService {

    public SharedServicesRequest__c SSR {get; set;}
    public String requestType {get; set;}
    
    public ECO_GlobalBusinessService(ApexPages.StandardController controller)
    {
        SSR = (SharedServicesRequest__c)controller.getRecord();
    }
    
    public list<RecordType> getGBSRecordTypes()
    {
        return [select Id, toLabel(Name), DeveloperName, Description from RecordType where sObjectType = 'SharedServicesRequest__c'];
    }

    public PageReference goGBSSelector(){
        PageReference gbsSelector = new PageReference('/apex/ECO_GBSSelector');
        gbsSelector.getParameters().put('requestType', this.requestType);

        return gbsSelector;
    }

    
}