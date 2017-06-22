public without sharing class ECO_Utils_Activities {

    private System.LoggingLevel debugLevel = LoggingLevel.INFO;
    
    public class Attendee {
        public String Id {get; set;}
        public String Name {get; set;}
        public String Phone {get; set;}
        public String Email {get; set;}
        
        public Attendee(String i, String n, String p, String e) {
            this.Id = i;
            this.Name = n;
            this.Phone = p;
            this.Email = e;
        }
    }

    public static List<EventRelation> getInvitees(String myEventId) {
        return new List<EventRelation>([Select 	Id, 
        										RelationId, 
        										Relation.Name, 
        										Relation.Phone, 
        										Relation.Email, 
        										EventId 
                                        From EventRelation 
                                        Where IsInvitee = true 
                                        And EventId = :myEventId]);
    }
    
	public static List<Attendee> getAttendees(String myEventId) {
		return getAttendees(getInvitees(myEventId));	
    }
        
    public static List<Attendee> getAttendees(List<EventRelation> myInvitees) {
        Set<Id> contactAttendeeIDs = new Set<Id>();
        Set<Id> userAttendeeIDs = new Set<Id>();
        Set<Id> leadAttendeeIDs = new Set<Id>();
        
        for(EventRelation oER : myInvitees) {
            Schema.SObjectType objType = oER.RelationId.getSObjectType();
            Schema.DescribeSObjectResult oDSOR = objType.getDescribe();
            if (oDSOR.getName() == 'Contact') { 
                contactAttendeeIDs.add(oER.RelationId);
            }
            if (oDSOR.getName() == 'User') {
                userAttendeeIDs.add(oER.RelationId);
            }
            if (oDSOR.getName() == 'Lead') {
                leadAttendeeIDs.add(oER.RelationId);
            }
        }
        
        List<Attendee> myAttendees = new List<Attendee>();

        if (!contactAttendeeIDs.isEmpty()) {
            for (Contact c : [Select Id, Name, Phone, Email From Contact Where Id In :contactAttendeeIDs]) {
                myAttendees.add(new Attendee(c.Id, c.Name, c.Phone, c.Email));
            }
        }
        
        if (!userAttendeeIDs.isEmpty()) {
            for (User u : [Select Id, Name, Phone, Email From User Where Id In :userAttendeeIDs]) {
                myAttendees.add(new Attendee(u.Id, u.Name, u.Phone, u.Email));
            }
        }
        
        if (!leadAttendeeIDs.isEmpty()) {
            for (Lead l : [Select Id, Name, Phone, Email From Lead Where Id In :leadAttendeeIDs]) {
                myAttendees.add(new Attendee(l.Id, l.Name, l.Phone, l.Email));
            }
        }
        return myAttendees;
    }
  }