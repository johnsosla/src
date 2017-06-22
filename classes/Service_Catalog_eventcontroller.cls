public class Service_Catalog_eventcontroller 
{
   
        public String CalendarUrl {get; set;}
        public String catalogEntryUrlConst {get; set;}

         List<cEvent> getEvents = new List<cEvent>();
        public class cEvent
        {
            public ID nid {get; set;}
            public String nMonthName {get; set;}
            public String nDay {get; set;}
            public DateTime nStartDateTime {get; set;}
            public String nSubject {get; set;}
            public DateTime nEndDateTime {get; set;}
            public String catalogEntryUrlConst {get; set;}

            public cEvent(Event n)
            {
                this.nid=n.id;
                this.nSubject=n.Subject;
                this.nStartDateTime=n.StartDateTime;
                this.nEndDateTime=n.EndDateTime;
                this.nMonthName = n.StartDateTime.format('MMM');
                this.nDay=n.StartDateTime.format('dd');
                
                List<Service_Catalog_Settings__c> cal = Service_Catalog_Settings__c.getall().values();
                this.catalogEntryUrlConst = cal[0].catalogEntryUrlConst__c;

            }
        }
    
    public Service_Catalog_eventcontroller()
    {
        List<Service_Catalog_Settings__c> cal = Service_Catalog_Settings__c.getall().values();
        String calendarId = cal[0].CalendarId__c;

        for(Event e: [SELECT Id,Subject, StartDateTime, EndDateTime FROM Event where OwnerId  = :calendarId and StartDateTime > Yesterday order by StartDateTime Desc])
        {
            getEvents.add(new cEvent(e));
            List<Service_Catalog_Settings__c> calLink = Service_Catalog_Settings__c.getall().values();
            CalendarUrl = calLink[0].CalendarUrl__c;
        } 
        
        catalogEntryUrlConst = cal[0].catalogEntryUrlConst__c;
    }    
    
    public List <cEvent> geteventData() 
    {
        return getEvents;
    }






}