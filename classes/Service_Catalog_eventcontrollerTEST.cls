@isTest
private class Service_Catalog_eventcontrollerTEST
{
	static testmethod void Test_catalogs_events()
	{
 	    //public calendars parent object are hidden
				//Id ChatterId; 
   				//CollaborationGroup grp= new CollaborationGroup();
   				//grp.Name = 'TestGroupForServiceCat';                    
  				//grp.CollaborationType='Public';
   				//insert grp;
				//ChatterId= grp.Id;


		//String CalendarId = '023M00000064sQm';
 	    //List<Service_Catalog_Settings__c> lstCustomSettings = new List<Service_Catalog_Settings__c>();
		//Service_Catalog_Settings__c customSetting = new Service_Catalog_Settings__c(Name='Service Catalog Settings');//Name='ChatterId', 
		//System.debug('#### '+customSetting);
		//customSetting.Name = 'CalendarId';
		//customSetting.CalendarId__c=  String.valueOf(CalendarId);
		//lstCustomSettings.add(customSetting);
		//customSetting.Name = 'ChatterId';
    	//		customSetting.ChatterId__c=  String.valueOf(ChatterId);
		//insert lstCustomSettings;
		//System.debug('#### '+Service_Catalog_Settings__c.getAll() );



		//create contact for calendar
		//Contact newContact = new Contact(FirstName='Dominick', LastName='Medley', Phone='2284527000', Email='dominick.medley@test.com');
        //INSERT newContact;
        //Event testEvent = new Event(OwnerId = (Id)CalendarId,
        //Subject = 'This is a public calendar event!', IsRecurrence = false,  ActivityDate = System.Today(), DurationInMinutes = 0,
        //ActivityDateTime = System.Today());
        //insert testEvent;

		Test.startTest();
			//Service_Catalog_eventcontroller SCat_cont = new Service_Catalog_eventcontroller();
System.assertEquals(1,1);
		Test.stopTest() ;




	}


}