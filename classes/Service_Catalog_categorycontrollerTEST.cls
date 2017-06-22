@isTest
private class Service_Catalog_categorycontrollerTEST
{    
         static testmethod void testCategories()
         {
         	    Id ChatterId; 
   				CollaborationGroup grp= new CollaborationGroup();
   				grp.Name = 'TestGroupForServiceCat';                    
  				grp.CollaborationType='Public';
   				insert grp;
				ChatterId= grp.Id;


         	    String orgURL = URL.getSalesforceBaseUrl().toExternalForm() +'/';
         	    List<Service_Catalog_Settings__c> lstCustomSettings = new List<Service_Catalog_Settings__c>();
  			    Service_Catalog_Settings__c customSetting = new Service_Catalog_Settings__c(Name='Service Catalog Settings',catalogEntryUrlConst__c=String.valueOf(orgURL));//Name='ChatterId', 
    			//System.debug('#### '+customSetting);
  				customSetting.Name = 'ChatterId';
    			customSetting.ChatterId__c=  String.valueOf(ChatterId);
    			lstCustomSettings.add(customSetting);
  				insert lstCustomSettings;
  				System.debug('#### '+Service_Catalog_Settings__c.getAll() );

  				List<Service_Catalog_Entry__c> ListSce =  new List<Service_Catalog_Entry__c>();
  				Service_Catalog_Entry__c sc =  new Service_Catalog_Entry__c();
  				sc.Category__c = 'Certifications';
  				ListSce.add(sc);
  				insert ListSce;

  				Test.startTest();
  				Service_Catalog_categorycontroller SCat_cont = new Service_Catalog_categorycontroller();
				String catURL = Service_Catalog_categorycontroller.getcatalogEntryUrlConst();
				System.assertEquals(orgURL,catURL);
				List<String> catResults = Service_Catalog_categorycontroller.getCategories();
				System.assert(catResults.size()>0);

  				Test.stopTest();  
         
         }
         

}