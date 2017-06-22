public class Service_Catalog_categorySEsController 
{
    public static string catParam = System.currentPagereference().getParameters().get('catParam');
    
    public static integer countOfRecs = 0;   
    
    public static string getcatParam()
    {
        return catParam;
    }
    
    public static integer getcountOfRecs()
    {
        return countOfRecs;
    }
    
    public static List<Service_Catalog_Entry__c> getCatSEs() 
    {
        string countQuery = '',
               resultsQuery = '';
        
        countOfRecs = [Select count() From Service_Catalog_Entry__c WHERE Category__c INCLUDES (:catParam) and Status__c='Published'];
        
        List<Service_Catalog_Entry__c> results = [Select Id, Name, Category__c, SME__c, Capability_Description__c, 
                                                  Capability_Indicator__c, Capacity_Indicator__c, Standards_Indicator__c, 
                                                  Status__c, Rating__c, Customer_Rating_Count__c 
                                                  //Rating_Count__c 
                                                  From Service_Catalog_Entry__c WHERE Category__c INCLUDES (:catParam) and Status__c='Published'];
        
        
        if (catParam == '')
        {
            countOfRecs = [Select count() From Service_Catalog_Entry__c Where Status__c='Published'];
            
            results = [Select Id, Name, Category__c, SME__c, Capability_Description__c, 
                       Capability_Indicator__c, Capacity_Indicator__c, Standards_Indicator__c, 
                       Status__c, Rating__c, Customer_Rating_Count__c 
                       //Rating_Count__c 
                       From Service_Catalog_Entry__c 
                       Where Status__c='Published'];
            
            catParam = 'All Service Catalog Entries';
        }
        
        results.sort();
        
        return results;
    }  
}