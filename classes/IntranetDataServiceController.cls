public with sharing class IntranetDataServiceController extends ECO_PageControllerBase {
    public final User user;
	public User theUser { get; set; }
    public String theUserEmail { get; set; }
    public String photoUrl { get; set; }
    public List<Configuration__c> applications { get; set; }
	public List<ProcessInstanceWorkitem> approvals { get; set; }   
	public List<Task> tasks { get; set; }
	public List<PortalMessage__c> alerts { get; set; }    
    public IntranetDataServiceController() {
        user = ECO_Service_Users.getUserInfoById(UserInfo.getUserId());
        theUser = ECO_Service_Users.getUserInfoById(UserInfo.getUserId());
        theUserEmail = UserInfo.getUserEmail();
        photoUrl = ConnectApi.ChatterUsers.getPhoto(null, theUser.Id).smallPhotoUrl;
        applications = ECO_Service_Applications.getSortedList(theUser);
        approvals = ECO_Service_Users.getApprovalsForUser(theUser.Id);
		tasks = ECO_Service_Users.getOpenTasksForUser(theUser.Id);
		alerts = ECO_Utils_Alerts.getPortalMessagesForUser(theUser.Id);        
    } 
}