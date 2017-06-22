public class ECO_ProjectTeamMemberRedirectController {
	
	public ProjectTeamMember__c projectTeamMember {get; set;}

	public ECO_ProjectTeamMemberRedirectController(ApexPages.StandardController standardController) {
		projectTeamMember = (ProjectTeamMember__c)standardController.getRecord();
	}

	public PageReference redirect()
	{
		return new PageReference('/' + projectTeamMember.Id + '/e?nooverride=1&retURL=/apex/ECO_Stakeholders?id='+projectTeamMember.Project__c);
	}
}