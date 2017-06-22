/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM DTW
*              CLASS: DTW_EmailPlugin
*              PURPOSE: Plugin class for process builder to enable sending apex emails from process builder.
*                       This is needed to work around the known defect in Salesforce where email alerts do 
*                       not merge VF templates properly (https://success.salesforce.com/issues_view?id=a1p30000000SdBfAAK)
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
global class DTW_EmailPlugin {

	@InvocableMethod(label='Send Email' description='Sends email to specified user with specified template name')
	global static void sendEmail(List<SendEmailRequest> requests) {
        // Invoke handler class dynamically in order to avoid hard link to actual code.
        // This is to avoid a known bug in Salesforce where making updates to a process builder plugin makes any associated actions dissapear from the process builder UI
        Type t = Type.forName('DTW_EmailPluginHandler');
        IEmailPluginHandler handler = (IEmailPluginHandler) t.newInstance();
        handler.handle(requests);
     }
    
    global class SendEmailRequest {
        @InvocableVariable(required=true)
        public ID userId;
        
        @InvocableVariable(required=true)
	    public String emailTemplateName;

        @InvocableVariable(required=false)
        public ID relatedObjectId;

        @InvocableVariable(required=false)
        public String globalEmailAddressName;
    }

    public interface IEmailPluginHandler {
        void handle(List<SendEmailRequest> requests);
    }
}