public class Service_Catalog_MyTestButtonController {
    private ApexPages.StandardController standardController;
    
    public static string catalogId = '';
    
    public static string catalogLink = '';
 
    public Service_Catalog_MyTestButtonController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        
        Id recordId = standardController.getId();
        catalogId = recordId;
        
    }
 
    public PageReference doSomething()
    {
        // Apex code for handling record from a Detail page goes here
        Id recordId = standardController.getId();
        catalogId = recordId;
        Service_Catalog_Entry__c record = (Service_Catalog_Entry__c) standardController.getRecord();
        return null;
    }
    
    public static string getcatalogId()
    {
        return catalogId;
    }    
}