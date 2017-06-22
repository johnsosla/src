public class Service_Catalog_categorycontroller {
  
  public static string catalogEntryUrlConst = '';
  public static string linkMyCatEntriesURL{get;set;}
    
  public static string getcatalogEntryUrlConst()
  {
        List<Service_Catalog_Settings__c> mcs = Service_Catalog_Settings__c.getall().values();
		catalogEntryUrlConst = mcs[0].catalogEntryUrlConst__c;
        linkMyCatEntriesURL = mcs[0].linkMyCatEntriesURL__c;      
      
      	return catalogEntryUrlConst;
  }  
    
  public static List<string> getCategories() 
    {
            //Account.Type.getDescribe().getPicklistValues(); 
            //SomeObject.SomePicklistField.getDescribe().getPickListValues();                 
          //Schema.PicklistEntry[] PLCategory = Service_Catalog_Entry__c.Category__c.getDescribe().getPickListValues();
          //PLCategory.sort();
                  
          List<Schema.PicklistEntry> PLCategory = Service_Catalog_Entry__c.Category__c.getDescribe().getPickListValues();
        
          List<string> results = new List<string>();
        
        for (Schema.PicklistEntry a : PLCategory)
        { 
          results.add(a.getLabel()); 
        }
        
          results.sort();
          
            return results;
    }


    
    /*
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Subject, StartDateTime, EndDateTime FROM Event]));
            }
            return setCon;
        }
        set;
    }

    // Initialize setCon and return a list of records
    public List<Event> getEvents() {
        return (List<Event>) setCon.getRecords();
    }
  */
}