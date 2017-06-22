public with sharing class ECO_DTO_ProjectTeamMember {
	public ProjectTeamMember__c member {get; set;}
	public Boolean selected {get; set;}

	public ECO_DTO_ProjectTeamMember(ProjectTeamMember__c member) {
		this.member = member;
	}
}