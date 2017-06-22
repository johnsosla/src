public class HelperMethods {

 
    // Returns a dynamic SOQL statement for the whole object, 
    // includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
 


    
    //  -------------------------------------------------------------------------
//  HELPER method: sendTemplatedEmail
//  
//  Needs work
//  -------------------------------------------------------------------------
public static void sendTemplatedEmail(String[] toRecipients, String[] ccRecipients, String templateApiName, ID targetObjId, Id whatId, ID orgWideEmailId, Boolean saveAsActivity, Attachment[] attachList ) {
 
    // debug code
    //List<String> myEmail = new List<String> { 'luke.farbotko@aecom.com' };
	//Opportunity o = [select id from Opportunity where id = '006e0000005QhNz' limit 1];
	//HelperMethods.sendTemplatedEmail(myEmail, null, 'ANZ_Client_Bid_Activity_Template', null, o.id, null, false, null);
    
    try{
        
        // Pick a dummy Contact
        Contact c = [select id, Email from Contact where  email like '%l.com' limit 1];
     
        // Construct the list of emails we want to send
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
     
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId( [select id from EmailTemplate where DeveloperName= : templateApiName].id );
        msg.setWhatId(whatId);
        msg.setTargetObjectId(c.id);
        msg.setToAddresses(toRecipients);
        msg.setSaveAsActivity(saveAsActivity);
        
        lstMsgs.add(msg);
        
        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();
        try{Messaging.sendEmail(lstMsgs);}catch(EmailException e){}
        
       	Database.rollback(sp);
        
        // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
        // contents to a new SingleEmailMessage. Then send those new messages.
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : lstMsgs) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            lstMsgsToSend.add(emailToSend);
        }
        Messaging.sendEmail(lstMsgsToSend);
	}
  	catch (EmailException e) {}
}  
    
    
     //  -------------------------------------------------------------------------
    //  HELPER method: sendTemplatedEmail
    //  
    //  Needs work
    //  -------------------------------------------------------------------------
    public static void sendHTMLEmail(String[] toRecipients, string HTMLBody, string subject ) {
 
    try{

       		List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(toRecipients);
            emailToSend.setHTMLBody(HTMLBody);
            emailToSend.setSubject(subject);
        
            lstMsgs.add(emailToSend);
       		Messaging.sendEmail(lstMsgs);
          
	}
  	catch (EmailException e) {}
}  
    
    
    
    
}